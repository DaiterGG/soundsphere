local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.FullBracket: sphere.Modifier
---@operator call: sphere.FullBracket
local FullBracket = Modifier + {}

FullBracket.name = "FullBracket"
FullBracket.shortName = "FB"

--FullBracket.defaultValue = 1
--FullBracket.values = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

FullBracket.description = "Convert every pattern to brackets"

-- ---@param config table
-- ---@return string
-- ---@return string
-- function FullBracket:getString(config)
-- 	return tostring(config.value), "MC"
-- end

---@param config table
function FullBracket:apply(config, chart)
	local keyCount = chart.inputMode.key
	local sj = FixMap:findShortestJack(chart)
	print("shortest jack " .. sj)

    local keyChart = {}
    local new_notes = Notes()

	for _, lnote in ipairs(chart.notes:getLinkedNotes()) do
        local inputType, inputIndex = InputMode:splitInput(lnote:getColumn())
        if inputType == "key" then
            if lnote.startNote.type ~= "ignore" then --exlude all "ignore" notes 
                if lnote.endNote and lnote.endNote.type == "ignore" then
                    lnote.startNote.type = "note"
                    lnote:unlink()
                    lnote.endNote = nil
                end
                local n = {}

                n.lData = lnote
                n.startNote = lnote.startNote
                n.endNote = lnote.endNote
                n.startTime = lnote:getStartTime()
                n.endTime = lnote:getEndTime()
                n.column = inputIndex
                
                keyChart[#keyChart + 1] = n
            end
        else
            new_notes:insert(lnote.startNote)
            if lnote.endNote then new_notes:insert(lnote.endNote) end
        end
    end
    chart.notes = new_notes

	local lines = {}
	for _, note in ipairs(keyChart) do
		local time = note.startTime
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
	local prevLine = { time = -999999 }
	local prevLine2 = { time = -999999 }
	local blockedColumns = {}
	local notesDeleted = 0
	for _, line in ipairs(ilines) do
		--print(line.time)
		if line.time - prevLine2.time < sj then
			for _, n in ipairs(prevLine2) do
				blockedColumns[n.column] = true
				--print("SJ TRIGGERED " .. n.column)
			end
		end
		local notesToMove = {}
		for i = 1, #line do
			if blockedColumns[line[i].column] then
				table.insert(notesToMove, line[i])
			else
				blockedColumns[line[i].column + 1] = true
				blockedColumns[line[i].column] = true
				blockedColumns[line[i].column - 1] = true
			end
		end
		--print("line " .. #line)
		--self:show(blockedColumns)
		--print("notesToMove " .. #notesToMove)
		if #notesToMove > 0 then
			for n = 1, #notesToMove do
				local seed = math.random(0, keyCount - 1)
				local moved = false
				for c = 1, keyCount do
					local newC = math.fmod(seed + c - 1, keyCount) + 1
					if not blockedColumns[newC] then
						--print("note Moved from " .. notesToMove[n].noteData.column .. " to " .. newC)
						notesToMove[n].lData:setColumn("key" .. newC)
						notesToMove[n].column = newC
						blockedColumns[newC - 1] = true
						blockedColumns[newC] = true
						blockedColumns[newC + 1] = true
						moved = true
						break
					end
				end
				if not moved then
					notesToMove[n].toDelete = true
					for i = 1, #line do
						if line[i].starTime == notesToMove[n].starTime and
						line[i].column == notesToMove[n].column then
							table.remove(line, i)
							notesDeleted = notesDeleted + 1
							--print("note removed from line " .. #line)
							break
						end
					end
				end
			end
		end
		--print("new line " .. #line)
		blockedColumns = {}
		for i = 1, #line do
			blockedColumns[line[i].column] = true
		end
		--print("new blocked")
		--self:show(blockedColumns)
		prevLine2 = prevLine
		prevLine = line
		--print("end")
	end
	local i = 1
	while i <= #keyChart do
		if keyChart[i].toDelete then
			table.remove(keyChart, i)
		else
			i = i + 1
		end
	end
	print("notesDeleted: " .. notesDeleted)
	FixMap:applyFix(chart, keyChart, sj)
end

-- function FullBracket:show(blockedColumns)
-- 	for _, __ in pairs(blockedColumns) do
-- 		print(_ .. " " .. tostring(__))
-- 	end
-- end
return FullBracket
