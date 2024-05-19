local Modifier = require("sphere.models.ModifierModel.Modifier")
local table_util = require("table_util")
---@class sphere.FixMap: sphere.Modifier
---@operator call: sphere.FixMap
local FixMap = Modifier + {}

FixMap.name = "FixMap"

FixMap.defaultValue = 0.4
FixMap.values = {}

for i = 0, 25 do
	table.insert(FixMap.values, i * 0.01)  -- [0, 0.25]
end
for i = 1, 15 do
	table.insert(FixMap.values, 0.25 + i * 0.05)  -- [0.25, 1]
end
for i = 1, 30 do
	table.insert(FixMap.values,1 + i * 0.1)  -- [1, 4]
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

	self:applyFix(config, config.value)
end
-- use this method if your modifier is breaking a map
function FixMap:applyFix(config, duration)
	local noteChart = self.noteChart
	self.notes = {}
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		for i, noteData in ipairs(noteDatas) do
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart"
			then
				table.insert(self.notes, {
					noteData = noteData,
					inputType = inputType,
					inputIndex = inputIndex,
					noteDataIndex = i,
					layerDataIndex = layerDataIndex,
				})
			end
		end
	end
	table.sort(self.notes, function(a, b)
		return a.noteData.timePoint < b.noteData.timePoint
	end)

	local inputCount
	for inputType, _inputCount in pairs(noteChart.inputMode) do
		inputCount = _inputCount
	end

	local notes = self.notes
	local x = 0
	while x < #notes do
		x = x + 1
		local obstructions = {}
		for  _, _note in pairs(notes) do
			if
				_note ~= notes[x] and
				_note.inputIndex == notes[x].inputIndex and
				self:getEndTime(_note) > notes[x].noteData.timePoint.absoluteTime - duration and
				_note.noteData.timePoint.absoluteTime <= notes[x].noteData.timePoint.absoluteTime
			then
				table.insert(obstructions, _note)
			end
		end

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
							self:getEndTime(_note) > notes[x].noteData.timePoint.absoluteTime - duration and
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
				table.insert(noteChart.layerDatas[notes[x].layerDataIndex].noteDatas[notes[x].inputType][foundNewColumn], nToChange:clone())
				nToChange.noteType = "Ignore"
				notes[x].inputIndex = foundNewColumn
			--only obstruction is HoldNote, all space is obstructed,
			--possible to shorten HoldNote on current column to fit
			elseif
				#obstructions == 1 and
				obstructions[1].noteData.noteType == "LongNoteStart" and
				obstructions[1].noteData.endNoteData.noteType == "LongNoteEnd" and
				obstructions[1].noteData.timePoint.absoluteTime <= notes[x].noteData.timePoint.absoluteTime - duration
			then
				self:shortenLN(noteChart,notes[x],obstructions[1],duration)
			--obstruction, all space is obstructed,
            --possible to shorten HoldNote on any other column to fit
			elseif bestLNToShorten then
				self:shortenLN(noteChart,notes[x],bestLNToShorten,duration)
				table.insert(noteChart.layerDatas[notes[x].layerDataIndex].noteDatas[notes[x].inputType][bestLNToShorten.inputIndex], nToChange:clone())
				nToChange.noteType = "Ignore"
				notes[x].inputIndex = bestLNToShorten.inputIndex
			--give up
			else
				nToChange.noteType = "Ignore"
				if nToChange.endNoteData then nToChange.endNoteData.noteType = "Ignore" end
				table.remove(notes, x)
				x = x - 1
			end
		end
	end
	noteChart:compute()
end

function FixMap:shortenLN(noteChart, note, LN ,duration)
    local shorterEnd = note.noteData.timePoint.absoluteTime - duration;
	local nToChange = noteChart.layerDatas[LN.layerDataIndex].noteDatas[LN.inputType][LN.inputIndex][LN.noteDataIndex]
    if shorterEnd - LN.noteData.timePoint.absoluteTime >= duration then
		nToChange.endNoteData.timePoint = noteChart.layerDatas[LN.layerDataIndex]:getTimePoint(shorterEnd)
		LN.noteData.endNoteData.timePoint.absoluteTime = shorterEnd
    else
		--no micro LNs
		nToChange.noteType = "ShortNote"
		nToChange.endNoteData.noteType = "Ignore"
		LN.noteType = "ShortNote"
		LN.noteData.endNoteData = nil
    end
end

function FixMap:getEndTime(note)
	if note.noteData.noteType == "LongNoteStart" then
		return note.noteData.endNoteData.timePoint.absoluteTime
	else
		return note.noteData.timePoint.absoluteTime
	end
end

return FixMap