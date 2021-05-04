local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ModifierIconView = Class:new()

ModifierIconView.shapes = {
	empty = {false, false, false, false, false, false, false, false},
	full = {true, true, true, true, true, true, true, true},
	topBottom = {false, true, true, false, true, true, true, true},
	bottomArcs = {false, false, false, false, false, false, true, true},
}

ModifierIconView.lines = {
	one = {10 / 52},
	two = {-2 / 52, 22 / 52},
}

ModifierIconView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

ModifierIconView.draw = function(self)
	local config = self.config
	local screen = config.screen
	local cs = self.cs

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(cs:X(config.size / 40 / screen.h))

	self:drawBorder(self.shapes.bottomArcs)
	self:drawText(self.lines.two, "MOD", "00")
end

ModifierIconView.drawText = function(self, lines, topText, bottomText)
	local config = self.config
	local screen = config.screen
	local cs = self.cs

	local fx = config.x + config.size / 8
	local fy = config.y + config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4

	local font = aquafonts.getFont(spherefonts.NotoMonoRegular, 28)
	love.graphics.setFont(font)
	if topText then
		love.graphics.printf(
			topText,
			cs:X(fx / screen.h, true),
			cs:Y((fy + lines[1] * fs) / screen.h, true),
			52,
			"center",
			0,
			cs.one / screen.h * fs / 52,
			cs.one / screen.h * fs / 52
		)
	end
	if bottomText then
		love.graphics.printf(
			bottomText,
			cs:X(fx / screen.h, true),
			cs:Y((fy + lines[2] * fs) / screen.h, true),
			52,
			"center",
			0,
			cs.one / screen.h * fs / 52,
			cs.one / screen.h * fs / 52
		)
	end
end

ModifierIconView.drawBorder = function(self, shape)
	local config = self.config
	local screen = config.screen
	local cs = self.cs

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(cs:X(config.size / 40 / screen.h))

	local fx = config.x + config.size / 8
	local fy = config.y + config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4

	if shape[1] then
		love.graphics.line(
			cs:X(fx / screen.h, true),
			cs:Y((fy + fr) / screen.h, true),
			cs:X(fx / screen.h, true),
			cs:Y((fy + fs - fr) / screen.h, true)
		)
	end
	if shape[2] then
		love.graphics.line(
			cs:X((fx + fr) / screen.h, true),
			cs:Y((fy + fs) / screen.h, true),
			cs:X((fx + fs - fr) / screen.h, true),
			cs:Y((fy + fs) / screen.h, true)
		)
	end
	if shape[3] then
		love.graphics.line(
			cs:X((fx + fr) / screen.h, true),
			cs:Y(fy / screen.h, true),
			cs:X((fx + fs - fr) / screen.h, true),
			cs:Y(fy / screen.h, true)
		)
	end
	if shape[4] then
		love.graphics.line(
			cs:X((fx + fs) / screen.h, true),
			cs:Y((fy + fr) / screen.h, true),
			cs:X((fx + fs) / screen.h, true),
			cs:Y((fy + fs - fr) / screen.h, true)
		)
	end

	if shape[5] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fr) / screen.h, true),
			cs:Y((fy + fr) / screen.h, true),
			cs:X(fr / screen.h),
			-math.pi,
			-math.pi / 2
		)
	end
	if shape[6] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fs - fr) / screen.h, true),
			cs:Y((fy + fr) / screen.h, true),
			cs:X(fr / screen.h),
			-math.pi / 2,
			0
		)
	end
	if shape[7] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fr) / screen.h, true),
			cs:Y((fy + fs - fr) / screen.h, true),
			cs:X(fr / screen.h),
			math.pi,
			math.pi / 2
		)
	end
	if shape[8] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fs - fr) / screen.h, true),
			cs:Y((fy + fs - fr) / screen.h, true),
			cs:X(fr / screen.h),
			math.pi / 2,
			0
		)
	end
end

return ModifierIconView
