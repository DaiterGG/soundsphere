local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
---@class sphere.FixMap: sphere.Modifier
---@operator call: sphere.FixMap
local FixMap = Modifier + {}

FixMap.name = "FixMap"

FixMap.defaultValue = 0.2
FixMap.values = {}

for i = 0, 25 do
	table.insert(FixMap.values, i * 0.01) -- [0, 0.25]
end
for i = 1, 15 do
	table.insert(FixMap.values, 0.25 + i * 0.05) -- [0.30, 1]
end
for i = 1, 30 do
	table.insert(FixMap.values, 1 + i * 0.1) -- [1.1, 4]
end

FixMap.description = "Prevent imposible overlaping and jacks shorter than 'value'"

---@param config table
---@return string
---@return string
function FixMap:getString(config)
	return "FIX", tostring(config.value * 100)
end

---@param config table
function FixMap:apply(config, chart)
	FixMap:applyFix(chart, config.value)
end

-- use this method if your modifier is breaking a map
function FixMap:applyFix(noteChart, duration)
	noteChart.notes:sort()
	local notes = noteChart.notes:getLinkedNotes()

	local inputCount = noteChart.inputMode.key

	local x = 0
	while x < #notes do
		x = x + 1
		if notes[x].startNote.type == "note" or notes[x].startNote.type == "hold" then
			local obstructions = {}
			for _, _note in pairs(notes) do
				if
					_note ~= notes[x] and
					_note.startNote.column == notes[x].startNote.column and
					_note:getEndTime() > notes[x]:getStartTime() - duration and
					_note:getStartTime() <= notes[x]:getStartTime()
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
					local _, index = InputMode:splitInput(notes[x].startNote.column)

					local newColumn = index + i;
					-- out of 1 bound: skip, out of both: break
					if newColumn < 1 or newColumn > inputCount then
						local nextNewColumn = index + i * -1
						if nextNewColumn < 1 or nextNewColumn > inputCount then
							break
						end
					else
						local newObstructions = {}
						for _, _note in pairs(notes) do
							local _, _index = InputMode:splitInput(_note.startNote.column)
							if
								_note ~= notes[x] and
								_index == newColumn and
								_note:getEndTime() > notes[x].startNote:getTime() - duration and
								_note.startNote:getTime() <= notes[x].startNote:getTime()
							then
								table.insert(newObstructions, _note)
							end
						end
						if #newObstructions == 0 then
							foundNewColumn = newColumn
							break
						else
							if not LNFound and #newObstructions == 1
								and newObstructions[1].startNote:getTime() <= notes[x].startNote:getTime() - duration
							then
								LNFound = true
								bestLNToShorten = newObstructions[1];
							end
						end
					end
					i = i * -1
				end
				--obstruction, possible move to closest space
				if foundNewColumn ~= -1 then
					--print("obstruction, possible move to closest space ")

					local new_column = "key" .. foundNewColumn
					notes[x]:setColumn(new_column)
					-- only obstruction is HoldNote, all space is obstructed,
					-- possible to shorten HoldNote on current column to fit
				elseif
					#obstructions == 1 and
					obstructions[1].startNote.type == "hold" and
					obstructions[1].startNote:getTime() <= notes[x].startNote:getTime() - duration
				then
					--print("possible to shorten HoldNote on current column to fit")

					self:shortenLN(noteChart, notes[x], obstructions[1], duration)
					--obstruction, all space is obstructed,
					--possible to shorten HoldNote on any other column to fit
				elseif bestLNToShorten then
					--print("possible to shorten HoldNote on any other column to fit")

					self:shortenLN(noteChart, notes[x], bestLNToShorten, duration)

					notes[x]:setColumn(bestLNToShorten.startNote.column)
					--give up
				else
					--print("give up")

					notes[x].startNote.type = "ignore"
					notes[x].startNote.weight = 0
					if notes[x].endNote then
						notes[x].endNote.type = "ignore"
						notes[x].endNote.weight = 0
					end
					table.remove(notes, x)
					x = x - 1
				end
			end
		end
	end
	-- for _, noteData in ipairs(noteChart.notes:getLinkedNotes()) do
	-- 	print(noteData.startNote, noteData.endNote)
	-- end
	-- print("________________________________________")
	noteChart:compute()
end

function FixMap:shortenLN(noteChart, note, LN, duration)
	-- local shorterEnd = note.startNote:getTime() - duration;
	-- if shorterEnd - LN.startNote:getTime() >= duration then
	-- 	local layer = noteChart.layers.main
	-- 	local p = layer:getPoint(shorterEnd)
	-- 	local vp = layer.visuals.main:newPoint(p)
	-- 	LN.endNote.visualPoint = vp
	-- else
	-- 	--no micro LNs
	-- 	LN.startNote.type = "note"
	-- 	LN.endNote.type = "ignore"
	-- 	LN:unlink()
	-- end
end

function FixMap:findShortestJack(noteChart)
	local minJack = math.huge
	local column_notes = noteChart.notes:getColumnNotes()
	for column, columnChart in pairs(column_notes) do
		local inputType, inputIndex = InputMode:splitInput(column)
		if inputType == "key" then
			local prevTime = math.huge * -1
			for i, noteData in ipairs(columnChart) do
				local timeDif = noteData:getTime() - prevTime
				if timeDif < minJack then
					minJack = timeDif
				end
				prevTime = noteData:getTime()
			end
		end
	end
	if minJack < 0.02 then minJack = 0.02 end
	return minJack
end

return FixMap
