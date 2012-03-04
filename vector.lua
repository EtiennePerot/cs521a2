vector = class('Vector')

function vector:initialize(x, y)
	self.x = x
	self.y = y
end

function vector:add(vec)
	return vector(self.x + vec.x, self.y + vec.y)
end

function vector:scale(scaleX, scaleY)
	scaleY = scaleY or scaleX
	return vector(self.x * scaleX, self.y * scaleY)
end

function vector:length()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function vector:normalize()
	return self:scale(1 / self:length())
end

function vector:rotate(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return vector(self.x * c - self.y * s, self.x * s + self.y * c)
end
