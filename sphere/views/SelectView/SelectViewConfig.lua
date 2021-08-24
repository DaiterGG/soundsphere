local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local NoteChartSetList = {
	class = "NoteChartSetListView",
	transform = transform,
	x = 1187,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	elements = {
		{
			type = "text",
			field = "noteChartDataEntry.title",
			onNew = false,
			x = 44,
			baseline = 45,
			limit = 410,
			align = "left",
			fontSize = 24,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "noteChartDataEntry.artist",
			onNew = false,
			x = 45,
			baseline = 19,
			limit = 409,
			align = "left",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "circle",
			field = "tagged",
			onNew = false,
			x = 22,
			y = 36,
			r = 7
		},
	},
}

local NoteChartList = {
	class = "NoteChartListView",
	transform = transform,
	x = 733,
	y = 216,
	w = 454,
	h = 648,
	rows = 9,
	elements = {
		{
			type = "text",
			field = "noteChartDataEntry.name",
			onNew = false,
			x = 116,
			baseline = 45,
			limit = 338,
			align = "left",
			fontSize = 24,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "noteChartDataEntry.creator",
			onNew = true,
			x = 117,
			baseline = 19,
			limit = 337,
			align = "left",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "noteChartDataEntry.inputMode",
			onNew = true,
			x = 17,
			baseline = 19,
			limit = 47,
			align = "left",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "difficulty",
			onNew = false,
			x = 0,
			baseline = 45,
			limit = 72,
			align = "right",
			fontSize = 24,
			fontFamily = "Noto Sans Mono"
		},
		{
			type = "circle",
			field = "tagged",
			onNew = false,
			x = 94,
			y = 36,
			r = 7
		},
	},
}

local StageInfo = {
	class = "StageInfoView",
	transform = transform,
	x = 279,
	y = 279,
	w = 454,
	h = 522,
	smallCell = {
		x = {0, 113, 227, 340},
		y = {0, 50, 101, 152, 319, 370, 421, 472},
		name = {
			x = 22,
			baseline = 15,
			limit = 69,
			align = "right",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		value = {
			text = {
				x = 22,
				baseline = 44,
				limit = 70,
				align = "right",
				fontSize = 24,
				fontFamily = "Noto Sans"
			},
			bar = {
				x = 22,
				y = 26,
				w = 70,
				h = 19
			}
		}
	},
	largeCell = {
		x = {0, 227},
		y = {225},
		name = {
			x = 22,
			baseline = 14,
			limit = 160,
			align = "right",
			fontSize = 18,
			fontFamily = "Noto Sans"
		},
		value = {
			text = {
				x = 22,
				baseline = 49,
				limit = 161,
				align = "right",
				fontSize = 36,
				fontFamily = "Noto Sans"
			}
		}
	}
}

StageInfo.cells = {
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 3,
		name = "duration",
		key = "selectModel.noteChartItem.noteChartDataEntry.length"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 4,
		name = "notes",
		key = "selectModel.noteChartItem.noteChartDataEntry.noteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {3, 4}, y = 4,
		name = "long notes",
		key = "longNoteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 4,
		name = "level",
		key = "selectModel.noteChartItem.noteChartDataEntry.level"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 1, y = 1,
		name = "accuracy",
		format = "%2.2f",
		key = "selectModel.scoreItem.scoreEntry.accuracy"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		format = "%2.2f",
		key = "selectModel.scoreItem.scoreEntry.score"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 5,
		name = "played",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 6,
		name = "pp",
		key = "pp"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 6,
		name = "rank",
		key = "rank"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {1, 2}, y = 8,
		name = "predicted accuracy",
		key = "accuracy"
	},
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = 0.5
}

local Preview = {
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080
}

local NoteChartSetScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = NoteChartSetList,
	x = 1641,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
}

local Logo = {
	class = "LogoView",
	transform = transform,
	x = 279,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 89,
		baseline = 56,
		limit = 365,
		align = "left",
		fontSize = 32,
		fontFamily = "Noto Sans"
	}
}

local UserInfo = {
	class = "UserInfoView",
	transform = transform,
	x = 1187,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 386,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 0,
		baseline = 54,
		limit = 365,
		align = "right",
		fontSize = 26,
		fontFamily = "Noto Sans"
	}
}

local SearchField = {
	class = "SearchFieldView",
	transform = transform,
	x = 733,
	y = 89,
	w = 281,
	h = 55,
	frame = {
		x = 6,
		y = 6,
		w = 269,
		h = 43,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		baseline = 35,
		limit = 227,
		align = "left",
		fontSize = 20,
		fontFamily = "Noto Sans"
	},
	point = {
		r = 7
	}
}

local SortStepper = {
	class = "SortStepperView",
	transform = transform,
	x = 1014,
	y = 89,
	w = 173,
	h = 55,
	frame = {
		x = 6,
		y = 6,
		w = 161,
		h = 43,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		baseline = 35,
		limit = 119,
		align = "center",
		fontSize = 20,
		fontFamily = "Noto Sans"
	}
}

local ModifierIconGrid = {
	class = "ModifierIconGridView",
	transform = transform,
	x = 301,
	y = 855,
	w = 410,
	h = 136,
	columns = 6,
	rows = 2
}

local StageInfoModifierIconGrid = {
	class = "ModifierIconGridView",
	transform = transform,
	x = 301,
	y = 598,
	w = 183,
	h = 138,
	columns = 4,
	rows = 3
}

local BottomScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 392,
	y = 991,
	w = 681,
	h = 89,
	rows = 1,
	columns = 3,
	text = {
		x = 0,
		baseline = 54,
		limit = 228,
		align = "center",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	screens = {
		{
			{
				name = "Modifier",
				displayName = "modifiers"
			},
			{
				name = "NoteSkin",
				displayName = "noteskins"
			},
			{
				name = "Input",
				displayName = "input"
			}
		}
	}
}

local LeftScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 89,
	y = 279,
	w = 190,
	h = 261,
	rows = 4,
	columns = 1,
	text = {
		x = 0,
		baseline = 41,
		limit = 190,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	screens = {
		{
			{
				name = "Collection",
				displayName = "collection"
			}
		},
		{
			{
				name = "Settings",
				displayName = "settings"
			}
		},
	}
}

local Rectangle = {
	class = "RectangleView",
	transform = transform,
	rectangles = {
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 733,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		},
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 1183,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		},
		{
			color = {1, 1, 1, 0.25},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 270,
			y = 279,
			w = 8,
			h = 522,
			rx = 4,
			ry = 4
		}
	}
}

local Line = {
	class = "LineView",
	transform = transform,
	lines = {}
}

local SelectViewConfig = {
	Background,
	Preview,
	NoteChartSetList,
	NoteChartList,
	StageInfo,
	NoteChartSetScrollBar,

	Logo,
	UserInfo,
	SearchField,
	SortStepper,

	ModifierIconGrid,
	StageInfoModifierIconGrid,
	BottomScreenMenu,
	LeftScreenMenu,

	Rectangle,
	Line
}

return SelectViewConfig
