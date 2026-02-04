cardDetails = {
	[1] = {
		label = 'Bread',
		effect = 'automatically played when drawn. Needed to start toast, but can cause sandwiches.',
		points = 0,
		onDraw = {'plate'}
	},
	[2] = {
		label = 'Strawberries',
		effect = 'when played, previews the next three cards in the deck',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 3,
			actions = {'close'}
		}
	},
	[3] = {
		label = 'Blueberries',
		effect = 'when played, preview the next card, you may shuffle',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 1,
			actions = {'shuffle', 'skip_shuffle'}
		}
	},
	[4] = {
		label = 'Oranges',
		effect = 'preview the next card, you may draw',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 1,
			actions = {'pick', 'skip_pick'}
		}
	},
	[5] = {
		label = 'Avocado',
		effect = 'preview the next 3 cards, you may draw one',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 3,
			actions = {'pick', 'skip_pick'}
		}
	},
	[6] = {
		label = 'Jam',
		effect = 'preview the next 3 cards, you may shuffle the draw pile',
		points = 1,
		onPlay = {
			name = 'preview',
			previewCount = 3,
			actions = {'shuffle', 'skip_shuffle'}
		}
	},
	[7] = {
		label = 'Tomatoes',
		effect = 'worth an extra point',
		points = 2,
	},
	[8] = {
		label = 'Hummus',
		effect = 'worth an extra point',
		points = 2,
	},
	[9] = {
		label = 'Bananas',
		effect = 'worth an extra point',
		points = 2,
	},
}
