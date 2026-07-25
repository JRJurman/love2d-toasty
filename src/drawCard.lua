require('cardDetails')
require('ui')
require('drawFatRect')

-- actions
local pickAsset = love.graphics.newImage('Assets/pick.png')
local shuffleAsset = love.graphics.newImage('Assets/shuffle.png')
local alternateAsset = love.graphics.newImage('Assets/alternate.png')
local lessDrawAsset = love.graphics.newImage('Assets/less_draw.png')
local plateNowAsset = love.graphics.newImage('Assets/plate_now.png')
local removeAsset = love.graphics.newImage('Assets/remove.png')
local returnAllAsset = love.graphics.newImage('Assets/return_all.png')
local returnAsset = love.graphics.newImage('Assets/return.png')
local sideAsset = love.graphics.newImage('Assets/side.png')

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
local picklesAsset = love.graphics.newImage('Ingredients/pickles.png')
local blueberriesAsset = love.graphics.newImage('Ingredients/blueberries.png')
local bananasAsset = love.graphics.newImage('Ingredients/bananas.png')
local creamCheeseAsset = love.graphics.newImage('Ingredients/cream_cheese.png')
local pitaAsset = love.graphics.newImage('Ingredients/pita.png')
local hummusAsset = love.graphics.newImage('Ingredients/hummus.png')
local salmonAsset = love.graphics.newImage('Ingredients/salmon.png')
local tomatoAsset = love.graphics.newImage('Ingredients/tomato.png')

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
	drawSeed(x + 40, y + 30, 15, 7, 0.25)
	drawSeed(x + 24, y + 142, 18, 12, 0.25)
	drawSeed(x + 29, y + 247, 18, 8, 0.27)

	-- draw right seeds
	drawSeed(x + 255, y + 38, 15, 9, -0.27)
	drawSeed(x + 270, y + 220, 18, 8, -0.30)
end

local cardFontSize = 50
local smallCardFontSize = 40
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
		love.graphics.draw(avocadoAsset, x + 93, y + 68, 0, 0.75)
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
		love.graphics.draw(cheddarAsset, x + 105, y + 90, 0, 0.65)
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
	if card == 15 then
		love.graphics.draw(picklesAsset, x + 90, y + 90, 0, 0.65)
	end
	if card == 16 then
		love.graphics.draw(blueberriesAsset, x + 110, y + 90, 0, 0.65)
	end
	if card == 17 then
		love.graphics.draw(bananasAsset, x + 120, y + 90, 0, 0.55)
	end
	if card == 18 then
		love.graphics.draw(creamCheeseAsset, x + 90, y + 90, 0, 0.65)
	end
	if card == 19 then
		love.graphics.draw(pitaAsset, x + 90, y + 75, 0, 0.75)
	end
	if card == 20 then
		love.graphics.draw(hummusAsset, x + 90, y + 90, 0, 0.65)
	end
	if card == 21 then
		love.graphics.draw(salmonAsset, x + 20, y + 70, 0, 0.85)
	end
	if card == 22 then
		love.graphics.draw(tomatoAsset, x + 120, y + 90, 0, 0.55)
	end
end

function drawAction(x, y, card)
	love.graphics.setColor(1,1,1)
	if cardDetails[card].effectKey then
		local ability = cardDetails[card].effectKey
		if ability == 'plate' then
			love.graphics.draw(pickAsset, x + 5, y + 150, 0, 0.4)
		end
		if ability == 'shuffle' then
			love.graphics.draw(shuffleAsset, x + 5, y + 150, 0, 0.4)
		end
		if ability == 'side' then
			love.graphics.draw(sideAsset, x + 5, y + 150, 0, 0.4)
		end
		if ability == 'finish' then
			love.graphics.draw(plateNowAsset, x + 15, y + 150, 0, 0.35)
		end
		if ability == 'reduce-draw' then
			love.graphics.draw(lessDrawAsset, x + 5, y + 150, 0, 0.4)
		end
		if ability == 'small-recover' then
			love.graphics.draw(returnAsset, x + 10, y + 150, 0, 0.35)
		end
		if ability == 'decker' then
			love.graphics.draw(alternateAsset, x + 5, y + 150, 0, 0.4)
		end
		if ability == 'recover-all' then
			love.graphics.draw(returnAllAsset, x + 10, y + 150, 0, 0.35)
		end
		if ability == 'remove' then
			love.graphics.draw(removeAsset, x + 5, y + 150, 0, 0.35)
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

	-- draw card title
	love.graphics.setColor(35/256, 46/256, 53/256)
	local yOffset = -10
	love.graphics.setFont(getFont(cardFontSize))
	if #cardDetails[card].label > 11 then
		love.graphics.setFont(getFont(smallCardFontSize))
		yOffset = 0
	end
	love.graphics.printf(cardDetails[card].label, x, y + yOffset, cardSize.width, 'center')

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
