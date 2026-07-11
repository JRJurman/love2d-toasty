local json = require("json")
require('shuffle')
require('hsl')

require('save')
require('animation')
local ease = require('ease')
local push = require "push"

require('cardDetails')
require('ui')
require('drawCard')
require('drawFatRect')
require('drawSlider')
require('drawCheckbox')
require('drawPlate')
require('drawChef')
require('drawReceipt')
require('drawChalkBoard')
require('drawChalkToast')
require('drawCuttingBoard')
require('deckFunctions')
require('remapFunctions')
require('plateFunctions')
require('ttsFunctions')
require('actionDetails')
require('sfx')
require('tts')
require('resize')

require('FontFunctions')
DebuggingScreen = require('DebuggingScreen')

love.graphics.setFont(getFont(30))

-- determine if we should be in landscape or portrait mode
local windowWidth, windowHeight = love.graphics.getDimensions()
isTall = nil
resize(windowWidth, windowHeight, isTall)

local startingDeck = {
	-- bread
	1, 1, 1, 1,
	-- one point cards
	2, 2, 2, 2,
	-- two point cards
	5, 5, 8, 8, 11, 11, 14, 14,
	-- shuffle
	3, 6,
	-- plate
	4, 7,
}

local commonCardRewardsStart = 3
local commonCardRewardsEnd = 14

local uncommonCardRewardsStart = 15
local uncommonCardRewardsEnd = 18

local rareCardRewardsStart = 19
local rareCardRewardsEnd = 22

local drawPile = {}

local discardPile = {}
local hand = {}
local currentPlate = {}
local completedPlates = {}

local modalCards = {}
local hasSeenModalInstructions = true
local hasSeenCardInstructions = false
local hasSeenModalActionInstructions = false
local hasSeenHandActionInstructions = false

-- start the game with a start game modal
local hasStarted = false
local modalActive = true
local modalActions = {'start'}

local settingsModalActive = false
local lastSelection = nil

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
local roundMultiplier = 1.4
local completingRound = false
local fattestStack = 0

local	routines = {}

local selectionText = ''
local drawnSelectionText = ''
local navText = ''
local drawnNavText = ''
local animationText = ''
local drawnAnimationText = ''

local repeating = false

-- variables to keep track of touch interactions
-- (this swaps between swipes and searches)
-- see https://github.com/JRJurman/love2d-swipe-example
local isTouching = false
local touchTime = 0
local startTouchPos = { x = nil, y = nil }

-- how long before we swap from swipe to search
local swipeTimeThreshold = 0.5

-- variables to keep track of time after single touch
local tapRoutines = {}
local singleTouchThreshold = 0.5

gameSeed = nil
waitingSeed = 0

defaultCursorHue = 0.3
cursorHue = defaultCursorHue
defaultMasterVolume = 1
masterVolume = defaultMasterVolume
defaultMusicVolume = 0.8
musicVolume = defaultMusicVolume
defaultSfxVolume = 0.7
sfxVolume = defaultSfxVolume
defaultUserAnimationScale = 1
userAnimationScale = defaultUserAnimationScale
defaultTTSEnabled = true
ttsEnabled = defaultTTSEnabled

local defaultDrawSize = 3
local drawSize = defaultDrawSize

local	intro = love.audio.newSource("Assets/intro.ogg", "stream")
local loop  = love.audio.newSource("Assets/loop.ogg", "stream")
intro:setVolume(masterVolume * musicVolume * 0.2)
intro:setLooping(true)
loop:setVolume(masterVolume * musicVolume * 0.2)
loop:setLooping(true)

local animationScale = 0.75
local navAnimationSpeed = 0.30
local drawAnimationSpeed = 1

local movingCard = { x = ui.drawPile.x, y = ui.drawPile.y, enabled = false, cardValue = nil }

local settingsFileName = 'settings.v1.json'
function saveSettingsJSON()
	saveGameData(settingsFileName, {
		cursorHue = cursorHue,
		masterVolume = masterVolume,
		musicVolume = musicVolume,
		sfxVolume = sfxVolume,
		userAnimationScale = userAnimationScale,
		ttsEnabled = ttsEnabled
	})
end

function loadSettingsJSON()
	local savedSettings = loadGameData(settingsFileName)
	if savedSettings then
		cursorHue = savedSettings.cursorHue
		masterVolume = savedSettings.masterVolume
		musicVolume = savedSettings.musicVolume
		sfxVolume = savedSettings.sfxVolume
		userAnimationScale = savedSettings.userAnimationScale
		if savedSettings.ttsEnabled == nil then
			ttsEnabled = defaultTTSEnabled
		else
			ttsEnabled = savedSettings.ttsEnabled
			if ttsEnabled == false then
				disableTTS()
			end
		end
		updateMusicVolume()
	end
end

function resetSettings()
	clearGameData(settingsFileName)
	cursorHue = defaultCursorHue
	masterVolume = defaultMasterVolume
	musicVolume = defaultMusicVolume
	sfxVolume = defaultSfxVolume
	userAnimationScale = defaultUserAnimationScale
	ttsEnabled = defaultTTSEnabled
	enableTTS()
	updateMusicVolume()
end

function updateMusicVolume()
	-- update the volume for running music
	if (intro) then
		intro:setVolume(masterVolume * musicVolume * 0.143)
	end
	loop:setVolume(masterVolume * musicVolume * 0.143)
end

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

	if settingsModalActive then
		return 'withSettingsModal'
	elseif modalActive then
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

	playDealSFX()

	local movedCard = table.remove(drawPile, drawIndex)

	movingCard.enabled = true
	movingCard.cardValue = movedCard
	movingCard.x = ui.drawPile.x
	movingCard.y = ui.drawPile.y

	-- if the previous hand card this, change the print to acknowledge that (so the screen reader updates correctly)
	if handIndex == 3 and hand[2] == movedCard and hand[1] == movedCard then
		animationText = 'and another '..cardDetails[movedCard].label
		wait(0.40 * animationScale * (1/userAnimationScale))
	elseif handIndex > 1 and hand[handIndex - 1] == movedCard then
		animationText = 'another '..cardDetails[movedCard].label
		wait(0.25 * animationScale * (1/userAnimationScale))
	else
		animationText = cardDetails[movedCard].label
	end
	animateMany(movingCard, {"x", "y"}, {targetX, targetY}, drawAnimationSpeed * animationScale * (1/userAnimationScale), ease.inovershoot)
	hand[handIndex] = movedCard
	movingCard.enabled = false

	-- if this is bread, play it immediately
	local drawnCardDetails = cardDetails[hand[handIndex]]
	if drawnCardDetails.onDraw then
		if drawnCardDetails.onDraw[1] == 'plate' then
			plateCardFromHand(handIndex, targetX, targetY)
		end
	end

	isDrawing = false
end

