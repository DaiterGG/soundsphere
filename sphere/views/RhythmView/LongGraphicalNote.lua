local GraphicalNote = require("sphere.views.RhythmView.GraphicalNote")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.update = function(self)
	self.startTimeState = self.graphicalNoteModel.startTimeState
	self.endTimeState = self.graphicalNoteModel.endTimeState
	self.logicalState = self.graphicalNoteModel.logicalNote:getLastState()

	self.headDrawable.x = self:getHeadX()
	self.tailDrawable.x = self:getTailX()
	self.bodyDrawable.x = self:getBodyX()
	self.headDrawable.sx = self:getHeadScaleX()
	self.tailDrawable.sx = self:getTailScaleX()
	self.bodyDrawable.sx = self:getBodyScaleX()

	self.headDrawable.y = self:getHeadY()
	self.tailDrawable.y = self:getTailY()
	self.bodyDrawable.y = self:getBodyY()
	self.headDrawable.sy = self:getHeadScaleY()
	self.tailDrawable.sy = self:getTailScaleY()
	self.bodyDrawable.sy = self:getBodyScaleY()

	self.headDrawable:reload()
	self.tailDrawable:reload()
	self.bodyDrawable:reload()

	self.headDrawable.color = self:getHeadColor()
	self.tailDrawable.color = self:getTailColor()
	self.bodyDrawable.color = self:getBodyColor()
end

LongGraphicalNote.activate = function(self)
	self.headDrawable = self:getHeadDrawable()
	self.tailDrawable = self:getTailDrawable()
	self.bodyDrawable = self:getBodyDrawable()
	self.headDrawable:reload()
	self.tailDrawable:reload()
	self.bodyDrawable:reload()
	self.headContainer = self:getHeadContainer()
	self.tailContainer = self:getTailContainer()
	self.bodyContainer = self:getBodyContainer()
	self.headContainer:add(self.headDrawable)
	self.tailContainer:add(self.tailDrawable)
	self.bodyContainer:add(self.bodyDrawable)

	self.activated = true
end

LongGraphicalNote.deactivate = function(self)
	self.headContainer:remove(self.headDrawable)
	self.tailContainer:remove(self.tailDrawable)
	self.bodyContainer:remove(self.bodyDrawable)
	self.activated = false
end

LongGraphicalNote.reload = function(self)
	self.headDrawable.sx = self:getHeadScaleX()
	self.headDrawable.sy = self:getHeadScaleY()
	self.tailDrawable.sx = self:getTailScaleX()
	self.tailDrawable.sy = self:getTailScaleY()
	self.bodyDrawable.sx = self:getBodyScaleX()
	self.bodyDrawable.sy = self:getBodyScaleY()
	self.headDrawable:reload()
	self.tailDrawable:reload()
	self.bodyDrawable:reload()
end

LongGraphicalNote.getHeadColor = function(self)
	return self.noteSkinImageView:getG(self, "Head", "color", self.startTimeState)
end

LongGraphicalNote.getTailColor = function(self)
	return self.noteSkinImageView:getG(self, "Tail", "color", self.startTimeState)
end

LongGraphicalNote.getBodyColor = function(self)
	return self.noteSkinImageView:getG(self, "Body", "color", self.startTimeState)
end

LongGraphicalNote.getHeadLayer = function(self)
	return self.noteSkinImageView:getNoteLayer(self, "Head")
end

LongGraphicalNote.getTailLayer = function(self)
	return self.noteSkinImageView:getNoteLayer(self, "Tail")
end

LongGraphicalNote.getBodyLayer = function(self)
	return self.noteSkinImageView:getNoteLayer(self, "Body")
end

LongGraphicalNote.getHeadDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Head")
end

LongGraphicalNote.getTailDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Tail")
end

LongGraphicalNote.getBodyDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Body")
end

LongGraphicalNote.getHeadContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Head")
end

LongGraphicalNote.getTailContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Tail")
end

LongGraphicalNote.getBodyContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Body")
end

LongGraphicalNote.getHeadWidth = function(self)
	return self.noteSkinImageView:getG(self, "Head", "w", self.startTimeState)
