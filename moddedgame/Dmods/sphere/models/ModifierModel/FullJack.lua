local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.FullJack: sphere.Modifier
---@operator call: sphere.FullJack
local FullJack = Modifier + {}

FullJack.name = "FullJack"

FullJack.defaultValue = 0
FullJack.values = {}
for i = 0, 25 do
    table.insert(FullJack.values, i * 0.01) -- [0, 0.25]
end
for i = 1, 15 do
    table.insert(FullJack.values, 0.25 + i * 0.05) -- [0.30, 1]
end
for i = 1, 30 do
    table.insert(FullJack.values, 1 + i * 0.1) -- [1.1, 4]
end

---@param config table
---@return string
---@return string
function FullJack:getString(config) return "FJ", tostring(config.value * 100) end

FullJack.description =
    "Position notes on top of each other\n'value' is a minimum distance between jacks\nwhen '0' it's based on original map"

---@param config table
function FullJack:apply(config, chart)
    local keyCount = chart.inputMode.key
    local sj
    if config.value == 0 then
        sj = FixMap:findShortestJack(chart)
        print("shortest jack " .. sj)
    else
        sj = config.value
    end

    local keyChart = {}
    local new_notes = Notes()

    for _, lnote in ipairs(chart.notes:getLinkedNotes()) do
        local inputType, inputIndex = InputMode:splitInput(lnote:getColumn())
        if inputType == "key" and lnote.startNote.type ~= "ignore" then
            local n = {}

            n.lData = lnote
            n.startNote = lnote.startNote
            if lnote.endNote and lnote.endNote.type ~= "ignore" then
                n.endNote = lnote.endNote
            end
            n.startTime = lnote:getStartTime()
            n.endTime = lnote:getEndTime()
            n.column = inputIndex

            keyChart[#keyChart + 1] = n
        else
            new_notes:insert(lnote.startNote)
            if lnote.endNote then new_notes:insert(lnote.endNote) end
        end
    end
    chart.notes = new_notes

    local lines = {}
    for _, note in ipairs(keyChart) do
        local time = note.startTime
        lines[time] = lines[time] or {time = time}
        table.insert(lines[time], note)
    end

    local ilines = {}
    for _, line in pairs(lines) do table.insert(ilines, line) end

    table.sort(ilines, function(a, b) return a.time < b.time end)

    local columns = {lenght = 0}
    local lastTime = -999999

    for _, line in ipairs(ilines) do
        if line.time - lastTime >= sj then
            local notesToMove = {}
            for i = 1, #line do
                if columns.lenght <= 0 then break end
                if columns[line[i].column] then
                    columns[line[i].column] = "occupied"
                    -- print(line[i].column .. " " .. columns[line[i].column])
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
            -- print("notesToMove: " .. #notesToMove)
            -- self:show(columns)
            if #notesToMove > 0 then
                for n = 1, #notesToMove do
                    local seed = math.random(0, keyCount - 1)
                    for c = 1, keyCount do
                        local rngC = math.fmod(seed + c - 1, keyCount) + 1
                        if columns[rngC] == "free" then
                            columns[rngC] = nil
                            -- print("move " .. notesToMove[n].column .. " to " .. "key" .. rngC)
                            notesToMove[n].column = rngC
                            notesToMove[n].lData:setColumn("key" .. rngC)
                            break
                        end
                    end
                end
            end
            lastTime = line.time
        end
        columns = {lenght = 0}
        for i = 1, #line do
            columns[line[i].column] = "free"
            columns.lenght = columns.lenght + 1
        end
    end
    -- chart:compute()
    FixMap:applyFix(chart, keyChart, sj)
end

-- function FullJack:show(blockedColumns)
-- 	print("show")
-- 	for _, __ in pairs(blockedColumns) do
-- 		print(_ .. " " .. tostring(__))
-- 	end
-- 	print("end")
-- end
return FullJack
