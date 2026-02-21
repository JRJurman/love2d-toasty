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
		points = 2,
	},
	[3] = {
		label = 'Avocado',
		effectShortLabel = 'on play effect, shuffle',
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
		effectShortLabel = 'on play effect, plate',
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
		effectShortLabel = 'on play effect, shuffle',
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
		effectShortLabel = 'on play effect, plate',
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
		effectShortLabel = 'on play effect, shuffle',
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
		effectShortLabel = 'on play effect, plate',
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
		effectShortLabel = 'on play effect, shuffle',
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
		effectShortLabel = 'on play effect, plate',
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
}
