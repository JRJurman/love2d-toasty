cardSize = {
	width = 300,
	height = 300,
}

-- UI elements
ui = {
	readout = {
		x = 1090,
		y = 10,
		width = 510,
		height = 800,
	},
	plate = {
		label = 'Current Plate',
		selectable = true,

		nav = {
			withHand = {
				down = 'card2',
				left = 'score',
			},
			withActions = {
				down = 'actionNewPlate',
				left = 'score',
			},
			withModal = {},
		},

		x = 550,
		y = 10,
		width = 530,
		height = 800,
	},
	score = {
		label = 'Round Score',
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
			withModal = {
				down = 'deck',
				right = 'modalAction1'
			},
		},

		x = 50,
		y = 10,
		width = 510,
		height = 800,
	},
	hand = {
		x = 380,
		y = 780,
		width = 880,
		height = 375,
	},
	served = {
		x = 110,
		y = 215,
		width = 400,
		height = 570,
	},
	plateScore = {
		x = 550,
		y = 10,
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
		y = 780,
		width = 340,
		height = 375,
	},
	drawPile = {
		x = 30,
		y = 810,
		width = cardSize.width,
		height = cardSize.height,
	},
	discardPile = {
		x = 1290,
		y = 810,
		width = cardSize.width,
		height = cardSize.height,
	},
	card1 = {
		label = 'First Card',
		card = true,
		handIndex = 1,
		selectable = true,
		hand = true,

		nav = {
			withHand = {
				left = 'deck',
				right = 'card2',
				up = 'plate',
			},
			withActions = {},
			withModal = {
				left = 'deck',
				right = 'card2',
				up = 'modalAction1',
			},
		},

		x = 405,
		y = 810,
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
				up = 'plate',
				left = 'card1',
				right = 'card3',
			},
			withActions = {},
			withModal = {
				up = 'modalAction1',
				left = 'card1',
				right = 'card3',
			},
		},

		x = 405 + (cardSize.width*0.9),
		y = 810,
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
				up = 'plate',
				left = 'card2',
			},
			withActions = {},
			withModal = {
				up = 'modalAction1',
				left = 'card2',
			},
		},

		x = 405 + (cardSize.width*1.8),
		y = 810,
		width = cardSize.width,
		height = cardSize.height,
	},
	plateCards = {
		x = 675,
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
			withHand = {},
			withActions = {
				up = 'plate',
				left = 'deck',
				right = 'actionNewPlate',
			},
			withModal = {},
		},

		x = 500,
		y = 900,
		width = 250,
		height = 250,
	},
	actionNewPlate = {
		label = 'Plate Action',
		action = true,
		selectable = true,
		hand = false,

		nav = {
			withHand = {},
			withActions = {
				up = 'plate',
				left = 'actionDraw',
			},
			withModal = {},
		},

		x = 770,
		y = 900,
		width = 250,
		height = 250,
	},
	offScreenModal = {
		x = 20,
		y = -1200,
		width = 1030,
		height = 760,
	},
	onScreenModal = {
		x = 20,
		y = 20,
		width = 1030,
		height = 760,
	},
	modal = {
		x = 20,
		y = -1200,
		width = 1030,
		height = 760,
	},
	-- NOTE: modal ui is relative, because it moves with it
	modalCard1 = {
		label = 'First Previewed Card',
		modal = true,
		card = true,
		drawIndex = 1,
		selectable = true,

		nav = {
			withHand = {},
			withActions = {},
			withModal = {
				right = 'modalCard2',
				down = 'modalAction1',
			},
		},

		x = 70,
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
			withHand = {},
			withActions = {},
			withModal = {
				left = 'modalCard1',
				right = 'modalCard3',
				down = 'modalAction1',
			},
		},

		x = 70 + cardSize.width + 10,
		y = 220,
		width = cardSize.width,
		height = cardSize.height,
	},
	modalCard3 = {
		label = 'Third Previewed Card',
		modal = true,
		card = true,
		drawIndex = 3,
		selectable = true,

		nav = {
			withHand = {},
			withActions = {},
			withModal = {
				left = 'modalCard2',
				down = 'modalAction2',
			},
		},

		x = 70 + (cardSize.width * 2) + 20,
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
			withHand = {},
			withActions = {},
			withModal = {
				up = 'modalCard1',
				down = 'card1',
				right = 'modalAction2',
			},
		},

		x = 70,
		y = 570,
		width = 300,
		height = 150,
	},
	modalAction2 = {
		label = 'Modal Action',
		modal = true,
		action = true,
		actionIndex = 2,
		selectable = true,

		nav = {
			withHand = {},
			withActions = {},
			withModal = {
				up = 'modalCard3',
				down = 'card1',
				left = 'modalAction1',
			},
		},

		x = 500,
		y = 570,
		width = 300,
		height = 150,
	},
}
