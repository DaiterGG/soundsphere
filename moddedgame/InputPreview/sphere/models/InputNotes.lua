local class = require("class")
local InputNote = require("sphere.models.InputNote")
local cfg = require("moddedgame.InputConfig.config")

local InputNotes = class()

function InputNotes:new(keyMod)
    self.keyMod = keyMod
    self.notes = {}
    self.pressed = {}
    local k = "key" .. keyMod
    self.color = cfg.color[k] or cfg.color.default
    self.width = cfg.columnWidth[k] or cfg.columnWidth.default

    self.posY = cfg.startPosY[k] or cfg.startPosY.default
    self.yLimit = cfg.endPosY[k] or cfg.endPosY.default
    self.posX = cfg.posX[k] or cfg.posX.default
    if self.posX[1] == "inline" then
        self.posX = self:inline(self.posX[2])
    end
    local speed
    if cfg.scrollSpeed[k] then
        self.scrollType = cfg.scrollSpeed[k].type
        speed = cfg.scrollSpeed[k].speed
    else
        self.scrollType = cfg.scrollSpeed.default.type
        speed = cfg.scrollSpeed.default.speed
    end

    if self.scrollType == "osu" then
        speed = speed * 7 / 96
    end

    self.scrollSpeed = speed * 1000
    self.scrollDir = cfg.scrollDir
end

function InputNotes:press(column)
    if self.pressed[column] then return end
    local w = self.width
    if type(w) == "table" then
        w = w[column]
    end
    local c = self.color
    if type(c[column]) == "table" then
        c = c[column]
    end
    local y = self.posY
    if type(y) == "table" then
        y = y[column]
    end
    y = 10.8 * y
    local yl = self.yLimit
    if type(yl) == "table" then
        yl = yl[column]
    end
    yl = 10.8 * yl
    
    local newNote = InputNote:new(column, w, self.scrollSpeed, c, y, self.posX[column], self.scrollDir, yl)
    newNote.i = #(self.notes) + 1
    table.insert(self.notes, newNote)
    self.pressed[column] = newNote
end

---@param column number
function InputNotes:release(column)
    if self.pressed[column] then
        self.pressed[column]:release()
        self.pressed[column] = nil
    end
end

function InputNotes:update()
    local i = 1
    while i <= #self.notes do
        if self.notes[i].toDelete then
            table.remove(self.notes, i)
        else
            self.notes[i]:update()
            i = i + 1
        end
    end
end

function InputNotes:inline(startPos)
    local _ = {}
    for i = 1, self.keyMod do
        local w = self.width
        if type(w) == "table" then
            w = w[i]
        end
        _[i] = startPos + ((i - 1) * w)
    end
    return _
end

return InputNotes
