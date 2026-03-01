local navSound = love.sound.newSoundData('Assets/nav.wav')
local navSource = love.audio.newSource(navSound)

function playNavSFX()
	navSource:setVolume(sfxVolume * masterVolume)
	navSource:play()
end

local dropSound = love.sound.newSoundData('Assets/drop.wav')
local dropSource = love.audio.newSource(dropSound)

function playDropSFX()
	dropSource:setVolume(sfxVolume * masterVolume)
	dropSource:play()
end

local shuffleSound = love.sound.newSoundData('Assets/shuffle.wav')
local shuffleSource = love.audio.newSource(shuffleSound)

function playShuffleSFX()
	shuffleSource:setVolume(sfxVolume * masterVolume)
	shuffleSource:play()
end

local tossSound = love.sound.newSoundData('Assets/toss.wav')
local tossSource = love.audio.newSource(tossSound)

function playTossSFX()
	tossSource:setVolume(sfxVolume * masterVolume)
	tossSource:play()
end

local stackSound = love.sound.newSoundData('Assets/stack.wav')
local stackSource = love.audio.newSource(stackSound)

function playStackSFX()
	stackSource:setVolume(sfxVolume * masterVolume)
	stackSource:play()
end

local dealSound = love.sound.newSoundData('Assets/deal.wav')
local dealSource = love.audio.newSource(dealSound)

function playDealSFX()
	dealSource:setVolume(sfxVolume * masterVolume)
	dealSource:play()
end

local pushSound = love.sound.newSoundData('Assets/push.wav')
local pushSource = love.audio.newSource(pushSound)

function playPushSFX()
	pushSource:setVolume(sfxVolume * masterVolume)
	pushSource:play()
end

local pullSound = love.sound.newSoundData('Assets/pull.wav')
local pullSource = love.audio.newSource(pullSound)

function playPullSFX()
	pullSource:setVolume(sfxVolume * masterVolume)
	pullSource:play()
end

local discardSound = love.sound.newSoundData('Assets/discard.wav')
local discardSource = love.audio.newSource(discardSound)

function playDiscardSFX()
	discardSource:setVolume(sfxVolume * masterVolume)
	discardSource:play()
end

local highSound = love.sound.newSoundData('Assets/high.wav')
local highSource = love.audio.newSource(highSound)

function playhighSFX()
	highSource:setVolume(sfxVolume * masterVolume)
	highSource:play()
end
