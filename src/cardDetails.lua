cardDetails = {
	[-1] = {
		label = 'Discard',
	},
	[0] = {
		label = 'Deck',
	},
	[1] = {
		label = 'Bread',
		rarity = 'common',
		effectShortLabel = 'starts toast, causes sandwiches.',
		effect = 'automatically played when drawn. Needed to start toast, but can cause sandwiches.',
		points = 0,
		onDraw = {'plate'}
	},
	[2] = {
		label = 'Butter',
		rarity = 'common',
		points = 1,
	},
	[3] = {
		label = 'Avocado',
		rarity = 'common',
		effectKey = 'shuffle',
		effectShortLabel = 'on playing from hand, shuffle deck',
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
		rarity = 'common',
		effectKey = 'plate',
		effectShortLabel = 'on playing from hand, plate another ingredient',
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
		rarity = 'common',
		points = 2,
	},
	[6] = {
		label = 'Jam',
		rarity = 'common',
		effectKey = 'shuffle',
		effectShortLabel = 'on playing from hand, shuffle deck',
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
		rarity = 'common',
		effectKey = 'plate',
		effectShortLabel = 'on playing from hand, plate another ingredient',
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
		rarity = 'common',
		points = 2,
	},
	[9] = {
		label = 'Cheddar',
		rarity = 'common',
		effectKey = 'shuffle',
		effectShortLabel = 'on playing from hand, shuffle deck',
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
		rarity = 'common',
		effectKey = 'plate',
		effectShortLabel = 'on playing from hand, plate another ingredient',
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
		rarity = 'common',
		points = 2,
	},
	[12] = {
		label = 'Ricotta',
		rarity = 'common',
		effectKey = 'shuffle',
		effectShortLabel = 'on playing from hand, shuffle deck',
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
		rarity = 'common',
		effectKey = 'plate',
		effectShortLabel = 'on playing from hand, plate another ingredient',
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
		rarity = 'common',
		points = 2,
	},
	[15] = {
		label = 'Pickles',
		rarity = 'uncommon',
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
		rarity = 'uncommon',
		effectKey = 'finish',
		effectShortLabel = 'on playing from hand, finish toast',
		effect = 'when played immediately scores and completes your plate.',
		points = 4,
		onPlay = {
			name = 'finish',
		}
	},
	[17] = {
		label = 'Bananas',
		rarity = 'uncommon',
		effectKey = 'reduce-draw',
		effectShortLabel = 'on playing from hand, reduce next draw size',
		effect = 'when played reduce the number of cards you will draw next turn by one.',
		points = 1,
		onPlay = {
			name = 'reduce-draw',
		}
	},
	[18] = {
		label = 'Cream Cheese',
		rarity = 'uncommon',
		effectKey = 'small-recover',
		effectShortLabel = 'on playing from hand, recover some ingredients',
		effect = 'when played return two random ingredients from the discard to your deck.',
		points = 1,
		onPlay = {
			name = 'small-recover'
		}
	},
	[19] = {
		label = 'Pita',
		rarity = 'rare',
		effectKey = 'decker',
		effectShortLabel = 'starts toast, does not cause sandwiches',
		effect = 'can be played to start toast or as an ingredient on top of existing toast, does not cause sandwiches.',
		points = 2
	},
	[20] = {
		label = 'Hummus',
		rarity = 'rare',
		effectKey = 'recover-all',
		effectShortLabel = 'on playing from hand, recover all ingredients',
		effect = 'when played return all ingredients from the discard to your deck.',
		points = 2,
		onPlay = {
			name = 'recover-all'
		}
	},
	[21] = {
		label = 'Salmon',
		rarity = 'rare',
		points = 8
	},
	[22] = {
		label = 'Tomato',
		rarity = 'rare',
		effectKey = 'remove',
		effectShortLabel = 'on playing from hand, remove ingredient from deck',
		effect = 'when played preview the next two cards and you may remove one from your deck.',
		points = 2,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'remove', 'skip'}
		}
	}
}
