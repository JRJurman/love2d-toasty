require('animation')
local ease = require('ease')

-- all the options listed (this is so that we can navigate between them, not usually required)
local easingOptions = {
	'linear',
	'inquad',
	'outquad',
	'inoutquad',
	'outinquad',
	'inquart',
	'outquart',
	'inoutquart',
	'outinquart',
	'inovershoot',
	'outovershoot',
	'inoutovershoot',
	'outinovershoot',
	'inelastic',
	'outelastic',
	'inoutelastic',
	'outinelastic',
	'inbounce',
	'outbounce',
}

-- accessible descriptions for each option
local easingOptionDescriptions = {
  linear =
    "linear, moves at a constant speed from start to end, with no acceleration or deceleration.",

  inquad =
    "in quad, starts slowly and continuously speeds up toward the end.",

  outquad =
    "out quad, starts quickly and gradually slows down as it reaches the end.",

  inoutquad =
    "in out quad, starts slowly, speeds up in the middle, then slows down at the end.",

  outinquad =
    "out in quad, starts quickly, slows down in the middle, then speeds up again at the end.",

  inquart =
    "in quart, starts very slowly, then accelerates sharply near the end.",

  outquart =
    "out quart, starts very fast, then decelerates sharply as it approaches the end.",

  inoutquart =
    "in out quart, move very slow at the beginning and end, with a strong acceleration through the middle.",

  outinquart =
    "out in quart, moves fast at the start and end, with a pronounced slowdown and pause in the middle.",

  inovershoot =
    "in overshoot, pulls back before the start, and then springs toward the end.",

  outovershoot =
    "out overshoot, moves quickly toward the target, overshoots it, then eases back into place.",

  inoutovershoot =
    "in out overshoot, pulls back before the start, and then springs forward overshooting the end.",

  outinovershoot =
    "out in overshoot, overshoots the center early, slows, and then springs towards the end.",

  inelastic =
    "in elastic, begins slowly, then springs forward to the end.",

  outelastic =
    "out elastic, starts quickly, and slows before reaching the end.",

  inoutelastic =
    "in out elastic, has a pause before springing toward the center, and then slowing down at the end.",

  outinelastic =
    "out in elastic, moves quickly to the center, pauses, and then quickly to the end.",

  inbounce =
    "in bounce, bounces at the start point, and then springs to the end",

  outbounce =
    "out bounce, hits the target early, then bounces backward and forward before settling.",
}


local initX = 200
local initY = 50
local finalX = 500
local squareSize = 30

local animationSelection = 1

function love.load()
	square = { x=initX, y=initY}
	routines = {}

	print('tts: Animations Demo, there is a square on a track, and several animation functions listed on the left. Press up or down to move between animation options and make the square move, press any other key to repeat the animation.')
end

function love.update(dt)
	updateAnimations(routines, dt)
end

function love.draw()
	love.graphics.clear()

	-- draw the square
	love.graphics.setColor(0.98, 0.43, 0.47)
	love.graphics.rectangle("fill", square.x, square.y, squareSize, squareSize)

	-- draw a line that the square animates on
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.rectangle("fill", initX + squareSize/2, initY + squareSize/2, finalX - initX, 2)

	-- print each easing function
	local easeTextPos = { x=32, y=32}
	for index, name in ipairs(easingOptions) do
		if index == animationSelection then
			love.graphics.setColor(0.98, 0.43, 0.47)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print(index..': '..name, easeTextPos.x, easeTextPos.y)
		easeTextPos.y = easeTextPos.y + 16
	end

	-- print the description beneath the animation
	local description = easingOptionDescriptions[easingOptions[animationSelection]]
	love.graphics.print(description, initX, initY + 80)
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

	-- if any key is pressed, stop any animations already running
	stopAnimations(routines)

	if key == "down" then
		if animationSelection < #easingOptions then
			animationSelection = animationSelection + 1
		end
		print('tts: '..easingOptionDescriptions[easingOptions[animationSelection]])
	end

	if key == "up" then
		if animationSelection > 1 then
			animationSelection = animationSelection - 1
		end
		print('tts: '..easingOptionDescriptions[easingOptions[animationSelection]])
	end

	-- repeat text if r was pressed
	if key == "r" then
		async(function()
			print('tts: repeating...')
			wait(1)
			print('tts: '..easingOptionDescriptions[easingOptions[animationSelection]])
		end)
	end

	async(function()
		square.x = initX
		animate(square, "x", finalX, 2, ease[easingOptions[animationSelection]])
	end)
end
