local frame_print = require("aqua.graphics.frame_print")
local just = require("just")

return function(id, text, h, align)
	love.graphics.setColor(1, 1, 1, 1)

	local font = love.graphics.getFont()
	local w = font:getWidth(text)

	just.mouse_over(id, just.is_over(w, h), "mouse")

	frame_print(text, 0, 0, w, h, 1, align, "center")

	just.next(w, h)
end
