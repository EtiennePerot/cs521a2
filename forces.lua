require 'vector'

local gravityForce = vector(0, -384)
function applyGravity(position, speed, dt)
	return position, speed:add(gravityForce:scale(dt))
end
