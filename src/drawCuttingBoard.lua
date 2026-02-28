local cuttingBoardAsset = love.graphics.newImage('Assets/cutting_board.png')

function drawCuttingBoard(x, y)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(cuttingBoardAsset, x, y, 0, 0.9)
end
