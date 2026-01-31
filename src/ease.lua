-- easing functions based on "Animation Curves cheat sheet/library":
-- https://www.lexaloffle.com/bbs/?tid=40577

local ease = {}

-- default linear motion
function ease.linear(t) return t end

-- Quadratic functions
function ease.inquad(t)
	return t*t
end

function ease.outquad(t)
	t=t-1
	return 1-t*t
end

function ease.inoutquad(t)
	if(t<.5) then
		return t*t*2
	else
		t=t-1
		return 1-t*t*2
	end
end

function ease.outinquad(t)
	if t<.5 then
		t=t-.5
		return .5-t*t*2
	else
		t=t-.5
		return .5+t*t*2
	end
end

-- Quartic functions
-- these are very similar to quadratics, but flatter at the start and steeper towards the end

function ease.inquart(t)
	return t*t*t*t
end

function ease.outquart(t)
	t=t-1
	return 1-t*t*t*t
end

function ease.inoutquart(t)
	if t<.5 then
		return 8*t*t*t*t
	else
		t=t-1
		return (1-8*t*t*t*t)
	end
end

function ease.outinquart(t)
	if t<.5 then
		t=t-.5
		return .5-8*t*t*t*t
	else
		t=t-.5
		return .5+8*t*t*t*t
	end
end

-- Overshooting functions
-- these functions overshoot the range slightly and then return to it

function ease.inovershoot(t)
	return 2.7*t*t*t-1.7*t*t
end

function ease.outovershoot(t)
	t=t-1
	return 1+2.7*t*t*t+1.7*t*t
end

function ease.inoutovershoot(t)
	if(t<.5) then
		return (2.7*8*t*t*t-1.7*4*t*t)/2
	else
		t=t-1
		return 1+(2.7*8*t*t*t+1.7*4*t*t)/2
	end
end

function ease.outinovershoot(t)
	if t<.5 then
		t=t-.5
		return (2.7*8*t*t*t+1.7*4*t*t)/2+.5
	else
		t=t-.5
		return (2.7*8*t*t*t-1.7*4*t*t)/2+.5
	end
end

-- Elastic functions
-- these functions overshoot slightly and then oscillate near the edges of the range,
-- like an elastic band

function ease.inelastic(t)
	if(t==0) then return 0 end
	return 2^(10*t-10)*math.cos(2*t-2)
end

function ease.outelastic(t)
	if(t==1) then return 1 end
	return 1-2^(-10*t)*math.cos(2*t)
end

function ease.inoutelastic(t)
	if t<.5 then
		return 2^(10*2*t-10)*math.cos(2*2*t-2)/2
	else
		t=t-.5
		return 1-2^(-10*2*t)*math.cos(2*2*t)/2
	end
end

function ease.outinelastic(t)
	if t<.5 then
		return .5-2^(-10*2*t)*math.cos(2*2*t)/2
	else
		t=t-.5
		return 2^(10*2*t-10)*math.cos(2*2*t-2)/2+.5
	end
end

-- Bouncing functions
-- these functions hit the edge values early, then bounce back a few times

function ease.inbounce(t)
	t=1-t
	local n1=7.5625
	local d1=2.75

	if (t<1/d1) then
		return 1-n1*t*t;
	elseif(t<2/d1) then
		t=t-1.5/d1
		return 1-n1*t*t-.75;
	elseif(t<2.5/d1) then
		t=t-2.25/d1
		return 1-n1*t*t-.9375;
	else
		t=t-2.625/d1
		return 1-n1*t*t-.984375;
	end
end

function ease.outbounce(t)
	local n1=7.5625
	local d1=2.75

	if (t<1/d1) then
		return n1*t*t;
	elseif(t<2/d1) then
		t=t-1.5/d1
		return n1*t*t+.75;
	elseif(t<2.5/d1) then
		t=t-2.25/d1
		return n1*t*t+.9375;
	else
		t=t-2.625/d1
		return n1*t*t+.984375;
	end
end

return ease
