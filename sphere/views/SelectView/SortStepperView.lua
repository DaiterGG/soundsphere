
local Class = require("aqua.util.Class")
local just = require("just")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local StepperView = require("sphere.views.StepperView")

local SortStepperView = Class:new()

SortStepperView.construct = function(self)
	self.stepperView = StepperView:new()
end

SortStepperView.getIndexValue = function(self)
	return self.game.sortModel:toIndexValue(self.game.sortModel.name)
end

SortStepperView.getCount = function(self)
	return #self.game.sortModel.names
end

SortStepperView.updateIndexValue = function(self, indexValue)
	self.navigator:setSortFunction(self.game.sortModel:fromIndexValue(indexValue))
end

SortStepperView.increaseValue = function(self, delta)
	self.navigator:scrollSortFunction(delta)
end

SortStepperView.draw = function(self)
	local sortModel = self.game.sortModel

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local stepperView = self.stepperView
	local w, h = self.w, self.h

	local padding = self.frame.padding

	local value = self:getIndexValue()
	local count = self:getCount()

	local overAll, overLeft, overRight = stepperView:isOver(w, h)

	local id = tostring(self.item)
	local scrolled, delta = just.wheel_behavior(id .. "A", overAll)
	local changedLeft, activeLeft, hoveredLeft = just.button_behavior(id .. "L", overLeft)
	local changedRight, activeRight, hoveredRight = just.button_behavior(id .. "R", overRight)

	if changedLeft or delta == -1 then
		self:increaseValue(-1)
	elseif changedRight or delta == 1 then
		self:increaseValue(1)
	end

	love.graphics.setColor(1, 1, 1, 0.08)
	if hoveredLeft or hoveredRight then
		love.graphics.setColor(1, 1, 1, (activeLeft or activeRight) and 0.2 or 0.15)
	end

	local hm = h - padding * 2
	love.graphics.rectangle(
		"fill",
		padding,
		padding,
		w - padding * 2,
		hm,
		hm / 2,
		hm / 2
	)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get(unpack(self.text.font)))

	baseline_print(
		sortModel.name,
		self.text.x,
		self.text.baseline,
		self.w - self.text.x - self.text.xr,
		1,
		self.text.align
	)

	love.graphics.setLineWidth(self.frame.lineWidth)
	love.graphics.setLineStyle(self.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		padding,
		padding,
		self.w - padding * 2,
		hm,
		hm / 2,
		hm / 2
	)

	stepperView:draw(w, h, value, count)
end

return SortStepperView
