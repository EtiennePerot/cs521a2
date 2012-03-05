require 'vector'

function clamp(lowerBound, value, upperBound)
	return math.min(upperBound, math.max(lowerBound, value))
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
end

function circle:collide(other)
	if instanceOf(rectangle, other) then
		return other:collide(self)
	end
	if instanceOf(circle, other) then
		return self.center:distance(other.center) <= self.radius + other.radius
	end
end

function circle:contains(vector)
	return vector:distance(self.center) <= self.radius
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
