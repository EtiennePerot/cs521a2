require 'vector'
require 'meter'

force = class('Force')

function force:apply(dt, position, speed)
	return position, speed
end

gravity = force:subclass('Gravity')

function gravity:initialize()
	self.pull = vector(0, -384)
end

function gravity:apply(dt, position, speed)
	return position, speed:add(self.pull:scale(dt))
end

wind = force:subclass('Wind')

local maxWindForce = 256
local minWindUpdate = 5
local maxWindUpdate = 15
local windHudSize = 64
local windHudOffsetX = 10
local windHudOffsetY = 24
local windHalfHud = windHudSize / 2

function wind:initialize()
	self.updateCountdown = 0
	self:update(0)
	self.meter = meter
end

function wind:update(dt)
	self.updateCountdown = self.updateCountdown - dt
	if self.updateCountdown <= 0 then
		self.pull = vector(math.random(-maxWindForce, maxWindForce), math.random(-maxWindForce, maxWindForce))
		self.updateCountdown = math.random(minWindUpdate, maxWindUpdate)
		self.initialUpdateCountdown = self.updateCountdown
	end
end

function wind:horizontalSpeed() -- Used to determine water waves speed/direction
	return self.pull.x / maxWindForce
end

function wind:apply(dt, position, speed)
	return position, speed:add(self.pull:scale(dt))
end

function wind:draw()
	g.setLineWidth(0)
	g.setColor(255, 255, 255, 64)
	g.rectangle('fill', windHudOffsetX + 1, windHudOffsetY + 1, windHudSize - 2, self.updateCountdown * (windHudSize - 2) / self.initialUpdateCountdown)
	g.setLineWidth(2)
	g.setColor(255, 192, 192, 192)
	g.print('Wind', windHudOffsetX + 16, windHudOffsetY + windHudSize + 16, 0, 1, -1)
	g.rectangle('line', windHudOffsetX, windHudOffsetY, windHudSize, windHudSize)
	g.push()
	g.translate(windHudOffsetX + windHalfHud, windHudOffsetY + windHalfHud)
	g.circle('fill', 0, 0, 3, 6)
	local arrowX = self.pull.x * windHalfHud / maxWindForce
	local arrowY = self.pull.y * windHalfHud / maxWindForce
	g.line(0, 0, arrowX, arrowY)
	g.triangle('fill', arrowX - 4, -windHalfHud - 6, arrowX + 4, -windHalfHud - 6, arrowX, -windHalfHud - 2)
	g.print(tostring(math.floor(self.pull.x * 100 / maxWindForce)) .. '%', arrowX - 12, -windHalfHud - 8, 0, 1, -1)
	g.triangle('fill', windHalfHud + 2, arrowY, windHalfHud + 6, arrowY + 4, windHalfHud + 6, arrowY - 6)
	g.print(tostring(math.floor(self.pull.y * 100 / maxWindForce)) .. '%', windHalfHud + 8, arrowY + 6, 0, 1, -1)
	g.pop()
end
