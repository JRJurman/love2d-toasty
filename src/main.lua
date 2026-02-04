local json = require("json")
require('shuffle')

require('save')
require('animation')
local ease = require('ease')

require('cardDetails')
require('ui')

local DebuggingScreen = require('DebuggingScreen')

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

local discardPile = {}
local hand = {}
local currentPlate = {}
local completedPlates = {}

local modalCards = {}
local modalActions = {}

local modalActive = false
local modalExpanded = false

local selection = 'deck'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local roundGoal = 15

local	routines = {}
local ttsText = ''

gameSeed = 0
seed = 0

local navAnimationSpeed = 0.35
local drawAnimationSpeed = 0.8

local movingCard = {x = ui.drawPile.x, y = ui.drawPile.y, enabled = false }

function getNavKey()
	local hasCardsInHand = hand[1] or hand[2] or hand[3]

	if modalActive then
		return 'withModal'
	elseif hasCardsInHand then
		return 'withHand'
	else
		return 'withActions'
	end
end

function getScoreForPlate(plate)
	local plateScore = 0
	-- need 3 ingredients to start scoring (after bread)
	if #plate < 4 then
		return 0
	end

	for ingredientIndex, ingredient in ipairs(plate) do
		plateScore = plateScore + cardDetails[ingredient].points
	end
	return plateScore
end

function drawFromDeck(handIndex, drawIndex)
	drawIndex = drawIndex or 1
	local targetX = ui['card'..handIndex].x
	local targetY = ui['card'..handIndex].y

	-- don't draw if the draw pile is empty
	if #drawPile == 0 then
		return
	end

	movingCard.enabled = true
	movingCard.x = ui.drawPile.x
	movingCard.y = ui.drawPile.y
	animateMany(movingCard, {"x", "y"}, {targetX, targetY}, drawAnimationSpeed, ease.inovershoot)
	hand[handIndex] = table.remove(drawPile, drawIndex)
	movingCard.enabled = false

	-- if this is bread, play it immediately
	local drawnCardDetails = cardDetails[hand[handIndex]]
	if drawnCardDetails.onDraw then
		if drawnCardDetails.onDraw[1] == 'plate' then
			wait(0.5)
			plateCardFromHand(handIndex, targetX, targetY)
		end
	end
end

function plateCardFromHand(handIndex, startX, startY)
	movingCard.enabled = true
	local movedCard = hand[handIndex]
	hand[handIndex] = nil
	local startingCard = 'card'..handIndex
	movingCard.x = startX
	movingCard.y = startY

	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.plateCards.x, ui.plateCards.y},
		drawAnimationSpeed, ease.inovershoot
	)
	table.insert(currentPlate, movedCard)
	movingCard.enabled = false
end

function discardCardFromHand(handIndex, startX, startY)
	movingCard.enabled = true
	local movedCard = hand[handIndex]
	hand[handIndex] = nil
	local startingCard = 'card'..handIndex
	movingCard.x = startX
	movingCard.y = startY

	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.discardPile.x, ui.discardPile.y},
		drawAnimationSpeed, ease.inovershoot
	)
	table.insert(discardPile, movedCard)
	movingCard.enabled = false
end

function drawThree()
	-- draw three cards from drawPile to hand
	async(routines, function()
		drawFromDeck(1)
		drawFromDeck(2)
		drawFromDeck(3)

		wait(0.5)

		-- if we now have an empty hand, change the selection to actions
		-- (this can happen if the last hand has all bread)
		local handIsEmpty = hand[1] == nil and hand[2] == nil and hand[3] == nil
		if handIsEmpty then
			updateSelection('actionDraw')
		end
	end)
end

function love.load()
	print('tts: Created by Jesse Jurman.')

	local savedSeed = loadGameData('seed.json')

	-- shuffle and draw three at the start of the game
	async(routines, function()
		wait(1) -- wait one second to help generate a more random seed
		if savedSeed then
			gameSeed = savedSeed.seed
		else
			gameSeed = seed
		end
		print('seed: '..gameSeed)
		math.randomseed(gameSeed)
		shuffleDrawPile()
		drawThree()
	end)
end

function love.update(dt)
	seed = seed + dt*1000
	updateAnimations(routines, dt)
end

