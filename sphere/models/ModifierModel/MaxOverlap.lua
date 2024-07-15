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

MaxOverlap.description = "Limit the amount of LN overlap at any point"

---@param config table
---@return string
---@return string
function MaxOverlap:getString(config)
	return "MO", tostring(config.value)
end

---@param config table
function MaxOverlap:apply(config, chart)
	local limit = config.value

	table.sort(chart.notes, function(a, b)
		if a:getTime() < b:getTime() then
			return a.noteType == "LongNoteEnd" and b.noteType ~= "LongNoteEnd"
		else
			return a < b
		end
	end)
	local overlapCount = -1
	for _, note in chart.notes:iter() do
		if note.noteType == "LongNoteStart" then
			if overlapCount >= limit then
				note.noteType = "ShortNote"
				note.endNote.noteType = "Ignore"
			else
				overlapCount = overlapCount + 1
			end
		elseif note.noteType == "LongNoteEnd" then
			overlapCount = overlapCount - 1
		end
	end
	chart:compute()
end

return MaxOverlap
