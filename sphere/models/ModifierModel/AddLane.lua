local NoteData = require("ncdk.NoteData")
local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.AddLane: sphere.Modifier
---@operator call: sphere.AddLane
local AddLane = Modifier + {}

AddLane.name = "AddLane"

AddLane.defaultValue = 1
AddLane.values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

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
	local inputMode = noteChart.inputMode
	local keyValue = inputMode["key"]
	keyValue = keyValue + config.value
	for _, layerData in noteChart:getLayerDataIterator() do
		for i = 1 , keyValue do
			layerData.noteDatas["key"][i] = layerData.noteDatas["key"][i] or {}
		end
	end
	noteChart:compute()
end

return AddLane
