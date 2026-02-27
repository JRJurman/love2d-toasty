local chefAsset = love.graphics.newImage('Assets/chef.png')

function drawChef(x, y)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(chefAsset, x, y, 0, 0.80)
end
