star = class('Star')

function star:initialize(x, y)
	self.poly = {
		x - 2, y,
		x, y + 2,
		x + 2, y,
		x, y - 2
	}
	if math.random() > 0.5 then
		self.mode = 'line'
	else
		self.mode = 'fill'
	end
end

function star:draw()
	g.setColor(255, 224, 224, 192)
	g.setLineWidth(1)
	g.polygon(self.mode, self.poly)
end
