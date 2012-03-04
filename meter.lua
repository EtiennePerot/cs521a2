meter = class('Meter')

function meter:initialize(x, y, width, height)
	self.x = x + 1
	self.y = y + 1
	self.width = width - 2
	self.height = height - 2
	self.value = 0.5
end

function meter:valueUp(dt)
	self.value = math.min(1, self.value + dt)
end

function meter:valueDown(dt)
	self.value = math.max(0, self.value - dt)
end

function meter:draw()
	local valueW = self.value * self.width
	g.setLineWidth(0)
	g.setColor(192, 192, 92)
	g.rectangle('fill', self.x, self.y, valueW, self.height)
	g.setLineWidth(3)
	g.setColor(92, 92, 92)
	g.rectangle('line', self.x - 1, self.y - 1, self.width + 2, self.height + 2)
	g.setLineWidth(1)
	g.setColor(224, 224, 224)
	g.triangle('fill', self.x + valueW - 4, self.y - 8, self.x + valueW + 4, self.y - 8, self.x + valueW, self.y - 4)
	g.print(tostring(math.floor(self.value * 100)) .. '%', self.x + valueW - 12, self.y - 10, 0, 1, -1)
end
