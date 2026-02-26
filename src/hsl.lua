-- from https://www.love2d.org/wiki/HSL_color

-- Converts HSL to RGB. (input and output range: 0 - 1)
function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h*6, s, l
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return r+m, g+m, b+m, a
end

function hueToColor(hue)
	local roughHue = math.floor(hue * 10)
	if roughHue == 0 then
		return 'red'
	elseif roughHue == 1 then
		return 'orange'
	elseif roughHue == 2 then
		return 'yellow'
	elseif roughHue == 3 then
		return 'bright green'
	elseif roughHue == 4 then
		return 'green'
	elseif roughHue == 5 then
		return 'teal'
	elseif roughHue == 6 then
		return 'blue'
	elseif roughHue == 7 then
		return 'purple'
	elseif roughHue == 8 then
		return 'magenta'
	elseif roughHue == 9 then
		return 'pink'
	else
		return 'red'
	end
end
