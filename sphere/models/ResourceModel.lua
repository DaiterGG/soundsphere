local Class = require("Class")
local audio			= require("audio")
local Video			= require("sphere.database.Video")
local thread	= require("thread")
local FileFinder	= require("sphere.filesystem.FileFinder")
local table_util = require("table_util")

local video
local ok, ret = pcall(require, "video")
if ok then
	video = ret
else
	print(ret)
end

local _newSoundDataAsync = thread.async(function(path, sample_gain)
	local fileData = love.filesystem.newFileData(path)
	if not fileData then
		return
	end
	local audio = require("audio")
	local soundData = audio.newSoundData(fileData:getFFIPointer(), fileData:getSize(), sample_gain)
	fileData:release()
	return soundData
end)

local function newSoundDataAsync(path, sample_gain)
	local soundData = _newSoundDataAsync(path, sample_gain)
	if not soundData then return end
	return setmetatable(soundData, {__index = audio.SoundData})
end

local newImageDataAsync = thread.async(function(s)
	require("love.image")
	local status, err = pcall(love.image.newImageData, s)
	if not status then return end
	return err
end)

local function newImageAsync(s)
	local imageData = newImageDataAsync(s)
	if not imageData then return end
	return love.graphics.newImage(imageData)
end

local newFileDataAsync = thread.async(function(path)
	return love.filesystem.newFileData(path)
end)

local function newVideoAsync(path)
	local fileData = newFileDataAsync(path)
	if not fileData then return end

	local _v = video.open(fileData:getPointer(), fileData:getSize())
	if not _v then
		return
	end

	local v = setmetatable({}, {__index = Video})
	v.video = _v
	v.fileData = fileData
	v.imageData = love.image.newImageData(_v:getDimensions())
	v.image = love.graphics.newImage(v.imageData)

	return v
end

local loadOjm = thread.async(function(path)
	local audio = require("audio")
	local OJM = require("o2jam.OJM")

	local fileData, err = love.filesystem.newFileData(path)
	if not fileData then
		return false, err
	end

	local ojm = OJM:new(fileData:getFFIPointer(), fileData:getSize())
	local soundDatas = {}

	for sampleIndex, sampleData in pairs(ojm.samples) do
		local fd = love.filesystem.newFileData(sampleData, sampleIndex)
		soundDatas[sampleIndex] = audio.newSoundData(fd:getFFIPointer(), fd:getSize())
	end

	return soundDatas
end)

local loadOjmAsync = function(path)
	local soundDatas = loadOjm(path)
	if not soundDatas then
		return
	end
	for _, soundData in pairs(soundDatas) do
		setmetatable(soundData, {__index = audio.SoundData})
	end
	return soundDatas
end

local ResourceModel = Class:new()

ResourceModel.construct = function(self)
	self.all_resources = {
		loaded = {},
		loading = {},
		not_loaded = {},
	}
	self.resources = self.all_resources.loaded
	self.sample_gain = 0
	self.aliases = {}
end

local NoteChartTypes = {
	bms = {"bms", "osu", "quaver", "ksm", "sm", "midi"},
	o2jam = {"o2jam"},
}
local NoteChartTypeMap = {}
for t, list in pairs(NoteChartTypes) do
	for i = 1, #list do
		NoteChartTypeMap[list[i]] = t
	end
end

ResourceModel.load = function(self, chartPath, noteChart, callback)
	local noteChartType = NoteChartTypeMap[noteChart.type]

	local settings = self.game.configModel.configs.settings
	local sample_gain = settings.audio.sampleGain
	local bga_image = settings.gameplay.bga.image
	local bga_video = settings.gameplay.bga.video
	if self.sample_gain ~= sample_gain then
		self:unloadAudio()
		self.sample_gain = sample_gain
	end

	self.callback = callback
	self.aliases = {}

	local loaded = {}
	for path, resource in pairs(self.all_resources.loaded) do
		table.insert(loaded, path)
		local mt = getmetatable(resource)
		if mt and mt.__index == Video then
			resource:rewind()
		end
	end

	if noteChartType == "bms" then
		local newResources = {}
		for fileType, name, sequence in noteChart:getResourceIterator() do
			for _, path in ipairs(sequence) do
				local filePath
				if fileType == "sound" then
					filePath = FileFinder:findFile(path, "audio")
				elseif fileType == "image" then
					if bga_image then
						filePath = FileFinder:findFile(path, "image")
					end
					if bga_video and not filePath then
						filePath = FileFinder:findFile(path, "video")
					end
				end
				if filePath then
					table.insert(newResources, filePath)
					self.aliases[name] = filePath
					break
				end
			end
		end
		self:loadResources(loaded, newResources)
	elseif noteChartType == "o2jam" then
		self:loadOJM(loaded, chartPath:match("^(.+)n$") .. "m")
	end

	self:process()
end

ResourceModel.loadResource = function(self, path)
	local fileType = FileFinder:getType(path)
	if fileType == "audio" then
		self.all_resources.loaded[path] = newSoundDataAsync(path, self.sample_gain)
	elseif fileType == "image" then
		self.all_resources.loaded[path] = newImageAsync(path)
	elseif fileType == "video" and video then
		self.all_resources.loaded[path] = newVideoAsync(path)
	elseif path:lower():find("%.ojm$") then
		local soundDatas = loadOjmAsync(path)
		if soundDatas then
			for name, soundData in pairs(soundDatas) do
				self.aliases[name] = path .. ":" .. name
				self.all_resources.loaded[path .. ":" .. name] = soundData
			end
		end
	end
end

ResourceModel.loadOJM = function(self, loaded, ojmPath)
	for _, path in ipairs(loaded) do
		if not path:find(ojmPath, 1, true) then
			self.all_resources.loaded[path]:release()
			self.all_resources.loaded[path] = nil
		end
	end

	self.all_resources.not_loaded = {[ojmPath] = true}
end

ResourceModel.loadResources = function(self, loaded, newResources)
	local new, old, all = table_util.array_update(newResources, loaded)

	for _, path in ipairs(old) do
		self.all_resources.loaded[path]:release()
		self.all_resources.loaded[path] = nil
	end

	self.all_resources.not_loaded = {}
	for _, path in ipairs(new) do
		self.all_resources.not_loaded[path] = true
	end
end

local isProcessing = false
ResourceModel.process = thread.coro(function(self)
	if isProcessing then
		return
	end
	isProcessing = true

	local path = next(self.all_resources.not_loaded)
	while path do
		self.all_resources.not_loaded[path] = nil
		self.all_resources.loading[path] = true

		self:loadResource(path)

		self.all_resources.loading[path] = nil

		path = next(self.all_resources.not_loaded)
	end
	self.callback()

	isProcessing = false
end)

ResourceModel.unloadAudio = function(self)
	local path = next(self.all_resources.loaded)
	while path do
		local fileType = FileFinder:getType(path)
		if not fileType or fileType == "audio" then
			self.all_resources.loaded[path]:release()
			self.all_resources.loaded[path] = nil
		end
		path = next(self.all_resources.loaded)
	end
end

return ResourceModel