local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
---@class sphere.Shuffle: sphere.Modifier
---@operator call: sphere.Shuffle
local Shuffle = Modifier + {}

Shuffle.name = "Shuffle"

Shuffle.description = "Shuffle 'value%' notes around (true random)"

Shuffle.defaultValue = 100
Shuffle.values = {}

for i = 1, 10 do
	table.insert(Shuffle.values, i * 10)
end

---@param config table
---@return string
---@return string
function Shuffle:getString(config)
	return "SFL", tostring(config.value)
end

---@param config table
function Shuffle:apply(config, noteChart)
	local keyCount = noteChart.inputMode.key
	local sj = FixMap:findShortestJack(noteChart)
	print("shortest jack " .. sj)
	
	local persentage = config.value / 10
	local seed = -10 + math.random(persentage, 10) -- 0 if 100% of notes should be shuffled
	local count = seed
	for _, n in noteChart.notes:iter() do
		if
			n.noteType == "ShortNote" or
			n.noteType == "LongNoteStart" then
			if count >= 10 then
				count = 1
			else
				count = count + 1
			end
			if persentage >= count and count > 0 then
				local rngIndex = math.random(1, keyCount)
				n.column = "key" .. rngIndex
				if n.endNote then
					n.endNote.column = "key" .. rngIndex
				end
			end
		end
	end

	FixMap:applyFix(noteChart, sj)
end

return Shuffle
