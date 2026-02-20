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
		points = 1,
		onDraw = {'plate'}
	},
	[2] = {
		label = 'Butter',
		points = 2,
	},
	[3] = {
		label = 'Avocado',
		points = 2,
	},
	[4] = {
		label = 'Strawberry',
		effectShortLabel = 'on play, preview',
		effect = 'when played preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[5] = {
		label = 'Whip Cream',
		points = 2,
	},
	[6] = {
		label = 'Jam',
		effectShortLabel = 'on play, preview',
		effect = 'when played preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[7] = {
		label = 'Orange',
		effectShortLabel = 'on play, preview',
		effect = 'when played preview the next 2 cards.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'close'}
		}
	},
	[8] = {
		label = 'Egg',
		effectShortLabel = 'on play effect, pick',
		effect = 'when played preview the next two cards and you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[9] = {
		label = 'Cheddar',
		effectShortLabel = 'on play effect, pick',
		effect = 'when played preview the next two cards and you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[10] = {
		label = 'Garlic',
		points = 2,
	},
	[11] = {
		label = 'Onion',
		points = 2,
	},
	[12] = {
		label = 'Ricotta',
		effectShortLabel = 'on play effect, pick',
		effect = 'when played preview the next two cards and you may add one to your hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'pick', 'skip'}
		}
	},
	[13] = {
		label = 'Sausage',
		effectShortLabel = 'on play effect, shuffle',
		effect = 'when played preview the next two cards and you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
	[14] = {
		label = 'Bacon',
		effectShortLabel = 'on play effect, shuffle',
		effect = 'when played preview the next two cards and you may shuffle and guarantee a bread next hand.',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 2,
			actions = {'shuffle', 'skip'}
		}
	},
}
