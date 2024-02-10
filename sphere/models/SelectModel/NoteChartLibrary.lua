local class = require("class")
local path_util = require("path_util")

---@class sphere.NoteChartLibrary
---@operator call: sphere.NoteChartLibrary
local NoteChartLibrary = class()

NoteChartLibrary.set_id = 0
NoteChartLibrary.itemsCount = 0

---@param cacheModel sphere.CacheModel
function NoteChartLibrary:new(cacheModel)
	self.cacheModel = cacheModel
	self.items = {}
end

function NoteChartLibrary:clear()
	self.items = {}
end

---@param set_id number
function NoteChartLibrary:setNoteChartSetId(set_id)
	if set_id == self.set_id then
		return
	end
	self.set_id = set_id
	self.items = self.cacheModel.cacheDatabase:getChartviewsAtSet(set_id)
	for i, chart in ipairs(self.items) do
		chart.location_prefix = path_util.join("mounted_charts", chart.location_id)
		chart.location_dir = path_util.join("mounted_charts", chart.location_id, chart.dir)
		chart.location_path = path_util.join("mounted_charts", chart.location_id, chart.path)
	end
end

---@param chartfile_id number?
---@param chartmeta_id number?
---@return number
function NoteChartLibrary:getItemIndex(chartfile_id, chartmeta_id)
	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartmeta_id == chartmeta_id then
			return i
		end
	end
	return 1
end

return NoteChartLibrary
