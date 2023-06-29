

return {

	-- controllers

	editorController = {
		"noteChartModel",
		"editorModel",
		"noteSkinModel",
		"previewModel",
		"configModel",
		"resourceModel",
		"windowModel",
	},
	fastplayController = {
		"rhythmModel",
		"replayModel",
		"modifierModel",
		"noteChartModel",
		"difficultyModel",
	},
	gameplayController = {
		"rhythmModel",
		"noteChartModel",
		"noteSkinModel",
		"configModel",
		"modifierModel",
		"difficultyModel",
		"replayModel",
		"timeController",
		"multiplayerModel",
		"previewModel",
		"discordModel",
		"scoreModel",
		"onlineModel",
		"selectModel",
		"resourceModel",
		"windowModel",
	},
	mountController = {
		"mountModel",
		"configModel",
		"cacheModel",
	},
	multiplayerController = {
		"multiplayerModel",
		"modifierModel",
		"configModel",
		"selectModel",
		"noteChartSetLibraryModel",
	},
	resultController = {
		"selectModel",
		"replayModel",
		"rhythmModel",
		"modifierModel",
		"onlineModel",
		"configModel",
		"fastplayController",
	},
	selectController = {
		"noteChartModel",
		"selectModel",
		"previewModel",
		"modifierModel",
		"noteSkinModel",
		"configModel",
		"backgroundModel",
		"multiplayerModel",
		"onlineModel",
		"mountModel",
		"cacheModel",
		"osudirectModel",
		"windowModel",
	},
	timeController = {
		"rhythmModel",
		"noteChartModel",
		"configModel",
		"multiplayerModel",
		"notificationModel",
		"speedModel",
		"cacheModel",
	},

	-- models

	audioModel = {"configModel"},
	backgroundModel = {"configModel"},
	configModel = {},
	cacheModel = {"configModel"},
	collectionModel = {
		"configModel",
		"cacheModel",
	},
	discordModel = {},
	difficultyModel = {},
	editorModel = {
		"configModel",
		"resourceModel",
	},
	notificationModel = {},
	windowModel = {"configModel"},
	mountModel = {"configModel"},
	screenshotModel = {"configModel"},
	themeModel = {"configModel"},
	scoreModel = {"configModel"},
	onlineModel = {"configModel"},
	modifierModel = {
		"configModel",
		"game",
	},
	noteSkinModel = {"configModel"},
	noteChartModel = {
		"configModel",
		"scoreModel",
		"cacheModel",
	},
	inputModel = {"configModel"},
	noteChartSetLibraryModel = {
		"searchModel",
		"sortModel",
	},
	noteChartLibraryModel = {},
	scoreLibraryModel = {
		"configModel",
		"onlineModel",
		"scoreModel",
	},
	sortModel = {},
	searchModel = {"configModel"},
	selectModel = {
		"configModel",
		"searchModel",
		"sortModel",
		"noteChartSetLibraryModel",
		"noteChartLibraryModel",
		"scoreLibraryModel",
		"collectionModel",
	},
	previewModel = {
		"configModel",
		"modifierModel",
	},
	updateModel = {"configModel"},
	rhythmModel = {
		"replayModel",
		"modifierModel",
		"inputModel",
		"resourceModel",
	},
	osudirectModel = {
		"configModel",
		"cacheModel",
	},
	multiplayerModel = {
		"rhythmModel",
		"configModel",
		"modifierModel",
		"selectModel",
		"onlineModel",
		"osudirectModel",
	},
	replayModel = {
		"rhythmModel",
		"noteChartModel",
		"modifierModel",
	},
	speedModel = {"configModel"},
	resourceModel = {"configModel"},

	-- views

	gameView = {"game"},
	selectView = {"game"},
	resultView = {"game"},
	gameplayView = {"game"},
	multiplayerView = {"game"},
	editorView = {"game"},
}
