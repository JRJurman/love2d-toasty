local json = require("json")
require('shuffle')

require('save')
require('animation')
local ease = require('ease')

require('cardDetails')
require('ui')
require('drawCard')
require('drawFatRect')
require('deckFunctions')
require('remapFunctions')
require('recipeDetails')
require('recipeFunctions')
require('ttsFunctions')

require('FontFunctions')
DebuggingScreen = require('DebuggingScreen')

love.graphics.setFont(getFont(30))

local deck = {
	1, 1, 1, 1, 1,
	2, 2, 3, 3, 4, 4,
	5, 5, 6, 6, 7, 7,
	8, 8, 9, 9, 9, 9,
}

local drawPile = {}

local discardPile = {}
local hand = {}
local currentPlate = {}
local completedPlates = {}

local modalCards = {}
local modalActions = {}

local modalActive = false
local modalExpanded = false
local isDrawing = true
local isPlating = false

local selection = 'deck'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local roundGoal = 15

local	routines = {}

local selectionText = ''
local drawnSelectionText = ''
local navText = ''
local drawnNavText = ''

gameSeed = 0
seed = 0

local animationScale = 0.25
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

function drawFromDeck(handIndex, drawIndex)
	isDrawing = true
	drawIndex = drawIndex or 1
	local targetX = ui['card'..handIndex].x
	local targetY = ui['card'..handIndex].y

	-- don't draw if the draw pile is empty
	if #drawPile == 0 then
		isDrawing = false
		return
	end

	movingCard.enabled = true
	movingCard.x = ui.drawPile.x
	movingCard.y = ui.drawPile.y
	animateMany(movingCard, {"x", "y"}, {targetX, targetY}, drawAnimationSpeed * animationScale, ease.inovershoot)
	hand[handIndex] = table.remove(drawPile, drawIndex)
	movingCard.enabled = false

	-- if this is bread, play it immediately
	local drawnCardDetails = cardDetails[hand[handIndex]]
	if drawnCardDetails.onDraw then
		if drawnCardDetails.onDraw[1] == 'plate' then
			wait(0.5 * animationScale)
			plateCardFromHand(handIndex, targetX, targetY)
		end
	end

	isDrawing = false
end

function plateCardFromHand(handIndex, startX, startY)
	isPlating = true
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
		drawAnimationSpeed * animationScale, ease.inovershoot
	)
	table.insert(currentPlate, movedCard)
	isPlating = false
	movingCard.enabled = false
end

