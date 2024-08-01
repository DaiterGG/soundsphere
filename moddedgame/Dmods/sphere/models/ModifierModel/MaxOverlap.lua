local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.MaxOverlap
---@operator call: sphere.MaxOverlap
local MaxOverlap = Modifier + {}

MaxOverlap.name = "MaxOverlap"

MaxOverlap.defaultValue = 0
MaxOverlap.values = {}

for i = 0, 10 do table.insert(MaxOverlap.values, i) end

MaxOverlap.description = "Limit the amount of LN overlap at any point"

---@param config table
---@return string
---@return string
function MaxOverlap:getString(config) return "MO", tostring(config.value) end

---@param config table
function MaxOverlap:apply(config, chart)
    local limit = config.value
    LNs = {}
    for _, note in ipairs(chart.notes:getLinkedNotes()) do
        if note:isLong() then
            table.insert(LNs, {lData = note, note = note.startNote, endNote = note.endNote})
            table.insert(LNs, {note = note.endNote})
        end
    end
    table.sort(LNs, function(a, b)
        if a.note:getTime() == b.note:getTime() then
            return a.note.weight == -1 and b.note.weight ~= -1
        end
        return a.note < b.note
    end)
    local overlapCount = -1
    for _, n in ipairs(LNs) do
        if n.note.weight == 1 then
            if overlapCount >= limit then
                n.note.type = "note"
                n.endNote.type = "ignore"
                n.lData:unlink()
            else
                overlapCount = overlapCount + 1
            end
        elseif n.note.weight == -1 then
            overlapCount = overlapCount - 1
        end
    end

    chart:compute()
end

return MaxOverlap
