local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

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

FixMap.description =
    "Prevent imposible overlaping and jacks shorter than 'value'"

---@param config table
---@return string
---@return string
function FixMap:getString(config) return "FIX", tostring(config.value * 100) end

---@param config table
function FixMap:apply(config, chart)

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
    FixMap:applyFix(chart, keyChart, config.value)
end

-- use this method if your modifier is breaking a map
function FixMap:applyFix(chart, editChart, duration)
    self.chart = chart
    self.duration = duration
    table.sort(editChart, function(a, b) return a.startTime < b.startTime end)
    local inputCount = chart.inputMode.key
    local x = 0
    local notes = editChart

   
    for i, lnote in pairs(notes) do
        print(lnote.startNote, lnote.endNote)
    end


    while x < #notes do
        x = x + 1
        local obstructions = {}
        for _, _note in pairs(notes) do
            if _note ~= notes[x] and _note.column == notes[x].column and
                _note.endTime > notes[x].startTime - duration and
                _note.startTime <= notes[x].startTime then
                table.insert(obstructions, _note)
            end
        end
        -- print("#obstructions " .. #obstructions)

        if #obstructions > 0 then
            local foundNewColumn = -1
            local bestLNToShorten
            local LNFound = false
            local i = 0
            while true do
                if i <= 0 then i = i - 1 end
                -- i = -1, 1, -2, 2, -3...
                local index = notes[x].column

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
                        local _index = _note.column
                        if _note ~= notes[x] and _index == newColumn and
                            _note.endTime > notes[x].startTime - duration and
                            _note.startTime <= notes[x].startTime then
                            table.insert(newObstructions, _note)
                        end
                    end
                    if #newObstructions == 0 then
                        foundNewColumn = newColumn
                        break
                    else
                        if not LNFound and #newObstructions == 1 and
                            newObstructions[1].startTime <= notes[x].startTime -
                            duration then
                            LNFound = true
                            bestLNToShorten = newObstructions[1];
                        end
                    end
                end
                i = i * -1
            end
            -- obstruction, possible move to closest space
            if foundNewColumn ~= -1 then
                --print("obstruction, possible move to closest space ")

                notes[x].column = foundNewColumn
                notes[x].lData:setColumn("key" .. foundNewColumn)
                -- only obstruction is HoldNote, all space is obstructed,
                -- possible to shorten HoldNote on current column to fit
            elseif #obstructions == 1 and obstructions[1].endNote and
                obstructions[1].startTime <= notes[x].startTime - duration then
                --print("possible to shorten HoldNote on current column to fit")

                self:shortenLN(notes[x], obstructions[1])
                -- obstruction, all space is obstructed,
                -- possible to shorten HoldNote on any other column to fit
            elseif bestLNToShorten then
                --print("possible to shorten HoldNote on any other column to fit")

                self:shortenLN(notes[x], bestLNToShorten)

                notes[x].column = bestLNToShorten.column
                notes[x].lData:setColumn("key" .. bestLNToShorten.column)
                -- give up
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
   
    for i, lnote in pairs(notes) do
        print(lnote.startNote, lnote.endNote)
        chart.notes:insertLinked(lnote)
    end

    chart:compute()
end

function FixMap:shortenLN(note, LN)
    local duration = self.duration
    local shorterEnd = note.startTime - duration;
    if shorterEnd - LN.startTime >= duration then
        local layer = self.chart.layers.main
        local p = layer:getPoint(shorterEnd)
        local vp = layer.visuals.main:newPoint(p)
        LN.endNote.visualPoint = vp
        LN.endTime = shorterEnd
    else
        -- no micro LNs
        LN.startNote.type = "note"
        LN.endNote.type = "ignore"
        LN.lData:unlink()
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
                local timeDif = noteData:getTime() - prevTime
                if timeDif < minJack then minJack = timeDif end
                prevTime = noteData:getTime()
            end
        end
    end
    if minJack < 0.02 then minJack = 0.02 end
    return minJack
end

return FixMap
