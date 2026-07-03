cardSize = {
	width = 300,
	height = 300,
}

-- UI elements
ui = {
	readout = {
		x = 1070,
		y = 10,
		width = 530,
		height = 700,
	},
	plate = {
		label = 'Current Plate',
		selectable = true,

		nav = {
			withHand = {
				down = 'card1',
				left = 'score',
			},
			withActions = {
				down = 'actionDraw',
				left = 'score',
			},
		},

		x = 530,
		y = 10,
		width = 530,
		height = 800,
	},
	score = {
		label = 'Score',
		selectable = true,

		nav = {
			withHand = {
				down = 'deck',
				right = 'plate'
			},
			withActions = {
				down = 'deck',
				right = 'plate'
			},
		},

		x = 10,
		y = 45,
		width = 510,
		height = 800,
	},
	hand = {
		x = 365,
		y = 820,
		width = 880,
		height = 375,
	},
	served = {
		x = 20,
		y = 280,
		width = 400,
		height = 570,
	},
	plateScore = {
		x = 510,
		y = 15,
		width = 520,
		height = 280,
	},
	deck = {
		label = 'Deck',
		selectable = true,

		nav = {
			withHand = {
				right = 'card1',
				up = 'score',
			},
			withActions = {
				right = 'actionDraw',
				up = 'score',
			},
			withModal = {
				right = 'card1',
				up = 'modalAction1',
			},
		},

		x = 10,
		y = 820,
		width = 340,
		height = 375,
	},
	drawPile = {
		x = 30,
		y = 830,
		width = cardSize.width,
		height = cardSize.height,
	},
	discardPile = {
		x = 1280,
		y = 830,
		width = cardSize.width,
		height = cardSize.height,
	},
	card1 = {
		label = 'First Card in Hand',
		card = true,
		handIndex = 1,
		selectable = true,
		hand = true,

		nav = {
			withHand = {
				selectLabel = 'plate card',
				left = 'deck',
				right = 'card2',
				up = 'plate',
				down = 'settingsControl'
			},
			withModal = {
				left = 'deck',
				right = 'card2',
				up = 'modalAction1',
				down = 'settingsControl'
			},
		},

		x = 405,
		y = 850,
		width = cardSize.width,
		height = cardSize.height,
	},
	card2 = {
		label = 'Second Card',
		card = true,
		handIndex = 2,
		selectable = true,
		hand = true,

		nav = {
			withHand = {
				selectLabel = 'plate card',
				up = 'plate',
				left = 'card1',
				right = 'card3',
				down = 'settingsControl'
			},
			withModal = {
				up = 'modalAction1',
				left = 'card1',
				right = 'card3',
				down = 'settingsControl'
			},
		},

		x = 405 + (cardSize.width*0.9),
		y = 850,
		width = cardSize.width,
		height = cardSize.height,
	},
	card3 = {
		label = 'Third Card',
		card = true,
		handIndex = 3,
		selectable = true,
		hand = true,

		nav = {
			withHand = {
				selectLabel = 'plate card',
				up = 'plate',
				left = 'card2',
				down = 'settingsControl'
			},
			withModal = {
				up = 'modalAction1',
				left = 'card2',
				down = 'settingsControl'
			},
		},

		x = 405 + (cardSize.width*1.8),
		y = 850,
		width = cardSize.width,
		height = cardSize.height,
	},
	plateCards = {
		x = 655,
		y = 400,
		width = cardSize.width,
		height = cardSize.height,
	},
	actionDraw = {
		label = 'Draw Action',
		action = true,
		selectable = true,
		hand = false,

		nav = {
			withActions = {
				up = 'plate',
				left = 'deck',
				right = 'actionNewPlate',
				down = 'settingsControl'
			},
		},

		x = 440,
		y = 900,
		width = 365,
		height = 225,
	},
	actionNewPlate = {
		label = 'Plate Action',
		action = true,
		selectable = true,
		hand = false,

		nav = {
			withActions = {
				up = 'plate',
				left = 'actionDraw',
				down = 'settingsControl'
			},
		},

		x = 825,
		y = 900,
		width = 365,
		height = 225,
	},
	offScreenModal = {
		x = 5,
		y = -1200,
		width = 1055,
		height = 805,
	},
	onScreenModal = {
		x = 5,
		y = 5,
		width = 1055,
		height = 805,
	},
	modal = {
		x = 5,
		y = -1200,
		width = 1055,
		height = 805,
	},
	-- NOTE: modal ui is relative, because it moves with it
	modalCard1 = {
		label = 'First Previewed Card',
		modal = true,
		card = true,
		drawIndex = 1,
		selectable = true,

		nav = {
			withModal = {
				right = 'modalCard2',
				down = 'modalAction1',
			},
		},

		x = 210,
		y = 220,
		width = cardSize.width,
		height = cardSize.height,
	},
	modalCard2 = {
		label = 'Second Previewed Card',
		modal = true,
		card = true,
		drawIndex = 2,
		selectable = true,

		nav = {
			withModal = {
				left = 'modalCard1',
				down = 'modalAction1',
			},
		},

		x = 210 + cardSize.width + 20,
		y = 220,
		width = cardSize.width,
		height = cardSize.height,
	},
	modalAction1 = {
		label = 'Modal Action',
		modal = true,
		action = true,
		actionIndex = 1,
		selectable = true,

		nav = {
			withModal = {
				up = 'modalCard1',
				down = 'card1',
				right = 'modalAction2',
			},
		},

		x = 90,
		y = 570,
		width = 365,
		height = 150,
	},
	modalAction2 = {
		label = 'Modal Action',
		modal = true,
		action = true,
		actionIndex = 2,
		selectable = true,

		nav = {
			withModal = {
				up = 'modalCard1',
				down = 'card1',
				left = 'modalAction1',
			},
		},

		x = 510,
		y = 570,
		width = 365,
		height = 150,
	},
	settingsModal = {
		x = 5,
		y = -1200,
		width = 1055,
		height = 805,
	},
	settingsMasterSlider = {
		label = 'Master Audio Slider',
		modal = true,
		settingsModal = true,
		selectable = true,
		slider = true,

		nav = {
			withSettingsModal = {
				down = 'settingsMusicSlider',
			},
		},

		x = 90,
		y = 90,
		width = 700,
		height = 100,
	},
	settingsMusicSlider = {
		label = 'Music Audio Slider',
		modal = true,
		settingsModal = true,
		selectable = true,
		slider = true,

		nav = {
			withSettingsModal = {
				up = 'settingsMasterSlider',
				down = 'settingsSFXSlider',
			},
		},

		x = 90,
		y = 190,
		width = 700,
		height = 100,
	},
	settingsSFXSlider = {
		label = 'Sound Audio Slider',
		modal = true,
		settingsModal = true,
		selectable = true,
		slider = true,

		nav = {
			withSettingsModal = {
				up = 'settingsMusicSlider',
				down = 'settingsAnimationSlider',
			},
		},

		x = 90,
		y = 290,
		width = 700,
		height = 100,
	},
	settingsAnimationSlider = {
		label = 'Animation Speed Slider',
		modal = true,
		settingsModal = true,
		selectable = true,
		slider = true,

		nav = {
			withSettingsModal = {
				up = 'settingsSFXSlider',
				down = 'settingsCursorSlider',
			},
		},

		x = 90,
		y = 390,
		width = 700,
		height = 100,
	},
	settingsCursorSlider = {
		label = 'Cursor Hue Slider',
		modal = true,
		settingsModal = true,
		selectable = true,
		slider = true,

		nav = {
			withSettingsModal = {
				up = 'settingsAnimationSlider',
				down = 'modalSettingsSaveAction',
			},
		},

		x = 90,
		y = 490,
		width = 700,
		height = 100,
	},
	modalSettingsSaveAction = {
		label = 'Save Action',
		modal = true,
		settingsModal = true,
		action = true,
		actionIndex = 1,
		selectable = true,

		nav = {
			withSettingsModal = {
				up = 'settingsCursorSlider',
				right = 'modalSettingsResetAction',
			},
		},

		x = 90,
		y = 630,
		width = 365,
		height = 90,
	},
	modalSettingsResetAction = {
		label = 'Reset Action',
		modal = true,
		settingsModal = true,
		action = true,
		actionIndex = 2,
		selectable = true,

		nav = {
			withSettingsModal = {
				up = 'settingsCursorSlider',
				left = 'modalSettingsSaveAction',
			},
		},

		x = 510,
		y = 630,
		width = 365,
		height = 90,
	},
	chef = {
		x = 1360,
		y = 687,
	},
	chefReadoutArrow = {
		x1 = 1405,
		y1 = 707,
		x2 = 1445,
		y2 = 707,
		x3 = 1450,
		y3 = 752
	},
	scoreBoard = {
		x = 0,
		y = 0,
		width = 1060,
		height = 320,
	},
	settingsControl = {
		label = 'Settings',
		x = 1280,
		y = 1140,
		width = 300,
		height = 40,
		selectable = true,
		settingsControl = true,

		nav = {
			withHand = {
				up = 'card1',
			},
			withActions = {
				up = 'card1'
			},
			withModal = {
				up = 'card1'
			},
		},
	}
}

