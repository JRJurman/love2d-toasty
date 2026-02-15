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
require('trackDetails')

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
local roundNumber = 1
local roundMultiplier = 1.3
local completingRound = false

local	routines = {}

local selectionText = ''
local drawnSelectionText = ''
local navText = ''
local drawnNavText = ''
local intro, loop

gameSeed = 0
seed = 0

local animationScale = 0.75
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

	-- if we made a sandwich, immediately toss the plate
	local typeOfPlate = getTypeOfPlate(currentPlate)
	if typeOfPlate == -1 then
		wait(2 * animationScale)
		completePlate()
	end
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

	-- if this resolved in a discovered recipe, add that to our known recipes
	local recipe = getCompletedRecipeOnPlate(currentPlate)
	if recipe then
		discoveredRecipes[recipe] = true
	end
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

function checkToLoopMusic()
	if intro and not intro:isPlaying() then
			intro = nil
			loop:play()
	end
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

	-- music loading (and looping)
	intro = love.audio.newSource("Assets/intro.ogg", "stream")
	loop  = love.audio.newSource("Assets/loop.ogg", "stream")
	loop:setLooping(true)

	intro:play()
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
		love.graphics.rectangle("line", ui.actionDraw.x, ui.actionDraw.y, ui.actionDraw.width, ui.actionDraw.height)
		love.graphics.printf(ui.actionDraw.label, ui.actionDraw.x, ui.actionDraw.y + ui.actionDraw.height, ui.actionDraw.width, 'center')

		love.graphics.rectangle("line", ui.actionNewPlate.x, ui.actionNewPlate.y, ui.actionNewPlate.width, ui.actionNewPlate.height)
		love.graphics.printf(ui.actionNewPlate.label, ui.actionNewPlate.x, ui.actionNewPlate.y + ui.actionNewPlate.height, ui.actionNewPlate.width, 'center')
	end

	-- draw drawPile and discardPile
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.deck.x, ui.deck.y, ui.deck.width, ui.deck.height)

	love.graphics.setColor(0.83, 0.83, 0.87)
	drawCard(0, ui.drawPile.x, ui.drawPile.y)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#drawPile, ui.drawPile.x, ui.drawPile.y + ui.drawPile.height/4, ui.drawPile.width, 'center')
	love.graphics.setFont(getFont(30))
	love.graphics.printf(countValueInTopOfPile(drawPile, #drawPile, 1)..' Bread Slices', ui.drawPile.x, ui.drawPile.y + ui.drawPile.height - 50, ui.drawPile.width, 'center')

	love.graphics.setColor(0.43, 0.43, 0.47)
	drawCard(-1, ui.discardPile.x, ui.discardPile.y)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#discardPile, ui.discardPile.x, ui.discardPile.y + ui.discardPile.height/4, ui.discardPile.width, 'center')

	-- draw plated cards
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("line", ui.plate.x, ui.plate.y, ui.plate.width, ui.plate.height)
	for cardIndex, plateCard in ipairs(currentPlate) do
		drawRotatedCard(plateCard, ui.plateCards.x, ui.plateCards.y, cardIndex)
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
		love.graphics.printf(actionDetails[modalActions[1]].modalTitle, ui.modal.x + 10, ui.modal.y + 10, ui.modal.width - 20, 'center')
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
	love.graphics.setFont(getFont(40))
	love.graphics.printf(selectionText..'\n\n'..navText, ui.readout.x + 10, ui.readout.y, ui.readout.width - 20, 'center')

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
	ui.modal.y = ui.offScreenModal.y
	animate(ui.modal, 'y', ui.onScreenModal.y, navAnimationSpeed * animationScale, ease.outovershoot)
end

function minimizeModal()
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
		wait(1)

		-- for each plate, add each card in that plate back to the drawPile
		for plateIndex = #completedPlates, 1, -1 do
			local completedPlate = completedPlates[plateIndex]
			for ingredientIndex = #completedPlate, 1, -1 do
				table.insert(drawPile, table.remove(completedPlate, ingredientIndex))
			end
			table.remove(completedPlates, plateIndex)
			wait(1)
		end
		roundNumber = roundNumber + 1
		roundGoal = math.floor(roundGoal * roundMultiplier)

		-- load modal for players to add a new card to the deck
		modalActions = {'add', 'skip'}
		modalCards = { math.random(#cardDetails), math.random(#cardDetails), math.random(#cardDetails) }
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

	local selectionDetails = ''
	if selection == 'plate' then
		-- for debugging, just print all cards on plate
		for plateIndex, ingredient in ipairs(currentPlate) do
			print(plateIndex..': '..cardDetails[ingredient].label..' ('..ingredient..')')
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
			print(drawIndex..': '..cardDetails[ingredient].label..' ('..ingredient..')')
		end
	end

	selectionText = getSelectionInstruction()
	navText = getNavInstructions(selection, navKey)
end

function startModal()
	modalActive = true

	-- immediately set the modal as the selection
	expandModal()
	updateSelection('modalCard1')
end

function getSelectionInstruction()
	-- if this is a card, determine if this is a hand or modalCard,
	-- and then return those details
	if ui[selection].card then
		local selectedCard = nil
		if ui[selection].hand then
			selectedCard = hand[ui[selection].handIndex]
		elseif ui[selection].modal then
			selectedCard = modalCards[ui[selection].drawIndex]
		end

		-- if there is no card in this spot, return no details
		if selectedCard == nil then
			return 'No Card;'
		end

		local label = cardDetails[selectedCard].label
		local effect = cardDetails[selectedCard].effect
		local recipes = getRecipesForIngredient(selectedCard)
		local discoveredRecipes, undiscoveredRecipes = splitDiscoveredAndUndiscoveredRecipes(recipes)
		local cardSelectionText = label..'; '..effect..'\n'..#undiscoveredRecipes.. ' undiscovered recipes.'

		return cardSelectionText
	end

	if selection == 'modalAction1' then
		local selectedAction = actionDetails[modalActions[1]]
		if selectedAction then
			return selectedAction.actionDescription
		end
	end

	if selection == 'deck' then
		local breadInDrawPile = countValueInTopOfPile(drawPile, #drawPile, 1)
		local breadInDiscard = countValueInTopOfPile(discardPile, #discardPile, 1)

		return 'Deck and Discard; '..#drawPile..' cards left in deck, includes '..breadInDrawPile..' Bread Slices. '..#discardPile..' cards in discard. '
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

	if selection == 'actionDraw' then
	end

	return ''
end

function love.keypressed(rawKey)
	DebuggingScreen.keypressed(rawKey)

	key = remap(rawKey)
	local navKey = getNavKey()

	-- if we are drawing or plating, don't allow other actions
	if isDrawing or isPlating then
		return
	end

	-- navigation
	if key == 'down' or key == 'up' or key == 'left' or key == 'right' then
		async(routines, function()
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
					startModal()
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

	-- if we are selecting a card and the modal action is add, add it to our deck
	local modalActionIsAdd = modalActions[1] == 'add'
	if key == 'select' and isSelectingModalCard and modalActionIsAdd then
		async(routines, function()
			-- do starting shuffle
			drawPile = startingShuffle(drawPile)
			table.insert(drawPile, 1, modalCards[ui[selection].drawIndex])

			minimizeModal()
			modalActive = false

			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are choosing to skip or close the modal action...
	local isSelectingModalAction = ui[selection].modal and ui[selection].action
	local modalAction = isSelectingModalAction and modalActions[ui[selection].actionIndex]
	local isSelectingSkip = isSelectingModalAction and modalAction == 'skip' or modalAction == 'close'
	if key == 'select' and isSelectingSkip then
		async(routines, function()
			-- if the modal action was add, we still need to shuffle here
			if modalActions[1] == 'add' then
				drawPile = startingShuffle(drawPile)
			end

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
