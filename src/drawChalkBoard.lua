function drawChalkBoard(color, x, y, width, height)
	local radius = 20

	-- BACK
	-- top-left shading
	love.graphics.setColor(60/256, 36/256, 33/256)
	love.graphics.rectangle('fill', x, y, width, height, radius*3, radius*3)

	local borderDepth = 20
	local borderWidth = 20
	-- front of board border
	love.graphics.setColor(119/256, 72/256, 66/256)
	love.graphics.rectangle('fill', x + borderDepth, y + borderDepth, width - borderDepth, height - borderDepth, radius, radius)


	-- BOARD
	if color == 'green' then
		-- green board
		love.graphics.setColor(42/256, 87/256, 45/256)
	else
		-- black board
		love.graphics.setColor(16/256, 20/256, 31/256)
	end
	love.graphics.rectangle('fill', x + borderDepth + borderWidth, y + borderDepth + borderWidth, width - ((borderWidth + borderDepth)*2), height - ((borderWidth + borderDepth)*2))

	-- RIDGE
	local ridgeHeight = 40

	-- board ridge shadow
	love.graphics.setColor(60/256, 36/256, 33/256)
	love.graphics.rectangle('fill', x + (borderDepth*(7/8)), y + height - 60, width - borderDepth, ridgeHeight)

	-- top/left outline for board ridge (around shadow)
	love.graphics.setColor(85/256, 61/256, 44/256)
	love.graphics.rectangle('line', x + (borderDepth*(7/8)), y + height - 60, width - borderDepth, ridgeHeight)

	-- board ridge front
	love.graphics.setColor(119/256, 72/256, 66/256)
	love.graphics.rectangle('fill', x + (borderDepth*(15/8)), y + height - 60 + borderDepth, width - (borderDepth*2), ridgeHeight/2)

	-- bottom/right outline for board ridge (around front)
	love.graphics.setColor(170/256, 120/256, 88/256)
	love.graphics.rectangle('line', x + (borderDepth*(15/8)), y + height - 60 + borderDepth + (ridgeHeight/2), width - (borderDepth*2), 1)
	love.graphics.rectangle('line', x + (borderDepth*(15/8)) + width - (borderDepth*2), y + height - 60 + borderDepth, 1, ridgeHeight/2)

	-- chalk
	local chalkHeight = 30
	local chalkWidth = 120
	love.graphics.setColor(235/256, 237/256, 233/256)
	love.graphics.rectangle('fill', x + width - chalkWidth - 30, y + height - ridgeHeight - chalkHeight - (borderDepth/2), chalkWidth, chalkHeight, 15, 80)

end
