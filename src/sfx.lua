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

local pushSound = love.sound.newSoundData('Assets/push.wav')

function playPushSFX()
	local source = love.audio.newSource(pushSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end

local pullSound = love.sound.newSoundData('Assets/pull.wav')

function playPullSFX()
	local source = love.audio.newSource(pullSound)
	source:setVolume(sfxVolume * masterVolume)
	source:play()
end