toMobileLayout = function()
	-- hand
	ui.hand.x = 30
	ui.hand.y = 1160

	-- hand cards
	ui.card1.x = 70
	ui.card1.y = 1190
	ui.card2.x = 70 + (cardSize.width*0.9)
	ui.card2.y = 1190
	ui.card3.x = 70 + (cardSize.width*1.8)
	ui.card3.y = 1190

	-- hand actions
	ui.actionDraw.x = 105
	ui.actionDraw.y = 1240
	ui.actionNewPlate.x = 490
	ui.actionNewPlate.y = 1240

	-- draw & discard
	ui.deck.x = 10
	ui.deck.y = 1580
	ui.drawPile.x = 30
	ui.drawPile.y = 1610
	ui.discardPile.x = 365
	ui.discardPile.y = 1610

	-- chef and readout
	ui.chef.x = 825
	ui.chef.y = 1000
	ui.chefReadoutArrow.x1 = 923
	ui.chefReadoutArrow.y1 = 1080
	ui.chefReadoutArrow.x2 = 893
	ui.chefReadoutArrow.y2 = 1100
	ui.chefReadoutArrow.x3 = 893
	ui.chefReadoutArrow.y3 = 1060
	ui.readout.x = 10
	ui.readout.y = 837
	ui.readout.width = 890
	ui.readout.height = 300

	-- settings control
	ui.settingsControl.x = 695
	ui.settingsControl.y = 1640
	ui.settingsControl.width = 300
	ui.settingsControl.height = 200
