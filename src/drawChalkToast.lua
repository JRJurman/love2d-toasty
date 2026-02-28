local chalkToastAsset = love.graphics.newImage('Assets/chalk_toast.png')

function drawChalkToast(x, y)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(chalkToastAsset, x, y, 0, 1)
end
