local Class = require("Class")
local NoteChartExporter = require("sph.NoteChartExporter")
local OsuNoteChartExporter = require("osu.NoteChartExporter")
local FileFinder = require("sphere.filesystem.FileFinder")

local EditorController = Class:new()

EditorController.load = function(self)
	local noteChartModel = self.noteChartModel
	local editorModel = self.editorModel

	noteChartModel:load()
	noteChartModel:loadNoteChart()
	local noteChart = noteChartModel.noteChart

	local noteSkin = self.noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin:loadData()
	noteSkin.editor = true

	editorModel.noteSkin = noteSkin
	editorModel.noteChart = noteChart
	editorModel.audioPath = noteChartModel.noteChartEntry.path:match("^(.+)/.-$") .. "/" .. noteChart.metaData.audioPath
	editorModel:load()

	self.previewModel:stop()

	FileFinder:reset()
	FileFinder:addPath(noteChartModel.noteChartEntry.path:match("^(.+)/.-$"))
	FileFinder:addPath(noteSkin.directoryPath)
	FileFinder:addPath("userdata/hitsounds")
	FileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(noteChartModel.noteChartEntry.path, noteChartModel.noteChart, function()
		editorModel:loadResources()
	end)

	self.windowModel:setVsyncOnSelect(false)
end

EditorController.unload = function(self)
	self.editorModel:unload()

	local graphics = self.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.windowModel.baseVsync
	end
end

EditorController.save = function(self)
	local noteChartModel = self.noteChartModel

	self.editorModel:save()

	local exp = NoteChartExporter:new()
	exp.noteChart = noteChartModel.noteChart

	local path = noteChartModel.noteChartEntry.path:gsub(".sph$", "") .. ".sph"

	love.filesystem.write(path, exp:export())

	self.cacheModel:startUpdate(noteChartModel.noteChartEntry.path:match("^(.+)/.-$"))
end

EditorController.saveToOsu = function(self)
	local noteChartModel = self.noteChartModel

	self.editorModel:save()

	local exp = OsuNoteChartExporter:new()
	exp.noteChart = noteChartModel.noteChart
	exp.noteChartEntry = self.noteChartModel.noteChartEntry
	exp.noteChartDataEntry = self.noteChartModel.noteChartDataEntry

	local path = noteChartModel.noteChartEntry.path
	path = path:gsub(".osu$", ""):gsub(".sph$", "") .. ".sph.osu"

	love.filesystem.write(path, exp:export())
end

EditorController.receive = function(self, event)
	self.editorModel:receive(event)
	if event.name == "filedropped" then
		return self:filedropped(event[1])
	end
end

local exts = {
	mp3 = true,
	ogg = true,
}
EditorController.filedropped = function(self, file)
	local path = file:getFilename():gsub("\\", "/")

	local _name, ext = path:match("^(.+)%.(.-)$")
	if not exts[ext] then
		return
	end

	local audioName = _name:match("^.+/(.-)$")
	local chartSetPath = "userdata/charts/editor/" .. os.time() .. " " .. audioName

	love.filesystem.write(chartSetPath .. "/" .. audioName .. "." .. ext, file:read())
end

return EditorController
