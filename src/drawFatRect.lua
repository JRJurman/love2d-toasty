function drawFatRect(dir, thickness, x, y, width, height, radius)
	local radius = radius or 0
	local mult = 1
	if dir == 'outset' then
		mult = -1
	end

	for line=1, thickness do
		love.graphics.rectangle("line", x + (line * mult), y + (line * mult), width - (line * mult * 2), height - (line * mult * 2), radius)
	end
end
