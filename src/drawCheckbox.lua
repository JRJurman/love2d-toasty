function drawCheckbox(x, y, value)
	love.graphics.setFont(getFont(45))
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", (x + 10), y, 30, 30, 5, 5)
	if value then
		love.graphics.print('x', x + 13, y - 28)
	end
end
