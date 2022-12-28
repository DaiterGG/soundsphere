local Class = require("Class")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local Fraction = require("ncdk.Fraction")
local imgui = require("imgui")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

local function getTimePointText(timePoint)
	if timePoint._tempoData then
		return timePoint._tempoData.tempo .. " bpm"
	elseif timePoint._signatureData then
		return "signature " .. tostring(timePoint._signatureData.signature) .. " beats"
	elseif timePoint._stopData then
		return "stop " .. tostring(timePoint._stopData.duration) .. " beats"
	elseif timePoint._velocityData then
		return timePoint._velocityData.currentSpeed .. "x"
	elseif timePoint._expandData then
		return "expand into " .. tostring(timePoint._expandData.duration) .. " beats"
	elseif timePoint._intervalData then
		return timePoint._intervalData.intervals .. " intervals"
	end
end

SnapGridView.drawTimingObjects = function(self, field, currentTime, pixels)
	local rangeTracker = self.game.editorModel.layerData.timePointsRange
	local timePoint = rangeTracker.startObject
	if not timePoint or not currentTime then
		return
	end

	local endTimePoint = rangeTracker.endObject
	while timePoint and timePoint <= endTimePoint do
		local text = getTimePointText(timePoint)
		if text then
			local y = (timePoint[field] - currentTime) * pixels
			love.graphics.line(0, y, 10, y)
			gfx_util.printFrame(text, -500, y - 25, 490, 50, "right", "center")
		end

		timePoint = timePoint.next
	end
end

local colors = {
	white = {1, 1, 1},
	red = {1, 0, 0},
	blue = {0, 0, 1},
	green = {0, 1, 0},
	yellow = {1, 1, 0},
	violet = {1, 0, 1},
}

local snaps = {
	[1] = colors.white,
	[2] = colors.red,
	[3] = colors.violet,
	[4] = colors.blue,
	[5] = colors.yellow,
	[6] = colors.violet,
	[7] = colors.yellow,
	[8] = colors.green,
}

SnapGridView.drawComputedGrid = function(self, field, currentTime, pixels, w1, w2)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local snap = editorModel.snap

	if not currentTime then
		return
	end

	if ld.mode == "measure" then
		for time = ld.startTime:ceil(), ld.endTime:floor() do
			local signature = ld:getSignature(time)
			local _signature = signature:ceil()
			for i = 1, _signature do
				for j = 1, snap do
					local f = Fraction((i - 1) * snap + j - 1, signature * snap)
					if f:tonumber() < 1 then
						local timePoint = ld:getDynamicTimePoint(f + time, -1)
						if not timePoint then break end
						local y = (timePoint[field] - currentTime) * pixels

						local w = w1 or 30
						if i == 1 and j == 1 then
							w = w2 or w1 or 60
						end
						love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
						love.graphics.line(0, y, w, y)
					end
				end
			end
		end
	elseif ld.mode == "interval" then
		local timePoint = ld:getDynamicTimePointAbsolute(192, ld.startTime)
		local startIntervalData = timePoint.intervalData
		local startTime = timePoint.time:floor()
		timePoint = ld:getDynamicTimePointAbsolute(192, ld.endTime)
		local endIntervalData = timePoint.intervalData
		local endTime = timePoint.time:floor()

		while startIntervalData and startIntervalData < endIntervalData or startIntervalData == endIntervalData and startTime <= endTime do
			for j = 1, snap do
				local time = Fraction(j - 1, snap) + startTime
				timePoint = ld:getDynamicTimePoint(startIntervalData, time)
				if not timePoint or not timePoint[field] then break end
				local y = (timePoint[field] - currentTime) * pixels

				local w = w1 or 30
				if startTime == 0 and j == 1 then
					w = w2 or w1 or 60
				end
				love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
				love.graphics.line(0, y, w, y)
			end

			startTime = startTime + 1
			if startTime == startIntervalData.intervals and startIntervalData.next then
				startIntervalData = startIntervalData.next
				startTime = 0
			end
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

