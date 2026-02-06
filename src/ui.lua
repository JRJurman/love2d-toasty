cardSize = {
	width = 250,
	height = 250,
}

-- UI elements
ui = {
	hand = {
		x = 20,
		y = 20,
		width = 920,
		height = 400,
	},
	actions = {
		x = 20,
		y = 20,
		width = 920,
		height = 400,
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

		x = 20,
		y = 440,
		width = 400,
		height = 740,
	},
	plate = {
		label = 'Current Plate',

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

		x = 440,
		y = 440,
		width = 600,
		height = 740,
	},
	plateScore = {
		x = 1060,
		y = 540,
		width = 520,
		height = 280,
	},
	score = {
		label = 'Round Score',

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

		x = 1060,
		y = 900,
		width = 520,
		height = 280,
	},
	deck = {
		label = 'Draw and Discard Piles',

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

		x = 960,
		y = 20,
		width = 620,
		height = 400,
	},
	drawPile = {
		x = 1000,
		y = 60,
		width = cardSize.width,
		height = cardSize.height,
	},
	discardPile = {
		x = 1290,
		y = 60,
		width = cardSize.width,
		height = cardSize.height,
	},
	card1 = {
		label = 'First Card',
		card = true,
		handIndex = 1,

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

		x = 80,
		y = 100,
		width = cardSize.width,
		height = cardSize.height,
	},
	card2 = {
		label = 'Second Card',
		card = true,
		handIndex = 2,

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

		x = 350,
		y = 100,
		width = cardSize.width,
		height = cardSize.height,
	},
	card3 = {
		label = 'Third Card',
		card = true,
		handIndex = 3,

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

		x = 620,
		y = 100,
		width = cardSize.width,
		height = cardSize.height,
	},
	plateCards = {
		x = 480,
		y = 480,
		width = cardSize.width,
		height = cardSize.height,
	},
	actionDraw = {
			label = 'Draw 3 New Cards',
			action = true,

			nav = {
				withHand = {},
				withActions = {
					down = 'served',
					right = 'actionNewPlate',
				},
				withModal = {},
			},

			x = 80,
			y = 100,
			width = 250,
			height = 250,
	},
	actionNewPlate = {
		label = 'Start a new Plate',
		action = true,

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
		y = 100,
		width = 250,
		height = 250,
	},
	completedPlates = {
		x = 80,
		y = 900,
		width = cardSize.width,
		height = cardSize.height,
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
	actionModal = {
		label = '^ Go to Card Preview ^',

		x = 40,
		y = 30,
		width = 880,
		height = 40,
	},
	-- NOTE: modal ui is relative, because it moves with it
	modalCard1 = {
		label = 'First Previewed Card',
		modal = true,
		card = true,
		drawIndex = 1,

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
		label = 'Card Preview',
		modal = true,
		action = true,
		actionIndex = 1,

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
		label = 'Card Preview',
		modal = true,
		action = true,
		actionIndex = 2,

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
	}
}
