local GraphicalNote = require("sphere.screen.gameplay.GraphicEngine.GraphicalNote")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.update = function(self)
	self:computeVisualTime()
	
	if not self:tryNext() then
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
		
		local color = self:getColor()
		self.headDrawable.color = color
		self.tailDrawable.color = color
		self.bodyDrawable.color = color
	end
end

LongGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	self.endNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	
	self.sdt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	self.edt = self.graphicEngine.currentTime - self.endNoteData.timePoint.currentVisualTime
	self.fsdt = self.graphicEngine.currentTime - (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime)
end

LongGraphicalNote.updateFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint.absoluteTime
	local endTime = self.endNoteData.timePoint.absoluteTime
	self.fakeStartTime = self.graphicEngine.currentTime > startTime and self.graphicEngine.currentTime or startTime
	self.fakeStartTime = math.min(self.fakeStartTime, endTime)
end

LongGraphicalNote.getFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint.absoluteTime
	if self.logicalNote.state == "startPassedPressed" then
		self:updateFakeStartTime()
		return self.fakeStartTime
	else
		return self.fakeStartTime or self.startNoteData.timePoint.absoluteTime
	end
end

LongGraphicalNote.getFakeVelocityData = function(self)
	if self.logicalNote.state == "startPassedPressed" and self.fakeStartTime then
		return "current"
	else
		return self.fakeVelocityData or self.startNoteData.timePoint.velocityData
	end
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local fakeStartTime = self:getFakeStartTime()
	local fakeVelocityData = self:getFakeVelocityData()
	if fakeVelocityData == "current" then
		fakeVelocityData = self.noteDrawer.currentVelocityData
		self.fakeVelocityData = fakeVelocityData
	end
	
	local fakeVisualClearStartTime
		= (fakeStartTime - fakeVelocityData.timePoint.absoluteTime)
		* fakeVelocityData.currentSpeed
		+ fakeVelocityData.timePoint.zeroClearVisualTime
		
	local fakeVisualStartTime
		= (fakeVisualClearStartTime - self.noteDrawer.currentTimePoint.zeroClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint.absoluteTime
		
	return fakeVisualStartTime
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

LongGraphicalNote.getColor = function(self)
	local logicalNote = self.logicalNote
	
	local color = self.noteSkin.color
	if self.fakeStartTime and self.fakeStartTime >= self.endNoteData.timePoint.absoluteTime then
		return color.transparent
	elseif logicalNote.state == "clear" then
		return color.clear
	elseif logicalNote.state == "startMissed" then
		return color.startMissed
	elseif logicalNote.state == "startMissedPressed" then
		return color.startMissedPressed
	elseif logicalNote.state == "startPassedPressed" then
		return color.startPassedPressed
	elseif logicalNote.state == "endPassed" then
		return color.endPassed
	elseif logicalNote.state == "endMissed" then
		return color.endMissed
	elseif logicalNote.state == "endMissedPassed" then
		return color.endMissedPassed
	end

	return color.clear
end

LongGraphicalNote.getHeadLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Head")
end

LongGraphicalNote.getTailLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Tail")
end

LongGraphicalNote.getBodyLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Body")
end

LongGraphicalNote.getHeadDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Head")
end

LongGraphicalNote.getTailDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Tail")
end

LongGraphicalNote.getBodyDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Body")
end

LongGraphicalNote.getHeadContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Head")
end

LongGraphicalNote.getTailContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Tail")
end

LongGraphicalNote.getBodyContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Body")
end

LongGraphicalNote.getHeadWidth = function(self)
	return self.noteSkin:getG(0, self.sdt, self, "Head", "w")
end

LongGraphicalNote.getTailHeight = function(self)
	return self.noteSkin:getG(0, self.sdt, self, "Tail", "h")
end

LongGraphicalNote.getBodyWidth = function(self)
	return self.noteSkin:getG(0, self.sdt, self, "Body", "w")
end

LongGraphicalNote.getHeadHeight = function(self)
	return self.noteSkin:getG(0, self.sdt, self, "Head", "h")
end

LongGraphicalNote.getTailWidth = function(self)
	return self.noteSkin:getG(0, self.sdt, self, "Tail", "w")
end

LongGraphicalNote.getBodyHeight = function(self)
	return self.noteSkin:getG(0, self.sdt, self, "Body", "h")
end

LongGraphicalNote.getHeadX = function(self)
	local dt = self.fsdt
	return
		  self.noteSkin:getG(0, dt, self, "Head", "x")
		+ self.noteSkin:getG(0, dt, self, "Head", "w")
		* self.noteSkin:getG(0, dt, self, "Head", "ox")
end

LongGraphicalNote.getTailX = function(self)
	local dt = self.edt
	return
		  self.noteSkin:getG(0, dt, self, "Tail", "x")
		+ self.noteSkin:getG(0, dt, self, "Tail", "w")
		* self.noteSkin:getG(0, dt, self, "Tail", "ox")
end

LongGraphicalNote.getBodyX = function(self)
	local dg = self:getHeadX() - self:getTailX()
	local dt
	if dg >= 0 then
		dt = self.edt
	else
		dt = self.fsdt
	end
	return
		  self.noteSkin:getG(0, dt, self, "Body", "x")
		+ self.noteSkin:getG(0, dt, self, "Head", "w")
		* self.noteSkin:getG(0, dt, self, "Body", "ox")
end

LongGraphicalNote.getHeadY = function(self)
	local dt = self.fsdt
	return
		  self.noteSkin:getG(0, dt, self, "Head", "y")
		+ self.noteSkin:getG(0, dt, self, "Head", "h")
		* self.noteSkin:getG(0, dt, self, "Head", "oy")
end

LongGraphicalNote.getTailY = function(self)
	local dt = self.edt
	return
		  self.noteSkin:getG(0, dt, self, "Tail", "y")
		+ self.noteSkin:getG(0, dt, self, "Tail", "h")
		* self.noteSkin:getG(0, dt, self, "Tail", "oy")
end

LongGraphicalNote.getBodyY = function(self)
	local dg = self:getHeadY() - self:getTailY()
	local dt
	if dg >= 0 then
		dt = self.edt
	else
		dt = self.fsdt
	end
	return
		  self.noteSkin:getG(0, dt, self, "Body", "y")
		+ self.noteSkin:getG(0, dt, self, "Head", "h")
		* self.noteSkin:getG(0, dt, self, "Body", "oy")
end

LongGraphicalNote.getHeadScaleX = function(self)
	return self:getHeadWidth() / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Head"):getWidth())
end

LongGraphicalNote.getTailScaleX = function(self)
	return self:getTailWidth() / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Tail"):getWidth())
end

LongGraphicalNote.getBodyScaleX = function(self)
	return
		(
			math.abs(self:getHeadX() - self:getTailX())
			+ self.noteSkin:getG(0, self.sdt, self, "Body", "w")
		) / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Body"):getWidth())
end

LongGraphicalNote.getHeadScaleY = function(self)
	return self:getHeadHeight() / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Head"):getHeight())
end

LongGraphicalNote.getTailScaleY = function(self)
	return self:getTailHeight() / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Tail"):getHeight())
end

LongGraphicalNote.getBodyScaleY = function(self)
	return
		(
			math.abs(self:getHeadY() - self:getTailY())
			+ self.noteSkin:getG(0, self.sdt, self, "Body", "h")
		) / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Body"):getHeight())
end

LongGraphicalNote.whereWillDraw = function(self)
	local wwdStart = self.noteSkin:whereWillDraw(self, self.fsdt)
	local wwdEnd = self.noteSkin:whereWillDraw(self, self.edt)

	if wwdStart == wwdEnd then
		return wwdStart
	end

	return 0
end

return LongGraphicalNote
