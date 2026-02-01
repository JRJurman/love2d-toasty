require('dump')
require('shuffle')
require('cardDetails')

require('animation')
local ease = require('ease')

local cardSize = {
	width = 125,
	height = 125
}

-- UI elements
local ui = {
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
			}
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
			},
			withActions = {
				up = 'actionNewPlate',
				right = 'score',
			}
		},

		x = 220,
		y = 220,
		width = 300,
		height = 370,
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
			}
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
			}
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

		nav = {
			withHand = {
				right = 'card2',
				down = 'served',
			},
		},

		x = 40,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	card2 = {
		label = 'Second Card',

		nav = {
			withHand = {
				down = 'plate',
				left = 'card1',
				right = 'card3',
			},
		},


		x = 175,
		y = 30,
		width = cardSize.width,
		height = cardSize.height,
	},
	card3 = {
		label = 'Third Card',

		nav = {
			withHand = {
				down = 'plate',
				left = 'card2',
			},
		},


		x = 310,
		y = 30,
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
				withActions = {
					down = 'served',
					right = 'actionNewPlate',
				},
			},

			x = 40,
			y = 30,
			width = 125,
			height = 125,
	},
	actionNewPlate = {
		label = 'Start a new Plate',

		nav = {
			withActions = {
				down = 'plate',
				left = 'actionDraw',
				right = 'deck'
			},
		},

		x = 175,
		y = 30,
		width = 125,
		height = 125,
	}
}

local deck = {
	1, 1, 1, 1,
	2, 2, 3, 3, 4, 4,
	5, 5, 6, 6, 7, 7,
	8, 8, 9, 9, 9, 9,
}

local drawPile = {}
function countValueInTopOfPile(pile, count, value)
	local totalCount = 0
	for pileIndex=1, count do
		if pile[pileIndex] == value then
			totalCount = totalCount + 1
		end
	end
	return totalCount
end
function shuffleDrawPile()
	-- keep shuffling until the first six contain exactly 1 bread
	-- or until we hit like, 200 shuffles (give up at that point)
	local totalShuffles = 0
	repeat
		print('shuffling.. '..totalShuffles)
		totalShuffles = totalShuffles + 1
		drawPile = shuffle(deck)
	until countValueInTopOfPile(drawPile, 6, 1) == 1 or totalShuffles > 200
end

shuffleDrawPile()

local discardPile = {}
local hand = {}
local currentPlate = {}
local completedPlates = {}

local selection = 'deck'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local	routines = {}
local ttsText = ''

local navAnimationSpeed = 0.35
local drawAnimationSpeed = 0.8

local movingCard = {x = ui.drawPile.x, y = ui.drawPile.y, enabled = false }

function drawFromDeck()
	movingCard.enabled = true
	movingCard.x = ui.drawPile.x
	movingCard.y = ui.drawPile.y
	local target = ui.card1
	if hand[1] == nil then
		target = ui.card1
	elseif hand[2] == nil then
		target = ui.card2
	elseif hand[3] == nil then
		target = ui.card3
	end
	animate(movingCard, "x", target.x, drawAnimationSpeed, ease.inovershoot)
	table.insert(hand, table.remove(drawPile, 1))
	movingCard.enabled = false
end

function plateCardFromHand(handIndex)
	movingCard.enabled = true
	local movedCard = hand[handIndex]
	hand[handIndex] = nil
	print(dump(hand))
	local startingCard = 'card'..handIndex
	movingCard.x = ui[startingCard].x
	movingCard.y = ui[startingCard].y

	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.plateCards.x, ui.plateCards.y},
		drawAnimationSpeed, ease.inovershoot
	)
	table.insert(currentPlate, movedCard)
	movingCard.enabled = false
end

function drawThree()
	-- draw three cards from drawPile to hand
	async(routines, function()
		drawFromDeck()
		drawFromDeck()
		drawFromDeck()

		wait(0.5)

		-- check if any are bread (these automatically are played)
		if hand[1] == 1 then
			plateCardFromHand(1)
		end
		if hand[2] == 1 then
			plateCardFromHand(2)
		end
		if hand[3] == 1 then
			plateCardFromHand(3)
		end
	end)
end

