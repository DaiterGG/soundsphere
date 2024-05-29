local NoteData = require("ncdk.NoteData")
local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.Coop: sphere.Modifier
---@operator call: sphere.Coop
local Coop = Modifier + {}

Coop.name = "Coop"

Coop.defaultValue = 20
Coop.values = {}
for i = 1, 5 do
		table.insert(Coop.values, i * 10)
end

Coop.description = "Double the input mode and alternate the map between \nleft and right every value seconds"

---@param config table
---@return string
---@return string
function Coop:getString(config)
	return tostring(config.value), "COO"
end


---@param config table
function Coop:apply(config)
	local noteChart = self.noteChart
	local inputMode = noteChart.inputMode
	local oldKeymod = inputMode.key
	inputMode.key = inputMode.key * 2

	local notes = {}
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		for i, noteData in ipairs(noteDatas) do
			if noteData.noteType == "ShortNote" and
				noteData.endNoteData
			then
				noteData.endNoteData.noteType = "Ignore"
			end
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart"
			then
				table.insert(notes, {
					noteData = noteData,
					inputIndex = inputIndex,
					inputType = inputType,
					layerDataIndex = layerDataIndex,
				})
			end
		end
	end
	table.sort(notes, function(a, b)
		return a.noteData.timePoint < b.noteData.timePoint
	end)
	local keyValue = inputMode.key
	for _, layerData in noteChart:getLayerDataIterator() do
		for i = 1 , keyValue do
			layerData.noteDatas["key"][i] = layerData.noteDatas["key"][i] or {}
		end
	end

	local move = false
	local currentTime
	for _, n in ipairs(notes) do
		--config.value
		if nil == currentTime or currentTime + config.value < n.noteData.timePoint.absoluteTime then
			currentTime = n.noteData.timePoint.absoluteTime
			move = move == false --internet went off Idk how to do not in lua lol
		end
		if move then
			local newIndex = n.inputIndex + oldKeymod
			local datas = noteChart.layerDatas[n.layerDataIndex].noteDatas[n.inputType]
			datas[newIndex] = datas[newIndex] or {}
			local newND = n.noteData:clone()
			if newND.endNoteData then
				newND.endNoteData = newND.endNoteData:clone()
				noteChart.layerDatas[n.layerDataIndex]:addNoteData(newND.endNoteData, n.inputType, newIndex)
				n.noteData.endNoteData.noteType = "Ignore"
			end
			noteChart.layerDatas[n.layerDataIndex]:addNoteData(newND, n.inputType, newIndex)
			n.noteData.noteType = "Ignore"
		end
	end
		

	noteChart:compute()
end

return Coop
