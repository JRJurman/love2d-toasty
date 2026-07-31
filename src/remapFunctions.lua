
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
	key = player_remap[key] or key

	return key
end
