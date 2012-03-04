require 'forces'
require 'shapes'

cannonball = class('Cannonball')

local cannonballSize = 6
local cannonballActivation = 0.15

function cannonball:initialize(cannon, direction)
	self.cannon = cannon
	self.direction = direction
	self.active = 0
	self.shape = circle(cannon:getTipAbsolute(), cannonballSize)
	self.touchedGround = 0
end

function cannonball:update(dt, forces, objects)
	self.active = math.min(self.active + dt, cannonballActivation)
	for f = 1, #forces do
		self.pos, self.direction = forces[f]:apply(dt, self.pos, self.direction)
	end
	self.shape.center = self.shape.center:add(self.direction:scale(dt))
	if self.active == cannonballActivation then
		for o = 1, #objects do
			if instanceOf(cannon, objects[o]) then
				local shapes = objects[o]:getShapes()
				for s = 1, #shapes do
					if shapes[s]:collide(self.shape) then
						gameOver()
					else -- It's a mountain
						-- todo
					end
				end
			end
		end
	end
	return self.shape.center.x < 0 or self.shape.center.x > gameWidth or self.shape.center.y < 0 -- Don't check if above window, because it may fall back down
end

function cannonball:draw()
	g.setColor(224, 64, 64, self.active * 255 * (1 - self.touchedGround) / cannonballActivation)
	self.shape:draw()
end
