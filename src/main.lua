local json = require("json")
require('shuffle')
require('copy')

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
require('trackDetails')
require('actionDetails')

require('FontFunctions')
DebuggingScreen = require('DebuggingScreen')

love.graphics.setFont(getFont(30))

local startingDeck = {
	1, 1, 1, 1,
	2, 2, 3, 3,
	4, 5, 6, 7, 8, 9,
	10, 11, 12, 13, 14
}

local drawPile = {}

local discardPile = {}
local hand = {}
local currentPlate = {}
local completedPlates = {}

local modalCards = {}
local hasSeenInstructions = true

-- start the game with a start game modal
local hasStarted = false
local modalActive = true
local modalActions = {'start'}

local isDrawing = false
local isPlating = false

local selection = 'deck'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local roundGoal = 6
local roundNumber = 1
local roundMultiplier = 1.5
local completingRound = false

local	routines = {}

local selectionText = ''
local drawnSelectionText = ''
local navText = ''
local drawnNavText = ''
local intro, loop

-- we only say what the nav instructions are when someone first lands on a control
-- or when they've repeated the instruction
local heardNavInstructions = {}

local repeating = false

gameSeed = 0
seed = 0
masterVolume = 1
musicVolume = 1

local animationScale = 0.75
local navAnimationSpeed = 0.5
local drawAnimationSpeed = 1

local movingCard = {x = ui.drawPile.x, y = ui.drawPile.y, enabled = false }

function getHandSize()
	local currentHandSize = 0
	if hand[1] then
		currentHandSize = currentHandSize+1
	end
	if hand[2] then
		currentHandSize = currentHandSize+1
	end
	if hand[3] then
		currentHandSize = currentHandSize+1
	end
	return currentHandSize
end

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
	print('tts: '..cardDetails[hand[handIndex]].label)
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

	-- if we made a sandwich, immediately toss the plate
	local typeOfPlate = getTypeOfPlate(currentPlate)
	if typeOfPlate == -1 then
		print('tts: You made a Sandwich, no points! Tossing Plate.')
		wait(2.5 * animationScale)
		completePlate()
	end
end

function plateCardFromHand(handIndex, startX, startY)
	print('tts: plating '..cardDetails[hand[handIndex]].label)
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

	-- if this resolved in a discovered recipe, add that to our known recipes
	local recipe = getCompletedRecipeOnPlate(currentPlate)
	if recipe and discoveredRecipes[recipe] == nil then
		print('tts: New Recipe Discovered: '..recipeDetails[recipe].label..', '..recipeDetails[recipe].points..' points')
		discoveredRecipes[recipe] = true
		wait(3 * animationScale)
	end

	-- print current score
	local typeOfPlate = getTypeOfPlate(currentPlate)
	local typeOfPlateLabel = typesOfPlates[typeOfPlate]
	local currentPlateRawScore = getRawScoreForPlate(currentPlate)

	local scoreLabel = currentPlateRawScore..' points'
	local waitTime = 1.75
	if currentPlateRawScore == 1 then
		scoreLabel = '1 point'
	end
	-- if this is fat or ultimate toast, show the multiplier
	if typeOfPlate < 1 then
		scoreLabel = '0 points'
	elseif (typeOfPlate > 1) then
		scoreLabel = scoreLabel..' times '..typeOfPlate
		waitTime = waitTime + 0.75
	end
	-- if we are drawing our first bread, don't read out (it interrupts the draw readout)
	local isInitialBread = isDrawing and currentPlateRawScore == 1
	if not isInitialBread then
		print('tts: '..typeOfPlateLabel..', '..scoreLabel)
		wait(waitTime * animationScale)
	end

	-- if we have enough points, complete this plate, and start a new round
	local roundScore = getScoreForPlate(currentPlate) + getScoreForCompletedPlates()
	if roundScore >= roundGoal and not isDrawing then
		completePlate()
		return
	end

	-- update the selection text after plating (usually empty spot in hand)
	selectionText = getSelectionInstruction()
end