function checkForNewHighestStack()
	-- if this resolved in a new high stack, announce that
	-- (only counts if this isn't a sandwich)
	local typeOfPlate = getTypeOfPlate(currentPlate)
	if #currentPlate > fattestStack and typeOfPlate == 1 then
		-- if this isn't quite a "fat stack" yet, silently update this value
		fattestStack = #currentPlate
	end
	if #currentPlate > fattestStack and typeOfPlate > 1 then
		animationText = 'New Fattest Stack reached '..#currentPlate..' ingredients.'
		playhighSFX()
		fattestStack = #currentPlate
		wait(2.3 * animationScale * (1/userAnimationScale))
	end
end

function checkForEndOfRound()
	-- if we have enough points, complete this plate, and start a new round
	local roundScore = getScoreForPlate(currentPlate) + getScoreForCompletedPlates()
	if roundScore >= roundGoal and not isDrawing then
		playStackSFX()
		completePlate()
		return
	end
end

function readoutCurrentScore()
	-- if we are drawing our first bread, don't read out (it interrupts the draw readout)
	local isInitialBread = isDrawing and currentPlateRawScore == nil
	if isInitialBread then
		return
	end

	local typeOfPlate = getTypeOfPlate(currentPlate)

	-- if this is a sandwich, don't read out (we have special messaging for that)
	if typeOfPlate == -1 then
		return
	end

	local typeOfPlateLabel = typesOfPlates[typeOfPlate]
	local currentPlateRawScore = getScoreForPlate(currentPlate)

	local scoreLabel = currentPlateRawScore..' points'
	local waitTime = 1.25
	if currentPlateRawScore == 1 then
		scoreLabel = '1 point'
	end

	-- if this is fat or ultimate toast, show the multiplier
	if typeOfPlate < 1 then
		scoreLabel = '0 points'
	elseif (typeOfPlate > 1) then
		-- add "total to the end to clarify the score"
		-- read out as "Fat Toast (+6), 13 points total"
		scoreLabel = scoreLabel..' total'
		waitTime = waitTime + 1.35
	end

	animationText = typeOfPlateLabel..', '..scoreLabel
	wait(waitTime * animationScale * (1/userAnimationScale))
end

function checkForSandwich()
	-- if we made a sandwich, immediately toss the plate
	local typeOfPlate = getTypeOfPlate(currentPlate)
	if typeOfPlate == -1 then
		playTossSFX()
		animationText = 'You made a Sandwich, no points! Tossing Plate.'
		wait(2.65 * animationScale * (1/userAnimationScale))
		completePlate()
	end
end

function plateCardFromHand(handIndex, startX, startY)
	local hasOnDraw = cardDetails[hand[handIndex]].onDraw
	if hasOnDraw and hasOnDraw[1] == 'plate' then
		animationText = 'auto plating '..cardDetails[hand[handIndex]].label
	else
		animationText = 'plating '..cardDetails[hand[handIndex]].label
	end

	isPlating = true
	movingCard.enabled = true
	local movedCard = hand[handIndex]
	hand[handIndex] = nil
	local startingCard = 'card'..handIndex
	movingCard.cardValue = movedCard
	movingCard.x = startX
	movingCard.y = startY

	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.plateCards.x, ui.plateCards.y},
		drawAnimationSpeed * animationScale * (1/userAnimationScale), ease.inovershoot
	)
	playDropSFX()
	table.insert(currentPlate, movedCard)
	isPlating = false
	movingCard.enabled = false

	checkForNewHighestStack()
	readoutCurrentScore()
	checkForSandwich()
	checkForEndOfRound()
end

function plateCardFromDeck(drawIndex)
	animationText = 'plating '..cardDetails[drawPile[drawIndex]].label
	local movedCard = table.remove(drawPile, drawIndex)

	isPlating = true
	movingCard.enabled = true
	movingCard.cardValue = movedCard
	movingCard.x = ui.drawPile.x
	movingCard.y = ui.drawPile.y

	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.plateCards.x, ui.plateCards.y},
		drawAnimationSpeed * animationScale * (1/userAnimationScale), ease.inovershoot
	)
	playDropSFX()

	table.insert(currentPlate, movedCard)
	isPlating = false
	movingCard.enabled = false

	checkForNewHighestStack()
	readoutCurrentScore()
	checkForSandwich()
	checkForEndOfRound()
end

function updateSelectionAfterPlayOrDraw()
	local handIsEmpty = getHandSize() == 0
	local plateIsEmpty = #currentPlate == 0

	local breadInDeck = countValueInTopOfPile(drawPile, #drawPile, 1)
	local currentPlateRawScore = getRawScoreForPlate(currentPlate)

	-- if we are out of bread, and have no plate, end the game
	-- alternatively if we have no cards in deck (and the hand is empty), end the game
	local outOfBread = breadInDeck == 0 and #currentPlate == 0
	local outOfCards = #drawPile == 0 and handIsEmpty

	if outOfBread or outOfCards then
		modalActions = {'restart'}
		modalCards = {}
		startModal()
		return
	end

	if modalActive then
		return
	end

	-- if hand is empty, and plate is empty,
	-- just draw three cards (we can't start a new plate anyways)
	if handIsEmpty and plateIsEmpty then
		-- set selection to card1, so we auto navigate there
		selection = 'card1'

		-- check if we have started the round (if we have, then print that we are auto-drawing)
		local hasStartedRound = #completedPlates > 0
		if hasStartedRound then
			animationText = 'no plate to score, '
			wait(1 * animationScale * (1/userAnimationScale))
		end

		drawThree()
		return
	end

	-- if we now have an empty hand, change the selection to actions
	-- (this can happen for draw if the last hand has all bread)
	if handIsEmpty then
		updateSelection('actionDraw')
		return
	end

	-- if we are already selecting a card in hand, and there is a card there, select that again,
	-- otherwise select the next real card
	if selection == 'card1' and hand[1] then
		updateSelection('card1')
	elseif selection == 'card2' and hand[2] then
		updateSelection('card2')
	elseif selection == 'card3' and hand[3] then
		updateSelection('card3')
	else
		if hand[1] then
			updateSelection('card1')
		elseif hand[2] then
			updateSelection('card2')
		elseif hand[3] then
			updateSelection('card3')
		else
			updateSelection('card1')
		end
	end
end

function discardCardFromHand(handIndex, startX, startY)
	movingCard.enabled = true
	local movedCard = hand[handIndex]
	hand[handIndex] = nil
	local startingCard = 'card'..handIndex
	movingCard.cardValue = movedCard
	movingCard.x = startX
	movingCard.y = startY

	playDiscardSFX()
	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.discardPile.x, ui.discardPile.y},
		drawAnimationSpeed * animationScale * (1/userAnimationScale), ease.inovershoot
	)
	table.insert(discardPile, movedCard)
	movingCard.enabled = false
end

function discardCardFromDeck(drawIndex)
	local movedCard = table.remove(drawPile, drawIndex)
	movingCard.enabled = true
	movingCard.cardValue = movedCard
	movingCard.x = ui.drawPile.x
	movingCard.y = ui.drawPile.y

	animateMany(
		movingCard,
		{'x', 'y'},
		{ui.discardPile.x, ui.discardPile.y},
		drawAnimationSpeed * animationScale * (1/userAnimationScale), ease.inovershoot
	)
	table.insert(discardPile, movedCard)
	movingCard.enabled = false
end

