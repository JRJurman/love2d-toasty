cardDetails = {
	[-1] = {
		label = 'Discard',
	},
	[0] = {
		label = 'Deck',
	},
	[1] = {
		label = 'Bread',
		effect = 'automatically played when drawn. Needed to start toast, but can cause sandwiches.',
		points = 0,
		onDraw = {'plate'}
	},
	[2] = {
		label = 'Butter',
		effect = 'worth an extra point.',
		points = 2,
	},
	[3] = {
		label = 'Avocado',
		effect = 'worth an extra point.',
		points = 2,
	},
	[4] = {
		label = 'Strawberry',
		effect = 'preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[5] = {
		label = 'Whip Cream',
		effect = 'preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[6] = {
		label = 'Jam',
		effect = 'preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[7] = {
		label = 'Orange',
		effect = 'preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[8] = {
		label = 'Egg',
		effect = 'preview the next two cards, you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[9] = {
		label = 'Cheddar',
		effect = 'preview the next two cards, you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[10] = {
		label = 'Garlic',
		effect = 'preview the next two cards, you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[11] = {
		label = 'Onion',
		effect = 'preview the next two cards, you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[12] = {
		label = 'Ricotta',
		effect = 'preview the next two cards, you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[13] = {
		label = 'Sausage',
		effect = 'preview the next two cards, you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
	[14] = {
		label = 'Bacon',
		effect = 'preview the next two cards, you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
}
