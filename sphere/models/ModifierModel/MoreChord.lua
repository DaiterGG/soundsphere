local NoteData = require("ncdk.NoteData")
local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")

---@class sphere.MoreChord: sphere.Modifier
---@operator call: sphere.MoreChord
local MoreChord = Modifier + {}

MoreChord.name = "MoreChord"

MoreChord.defaultValue = 1
MoreChord.values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

MoreChord.description = "Add notes to every chord"

---@param config table
---@return string
---@return string
function MoreChord:getString(config)
	return tostring(config.value), "MC"
end

---@param config table
function MoreChord:apply(config)
	local value = config.value
	local noteChart = self.noteChart

	local keyCount = noteChart.inputMode.key
	local sj = FixMap:findShortestJack(noteChart)
	print("shortest jack " .. sj)

	local notes = {}
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		if inputType == "key" then
			for i, noteData in ipairs(noteDatas) do
				if noteData.noteType == "ShortNote" or
					noteData.noteType == "LongNoteStart"
				then
					table.insert(notes, {
						noteData = noteData,
						column = inputIndex,
						time = noteData.timePoint.absoluteTime,
						layer = layerDataIndex,
					})
				end
			end
		end
	end

	local lines = {}
	for _, note in ipairs(notes) do
		local time = note.time
		lines[time] = lines[time] or {time = time}
		table.insert(lines[time], note)
	end

	for _, line in pairs(lines) do
		for i = 1, value do
			local rngIndex = math.random(1, keyCount)
			local rngNote = math.random(1, #line)
			local datas = noteChart.layerDatas[line[1].layer].noteDatas["key"]
			datas[rngIndex] = datas[rngIndex] or {}
			local newND = line[rngNote].noteData:clone()
			if newND.endNoteData then
				newND.endNoteData = newND.endNoteData:clone()
				noteChart.layerDatas[line[1].layer]:addNoteData(newND.endNoteData, "key", rngIndex)
			end
			noteChart.layerDatas[line[1].layer]:addNoteData(newND, "key", rngIndex)
		end
	end

	noteChart:compute()
	FixMap:applyFix(noteChart, sj)
end

return MoreChord
