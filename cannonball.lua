require 'forces'
require 'shapes'
require 'water'

cannonball = class('Cannonball')

local cannonballSize = 6
local cannonballActivation = 0.15

function cannonball:initialize(cannon, direction)
	self.cannon = cannon
	self.speed = direction
	self.active = 0
	self.shape = circle(cannon:getTipAbsolute(), cannonballSize)
	self.touchedGround = false
	self.touchedGroundOpacity = 1
	self.red = math.random(64, 255)
	self.green = math.random(64, 255)
	self.blue = math.random(64, 255)
end

function cannonball:forcePass(dt, gravityForce, windForce, waterLevel)
	self.active = math.min(self.active + dt, cannonballActivation)
	self.shape.center, self.speed = gravityForce:apply(dt, self.shape.center, self.speed)
	if not self.touchedGround then
		self.shape.center, self.speed = windForce:apply(dt, self.shape.center, self.speed)
	end
	self.shape.center = self.shape.center:add(self.speed:scale(dt))
	return self.shape.center.x < 0 or self.shape.center.x > gameWidth or self.shape.center.y < waterLevel -- Don't check if above window, because it may fall back down
end

function cannonball:collisionPass(dt, objects)
	if self.active == cannonballActivation then
		for o = 1, #objects do
			if objects[o] ~= nil and objects[o] ~= self then
				if instanceOf(cannon, objects[o]) then
					if not self.touchedGround then
						local shapes = objects[o]:getShapes()
						for s = 1, #shapes do
							if shapes[s]:collide(self.shape) then
								gameOver(objects[o])
							end
						end
					end
				elseif instanceOf(cannonball, objects[o]) then
					if self.shape:collide(objects[o].shape) then
						self:resolveCannonballCollision(dt, objects[o])
						return true
					end
				else -- It's a mountain
					self:resolveMountainCollision(dt, objects[o])
				end
			end
		end
	end
end

function cannonball:resolveCannonballCollision(dt, other)
	local penetrationDistance = self.shape.radius + other.shape.radius - self.shape.center:distance(other.shape.center)
	local normal = self.shape.center:subtract(other.shape.center):normalize()
	local selfForce = self.speed:dot(normal)
	local otherForce = other.speed:dot(normal)
	self.speed = self.speed:add(normal:scale(-selfForce * bounceFactor))
	other.speed = other.speed:add(normal:scale(-otherForce * bounceFactor))
	local dtIncrement = dt / 64
	local maxDt = dt / 4
	local iters = 0
	while iters < maxUnstuckIterations and self.shape:collide(other.shape) do
		self.shape.center = self.shape.center:add(self.speed:scale(dtIncrement))
		dtIncrement = math.min(maxDt, dtIncrement * 2)
		iters = iters + 1
	end
end

function cannonball:collidesWithSegments(segments)
	for s = 1, #segments do
		if self.shape:collide(segments[s]) then
			return true
		end
	end
	return false
end

toDraw = {}

function cannonball:resolveMountainCollision(dt, mount)
	local xRange1 = math.floor(self.shape.center.x - self.shape.radius)
	local xRange2 = math.ceil(self.shape.center.x + self.shape.radius)
	local segments = mount:getSegments()
	if segments[xRange1] == nil and segments[xRange2] == nil then
		return -- Not within range of the mountain at all
	end
	local segment, collision
	local collisionSegments = {}
	local additionalSpeed = vector(0, 0)
	local segmentNormal, selfForce
	for i = xRange1, xRange2 do
		segment = segments[i]
		if segment ~= nil then
			collision = self.shape.center.y < segment.p1.y or self.shape:collide(segment)
			if collision then
				table.insert(collisionSegments, segment)
				segmentNormal = segment:getNormal()
				if segmentNormal.y < 0 then -- Make sure we're getting the outward normal
					segmentNormal = segmentNormal:negate()
				end
				additionalSpeed = additionalSpeed:add(segmentNormal:scale(math.abs(self.speed:dot(segmentNormal))))
			end
		end
	end
	if #collisionSegments > 0 then
		local incremental = additionalSpeed:scale(1 / #collisionSegments)
		self.speed = self.speed:add(incremental)
		local dtIncrement = dt / 64
		local maxDt = dt / 4
		local iters = 0
		while iters < maxUnstuckIterations and self:collidesWithSegments(collisionSegments) do
			self.shape.center = self.shape.center:add(incremental:scale(dtIncrement))
			dtIncrement = math.min(maxDt, dtIncrement * 2)
			iters = iters + 1
		end
		if not self.touchedGround then
			self.touchedGround = true
			self.touchedGroundOpacity = 0.35
			self.speed = vector(0, 0) -- Hard stop on first bounce, as requested on assignment
		end
	end
end

function cannonball:draw()
	g.setColor(self.red, self.green, self.blue, self.active * 255 * self.touchedGroundOpacity / cannonballActivation)
	self.shape:draw()
	g.setColor(255, 255, 255)
	g.setLineWidth(2)
	for i = 1, #toDraw do
		toDraw[i]:draw()
	end
end
