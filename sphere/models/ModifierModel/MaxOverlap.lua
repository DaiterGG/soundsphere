local Modifier = require("sphere.models.ModifierModel.Modifier")

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
function MaxOverlap:apply(config, noteChart)
	local limit = config.value

	local notes = {}
	for _, noteData in noteChart.notes:iter() do
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
			})
		end
	end

	table.sort(notes, function(a, b)
		if a.noteData.visualPoint.point.absoluteTime < b.noteData.visualPoint.point.absoluteTime then
			return true
		elseif a.noteData.visualPoint == b.noteData.visualPoint then
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
				note.noteData.endNote.noteType = "Ignore"
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
