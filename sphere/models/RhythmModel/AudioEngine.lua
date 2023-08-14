local _audio = require("audio")
local AudioContainer = require("audio.Container")
local class = require("class")

local AudioEngine = class()

AudioEngine.timeRate = 1

function AudioEngine:new()
	self.backgroundContainer = AudioContainer()
	self.foregroundContainer = AudioContainer()
end

function AudioEngine:updateVolume()
	self.backgroundContainer:setVolume(self.volume.master * self.volume.music)
	self.foregroundContainer:setVolume(self.volume.master * self.volume.effects)
end

function AudioEngine:load()
	self.loaded = true
end

function AudioEngine:update()
	self:updateTimeRate()
	self.backgroundContainer:update()
	self.foregroundContainer:update()
end

function AudioEngine:receive(event)
	if event.name == "LogicalNoteSound" then
		self:playNote(event[1], event[2])
	end
end

function AudioEngine:unload()
	self.backgroundContainer:release()
	self.foregroundContainer:release()
	self.loaded = false
end

function AudioEngine:playNote(noteData, isBackground)
	if not self.loaded or not noteData or not noteData.sounds then
		return
	end

	self:playAudio(noteData.sounds, isBackground, noteData.stream, noteData.timePoint.absoluteTime)
end

function AudioEngine:playAudio(sounds, isBackground, stream, offset)
	local currentTime = self.rhythmModel.timeEngine.currentTime
	for i = 1, #sounds do
		local mode = stream and self.mode.primary or self.mode.secondary

		local soundData = self.rhythmModel.resourceModel:getResource(sounds[i][1])

		if soundData then
			local audio = _audio.newSource(soundData, mode)
			audio.offset = offset or currentTime
			audio:setBaseVolume(sounds[i][2])
			local shouldPlay = true
			if self.forcePosition then
				local p = currentTime - audio.offset
				if p >= audio:getDuration() then
					shouldPlay = false
				else
					audio:setPosition(p)
				end
			end
			if shouldPlay then
				if isBackground then
					self.backgroundContainer:add(audio)
				else
					self.foregroundContainer:add(audio)
				end
			else
				audio:release()
			end
		end
	end
end

function AudioEngine:play()
	self.backgroundContainer:play()
	self.foregroundContainer:play()
end

function AudioEngine:pause()
	self.backgroundContainer:pause()
	self.foregroundContainer:pause()
end

function AudioEngine:updateTimeRate()
	local timeRate = self.rhythmModel.timeEngine.timeRate
	if self.timeRate == timeRate then
		return
	end
	self.backgroundContainer:setRate(timeRate)
	self.foregroundContainer:setRate(timeRate)
	self.timeRate = timeRate
end

function AudioEngine:getPosition()
	return self.backgroundContainer:getPosition()
end

function AudioEngine:setPosition(position)
	self.backgroundContainer:setPosition(position)
	self.foregroundContainer:setPosition(position)
end

return AudioEngine
