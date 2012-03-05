require 'forces'
require 'shapes'
require 'water'

cannonball = class('Cannonball')

local cannonballSize = 6
local cannonballActivation = 0.15

function cannonball:initialize(cannon, direction)
	self.cannon = cannon
	self.direction = direction
	self.active = 0
	self.shape = circle(cannon:getTipAbsolute(), cannonballSize)
	self.touchedGround = 0
	self.red = math.random(64, 255)
	self.green = math.random(64, 255)
	self.blue = math.random(64, 255)
end

function cannonball:forcePass(dt, forces, waterLevel)
	self.active = math.min(self.active + dt, cannonballActivation)
	for f = 1, #forces do
		self.shape.center, self.direction = forces[f]:apply(dt, self.shape.center, self.direction)
	end
	self.shape.center = self.shape.center:add(self.direction:scale(dt))
	return self.shape.center.x < 0 or self.shape.center.x > gameWidth or self.shape.center.y < waterLevel -- Don't check if above window, because it may fall back down
end

function cannonball:collisionPass(dt, objects)
	if self.active == cannonballActivation then
		for o = 1, #objects do
			if instanceOf(cannon, objects[o]) then
				local shapes = objects[o]:getShapes()
				for s = 1, #shapes do
					if shapes[s]:collide(self.shape) then
						gameOver(objects[o])
					end
				end
			elseif objects[o] ~= self and instanceOf(cannonball, objects[o]) then
				if self.shape:collide(objects[o].shape) then
					self:resolveCannonballCollision(dt, objects[o])
					return true
				end
			else -- It's a mountain
				-- todo
			end
		end
	end
end

function cannonball:resolveCannonballCollision(dt, other)
	local penetrationDistance = self.shape.radius + other.shape.radius - self.shape.center:distance(other.shape.center)
	local normal = self.shape.center:subtract(other.shape.center):normalize()
	local selfForce = self.direction:dot(normal)
	local otherForce = other.direction:dot(normal)
	self.direction = self.direction:add(normal:scale(-selfForce * bounceFactor))
	other.direction = other.direction:add(normal:scale(-otherForce * bounceFactor))
	local dtIncrement = dt / 64
	local maxDt = dt / 4
	while self.shape:collide(other.shape) do
		self.shape.center = self.shape.center:add(self.direction:scale(dtIncrement))
		dtIncrement = math.min(maxDt, dtIncrement * 2)
	end
end

function cannonball:draw()
	g.setColor(self.red, self.green, self.blue, self.active * 255 * (1 - self.touchedGround) / cannonballActivation)
	self.shape:draw()
end
