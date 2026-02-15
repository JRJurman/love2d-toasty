cardSize = {
	width = 300,
	height = 300,
}

-- UI elements
ui = {
	readout = {
		x = 10,
		y = 10,
		width = 530,
		height = 760,
	},
	plate = {
		label = 'Current Plate',
		selectable = true,

		nav = {
			withHand = {
				up = 'card2',
				right = 'score',
				left = 'served',
			},
			withActions = {
				up = 'actionNewPlate',
				right = 'score',
				left = 'served',
			},
			withModal = {
				up = 'card2',
				right = 'score',
				left = 'served',
			},
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
				up = 'deck',
				left = 'plate'
			},
			withActions = {
				up = 'deck',
				left = 'plate'
			},
			withModal = {
				up = 'deck',
				left = 'plate'
			},
		},

		x = 1080,
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
		label = 'Completed Plates',

		nav = {
			withHand = {
				up = 'card1',
				right = 'plate',
			},
			withActions = {
				up = 'actionDraw',
				right = 'plate',
			},
			withModal = {
				up = 'card1',
				right = 'plate',
			},
		},

		x = 1135,
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
		label = 'Draw and Discard Piles',
		selectable = true,

		nav = {
			withHand = {
				left = 'card3',
				down = 'score',
			},
			withActions = {
				left = 'actionNewPlate',
				down = 'score',
			},
			withModal = {
				left = 'card3',
				down = 'score',
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
				right = 'card2',
				down = 'served',
			},
			withActions = {},
			withModal = {
				right = 'card2',
				down = 'served',
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
				down = 'plate',
				left = 'card1',
				right = 'card3',
			},
			withActions = {},
			withModal = {
				down = 'plate',
				left = 'card1',
				right = 'card3',
				up = 'modalAction1',
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
				down = 'plate',
				left = 'card2',
				right = 'deck'
			},
			withActions = {},
			withModal = {
					down = 'plate',
				left = 'card2',
				right = 'deck',
				up = 'modalAction1',
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
		label = 'Draw 3 New Cards',
		action = true,
		selectable = true,
		hand = false,

		nav = {
			withHand = {},
			withActions = {
				down = 'served',
				right = 'actionNewPlate',
			},
			withModal = {},
		},

		x = 80,
		y = 60,
		width = 250,
		height = 250,
	},
	actionNewPlate = {
		label = 'Start a new Plate',
		action = true,
		selectable = true,
		hand = false,

		nav = {
			withHand = {},
			withActions = {
				down = 'plate',
				left = 'actionDraw',
				right = 'deck'
			},
			withModal = {},
		},

		x = 350,
		y = 60,
		width = 250,
		height = 250,
	},
	offScreenModal = {
		x = 80,
		y = -1200,
		width = 1440,
		height = 1040,
	},
	onScreenModal = {
		x = 80,
		y = 80,
		width = 1440,
		height = 1040,
	},
	modal = {
		x = 80,
		y = -1200,
		width = 1440,
		height = 1040,
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

		x = 300,
		y = 300,
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

		x = 600,
		y = 300,
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

		x = 900,
		y = 300,
		width = cardSize.width,
		height = cardSize.height,
	},
	modalAction1 = {
		label = 'Modal',
		modal = true,
		action = true,
		actionIndex = 1,
		selectable = true,

		nav = {
			withHand = {},
			withActions = {},
			withModal = {
				up = 'modalCard1',
				down = 'deck',
				right = 'modalAction2',
			},
		},

		x = 100,
		y = 800,
		width = 500,
		height = 200,
	},
	modalAction2 = {
		label = 'Modal',
		modal = true,
		action = true,
		actionIndex = 2,
		selectable = true,

		nav = {
			withHand = {},
			withActions = {},
			withModal = {
				up = 'modalCard3',
				down = 'deck',
				left = 'modalAction1',
			},
		},

		x = 700,
		y = 800,
		width = 500,
		height = 200,
	},
}
