local class = require("class")
local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")
local LongNoteView = require("sphere.views.RhythmView.LongNoteView")
local ImageNoteView = require("sphere.views.RhythmView.ImageNoteView")
local VideoNoteView = require("sphere.views.RhythmView.VideoNoteView")

local NoteViewFactory = class()

local notes = {
	default = {
		ShortNote = {ShortNoteView, "ShortNote"},
		SoundNote = {ShortNoteView, "SoundNote"},
		LongNote = {LongNoteView, "LongNote"},
	},
	animation = {
		ShortNote = {ShortNoteView, "ShortNoteAnimation"},
		LongNote = {ShortNoteView, "LongNoteAnimation"},
	},
	lighting = {
		ShortNote = {ShortNoteView, "ShortNoteLighting"},
		LongNote = {ShortNoteView, "LongNoteLighting"},
	},
	bga = {
		ImageNote = {ImageNoteView, "ImageNote"},
		VideoNote = {VideoNoteView, "VideoNote"},
	},
}

for _, c in pairs(notes) do
	for k, v in pairs(c) do
		c[k] = v[1](v[2])
	end
end

function NoteViewFactory:getNoteView(graphicalNote, mode)
	return notes[mode][graphicalNote.noteType]
end

return NoteViewFactory
