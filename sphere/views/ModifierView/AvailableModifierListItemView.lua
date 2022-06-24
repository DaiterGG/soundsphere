local transform = require("aqua.graphics.transform")

local ListItemView = require("sphere.views.ListItemView")

local AvailableModifierListItemView = ListItemView:new({construct = false})

AvailableModifierListItemView.draw = function(self)
	local listView = self.listView

	local tf = transform(listView.transform):translate(listView.x, listView.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * listView.h / listView.rows
	local item = self.item

	local prevItem = self.prevItem

	if item.oneUse and item.added then
		love.graphics.setColor(listView.name.addedColor)
	end

	self:drawValue(listView.name, item.name)

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or prevItem.oneUse ~= item.oneUse then
		local text = "One use modifiers"
		if not item.oneUse then
			text = "Sequential modifiers"
		end
		self:drawValue(listView.section, text)
	end
end

AvailableModifierListItemView.receive = function(self, event)
	local config = self.listView

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local tf = transform(config.transform):translate(config.x, config.y)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event[3]
		if button == 1 then
			self.listView.navigator:addModifier(self.itemIndex)
		end
	end
end

return AvailableModifierListItemView
