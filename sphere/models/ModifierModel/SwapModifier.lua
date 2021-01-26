local Modifier = require("sphere.models.ModifierModel.Modifier")

local SwapModifier = Modifier:new()

SwapModifier.type = "NoteChartModifier"

SwapModifier.name = "SwapModifier"

SwapModifier.apply = function(self)
	local config = self.config
	if not config.value then
		return
	end

	local map = self:getMap()

	local noteChart = self.noteChartModel.noteChart
	local layerDataSequence = noteChart.layerDataSequence

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			local submap = map[noteData.inputType]
			if submap and submap[noteData.inputIndex] then
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteData.inputIndex = submap[noteData.inputIndex]
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
			end
		end
	end
end

return SwapModifier
