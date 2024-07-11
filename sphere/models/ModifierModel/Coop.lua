local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
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
function Coop:apply(config, chart)
	

	local new_notes = {}
	for _, note in chart.notes:iter() do
		if note.noteType == "ShortNote" and
			note.endNote
		then
			note.endNote.noteType = "Ignore"
		end
		if
			note.noteType == "ShortNote" or
			note.noteType == "LongNoteStart"
		then
			table.insert(new_notes, {
				noteData = note,
			})
		end
	end
	table.sort(new_notes, function(a, b)
		return a.noteData < b.noteData
	end)
	
	local move = false
	local currentTime
	for _, n in ipairs(new_notes) do
		--config.value
		if not currentTime or currentTime + config.value < n.noteData.visualPoint.point.absoluteTime then
			currentTime = n.noteData.visualPoint.point.absoluteTime
			move = not move
		end
		if move then
			local type, new_column = InputMode:splitInput(n.noteData.column)
			new_column = type .. (new_column + chart.inputMode.key)
			n.noteData.column = new_column
			if n.noteData.endNote then
				n.noteData.endNote.column = new_column
			end
		end
	end

	chart.inputMode.key = chart.inputMode.key * 2
	chart:compute()
end

return Coop
