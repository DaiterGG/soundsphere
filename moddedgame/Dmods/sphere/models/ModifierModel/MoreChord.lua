local Modifier = require("sphere.models.ModifierModel.Modifier")
local FixMap = require("sphere.models.ModifierModel.FixMap")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

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

---@param config table
function MoreChord:apply(config, chart)
	local sj = FixMap:findShortestJack(chart)
    print("shortest jack " .. sj)

    local keyChart = {}
    local keyCount = chart.inputMode.key
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
		lines[time] = lines[time] or { time = time }
		table.insert(lines[time], note)
	end

	for _, line in pairs(lines) do
		for i = 1, config.value do
			local rngIndex = math.random(1, keyCount)
			local rngNote = math.random(1, #line)

			local newN = line[rngNote].lData:clone()
			newN:setColumn("key" .. rngIndex)
			local n = {}

            n.lData = newN
            n.startNote = newN.startNote
            n.endNote = newN.endNote
            n.startTime = newN:getStartTime()
            n.endTime = newN:getEndTime()
            n.column = rngIndex

			newN = n
            keyChart[#keyChart + 1] = newN
		end
	end
	
	FixMap:applyFix(chart, keyChart, sj)
end


return MoreChord