end

toDesktopLayout = function()
	-- hand
	ui.hand.x = 365
	ui.hand.y = 820

	-- hand cards
	ui.card1.x = 405
	ui.card1.y = 850
	ui.card2.x = 405 + (cardSize.width*0.9)
	ui.card2.y = 850
	ui.card3.x = 405 + (cardSize.width*1.8)
	ui.card3.y = 850

	-- hand actions
	ui.actionDraw.x = 440
	ui.actionDraw.y = 900
	ui.actionNewPlate.x = 825
	ui.actionNewPlate.y = 900

	-- draw & discard
	ui.deck.x = 10
	ui.deck.y = 820
	ui.drawPile.x = 30
	ui.drawPile.y = 830
	ui.discardPile.x = 1280
	ui.discardPile.y = 830

	-- chef and readout
	ui.chef.x = 1360
	ui.chef.y = 687
	ui.chefReadoutArrow.x1 = 1405
	ui.chefReadoutArrow.y1 = 707
	ui.chefReadoutArrow.x2 = 1445
	ui.chefReadoutArrow.y2 = 707
	ui.chefReadoutArrow.x3 = 1450
	ui.chefReadoutArrow.y3 = 752
	ui.readout.x = 1070
	ui.readout.y = 10
	ui.readout.width = 530
	ui.readout.height = 700

	-- settings control
	ui.settingsControl.x = 1280
	ui.settingsControl.y = 1140
	ui.settingsControl.width = 300
	ui.settingsControl.height = 40
end
