local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

---@class sphere.Mirror: sphere.SwapModifier
---@operator call: sphere.Mirror
local Mirror = SwapModifier + {}

Mirror.name = "Mirror"

Mirror.defaultValue = "all"
Mirror.values = {"all", "left", "right"}

Mirror.description = "Mirror the note chart"

---@param config table
---@return string
---@return string
function Mirror:getString(config)
	return "MR", config.value:sub(1, 1):upper()
end

---@param config table
---@return table
function Mirror:getMap(config)
	local noteChart = self.noteChart

	local inputMode = noteChart.inputMode

	local map = {}

	local value = config.value
	for inputType, inputCount in pairs(inputMode) do
		map[inputType] = {}
		local submap = map[inputType]

		for i = 1, inputCount do
			submap[i] = i
		end

		local halfFloor = math.floor(inputCount / 2)
		local halfCeil = math.ceil(inputCount / 2)
		if value == "all" then
			for i = 1, inputCount do
				submap[i] = inputCount - i + 1
			end
		elseif value == "left" then
			for i = 1, halfFloor do
				submap[i] = halfFloor - i + 1
			end
		elseif value == "right" then
			for i = 1, halfFloor do
				submap[halfCeil + i] = inputCount - i + 1
			end
		end
	end

	print(require("inspect")(map))

	return map
end

return Mirror
