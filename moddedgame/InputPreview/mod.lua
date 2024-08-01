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
    ModulePatcher:observe("sphere.views.GameplayView.InputAnimationView", "receive", function(self, instance, ...)
        local _self = select(1, ...)
        local event = select(2, ...)

        local key = event and event[1]

	    local found
	    for _, input in ipairs(_self.inputs) do
		    if key == input then
			    found = true
			    break
		    end
	    end
	    if not found then
	    	return
	    end
        local key = tonumber(key:split("y")[2])
        
        if event.name == "keypressed" then
            InputNotes:press(key)
        elseif event.name == "keyreleased" then
            InputNotes:release(key)
        end
    end)
end

return InputMod