end

LongGraphicalNote.getTailHeight = function(self)
	return self.noteSkinImageView:getG(self, "Tail", "h", self.startTimeState)
end

LongGraphicalNote.getBodyWidth = function(self)
	return self.noteSkinImageView:getG(self, "Body", "w", self.startTimeState)
end

LongGraphicalNote.getHeadHeight = function(self)
	return self.noteSkinImageView:getG(self, "Head", "h", self.startTimeState)
end

LongGraphicalNote.getTailWidth = function(self)
	return self.noteSkinImageView:getG(self, "Tail", "w", self.startTimeState)
end

LongGraphicalNote.getBodyHeight = function(self)
	return self.noteSkinImageView:getG(self, "Body", "h", self.startTimeState)
end

LongGraphicalNote.getHeadX = function(self)
	return
		  self.noteSkinImageView:getG(self, "Head", "x", self.startTimeState)
		+ self.noteSkinImageView:getG(self, "Head", "w", self.startTimeState)
		* self.noteSkinImageView:getG(self, "Head", "ox", self.startTimeState)
end

LongGraphicalNote.getTailX = function(self)
	return
		  self.noteSkinImageView:getG(self, "Tail", "x", self.endTimeState)
		+ self.noteSkinImageView:getG(self, "Tail", "w", self.endTimeState)
		* self.noteSkinImageView:getG(self, "Tail", "ox", self.endTimeState)
end

LongGraphicalNote.getBodyX = function(self)
	local dg = self:getHeadX() - self:getTailX()
	local timeState
	if dg >= 0 then
		timeState = self.endTimeState
	else
		timeState = self.startTimeState
	end
	return
		  self.noteSkinImageView:getG(self, "Body", "x", timeState)
		+ self.noteSkinImageView:getG(self, "Head", "w", timeState)
		* self.noteSkinImageView:getG(self, "Body", "ox", timeState)
end

LongGraphicalNote.getHeadY = function(self)
	return
		  self.noteSkinImageView:getG(self, "Head", "y", self.startTimeState)
		+ self.noteSkinImageView:getG(self, "Head", "h", self.startTimeState)
		* self.noteSkinImageView:getG(self, "Head", "oy", self.startTimeState)
end

LongGraphicalNote.getTailY = function(self)
	return
		  self.noteSkinImageView:getG(self, "Tail", "y", self.endTimeState)
		+ self.noteSkinImageView:getG(self, "Tail", "h", self.endTimeState)
		* self.noteSkinImageView:getG(self, "Tail", "oy", self.endTimeState)
end

LongGraphicalNote.getBodyY = function(self)
	local dg = self:getHeadY() - self:getTailY()
	local timeState
	if dg >= 0 then
		timeState = self.endTimeState
	else
		timeState = self.startTimeState
	end
	return
		  self.noteSkinImageView:getG(self, "Body", "y", timeState)
		+ self.noteSkinImageView:getG(self, "Head", "h", timeState)
		* self.noteSkinImageView:getG(self, "Body", "oy", timeState)
end

LongGraphicalNote.getHeadScaleX = function(self)
	return self:getHeadWidth() / self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Head"):getWidth())
end

LongGraphicalNote.getTailScaleX = function(self)
	return self:getTailWidth() / self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Tail"):getWidth())
end

LongGraphicalNote.getBodyScaleX = function(self)
	return
		(
			math.abs(self:getHeadX() - self:getTailX())
			+ self.noteSkinImageView:getG(self, "Body", "w", self.startTimeState)
		) / self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Body"):getWidth())
end

LongGraphicalNote.getHeadScaleY = function(self)
	return self:getHeadHeight() / self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Head"):getHeight())
end

LongGraphicalNote.getTailScaleY = function(self)
	return self:getTailHeight() / self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Tail"):getHeight())
end

LongGraphicalNote.getBodyScaleY = function(self)
	return
		(
			math.abs(self:getHeadY() - self:getTailY())
			+ self.noteSkinImageView:getG(self, "Body", "h", self.startTimeState)
		) / self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Body"):getHeight())
end

return LongGraphicalNote
