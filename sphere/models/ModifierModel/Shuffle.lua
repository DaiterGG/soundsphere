local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
---@class sphere.Shuffle: sphere.Modifier
---@operator call: sphere.Shuffle
local Shuffle = Modifier + {}

Shuffle.name = "Shuffle"

Shuffle.description = "Shuffle value% notes around (true random)"

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
function Shuffle:apply(config)
	local notes = {}
	local noteChart = self.noteChart
	local keyCount = noteChart.inputMode.key
	local sj = FixMap:findShortestJack(noteChart)
	print("shortest jack " .. sj)
	-- for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
	-- 	for i, noteData in ipairs(noteDatas) do
	-- 		if
	-- 			noteData.noteType == "ShortNote" or
	-- 			noteData.noteType == "LongNoteEnd" or
	-- 			noteData.noteType == "Ignore" or
	-- 			noteData.noteType == "LongNoteStart"
	-- 		then
	-- 			print(inputIndex .. " " .. noteData.timePoint.absoluteTime .. " " .. noteData.noteType)
	-- 			if noteData.endNoteData then print(noteData.endNoteData.timePoint.absoluteTime .. " " .. noteData.endNoteData.noteType) end
	-- 		end
	-- 	end
	-- end
	-- print("_____________________________")
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		for i, noteData in ipairs(noteDatas) do
			if noteData.noteType == "ShortNote" and
				noteData.endNoteData
			then
				noteData.endNoteData.noteType = "Ignore"
			end
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart"
			then
				table.insert(notes, {
					noteData = noteData,
					inputIndex = inputIndex,
					inputType = inputType,
					layerDataIndex = layerDataIndex,
				})
			end
		end
	end
	local persentage = config.value / 10
	for _, n in ipairs(notes) do
		local seed = -9 + math.random(persentage, 10) -- 1 if 100% of notes should be shuffled
		local count = seed
		if count >= 10 then count = 1
		else count = count + 1 end

		if persentage >= count then
			
			local rngIndex = math.random(1, keyCount)
			local datas = noteChart.layerDatas[n.layerDataIndex].noteDatas[n.inputType]
			datas[rngIndex] = datas[rngIndex] or {}
			local newND = n.noteData:clone()
			if newND.endNoteData then
				newND.endNoteData = newND.endNoteData:clone()
				noteChart.layerDatas[n.layerDataIndex]:addNoteData(newND.endNoteData, n.inputType, rngIndex)
				n.noteData.endNoteData.noteType = "Ignore"
			end
			noteChart.layerDatas[n.layerDataIndex]:addNoteData(newND, n.inputType, rngIndex)
			n.noteData.noteType = "Ignore"
		end
	end

	-- for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
	-- 	for i, noteData in ipairs(noteDatas) do
	-- 		if
	-- 			noteData.noteType == "ShortNote" or
	-- 			noteData.noteType == "LongNoteEnd" or
	-- 			noteData.noteType == "Ignore" or
	-- 			noteData.noteType == "LongNoteStart"
	-- 		then
	-- 			print(inputIndex .. " " .. noteData.timePoint.absoluteTime .. " " .. noteData.noteType)
	-- 			if noteData.endNoteData then print(noteData.endNoteData.timePoint.absoluteTime .. " " .. noteData.endNoteData.noteType) end
	-- 		end
	-- 	end
	-- end
	-- print("compute_____________________________")
	noteChart:compute()

	FixMap:applyFix(noteChart, sj)
end

return Shuffle