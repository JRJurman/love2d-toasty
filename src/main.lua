require('animation')
local ease = require('ease')

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- UI elements
local ui = {
	hand = {
		-- going in a direction goes to what?
		up = 'none',
		left = 'none',
		down = 'plate',
		right = 'deck',

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

		-- position and size
		x = 480,
		y = 10,
		width = 310,
		height = 200,
	}
}

local selection = 'hand'
local cursor = {
	x = ui[selection].x,
	y = ui[selection].y,
	width = ui[selection].width,
	height = ui[selection].height,
}

local	routines = {}

function love.load()
	print('tts: Created by Jesse Jurman.')
end

function love.update(dt)
	updateAnimations(routines, dt)
end

function love.draw()
	love.graphics.clear()

	love.graphics.setColor(0.98, 0.43, 0.47)

	-- draw the UI elements
	love.graphics.rectangle("line", ui.hand.x, ui.hand.y, ui.hand.width, ui.hand.height)
	love.graphics.rectangle("line", ui.served.x, ui.served.y, ui.served.width, ui.served.height)
	love.graphics.rectangle("line", ui.plate.x, ui.plate.y, ui.plate.width, ui.plate.height)
	love.graphics.rectangle("line", ui.score.x, ui.score.y, ui.score.width, ui.score.height)
	love.graphics.rectangle("line", ui.deck.x, ui.deck.y, ui.deck.width, ui.deck.height)

	-- draw the cursor
	love.graphics.setColor(0.43, 0.47, 0.98)
	love.graphics.rectangle("line", cursor.x, cursor.y, cursor.width, cursor.height)
end

-- for unknown reasons, love.js can sometimes read the arrow keys in safari as the following
-- https://github.com/JRJurman/love2d-a11y-template/issues/1
local remap = {
  kp8 = "up",
  kp2 = "down",
  kp4 = "left",
  kp6 = "right",
}

function love.keypressed(key)
	key = remap[key] or key

	if key == 'down' or key == 'up' or key == 'left' or key == 'right' then
		local nextSelection = ui[selection][key]
		print('nextSelection '..nextSelection)
		if nextSelection == 'none' then
			return
		end

		-- if they press up or down, make sure they can get back to the previous option
		if key == 'up' then
			ui[nextSelection].down = selection
		elseif key == 'down' then
			ui[nextSelection].up = selection
		end

		selection = ui[selection][key]
		print('selection: '..dump(ui[selection]))
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
	end

	-- if any key is pressed, stop any animations already running
	-- stopAnimations(routines)

	-- repeat text if r was pressed
	if key == "r" then
		async(function()
			print('tts: repeating...')
			wait(1)
			print('tts: Previous text')
		end)
	end
end
