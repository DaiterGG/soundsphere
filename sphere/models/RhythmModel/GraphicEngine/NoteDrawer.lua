local Class = require("Class")
local TimePoint = require("ncdk.TimePoint")
local GraphicalNoteFactory	= require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local NoteDrawer = Class:new()

NoteDrawer.load = function(self)
	local graphicEngine = self.graphicEngine
	local timeEngine = graphicEngine.rhythmModel.timeEngine
	local logicEngine = graphicEngine.rhythmModel.logicEngine
	self.layerData = graphicEngine.noteChart:getLayerData(self.layerIndex)

	self.currentTimePoint = TimePoint:new()
	self.currentTimePoint.side = -1
	self.currentTimePoint.visualTime = 0
	self.velocityIndex = 1
	self.tempoIndex = 1

	local sharedLogicalNotes = logicEngine.sharedLogicalNotes or {}

	self.notes = {}
	for noteDataIndex = 1, self.layerData:getNoteDataCount() do
		local noteData = self.layerData:getNoteData(noteDataIndex)

		if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
			local graphicalNote = GraphicalNoteFactory:getNote(noteData)

			if graphicalNote then
				graphicalNote.currentTimePoint = self.currentTimePoint
				graphicalNote.graphicEngine = graphicEngine
				graphicalNote.timeEngine = timeEngine
				graphicalNote.logicalNote = sharedLogicalNotes[noteData]
				if graphicEngine.noteSkin:check(graphicalNote) then
					table.insert(self.notes, graphicalNote)
				end
			end
		end
	end

	table.sort(self.notes, function(a, b)
		return a.startNoteData.timePoint.visualTime < b.startNoteData.timePoint.visualTime
	end)

	for index, graphicalNote in ipairs(self.notes) do
		graphicalNote.nextNote = self.notes[index + 1]
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 0
end

NoteDrawer.updateCurrentTime = function(self)
	local timeEngine = self.graphicEngine.rhythmModel.timeEngine
	local timePoint = self.currentTimePoint
	timePoint.absoluteTime = timeEngine.currentVisualTime - timeEngine.inputOffset

	local layerData = self.layerData

	local nextVelocityData = layerData:getVelocityData(self.velocityIndex + 1)
	while nextVelocityData and nextVelocityData.timePoint <= timePoint do
		self.velocityIndex = self.velocityIndex + 1
		nextVelocityData = layerData:getVelocityData(self.velocityIndex + 1)
	end

	local velocityData = layerData:getVelocityData(self.velocityIndex)
	while self.velocityIndex > 1 and velocityData and velocityData.timePoint > timePoint do
		self.velocityIndex = self.velocityIndex - 1
		velocityData = layerData:getVelocityData(self.velocityIndex)
	end

	timePoint.velocityData = velocityData
	timePoint:computeVisualTime()
end

NoteDrawer.update = function(self)
	self:updateCurrentTime()

	local notes = self.notes
	local note

	for i = self.startNoteIndex, self.endNoteIndex do
		notes[i]:update()
	end

	for i = self.startNoteIndex, 2, -1 do
		note = notes[i - 1]
		note:update()
		if not note:willDrawBeforeStart() and i == self.startNoteIndex then
			self.startNoteIndex = self.startNoteIndex - 1
		else
			break
		end
	end

	for i = self.endNoteIndex, #notes - 1, 1 do
		note = notes[i + 1]
		note:update()
		if not note:willDrawAfterEnd() and i == self.endNoteIndex then
			self.endNoteIndex = self.endNoteIndex + 1
		else
			break
		end
	end

	for i = self.startNoteIndex, self.endNoteIndex do
		note = notes[i]
		if note:willDrawBeforeStart() then
			self.startNoteIndex = self.startNoteIndex + 1
		else
			break
		end
	end

	for i = self.endNoteIndex, self.startNoteIndex, -1 do
		note = notes[i]
		if note:willDrawAfterEnd() then
			self.endNoteIndex = self.endNoteIndex - 1
		else
			break
		end
	end
end

return NoteDrawer
