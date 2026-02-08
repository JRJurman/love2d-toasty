require('cardDetails')
require('ui')
require('drawFatRect')
local json = require('json')

function drawCard(card, x, y)
	local currentColor = { love.graphics.getColor() }
	love.graphics.rectangle("fill", x, y, cardSize.width, cardSize.height, 20, 20)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x + 3, y + 3, cardSize.width - 6, cardSize.height - 6, 20, 20)
	love.graphics.setColor(unpack(currentColor))
	love.graphics.printf(cardDetails[card].label, x, y + 5, cardSize.width, 'center')
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
