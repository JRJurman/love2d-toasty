-- copied from Ladybud Roll

local DebuggingScreen = {}
debugging = false
points = {}
local originPoint = nil

local colors = {
	{0, 1, 0},
	{0, 1, 1},
	{1, 0, 0},
	{1, 0, 1},
	{1, 1, 0},
	{1, 1, 1},
}

function DebuggingScreen.keypressed(key)
	-- disabled for production release
	if key == 'b' then
		debugging = not debugging
		points = {}
	end
end

function DebuggingScreen.mousepressed(x, y)
	if not debugging then return end

	originPoint = {x, y}
end

function DebuggingScreen.mousereleased(x, y)
	if not debugging then return end

	originPoint = nil
	table.insert(points, {x, y})
	print('clicked - '..x..', '..y)
end

function DebuggingScreen.draw()
	if not debugging then return end

	love.graphics.setColor(0, 1, 0)

	-- draw current mouse position (circle)
	local x, y = love.mouse.getPosition()
	love.graphics.circle('fill', x, y, 3)

	-- if there is an origin point, draw a line from there to here
	if originPoint then
		love.graphics.line(originPoint[1], originPoint[2], x, y)
		love.graphics.print(math.abs(originPoint[1] - x)..', '..math.abs(originPoint[2] - y), x + 5, y - 10)
	end


	-- write current mouse position (text)
	love.graphics.print('mouse '..x..', '..y, 20, 580)

	-- draw all points that have been clicked on
	for key, point in pairs(points) do
		local colorKey = (key - 1) % #colors + 1
		love.graphics.setColor(unpack(colors[colorKey]))
		local px, py = point[1], point[2]
		love.graphics.print('point '..px..', '..py, 20, 580 - (key * 16))
		love.graphics.circle('fill', px, py, 3)
	end
end

return DebuggingScreen
