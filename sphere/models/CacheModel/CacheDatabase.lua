local TimedCache = require("TimedCache")
local thread = require("thread")
local Orm = require("sphere.Orm")
local ObjectQuery = require("sphere.ObjectQuery")
local ffi = require("ffi")
local class = require("class")

---@class sphere.CacheDatabase
---@operator call: sphere.CacheDatabase
local CacheDatabase = class()

CacheDatabase.dbpath = "userdata/charts.db"

function CacheDatabase:load()
	if self.loaded then
		return
	end
	self.db = Orm()
	local db = self.db
	db:open(self.dbpath)
	local sql = love.filesystem.read("sphere/models/CacheModel/database.sql")
	db:exec(sql)
	self:attachScores()
	self.loaded = true

	self.noteChartSetItemsCount = 0
	self.noteChartSetItems = {}
	self.noteChartItemsCount = 0
	self.noteChartItems = {}
	self.noteChartSlices = {}
	self.set_id_to_global_offset = {}
	self.id_to_global_offset = {}
	self.id_to_local_offset = {}

	local entryCaches = {}
	for _, t in ipairs({"noteChartSets", "noteCharts", "noteChartDatas"}) do
		entryCaches[t] = TimedCache()
		entryCaches[t].timeout = 1
		entryCaches[t].loadObject = function(_, id)
			local status, entries = pcall(db.select, db, t, "id = ?", id)
			if not status then
				return
			end
			return entries[1]
		end
	end
	self.entryCaches = entryCaches

	self.queryParams = {}
end

function CacheDatabase:unload()
	if not self.loaded then
		return
	end
	self.loaded = false
	self:detachScores()
	return self.db:close()
end

function CacheDatabase:attachScores()
	self.db:exec("ATTACH 'userdata/scores.db' AS scores_db")
end

function CacheDatabase:detachScores()
	self.db:exec("DETACH scores_db")
end

----------------------------------------------------------------

---@param t string
---@param id number
---@return table?
function CacheDatabase:getCachedEntry(t, id)
	return self.entryCaches[t]:getObject(id)
end

function CacheDatabase:update()
	for _, entryCache in pairs(self.entryCaches) do
		entryCache:update()
	end
end

----------------------------------------------------------------

ffi.cdef([[
	typedef struct {
		int32_t noteChartDataId;
		int32_t noteChartId;
		int32_t setId;
		int32_t scoreId;
		bool lamp;
	} EntryStruct
]])

CacheDatabase.EntryStruct = ffi.typeof("EntryStruct")

---@param object table
---@param row table
---@param colnames table
local function fillObject(object, row, colnames)
	for i, k in ipairs(colnames) do
		local value = row[i]
		if k:find("^__boolean_") then
			k = k:sub(11)
			if tonumber(value) == 1 then
				value = true
			else
				value = false
			end
		elseif type(value) == "cdata" then
			value = tonumber(value) or value
		end
		object[k] = value or 0
	end
end

function CacheDatabase:queryAll()
	self:queryNoteChartSets()
	self:queryNoteCharts()
	self:reassignData()
end

local _asyncQueryAll = thread.async(function(queryParams)
	local time = love.timer.getTime()
	local ffi = require("ffi")
	local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
	local self = CacheDatabase()
	self:load()
	self.queryParams = queryParams
	local status, err = pcall(self.queryAll, self)
	if not status then
		return
	end
	local t = {
		noteChartSetItemsCount = self.noteChartSetItemsCount,
		noteChartItemsCount = self.noteChartItemsCount,
		noteChartSlices = self.noteChartSlices,
		set_id_to_global_offset = self.set_id_to_global_offset,
		id_to_global_offset = self.id_to_global_offset,
		id_to_local_offset = self.id_to_local_offset,
		noteChartSetItems = ffi.string(self.noteChartSetItems, ffi.sizeof(self.noteChartSetItems)),
		noteChartItems = ffi.string(self.noteChartItems, ffi.sizeof(self.noteChartItems)),
	}
	self:unload()

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d + %d bytes"):format(#t.noteChartSetItems, #t.noteChartItems))
	return t
end)

