moon = class('Moon')

local radius = 64

function moon:initialize(x, y)
	self.x = math.max(radius, math.min(gameWidth - radius, x))
	self.y = math.max(radius, math.min(gameHeight - radius, y))
end

function moon:draw()
	g.setColor(232, 232, 240)
	g.circle('fill', self.x, self.y, radius, 32)
end
