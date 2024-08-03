local ModulePatcher = require("moddedgame.ModulePatcher.ModulePatcher")
local InputBoxes = require("moddedgame.KeyPreview.InputBoxes")

local InputMod = {}

function InputMod:init()


    ModulePatcher:observe("sphere.models.NoteSkinModel", "loadNoteSkin", function(self, instance, ...)
        local keyCount = select(2, ...)
        local k = tonumber(tostring(keyCount):split("k")[1])
        InputBoxes:new(k)
    end)
    ModulePatcher:observe("sphere.views.GameplayView.CircleProgressView", "draw", function(self, instance, ...)
        InputBoxes:update()
    end)
    ModulePatcher:observe("sphere.views.GameplayView.InputAnimationView", "receive", function(self, instance, ...)
        
    end)
end

return InputMod
