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

FixMap.description = "Prevent imposible overlaping and jacks shorter than value"

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
	-- for _, noteData in noteChart.notes:iter() do
	-- 	if
	-- 		noteData.noteType == "ShortNote" or
	-- 		noteData.noteType == "LongNoteEnd" or
	-- 		noteData.noteType == "LongNoteStart"
	-- 	then
	-- 		print(noteData.column .. " " .. noteData.visualPoint.point.absoluteTime .. " " .. noteData.noteType)
	-- 		if noteData.endNote then print(noteData.endNote.visualPoint.point.absoluteTime ..
	-- 			" " .. noteData.endNote.noteType) end
	-- 	end
	-- end
	-- print("________________________________________--")
	local notes = {}
	for _, noteData in noteChart.notes:iter() do
		if noteData.noteType == "ShortNote" and
			noteData.endNote
		then
			noteData.endNote.noteType = "Ignore"
		end
		if
			noteData.noteType == "ShortNote" or
			noteData.noteType == "LongNoteStart"
		then
			local _, index = InputMode:splitInput(noteData.column)
			table.insert(notes, {
				noteData = noteData,
			})
		end
	end
	table.sort(notes, function(a, b)
		return a.noteData < b.noteData
	end)
	local inputCount = noteChart.inputMode.key

	local x = 0
	while x < #notes do
		x = x + 1
		local obstructions = {}
		for _, _note in pairs(notes) do
			--if _note.noteData == nil then print("nilllllllllllll") end
			if
				_note ~= notes[x] and
				_note.noteData.column == notes[x].noteData.column and
				self:getEndTime(_note.noteData) > notes[x].noteData.visualPoint.point.absoluteTime - duration and
				_note.noteData.visualPoint.point.absoluteTime <= notes[x].noteData.visualPoint.point.absoluteTime
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
				local _, index = InputMode:splitInput(notes[x].noteData.column)

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
						local _, _index = InputMode:splitInput(_note.noteData.column)
						if
							_note ~= notes[x] and
							_index == newColumn and
							self:getEndTime(_note.noteData) > notes[x].noteData.visualPoint.point.absoluteTime - duration and
							_note.noteData.visualPoint.point.absoluteTime <= notes[x].noteData.visualPoint.point.absoluteTime
						then
							table.insert(newObstructions, _note)
						end
					end
					if #newObstructions == 0 then
						foundNewColumn = newColumn
						break
					else
						if not LNFound and #newObstructions == 1
							and newObstructions[1].noteData.visualPoint.point.absoluteTime <= notes[x].noteData.visualPoint.point.absoluteTime - duration
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
				notes[x].noteData.column = new_column
				if notes[x].noteData.endNote then
					notes[x].noteData.endNote.column = new_column
				end

				-- only obstruction is HoldNote, all space is obstructed,
				-- possible to shorten HoldNote on current column to fit
			elseif
				#obstructions == 1 and
				obstructions[1].noteData.noteType == "LongNoteStart" and
				obstructions[1].noteData.endNote.noteType == "LongNoteEnd" and
				obstructions[1].noteData.visualPoint.point.absoluteTime <= notes[x].noteData.visualPoint.point.absoluteTime - duration
			then
				--print("possible to shorten HoldNote on current column to fit")

				self:shortenLN(noteChart, notes[x], obstructions[1], duration)
				--obstruction, all space is obstructed,
				--possible to shorten HoldNote on any other column to fit
			elseif bestLNToShorten then
				--print("possible to shorten HoldNote on any other column to fit")

				self:shortenLN(noteChart, notes[x], bestLNToShorten, duration)

				local _, index = InputMode:splitInput(bestLNToShorten.noteData.column)
				local new_column = "key" .. index
				notes[x].noteData.column = new_column
				if notes[x].noteData.endNote then
					notes[x].noteData.endNote.column = new_column
				end
				--give up
			else
				--print("give up")

				notes[x].noteData.noteType = "Ignore"
				if notes[x].noteData.endNote then notes[x].noteData.endNote.noteType = "Ignore" end
				table.remove(notes, x)
				x = x - 1
			end
		end
	end
	-- local ends = 0
	-- local starts = 0
	-- for _, noteData in noteChart.notes:iter() do
	-- 	if noteData.noteType == "LongNoteStart" then starts = starts + 1 end
	-- 	if noteData.noteType == "LongNoteEnd" then ends = ends + 1 end
	-- 	if
	-- 		noteData.noteType == "ShortNote" or
	-- 		noteData.noteType == "LongNoteEnd" or
	-- 		noteData.noteType == "LongNoteStart"
	-- 	then
	-- 		print(noteData.column .. " " .. noteData.visualPoint.point.absoluteTime .. " " .. noteData.noteType)
	-- 		if noteData.endNote then
	-- 			print("|_" .. noteData.endNote.column .. " " .. noteData.endNote.visualPoint.point.absoluteTime ..
	-- 				" " .. noteData.endNote.noteType)
	-- 		end
	-- 		if noteData.startNote then
	-- 			print("|_" .. noteData.startNote.column .. " " .. noteData.startNote.visualPoint.point.absoluteTime ..
	-- 				" " .. noteData.startNote.noteType)
	-- 		end
	-- 	end
	-- end
	-- print("starts " .. starts .. " ends " .. ends)
	-- print("________________________________________--")

	noteChart:compute()
end

function FixMap:shortenLN(noteChart, note, LN, duration)
	local shorterEnd = note.noteData.visualPoint.point.absoluteTime - duration;
	if shorterEnd - LN.noteData.visualPoint.point.absoluteTime >= duration then
		local layer = noteChart.layers.main
		local p = layer:getPoint(shorterEnd)
		local vp = layer.visuals.main:newPoint(p)
		LN.noteData.endNote.visualPoint = vp
	else
		--no micro LNs
		LN.noteData.noteType = "ShortNote"
		LN.noteData.endNote.noteType = "Ignore"
	end
end

function FixMap:getEndTime(noteData)
	if noteData.noteType == "LongNoteStart" then
		return noteData.endNote.visualPoint.point.absoluteTime
	else
		return noteData.visualPoint.point.absoluteTime
	end
end

function FixMap:findShortestJack(noteChart)
	local minJack = math.huge
	local column_notes = noteChart.notes:getColumnNotes()
	for column, columnChart in pairs(column_notes) do
		local inputType, inputIndex = InputMode:splitInput(column)
		if inputType == "key" then
			local prevTime = math.huge * -1
			for i, noteData in ipairs(columnChart) do
				local timeDif = noteData.visualPoint.point.absoluteTime - prevTime
				if timeDif < minJack then
					minJack = timeDif
				end
				prevTime = noteData.visualPoint.point.absoluteTime
			end
		end
	end
	if minJack < 0.02 then minJack = 0.02 end
	return minJack
end

return FixMap
