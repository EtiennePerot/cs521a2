require 'forces'

cannonball = class('Cannonball')

local cannonballSize = 6

function cannonball:initialize(cannon, direction)
	self.cannon = cannon
	self.direction = direction
	self.pos = cannon:getTipAbsolute()
end

function cannonball:update(dt)
	self.pos, self.direction = applyGravity(self.pos, self.direction, dt)
	self.pos = self.pos:add(self.direction:scale(dt))
	return self.pos.x < 0 or self.pos.x > gameWidth or self.pos.y < 0 -- Don't check if above window, because it may fall back down
end

function cannonball:draw()
	g.setColor(224, 64, 64)
	g.circle('fill', self.pos.x, self.pos.y, cannonballSize, 10)
end