function drawThree()
	-- draw three cards from drawPile to hand
	async(routines, function()
		animationText = 'drawing from deck'
		wait(1 * animationScale * (1/userAnimationScale))
		for cardToDraw=1, drawSize do
			drawFromDeck(cardToDraw)
		end

		-- if we had modified the drawSize, reset it now
		drawSize = defaultDrawSize

		updateSelectionAfterPlayOrDraw()
	end)
end

function checkToLoopMusic()
	-- if we haven't started, and the intro didn't kick off yet, try playing it
	if hasStarted == false and intro and not intro:isPlaying() then
		intro:play()
		return
	end

	-- we don't need to check if the loop is already playing
	if loop:isPlaying() then
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
	-- shuffle the deck to make the start pile
	drawPile = safeShuffle(startingDeck, 3)
	hand = {}
	discardPile = {}
	currentPlate = {}
	completedPlates = {}
	roundGoal = 6
	roundNumber = 1
	drawSize = defaultDrawSize
	hasStarted = false
	modalActions = {'start'}
	modalCards = {}
	startModal()

	if intro then
		intro:play()
	end
end

function loadSeed()
	gameSeed = waitingSeed
	print('seed: '..gameSeed)
	math.randomseed(gameSeed)
end

function love.load()
	async(routines, function()
		startNewGame()
	end)
	async(routines, function()
		-- wait one second before loading (that way someone can hold lctrl to reset)
		wait(1)
		if love.keyboard.isDown( 'q' ) then
			resetSettings()
		else
			loadSettingsJSON()
		end
	end)
end

function love.update(dt)
	if gameSeed == nil then
		waitingSeed = waitingSeed + dt*10000
	end

	-- progress all animation routines by dt
	updateAnimations(routines, dt)

	-- not really animations, but timers all the same
	updateAnimations(tapRoutines, dt)

	checkToLoopMusic()
	if isTouching then
		touchTime = touchTime + dt
	end
end

