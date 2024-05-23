local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

---@class sphere.MaxOverlap
---@operator call: sphere.MaxOverlap
local MaxOverlap = Modifier + {}

MaxOverlap.name = "MaxOverlap"

MaxOverlap.defaultValue = 0
MaxOverlap.values = {}

for i = 0, 10 do
	table.insert(MaxOverlap.values, i)
end

MaxOverlap.description = "Limit amout of LN overlap at any point"

---@param config table
---@return string
---@return string
function MaxOverlap:getString(config)
	return "MO", tostring(config.value)
end

---@param config table
function MaxOverlap:apply(config)
	local limit = config.value
	local noteChart = self.noteChart

	local columns = noteChart.inputMode.key

	local notes = {}
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		if inputType == "key" then
			for i, noteData in ipairs(noteDatas) do
				if noteData.noteType == "ShortNote" and
					noteData.endNoteData
				then
					noteData.endNoteData.noteType = "Ignore"
				end
				if
					noteData.noteType == "ShortNote" or
					noteData.noteType == "LongNoteEnd" or
					noteData.noteType == "LongNoteStart"
				then
				table.insert(notes, {
					noteData = noteData,
					inputType = inputType,
					inputIndex = inputIndex,
					layerDataIndex = layerDataIndex,
				})
				end
			end
		end
	end

	table.sort(notes, function(a, b)
		if a.noteData.timePoint < b.noteData.timePoint then
			return true
		elseif a.noteData.timePoint == b.noteData.timePoint then
			return a.noteData.noteType == "LongNoteEnd" and b.noteData.noteType ~= "LongNoteEnd"
		else
			return false
		end
	end)
	local overlapCount = -1
	for _, note in ipairs(notes) do
		if note.noteData.noteType == "LongNoteStart" then
			if overlapCount >= limit then
				note.noteData.noteType = "ShortNote"
				note.noteData.endNoteData.noteType = "Ignore"
			else
				overlapCount = overlapCount + 1
			end
		elseif note.noteData.noteType == "LongNoteEnd" then
			overlapCount = overlapCount - 1
		end
	end
	noteChart:compute()
end

return MaxOverlap