function love.draw()
	love.graphics.clear()

	-- draw the UI elements
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.hand.x, ui.hand.y, ui.hand.width, ui.hand.height)
	love.graphics.rectangle("line", ui.served.x, ui.served.y, ui.served.width, ui.served.height)
	love.graphics.rectangle("line", ui.plate.x, ui.plate.y, ui.plate.width, ui.plate.height)
	love.graphics.rectangle("line", ui.deck.x, ui.deck.y, ui.deck.width, ui.deck.height)

	-- if we have an active modal, draw the modal action
	if modalActive then
		love.graphics.setColor(0.98, 0.98, 0.47)
		love.graphics.rectangle("line", ui.actionModal.x, ui.actionModal.y, ui.actionModal.width, ui.actionModal.height)
		love.graphics.printf(ui.actionModal.label, ui.actionModal.x, ui.actionModal.y, ui.actionModal.width, 'center')
	end

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

	-- draw actions if we don't have cards or an active modal
	if not hasCardsInHand and not modalActive then
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

	-- draw plated cards
	for cardIndex, plateCard in ipairs(currentPlate) do
		love.graphics.setColor(0.43, 0.98, 0.47)
		love.graphics.rectangle("line", ui.plateCards.x, ui.plateCards.y, ui.plateCards.width, ui.plateCards.height)
		love.graphics.printf(cardDetails[plateCard].label, ui.plateCards.x, ui.plateCards.y + ui.plateCards.height + (cardIndex * 12), ui.plateCards.width, 'center')
	end

	-- draw completed plates
	for plateIndex, completedPlate in ipairs(completedPlates) do
		love.graphics.setColor(0.98, 0.47, 0.98)
		local plateX = ui.completedPlates.x
		local plateY = ui.completedPlates.y - (40 * plateIndex)
		local plateScore = getScoreForPlate(completedPlate)
		love.graphics.rectangle("line", plateX, plateY, ui.completedPlates.width, ui.completedPlates.height)
		love.graphics.printf('+'..plateScore, plateX, plateY + ui.completedPlates.height * (5 / 6), ui.completedPlates.width, 'center')
	end

	-- draw the current plate score
	local currentPlateScore = getScoreForPlate(currentPlate)
	local scoreDescription = ''
	if #currentPlate == 0 then
		scoreDescription = 'Start toast by drawing bread!'
	elseif #currentPlate < 4 then
		scoreDescription = 'You need three ingredients before you can score for this plate.'
	end
	love.graphics.setColor(0.98, 0.98, 0.98)
	love.graphics.rectangle("line", ui.plateScore.x, ui.plateScore.y, ui.plateScore.width, ui.plateScore.height)
	love.graphics.printf('+'..currentPlateScore, ui.plateScore.x + 10, ui.plateScore.y + ui.plateScore.height/2, ui.plateScore.width - 20, 'center')
	love.graphics.printf(scoreDescription, ui.plateScore.x + 10, ui.plateScore.y + ui.plateScore.height/2 + 12, ui.plateScore.width - 20, 'center')

		-- draw round score
	local roundScore = currentPlateScore
	for plateIndex, completedPlate in ipairs(completedPlates) do
		roundScore = roundScore + getScoreForPlate(completedPlate)
	end
	love.graphics.rectangle("line", ui.score.x, ui.score.y, ui.score.width, ui.score.height)
	love.graphics.printf(roundScore..'/'..roundGoal, ui.score.x + 10, ui.score.y + ui.score.height/2, ui.score.width - 20, 'center')

	-- always draw the modal (it is sometimes offscreen)
	love.graphics.setColor( 0, 0, 0)
	love.graphics.rectangle("fill", ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)
	love.graphics.setColor(0.98, 0.47, 0.98)
	love.graphics.rectangle("line", ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)

	-- draw any cards on the modal
	if modalCards[1] then
		local cardX = ui.modal.x + ui.modalCard1.x
		local cardY = ui.modal.y + ui.modalCard1.y
		love.graphics.rectangle("line", cardX, cardY, ui.modalCard1.width, ui.modalCard1.height)
		love.graphics.printf(cardDetails[modalCards[1]].label, cardX, cardY + ui.modalCard1.height, ui.modalCard1.width, 'center')
	end
	if modalCards[2] then
		local cardX = ui.modal.x + ui.modalCard2.x
		local cardY = ui.modal.y + ui.modalCard2.y
		love.graphics.rectangle("line", cardX, cardY, ui.modalCard2.width, ui.modalCard2.height)
		love.graphics.printf(cardDetails[modalCards[2]].label, cardX, cardY + ui.modalCard2.height, ui.modalCard2.width, 'center')
	end
	if modalCards[3] then
		local cardX = ui.modal.x + ui.modalCard3.x
		local cardY = ui.modal.y + ui.modalCard3.y
		love.graphics.rectangle("line", cardX, cardY, ui.modalCard3.width, ui.modalCard3.height)
		love.graphics.printf(cardDetails[modalCards[3]].label, cardX, cardY + ui.modalCard3.height, ui.modalCard3.width, 'center')
	end

	-- draw any actions on the modal
	if modalActions[1] then
		local actionX = ui.modal.x + ui.modalAction1.x
		local actionY = ui.modal.y + ui.modalAction1.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalAction1.width, ui.modalAction1.height)
		love.graphics.printf(modalActions[1], actionX, actionY + ui.modalAction1.height, ui.modalAction1.width, 'center')
	end
	if modalActions[2] then
		local actionX = ui.modal.x + ui.modalAction2.x
		local actionY = ui.modal.y + ui.modalAction2.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalAction2.width, ui.modalAction2.height)
		love.graphics.printf(modalActions[2], actionX, actionY + ui.modalAction2.height, ui.modalAction2.width, 'center')
	end

	-- draw any cards that are moving
	if movingCard.enabled then
		love.graphics.setColor(0.43, 0.98, 0.47)
		love.graphics.rectangle("line", movingCard.x, movingCard.y, cardSize.width, cardSize.height)
	end

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	love.graphics.rectangle("line", cursor.x, cursor.y, cursor.width, cursor.height)

	DebuggingScreen.draw()
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

