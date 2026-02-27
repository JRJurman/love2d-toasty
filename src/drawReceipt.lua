local receiptAsset = love.graphics.newImage('Assets/receipt.png')

function drawReceipt(x, y, label)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(receiptAsset, x, y, 0, 0.80)

	love.graphics.setFont(getFont(90))
	love.graphics.setColor(35/256, 46/256, 53/256)
	love.graphics.printf(label, x + 30, y + 45, 180, 'center')
end
