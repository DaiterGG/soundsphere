local class = require("class")
local math_util = require("math_util")

---@class sphere.GraphsGenerator
---@operator call: sphere.GraphsGenerator
local GraphsGenerator = class()

function GraphsGenerator:load()
	self.densityGraph = {}
	self.intervalDatasGraph = {n = 0}
end

---@param noteChart ncdk.NoteChart
---@param firstTime number
---@param lastTime number
function GraphsGenerator:genDensityGraph(noteChart, firstTime, lastTime)
	local notes = {}
	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			local offset = noteData.timePoint.absoluteTime
			if noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart" then
				table.insert(notes, offset)
			end
		end
	end
	table.sort(notes)

	local pointsCount = math.floor(lastTime - firstTime) * 2

	if pointsCount == 0 then
		return
	end

	self.densityGraph = {}
	local points = self.densityGraph
	for i = 0, pointsCount do
		points[i] = 0
	end

	local maxValue = 0
	for _, time in ipairs(notes) do
		local pos = math_util.map(time, firstTime, lastTime, 0, pointsCount)
		local i = math.floor(pos + 0.5)
		points[i] = points[i] + 1
		maxValue = math.max(maxValue, points[i])
	end

	for i = 0, pointsCount do
		points[i] = points[i] / maxValue
	end
end

---@param layerData ncdk.DynamicLayerData
---@param firstTime number
---@param lastTime number
function GraphsGenerator:genIntervalDatasGraph(layerData, firstTime, lastTime)
	local intervalDatas = layerData.ranges.interval

	local offsets = {}
	local id = intervalDatas.first
	while id and id <= intervalDatas.last do
		table.insert(offsets, id.timePoint.absoluteTime)
		id = id.next
	end
	table.sort(offsets)

	local pointsCount = 2000

	self.intervalDatasGraph = {n = pointsCount}
	local points = self.intervalDatasGraph

	for _, time in ipairs(offsets) do
		local pos = math_util.map(time, firstTime, lastTime, 0, pointsCount)
		local i = math.floor(pos + 0.5)
		points[i] = true
	end
end

return GraphsGenerator