function CacheDatabase:asyncQueryAll()
	local t = _asyncQueryAll(self.queryParams)
	if not t then
		return
	end

	self.noteChartSetItemsCount = t.noteChartSetItemsCount
	self.id_to_global_offset = t.id_to_global_offset
	self.set_id_to_global_offset = t.set_id_to_global_offset
	self.noteChartItemsCount = t.noteChartItemsCount
	self.noteChartSlices = t.noteChartSlices
	self.id_to_local_offset = t.id_to_local_offset

	local size = ffi.sizeof("EntryStruct")
	self.noteChartSetItems = ffi.new("EntryStruct[?]", #t.noteChartSetItems / size)
	self.noteChartItems = ffi.new("EntryStruct[?]", #t.noteChartItems / size)
	ffi.copy(self.noteChartSetItems, t.noteChartSetItems, #t.noteChartSetItems)
	ffi.copy(self.noteChartItems, t.noteChartItems, #t.noteChartItems)
end

function CacheDatabase:queryNoteChartSets()
	local params = self.queryParams

	local objectQuery = ObjectQuery()

	objectQuery.db = self.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.setId",
		"scores.id AS scoreId",
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")
	objectQuery:setLeftJoin("scores", [[
		noteChartDatas.hash = scores.noteChartHash AND
		noteChartDatas.`index` = scores.noteChartIndex AND
		scores.isTop = TRUE
	]])

	if params.lamp then
		table.insert(objectQuery.fields, objectQuery:newBooleanCase("lamp", params.lamp))
	end

	objectQuery.where = params.where
	objectQuery.groupBy = params.groupBy
	objectQuery.orderBy = params.orderBy

	local count = objectQuery:getCount()
	local noteChartSets = ffi.new("EntryStruct[?]", count)
	local id_to_global_offset = {}
	local set_id_to_global_offset = {}
	self.noteChartSetItems = noteChartSets
	self.id_to_global_offset = id_to_global_offset
	self.set_id_to_global_offset = set_id_to_global_offset

	local stmt = self.db:stmt(objectQuery:getQueryParams())
	local colnames = {}

	local row = stmt:step({}, colnames)
	local i = 0
	while row do
		local entry = noteChartSets[i]
		fillObject(entry, row, colnames)
		set_id_to_global_offset[entry.setId] = i
		id_to_global_offset[entry.noteChartId] = i
		i = i + 1
		row = stmt:step(row)
	end
	stmt:close()
	self.noteChartSetItemsCount = i
end

function CacheDatabase:queryNoteCharts()
	local params = self.queryParams

	local objectQuery = ObjectQuery()

	self:load()
	objectQuery.db = self.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.setId",
		"scores.id AS scoreId",
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")
	objectQuery:setLeftJoin("scores", [[
		noteChartDatas.hash = scores.noteChartHash AND
		noteChartDatas.`index` = scores.noteChartIndex AND
		scores.isTop = TRUE
	]])

	if params.lamp then
		table.insert(objectQuery.fields, objectQuery:newBooleanCase("lamp", params.lamp))
	end

	objectQuery.where = params.where
	objectQuery.groupBy = nil
	objectQuery.orderBy = [[
		noteCharts.setId ASC,
		length(noteChartDatas.inputMode) ASC,
		noteChartDatas.inputMode ASC,
		noteChartDatas.difficulty ASC,
		noteChartDatas.name ASC,
		noteChartDatas.id ASC
	]]

	local count = objectQuery:getCount()
	local noteCharts = ffi.new("EntryStruct[?]", count)
	local slices = {}
	local id_to_local_offset = {}
	self.noteChartItems = noteCharts
	self.noteChartSlices = slices
	self.id_to_local_offset = id_to_local_offset

	local stmt = self.db:stmt(objectQuery:getQueryParams())
	local colnames = {}

	local offset = 0
	local size = 0
	local setId
	local row = stmt:step({}, colnames)
	local i = 0
	while row do
		local entry = noteCharts[i]
		fillObject(entry, row, colnames)
		if setId and setId ~= entry.setId then
			slices[setId] = {
				offset = offset,
				size = size,
			}
			offset = i
		end
		size = i - offset + 1
		setId = entry.setId
		id_to_local_offset[entry.noteChartId] = i - offset
		i = i + 1
		row = stmt:step(row)
	end
	if setId then
		slices[setId] = {
			offset = offset,
			size = size,
		}
	end
	stmt:close()
	self.noteChartItemsCount = i
end

function CacheDatabase:reassignData()
	if not self.queryParams.groupBy then
		return
	end

	for i = 0, self.noteChartSetItemsCount - 1 do
		local entry = self.noteChartSetItems[i]
		local setId = entry.setId
		local slice = self.noteChartSlices[setId]

		local lastScoreId = 0
		local currentEntry = entry
		local lamp = false

		for j = slice.offset, slice.offset + slice.size - 1 do
			local entry = self.noteChartItems[j]
			if entry.lamp then
				lamp = true
			end
			if entry.scoreId > lastScoreId then
				lastScoreId = entry.scoreId
				currentEntry = entry
			end
		end

		entry.noteChartDataId = currentEntry.noteChartDataId
		entry.noteChartId = currentEntry.noteChartId
		entry.scoreId = currentEntry.scoreId
		entry.lamp = lamp
	end
end

return CacheDatabase
