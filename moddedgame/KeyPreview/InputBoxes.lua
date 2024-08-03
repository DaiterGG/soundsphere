local class = require("class")
local cfg = require("moddedgame.InputConfig.config")
local KeyBox = require("moddedgame.KeyPreview.InputBox")

local InputBoxes = class()

function InputBoxes:new(keyMod)
    self.keyMod = keyMod
    self.boxes = {}
    self.pressed = {}
    self.color = cfg.color[k] or cfg.color.default
    self.width = cfg.columnWidth[k] or cfg.columnWidth.default

    self.posY = cfg.startPosY[k] or cfg.startPosY.default
    self.yLimit = cfg.endPosY[k] or cfg.endPosY.default
    self.posX = cfg.posX[k] or cfg.posX.default

    table.insert(self.boxes, KeyBox:new(1, 100, 100,{1,1,1,1},{1,1,1,1} ,100,100))

    -- for i = 1, keyMod do
    --     table.insert(self.boxes, KeyBox:new(i, 100, 100,{1,1,1,1},{1,1,1,1} ,100,100))
    -- end
end

function InputBoxes:getInput(key, isPressed)
    self.boxes[key]:press(isPressed)
end

function InputBoxes:update()
    for i = 1, #self.boxes do
        local b = self.boxes[i]
        self.boxes[i]:update()
        i = i + 1
    end
end

return InputBoxes
