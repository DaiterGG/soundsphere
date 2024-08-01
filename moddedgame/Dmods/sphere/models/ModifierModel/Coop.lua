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

Coop.description = "Double the input mode and alternate the map between \nleft and right every 'value' seconds"

---@param config table
---@return string
---@return string
function Coop:getString(config)
	return tostring(config.value), "COO"
end

---@param config table
function Coop:apply(config, chart)
	chart.notes:sort()
	local move = false
	local currentTime
	for _, n in ipairs(chart.notes:getLinkedNotes()) do
		if n.startNote.type == "note" or n.startNote.type == "hold" then
			if not currentTime or currentTime + config.value < n.startNote:getTime() then
				currentTime = n.startNote:getTime()
				move = not move
			end
			if move then
				local type, new_column = InputMode:splitInput(n.startNote.column)
				new_column = type .. (new_column + chart.inputMode.key)
				n.startNote.column = new_column
				if n.endNote then
					n.endNote.column = new_column
				end
			end
		end
	end

	chart.inputMode.key = chart.inputMode.key * 2
	chart:compute()
end

return Coop
