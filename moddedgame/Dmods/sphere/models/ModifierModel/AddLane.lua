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
---@param state table
function AddLane:applyMeta(config, state)
	local columnCount = state.inputMode.key
	if not columnCount then
		return
	end
	state.inputMode.key = state.inputMode.key + config.value
end


---@param config table
function AddLane:apply(config, chart)
	chart.inputMode.key = chart.inputMode.key + config.value
	chart:compute()
end

return AddLane
