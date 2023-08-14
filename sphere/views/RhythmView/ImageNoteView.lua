local NoteView = require("sphere.views.RhythmView.NoteView")

local ImageNoteView = NoteView + {}

function ImageNoteView:getDrawable()
	local images = self.graphicalNote.startNoteData.images
	local resourceModel = self.graphicalNote.graphicEngine.rhythmModel.resourceModel
	return resourceModel:getResource(images[1][1])
end

function ImageNoteView:draw()
	local drawable = self:getDrawable()
	if not drawable then
		return
	end

	love.graphics.setColor(self:getNotePart("Head"):getColor())
	love.graphics.draw(drawable, self:getTransformParams())
end

function ImageNoteView:getTransformParams()
	local hw = self:getNotePart("Head")
	local w, h = self:getDrawable():getDimensions()
	local nw, nh = hw:get("w"), hw:get("h")
	local sx = nw and nw / w or hw:get("sx") or 1
	local sy = nh and nh / h or hw:get("sy") or 1
	local ox = (hw:get("ox") or 0) * w
	local oy = (hw:get("oy") or 0) * h
	return
		hw:get("x"),
		hw:get("y"),
		hw:get("r") or 0,
		sx,
		sy,
		ox,
		oy
end

return ImageNoteView
