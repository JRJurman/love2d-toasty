require('cardDetails')
require('ui')
require('drawFatRect')
local json = require('json')

local abilityMapping = {
	close = 'Preview',
	shuffle = 'Shuffle',
	pick = 'Pick'
}

function drawCard(card, x, y)
	-- get the current font (so we can unset it later)
	local currentFont = love.graphics.getFont()

	-- get the current color (so we can use it after making a black background)
	local currentColor = { love.graphics.getColor() }

	-- border and then black inside
	love.graphics.rectangle("fill", x, y, cardSize.width, cardSize.height, 20, 20)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x + 3, y + 3, cardSize.width - 6, cardSize.height - 6, 20, 20)

	-- if we have a card, draw the title, points, and ability
	if card then
		local cardFontSize = 50
		love.graphics.setFont(getFont(cardFontSize))
		love.graphics.setColor(unpack(currentColor))
		love.graphics.printf(cardDetails[card].label, x, y - 10, cardSize.width, 'center')
		local titleLineY = y + cardFontSize + 10
		love.graphics.line(x, titleLineY, x + cardSize.width, titleLineY)

		-- write the number of points on the top left
		love.graphics.print('+'..cardDetails[card].points, x + 8, titleLineY - 10)

		-- write the ability under that (so cards can stack on the right side)
		if cardDetails[card].onPlay then
			local abilityLabel = abilityMapping[cardDetails[card].onPlay.actions[1]];
			local previewLabel = '('..cardDetails[card].onPlay.previewCount..')'
			love.graphics.print(previewLabel..':'..abilityLabel, x + 8, titleLineY + 35)
		end
	end



	-- reset the font
	love.graphics.setFont(currentFont)
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
