local class = require("class")

local InputNote = class()

function InputNote:new(column, width, scrollSpeed, color, startPosY, startPosX, vertDirection, yLimit)
    local new = setmetatable({}, { __index = self })
    new.posY = startPosY
    new.posX = startPosX
    new.scrollTime = love.timer.getTime()
    new.color = color
    new.released = false
    new.height = 0
    new.width = width
    new.scrollSpeed = scrollSpeed
    new.column = column
    new.yLimit = yLimit
    if vertDirection == "upscroll" then
        new.direction = -1
    else
        new.direction = 1
    end

    return new
end

function InputNote:release()
    self.released = true
end

function InputNote:update()
    local time = love.timer.getTime()
    local movedBy = (time - self.scrollTime) * self.scrollSpeed * self.direction
    self.posY = self.posY + movedBy
    love.graphics.setColor(self.color)
    love.graphics.origin()
    if not self.released then
        self.height = self.height + movedBy
    end
    if (self.posY - self.height > 1080 and self.posY > 1080) or
        (self.posY - self.height < 0 and self.posY < 0) then
        self.toDelete = true
        return
    end
    local h 
    local y = self.posY - self.height
    if (self.direction * self.posY > self.direction * self.yLimit) then
        h = self.yLimit - y
    else
        h = self.height
    end

    if h * self.direction > 0 then
        local sw, sh = love.graphics.getDimensions()
        local resY = sh / 1080
        local resX = sw / 1920
        local x = self.posX * resX
        local w = self.width * resX
        y = (self.posY - self.height) * resY
        h = h * resY
        love.graphics.rectangle("fill", x, y, w, h)
        self.scrollTime = time
    end
end

return InputNote
