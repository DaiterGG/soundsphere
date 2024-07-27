local class = require("class")

local InputNote = class()

function InputNote:new(column, width, scrollSpeed)
    local new = setmetatable({}, { __index = self })
    new.pos = 1080
    new.direction = -1
    new.scrollTime = love.timer.getTime()
    new.color = {0.071, 0.788, 0.357}
    new.released = false
    new.height = 0
    new.width = assert(width, "missing width")
    new.scrollSpeed = assert(scrollSpeed, "missing scrollSpeed")
    new.column = assert(column, "missing column")
    return new
end

function InputNote:release()
    self.released = true
end

function InputNote:update()
    local time = love.timer.getTime()
    local movedBy = (time - self.scrollTime) * self.scrollSpeed * self.direction
    self.pos = self.pos + movedBy
    love.graphics.setColor(self.color)
    love.graphics.origin()
    if not self.released then
        self.height = self.height + movedBy
    end
    --print("pos y", self.pos - self.height, " pos ", self.pos, " height ", self.height)
    local _ ,res = love.graphics.getDimensions()
    res = res / 1080
    local x = ((self.column - 1) * self.width) * res
    local y = (self.pos - self.height) * res
    local w = self.width * res
    local h = self.height * res
    love.graphics.rectangle("fill", x, y, w, h)
    self.scrollTime = time
end

return InputNote
