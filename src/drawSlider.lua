function drawSlider(x, y, width, value, min, max)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", (x + 10), y, (width - 20), 20, 20, 20)
	local position = ((value - min) / max) * (width - 20)
	love.graphics.circle('fill', (x + 10) + position, y + 10, 15)
end
