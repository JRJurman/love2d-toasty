require('cardDetails')
require('ui')
require('drawFatRect')
local json = require('json')

local abilityMapping = {
	close = 'Preview',
	shuffle = 'Shuffle',
	pick = 'Pick',
	plate = 'Plate'
}

function drawSeed(x, y, rx, ry, rotation)
	-- translate so that the origin is at the card center
	love.graphics.translate(x, y)

	-- rotate by a predetermined random amount
	love.graphics.rotate(rotation)
	love.graphics.ellipse('fill', 0, 0, rx, ry)

		-- reset rotation
	love.graphics.origin()
end

function drawCardBack(x, y)
	-- draw background
	love.graphics.setColor(145/256, 102/256, 72/256)
	love.graphics.rectangle("fill", x, y, cardSize.width, cardSize.height, 30, 30)

	-- draw left seeds
	love.graphics.setColor(190/256, 162/256, 132/256)
	-- love.graphics.ellipse('fill', x + 40, y + 30, 15, 7)
	drawSeed(x + 40, y + 30, 15, 7, 0.25)

	-- love.graphics.ellipse('fill', x + 24, y + 142, 18, 12)
	drawSeed(x + 24, y + 142, 18, 12, 0.25)

	-- love.graphics.ellipse('fill', x + 29, y + 247, 18, 8)
	drawSeed(x + 29, y + 247, 18, 8, 0.27)

	-- draw right seeds
	-- love.graphics.ellipse('fill', x + 255, y + 38, 15, 9)
	drawSeed(x + 255, y + 38, 15, 9, -0.27)
	-- love.graphics.ellipse('fill', x + 270, y + 220, 18, 8)
	drawSeed(x + 270, y + 220, 18, 8, -0.30)
end

local cardFontSize = 50
local titleFontSize = 80

function drawCardFront(x, y, card)
	-- draw background
	love.graphics.setColor(228/256, 214/256, 183/256)
	love.graphics.rectangle("fill", x, y, cardSize.width, cardSize.height, 30, 30)

	-- draw header and body background
	love.graphics.setColor(235/256, 237/256, 233/256)
	love.graphics.rectangle("fill", x + 10, y + 7, cardSize.width - 20, 55, 20, 20)

	love.graphics.setColor(235/256, 237/256, 233/256)
	love.graphics.rectangle("fill", x + 10, y + 70, cardSize.width - 20, 220, 20, 20)

	love.graphics.setColor(35/256, 46/256, 53/256)

	love.graphics.setFont(getFont(cardFontSize))
	love.graphics.printf(cardDetails[card].label, x, y - 10, cardSize.width, 'center')

	love.graphics.setFont(getFont(titleFontSize))
	love.graphics.print('+'..cardDetails[card].points, x + 18, y + 45)
end

function drawCard(card, x, y)
	-- get the current font (so we can unset it later)
	local currentFont = love.graphics.getFont()

	-- get the current color (so we can use it after making a black background)
	local currentColor = { love.graphics.getColor() }

	-- if this is the deck or discard, draw the card back
	if card == 0 or card == -1 then
		drawCardBack(x, y)

		love.graphics.setColor(unpack(currentColor))
		love.graphics.setFont(getFont(cardFontSize))
		love.graphics.printf(cardDetails[card].label, x, y - 10, cardSize.width, 'center')
	end

	-- if we have a face up card, draw the title, points, and ability
	if card and card ~= 0 and card ~= -1 then
		drawCardFront(x, y, card)

		-- write the number of points on the top left
		if cardDetails[card].points then
			-- love.graphics.print('+'..cardDetails[card].points, x + 8, titleLineY - 10)
		end

		-- write the ability under that (so cards can stack on the right side)
		if cardDetails[card].onPlay then
			local abilityLabel = abilityMapping[cardDetails[card].onPlay.actions[1]];
			-- love.graphics.print(abilityLabel, x + 8, titleLineY + 35)
		end
	end

	-- reset the font
	love.graphics.setFont(currentFont)
	love.graphics.setColor(unpack(currentColor))
end

-- build a list of rotation values that we can consistently render
local rotations = {}
for i=1,50 do
	table.insert(rotations, (math.random() - 0.5)/2)
end

function drawRotatedCard(card, x, y, rotationIndex)
	-- translate so that the origin is at the card center
	love.graphics.translate(x + (cardSize.width/2), y + (cardSize.height/2))

	-- rotate by a predetermined random amount
	love.graphics.rotate(rotations[rotationIndex])

	-- draw the card (offset based on the above translation)
	drawCard(card, -cardSize.width/2, -cardSize.height/2)

	-- reset rotation
	love.graphics.origin()
end