local primaryTempo = "60"
local defaultSignature = {"4", "1"}
SnapGridView.drawUI = function(self, w, h)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	just.push()

	imgui.setSize(w, h, 200, 55)
	editorModel.snap = imgui.slider1("snap select", editorModel.snap, "%d", 1, 16, 1, "snap")
	local speed = imgui.slider1("second pixels", h * editorModel.speed, "%d", 10, h, 10, "pixels per second") / h
	if speed ~= editorModel.speed then
		editorModel.speed = speed
		editorModel:updateRange()
	end

	if imgui.button("add object", "add") then
		self.game.gameView:setModal(require("sphere.views.EditorView.AddTimingObjectView"))
	end

	just.row(true)
	primaryTempo = imgui.input("primaryTempo input", primaryTempo, "primary tempo")
	if imgui.button("set primaryTempo button", "set") then
		ld:setPrimaryTempo(tonumber(primaryTempo))
	end
	if imgui.button("unset primaryTempo button", "unset") then
		ld:setPrimaryTempo(0)
	end
	just.row()

	just.row(true)
	imgui.label("set signature mode", "signature mode")
	if imgui.button("set short signature button", "short") then
		ld:setSignatureMode("short")
	end
	if imgui.button("set long signature button", "long") then
		ld:setSignatureMode("long")
	end
	just.row()

	imgui.setSize(w, h, 100, 55)
	just.row(true)
	defaultSignature[1] = imgui.input("defsig n input", defaultSignature[1])
	imgui.unindent()
	imgui.label("/ label", "/")
	defaultSignature[2] = imgui.input("defsig d input", defaultSignature[2], "default signature")
	if imgui.button("set defsig button", "set") then
		ld:setDefaultSignature(Fraction(tonumber(defaultSignature[1]), tonumber(defaultSignature[2])))
	end
	just.row(false)
	imgui.setSize(w, h, 200, 55)

	just.text("primary tempo: " .. ld.primaryTempo)
	just.text("signature mode: " .. ld.signatureMode)
	just.text("default signature: " .. ld.defaultSignature)

	local dtp = editorModel:getDynamicTimePoint()

	just.text("time point: " .. tostring(dtp))

	if ld.mode == "measure" then
		local measureOffset = dtp.measureTime:floor()
		local signature = ld:getSignature(measureOffset)
		local snap = editorModel.snap

		local beatTime = (dtp.measureTime - measureOffset) * signature
		local snapTime = (beatTime - beatTime:floor()) * snap

		just.text("beat: " .. tostring(beatTime))
		just.text("snap: " .. tostring(snapTime))
	end

	just.row(true)
	if imgui.button("prev tp", "prev") and dtp.prev then
		editorModel:scrollTimePoint(dtp.prev)
	end
	if imgui.button("next tp", "next") and dtp.next then
		editorModel:scrollTimePoint(dtp.next)
	end
	just.row()

	just.pop()
end

SnapGridView.drawNotes = function(self, pixels, width)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local rangeTracker = self.game.editorModel.layerData.timePointsRange
	local timePoint = rangeTracker.startObject
	if not timePoint then
		return
	end

	local currentTime = editorModel.timePoint.absoluteTime

	local endTimePoint = rangeTracker.endObject
	while timePoint and timePoint <= endTimePoint do
		local noteDatas = timePoint.noteDatas
		if noteDatas then
			for _, noteData in ipairs(noteDatas) do
				local y = (timePoint.absoluteTime - currentTime) * pixels
				local x = (noteData.inputIndex - 1) * width / 4
				local h = (pixels > 0 and 1 or -1) * width / 16
				just.push()
				love.graphics.translate(x, y)
				love.graphics.rectangle("fill", 0, 0, width / 4, h)
				if just.button("remove note" .. tostring(noteData), just.is_over(width / 4, h), 2) then
					ld:removeNoteData(noteData)
				end
				just.pop()
			end
		end

		timePoint = timePoint.next
	end
end

local function drag(id, w, h)
	local over = just.is_over(w, h)
	local _, active, hovered = just.button(id, over)

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	just.next(w, h)

	return just.active_id == id
end

local prevMouseY = 0
SnapGridView.draw = function(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	self:drawUI(w, h)

	love.graphics.translate(w / 3, 0)

	love.graphics.push()
	love.graphics.translate(0, h / 2)
	love.graphics.line(0, 0, 240, 0)

	local speed = -h * editorModel.speed

	local editorTimePoint = editorModel.timePoint
	love.graphics.translate(-40, 0)
	if ld.mode == "measure" then
		self:drawTimingObjects("beatTime", editorTimePoint.beatTime, speed)
	elseif ld.mode == "interval" then
		self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, speed)
	end
	love.graphics.translate(40, 0)
	self:drawComputedGrid("beatTime", editorTimePoint.beatTime, speed)

	love.graphics.translate(80, 0)
	self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime, speed)

	love.graphics.translate(80, 0)
	self:drawComputedGrid("visualTime", editorTimePoint.visualTime, speed)

	love.graphics.pop()

	love.graphics.push()
	love.graphics.translate(300, 0)
	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local my = h - _my

	local over = just.is_over(320, h)
	local t = editorTimePoint.absoluteTime - (my - h / 2) / speed
	if over then
		love.graphics.rectangle("fill", _mx, _my, 80, -20)
	end

	if just.button("add note", over, 1) then
		editorModel:addNote(t, "key", 1)
	end

	love.graphics.push()
	for i = 1, 4 do
		love.graphics.line(0, 0, 0, h)
		if just.button("add note" .. i, just.is_over(80, h), 1) then
			editorModel:addNote(t, "key", i)
		end
		love.graphics.translate(80, 0)
	end
	love.graphics.line(0, 0, 0, h)
	love.graphics.pop()

	love.graphics.translate(0, h / 2)
	love.graphics.line(0, 0, 320, 0)
	self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime, speed, 320, 320)
	self:drawNotes(speed, 320)
	love.graphics.pop()

	just.push()
	just.row(true)
	local pixels = drag("drag1", 240, h) and speed
	if pixels then
		editorModel:scrollSeconds((my - prevMouseY) / pixels)
	end
	just.row()
	just.pop()

	prevMouseY = my

	local scroll = just.wheel_over("scale scroll", just.is_over(240, h))
	scroll = scroll and -scroll
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		editorModel:scrollSnaps(scroll)
	end
end

return SnapGridView
