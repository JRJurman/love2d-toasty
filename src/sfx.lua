local sfxVolume = 1.2
local navSound = love.sound.newSoundData('Assets/nav.wav')

function playNavSFX()
	local source = love.audio.newSource(navSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local dropSound = love.sound.newSoundData('Assets/drop.wav')

function playDropSFX()
	local source = love.audio.newSource(dropSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local shuffleSound = love.sound.newSoundData('Assets/shuffle.wav')

function playShuffleSFX()
	local source = love.audio.newSource(shuffleSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local tossSound = love.sound.newSoundData('Assets/toss.wav')

function playTossSFX()
	local source = love.audio.newSource(tossSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local stackSound = love.sound.newSoundData('Assets/stack.wav')

function playStackSFX()
	local source = love.audio.newSource(stackSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local dealSound = love.sound.newSoundData('Assets/deal.wav')

function playDealSFX()
	local source = love.audio.newSource(dealSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end
