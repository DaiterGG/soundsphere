local Modifier = require("sphere.models.ModifierModel.Modifier")
---@class sphere.FixMap: sphere.Modifier
---@operator call: sphere.FixMap
local FixMap = Modifier + {}

FixMap.name = "FixMap"

FixMap.defaultValue = 0.2
FixMap.values = {}

for i = 0, 25 do
	table.insert(FixMap.values, i * 0.01)  -- [0, 0.25]
end
for i = 1, 15 do
	table.insert(FixMap.values, 0.25 + i * 0.05)  -- [0.30, 1]
end
for i = 1, 30 do
	table.insert(FixMap.values,1 + i * 0.1)  -- [1.1, 4]
end

FixMap.description = "Prevent imposible overlaping and jacks shorter than value"

---@param config table
---@return string
---@return string
function FixMap:getString(config)
	return "FIX", tostring(config.value * 100)
end

---@param config table
function FixMap:apply(config)

	FixMap:applyFix(self.noteChart, config.value)
end
-- use this method if your modifier is breaking a map
function FixMap:applyFix(noteChart, duration)
	-- for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
	-- 	for i, noteData in ipairs(noteDatas) do
	-- 		if
	-- 			noteData.noteType == "ShortNote" or
	-- 			noteData.noteType == "LongNoteEnd" or
	-- 			noteData.noteType == "LongNoteStart"
	-- 			then
	-- 				print(inputIndex .. " " .. noteData.timePoint.absoluteTime .. " " .. noteData.noteType)
	-- 				if noteData.endNoteData then print(noteData.endNoteData.timePoint.absoluteTime .. " " .. noteData.endNoteData.noteType) end
	-- 			end
	-- 	end
	-- end
	-- print("________________________________________--")
	local notes = {}
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
					inputType = inputType,
					inputIndex = inputIndex,
					noteDataIndex = i,
					layerDataIndex = layerDataIndex,
				})
			end
		end
	end
	table.sort(notes, function(a, b)
		return a.noteData.timePoint < b.noteData.timePoint
	end)
	local inputCount
	for inputType, _inputCount in pairs(noteChart.inputMode) do
		inputCount = _inputCount
	end

	local x = 0
	while x < #notes do
		x = x + 1
		local obstructions = {}
		for  _, _note in pairs(notes) do
			--if _note.noteData == nil then print("nilllllllllllll") end
			if
				_note ~= notes[x] and
				_note.inputIndex == notes[x].inputIndex and
				self:getEndTime(_note.noteData) > notes[x].noteData.timePoint.absoluteTime - duration and
				_note.noteData.timePoint.absoluteTime <= notes[x].noteData.timePoint.absoluteTime
			then
				table.insert(obstructions, _note)
			end
		end
		--print("#obstructions " .. #obstructions)

		if #obstructions > 0 then

			local foundNewColumn = -1
			local bestLNToShorten
			local LNFound = false
			local i = 0
			while true do
				if i <= 0 then
					i = i - 1
				end
                -- i = -1, 1, -2, 2, -3...
                local newColumn = notes[x].inputIndex + i;
				-- out of 1 bound: skip, out of both: break
				if newColumn < 1 or newColumn > inputCount then
					local nextNewColumn = notes[x].inputIndex + i * -1
					if nextNewColumn < 1 or nextNewColumn > inputCount then
						break
					end
				else
					local newObstructions = {}
					for _, _note in pairs(notes) do
						if
							_note ~= notes[x] and
							_note.inputIndex == newColumn and
							self:getEndTime(_note.noteData) > notes[x].noteData.timePoint.absoluteTime - duration and
							_note.noteData.timePoint.absoluteTime <= notes[x].noteData.timePoint.absoluteTime
						then
							table.insert(newObstructions, _note)
						end
					end
					if #newObstructions == 0 then
						foundNewColumn = newColumn
						break
					else
						if not LNFound and #newObstructions == 1
						and newObstructions[1].noteData.timePoint.absoluteTime <= notes[x].noteData.timePoint.absoluteTime - duration
						then
							LNFound = true
							bestLNToShorten = newObstructions[1];
						end
					end
				end
				i = i * -1
			end
			local nToChange = noteChart.layerDatas[notes[x].layerDataIndex].noteDatas[notes[x].inputType][notes[x].inputIndex][notes[x].noteDataIndex]
			--obstruction, possible move to closest space
			if foundNewColumn ~= -1 then
				--print("obstruction, possible move to closest space ")
				notes[x].noteData = notes[x].noteData:clone()
				if notes[x].noteData.endNoteData then
					notes[x].noteData.endNoteData = notes[x].noteData.endNoteData:clone()
				end
				
				noteChart.layerDatas[notes[x].layerDataIndex]:addNoteData(notes[x].noteData, notes[x].inputType, foundNewColumn)
				
				nToChange.noteType = "Ignore"
				if nToChange.endNoteData then
					noteChart.layerDatas[notes[x].layerDataIndex]:addNoteData(notes[x].noteData.endNoteData, notes[x].inputType, foundNewColumn)

					nToChange.endNoteData.noteType = "Ignore"
				end
				notes[x].inputIndex = foundNewColumn
			--only obstruction is HoldNote, all space is obstructed,
			--possible to shorten HoldNote on current column to fit
			elseif
				#obstructions == 1 and
				obstructions[1].noteData.noteType == "LongNoteStart" and
				obstructions[1].noteData.endNoteData.noteType == "LongNoteEnd" and
				obstructions[1].noteData.timePoint.absoluteTime <= notes[x].noteData.timePoint.absoluteTime - duration
			then
				--print("possible to shorten HoldNote on current column to fit")

				self:shortenLN(noteChart,notes[x],obstructions[1],duration)
			--obstruction, all space is obstructed,
            --possible to shorten HoldNote on any other column to fit
			elseif bestLNToShorten then
				--print("possible to shorten HoldNote on any other column to fit")

				self:shortenLN(noteChart,notes[x],bestLNToShorten,duration)
				notes[x].noteData = notes[x].noteData:clone()
				if notes[x].noteData.endNoteData then
					notes[x].noteData.endNoteData = notes[x].noteData.endNoteData:clone()
				end
				noteChart.layerDatas[notes[x].layerDataIndex]:addNoteData(notes[x].noteData, notes[x].inputType, bestLNToShorten.inputIndex)

				nToChange.noteType = "Ignore"
				if notes[x].noteData.endNoteData then
					noteChart.layerDatas[notes[x].layerDataIndex]:addNoteData(notes[x].noteData.endNoteData, notes[x].inputType, bestLNToShorten.inputIndex)

					nToChange.endNoteData.noteType = "Ignore"
				end
				notes[x].inputIndex = bestLNToShorten.inputIndex
			--give up
			else
				--print("give up")

				notes[x].noteData.noteType = "Ignore"
				if notes[x].noteData.endNoteData then notes[x].noteData.endNoteData.noteType = "Ignore" end
				table.remove(notes, x)
				x = x - 1
			end
		end
	end
	-- for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
	-- 	for i, noteData in ipairs(noteDatas) do
	-- 		if
	-- 			noteData.noteType == "ShortNote" or
	-- 			noteData.noteType == "LongNoteEnd" or
	-- 			noteData.noteType == "LongNoteStart"
	-- 			then
	-- 				print(inputIndex .. " " .. noteData.timePoint.absoluteTime .. " " .. noteData.noteType)
	-- 				if noteData.endNoteData then print(noteData.endNoteData.timePoint.absoluteTime .. " " .. noteData.endNoteData.noteType) end
	-- 			end
	-- 	end
	-- end
	noteChart:compute()
end

function FixMap:shortenLN(noteChart, note, LN ,duration)
    local shorterEnd = note.noteData.timePoint.absoluteTime - duration;
	local nToChange = noteChart.layerDatas[LN.layerDataIndex].noteDatas[LN.inputType][LN.inputIndex][LN.noteDataIndex]
    if shorterEnd - LN.noteData.timePoint.absoluteTime >= duration then
		LN.noteData.endNoteData.timePoint = noteChart.layerDatas[LN.layerDataIndex]:getTimePoint(shorterEnd, LN.noteData.endNoteData.timePoint.side)
		LN.noteData.endNoteData.timePoint.absoluteTime = shorterEnd
    else
		--no micro LNs
		LN.noteData.noteType = "ShortNote"
		LN.noteData.endNoteData.noteType = "Ignore"
    end
end

function FixMap:getEndTime(noteData)
	if noteData.noteType == "LongNoteStart" then
		return noteData.endNoteData.timePoint.absoluteTime
	else
		return noteData.timePoint.absoluteTime
	end
end


function FixMap:findShortestJack(noteChart)
	local minJack = math.huge
	for noteDatas in noteChart:getInputIterator() do
		local prevTime = math.huge * -1
		for i, noteData in ipairs(noteDatas) do
			if
			noteData.noteType == "ShortNote" or
			noteData.noteType == "LongNoteStart" or
			noteData.noteType == "LongNoteEnd"
			then
				local timeDif = noteData.timePoint.absoluteTime - prevTime
				if timeDif < minJack then
					minJack = timeDif
				end
				prevTime = noteData.timePoint.absoluteTime
			end
		end
	end
	if minJack < 0.02 then minJack = 0.02 end
	return minJack
end

return FixMap