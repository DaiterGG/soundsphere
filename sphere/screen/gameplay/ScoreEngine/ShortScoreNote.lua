local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local ShortScoreNote = ScoreNote:new()

ShortScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	ScoreNote.construct(self)
end

ShortScoreNote.getMaxScore = function(self)
	if not self.logicalNote.autoplay then
		return 1
	end

	return 0
end

ShortScoreNote.passEdge = 0.120
ShortScoreNote.missEdge = 0.160
ShortScoreNote.getTimeState = function(self)
	local deltaTime = (self.scoreEngine.currentTime - self.startNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate

	if math.abs(deltaTime) <= self.passEdge then
		return "exactly"
	elseif deltaTime > self.passEdge then
		return "late"
	elseif deltaTime >= -self.missEdge then
		return "early"
	end
	
	return "none"
end

ShortScoreNote.isHere = function(self)
	return self.startNoteData.timePoint.absoluteTime <= self.scoreEngine.currentTime
end

ShortScoreNote.isReachable = function(self)
	local timeState = self:getTimeState()
	return timeState ~= "none" and timeState ~= "late"
end

ShortScoreNote.update = function(self)
	local states = self.logicalNote.states
    local oldState, newState = states[self.currentStateIndex - 1], states[self.currentStateIndex]

	if newState == "clear" then
	elseif newState == "passed" then
		return self:unload()
	elseif newState == "missed" then
		return self:unload()
	end

	self:nextStateIndex()
end

return ShortScoreNote
