local class = require("class")
local InputNote = require("sphere.models.InputNote")
local math_util = require("math_util")

local InputNotes = class()

local osuFactor = 7 / 96

function InputNotes:new(keyMod)
    self.keyMod = keyMod
    self.notes = {}
    self.pressed = {}
    self.color = {0.071, 0.788, 0.357, 1}
    self.startPosY = 1080
    self.width = 140
    self.startPosX = 0
    self.startPosX = self:inline()

    self.scrollType = "osu"
    local speed = 27

    if self.scrollType == "osu" then
        speed = speed * osuFactor
    end

    self.scrollSpeed = speed * 1000
    self.scrollDir = "upscroll"
end

function InputNotes:press(column)
    local newNote = InputNote:new(column, self.width, self.scrollSpeed, self.color, self.startPosY, self.startPosX[column], self.scrollDir)
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
function InputNotes:inline()
    _ = {}
   for i = 1, self.keyMod do
       _[i] = self.startPosX + ((i - 1) * self.width)
   end
   return _
end

return InputNotes
