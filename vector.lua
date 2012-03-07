vector = class('Vector')

function vector:initialize(x, y)
	self.x = x
	self.y = y
end

function vector:add(vec)
	return vector(self.x + vec.x, self.y + vec.y)
end

function vector:subtract(vec)
	return vector(self.x - vec.x, self.y - vec.y)
end

function vector:scale(scaleX, scaleY)
	scaleY = scaleY or scaleX
	return vector(self.x * scaleX, self.y * scaleY)
end

function vector:negate()
	return vector(-self.x, -self.y)
end

function vector:length()
	return math.sqrt(self:squareLength())
end

function vector:squareLength()
	return self.x * self.x + self.y * self.y
end

function vector:distance(vec)
	return self:subtract(vec):length()
end

function vector:squareDistance(vec)
	return self:subtract(vec):squareLength()
end

function vector:dot(vec)
	return self.x * vec.x + self.y * vec.y
end

function vector:angle()
	if self.x == 0 then
		if self.y > 0 then
			return math.pi / 2
		end
		return -math.pi / 2
	end
	return math.atan(self.y / self.x)
end

function vector:normalize()
	return self:scale(1 / self:length())
end

function vector:rotate(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return vector(self.x * c - self.y * s, self.x * s + self.y * c)
end
