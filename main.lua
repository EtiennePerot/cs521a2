require 'globals'
require 'middleclass'
require 'conf'
require 'star'
require 'moon'
require 'water'
require 'mountain'
require 'cannon'

math.randomseed(os.time()) -- Randomize seed
local mountain1 = mountain(0, 5 * gameWidth / 12, 0, 2 * gameHeight / 3)
local mountain2 = mountain(7 * gameWidth / 12, gameWidth, 0, 2 * gameHeight / 3)
local waterLevel = gameHeight / 12
local water = water(waterLevel)
local moon = moon(math.random(gameWidth), math.random(2 * gameHeight / 3, gameHeight))
local stars = {}
for s = 1, math.random(32, 64) do
	stars[s] = star(math.random(gameWidth), math.random(waterLevel, gameHeight))
end
local cannon1 = cannon(mountain1, 'right')
local cannon2 = cannon(mountain2, 'left')
local cannonballs = {}
local gravityForce = gravity()
local windForce = wind()
local allForces = {gravityForce, windForce}

function love.load()
	g.setBackgroundColor(8, 16, 48)
end

function addCannonball(ball)
	if ball ~= nil then
		table.insert(cannonballs, ball)
	end
end

function love.update(dt)
	windForce:update(dt)
	water:update(dt, windForce)
	cannon1:update(dt)
	cannon2:update(dt)
	local cannonballsToRemove = {}
	for c = 1, #cannonballs do
		if cannonballs[c]:update(dt, allForces) then
			table.insert(cannonballsToRemove, c)
		end
	end
	for c = #cannonballsToRemove, 1, -1 do
		table.remove(cannonballs, cannonballsToRemove[c])
	end
	if love.keyboard.isDown('w') then
		cannon1:angleUp(dt)
	end
	if love.keyboard.isDown('s') then
		cannon1:angleDown(dt)
	end
	if love.keyboard.isDown('a') then
		cannon1:powerDown(dt)
	end
	if love.keyboard.isDown('d') then
		cannon1:powerUp(dt)
	end
	if love.keyboard.isDown('e') then
		addCannonball(cannon1:fire())
	end
	if love.keyboard.isDown('up') then
		cannon2:angleUp(dt)
	end
	if love.keyboard.isDown('down') then
		cannon2:angleDown(dt)
	end
	if love.keyboard.isDown('left') then
		cannon2:powerDown(dt)
	end
	if love.keyboard.isDown('right') then
		cannon2:powerUp(dt)
	end
	if love.keyboard.isDown(' ') then
		addCannonball(cannon2:fire())
	end
end

function love.draw()
	g.scale(1, -1) -- Flip Y axis
	g.translate(0, -gameHeight) -- Translate things back into view
	moon:draw()
	water:draw()
	for s = 1, #stars do
		stars[s]:draw()
	end
	mountain1:draw()
	mountain2:draw()
	cannon1:draw()
	cannon2:draw()
	for c = 1, #cannonballs do
		cannonballs[c]:draw()
	end
	windForce:draw()
end
