local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local TimeRate = InconsequentialModifier:new()

TimeRate.name = "TimeRate"
TimeRate.shortName = "TimeRate"

TimeRate.construct = function(self)
	self.value = 1
end

TimeRate.tostring = function(self)
	return self.value .. "X"
end

TimeRate.apply = function(self)
	local engine = self.sequence.manager.engine
	engine.score.timeRate = true
	engine.timeRate = self.value
	engine.targetTimeRate = self.value
	engine:setTimeRate(self.value)
end

return TimeRate