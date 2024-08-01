local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
local Notes = require("ncdk2.notes.Notes")
local InputMode = require("ncdk.InputMode")

---@class sphere.Shuffle: sphere.Modifier
---@operator call: sphere.Shuffle
local Shuffle = Modifier + {}

Shuffle.name = "Shuffle"

Shuffle.description = "Shuffle 'value%' notes around (true random)"

Shuffle.defaultValue = 100
Shuffle.values = {}

for i = 1, 10 do table.insert(Shuffle.values, i * 10) end

---@param config table
---@return string
---@return string
function Shuffle:getString(config) return "SFL", tostring(config.value) end

---@param config table
function Shuffle:apply(config, chart)

    local sj = FixMap:findShortestJack(chart)
    print("shortest jack " .. sj)

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

    local keyCount = chart.inputMode.key

    local persentage = config.value / 10
    local seed = -10 + math.random(persentage, 10) -- 0 if 100% of notes should be shuffled
    local count = seed
    for _, n in ipairs(keyChart) do
        if count >= 10 then
            count = 1
        else
            count = count + 1
        end
        if persentage >= count and count > 0 then
            local rngIndex = math.random(1, keyCount)
			n.column = rngIndex
			n.lData:setColumn("key" .. rngIndex)
        end
    end

    FixMap:applyFix(chart, keyChart, sj)
end

return Shuffle
