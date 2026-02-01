require('dump')
require('shuffle')

require('animation')
local ease = require('ease')

local cardSize = {
	width = 125,
	height = 125
}

-- UI elements
local ui = {
	hand = {
		label = 'Hand',

		-- going in a direction goes to what?
		up = 'none',
		left = 'none',
		down = 'plate',
		right = 'deck',
		select = 'card1',

		-- position and size
		x = 10,
		y = 10,
		width = 460,
		height = 200,
	},
	served = {
		label = 'Completed Plates',

		-- going in a direction goes to what?
		up = 'hand',
		left = 'none',
		down = 'none',
		right = 'plate',
		select = 'none',

		-- position and size
		x = 10,
		y = 220,
		width = 200,
		height = 370,
	},
	plate = {
		label = 'Current Plate',

		-- going in a direction goes to what?
		up = 'hand',
		left = 'served',
		down = 'none',
		right = 'score',
		select = 'none',

		-- position and size
		x = 220,
		y = 220,
		width = 300,
		height = 370,
	},
	score = {
		label = 'Round Score',

		-- going in a direction goes to what?
		up = 'deck',
		left = 'plate',
		down = 'none',
		right = 'none',
		select = 'none',

		-- position and size
		x = 530,
		y = 450,
		width = 260,
		height = 140,
	},
	deck = {
		label = 'Draw and Discard Piles',

		-- going in a direction goes to what?
		up = 'none',
		left = 'hand',
		down = 'score',
		right = 'none',
		select = 'none',

		-- position and size
		x = 480,
		y = 10,
		width = 310,
		height = 200,
	},
	drawPile = {
		-- position and size
		x = 500,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	discardPile = {
		-- position and size
		x = 645,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	card1 = {
		label = 'First Card',

		-- going in a direction goes to what?
		up = 'hand',
		left = 'none',
		down = 'none',
		right = 'card2',
		select = 'none',

		-- position and size
		x = 40,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	card2 = {
		label = 'Second Card',

		-- going in a direction goes to what?
		up = 'hand',
		left = 'card1',
		down = 'none',
		right = 'card3',
		select = 'none',

		-- position and size
		x = 175,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	card3 = {
		label = 'Third Card',

		-- going in a direction goes to what?
		up = 'hand',
		left = 'card2',
		down = 'none',
		right = 'none',
		select = 'none',

		-- position and size
		x = 310,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
}

local cardDetails = {
	[1] = {
		label = 'Bread',
		effect = 'automatically played when drawn. Needed to start toast, but can cause sandwiches.'
	},
	[2] = {
		label = 'Strawberries',
		effect = 'when played, previews the next three cards in the deck'
	},
	[3] = {
		label = 'Blueberries',
		effect = 'when played, preview the next card, you may shuffle'
	},
	[4] = {
		label = 'Oranges',
		effect = 'preview the next card, you may draw'
	},
	[5] = {
		label = 'Avocado',
		effect = 'preview the next 3 cards, you may draw one, if you do, shuffle the rest'
	},
	[6] = {
		label = 'Jam',
		effect = '+1 point'
	},
	[7] = {
		label = 'Tomatoes',
		effect = '+1 point'
	},
	[8] = {
		label = 'Hummus',
		effect = '+1 point'
	},
	[9] = {
		label = 'Bananas',
		effect = '+1 point'
	},
}

local deck = {
	1, 1, 1, 1,
	2, 2, 3, 3, 4, 4,
	5, 5, 6, 6, 7, 7,
	8, 8, 9, 9, 9, 9,
}

local drawPile = shuffle(deck)
local discardPile = {}
local hand = {}

local selection = 'hand'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local	routines = {}
local ttsText = ''

local navAnimationSpeed = 0.35
local drawAnimationSpeed = 1

local cardFromDeck = {x = ui.drawPile.x, y = ui.drawPile.y, enabled = false }

function love.load()
	print('tts: Created by Jesse Jurman.')

	-- draw three cards from drawPile to hand
	local posEaseFunction = ease.inovershoot
	async(routines, function()
		cardFromDeck.enabled = true
		cardFromDeck.x = ui.drawPile.x
		cardFromDeck.y = ui.drawPile.y
		animate(cardFromDeck, "x", ui.card1.x, drawAnimationSpeed, posEaseFunction)
		table.insert(hand, table.remove(drawPile, 1))
		cardFromDeck.x = ui.drawPile.x
		cardFromDeck.y = ui.drawPile.y
		animate(cardFromDeck, "x", ui.card2.x, drawAnimationSpeed, posEaseFunction)
		table.insert(hand, table.remove(drawPile, 1))
		cardFromDeck.x = ui.drawPile.x
		cardFromDeck.y = ui.drawPile.y
		animate(cardFromDeck, "x", ui.card3.x, drawAnimationSpeed, posEaseFunction)
		table.insert(hand, table.remove(drawPile, 1))
		cardFromDeck.enabled = false
	end)
end

function love.update(dt)
	updateAnimations(routines, dt)
end

function love.draw()
	love.graphics.clear()

	-- draw the UI elements
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.hand.x, ui.hand.y, ui.hand.width, ui.hand.height)
	love.graphics.rectangle("line", ui.served.x, ui.served.y, ui.served.width, ui.served.height)
	love.graphics.rectangle("line", ui.plate.x, ui.plate.y, ui.plate.width, ui.plate.height)
	love.graphics.rectangle("line", ui.score.x, ui.score.y, ui.score.width, ui.score.height)
	love.graphics.rectangle("line", ui.deck.x, ui.deck.y, ui.deck.width, ui.deck.height)

	-- draw cards
	love.graphics.setColor(0.43, 0.98, 0.47)
	if hand[1] then
		love.graphics.rectangle("line", ui.card1.x, ui.card1.y, ui.card1.width, ui.card1.height)
		love.graphics.printf(cardDetails[hand[1]].label, ui.card1.x, ui.card1.y + ui.card1.height, ui.card1.width, 'center')
	end
	if hand[2] then
		love.graphics.rectangle("line", ui.card2.x, ui.card2.y, ui.card2.width, ui.card2.height)
		love.graphics.printf(cardDetails[hand[2]].label, ui.card2.x, ui.card2.y + ui.card2.height, ui.card2.width, 'center')
	end
	if hand[3] then
		love.graphics.rectangle("line", ui.card3.x, ui.card3.y, ui.card3.width, ui.card3.height)
		love.graphics.printf(cardDetails[hand[3]].label, ui.card3.x, ui.card3.y + ui.card3.height, ui.card3.width, 'center')
	end

	-- draw drawPile and discardPile
	love.graphics.setColor(0.43, 0.43, 0.47)
	love.graphics.rectangle("line", ui.drawPile.x, ui.drawPile.y, ui.drawPile.width, ui.drawPile.height)
	love.graphics.rectangle("line", ui.discardPile.x, ui.discardPile.y, ui.discardPile.width, ui.discardPile.height)
	love.graphics.printf(#drawPile, ui.drawPile.x, ui.drawPile.y + ui.drawPile.height/2, ui.drawPile.width, 'center')
	love.graphics.printf(#discardPile, ui.discardPile.x, ui.discardPile.y + ui.discardPile.height/2, ui.discardPile.width, 'center')

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	love.graphics.rectangle("line", cursor.x, cursor.y, cursor.width, cursor.height)

	-- draw any cards that are moving
	if cardFromDeck.enabled then
		love.graphics.setColor(0.43, 0.98, 0.47)
		love.graphics.rectangle("line", cardFromDeck.x, cardFromDeck.y, cardSize.width, cardSize.height)
	end
end

-- for unknown reasons, love.js can sometimes read the arrow keys in safari as the following
-- https://github.com/JRJurman/love2d-a11y-template/issues/1
local hardware_remap = {
  kp8 = "up",
  kp2 = "down",
  kp4 = "left",
  kp6 = "right",
}

local game_remap = {
	x = "select"
}

local player_remap = {}

function remap(key)
	key = hardware_remap[key] or key
	key = game_remap[key] or key
	key = player_remap[key] or key

	return key
end

function love.keypressed(key)
	key = remap(key)

	local isCardSelected = selection == 'card1' or selection == 'card2' or selection == 'card3'

	-- navigation
	if key == 'down' or key == 'up' or key == 'left' or key == 'right' or key == 'select' then
		local nextSelection = ui[selection][key]
		if nextSelection == 'none' then
			return
		end

		-- if they press up or down, make sure they can get back to the previous option
		-- don't do this if they are in a hand selection
		if key == 'up' and not isCardSelected then
			ui[nextSelection].down = selection
		elseif key == 'down' and not isCardSelected then
			ui[nextSelection].up = selection
		end

		selection = ui[selection][key]
		local posEaseFunction = ease.inovershoot
		local sizeEaseFunction = ease.inovershoot
		async(routines, function()
			animate(cursor, "x", ui[selection].x, navAnimationSpeed, posEaseFunction)
		end)
		async(routines, function()
			animate(cursor, "y", ui[selection].y, navAnimationSpeed, posEaseFunction)
		end)
		async(routines, function()
			animate(cursor, "width", ui[selection].width, navAnimationSpeed, sizeEaseFunction)
		end)
		async(routines, function()
			animate(cursor, "height", ui[selection].height, navAnimationSpeed, sizeEaseFunction)
		end)

		local navDirections = 'Use the following keys to change selection: '
		local dirLabel = ''
		if ui[selection].select ~= 'none' then
			dirLabel = ui[ui[selection].select].label
			navDirections = navDirections..' select, '..dirLabel..'. '
		end
		if ui[selection].up ~= 'none' then
			dirLabel = ui[ui[selection].up].label
			navDirections = navDirections..' up, '..dirLabel..'; '
		end
		if ui[selection].down ~= 'none' then
			dirLabel = ui[ui[selection].down].label
			navDirections = navDirections..' down, '..dirLabel..'; '
		end
		if ui[selection].left ~= 'none' then
			dirLabel = ui[ui[selection].left].label
			navDirections = navDirections..' left, '..dirLabel..'; '
		end
		if ui[selection].right ~= 'none' then
			dirLabel = ui[ui[selection].right].label
			navDirections = navDirections..' right, '..dirLabel..'. '
		end
		dirLabel = ui[selection].label
		ttsText = dirLabel..' selected. '..navDirections
		print('tts: '..ttsText)
	end

	-- card selection
	if key == 'select' and isCardSelected then

	end

	-- repeat text if r was pressed
	if key == "r" then
		async(routines, function()
			print('tts: repeating...')
			wait(0.5)
			print('tts: '..ttsText)
		end)
	end
end
