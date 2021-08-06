local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local StageInfoView = Class:new()

StageInfoView.draw = function(self)
	for _, cell in ipairs(self.config.cells) do
		self:drawCellName(cell)
		if cell.valueType == "text" then
			self:drawTextCell(cell)
		elseif cell.valueType == "bar" then
			self:drawBarCell(cell)
		end
	end
end

StageInfoView.drawCellName = function(self, cell)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local cx, dcw
	if type(cell.x) == "table" then
		cx = cell.type.x[cell.x[1]]
		dcw = cell.type.x[cell.x[2]] - cell.type.x[cell.x[1]]
	else
		cx = cell.type.x[cell.x]
		dcw = 0
	end

	local fontName = spherefonts.get(cell.type.name.fontFamily, cell.type.name.fontSize)
	love.graphics.setFont(fontName)
	baseline_print(
		cell.name,
		cx + cell.type.name.x,
		cell.type.y[cell.y] + cell.type.name.baseline,
		cell.type.name.limit + dcw,
		1,
		cell.type.name.align
	)
end

StageInfoView.drawTextCell = function(self, cell)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local cx, dcw
	if type(cell.x) == "table" then
		cx = cell.type.x[cell.x[1]]
		dcw = cell.type.x[cell.x[2]] - cell.type.x[cell.x[1]]
	else
		cx = cell.type.x[cell.x]
		dcw = 0
	end

	local fontValue = spherefonts.get(cell.type.value.text.fontFamily, cell.type.value.text.fontSize)
	love.graphics.setFont(fontValue)
	baseline_print(
		"0",
		cx + cell.type.value.text.x,
		cell.type.y[cell.y] + cell.type.value.text.baseline,
		cell.type.value.text.limit + dcw,
		1,
		cell.type.value.text.align
	)
end

StageInfoView.drawBarCell = function(self, cell)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local cx, dcw
	if type(cell.x) == "table" then
		cx = cell.type.x[cell.x[1]]
		dcw = cell.type.x[cell.x[2]] - cell.type.x[cell.x[1]]
	else
		cx = cell.type.x[cell.x]
		dcw = 0
	end

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		cx + cell.type.value.bar.x,
		cell.type.y[cell.y] + cell.type.value.bar.y,
		cell.type.value.bar.w + dcw,
		cell.type.value.bar.h,
		cell.type.value.bar.h / 2,
		cell.type.value.bar.h / 2
	)

	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.rectangle(
		"fill",
		cx + cell.type.value.bar.x,
		cell.type.y[cell.y] + cell.type.value.bar.y,
		(cell.type.value.bar.w + dcw) / 3,
		cell.type.value.bar.h,
		cell.type.value.bar.h / 2,
		cell.type.value.bar.h / 2
	)
end

return StageInfoView
