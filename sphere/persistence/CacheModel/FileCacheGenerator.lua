local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.FileCacheGenerator
---@operator call: sphere.FileCacheGenerator
local FileCacheGenerator = class()

---@param chartRepo sphere.ChartRepo
---@param noteChartFinder sphere.NoteChartFinder
function FileCacheGenerator:new(chartRepo, noteChartFinder)
	self.chartRepo = chartRepo
	self.noteChartFinder = noteChartFinder
end

---@param root_dir string
function FileCacheGenerator:lookup(root_dir)
	local iterator = self.noteChartFinder:iter(root_dir)
	local chartfile_set

	local typ, dir, name, modtime = iterator()
	while typ do
		local res
		if typ == "related_dir" then
			chartfile_set = self:processChartfileSet(dir, name, modtime, false)
		elseif typ == "related" then
			self:processChartfile(chartfile_set.id, name, modtime)
		elseif typ == "related_all" then
			self.chartRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
		elseif typ == "unrelated_dir" then
		elseif typ == "unrelated" then
			chartfile_set = self:processChartfileSet(dir, name, modtime, true)
			self:processChartfile(chartfile_set.id, name, modtime)
		elseif typ == "unrelated_all" then
			self.chartRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
			self.chartRepo:deleteChartfileSets({dir = dir, name__notin = name})
		elseif typ == "directory_dir" then
		elseif typ == "directory" then
			res = self:shouldScan(dir, name, modtime)
		elseif typ == "directory_all" then
			self.chartRepo:deleteChartfileSets({dir = dir, name__notin = name})
		end
		typ, dir, name, modtime = iterator(res)
	end
end

---@param dir string
---@param name string
---@param modified_at number
---@return boolean
function FileCacheGenerator:shouldScan(dir, name, modified_at)
	local chartfile_set = self.chartRepo:selectChartfileSet(dir, name)
	if not chartfile_set then
		return true
	end
	if chartfile_set.modified_at ~= modified_at then
		return true
	end
	return false
end

---@param dir string
---@param name string
---@param modified_at number
---@param is_file boolean
---@return table
function FileCacheGenerator:processChartfileSet(dir, name, modified_at, is_file)
	local chartfile_set = self.chartRepo:selectChartfileSet(dir, name)

	if chartfile_set then
		if chartfile_set.modified_at ~= modified_at then
			chartfile_set.modified_at = modified_at
			self.chartRepo:updateChartfileSet(chartfile_set)
		end
		return chartfile_set
	end

	return self.chartRepo:insertChartfileSet({
		dir = dir,
		name = name,
		modified_at = modified_at,
		is_file = is_file,
	})
end

---@param name string
---@param set_id number
---@param modified_at number
function FileCacheGenerator:processChartfile(set_id, name, modified_at)
	local chartfile = self.chartRepo:selectChartfile(set_id, name)

	if not chartfile then
		self.chartRepo:insertChartfile({
			name = name,
			modified_at = modified_at,
			set_id = set_id,
		})
		return
	end

	if chartfile.modified_at ~= modified_at then
		chartfile.hash = sql_util.NULL
		chartfile.modified_at = modified_at
		self.chartRepo:updateChartfile(chartfile)
	end
end

return FileCacheGenerator
