function drawPlate(x, y)
	love.graphics.setColor(201/256, 207/256, 204/256)
	love.graphics.circle('fill', x, y, 200)
	love.graphics.setColor(236/256, 237/256, 234/256)
	love.graphics.circle('fill', x - 5, y - 5, 188)

	love.graphics.setColor(201/256, 207/256, 204/256)
	love.graphics.circle('fill', x, y, 170)
	love.graphics.setColor(236/256, 237/256, 234/256)
	love.graphics.circle('fill', x + 7, y + 7, 162)
end