function love.load()
	print('tts: Created by Jesse Jurman.')

	-- draw three at the start of the game
	drawThree()
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

	-- draw cards in hand
	local hasCardsInHand = hand[1] or hand[2] or hand[3]
	if hasCardsInHand then
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
	end

	-- draw actions if not
	if not hasCardsInHand then
		love.graphics.setColor(0.98, 0.98, 0.47)
		love.graphics.rectangle("line", ui.actionDraw.x, ui.actionDraw.y, ui.actionDraw.width, ui.actionDraw.height)
		love.graphics.printf(ui.actionDraw.label, ui.actionDraw.x, ui.actionDraw.y + ui.actionDraw.height, ui.actionDraw.width, 'center')

		love.graphics.rectangle("line", ui.actionNewPlate.x, ui.actionNewPlate.y, ui.actionNewPlate.width, ui.actionNewPlate.height)
		love.graphics.printf(ui.actionNewPlate.label, ui.actionNewPlate.x, ui.actionNewPlate.y + ui.actionNewPlate.height, ui.actionNewPlate.width, 'center')
	end

	-- draw drawPile and discardPile
	love.graphics.setColor(0.43, 0.43, 0.47)
	love.graphics.rectangle("line", ui.drawPile.x, ui.drawPile.y, ui.drawPile.width, ui.drawPile.height)
	love.graphics.printf(#drawPile, ui.drawPile.x, ui.drawPile.y + ui.drawPile.height/2, ui.drawPile.width, 'center')
	love.graphics.printf(countValueInTopOfPile(drawPile, #drawPile, 1)..' Bread Slices', ui.drawPile.x, ui.drawPile.y + ui.drawPile.height, ui.drawPile.width, 'center')

	love.graphics.rectangle("line", ui.discardPile.x, ui.discardPile.y, ui.discardPile.width, ui.discardPile.height)
	love.graphics.printf(#discardPile, ui.discardPile.x, ui.discardPile.y + ui.discardPile.height/2, ui.discardPile.width, 'center')
	love.graphics.printf(countValueInTopOfPile(discardPile, #discardPile, 1)..' Bread Slices', ui.discardPile.x, ui.discardPile.y + ui.discardPile.height, ui.discardPile.width, 'center')

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	love.graphics.rectangle("line", cursor.x, cursor.y, cursor.width, cursor.height)

	-- draw plated cards
	for cardIndex, plateCard in ipairs(currentPlate) do
		love.graphics.setColor(0.43, 0.98, 0.47)
		love.graphics.rectangle("line", ui.plateCards.x, ui.plateCards.y, ui.plateCards.width, ui.plateCards.height)
		love.graphics.printf(cardDetails[plateCard].label, ui.plateCards.x, ui.plateCards.y + ui.plateCards.height + (cardIndex * 12), ui.plateCards.width, 'center')
	end

	-- draw any cards that are moving
	if movingCard.enabled then
		love.graphics.setColor(0.43, 0.98, 0.47)
		love.graphics.rectangle("line", movingCard.x, movingCard.y, cardSize.width, cardSize.height)
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
	x = "select",
	space = "select",
	["return"] = "select",
}

local player_remap = {}

function remap(key)
	key = hardware_remap[key] or key
	key = game_remap[key] or key
	key = player_remap[key] or key

	return key
end

function updateSelection(target)
	selection = target
	async(routines, function()
		animateMany(cursor,
			{"x", "y", "width", "height"},
			{ui[selection].x, ui[selection].y, ui[selection].width, ui[selection].height},
			navAnimationSpeed, ease.inovershoot
		)
	end)

	local hasCardsInHand = hand[1] or hand[2] or hand[3]
	local navKey = hasCardsInHand and 'withHand' or 'withActions'

	local navDirections = 'Use the following keys to change selection: '
	local dirLabel = ''
	if ui[selection].nav[navKey].up then
		dirLabel = ui[ui[selection].nav[navKey].up].label
		navDirections = navDirections..' up, '..dirLabel..'; '
	end
	if ui[selection].nav[navKey].down then
		dirLabel = ui[ui[selection].nav[navKey].down].label
		navDirections = navDirections..' down, '..dirLabel..'; '
	end
	if ui[selection].nav[navKey].left then
		dirLabel = ui[ui[selection].nav[navKey].left].label
		navDirections = navDirections..' left, '..dirLabel..'; '
	end
	if ui[selection].nav[navKey].right then
		dirLabel = ui[ui[selection].nav[navKey].right].label
		navDirections = navDirections..' right, '..dirLabel..'. '
	end
	dirLabel = ui[selection].label
	ttsText = dirLabel..' selected. '..navDirections
	print('tts: '..ttsText)
end

function love.keypressed(rawKey)
	key = remap(rawKey)
	print('raw, '..rawKey..' remapped, '..key)

	local hasCardsInHand = hand[1] or hand[2] or hand[3]
	local navKey = hasCardsInHand and 'withHand' or 'withActions'

	local isCardSelected = selection == 'card1' or selection == 'card2' or selection == 'card3'
	local isActionSelected = selection == 'actionDraw' or selection == 'actionNewPlate'

	-- navigation
	if key == 'down' or key == 'up' or key == 'left' or key == 'right' then
		local nextSelection = ui[selection].nav[navKey][key]
		if nextSelection then
			-- if they press up or down, make sure they can get back to the previous option
			-- don't do this if they are in a hand selection
			if key == 'up' then
				ui[nextSelection].nav[navKey].down = selection
			elseif key == 'down' then
				ui[nextSelection].nav[navKey].up = selection
			end

			updateSelection(nextSelection)
		end
	end

	-- card selection
	if key == 'select' and isCardSelected then
		async(routines, function()
			if selection == 'card1' then
				plateCardFromHand(1)
			end
			if selection == 'card2' then
				plateCardFromHand(2)
			end
			if selection == 'card3' then
				plateCardFromHand(3)
			end

			-- if hand is empty, update selection
			local handIsEmpty = hand[1] == nil and hand[2] == nil and hand[3] == nil
			if handIsEmpty then
				updateSelection('actionDraw')
			end
		end)
	end

	-- action selection
	if key == 'select' and isActionSelected then
		async(routines, function()
			if selection == 'actionDraw' then
				-- we don't actually have to do anything here, we'll draw at the end anyways
			end
			if selection == 'actionNewPlate' then
				local completedPlate = currentPlate
				currentPlate = {}
				-- TODO animate plate to completed plates
				table.insert(completedPlates, completedPlate)
			end

			-- draw three now (we always do this)
			drawThree()

			-- reset the selection to hand
			updateSelection('card1')
		end)
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
