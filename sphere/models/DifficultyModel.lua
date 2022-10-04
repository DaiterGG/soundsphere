local Class = require("Class")
local enps = require("libchart.enps")

local DifficultyModel = Class:new()

DifficultyModel.getDifficulty = function(self, noteChart)
	local notes = {}

	local longAreaSum = 0
	local longNoteCount = 0
	local minTime = math.huge
	local maxTime = -math.huge
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart" or
				noteData.noteType == "LaserNoteStart"
			then
				notes[#notes + 1] = {
					time = noteData.timePoint.absoluteTime,
					input = noteData.inputType .. noteData.inputIndex,
				}

				minTime = math.min(minTime, noteData.timePoint.absoluteTime)
				maxTime = math.max(maxTime, noteData.timePoint.absoluteTime)
			end

			if noteData.noteType == "LongNoteStart" then
				longNoteCount = longNoteCount + 1
				minTime = math.min(minTime, noteData.endNoteData.timePoint.absoluteTime)
				maxTime = math.max(maxTime, noteData.endNoteData.timePoint.absoluteTime)
				longAreaSum = longAreaSum + noteData.endNoteData.timePoint.absoluteTime - noteData.timePoint.absoluteTime
			end
		end
	end
	table.sort(notes, function(a, b) return a.time < b.time end)

	local enpsValue, aStrain, generalizedKeymode, strains = enps.getEnps(notes)
	local longArea = longAreaSum / (maxTime - minTime) / generalizedKeymode
	local longRatio = longNoteCount / #notes

	local highSum = 0
	local highCount = 0
	local lowSum = 0
	local lowCount = 0
	for i = 1, #strains do
		local strain = strains[i]
		if strain >= aStrain then
			highSum = highSum + strain
			highCount = highCount + 1
		else
			lowSum = lowSum + strain
			lowCount = lowCount + 1
		end
	end

	local high = 0
	local low = 0
	if highSum > 0 then
		high = highSum / highCount * generalizedKeymode
	end
	if lowSum > 0 then
		low = lowSum / lowCount * generalizedKeymode
	end
	-- print("enps: " .. math.floor(enpsValue * 100) / 100)
	-- print("low enps: " .. math.floor(low * 100) / 100 .. ", " .. math.floor(low / enpsValue * 100) / 100 .. ", " .. math.floor(low / enpsValue * 100) - 100 .. "%")
	-- print("high enps: " .. math.floor(high * 100) / 100 .. ", " .. math.floor(high / enpsValue * 100) / 100 .. ", " .. math.floor(high / enpsValue * 100) - 100 .. "%")
	-- print("high/all: " .. math.floor(highCount / (lowCount + highCount) * 100) / 100)

	return enpsValue, longRatio, longArea
end

return DifficultyModel
