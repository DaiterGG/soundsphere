local transform = require("aqua.graphics.transform")
local just_layout = require("just.layout")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local function setRect(t, x, y, w, h)
	t.x = assert(x)
	t.y = assert(y)
	t.w = assert(w)
	t.h = assert(h)
end

local function getRect(out, r)
	if not out then
		return r.x, r.y, r.w, r.h
	end
	out.x = r.x
	out.y = r.y
	out.w = r.w
	out.h = r.h
end

local function drawFrame(rect)
	local x, y, w, h = getRect(nil, rect)
	love.graphics.rectangle("fill", x, y, w, h, 36)
end

return {
	header = {},
	footer = {},
	subheader = {},
	column1 = {},
	column2 = {},
	column3 = {},
	column2row1 = {},
	column2row2 = {},
	column2row3 = {},
	column2row2row1 = {},
	column2row2row2 = {},
	column1row1 = {},
	column1row2 = {},
	column1row3 = {},
	column1row1row1 = {},
	column1row1row2 = {},
	transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0},
	draw = function(self)
		local width, height = love.graphics.getDimensions()
		love.graphics.origin()

		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.rectangle("fill", 0, 0, width, height)

		love.graphics.replaceTransform(transform(self.transform))

		local _x, _y = love.graphics.inverseTransformPoint(0, 0)
		local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
		local _w, _h = _xw - _x, _yh - _y

		self.x, self.x = _x, _y
		self.w, self.h = _w, _h

		local x_int = 24
		local y_int = 55

		local x0, w0 = just_layout(_x, _w, {-1})
		local x1, w1 = just_layout(_x, _w, {y_int, -1/2, x_int, -1/3, x_int, -(1 - 1/2 - 1/3), y_int})

		local y0, h0 = just_layout(0, 1080, {89, y_int, -1, y_int, 1080 / 3})

		setRect(self.header, x0[1], y0[1], w0[1], h0[1])
		setRect(self.footer, x0[1], y0[5], w0[1], h0[5])
		setRect(self.subheader, x1[4], y0[2], w1[4], h0[2])

		setRect(self.column1, x1[2], y0[3], w1[2], h0[3])
		setRect(self.column2, x1[4], y0[3], w1[4], h0[3])
		setRect(self.column3, x1[6], y0[3], w1[6], h0[3])

		local y1, h1 = just_layout(self.column2.y, self.column2.h, {336, -1, 72})
		-- local y1, h1 = just_layout(self.column2.y, self.column2.h, {336, x_int, -1})

		setRect(self.column2row1, x1[4], y1[1], w1[4], h1[1])
		setRect(self.column2row2, x1[4], y1[2], w1[4], h1[2])
		setRect(self.column2row3, x1[4], y1[3], w1[4], h1[3])

		local y2, h2 = just_layout(self.column2row2.y, self.column2row2.h, {72, 72 * 5})

		setRect(self.column2row2row1, x1[4], y2[1], w1[4], h2[1])
		setRect(self.column2row2row2, x1[4], y2[2], w1[4], h2[2])

		local y3, h3 = just_layout(self.column1.y, self.column1.h, {72 * 6, x_int, -1, x_int, 72 * 2})

		setRect(self.column1row1, x1[2], y3[1], w1[2], h3[1])
		setRect(self.column1row2, x1[2], y3[3], w1[2], h3[3])
		setRect(self.column1row3, x1[2], y3[5], w1[2], h3[5])

		local y4, h4 = just_layout(self.column1row1.y, self.column1row1.h, {72, -1})

		setRect(self.column1row1row1, x1[2], y4[1], w1[2], h4[1])
		setRect(self.column1row1row2, x1[2], y4[2], w1[2], h4[2])

		love.graphics.setColor(0, 0, 0, 0.8)

		love.graphics.rectangle("fill", _x, _y, _w, h0[1])
		love.graphics.rectangle("fill", _x, _yh - h0[5], _w, h0[5])

		return self:drawNotecharts()
	end,
	drawNotecharts = function(self)
		drawFrame(self.column3)
		drawFrame(self.column1)
		drawFrame(self.column2row1)
		-- drawFrame(self.column2row2)
		-- drawFrame(self.column2row3)

		love.graphics.setColor(0, 0, 0, 0.9)
		local x, y, w, h = getRect(nil, self.column2row2)
		RoundedRectangle("fill", x, y - 1, w, h + 1, 36, false, false, 2)

		love.graphics.setColor(0, 0, 0, 0.8)
		local x, y, w, h = getRect(nil, self.column2row3)
		RoundedRectangle("fill", x, y, w, h, 36, false, false, 2)
	end,
}