local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.FileCacheGenerator
---@operator call: sphere.FileCacheGenerator
local FileCacheGenerator = class()

---@param chartfilesRepo sphere.ChartfilesRepo
---@param noteChartFinder sphere.NoteChartFinder
---@param handle function
function FileCacheGenerator:new(chartfilesRepo, noteChartFinder, handle)
	self.chartfilesRepo = chartfilesRepo
	self.noteChartFinder = noteChartFinder
	self.handle = handle
end

---@param root_dir string?
---@param location_id number
---@param location_prefix string?
function FileCacheGenerator:lookup(root_dir, location_id, location_prefix)
	local iterator = self.noteChartFinder:iter(location_prefix, root_dir)
	local chartfile_set, chartfile
	local handle = self.handle

	local typ, dir, name, modtime = iterator()
	while typ do
		local res
		if typ == "related_dir" then
			chartfile_set = self:processChartfileSet({
				dir = dir,
				name = name,
				modified_at = modtime,
				is_file = false,
				location_id = location_id,
			})
		elseif typ == "related" then
			chartfile = self:processChartfile(chartfile_set.id, name, modtime)
			handle(chartfile)
		elseif typ == "related_all" then
			self.chartfilesRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
		elseif typ == "unrelated_dir" then
		elseif typ == "unrelated" then
			chartfile_set = self:processChartfileSet({
				dir = dir,
				name = name,
				modified_at = modtime,
				is_file = true,
				location_id = location_id,
			})
			chartfile = self:processChartfile(chartfile_set.id, name, modtime)
			handle(chartfile)
		elseif typ == "unrelated_all" then
			self.chartfilesRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
			self.chartfilesRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name__notin = name,
				location_id = location_id,
			})
		elseif typ == "directory_dir" then
		elseif typ == "directory" then
			res = self:shouldScan(dir, name, modtime)
		elseif typ == "directory_all" then
			self.chartfilesRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name__notin = name,
				location_id = location_id,
			})
		elseif typ == "not_found" then
			self.chartfilesRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name = name,
				location_id = location_id,
			})
		end
		typ, dir, name, modtime = iterator(res)
	end
end

---@param dir string?
---@param name string
---@param modified_at number
---@return boolean
function FileCacheGenerator:shouldScan(dir, name, modified_at)
	local chartfile_set = self.chartfilesRepo:selectChartfileSet(dir, name)
	if not chartfile_set then
		return true
	end
	if chartfile_set.modified_at ~= modified_at then
		return true
	end
	return false
end

---@param chartfile_set table
---@return table
function FileCacheGenerator:processChartfileSet(chartfile_set)
	local _chartfile_set = self.chartfilesRepo:selectChartfileSet(
		chartfile_set.dir,
		chartfile_set.name
	)

	if _chartfile_set then
		if _chartfile_set.modified_at ~= chartfile_set.modified_at then
			_chartfile_set.modified_at = chartfile_set.modified_at
			self.chartfilesRepo:updateChartfileSet(_chartfile_set)
		end
		return _chartfile_set
	end

	_chartfile_set = self.chartfilesRepo:insertChartfileSet(chartfile_set)

	return _chartfile_set
end

---@param name string
---@param set_id number
---@param modified_at number
---@return table
function FileCacheGenerator:processChartfile(set_id, name, modified_at)
	local chartfile = self.chartfilesRepo:selectChartfile(set_id, name)

	if not chartfile then
		return self.chartfilesRepo:insertChartfile({
			name = name,
			modified_at = modified_at,
			set_id = set_id,
		})
	end

	if chartfile.modified_at ~= modified_at then
		chartfile.hash = sql_util.NULL
		chartfile.modified_at = modified_at
		self.chartfilesRepo:updateChartfile(chartfile)
	end

	return chartfile
end

return FileCacheGenerator