function love.draw()
	push:start()

	love.graphics.clear()
	love.graphics.setFont(getFont(30))

	-- draw cards in hand
	drawCuttingBoard(ui.hand.x, ui.hand.y)
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
		love.graphics.setColor(16/256, 20/256, 31/256)
		love.graphics.setFont(getFont(90))
		love.graphics.rectangle("line", ui.actionDraw.x, ui.actionDraw.y, ui.actionDraw.width, ui.actionDraw.height)
		love.graphics.printf("Draw Cards", ui.actionDraw.x, ui.actionDraw.y - 18, ui.actionDraw.width, 'center')

		love.graphics.rectangle("line", ui.actionNewPlate.x, ui.actionNewPlate.y, ui.actionNewPlate.width, ui.actionNewPlate.height)
		love.graphics.printf("New Plate", ui.actionNewPlate.x, ui.actionNewPlate.y - 18, ui.actionNewPlate.width, 'center')
	end

	-- draw drawPile and discardPile
	love.graphics.setColor(235/256, 237/256, 233/256)
	drawCard(0, ui.drawPile.x, ui.drawPile.y)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#drawPile, ui.drawPile.x, ui.drawPile.y + ui.drawPile.height/4, ui.drawPile.width, 'center')
	love.graphics.setFont(getFont(30))
	local breadInDeck = countValueInTopOfPile(drawPile, #drawPile, 1)
	love.graphics.printf(breadInDeck..' Bread Slices', ui.drawPile.x, ui.drawPile.y + ui.drawPile.height - 50, ui.drawPile.width, 'center')

	drawCard(-1, ui.discardPile.x, ui.discardPile.y)
	love.graphics.setFont(getFont(80))
	love.graphics.printf(#discardPile, ui.discardPile.x, ui.discardPile.y + ui.discardPile.height/4, ui.discardPile.width, 'center')

	-- draw plated cards
	-- (we only draw the top 5, since there can be rendering issues if we try to draw too many)
	drawPlate(ui.plateCards.x + (ui.plateCards.width / 2), ui.plateCards.y + (ui.plateCards.height / 2))
	if #currentPlate > 0 then
		for cardIndex=math.max(#currentPlate - 5, 1), #currentPlate do
			drawRotatedCard(currentPlate[cardIndex], ui.plateCards.x, ui.plateCards.y, cardIndex)
		end
	end

	-- draw board for shift / round score, and the current plate score
	drawChalkBoard('black', ui.scoreBoard.x, ui.scoreBoard.y, ui.scoreBoard.width, ui.scoreBoard.height)

	-- draw completed plates as receipts
	love.graphics.setColor(0.43, 0.43, 0.47)
	for plateIndex, completedPlate in ipairs(completedPlates) do
		local receiptWidth = 215
		local receiptHeight = 150
		local receiptX = ui.served.x + (((plateIndex-1) % 2) * receiptWidth)
		local receiptY = ui.served.y + (math.floor((plateIndex-1) / 2) * receiptHeight)
		local plateScore = getScoreForPlate(completedPlate)
		drawReceipt(receiptX, receiptY, '+'..plateScore)
	end

	-- draw the current plate score (if we aren't completing a round)
	love.graphics.setColor(0.98, 0.98, 0.98)
	if not completingRound then
		local typeOfPlate = getTypeOfPlate(currentPlate)
		local currentPlateRawScore = getRawScoreForPlate(currentPlate)
		love.graphics.setFont(getFont(90))

		local scoreLabel = '+'..currentPlateRawScore
		if typeOfPlate == -1 or currentPlateRawScore == 0 then
			scoreLabel = '0'
		end
		love.graphics.printf(scoreLabel, ui.plateScore.x + 10, ui.plateScore.y, ui.plateScore.width - 20, 'center')

		-- print type of plate
		love.graphics.setFont(getFont(50))
		local scoreDescription = typesOfPlates[typeOfPlate]
		love.graphics.printf(scoreDescription, ui.plateScore.x, ui.plateScore.y + 100, ui.plateScore.width, 'center')
	else
		love.graphics.setFont(getFont(90))
		love.graphics.printf('SHIFT COMPLETE', ui.plateScore.x, ui.plateScore.y, ui.plateScore.width, 'center')
	end

	-- draw round score
	love.graphics.setFont(getFont(30))
	love.graphics.printf('Shift '..roundNumber, ui.score.x + 10, ui.score.y, ui.score.width - 20, 'center')
	love.graphics.setFont(getFont(90))
	local roundScore = getScoreForPlate(currentPlate) + getScoreForCompletedPlates()
	love.graphics.printf(roundScore..'/'..roundGoal, ui.score.x + 10, ui.score.y + 15, ui.score.width - 20, 'center')
	-- draw the number of discovered vs undiscovered in the round score
	love.graphics.setFont(getFont(30))
	love.graphics.printf('Fattest Stack: '..fattestStack..' ingredients', ui.score.x + 10, ui.score.y + 130, ui.score.width - 20, 'center')

	-- draw the modal if it is active
	if modalActive then
		drawChalkBoard('black', ui.modal.x, ui.modal.y, ui.modal.width, ui.modal.height)

		-- draw modal title
		love.graphics.setColor(235/256, 237/256, 233/256)
		if modalActions[1] then
			love.graphics.setFont(getFont(90))
			love.graphics.printf(actionDetails[modalActions[1]].modalTitle, ui.modal.x + 10, ui.modal.y + 15, ui.modal.width - 20, 'center')
			if actionDetails[modalActions[1]].modalSubtitle then
				love.graphics.setFont(getFont(50))
				love.graphics.printf(actionDetails[modalActions[1]].modalSubtitle, ui.modal.x + 10, ui.modal.y + 120, ui.modal.width - 20, 'center')
			end
		end

		-- if this is the start modal, show the toast graphic
		if modalActions[1] == 'start' then
			drawChalkToast(ui.modal.x + 315, ui.modal.y + 125)
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

		-- draw any actions on the modal
		love.graphics.setFont(getFont(70))
		if modalActions[1] then
			local actionX = ui.modal.x + ui.modalAction1.x
			local actionY = ui.modal.y + ui.modalAction1.y
			love.graphics.rectangle("line", actionX, actionY, ui.modalAction1.width, ui.modalAction1.height)
			love.graphics.printf(actionDetails[modalActions[1]].label, actionX, actionY - 25, ui.modalAction1.width, 'center')
		end
		if modalActions[2] then
			local actionX = ui.modal.x + ui.modalAction2.x
			local actionY = ui.modal.y + ui.modalAction2.y
			love.graphics.rectangle("line", actionX, actionY, ui.modalAction2.width, ui.modalAction2.height)
			love.graphics.printf(actionDetails[modalActions[2]].label, actionX, actionY - 25, ui.modalAction2.width, 'center')
		end
		love.graphics.setFont(getFont(30))
	end

	love.graphics.setFont(getFont(30))

	-- draw any cards that are moving
	if movingCard.enabled then
		love.graphics.setColor(0.43, 0.98, 0.47)
		drawCard(movingCard.cardValue, movingCard.x, movingCard.y)
	end

	-- draw the readout
	local isAnimating = #routines > 0

	-- readout border
	love.graphics.setColor(175/256, 201/256, 104/256)
	love.graphics.rectangle("fill", ui.readout.x, ui.readout.y, ui.readout.width, ui.readout.height)

	-- readout center
	love.graphics.setColor(210/256, 218/256, 153/256)
	love.graphics.rectangle("fill", ui.readout.x + 10, ui.readout.y + 10, ui.readout.width - 20, ui.readout.height - 40)

	-- readout arrow
	love.graphics.setColor(175/256, 201/256, 104/256)
	love.graphics.polygon('fill',
		ui.chefReadoutArrow.x1, ui.chefReadoutArrow.y1,
		ui.chefReadoutArrow.x2, ui.chefReadoutArrow.y2,
		ui.chefReadoutArrow.x3, ui.chefReadoutArrow.y3
	)

	-- readout text
	love.graphics.setColor(16/256, 20/256, 31/256)

	-- change font size based on has started (the first modal needs a lot of space)
	if hasStarted == false then
		love.graphics.setFont(getFont(39))
	else
		love.graphics.setFont(getFont(46))
	end
	local readoutText = selectionText
	if isAnimating then
		readoutText = animationText
	end
	love.graphics.printf(readoutText, ui.readout.x + 15, ui.readout.y, ui.readout.width - 30, 'center')

	-- draw the chef
	drawChef(ui.chef.x, ui.chef.y)

	-- draw the settings option
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(getFont(40))
	love.graphics.rectangle("line", ui.settingsControl.x, ui.settingsControl.y, ui.settingsControl.width, ui.settingsControl.height)
	love.graphics.printf("Settings", ui.settingsControl.x, ui.settingsControl.y - 15, ui.settingsControl.width, 'center')

	-- draw the settings modal
	if settingsModalActive then
		drawChalkBoard('green', ui.settingsModal.x, ui.settingsModal.y, ui.settingsModal.width, ui.settingsModal.height)

		-- draw modal title
		love.graphics.setFont(getFont(50))
		love.graphics.printf('Settings', ui.settingsModal.x + 10, ui.settingsModal.y + 30, ui.settingsModal.width - 20, 'center')

		-- draw the settings
		love.graphics.setFont(getFont(30))
		local masterX = ui.settingsMasterSlider.x + ui.settingsModal.x + 10
		local masterY = ui.settingsMasterSlider.y + ui.settingsModal.y
		love.graphics.printf('Master Volume', masterX, masterY, ui.settingsMasterSlider.width, 'left')
		drawSlider(masterX, masterY + 10 + (ui.settingsMasterSlider.height / 2), ui.settingsMasterSlider.width - 20, masterVolume, 0, 1)

		local musicX = ui.settingsMusicSlider.x + ui.settingsModal.x + 10
		local musicY = ui.settingsMusicSlider.y + ui.settingsModal.y
		love.graphics.printf('Music Volume', ui.settingsMusicSlider.x + ui.settingsModal.x + 5, ui.settingsMusicSlider.y + ui.settingsModal.y, ui.settingsModal.width - 20, 'left')
		drawSlider(musicX, musicY + 10 + (ui.settingsMusicSlider.height / 2), ui.settingsMusicSlider.width - 20, musicVolume, 0, 1)

		local sfxX = ui.settingsSFXSlider.x + ui.settingsModal.x + 10
		local sfxY = ui.settingsSFXSlider.y + ui.settingsModal.y
		love.graphics.printf('Sound Volume', ui.settingsSFXSlider.x + ui.settingsModal.x + 5, ui.settingsSFXSlider.y + ui.settingsModal.y, ui.settingsModal.width - 20, 'left')
		drawSlider(sfxX, sfxY + 10 + (ui.settingsSFXSlider.height / 2), ui.settingsSFXSlider.width - 20, sfxVolume, 0, 1)

		local animationX = ui.settingsAnimationSlider.x + ui.settingsModal.x + 10
		local animationY = ui.settingsAnimationSlider.y + ui.settingsModal.y
		love.graphics.printf('Animation Speed', ui.settingsAnimationSlider.x + ui.settingsModal.x + 5, ui.settingsAnimationSlider.y + ui.settingsModal.y, ui.settingsModal.width - 20, 'left')
		drawSlider(animationX, animationY + 10 + (ui.settingsAnimationSlider.height / 2), ui.settingsAnimationSlider.width - 20, userAnimationScale, 0.25, 4)

		local cursorHueX = ui.settingsCursorSlider.x + ui.settingsModal.x + 10
		local cursorHueY = ui.settingsCursorSlider.y + ui.settingsModal.y
		love.graphics.printf('Cursor Hue', ui.settingsCursorSlider.x + ui.settingsModal.x + 5, ui.settingsCursorSlider.y + ui.settingsModal.y, ui.settingsModal.width - 20, 'left')
		drawSlider(cursorHueX, cursorHueY + 10 + (ui.settingsCursorSlider.height / 2), ui.settingsCursorSlider.width - 20, cursorHue, 0, 1)

		local ttsCheckboxX = ui.settingsTTSCheckbox.x + ui.settingsModal.x + 10
		local ttsCheckboxY = ui.settingsTTSCheckbox.y + ui.settingsModal.y
		love.graphics.printf('Text to Speech', ui.settingsTTSCheckbox.x + ui.settingsModal.x + 5, ui.settingsTTSCheckbox.y + ui.settingsModal.y, ui.settingsModal.width - 20, 'left')
		drawCheckbox(ttsCheckboxX, ttsCheckboxY + 10 + (ui.settingsCursorSlider.height / 2), ttsEnabled)

		-- draw actions on the modal
		love.graphics.setFont(getFont(60))
		local actionX = ui.settingsModal.x + ui.modalSettingsSaveAction.x
		local actionY = ui.settingsModal.y + ui.modalSettingsSaveAction.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalSettingsSaveAction.width, ui.modalSettingsSaveAction.height)
		love.graphics.printf('Save', actionX, actionY, ui.modalSettingsSaveAction.width, 'center')

		local actionX = ui.settingsModal.x + ui.modalSettingsResetAction.x
		local actionY = ui.settingsModal.y + ui.modalSettingsResetAction.y
		love.graphics.rectangle("line", actionX, actionY, ui.modalSettingsResetAction.width, ui.modalSettingsResetAction.height)
		love.graphics.printf('Reset', actionX, actionY, ui.modalSettingsResetAction.width, 'center')

		-- draw mobile settings readout
		if isTall then
			love.graphics.setFont(getFont(50))
			love.graphics.printf(readoutText, ui.settingsMobileReadout.x + 15, ui.settingsMobileReadout.y, ui.settingsMobileReadout.width - 30, 'center')
		end
	end

	-- draw the cursor
	love.graphics.setColor(HSL(cursorHue, 1, 0.60))
	drawFatRect('outset', 10, cursor.x, cursor.y, cursor.width, cursor.height)

	DebuggingScreen.draw()

	-- if we are animating, unset the selection and nav text
	-- (these will almost always be set by the animating function)
	-- and update the screen reader with the animation text
	if isAnimating and (drawnAnimationText ~= animationText) then
		drawnSelectionText = ''
		drawnNavText = ''

		drawnAnimationText = animationText
		speak(animationText)
	end

	-- update the screen reader (if text changed)
	-- (we don't do this every frame, because it would overwhelm the dev console)
	-- only do this if we aren't animating right now
	if not isAnimating and (drawnSelectionText ~= selectionText or drawnNavText ~= navText) then
		animationText = ''
		local ttsText = string.gsub(selectionText..'. ', '\n', '; ')
		-- if they are repeating, include nav text
		local shouldIncludeNavText = repeating and hasStarted
		if shouldIncludeNavText then
			repeating = false
			ttsText = string.gsub(selectionText..'. Navigation Controls: '..navText, '\n', '; ')
		end
		speak(ttsText)
		drawnSelectionText = selectionText
		drawnNavText = navText
	end

	push:finish()
end

function love.resize(width, height)
	resize(width, height, isTall)
end

function shuffleDrawPile(deep)
	animationText = 'Shuffling Deck'
	playShuffleSFX()
	wait(0.75 * animationScale * (1/userAnimationScale))
	drawPile = safeShuffle(drawPile, deep)
end

function expandModal()
	playPullSFX()
	if hasStarted then
		animationText = 'opening modal'
	end
	ui.modal.y = ui.offScreenModal.y
	animate(ui.modal, 'y', ui.onScreenModal.y, 0.3 * animationScale * (1/userAnimationScale), ease.outovershoot)
end

function minimizeModal()
	animationText = 'closing modal'
	playPushSFX()
	wait(0.5 * animationScale * (1/userAnimationScale))
	ui.modal.y = ui.onScreenModal.y
	animate(ui.modal, 'y', ui.offScreenModal.y, 0.3 * animationScale * (1/userAnimationScale), ease.inovershoot)
end

function expandSettingsModal()
	playPullSFX()
	animationText = 'opening settings'
	ui.settingsModal.y = ui.offScreenModal.y
	animate(ui.settingsModal, 'y', ui.onScreenModal.y, 0.3 * animationScale * (1/userAnimationScale), ease.outovershoot)
end

function minimizeSettingsModal()
	animationText = 'closing settings'
	playPushSFX()
	wait(0.5 * animationScale * (1/userAnimationScale))
	ui.settingsModal.y = ui.onScreenModal.y
	animate(ui.settingsModal, 'y', ui.offScreenModal.y, 0.3 * animationScale * (1/userAnimationScale), ease.inovershoot)
end

function getScoreForCompletedPlates()
	local completedPlatesScore = 0
	for plateIndex, completedPlate in ipairs(completedPlates) do
		completedPlatesScore = completedPlatesScore + getScoreForPlate(completedPlate)
	end
	return completedPlatesScore
end

function startGameEndModal()
	modalActions = {'endless', 'restart'}
	modalCards = {}
	startModal()
end

function startNextRoundModal()
	-- load modal for players to add a new card to the deck
	modalActions = {'add', 'skip'}
	-- make sure each number is unique by starting at a random number, and showing the next one
	modalCards = {}
	if roundNumber ~= 2 and roundNumber ~= 6 then
		local commonCardReward = math.random(commonCardRewardsStart, commonCardRewardsEnd)
		local uncommonCardReward = math.random(uncommonCardRewardsStart, uncommonCardRewardsEnd)
		modalCards = { commonCardReward, uncommonCardReward }
	else
		local firstRareCardReward = math.random(rareCardRewardsStart, rareCardRewardsEnd - 1)
		local secondRareCardReward = firstRareCardReward + 1
		modalCards = { firstRareCardReward, secondRareCardReward }
	end
	startModal()

	-- once the player has selected a card to add, we'll shuffle then
	-- (see love.keypressed)
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
		local nextRoundGoal = math.floor(roundGoal * roundMultiplier)
		animationText = 'Current Score is '..completedPlatesScore..' out of '..roundGoal..' needed. Shift '..roundNumber..' Completed. Your new goal is '..nextRoundGoal..' points.'
		local waitTime = 4.65
		if roundGoal > 9 then
			waitTime = waitTime + 0.25
		end

		-- discard any cards in hand we have any
		if hand[1] then
				discardCardFromHand(1, ui.card1.x, ui.card1.y)
				waitTime = waitTime - drawAnimationSpeed
		end
		if hand[2] then
				discardCardFromHand(2, ui.card2.x, ui.card2.y)
				waitTime = waitTime - drawAnimationSpeed
		end
		if hand[3] then
				discardCardFromHand(3, ui.card3.x, ui.card3.y)
				waitTime = waitTime - drawAnimationSpeed
		end

		-- add the discard to draw pile
		for discardIndex = #discardPile, 1, -1 do
			table.insert(drawPile, table.remove(discardPile, discardIndex))
		end

		-- for each plate, add each card in that plate back to the drawPile
		for plateIndex = #completedPlates, 1, -1 do
			local completedPlate = completedPlates[plateIndex]
			for ingredientIndex = #completedPlate, 1, -1 do
				table.insert(drawPile, table.remove(completedPlate, ingredientIndex))
			end
			table.remove(completedPlates, plateIndex)
			wait(0.75 * animationScale * (1/userAnimationScale))
			waitTime = waitTime - 0.75
		end
		roundNumber = roundNumber + 1
		roundGoal = nextRoundGoal
		drawSize = defaultDrawSize

		-- based on how much time was already used, wait the remaining time to read the rest of the text
		wait(waitTime * animationScale * (1/userAnimationScale))

		if roundNumber == 6 then
			startGameEndModal()
		else
			startNextRoundModal()
		end

		completingRound = false
	end
end

function updateSelection(target, skipNavAnimation)
	local navSpeed = navAnimationSpeed
	if skipNavAnimation then
		navSpeed = 0
	end

	-- if we are on the start / restart modal, and you try to navigate to some other modal control, don't
	-- (this is common trip up for mouse controls)
	if selection == 'modalAction1' and (modalActions[1] == 'start' or modalActions[1] == 'restart') then
		if ui[target].modal and not ui[target].settingsModal then
			-- if we are swapping from restart to start though, do update the selection text
			selectionText = getSelectionInstruction()
			return
		end
	end

	selection = target

	async(routines, function()
		local targetX = ui[selection].x
		local targetY = ui[selection].y
		-- if we are in a modal, modify the target positions respectively
		if (modalActive and ui[selection].modal) then
			targetX = targetX + ui.modal.x
			targetY = targetY + ui.modal.y
		end
		if (settingsModalActive and ui[selection].modal) then
			targetX = targetX + ui.settingsModal.x
			targetY = targetY + ui.settingsModal.y
		end
		animateMany(cursor,
			{"x", "y", "width", "height"},
			{targetX, targetY, ui[selection].width, ui[selection].height},
			navSpeed * animationScale * (1/userAnimationScale), ease.inovershoot
		)
		playNavSFX()
	end)

	local navKey = getNavKey()

	selectionText = getSelectionInstruction()
	navText = ''
	if hasStarted then
		navText = getNavInstructions(selection, navKey)
	end
end

function startModal()
	modalActive = true

	hasSeenModalInstructions = false
	expandModal()

	-- immediately set the modal as the selection
	if modalCards[1] then
		updateSelection('modalCard1')
	else
		updateSelection('modalAction1')
	end
end

function startSettingsModal()
	settingsModalActive = true
	lastSelection = selection

	expandSettingsModal()

	updateSelection('settingsMasterSlider')
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
			location = indexText..' card in hand, '
			if ui[selection].handIndex == 1 then
				location = 'You have '..currentHandSize..' out of '..totalHandSize..' cards. '..indexText..' card in hand, '
			end
		elseif ui[selection].modal then
			local modalSize = #modalCards
			local indexText = indexToString(ui[selection].drawIndex)
			if modalActions[1] == 'add' then
				location = indexText..' card;'
				if ui[selection].drawIndex == 1 then
					location = 'You have '..modalSize..' cards to choose from. '..indexText..' card, '
				end
			else
				location = indexText..' card, '
				if ui[selection].drawIndex == 1 then
					if modalActions[1] == 'pick' or modalActions[1] == 'plate' then
						location = 'You have '..modalSize..' cards from deck to choose from. '..indexText..' card, '
					else
						location = 'You have '..modalSize..' cards from deck to preview. '..indexText..' card, '
					end
				end
			end
		end

		-- if there is no card in this spot, return no details
		if selectedCard == nil then
			return location..'No Card;'
		end

		-- if this is a modal card, and this is the first card, include the modal instructions
		local modalInstructions = ''
		if ui[selection].modal and hasSeenModalInstructions == false then
			local modalAction = actionDetails[modalActions[1]]
			modalInstructions = modalAction.initialModalDescription..' '
			hasSeenModalInstructions = true
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
		local pointsText = 'worth '..cardDetails[selectedCard].points..' points; '
		if cardDetails[selectedCard].points == 1 then
			pointsText = 'worth 1 point; '
		end

		local firstNavInstructions = ''
		if ui[selection].hand and hasSeenCardInstructions == false then
			hasSeenCardInstructions = true
			firstNavInstructions = 'Use left and right to move between cards, select a card to plate it. '
		end
		local cardSelectionText = modalInstructions..location..label..', '..pointsText..effect..' '..firstNavInstructions

		return cardSelectionText
	end

	if selection == 'modalAction1' then
		local selectedAction = actionDetails[modalActions[1]]
		if modalActions[1] == 'start' then
			return selectedAction.initialModalDescription..' '..selectedAction.actionDescription
		end
		if modalActions[1] == 'restart' or modalActions[1] == 'endless' then
			local roundScore = 'You made it to shift '..roundNumber..'. Your fattest toast was '..fattestStack..' ingredients.'
			return selectedAction.initialModalDescription..' '..roundScore..' '..selectedAction.actionDescription
		end
		if selectedAction then
			local totalActionsLabel = ''
			local firstModalInstructions = ''
			if hasStarted and #modalActions > 1 then
				totalActionsLabel = 'You have '..#modalActions..' options, first option, '
			else
				totalActionsLabel = indexToString(ui[selection].actionIndex).. ' option, '
			end
			if hasStarted and #modalActions > 1 and hasSeenModalActionInstructions == false then
				hasSeenModalActionInstructions = true
				firstModalInstructions = 'Press right to see other option.'
			end
			return totalActionsLabel..selectedAction.actionDescription..' '..firstModalInstructions
		end
	end

	if selection == 'modalAction2' then
		local selectedAction = actionDetails[modalActions[2]]
		if selectedAction then
			return indexToString(ui[selection].actionIndex).. ' option, '..selectedAction.actionDescription
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

		local plateDescription = 'Current Plate: '..scoreDescription..' with '..#currentPlate..' ingredients, worth '..currentPlateRawScore..' points'

		-- if this is fat or ultimate toast, show the multiplier
		if (typeOfPlate > 1) then
			plateDescription = plateDescription..' plus '..(typeOfPlate * 4)..' points'
		end

		return plateDescription
	end

	local roundScore = getScoreForPlate(currentPlate) + getScoreForCompletedPlates()
	if selection == 'score' then
		local scoreLabel = 'Score: '..roundScore..' points out of '..roundGoal..' needed to complete the shift. There are '..#completedPlates..' completed plates.'
		local stackLabel = 'Your fattest stack is '..fattestStack..' ingredients.'
		return scoreLabel..stackLabel
	end

	if selection == 'actionDraw' then
		local breadInDeck = countValueInTopOfPile(drawPile, #drawPile, 1)
		local drawPileText = 'There are '..#drawPile..' cards remaining in deck, with '..breadInDeck..' bread slices.'
		local firstHandInstructions = ''
		if hasSeenHandActionInstructions == false then
			hasSeenHandActionInstructions = true
			firstHandInstructions = 'Press right to see other action.'
		end

		return 'Two actions, First action: Draw, Select to draw '..drawSize..' new cards. '..drawPileText..' '..firstHandInstructions
	end

	if selection == 'actionNewPlate' then
		local scoreText = 'You have '..roundScore..' points out of '..roundGoal..' needed to complete the shift. '
		return 'Second Action: Score points and start a new plate. '..scoreText
	end

	if selection == 'settingsMasterSlider' then
		return 'Master Volume Slider, press left to decrease, right to increase, down to see other settings'
	end

	if selection == 'settingsMusicSlider' then
		return 'Music Volume Slider, press left to decrease, right to increase'
	end

	if selection == 'settingsSFXSlider' then
		return 'Sound Volume Slider, press left to decrease, right to increase'
	end

	if selection == 'settingsAnimationSlider' then
		return 'Animation Speed Slider, press left to slow down, right to speed up'
	end

	if selection == 'settingsCursorSlider' then
		return 'Cursor Hue Slider, press left and right to change cursor hue color'
	end

	if selection == 'settingsTTSCheckbox' then
		return 'Text to Speech checkbox, select to toggle text to speech engine - ignored if screen reader is detected'
	end

	if selection == 'modalSettingsSaveAction' then
		return 'Save Settings and continue game'
	end

	if selection == 'modalSettingsResetAction' then
		return 'Reset settings to default'
	end

	if selection == 'settingsControl' then
		return 'Settings, select to open configuration options'
	end

	return ''
end

function repeatText()
	animationText = 'repeating...'
	if hasStarted then
		repeating = true
	end
	wait(0.5 * animationScale * (1/userAnimationScale))
	animationText = ''
end

function love.keypressed(rawKey)
	DebuggingScreen.keypressed(rawKey)

	print('rawKey: '..rawKey)

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
	-- don't navigate if we are in the start or restart modal (unless we are in settings)
	local noNavModals = modalActive and (modalActions[1] == 'start' or modalActions[1] == 'restart')
	local isPressingNavKey = (key == 'down' or key == 'up' or key == 'left' or key == 'right')
	if isPressingNavKey and (not noNavModals or settingsModalActive) then
		async(routines, function()
			local nextSelection = ui[selection].nav[navKey] and ui[selection].nav[navKey][key]

			if nextSelection then
				updateSelection(nextSelection)
			end
		end)
	end

	-- if we are in a non nav modal, but they did press a nav key, repeat text
	-- this can be important if they missed the intro text
	if noNavModals and not settingsModalActive and isPressingNavKey then
		async(routines, function()
			repeatText()
		end)
	end

	-- if this is a settings slider, and we hit left or right, update those settings
	if (key == 'left' or key == 'right') and ui[selection].slider then
		playNavSFX()
		if selection == 'settingsMasterSlider' then
			local delta = (key == 'left' and -1) or 1
			masterVolume = math.floor((masterVolume*10) + delta) / 10
			masterVolume = math.min(math.max(masterVolume, 0), 1)
			selectionText = (math.floor(masterVolume * 100))..'%'
			updateMusicVolume()
		end
		if selection == 'settingsMusicSlider' then
			local delta = (key == 'left' and -1) or 1
			musicVolume = math.floor((musicVolume*10) + delta) / 10
			musicVolume = math.min(math.max(musicVolume, 0), 1)
			selectionText = (math.floor(musicVolume * 100))..'%'
			updateMusicVolume()
		end
		if selection == 'settingsSFXSlider' then
			local delta = (key == 'left' and -1) or 1
			sfxVolume = math.floor((sfxVolume*10) + delta) / 10
			sfxVolume = math.min(math.max(sfxVolume, 0), 1)
			selectionText = (math.floor(sfxVolume * 100))..'%'
		end
		if selection == 'settingsAnimationSlider' then
			local delta = (key == 'left' and -.5) or .5
			userAnimationScale = userAnimationScale + delta
			userAnimationScale = math.min(math.max(userAnimationScale, 0.5), 4)
			selectionText = userAnimationScale
		end
		if selection == 'settingsCursorSlider' then
			local delta = (key == 'left' and -1) or 1
			cursorHue = math.floor((cursorHue*10) + delta) / 10
			cursorHue = math.min(math.max(cursorHue, 0), 1)
			selectionText = hueToColor(cursorHue)
		end
	end

	-- if we reset, reset the default settings
	if key == 'select' and selection == 'modalSettingsResetAction' then
		resetSettings()
		async(routines, function()
			minimizeSettingsModal()
			settingsModalActive = false
			updateSelection(lastSelection)
		end)
		return
	end

	-- if we saved, then close the modal
	if key == 'select' and selection == 'modalSettingsSaveAction' then
		saveSettingsJSON()
		async(routines, function()
			minimizeSettingsModal()
			settingsModalActive = false
			updateSelection(lastSelection)
		end)
		return
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
				wait(0.5 * animationScale * (1/userAnimationScale))
				return
			end

			local playedCardDetails = cardDetails[hand[handIndex]]

			-- if there is bread on the plate, plate this card
			-- (otherwise, discard it)
			canPlate = canPlateIngredient(currentPlate, hand[handIndex])
			if canPlate then
				plateCardFromHand(handIndex, ui[selection].x, ui[selection].y)
			else
				animationText = 'No bread, discarding '..cardDetails[hand[handIndex]].label
				wait(0.75 * animationScale * (1/userAnimationScale))
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
				if playedCardDetails.onPlay.name == 'finish' then
					local typeOfPlate = getTypeOfPlate(currentPlate)
					if typeOfPlate > 0 then
						animationText = 'Scoring Plate'
						playStackSFX()
						wait(1 * animationScale * (1/userAnimationScale))
						completePlate()
					end
					updateSelectionAfterPlayOrDraw()
				end
				if playedCardDetails.onPlay.name == 'reduce-draw' then
					-- reduce draw size (but never below one)
					drawSize = math.max(drawSize - 1, 1)

					updateSelectionAfterPlayOrDraw()
				end
			else
				updateSelectionAfterPlayOrDraw()
			end
		end)
	end

	local isSelectingModalCard = ui[selection].modal and ui[selection].card and modalCards[ui[selection].drawIndex]

	-- if we are selecting a card and the modal action is pick, draw it
	local modalActionIsPick = modalActions[1] == 'pick'
	if key == 'select' and isSelectingModalCard and modalActionIsPick then
		async(routines, function()
			local firstEmptyHandSlot = (hand[1] == nil and 1) or (hand[2] == nil and 2) or (hand[3] == nil and 3)
			local targetSelection = 'card'..firstEmptyHandSlot
			minimizeModal()
			modalActive = false
			animationText = 'drawing from deck'
			drawFromDeck(firstEmptyHandSlot, ui[selection].drawIndex)
			-- first update to the target selection
			-- but, if our hand is empty (it was bread), reset it
			updateSelection(targetSelection)
			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are selecting a card and the modal action is plate, plate it
	local modalActionIsPlate = modalActions[1] == 'plate'
	if key == 'select' and isSelectingModalCard and modalActionIsPlate then
		async(routines, function()
			minimizeModal()
			modalActive = false
			animationText = 'plating from deck'

			local canPlate = canPlateIngredient(currentPlate, drawPile[ui[selection].drawIndex])
			if canPlate then
				plateCardFromDeck(ui[selection].drawIndex)
			else
				animationText = 'No bread, discarding '..cardDetails[drawPile[ui[selection].drawIndex]].label
				wait(0.75 * animationScale * (1/userAnimationScale))
				discardCardFromDeck(ui[selection].drawIndex)
			end

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
			shuffleDrawPile(2)

			-- insert selected card at top of draw pile
			table.insert(drawPile, 1, modalCards[ui[selection].drawIndex])

			minimizeModal()
			modalActive = false

			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are choosing to skip or close the modal action...
	local isSelectingModalAction = ui[selection].modal and ui[selection].action and not settingsModalActive
	local modalAction = isSelectingModalAction and modalActions[ui[selection].actionIndex]
	local isSelectingSkip = isSelectingModalAction and modalAction == 'skip' or modalAction == 'close' or modalAction == 'start'
	if key == 'select' and isSelectingSkip then
		async(routines, function()
			-- if the modal action was start, start the music
			if modalActions[1] == 'start' then
				-- if we have the intro track, play it now
				-- (if we restarted, this will be nil)
				if intro then
					intro:setLooping(false)
				end

				hasStarted = true
				-- set the game seed now (if gameseed is nil)
				if gameSeed == nil then
					loadSeed()
				end
				-- now that we've loaded a seed, do a shuffle of the deck
				shuffleDrawPile(drawSize)
			end

			-- if the modal action was add, we still need to shuffle here
			if modalActions[1] == 'add' then
				shuffleDrawPile(2)
			end

			minimizeModal()
			modalActive = false

			updateSelectionAfterPlayOrDraw()
		end)
	end

	local isSelectingEndless = isSelectingModalAction and modalActions[ui[selection].actionIndex] == 'endless'
	if key == 'select' and isSelectingEndless then
		async(routines, function()
			minimizeModal()
			modalActive = false

			startNextRoundModal()
		end)
	end

	local isSelectingRestart = isSelectingModalAction and modalActions[ui[selection].actionIndex] == 'restart'
	if key == 'select' and isSelectingRestart then
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
			shuffleDrawPile(drawSize)

			updateSelectionAfterPlayOrDraw()
		end)
	end

	-- if we are selecting a checkbox toggle
	if key == 'select' and selection == 'settingsTTSCheckbox' then
		if ttsEnabled then
			ttsEnabled = false
			selectionText = 'Text to speech disabled'
			disableTTS()
		else
			ttsEnabled = true
			selectionText = 'Text to speech enabled'
			enableTTS()
		end
	end

	-- non-modal action selection
	if key == 'select' and ui[selection].action then
		async(routines, function()
			if selection == 'actionDraw' then
				drawThree()
			end
			if selection == 'actionNewPlate' then
				animationText = 'Scoring Plate'
				playStackSFX()
				wait(1 * animationScale * (1/userAnimationScale))

				completePlate()
				if not modalActive then
					drawThree()
				end
			end
		end)
	end

	-- if we are selecting settings
	if key == 'select' and ui[selection].settingsControl then
		async(routines, function()
			startSettingsModal()
		end)
	end

	-- repeat text if r was pressed
	if key == "r" then
		async(routines, function()
			repeatText()
		end)
	end

	if key == 'escape' then
		async(routines, function()
			if not settingsModalActive then
				startSettingsModal()
			else
				minimizeSettingsModal()
				settingsModalActive = false
				updateSelection(lastSelection)
			end
		end)
	end
end

function startTouch(x, y)
	isTouching = true
	touchTime = 0
	startTouchPos = { x = x, y = y }
end

function getElementAt(x, y)
	local handIsEmpty = getHandSize() == 0

	for selectionKey, uiElement in pairs(ui) do
		if uiElement.selectable then
			-- check if the mouse / touch is within a selectable ui element
			local isWithinX = x > uiElement.x and x < uiElement.x + uiElement.width
			local isWithinY = y > uiElement.y and y < uiElement.y + uiElement.height

			-- if we are within the x and y of an element,
			-- make sure that that element is valid for the current state we are in
			if isWithinX and isWithinY then
				if uiElement.settingsModal or settingsModalActive then
					if uiElement.settingsModal and settingsModalActive then
						return selectionKey
					end
				elseif modalActive or uiElement.modal then
					if modalActive and uiElement.modal then
						return selectionKey
					end
				else
					if uiElement.hand then
						if not handIsEmpty then
							return selectionKey
						end
					elseif uiElement.action then
						if handIsEmpty and not uiElement.modal then
							return selectionKey
						end
					else
						return selectionKey
					end
				end
			end
		end
	end
end

function selectElementAt(x, y)
	selectionKey = getElementAt(x, y)

	if selectionKey and (selectionKey ~= selection) then
		updateSelection(selectionKey, true)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	-- if we had started a countdown for a single tap, kill it now
	stopAnimations(tapRoutines)

	x, y = push:toGame(x, y)
	if (x == nil or y == nil) then
		return
	end

	-- sometimes we get a mousemoved event BEFORE a mouse press;
	-- mark that we are starting a touch interaction and return early
	if istouch and isTouching == false then
		startTouch(x, y)
		return
	end

	if istouch then
		-- if we are below swipeTimeThreshold, we could be swiping
		if touchTime < swipeTimeThreshold then
			return
		end

		-- otherwise, consider this a search
		-- (do selectElementAt at the end)
	end

	-- if we are animating, don't do anything
	local isAnimating = #routines > 0
	if isAnimating then
		return
	end

	selectElementAt(x, y)
end

function love.mousepressed(x, y, button, istouch, presses)
	-- if we had started a countdown for a single tap, kill it now
	stopAnimations(tapRoutines)

	x, y = push:toGame(x, y)
	if (x == nil or y == nil) then
		return
	end

	if istouch then
		startTouch(x, y)
	end

	DebuggingScreen.mousepressed(x, y)
end

function love.mousereleased(x, y, button, istouch, presses)
	isTouching = false

	-- if we had started a countdown for a single tap, kill it now
	stopAnimations(tapRoutines)

	x, y = push:toGame(x, y)
	if (x == nil or y == nil) then
		return
	end

	-- if this is a mouse click (not a touchscreen tap),
	-- if we clicked an element, select it
	if not istouch then
		clickedElement = getElementAt(x, y)
		if clickedElement then
			love.keypressed('select')
		end
	end

	-- if we get a double tap, select whatever element has focus
	if istouch and presses > 1 then
		touchTime = 0
		love.keypressed('select')
	end

	if istouch and presses == 1 then
		-- determine how much x and y we moved
		dx = x - startTouchPos.x
		dy = y - startTouchPos.y

		-- if we were holding for more than swipeTimeThreshold,
		-- don't register this as a swipe action
		-- (in either case, reset touchTime, for debugging purposes mostly)
		if touchTime > swipeTimeThreshold then
			touchTime = 0
			return
		end
		touchTime = 0

		-- if dx and dy are 0, this was just a tap
		isSingleTap = dx == 0 and dy == 0

		-- check if there is an element under the tapped selection
		tappedSelection = getElementAt(x, y)

		-- if this is a single tap, and they are selecting an element
		-- start a counter to track if this was only a single tap
		if isSingleTap then
			if tappedSelection then
				async(tapRoutines, function()
					local elapsed = 0

					while elapsed < singleTouchThreshold do
						local dt = coroutine.yield()
						elapsed = elapsed + (dt or 0)
					end

					-- if we haven't killed this routine, select this element
					selectElementAt(x, y)
					wait(0.05)
					love.keypressed('select')
				end)
			end
			return
		end

		abs_dx = math.abs(dx)
		abs_dy = math.abs(dy)

		if abs_dx > abs_dy then
			if dx > 0 then
				love.keypressed('right')
			else
				love.keypressed('left')
			end
		else
			if dy > 0 then
				love.keypressed('down')
			else
				love.keypressed('up')
			end
		end
	end

	DebuggingScreen.mousereleased(x, y)
end
