cardSize = {
	width = 125,
	height = 125
}

-- UI elements
ui = {
	hand = {
		x = 10,
		y = 10,
		width = 460,
		height = 200,
	},
	actions = {
		x = 10,
		y = 10,
		width = 460,
		height = 200,
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

		x = 10,
		y = 220,
		width = 200,
		height = 370,
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

		x = 220,
		y = 220,
		width = 300,
		height = 370,
	},
	plateScore = {
		x = 530,
		y = 270,
		width = 260,
		height = 140,
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

		x = 530,
		y = 450,
		width = 260,
		height = 140,
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

		x = 480,
		y = 10,
		width = 310,
		height = 200,
	},
	drawPile = {
		x = 500,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	discardPile = {
		x = 645,
		y = 30,
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

		x = 40,
		y = 50,
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

		x = 175,
		y = 50,
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

		x = 310,
		y = 50,
		width = cardSize.width,
		height = cardSize.height,
	},
	plateCards = {
		x = 240,
		y = 240,
		width = cardSize.width,
		height = cardSize.height,
	},
	actionDraw = {
			label = 'Draw 3 New Cards',

			nav = {
				withHand = {},
				withActions = {
					down = 'served',
					right = 'actionNewPlate',
				},
				withModal = {},
			},

			x = 40,
			y = 50,
			width = 125,
			height = 125,
	},
	actionNewPlate = {
		label = 'Start a new Plate',

		nav = {
			withHand = {},
			withActions = {
				down = 'plate',
				left = 'actionDraw',
				right = 'deck'
			},
			withModal = {},
		},

		x = 175,
		y = 50,
		width = 125,
		height = 125,
	},
	completedPlates = {
		x = 40,
		y = 450,
		width = cardSize.width,
		height = cardSize.height,
	},
	offScreenModal = {
		x = 40,
		y = -600,
		width = 720,
		height = 520,
	},
	onScreenModal = {
		x = 40,
		y = 40,
		width = 720,
		height = 520,
	},
	modal = {
		x = 40,
		y = -600,
		width = 720,
		height = 520,
	},
	actionModal = {
		label = '^ Go to Card Preview ^',

		x = 20,
		y = 15,
		width = 440,
		height = 20,
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

		x = 150,
		y = 150,
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

		x = 300,
		y = 150,
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

		x = 450,
		y = 150,
		width = cardSize.width,
		height = cardSize.height,
	},
	modalAction1 = {
		label = 'Card Preview',
		modal = true,

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
		y = 300,
		width = 300,
		height = 100,
	},
	modalAction2 = {
		label = 'Card Preview',
		modal = true,

		nav = {
			withHand = {},
			withActions = {},
			withModal = {
				up = 'modalCard3',
				down = 'deck',
				left = 'modalAction1',
			},
		},

		x = 450,
		y = 300,
		width = 300,
		height = 100,
	}
}
