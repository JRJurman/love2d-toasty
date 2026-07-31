
-- for unknown reasons, love.js can sometimes read the arrow keys in safari as the following
-- https://github.com/JRJurman/love2d-a11y-template/issues/1
local hardware_remap = {
  kp8 = "up",
  kp2 = "down",
  kp4 = "left",
  kp6 = "right",
}

local keyboard_remap = {
	w = "up",
	a = "left",
	s = "down",
	d = "right",
	r = "repeat",

	x = "select",
	space = "select",
	["return"] = "select",
}

local player_remap = {}

function keyboardRemap(key)
	key = hardware_remap[key] or key
	key = keyboard_remap[key] or key

	return key
end

local controller_remap = {
	a = "select",
	b = "select",
	x = "select",
	y = "select",

	leftshoulder = "repeat",
	rightshoulder = "repeat",

	back = "escape",
	start = "select",

	dpup = "up",
	dpdown = "down",
	dpleft = "left",
	dpright = "right",

	space = "select",
	["return"] = "select",
}

function controllerRemap(key)
	key = controller_remap[key] or key

	return key
end
