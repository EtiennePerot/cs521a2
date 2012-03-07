require 'meter'
require 'cannonball'
require 'vector'
require 'shapes'

cannon = class('Cannon')

local baseWidth = 32
local baseThickness = 18
local cannonLength = 32
local cannonWidth = 12
local meterWidth = 128
local meterHeight = 12
local meterOffset = 24
local cannonCooldown = 0.7
local maxCannonballSpeed = 768

function cannon:initialize(mountain, facing)
	self.mountain = mountain
	local x = self.mountain:getRandomX(facing)
	self.pos = vector(x, self.mountain:getY(x))
	self.facing = facing
	self.angle = quarterPi
	self.meter = meter(self.pos.x - meterWidth / 2, self.pos.y - meterOffset - meterHeight, meterWidth, meterHeight)
	self.cooldown = 0
	if self.facing == 'left' then
		self.baseShape = rectangle(self.pos, baseWidth, baseThickness, quarterPi)
	else
		self.baseShape = rectangle(self.pos, baseWidth, baseThickness, -quarterPi)
	end
	self:updateCannonShape()
end

function cannon:update(dt)
	self.cooldown = math.max(0, self.cooldown - dt)
end

function cannon:updateCannonShape()
	local angle = self.angle
	if self.facing == 'left' then
		angle = pi - angle
	end
	local cannonCenter = vector(cannonLength / 2 - baseThickness / 2, 0):rotate(angle):add(self.pos)
	self.cannonShape = rectangle(cannonCenter, cannonLength, cannonWidth, angle)
end

function cannon:angleUp(dt)
	self.angle = math.min(halfPi, self.angle + threeQuartersPi * dt)
	self:updateCannonShape()
end

function cannon:angleDown(dt)
	self.angle = math.max(0, self.angle - threeQuartersPi * dt)
	self:updateCannonShape()
end

function cannon:powerUp(dt)
	self.meter:valueUp(dt)
end

function cannon:powerDown(dt)
	self.meter:valueDown(dt)
end

function cannon:getTip()
	local tip = vector(cannonLength - baseThickness / 2, 0)
	tip = tip:rotate(self.angle)
	if self.facing == 'left' then
		tip.x = -tip.x
	end
	return tip
end

function cannon:getTipAbsolute()
	return self:getTip():add(self.pos)
end

function cannon:getShapes()
	return {self.cannonShape}
end

function cannon:fire()
	if self.cooldown > 0 then
		return nil
	end
	self.cooldown = cannonCooldown
	local direction = self:getTip():normalize():scale(self.meter:getValue() * maxCannonballSpeed)
	return cannonball(self, direction)
end

function cannon:draw()
	g.setColor(192, 192, 192)
	self.cannonShape:draw()
	g.setColor(164, 164, 164)
	self.baseShape:draw()
	g.print(math.floor(math.abs(self.angle * radToDeg)), self.pos.x - baseWidth / 3, self.pos.y + baseThickness / 3, 0, 1, -1)
	self.meter:draw()
end
