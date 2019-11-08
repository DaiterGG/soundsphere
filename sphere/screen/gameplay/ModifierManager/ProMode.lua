local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local ProMode = InconsequentialModifier:new()

ProMode.name = "ProMode"
ProMode.shortName = "ProMode"

ProMode.apply = function(self)
	self.sequence.manager.engine.score.promode = true
end

return ProMode