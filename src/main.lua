require('animation')
local ease = require('ease')

-- UI elements
local ui = {
	hand = {
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
	card1 = {
		-- going in a direction goes to what?
		up = 'hand',
		left = 'none',
		down = 'none',
		right = 'card2',
		select = 'none',

		-- position and size
		x = 40,
		y = 30,
		width = 125,
		height = 125,
	},
	card2 = {
		-- going in a direction goes to what?
		up = 'hand',
		left = 'card1',
		down = 'none',
		right = 'card3',
		select = 'none',

		-- position and size
		x = 175,
		y = 30,
		width = 125,
		height = 125,
	},
	card3 = {
		-- going in a direction goes to what?
		up = 'hand',
		left = 'card2',
		down = 'none',
		right = 'none',
		select = 'none',

		-- position and size
		x = 310,
		y = 30,
		width = 125,
		height = 125,
	},
}

local deck = {
	'A', 'A', 'A', 'A',
	'1', '1', '2', '2',
	'3', '3', '4', '4',
	'5', '5', '6', '6',
	'7', '7', '8', '8',
	'9', '9', '9', '9',
}

local selection = 'hand'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local	routines = {}
local ttsText = ''

function love.load()
	print('tts: Created by Jesse Jurman.')
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
	love.graphics.rectangle("line", ui.card1.x, ui.card1.y, ui.card1.width, ui.card1.height)
	love.graphics.rectangle("line", ui.card2.x, ui.card2.y, ui.card2.width, ui.card2.height)
	love.graphics.rectangle("line", ui.card3.x, ui.card3.y, ui.card3.width, ui.card3.height)

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	love.graphics.rectangle("line", cursor.x, cursor.y, cursor.width, cursor.height)
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

	if key == 'down' or key == 'up' or key == 'left' or key == 'right' or key == 'select' then
		local nextSelection = ui[selection][key]
		if nextSelection == 'none' then
			return
		end

		-- if they press up or down, make sure they can get back to the previous option
		-- don't do this if they are in a hand selection
		local isCardSelection = selection == 'card1' or selection == 'card2' or selection == 'card3'
		if key == 'up' and not isCardSelection then
			ui[nextSelection].down = selection
		elseif key == 'down' and not isCardSelection then
			ui[nextSelection].up = selection
		end

		selection = ui[selection][key]
		local posEaseFunction = ease.inovershoot
		local sizeEaseFunction = ease.inovershoot
		local animationSpeed = 0.35
		async(routines, function()
			animate(cursor, "x", ui[selection].x, animationSpeed, posEaseFunction)
		end)
		async(routines, function()
			animate(cursor, "y", ui[selection].y, animationSpeed, posEaseFunction)
		end)
		async(routines, function()
			animate(cursor, "width", ui[selection].width, animationSpeed, sizeEaseFunction)
		end)
		async(routines, function()
			animate(cursor, "height", ui[selection].height, animationSpeed, sizeEaseFunction)
		end)

		local navDirections = 'Use the following keys to change selection: '
		if ui[selection].select ~= 'none' then
			navDirections = navDirections..' select, '..ui[selection].select..'. '
		end
		if ui[selection].up ~= 'none' then
			navDirections = navDirections..' up, '..ui[selection].up..'; '
		end
		if ui[selection].down ~= 'none' then
			navDirections = navDirections..' down, '..ui[selection].down..'; '
		end
		if ui[selection].left ~= 'none' then
			navDirections = navDirections..' left, '..ui[selection].left..'; '
		end
		if ui[selection].right ~= 'none' then
			navDirections = navDirections..' right, '..ui[selection].right..'. '
		end
		ttsText = selection..' selected. '..navDirections
		print('tts: '..ttsText)
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
