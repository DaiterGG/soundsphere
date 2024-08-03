local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.Coop: sphere.Modifier
---@operator call: sphere.Coop
local Coop = Modifier + {}

Coop.name = "Coop"

Coop.defaultValue = 20
Coop.values = {}
for i = 1, 5 do table.insert(Coop.values, i * 10) end

Coop.description =
    "Double the input mode and alternate the map between \nleft and right every 'value' seconds"

---@param config table
---@return string
---@return string
function Coop:getString(config) return tostring(config.value), "COO" end

---@param config table
---@param state table
function Coop:applyMeta(config, state)
	local columnCount = state.inputMode.key
	if not columnCount then
		return
	end
	state.inputMode.key = state.inputMode.key * 2
end


---@param config table
function Coop:apply(config, chart)

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

    local keyCount = chart.inputMode.key

    table.sort(keyChart, function(a, b) return a.startTime < b.startTime end)

    local move = false
    local currentTime
    for _, n in ipairs(keyChart) do
        if not currentTime or currentTime + config.value < n.startTime then
            currentTime = n.startTime
            move = not move
        end
        if move then
            local new_column = n.column + keyCount
            n.lData:setColumn("key" .. new_column)
        end
    end

    for i, lnote in pairs(keyChart) do
        -- print(lnote.startNote, lnote.endNote)
        chart.notes:insertLinked(lnote)
    end

    chart.inputMode.key = keyCount * 2
    chart:compute()
end

return Coop
