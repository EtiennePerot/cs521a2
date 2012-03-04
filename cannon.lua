require 'meter'

cannon = class('Cannon')

local baseWidth = 32
local baseThickness = 18
local cannonLength = 32
local cannonWidth = 12
local meterWidth = 128
local meterHeight = 12
local meterOffset = 24

function cannon:initialize(mountain, facing)
	self.mountain = mountain
	self.x = self.mountain:getRandomX(facing)
	self.y = self.mountain:getY(self.x)
	self.facing = facing
	if self.facing == 'left' then
		self.rotateBaseDraw = math.pi / 4
	else
		self.rotateBaseDraw = -math.pi / 4
	end
	self.angle = math.pi / 4
	self.meter = meter(self.x - meterWidth / 2, self.y - meterOffset - meterHeight, meterWidth, meterHeight)
end

function cannon:angleUp(dt)
	self.angle = math.min(math.pi / 2, self.angle + math.pi * dt / 1.5)
end

function cannon:angleDown(dt)
	self.angle = math.max(0, self.angle - math.pi * dt / 1.5)
end

function cannon:powerUp(dt)
	self.meter:valueUp(dt)
end

function cannon:powerDown(dt)
	self.meter:valueDown(dt)
end

function cannon:draw()
	g.push()
	g.translate(self.x, self.y)
	-- Draw cannon
	g.push()
	g.setColor(192, 192, 192)
	if self.facing == 'left' then
		g.rotate(-self.angle - math.pi)
	else
		g.rotate(self.angle)
	end
	g.rectangle('fill', -cannonWidth / 2, -cannonWidth / 2, cannonLength, cannonWidth)
	g.pop()
	-- Draw base
	g.push()
	g.setColor(164, 164, 164)
	g.rotate(self.rotateBaseDraw)
	g.rectangle('fill', -baseWidth / 2, -baseThickness / 2, baseWidth, baseThickness)
	g.setColor(0, 0, 0)
	g.pop()
	g.print(math.floor(math.abs(self.angle * 180 / math.pi)), -baseWidth / 3, baseThickness / 3, 0, 1, -1)
	g.pop()
	self.meter:draw()
end