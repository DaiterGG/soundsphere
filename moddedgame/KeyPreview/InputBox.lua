local class = require("class")
local just = require("just")

local InputBox = class()

function InputBox:new(column, width, height, colorIdle, colorHeld, x, y)
    local new = setmetatable({}, { __index = self })
    new.x = x
    new.y = y
    new.colorIdle = colorIdle
    new.colorHeld = colorHeld
    new.isPressed = false
    new.height = height
    new.width = width
    new.column = column
    new.mousePos = love.mouse.getPosition()
    new.lastX = 0
    new.lastY = 0
    new.lastOver = nil
    return new
end

function InputBox:press(isPressed)
    self.isPressed = isPressed
end

function InputBox:update()
    love.graphics.origin()
    if self.isPressed then
        love.graphics.setColor(self.colorHeld)
    else
        love.graphics.setColor(self.colorIdle)
    end
    local sw, sh = love.graphics.getDimensions()
    local resX = sw / 1920
    local resY = sh / 1080


    local changed, active, hovered = just.button("ibox" .. self.column, self.lastOver)
    if active then
        if just.mousepressed(1) then
            self.lastX, self.lastY = love.mouse.getPosition()
            self.lastX = self.lastX / resX
            self.lastY = self.lastY / resY
        end
        print("active")
        local xd, yd = love.mouse.getPosition()
        xd = xd / resX
        yd = yd / resY
        self.x = self.x + (xd - self.lastX)
        self.y = self.y + (yd - self.lastY)
        self.lastX, self.lastY = xd, yd
    end
    
    local xd, yd = love.mouse.getPosition()
    
    local w = self.width * resX
    local h = self.height * resX
    local x = self.x * resX - w / 2
    local y = self.y * resY - h / 2
    
    
    self.lastOver = just.is_over(w, h, x, y)
    love.graphics.rectangle("fill", x, y, w, h)
end

return InputBox
