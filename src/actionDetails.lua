wideInstructions = 'Use Spacebar, Enter, or X to select, W A S D or arrow keys to change selection. Use the R key to repeat instructions any time. Escape for settings.'
tallInstructions = ''

actionDetails = {
	start = {
		modalTitle = "Toasty!",
		modalSubtitle = "a push-your-luck deck builder",
		label = "Start",
		initialModalDescription = "Chef, start plates with bread and then make fat stacks of ingredients on top. You must never make a sandwich though, chef, sandwiches are forbidden. Make it through 5 shifts.",
		actionDescription = "Select to start the game",
	},
	restart = {
		modalTitle = "Game Over!",
		modalSubtitle = "better luck next time",
		label = "Start Again",
		initialModalDescription = "Chef, you ran out of bread! Start a new game?",
		actionDescription = "Select to start the game again from the beginning.",
	},
	-- close is for preview
	close = {
		modalTitle = "Preview Next Cards",
		label = "Close",
		initialModalDescription = "Showing the next cards that you will draw.",
		actionDescription = "Select to close the modal.",
	},
	skip = {
		label = "Skip",
		actionDescription = "Select to skip taking an action.",
	},
	shuffle = {
		modalTitle = "Shuffle Next Cards?",
		modalSubtitle = "guarantees a bread next hand",
		label = "Shuffle",
		initialModalDescription = "Showing the next cards that you will draw, you may shuffle them back into your draw pile, and guarantee a bread next hand.",
		actionDescription = "Select this option to shuffle your draw pile, and guarantee a bread next hand.",
	},
	pick = {
		modalTitle = "Pick a Card?",
		label = "Select Card",
		initialModalDescription = "Showing the next cards that you will draw, you may pick one to add one to your hand now.",
		actionDescription = "Select a card above to add to your hand.",
	},
	plate = {
		modalTitle = "Plate a Card?",
		label = "Select Card",
		initialModalDescription = "Showing the next cards that you will draw, you may pick one to immediately plate now.",
		actionDescription = "Select a card above to immediately plate.",
	},
	add = {
		modalTitle = "Add a Card?",
		modalSubtitle = "comes with free bread",
		label = "Add Card",
		initialModalDescription = "Starting new shift. Showing new cards that you can add to your deck. Each comes with a free bread card.",
		actionDescription = "Select a card above to add it to your deck.",
	},
	remove = {
		modalTitle = "Remove a Card?",
		label = "Remove Card",
		initialModalDescription = "Showing the next cards that you will draw, you may pick one to remove from your deck permanently.",
		actionDescription = "Select a card above to remove it from your deck.",
	},
	endless = {
		modalTitle = "Shifts Complete!",
		modalSubtitle = "great job",
		label = "Continue",
		initialModalDescription = "You completed the beginning shifts!",
		actionDescription = "Select this option to keep going and complete as many shifts as you can, or press right and start over.",
	},
}