function updateSelectionAfterPlayOrDraw()
	local handIsEmpty = hand[1] == nil and hand[2] == nil and hand[3] == nil
	local plateIsEmpty = #currentPlate == 0
	-- if hand is empty, modal isn't active, and plate is empty,
	-- just draw three cards (we can't start a new plate anyways)
	if handIsEmpty and not modalActive and plateIsEmpty then
		drawThree()
		return;
	end

	-- if we now have an empty hand (and the modal isn't active), change the selection to actions
	-- (this can happen for draw if the last hand has all bread)
	if handIsEmpty and not modalActive then
		updateSelection('actionDraw')
		return;
	end

	-- if we aren't already selecting a card, reset to card1
	if selection ~= 'card1' and selection ~= 'card2' and selection ~= 'card3' then
		updateSelection('card1')
	end
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
		drawAnimationSpeed * animationScale, ease.inovershoot
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

		updateSelectionAfterPlayOrDraw()
	end)
end

function love.load()
	print('tts: Created by Jesse Jurman.')

	local savedSeed = loadGameData('seed.json')

	-- shuffle and draw three at the start of the game
	async(routines, function()
		wait(1 * animationScale) -- wait one second to help generate a more random seed
		if savedSeed then
			gameSeed = savedSeed.seed
		else
			gameSeed = seed
		end
		print('seed: '..gameSeed)
		math.randomseed(gameSeed)
		drawPile = startingShuffle(deck)
		print('deck size: '..#deck)
		print('drawPile size: '..#drawPile)
		drawThree()
	end)
end

function love.update(dt)
	seed = seed + dt*1000
	updateAnimations(routines, dt)
end

function love.draw()
	love.graphics.clear()
	love.graphics.setFont(getFont(30))

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
			drawCard(hand[1], ui.card1.x, ui.card1.y)
		end
		if hand[2] then
			drawCard(hand[2], ui.card2.x, ui.card2.y)
		end
		if hand[3] then
			drawCard(hand[3], ui.card3.x, ui.card3.y)
		end
	end

	-- draw actions if we don't have cards or an active modal, and we aren't drawing or plating
	if not hasCardsInHand and not modalActive and not isDrawing and not isPlating then
		love.graphics.setColor(0.98, 0.98, 0.47)
		love.graphics.rectangle("line", ui.actionDraw.x, ui.actionDraw.y, ui.actionDraw.width, ui.actionDraw.height)
		love.graphics.printf(ui.actionDraw.label, ui.actionDraw.x, ui.actionDraw.y + ui.actionDraw.height, ui.actionDraw.width, 'center')

		love.graphics.rectangle("line", ui.actionNewPlate.x, ui.actionNewPlate.y, ui.actionNewPlate.width, ui.actionNewPlate.height)
		love.graphics.printf(ui.actionNewPlate.label, ui.actionNewPlate.x, ui.actionNewPlate.y + ui.actionNewPlate.height, ui.actionNewPlate.width, 'center')
	end

	-- draw drawPile and discardPile
	love.graphics.setColor(0.43, 0.43, 0.47)
	love.graphics.rectangle("line", ui.drawPile.x, ui.drawPile.y, ui.drawPile.width, ui.drawPile.height)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#drawPile, ui.drawPile.x, ui.drawPile.y + ui.drawPile.height/4, ui.drawPile.width, 'center')
	love.graphics.setFont(getFont(30))
	love.graphics.printf(countValueInTopOfPile(drawPile, #drawPile, 1)..' Bread Slices', ui.drawPile.x, ui.drawPile.y + ui.drawPile.height, ui.drawPile.width, 'center')

	love.graphics.rectangle("line", ui.discardPile.x, ui.discardPile.y, ui.discardPile.width, ui.discardPile.height)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#discardPile, ui.discardPile.x, ui.discardPile.y + ui.discardPile.height/4, ui.discardPile.width, 'center')
	love.graphics.setFont(getFont(30))
	love.graphics.printf(countValueInTopOfPile(discardPile, #discardPile, 1)..' Bread Slices', ui.discardPile.x, ui.discardPile.y + ui.discardPile.height, ui.discardPile.width, 'center')

	-- draw plated cards
	for cardIndex, plateCard in ipairs(currentPlate) do
		drawRotatedCard(plateCard, ui.plateCards.x, ui.plateCards.y, cardIndex)
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
	local typeOfPlate = getTypeOfPlate(currentPlate)
	local currentPlateRawScore = getRawScoreForPlate(currentPlate)
	local breadOnPlate = countValueInTopOfPile(currentPlate, #currentPlate, 1)
	love.graphics.setColor(0.98, 0.98, 0.98)
	love.graphics.rectangle("line", ui.plateScore.x, ui.plateScore.y, ui.plateScore.width, ui.plateScore.height)
	love.graphics.setFont(getFont(90))

	local scoreLabel = '+'..currentPlateRawScore
	-- if this is fat or ultimate toast, show the multiplier
	if typeOfPlate < 1 then
		scoreLabel = '0'
	elseif (typeOfPlate > 1) then
		scoreLabel = scoreLabel..' x'..typeOfPlate
	end
	love.graphics.printf(scoreLabel, ui.plateScore.x + 10, ui.plateScore.y, ui.plateScore.width - 20, 'center')

	-- print type of plate
	love.graphics.setFont(getFont(50))
	local scoreDescription = typesOfPlates[typeOfPlate]
	local plateRecipe = getCompletedRecipeOnPlate(currentPlate)
	if plateRecipe then
		scoreDescription = recipeDetails[plateRecipe].label..' (+'..recipeDetails[plateRecipe].points..')'
	end
	love.graphics.printf(scoreDescription, ui.plateScore.x, ui.plateScore.y + 100, ui.plateScore.width, 'center')

	-- print the points from toppings


	-- draw round score
	love.graphics.setFont(getFont(90))
	local roundScore = getScoreForPlate(currentPlate)
	for plateIndex, completedPlate in ipairs(completedPlates) do
		roundScore = roundScore + getScoreForPlate(completedPlate)
	end
	love.graphics.rectangle("line", ui.score.x, ui.score.y, ui.score.width, ui.score.height)
	love.graphics.printf(roundScore..'/'..roundGoal, ui.score.x + 10, ui.score.y, ui.score.width - 20, 'center')
	love.graphics.setFont(getFont(30))

	-- always draw the modal (it is sometimes offscreen)
	love.graphics.setColor( 0, 0, 0)
	love.graphics.rectangle("fill", ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)
	love.graphics.setColor(0.98, 0.47, 0.98)
	love.graphics.rectangle("line", ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)

	-- draw any cards on the modal
	if modalCards[1] then
		local cardX = ui.modal.x + ui.modalCard1.x
		local cardY = ui.modal.y + ui.modalCard1.y
		drawCard(modalCards[1], cardX, cardY)
	end
	if modalCards[2] then
		local cardX = ui.modal.x + ui.modalCard2.x
		local cardY = ui.modal.y + ui.modalCard2.y
		drawCard(modalCards[2], cardX, cardY)
	end
	if modalCards[3] then
		local cardX = ui.modal.x + ui.modalCard3.x
		local cardY = ui.modal.y + ui.modalCard3.y
		drawCard(modalCards[3], cardX, cardY)
	end

	-- draw any actions on the modal
	if modalActions[1] then
		local actionX = ui.modal.x + ui.modalAction1.x
		local actionY = ui.modal.y + ui.modalAction1.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalAction1.width, ui.modalAction1.height)
		love.graphics.printf(modalActions[1], actionX, actionY + ui.modalAction1.height/2, ui.modalAction1.width, 'center')
	end
	if modalActions[2] then
		local actionX = ui.modal.x + ui.modalAction2.x
		local actionY = ui.modal.y + ui.modalAction2.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalAction2.width, ui.modalAction2.height)
		love.graphics.printf(modalActions[2], actionX, actionY + ui.modalAction2.height/2, ui.modalAction2.width, 'center')
	end

	-- draw any cards that are moving
	if movingCard.enabled then
		love.graphics.setColor(0.43, 0.98, 0.47)
		drawCard(nil, movingCard.x, movingCard.y)
	end

	-- draw the readout
	love.graphics.setColor(0.87, 0.87, 0.97)
	love.graphics.rectangle("line", ui.readout.x, ui.readout.y, ui.readout.width, ui.readout.height)
	love.graphics.printf(selectionText, ui.readout.x + 10, ui.readout.y, ui.readout.width - 20, 'center')
	love.graphics.printf(navText, ui.readout.x + 10, ui.readout.y + (ui.readout.height*0.75), ui.readout.width - 20, 'center')

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	drawFatRect('outset', 5, cursor.x, cursor.y, cursor.width, cursor.height)

	DebuggingScreen.draw()

	-- update the screen reader (if text changed)
	-- (we don't do this every frame, because it would overwhelm the dev console)
	if drawnSelectionText ~= selectionText or drawnNavText ~= navText then
		print('tts: '..selectionText..'. '..navText)
		drawnSelectionText = selectionText
		drawnNavText = navText
	end
end

function expandModal()
	-- flatten cursor to the top
	cursor = { x = 0, y = 0, width = 800, height = 0}

	ui.modal.y = ui.offScreenModal.y
	animate(ui.modal, 'y', ui.onScreenModal.y, navAnimationSpeed * animationScale, ease.outovershoot)
	modalExpanded = true
end

function minimizeModal()
	-- flatten cursor to the top
	cursor = { x = 0, y = 0, width = 800, height = 0}

	ui.modal.y = ui.onScreenModal.y
	animate(ui.modal, 'y', ui.offScreenModal.y, navAnimationSpeed * animationScale, ease.inovershoot)
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
			navAnimationSpeed * animationScale, ease.inovershoot
		)
	end)

	local navKey = getNavKey()

	local selectionDetails = ''
	if selection == 'plate' then
		-- for debugging, just print all cards on plate
		for plateIndex, ingredient in ipairs(currentPlate) do
			print(plateIndex..': '..cardDetails[ingredient].label)
		end

		-- write down all the ingredients on the plate
		selectionDetails = 'Current Plate, '

		-- write down how many undiscovered recipes (and what discovered recipes) we have
		local plateRecipes = getPotentialRecipeOnPlate(currentPlate)
		local discoveredPlateRecipes, undiscoveredPlateRecipes = splitDiscoveredAndUndiscoveredRecipes(plateRecipes)
		if #undiscoveredPlateRecipes > 0 then
			selectionDetails = selectionDetails..'. '..#undiscoveredPlateRecipes..' undiscovered recipes.'
		end
		if #discoveredPlateRecipes > 0 then
			selectionDetails = selectionDetails..'. '..#discoveredPlateRecipes..' discovered recipes: '
			for _, discoveredPlateRecipes in ipairs(discoveredPlateRecipes) do
				-- TODO add print for discovered recipes
			end
		end
	end
	if selection == 'deck' then
		-- for debugging, just print all cards remaining in deck
		for drawIndex, ingredient in ipairs(drawPile) do
			print(drawIndex..': '..cardDetails[ingredient].label)
		end
	end

	selectionText = getSelectionInstruction(selection, hand, modalCards)
	navText = getNavInstructions(selection, navKey)
end

function love.keypressed(rawKey)
	DebuggingScreen.keypressed(rawKey)

	key = remap(rawKey)
	print('raw, '..rawKey..' remapped, '..key)

	local navKey = getNavKey()

	-- if we are drawing or plating, don't allow other actions
	if isDrawing or isPlating then
		return
	end

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

	-- if we are selecting a non-modal card and modal is not active, trigger the onPlay
	local isNonModalCard = ui[selection].card and not ui[selection].modal
	if key == 'select' and isNonModalCard and not modalActive then
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
					modalCards = {}
					modalActions = {}
					for previewIndex=1, previewCount do
						if drawPile[previewIndex] then
							modalCards[previewIndex] = drawPile[previewIndex]
						end
					end
					for actionIndex, action in ipairs(playedCardDetails.onPlay.actions) do
						table.insert(modalActions, action)
					end
					modalActive = true

					-- immediately set the modal as the selection
					expandModal()
					updateSelection('modalCard1')
				end
			else
				updateSelectionAfterPlayOrDraw()
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
			-- first update to the target selection
			-- but, if our hand is empty (it was bread), reset it
			updateSelection(targetSelection)
			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are choosing to skip or close the modal action...
	local isSelectingModalAction = ui[selection].modal and ui[selection].action
	local modalAction = isSelectingModalAction and modalActions[ui[selection].actionIndex]
	local isSelectingSkip = isSelectingModalAction and modalAction == 'skip' or modalAction == 'close'
	if key == 'select' and isSelectingSkip then
		async(routines, function()
			minimizeModal()
			modalActive = false

			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are choosing to shuffle cards
	local isSelectingShuffle = isSelectingModalAction and modalActions[ui[selection].actionIndex] == 'shuffle'
	if key == 'select' and isSelectingShuffle then
		async(routines, function()
			minimizeModal()
			modalActive = false
			drawPile = safeShuffle(drawPile)

			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- non-modal action selection
	if key == 'select' and ui[selection].action then
		async(routines, function()
			if selection == 'actionDraw' then
				drawThree()
			end
			if selection == 'actionNewPlate' then
				local completedPlate = currentPlate
				currentPlate = {}
				-- TODO animate plate to completed plates
				table.insert(completedPlates, completedPlate)
				drawThree()
			end
		end)
	end

	-- repeat text if r was pressed
	if key == "r" then
		async(routines, function()
			print('tts: repeating...')
			wait(0.5 * animationScale)
			print('tts: '..navText)
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
