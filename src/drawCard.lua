require('cardDetails')
require('ui')
require('drawFatRect')

-- actions
local pickAsset = love.graphics.newImage('Assets/pick.png')
local shuffleAsset = love.graphics.newImage('Assets/shuffle.png')

-- ingredients
local breadAsset = love.graphics.newImage('Ingredients/bread.png')
local butterAsset = love.graphics.newImage('Ingredients/butter.png')
local avocadoAsset = love.graphics.newImage('Ingredients/avocado.png')
local strawberryAsset = love.graphics.newImage('Ingredients/strawberry.png')
local whipCreamAsset = love.graphics.newImage('Ingredients/whip_cream.png')
local jamAsset = love.graphics.newImage('Ingredients/jam.png')
local orangeAsset = love.graphics.newImage('Ingredients/orange.png')
local eggAsset = love.graphics.newImage('Ingredients/egg.png')
local cheddarAsset = love.graphics.newImage('Ingredients/cheddar.png')
local garlicAsset = love.graphics.newImage('Ingredients/garlic.png')
local onionAsset = love.graphics.newImage('Ingredients/onion.png')
local ricottaAsset = love.graphics.newImage('Ingredients/ricotta.png')
local sausageAsset = love.graphics.newImage('Ingredients/sausage.png')
local baconAsset = love.graphics.newImage('Ingredients/bacon.png')


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

function drawIngredient(x, y, card)
	love.graphics.setColor(1,1,1)
	if card == 1 then
		love.graphics.draw(breadAsset, x + 48, y + 75, 0, 0.70)
	end
	if card == 2 then
		love.graphics.draw(butterAsset, x + 50, y + 85, 0, 0.80)
	end
	if card == 3 then
		love.graphics.draw(avocadoAsset, x + 90, y + 65, 0, 0.75)
	end
	if card == 4 then
		love.graphics.draw(strawberryAsset, x + 75, y + 65, 0, 0.78)
	end
	if card == 5 then
		love.graphics.draw(whipCreamAsset, x + 65, y + 90, 0, 0.70)
	end
	if card == 6 then
		love.graphics.draw(jamAsset, x + 110, y + 100, 0, 0.60)
	end
	if card == 7 then
		love.graphics.draw(orangeAsset, x + 90, y + 80, 0, 0.75)
	end
	if card == 8 then
		love.graphics.draw(eggAsset, x + 25, y + 60, 0, 0.85)
	end
	if card == 9 then
		love.graphics.draw(cheddarAsset, x + 115, y + 65, 0, 0.60)
	end
	if card == 10 then
		love.graphics.draw(garlicAsset, x + 110, y + 90, 0, 0.60)
	end
	if card == 11 then
		love.graphics.draw(onionAsset, x + 75, y + 65, 0, 0.80)
	end
	if card == 12 then
		love.graphics.draw(ricottaAsset, x + 75, y + 65, 0, 0.70)
	end
	if card == 13 then
		love.graphics.draw(sausageAsset, x + 90, y + 70, 0, 0.70)
	end
	if card == 14 then
		love.graphics.draw(baconAsset, x + 90, y + 90, 0, 0.65)
	end
end

function drawAction(x, y, card)
	love.graphics.setColor(1,1,1)
	if cardDetails[card].onPlay then
		local ability = cardDetails[card].onPlay.actions[1];
		if ability == 'plate' then
			love.graphics.draw(pickAsset, x + 5, y + 150, 0, 0.4)
		end
		if ability == 'shuffle' then
			love.graphics.draw(shuffleAsset, x + 5, y + 150, 0, 0.4)
		end
	end
end

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

	-- draw card title
	love.graphics.setFont(getFont(cardFontSize))
	love.graphics.printf(cardDetails[card].label, x, y - 10, cardSize.width, 'center')

	-- draw card points
	if cardDetails[card].points > 0 then
		love.graphics.setFont(getFont(titleFontSize))
		love.graphics.print('+'..cardDetails[card].points, x + 18, y + 45)
	end

	-- draw ingredient
	drawIngredient(x, y, card)

	-- draw the ability
	drawAction(x, y, card)
end

function drawCard(card, x, y)
	-- get the current font (so we can unset it later)
	local currentFont = love.graphics.getFont()

	-- get the current color (so we can use it after making a black background)
	local currentColor = { love.graphics.getColor() }

	-- if this is the deck or discard, draw the card back
	local isCardBack = card == 0 or card == -1
	if isCardBack then
		drawCardBack(x, y)

		love.graphics.setColor(unpack(currentColor))
		love.graphics.setFont(getFont(cardFontSize))
		love.graphics.printf(cardDetails[card].label, x, y - 10, cardSize.width, 'center')
	end

	-- if we have a face up card, draw the title, points, and ability
	if card and not isCardBack then
		drawCardFront(x, y, card)
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
