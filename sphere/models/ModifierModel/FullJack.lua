local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
local InputMode = require("ncdk.InputMode")

---@class sphere.FullJack: sphere.Modifier
---@operator call: sphere.FullJack
local FullJack = Modifier + {}

FullJack.name = "FullJack"
FullJack.shortName = "FJ"

FullJack.description = "Position notes on top of each other"

---@param config table
function FullJack:apply(config, chart)
	local keyCount = chart.inputMode.key
	local sj = FixMap:findShortestJack(chart)
	print("shortest jack " .. sj)

	local notes = {}
	for _, noteData in chart.notes:iter() do
		if noteData.noteType == "ShortNote" or
			noteData.noteType == "LongNoteStart"
		then
			local _, key = InputMode:splitInput(noteData.column)
			table.insert(notes, {
				noteData = noteData,
				column = key

			})
		end
	end
	local lines = {}
	for _, note in ipairs(notes) do
		local time = note.noteData:getTime()
		lines[time] = lines[time] or { time = time }
		table.insert(lines[time], note)
	end
	local ilines = {}
	for _, line in pairs(lines) do
		table.insert(ilines, line)
	end
	table.sort(ilines, function(a, b)
		return a.time < b.time
	end)
	local columns = { lenght = 0 }
	local lastTime = -999999
	for _, line in ipairs(ilines) do
		if line.time - lastTime >= sj then
			local notesToMove = {}
			for i = 1, #line do
				if columns.lenght <= 0 then break end
				if columns[line[i].column] then
					columns[line[i].column] = "occupied"
					--print(line[i].column .. " " .. columns[line[i].column])
					columns.lenght = columns.lenght - 1
				end
			end
			for i = 1, #line do
				if columns.lenght <= 0 then break end
				if not columns[line[i].column] then
					table.insert(notesToMove, line[i])
					columns.lenght = columns.lenght - 1
				end
			end
			--print("notesToMove: " .. #notesToMove)
			--self:show(columns)
			if #notesToMove > 0 then
				for n = 1, #notesToMove do
					local seed = math.random(0, keyCount - 1)
					for c = 1, keyCount do
						local rngC = math.fmod(seed + c - 1, keyCount) + 1
						if columns[rngC] == "free" then
							columns[rngC] = nil
							--print("move " .. notesToMove[n].column .. " to " .. "key" .. rngC)
							notesToMove[n].column = rngC
							notesToMove[n].noteData.column = "key" .. rngC
							if notesToMove[n].noteData.endNote then
								notesToMove[n].noteData.endNote.column = "key" .. rngC
							end
							break
						end
					end
				end
			end
			columns = { lenght = 0 }
			for i = 1, #line do
				columns[line[i].column] = "free"
				columns.lenght = columns.lenght + 1
			end
			--print("end")
		end
		lastTime = line.time
	end
	--chart:compute()
	FixMap:applyFix(chart, sj)
end

-- function FullJack:show(blockedColumns)
-- 	print("show")
-- 	for _, __ in pairs(blockedColumns) do
-- 		print(_ .. " " .. tostring(__))
-- 	end
-- 	print("end")
-- end
return FullJack
