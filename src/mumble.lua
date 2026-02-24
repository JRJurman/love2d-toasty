require('animation')

local mumbles = {
	love.sound.newSoundData('Assets/voice_11.wav'),
	love.sound.newSoundData('Assets/voice_12.wav'),
	love.sound.newSoundData('Assets/voice_13.wav'),
	love.sound.newSoundData('Assets/voice_14.wav'),
	love.sound.newSoundData('Assets/voice_15.wav'),
	love.sound.newSoundData('Assets/voice_16.wav'),
	love.sound.newSoundData('Assets/voice_17.wav'),
}

local mumbleVolume = 0.8

function playBlip(index)
	local source = love.audio.newSource(mumbles[index])
	source:setVolume(mumbleVolume)
	source:play()
end

local interval = 0.3
local jitter = 0.05

function mumble(routines, seconds)
	async(routines, function()
		local totalWait = 0
		while totalWait < seconds do
			print(totalWait)
			-- get a random sound
			local mumbleIndex = math.random(#mumbles)
			-- determine a random wait
			local waitTime = interval + math.random()*jitter

			-- play the sound, and wait for as long as the wait time
			playBlip(mumbleIndex)
			wait(waitTime)
			totalWait = totalWait + waitTime
		end
	end)
end
