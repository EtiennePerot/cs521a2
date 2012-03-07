require 'vector'

function clamp(lowerBound, value, upperBound)
	return math.min(upperBound, math.max(lowerBound, value))
end

function sgn(x)
	if x < 0 then
		return -1
	end
	return 1
end

function sgnInvert(x)
	return -sgn(x)
end

shape = class('Shape')
function shape:collide(other)
	return false
end

function shape:contains(vector)
	return false
end

function shape:draw()
end

circle = shape:subclass('Circle')
function circle:initialize(center, radius)
	self.center = center
	self.radius = radius
	self.radiusSquare = radius * radius
end

function circle:collide(other)
	if instanceOf(rectangle, other) then
		return other:collide(self)
	end
	if instanceOf(circle, other) then
		return self.center:distance(other.center) <= self.radius + other.radius
	end
	if instanceOf(segment, other) then
		local projLength = clamp(0, self.center:subtract(other.p1):dot(other.normalDifference), other.length)
		local projected = other.p1:add(other.normalDifference:scale(projLength))
		return self:contains(projected)
	end
	-- Assume it is a series of points
	for p = 1, #other do
		if self:contains(other[p]) then
			return true
		end
		return false
	end
end

function circle:contains(vec)
	return vec:distance(self.center) <= self.radius
end

function circle:draw()
	g.circle('fill', self.center.x, self.center.y, self.radius, self.radius * 1.5)
end

rectangle = shape:subclass('Rectangle')
function rectangle:initialize(center, width, height, rotation)
	self.center = center
	self.width = width
	self.halfWidth = width / 2
	self.height = height
	self.halfHeight = height / 2
	self.rotation = rotation or 0
end

function rectangle:collide(other)
	if instanceOf(circle, other) then
		-- Rotate circle
		local newCenter = other.center:subtract(self.center):rotate(-self.rotation)
		-- Quick check which should instantly return false if the circle is far away
		if newCenter:length() > self.width + self.height + other.radius then
			return false
		end
		local newCircle = circle(newCenter, other.radius)
		-- Compute closest point inside the rectangle
		local closestX = clamp(-self.halfWidth, newCenter.x, self.halfWidth)
		local closestY = clamp(-self.halfHeight, newCenter.y, self.halfHeight)
		local closest = vector(closestX, closestY)
		-- Check if that point is inside the circle
		return newCircle:contains(closest)
	end
	-- Other collisions unimplemented
end

function rectangle:draw()
	g.push()
	g.translate(self.center.x, self.center.y)
	g.rotate(self.rotation)
	g.rectangle('fill', -self.halfWidth, -self.halfHeight, self.width, self.height)
	g.setColor(0, 0, 0)
	g.pop()
end

segment = shape:subclass('Segment')
function segment:initialize(p1, p2)
	self.p1 = p1
	self.p2 = p2
	self.difference = self.p2:subtract(self.p1)
	self.length = self.difference:length()
	self.normalDifference = self.difference:normalize()
	self.normal = self.normalDifference:rotate(halfPi)
end

function segment:getNormal()
	return self.normal
end

function segment:collide(other)
	if instanceOf(circle, other) then
		return other:collide(self)
	end
end

function segment:draw()
	g.line(self.p1.x, self.p1.y, self.p2.x, self.p2.y)
end
