local push = require "push"

function resize(width, height, prevIsTall)
	isTall = width < height

	-- setup for push.lua, library to preserve aspect ratio
	local gameWidth = isTall and 1080 or 1600
	local gameHeight = isTall and 1920 or 1200

	-- we call setupScreen if we need to change the layout (or isTall was nil)
	if (prevIsTall ~= isTall) then
		push:setupScreen(gameWidth, gameHeight, width, height, {fullscreen = false, resizable = true})
	else
		push:resize(width, height)
	end

	-- update ui elements to either a mobile or desktop layout
	if isTall then
		toMobileLayout()
	else
		toDesktopLayout()
	end
end
