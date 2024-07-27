local class = require("class")
local InputNote = require("sphere.models.InputNote")

local InputNotes = class()

function InputNotes:new()
    self.notes = {}
    self.pressed = {}
end

function InputNotes:press(column)
    local newNote = InputNote:new(column, 140, 2000)
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
    for _, note in ipairs(self.notes) do
        note:update()
    end
end

return InputNotes
