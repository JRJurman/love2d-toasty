local sfxVolume = 1.2
local navSound = love.sound.newSoundData('Assets/nav.wav')

function playNav()
	local source = love.audio.newSource(navSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local dropSound = love.sound.newSoundData('Assets/drop.wav')

function playDrop()
	local source = love.audio.newSource(dropSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local shuffleSound = love.sound.newSoundData('Assets/shuffle.wav')

function playShuffle()
	local source = love.audio.newSource(shuffleSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local tossSound = love.sound.newSoundData('Assets/toss.wav')

function playToss()
	local source = love.audio.newSource(tossSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local stackSound = love.sound.newSoundData('Assets/stack.wav')

function playStack()
	local source = love.audio.newSource(stackSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end
