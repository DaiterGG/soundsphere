local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
local InputMode = require("ncdk.InputMode")

---@class sphere.MoreChord: sphere.Modifier
---@operator call: sphere.MoreChord
local MoreChord = Modifier + {}

MoreChord.name = "MoreChord"

MoreChord.defaultValue = 1
MoreChord.values = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

MoreChord.description = "Add notes to every chord"

---@param config table
---@return string
---@return string
function MoreChord:getString(config)
	return tostring(config.value), "MC"
end

local function _insert (chart, note)
	assert(note, "missing note")
	table.insert(chart.notes.notes, note)

	local column = note.column
	local layer = chart.layers.main
	local p = note.visualPoint.point
	local vp = note.visualPoint --layer.visuals.main:newPoint(p)
	---@cast vp ncdk2.VisualPoint

	local point_notes = chart.notes.point_notes
	point_notes[vp] = point_notes[vp] or {}
	local p = point_notes[vp]
	p[column] = note
end

---@param config table
function MoreChord:apply(config, noteChart)
	local value = config.value

	local keyCount = noteChart.inputMode.key
	print("key count " .. keyCount)

	local sj = FixMap:findShortestJack(noteChart)
	print("shortest jack " .. sj)

	local notes = {}
	for _, noteData in noteChart.notes:iter() do
		if noteData.noteType == "ShortNote" or
			noteData.noteType == "LongNoteStart"
		then
			table.insert(notes, {
				noteData = noteData,
				time = noteData.visualPoint.point.absoluteTime,
			})
		end
	end

	local lines = {}
	for _, note in ipairs(notes) do
		local time = note.time
		lines[time] = lines[time] or { time = time }
		table.insert(lines[time], note)
	end

	for _, line in pairs(lines) do
		for i = 1, value do
			local rngIndex = math.random(1, keyCount)
			local rngNote = math.random(1, #line)
			local newN = line[rngNote].noteData:clone()
			newN.column = "key" .. rngIndex
			if newN.endNote then
				newN.endNote = newN.endNote:clone()
				newN.endNote.startNote = newN
				newN.endNote.column = "key" .. rngIndex
				_insert(noteChart, newN.endNote)
			end
			_insert(noteChart, newN)
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
	-- 	end
	-- end
	-- print("starts " .. starts .. " ends " .. ends)
	-- print("________________________________________--")
	--noteChart:compute()
	FixMap:applyFix(noteChart, sj)
end


return MoreChord