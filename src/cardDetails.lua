cardDetails = {
	[-1] = {
		label = 'Discard',
	},
	[0] = {
		label = 'Deck',
	},
	[1] = {
		label = 'Bread',
		effectShortLabel = 'starts toast, causes sandwiches.',
		effect = 'automatically played when drawn. Needed to start toast, but can cause sandwiches.',
		points = 0,
		onDraw = {'plate'}
	},
	[2] = {
		label = 'Butter',
		points = 1,
	},
	[3] = {
		label = 'Avocado',
		effectKey = 'shuffle',
		effectShortLabel = 'on play effect, shuffle deck',
		effect = 'when played preview the next two cards and you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
	[4] = {
		label = 'Strawberry',
		effectKey = 'plate',
		effectShortLabel = 'on play effect, plate another ingredient',
		effect = 'when played preview the next two cards and you may immediately plate one.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'plate', 'skip'}
		}
	},
	[5] = {
		label = 'Whip Cream',
		points = 2,
	},
	[6] = {
		label = 'Jam',
		effectKey = 'shuffle',
		effectShortLabel = 'on play effect, shuffle deck',
		effect = 'when played preview the next two cards and you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
	[7] = {
		label = 'Orange',
		effectKey = 'plate',
		effectShortLabel = 'on play effect, plate another ingredient',
		effect = 'when played preview the next two cards and you may immediately plate one.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'plate', 'skip'}
		}
	},
	[8] = {
		label = 'Egg',
		points = 2,
	},
	[9] = {
		label = 'Cheddar',
		effectKey = 'shuffle',
		effectShortLabel = 'on play effect, shuffle deck',
		effect = 'when played preview the next two cards and you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
	[10] = {
		label = 'Garlic',
		effectKey = 'plate',
		effectShortLabel = 'on play effect, plate another ingredient',
		effect = 'when played preview the next two cards and you may immediately plate one.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'plate', 'skip'}
		}
	},
	[11] = {
		label = 'Onion',
		points = 2,
	},
	[12] = {
		label = 'Ricotta',
		effectKey = 'shuffle',
		effectShortLabel = 'on play effect, shuffle deck',
		effect = 'when played preview the next two cards and you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
	[13] = {
		label = 'Sausage',
		effectKey = 'plate',
		effectShortLabel = 'on play effect, plate another ingredient',
		effect = 'when played preview the next two cards and you may immediately plate one.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'plate', 'skip'}
		}
	},
	[14] = {
		label = 'Bacon',
		points = 2,
	},
	[15] = {
		label = 'Pickles',
		effectKey = 'side',
		effectShortLabel = 'a side even when toast is missing',
		effect = 'can always be played even when no toast has been started yet.',
		points = 1,
		onPlate = {
			name = 'side',
		}
	},
	[16] = {
		label = 'Blueberries',
		effectKey = 'finish',
		effectShortLabel = 'on play effect, finish toast',
		effect = 'when played immediately scores and completes your plate.',
		points = 4,
		onPlay = {
			name = 'finish',
		}
	},
	[17] = {
		label = 'Bananas',
		effectKey = 'reduce-draw',
		effectShortLabel = 'on play effect, reduce next draw size',
		effect = 'when played reduce the number of cards you will draw next turn by one.',
		points = 1,
		onPlay = {
			name = 'reduce-draw',
		}
	},
	[18] = {
		label = 'Cream Cheese',
		effect = 'small-recover',
		effectShortLabel = 'on play effect, recover some ingredients',
		effect = 'when played return two random ingredients from the discard to your deck.',
		points = 1,
		onPlay = {
			name = 'small-recover'
		}
	},
	[19] = {
		label = 'Pita',
		effect = 'decker',
		effectShortLabel = 'starts toast, does not causes sandwiches',
		effect = 'can be played to start toast or as an ingredient on top of existing toast, does not cause sandwiches.',
		points = 2
	},
	[20] = {
		label = 'Hummus',
		effect = 'recover-all',
		effectShortLabel = 'on play effect, recover all ingredients',
		effect = 'when played return all ingredients from the discard to your deck.',
		points = 2,
		onPlay = {
			name = 'recover-all'
		}
	},
	[21] = {
		label = 'Salmon',
		points = 8
	},
	[22] = {
		label = 'Tomato',
		effectKey = 'remove',
		effectShortLabel = 'on play effect, remove ingredient from deck',
		effect = 'when played preview the next two cards and you may remove one from your deck.',
		points = 2,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'remove', 'skip'}
		}
	}
}