function updateSelectionAfterPlayOrDraw()
	local handIsEmpty = getHandSize() == 0
	local plateIsEmpty = #currentPlate == 0

	local breadInDeck = countValueInTopOfPile(drawPile, #drawPile, 1)
	local currentPlateRawScore = getRawScoreForPlate(currentPlate)
	-- if we are out of bread, and have no plate, end the game
	if breadInDeck == 0 and currentPlateRawScore == 0 then
		modalActions = {'restart'}
		modalCards = {}
		startModal()
		return
	end

	-- if hand is empty, modal isn't active, and plate is empty,
	-- just draw three cards (we can't start a new plate anyways)
	if handIsEmpty and not modalActive and plateIsEmpty then
		drawThree()
		return
	end

	-- if we now have an empty hand (and the modal isn't active), change the selection to actions
	-- (this can happen for draw if the last hand has all bread)
	if handIsEmpty and not modalActive then
		updateSelection('actionDraw')
		return
	end

	-- if we are already selecting a card, select that again, otherwise select card1
	if selection == 'card2' then
		updateSelection('card2')
	elseif selection == 'card3' then
		updateSelection('card3')
	else
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
		print('tts: drawing from deck')
		drawFromDeck(1)
		drawFromDeck(2)
		drawFromDeck(3)

		updateSelectionAfterPlayOrDraw()
	end)
end

function checkToLoopMusic()
	-- don't start looping until the game has started
	if not hasStarted then
		return
	end

	-- sometimes, if we've left the tab focus, we'll fail to start the loop
	if intro == nil and not loop:isPlaying() then
		loop:play()
	end

	-- when the intro is done, unset it and start the loop
	if intro and not intro:isPlaying() then
			intro = nil
			loop:play()
	end

end

function startNewGame()
	drawPile = copy(startingDeck)
	-- add 5 random ingredients
	for addIndex = 1, 5 do
		table.insert(drawPile, math.random(13) + 1)
	end

	-- shuffle the deck to make the start pile
	drawPile = startingShuffle(drawPile)
	hand = {}
	discardPile = {}
	currentPlate = {}
	completedPlates = {}
	roundGoal = 6
	roundNumber = 1
	hasStarted = false
	modalActions = {'start'}
	modalCards = {}
	startModal()
end

function love.load()
	print('tts: Created by Jesse Jurman.')

	local savedSeed = loadGameData('seed.json')

	-- seed loading and starting shuffle
	async(routines, function()
		wait(1 * animationScale) -- wait one second to help generate a more random seed
		if savedSeed then
			gameSeed = savedSeed.seed
		else
			gameSeed = seed
		end
		print('seed: '..gameSeed)
		math.randomseed(gameSeed)

		startNewGame()
	end)

	-- music loading (and looping)
	intro = love.audio.newSource("Assets/intro.ogg", "stream")
	loop  = love.audio.newSource("Assets/loop.ogg", "stream")
	intro:setVolume(masterVolume * musicVolume)
	loop:setVolume(masterVolume * musicVolume)
	loop:setLooping(true)
	-- we won't start the music until we hit start
end

function love.update(dt)
	seed = seed + dt*10000
	updateAnimations(routines, dt)
	checkToLoopMusic()
end

function love.draw()
	love.graphics.clear()
	love.graphics.setFont(getFont(30))

	-- draw cards in hand
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.hand.x, ui.hand.y, ui.hand.width, ui.hand.height)
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
		love.graphics.setFont(getFont(50))
		love.graphics.rectangle("line", ui.actionDraw.x, ui.actionDraw.y, ui.actionDraw.width, ui.actionDraw.height)
		love.graphics.printf("Draw Cards", ui.actionDraw.x, ui.actionDraw.y + 20, ui.actionDraw.width, 'center')

		love.graphics.rectangle("line", ui.actionNewPlate.x, ui.actionNewPlate.y, ui.actionNewPlate.width, ui.actionNewPlate.height)
		love.graphics.printf("New Plate", ui.actionNewPlate.x, ui.actionNewPlate.y + 20, ui.actionNewPlate.width, 'center')
	end

	-- draw drawPile and discardPile
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.deck.x, ui.deck.y, ui.deck.width, ui.deck.height)

	love.graphics.setColor(0.83, 0.83, 0.87)
	drawCard(0, ui.drawPile.x, ui.drawPile.y)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#drawPile, ui.drawPile.x, ui.drawPile.y + ui.drawPile.height/4, ui.drawPile.width, 'center')
	love.graphics.setFont(getFont(30))
	local breadInDeck = countValueInTopOfPile(drawPile, #drawPile, 1)
	love.graphics.printf(breadInDeck..' Bread Slices', ui.drawPile.x, ui.drawPile.y + ui.drawPile.height - 50, ui.drawPile.width, 'center')

	love.graphics.setColor(0.43, 0.43, 0.47)
	drawCard(-1, ui.discardPile.x, ui.discardPile.y)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#discardPile, ui.discardPile.x, ui.discardPile.y + ui.discardPile.height/4, ui.discardPile.width, 'center')

	-- draw plated cards
	-- (we only draw the top 5, since there can be rendering issues if we try to draw too many)
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.plate.x, ui.plate.y, ui.plate.width, ui.plate.height)
	if #currentPlate > 0 then
		for cardIndex=math.max(#currentPlate - 5, 1), #currentPlate do
			drawRotatedCard(currentPlate[cardIndex], ui.plateCards.x, ui.plateCards.y, cardIndex)
		end
	end

	-- draw completed plates as receipts
	love.graphics.setColor(0.43, 0.43, 0.47)
	love.graphics.rectangle("line", ui.served.x, ui.served.y, ui.served.width, ui.served.height)
	for plateIndex, completedPlate in ipairs(completedPlates) do
		love.graphics.setColor(0.98, 0.47, 0.98)
		local receiptWidth = 200
		local receiptHeight = 150
		local receiptX = ui.served.x + 60
		local receiptY = ui.served.y + ((plateIndex-1) * (receiptHeight*0.8))
		local plateScore = getScoreForPlate(completedPlate)
		love.graphics.rectangle("line", receiptX, receiptY, receiptWidth, receiptHeight)
		love.graphics.printf('+'..plateScore, receiptX, receiptY, receiptWidth, 'center')
	end

	-- draw the current plate score (if we aren't completing a round)
	love.graphics.setColor(0.98, 0.98, 0.98)
	love.graphics.rectangle("line", ui.plateScore.x, ui.plateScore.y, ui.plateScore.width, ui.plateScore.height)
	if not completingRound then
		local typeOfPlate = getTypeOfPlate(currentPlate)
		local currentPlateRawScore = getRawScoreForPlate(currentPlate)
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
	else
		love.graphics.setFont(getFont(90))
		love.graphics.printf('ROUND COMPLETE', ui.plateScore.x, ui.plateScore.y, ui.plateScore.width, 'center')
	end

	-- draw round score
	love.graphics.rectangle("line", ui.score.x, ui.score.y, ui.score.width, ui.score.height)
	love.graphics.setFont(getFont(30))
	love.graphics.printf('Round '..roundNumber, ui.score.x + 10, ui.score.y, ui.score.width - 20, 'center')
	love.graphics.setFont(getFont(90))
	local roundScore = getScoreForPlate(currentPlate) + getScoreForCompletedPlates()
	love.graphics.printf(roundScore..'/'..roundGoal, ui.score.x + 10, ui.score.y + 15, ui.score.width - 20, 'center')
	-- draw the number of discovered vs undiscovered in the round score
	love.graphics.setFont(getFont(30))
	local totalDiscoveredRecipes = getTotalDiscoveredRecipes()
	love.graphics.printf(totalDiscoveredRecipes..'/'..#recipeDetails..' Discovered Recipes', ui.score.x + 10, ui.score.y + 130, ui.score.width - 20, 'center')

	-- always draw the modal (it is sometimes offscreen)
	love.graphics.setColor( 0, 0, 0)
	love.graphics.rectangle("fill", ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)
	love.graphics.setColor(0.98, 0.47, 0.98)
	love.graphics.rectangle("line", ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)

	-- draw modal title
	if modalActions[1] then
		love.graphics.setFont(getFont(90))
		love.graphics.printf(actionDetails[modalActions[1]].modalTitle, ui.modal.x + 10, ui.modal.y, ui.modal.width - 20, 'center')
		if actionDetails[modalActions[1]].modalSubtitle then
			love.graphics.setFont(getFont(50))
			love.graphics.printf(actionDetails[modalActions[1]].modalSubtitle, ui.modal.x + 10, ui.modal.y + 95, ui.modal.width - 20, 'center')
		end
		love.graphics.setFont(getFont(30))
	end

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
	love.graphics.setFont(getFont(50))
	if modalActions[1] then
		local actionX = ui.modal.x + ui.modalAction1.x
		local actionY = ui.modal.y + ui.modalAction1.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalAction1.width, ui.modalAction1.height)
		love.graphics.printf(actionDetails[modalActions[1]].label, actionX, actionY + 20, ui.modalAction1.width, 'center')
	end
	if modalActions[2] then
		local actionX = ui.modal.x + ui.modalAction2.x
		local actionY = ui.modal.y + ui.modalAction2.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalAction2.width, ui.modalAction2.height)
		love.graphics.printf(actionDetails[modalActions[2]].label, actionX, actionY + 20, ui.modalAction2.width, 'center')
	end
	love.graphics.setFont(getFont(30))

	-- draw any cards that are moving
	if movingCard.enabled then
		love.graphics.setColor(0.43, 0.98, 0.47)
		drawCard(nil, movingCard.x, movingCard.y)
	end

	-- draw the readout
	love.graphics.setColor(0.87, 0.87, 0.97)
	love.graphics.rectangle("line", ui.readout.x, ui.readout.y, ui.readout.width, ui.readout.height)
	love.graphics.setFont(getFont(40))
	love.graphics.printf(selectionText..'\n\n'..navText, ui.readout.x + 10, ui.readout.y, ui.readout.width - 20, 'center')

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	drawFatRect('outset', 5, cursor.x, cursor.y, cursor.width, cursor.height)

	DebuggingScreen.draw()


	-- if we are animating, unset the selection and nav text
	-- (these will almost always be set by the animating function)
	local isAnimating = #routines > 0
	if isAnimating then
		drawnSelectionText = ''
		drawnNavText = ''
	end
	-- update the screen reader (if text changed)
	-- (we don't do this every frame, because it would overwhelm the dev console)
	-- only do this if we aren't animating right now
	if not isAnimating and (drawnSelectionText ~= selectionText or drawnNavText ~= navText) then
		local ttsText = string.gsub(selectionText..'. ', '\n', '; ')
		-- OLD: if we haven't hear the nav instructions, include that and update
		-- local shouldIncludeNavText = heardNavInstructions[selection] == nil and hasStarted
		-- NEW: if they are repeating, include nav text
		local shouldIncludeNavText = repeating and hasStarted
		if shouldIncludeNavText then
			repeating = false
			ttsText = string.gsub(selectionText..'. '..navText, '\n', '; ')
			heardNavInstructions[selection] = true
		end
		print('tts: '..ttsText)
		drawnSelectionText = selectionText
		drawnNavText = navText
	end
end

function expandModal()
	print('tts: opening modal')
	ui.modal.y = ui.offScreenModal.y
	animate(ui.modal, 'y', ui.onScreenModal.y, navAnimationSpeed * animationScale, ease.outovershoot)
end

function minimizeModal()
	print('tts: closing modal')
	ui.modal.y = ui.onScreenModal.y
	animate(ui.modal, 'y', ui.offScreenModal.y, navAnimationSpeed * animationScale, ease.inovershoot)
end

function getScoreForCompletedPlates()
	local completedPlatesScore = 0
	for plateIndex, completedPlate in ipairs(completedPlates) do
		completedPlatesScore = completedPlatesScore + getScoreForPlate(completedPlate)
	end
	return completedPlatesScore
end

function completePlate()
	local completedPlate = currentPlate
	currentPlate = {}
	-- TODO animate plate to completed plates
	table.insert(completedPlates, completedPlate)

	-- if we pass the round score, shuffle the discard and plate cards back to the draw pile
	local completedPlatesScore = getScoreForCompletedPlates()
	if completedPlatesScore >= roundGoal then
		completingRound = true
		-- add the discard to draw pile
		for discardIndex = #discardPile, 1, -1 do
			table.insert(drawPile, table.remove(discardPile, discardIndex))
		end
		print('tts: '..completedPlatesScore..' out of '..roundGoal..' points needed. Round Complete. Starting new round.')
		wait(1 * animationScale)

		-- discard any cards in hand we have any
		if hand[1] then
				discardCardFromHand(1, ui.card1.x, ui.card1.y)
		end
		if hand[2] then
				discardCardFromHand(2, ui.card2.x, ui.card2.y)
		end
		if hand[3] then
				discardCardFromHand(3, ui.card3.x, ui.card3.y)
		end

		-- for each plate, add each card in that plate back to the drawPile
		for plateIndex = #completedPlates, 1, -1 do
			local completedPlate = completedPlates[plateIndex]
			for ingredientIndex = #completedPlate, 1, -1 do
				table.insert(drawPile, table.remove(completedPlate, ingredientIndex))
			end
			table.remove(completedPlates, plateIndex)
			wait(0.75 * animationScale)
		end
		roundNumber = roundNumber + 1
		roundGoal = math.floor(roundGoal * roundMultiplier)

		-- load modal for players to add a new card to the deck
		modalActions = {'add', 'skip'}
		-- make sure each number is unique by starting at a random number, and showing the next two
		local firstRandomCard = math.random(2, #cardDetails - 2)
		modalCards = { firstRandomCard, firstRandomCard + 1, firstRandomCard + 2 }
		startModal()

		-- once the player has selected a card to add, we'll shuffle then
		-- (see love.keypressed)

		completingRound = false
	end
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

	if selection == 'deck' then
		-- for debugging, just print all cards remaining in deck
		for drawIndex, ingredient in ipairs(drawPile) do
			print(drawIndex..': '..cardDetails[ingredient].label..' ('..ingredient..')')
		end
	end

	selectionText = getSelectionInstruction()
	navText = ''
	if hasStarted then
		navText = getNavInstructions(selection, navKey)
	end
end

function startModal()
	modalActive = true

	hasSeenInstructions = false
	expandModal()

	-- immediately set the modal as the selection
	if modalCards[1] then
		updateSelection('modalCard1')
	else
		updateSelection('modalAction1')
	end
end

function getSelectionInstruction()
	-- if this is a card, determine if this is a hand or modalCard,
	-- and then return those details
	if ui[selection].card then
		local selectedCard = nil
		local location = ''

		-- determine what the selected card is
		if ui[selection].hand then
			selectedCard = hand[ui[selection].handIndex]
		elseif ui[selection].modal then
			selectedCard = modalCards[ui[selection].drawIndex]
		end

		-- determine the location label
		-- (if this is the first card, say how many total there are)
		if ui[selection].hand then
			local totalHandSize = 3
			local currentHandSize = getHandSize()
			local indexText = indexToString(ui[selection].handIndex)
			location = indexText..' card, ;'
			if ui[selection].handIndex == 1 then
				location = currentHandSize..' out of '..totalHandSize..' cards in hand. '..indexText..' card, '
			end
		elseif ui[selection].modal then
			local modalSize = #modalCards
			local indexText = indexToString(ui[selection].drawIndex)
			if modalActions[1] == 'add' then
				location = indexText..' card;'
				if ui[selection].drawIndex == 1 then
					location = modalSize..' cards to choose from. '..indexText..' card, '
				end
			else
				location = indexText..' card, '
				if ui[selection].drawIndex == 1 then
					if modalActions[1] == 'pick' then
						location = modalSize..' cards from deck to choose from. '..indexText..' card, '
					else
						location = modalSize..' cards from deck to preview. '..indexText..' card, '
					end
				end
			end
		end

		-- if there is no card in this spot, return no details
		if selectedCard == nil then
			return location..'No Card;'
		end

		-- if this is a modal card, and we haven't heard the instructions yet, read them
		local modalInstructions = ''
		if ui[selection].modal and hasSeenInstructions == false then
			local modalAction = actionDetails[modalActions[1]]
			modalInstructions = modalAction.initialModalDescription..' '
			hasSeenInstructions = true
		end

		local effect = ''
		if cardDetails[selectedCard].effect then
			effect = cardDetails[selectedCard].effect
		end
		-- if this is a modal card, read the short effect label
		if ui[selection].modal and cardDetails[selectedCard].effectShortLabel then
			effect = cardDetails[selectedCard].effectShortLabel
		end

		local label = cardDetails[selectedCard].label
		local points = cardDetails[selectedCard].points..' points; '
		if cardDetails[selectedCard].points == 1 then
			points = '1 point; '
		end
		local cardSelectionText = modalInstructions..location..label..', '..points..effect

		return cardSelectionText
	end

	if selection == 'modalAction1' then
		local selectedAction = actionDetails[modalActions[1]]
		if modalActions[1] == 'start' then
			return selectedAction.initialModalDescription..' '..selectedAction.actionDescription
		end
		if modalActions[1] == 'restart' then
			local discoveredRecipesCount = getTotalDiscoveredRecipes()
			local roundScore = 'You made it to round '..roundNumber..'. You have discovered '..discoveredRecipesCount..' recipes.'
			return selectedAction.initialModalDescription..' '..roundScore..' '..selectedAction.actionDescription
		end
		if selectedAction then
			local totalActionsLabel = ''
			if hasStarted and #modalActions > 1 then
				totalActionsLabel = #modalActions..' actions, first action '
			end
			return totalActionsLabel..selectedAction.actionDescription
		end
	end

	if selection == 'modalAction2' then
		local selectedAction = actionDetails[modalActions[2]]
		if selectedAction then
			return selectedAction.actionDescription
		else
			return 'No Action'
		end
	end

	if selection == 'deck' then
		local breadInDrawPile = countValueInTopOfPile(drawPile, #drawPile, 1)
		local breadInDiscard = countValueInTopOfPile(discardPile, #discardPile, 1)

		return 'Deck; There are '..#drawPile..' cards left in deck, including '..breadInDrawPile..' Bread Slices. There are '..#discardPile..' cards in discard. '
	end

	if selection == 'plate' then
		local typeOfPlate = getTypeOfPlate(currentPlate)
		local scoreDescription = typesOfPlates[typeOfPlate]
		local currentPlateRawScore = getRawScoreForPlate(currentPlate)
		local plateRecipe = getCompletedRecipeOnPlate(currentPlate)

		if plateRecipe then
			scoreDescription = recipeDetails[plateRecipe].label..' (additional '..recipeDetails[plateRecipe].points..' points)'
		end

		local plateDescription = 'Current Plate: '..scoreDescription..' worth '..currentPlateRawScore..' points'

		-- if this is fat or ultimate toast, show the multiplier
		if (typeOfPlate > 1) then
			plateDescription = plateDescription..' times '..typeOfPlate
		end

		return plateDescription
	end

	local roundScore = getScoreForPlate(currentPlate) + getScoreForCompletedPlates()
	if selection == 'score' then
		local discoveredRecipesCount = getTotalDiscoveredRecipes()
		local totalRecipeCount = #recipeDetails
		local scoreLabel = 'Round Score: '..roundScore..' points out of '..roundGoal..' needed to complete the round. There are '..#completedPlates..' completed plates.'
		local recipeLabel = 'You have discovered '..discoveredRecipesCount..' out of '..totalRecipeCount..' total recipes.'
		return scoreLabel..recipeLabel
	end

	if selection == 'actionDraw' then
		local scoreText = roundScore..' points out of '..roundGoal..' needed to complete the round. '
		return scoreText..'Two actions, First action: Draw, Select to draw 3 new cards.'
	end

	if selection == 'actionNewPlate' then
		return 'Second Action: Score points and start a new plate.'
	end

	return ''
end

function love.keypressed(rawKey)
	-- DebuggingScreen.keypressed(rawKey)

	key = remap(rawKey)
	local navKey = getNavKey()

	-- if we are animating don't allow other actions
	local isAnimating = #routines > 0
	if isAnimating then
		return
	end
	-- if we are drawing or plating, don't allow other actions
	if isDrawing or isPlating then
		return
	end

	-- navigation
	if key == 'down' or key == 'up' or key == 'left' or key == 'right' then
		async(routines, function()
			local nextSelection = ui[selection].nav[navKey] and ui[selection].nav[navKey][key]

			if nextSelection then
				updateSelection(nextSelection)
			end
		end)
	end

	-- if we are selecting a non-modal card and modal is not active, trigger the onPlay
	local isNonModalCard = ui[selection].card and not ui[selection].modal
	if key == 'select' and isNonModalCard and modalActive then
		selectionText = 'Modal open, can not play card.'
	end
	if key == 'select' and isNonModalCard and not modalActive then
		async(routines, function()
			-- get handIndex based on selection
			local handIndex = ui[selection].handIndex

			-- confirm there is a card we can play (if not, do nothing)
			if hand[handIndex] == nil then
				-- reset the selection text
				selectionText = 'No Card'
				wait(0.5 * animationScale)
				return
			end

			local playedCardDetails = cardDetails[hand[handIndex]]

			-- if there is bread on the plate, plate this card
			-- (otherwise, discard it)
			if currentPlate[1] == 1 then
				plateCardFromHand(handIndex, ui[selection].x, ui[selection].y)
			else
				print('tts: No bread, discarding '..cardDetails[hand[handIndex]].label)
				wait(0.75 * animationScale)
				discardCardFromHand(handIndex, ui[selection].x, ui[selection].y)
			end

			-- if modal is active because we completed a round, return early
			if modalActive then
				return
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
					startModal()
				end
			else
				updateSelectionAfterPlayOrDraw()
			end
		end)
	end

	-- if we are selecting a card and the modal action is pick, draw it
	local modalActionIsPick = modalActions[1] == 'pick'
	local isSelectingModalCard = ui[selection].modal and ui[selection].card and modalCards[ui[selection].drawIndex]
	if key == 'select' and isSelectingModalCard and modalActionIsPick then
		async(routines, function()
			local firstEmptyHandSlot = (hand[1] == nil and 1) or (hand[2] == nil and 2) or (hand[3] == nil and 3)
			local targetSelection = 'card'..firstEmptyHandSlot
			minimizeModal()
			modalActive = false
			print('tts: drawing from deck')
			drawFromDeck(firstEmptyHandSlot, ui[selection].drawIndex)
			-- first update to the target selection
			-- but, if our hand is empty (it was bread), reset it
			updateSelection(targetSelection)
			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are selecting a card and the modal action is add, add it to our deck
	local modalActionIsAdd = modalActions[1] == 'add'
	if key == 'select' and isSelectingModalCard and modalActionIsAdd then
		async(routines, function()
			-- add free bread
			table.insert(drawPile, 1, 1)

			-- do starting shuffle
			drawPile = startingShuffle(drawPile)

			-- insert selected card at top of draw pile
			table.insert(drawPile, 1, modalCards[ui[selection].drawIndex])

			minimizeModal()
			modalActive = false

			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are choosing to skip or close the modal action...
	local isSelectingModalAction = ui[selection].modal and ui[selection].action
	local modalAction = isSelectingModalAction and modalActions[ui[selection].actionIndex]
	local isSelectingSkip = isSelectingModalAction and modalAction == 'skip' or modalAction == 'close' or modalAction == 'start'
	if key == 'select' and isSelectingSkip then
		print('modalAction: '..modalAction)
		async(routines, function()
			-- if the modal action was start, start the music
			if modalActions[1] == 'start' then
				hasStarted = true
				-- if we have the intro track, play it now
				-- (if we restarted, this will be nil)
				if intro then
					intro:play()
				end
			end

			-- if the modal action was add, we still need to shuffle here
			if modalActions[1] == 'add' then
				drawPile = startingShuffle(drawPile)
			end

			minimizeModal()
			modalActive = false

			updateSelectionAfterPlayOrDraw()
		end)
	end

	if modalAction == 'restart' then
		async(routines, function()
			startNewGame()
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
				completePlate()
				if not modalActive then
					drawThree()
				end
			end
		end)
	end

	-- repeat text if r was pressed
	if key == "r" then
		async(routines, function()
			print('tts: repeating...')
			-- unset nav instructions
			repeating = true
			heardNavInstructions[selection] = nil
			wait(0.5 * animationScale)

		end)
	end

	-- testing saving / loading
	if key == 'v' then
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
