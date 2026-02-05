scale = 2

cardSize = {
	width = 125 * scale,
	height = 125 * scale,
}

-- UI elements
ui = {
	hand = {
		x = 10 * scale,
		y = 10 * scale,
		width = 460 * scale,
		height = 200 * scale,
	},
	actions = {
		x = 10 * scale,
		y = 10 * scale,
		width = 460 * scale,
		height = 200 * scale,
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

		x = 10 * scale,
		y = 220 * scale,
		width = 200 * scale,
		height = 370 * scale,
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

		x = 220 * scale,
		y = 220 * scale,
		width = 300 * scale,
		height = 370 * scale,
	},
	plateScore = {
		x = 530 * scale,
		y = 270 * scale,
		width = 260 * scale,
		height = 140 * scale,
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

		x = 530 * scale,
		y = 450 * scale,
		width = 260 * scale,
		height = 140 * scale,
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

		x = 480 * scale,
		y = 10 * scale,
		width = 310 * scale,
		height = 200 * scale,
	},
	drawPile = {
		x = 500 * scale,
		y = 30 * scale,
		width = cardSize.width,
		height = cardSize.height,
	},
	discardPile = {
		x = 645 * scale,
		y = 30 * scale,
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

		x = 40 * scale,
		y = 50 * scale,
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

		x = 175 * scale,
		y = 50 * scale,
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

		x = 310 * scale,
		y = 50 * scale,
		width = cardSize.width,
		height = cardSize.height,
	},
	plateCards = {
		x = 240 * scale,
		y = 240 * scale,
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

			x = 40 * scale,
			y = 50 * scale,
			width = 125 * scale,
			height = 125 * scale,
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

		x = 175 * scale,
		y = 50 * scale,
		width = 125 * scale,
		height = 125 * scale,
	},
	completedPlates = {
		x = 40 * scale,
		y = 450 * scale,
		width = cardSize.width,
		height = cardSize.height,
	},
	offScreenModal = {
		x = 40 * scale,
		y = -600 * scale,
		width = 720 * scale,
		height = 520 * scale,
	},
	onScreenModal = {
		x = 40 * scale,
		y = 40 * scale,
		width = 720 * scale,
		height = 520 * scale,
	},
	modal = {
		x = 40 * scale,
		y = -600 * scale,
		width = 720 * scale,
		height = 520 * scale,
	},
	actionModal = {
		label = '^ Go to Card Preview ^',

		x = 20 * scale,
		y = 15 * scale,
		width = 440 * scale,
		height = 20 * scale,
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

		x = 150 * scale,
		y = 150 * scale,
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

		x = 300 * scale,
		y = 150 * scale,
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

		x = 450 * scale,
		y = 150 * scale,
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

		x = 100 * scale,
		y = 300 * scale,
		width = 300 * scale,
		height = 100 * scale,
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

		x = 450 * scale,
		y = 300 * scale,
		width = 300 * scale,
		height = 100 * scale,
	}
}
