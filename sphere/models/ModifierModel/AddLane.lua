local NoteData = require("ncdk.NoteData")
local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.AddLane: sphere.Modifier
---@operator call: sphere.AddLane
local AddLane = Modifier + {}

AddLane.name = "AddLane"

AddLane.defaultValue = 1
AddLane.values = {1, 2, 3, 4, 5 , 6, 7, 8, 9, 10}

AddLane.description = "Insert empty columns (to the right)"

---@param config table
---@return string
---@return string
function AddLane:getString(config)
	return tostring(config.value), "ADD"
end

---@param config table
function AddLane:apply(config)
	local noteChart = self.noteChart
	local value = config.value

	local inputMode = noteChart.inputMode

	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount + value
	end

	noteChart:compute()
end

return AddLane
