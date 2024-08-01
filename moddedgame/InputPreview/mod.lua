local ModulePatcher = require("moddedgame.ModulePatcher.ModulePatcher")

local InputMod = {}

function InputMod:init()

    local InputNotes = require("sphere.models.InputNotes")

    ModulePatcher:observe("sphere.models.NoteSkinModel", "loadNoteSkin", function(self, instance, ...)
        local keyCount = select(2, ...)

        local k = tonumber(tostring(keyCount):split("k")[1])
        InputNotes:new(k)
    end)
    ModulePatcher:observe("sphere.views.GameplayView.CircleProgressView", "draw", function(self, instance, ...)
        InputNotes:update()
    end)
    ModulePatcher:observe("sphere.models.RhythmModel.InputManager", "setState", function(self, instance, ...)
        local virtualKey = select(2, ...)
        local state = select(3, ...)
        local key = tonumber(virtualKey:split("y")[2])
        if state then
            InputNotes:press(key)
        else
            InputNotes:release(key)
        end
    end)
end

return InputMod