function expandModal()
	-- flatten cursor to the top
	cursor = { x = 0, y = 0, width = 800, height = 0}

	ui.modal.y = ui.offScreenModal.y
	animate(ui.modal, 'y', ui.onScreenModal.y, navAnimationSpeed, ease.outovershoot)
	modalExpanded = true
end

function minimizeModal()
	-- flatten cursor to the top
	cursor = { x = 0, y = 0, width = 800, height = 0}

	ui.modal.y = ui.onScreenModal.y
	animate(ui.modal, 'y', ui.offScreenModal.y, navAnimationSpeed, ease.inovershoot)
	modalExpanded = false
end

function updateSelection(target)
	selection = target
	async(routines, function()
		local targetX = ui[selection].x
		local targetY = ui[selection].y
		-- if we are in a modal, modify the target positions respectively
		if (ui[selection].modal) then
			targetX = targetX + ui.modal.x
			targetY = targetY + ui.modal.y
		end
		animateMany(cursor,
			{"x", "y", "width", "height"},
			{targetX, targetY, ui[selection].width, ui[selection].height},
			navAnimationSpeed, ease.inovershoot
		)
	end)

	local navKey = getNavKey()

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
	DebuggingScreen.keypressed(rawKey)

	key = remap(rawKey)
	print('raw, '..rawKey..' remapped, '..key)

	local navKey = getNavKey()

	local isCardSelected = selection == 'card1' or selection == 'card2' or selection == 'card3'
	local isActionSelected = selection == 'actionDraw' or selection == 'actionNewPlate'

	-- navigation
	if key == 'down' or key == 'up' or key == 'left' or key == 'right' then
		async(routines, function()
			local nextSelection = ui[selection].nav[navKey][key]

			-- if we moved in or out of the modal, expand or minimize it
			if nextSelection then
				-- if we were on the modal, and now we are not, hide the modal
				if modalExpanded and not ui[nextSelection].modal then
					minimizeModal()
				end

				-- if we were not on the modal, and now we are, show the modal
				if not modalExpanded and ui[nextSelection].modal then
					expandModal()
				end
			end

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
		end)
	end

	-- card selection
	if key == 'select' and isCardSelected then
		async(routines, function()
			-- get handIndex based on selection
			local handIndex = ui[selection].handIndex
			local playedCardDetails = cardDetails[hand[handIndex]]

			-- if there is bread on the plate, plate this card
			-- (otherwise, discard it)
			if currentPlate[1] == 1 then
				plateCardFromHand(handIndex, ui[selection].x, ui[selection].y)
			else
				discardCardFromHand(handIndex, ui[selection].x, ui[selection].y)
			end

			-- if there is a onPlay action, trigger that
			if playedCardDetails.onPlay then
				if playedCardDetails.onPlay.name == 'preview' then
					local previewCount = playedCardDetails.onPlay.previewCount
					for previewIndex=1, previewCount do
						modalCards[previewIndex] = drawPile[previewIndex]
					end
					for actionIndex, action in ipairs(playedCardDetails.onPlay.actions) do
						table.insert(modalActions, action)
					end
					modalActive = true
				end
			end

			-- if hand is empty, update selection
			local handIsEmpty = hand[1] == nil and hand[2] == nil and hand[3] == nil
			if handIsEmpty and not modalActive then
				updateSelection('actionDraw')
			end
		end)
	end

	-- if we are selecting a card and the modal action is pick, draw it
	local modalActionIsPick = modalActions[1] == 'pick'
	local isSelectingModalCard = ui[selection].modal and ui[selection].card
	if key == 'select' and isSelectingModalCard and modalActionIsPick then
		async(routines, function()
			local firstEmptyHandSlot = (hand[1] == nil and 1) or (hand[2] == nil and 2) or (hand[3] == nil and 3)
			local targetSelection = 'card'..firstEmptyHandSlot
			minimizeModal()
			modalActive = false
			drawFromDeck(firstEmptyHandSlot, ui[selection].drawIndex)
			updateSelection(targetSelection)
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

	-- testing saving / loading
	if key == 's' or key == 'w' then
		saveGameData('seed.json', { seed = gameSeed })
	end

	if key == 'c' then
		clearGameData('seed.json')
	end

	-- if we need to figure out where we are
	if key == '/' then
		print('selection: '..selection)
	end
end

function love.mousepressed(x, y)
	DebuggingScreen.mousepressed(x, y)
end

function love.mousereleased(x, y)
	DebuggingScreen.mousereleased(x, y)
end
