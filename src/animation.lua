local ease = require('ease')

-- animation functions using coroutines
-- "Coroutines and Animation in PICO-8" - https://youtu.be/tfGmjB72t0o

-- helper function to add routines to our global table
function async(func)
	table.insert(routines, coroutine.create(func))
end

-- helper function to pause between animations in an async call
function wait(seconds)
	local elapsed = 0
	while elapsed < seconds do
		local dt = coroutine.yield()
		elapsed = elapsed + (dt or 0)
	end
end

-- helper function to change a property on an object over time
function animate(obj, key, value, duration, easing)
	duration = duration or 0.5

	local start = obj[key]
	local elapsed = 0

	easing = easing or ease.linear

	while elapsed < duration do
		local dt = coroutine.yield()
		elapsed = elapsed + (dt or 0)
		local time = math.min(elapsed / duration, 1)
		local appliedEasing = easing(time)
		obj[key] = lerp(start, value, appliedEasing)
	end

	obj[key] = value
end

--(linear interpolation between a/b)
function lerp(a,b,t)
	return a+(b-a)*t
end

function updateAnimations(routines, dt)
	-- iterates backwards, so that removing routines doesn't cause issues
	for index = #routines, 1, -1 do
		local routine = routines[index]
		-- if this routine is done, remove it from our list of routines
		if coroutine.status(routine) == "dead" then
			table.remove(routines, index)
		else
			-- if we ran into an error, print to the console log, and then remove this routine
			local ok, error = coroutine.resume(routine, dt)
			if not ok then
				print("coroutine failed: " .. error)
				table.remove(routines, index)
			end
		end
	end
end

function stopAnimations(routines)
	-- iterates backwards, so that removing routines doesn't cause issues
	for index = #routines, 1, -1 do
		table.remove(routines, index)
	end
end
