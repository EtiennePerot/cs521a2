require 'globals'
require 'middleclass'
require 'conf'
require 'star'
require 'moon'
require 'water'
require 'mountain'
require 'cannon'

math.randomseed(os.time()) -- Randomize seed

local overlayImage, gameOverImage
local mountain1, mountain2
local waterObject, waterLevel
local moonObject, stars
local cannon1, cannon2, cannonballs
local gravityForce, windForce
local allForces, allObjects
local isGameOver

function love.load()
	g.setBackgroundColor(8, 16, 48)
	overlayImage = g.newImage('mask.png')
	gameOverImage = g.newImage('gameOver.png')
	mountain1 = mountain(0, 5 * gameWidth / 12, 0, 2 * gameHeight / 3)
	mountain2 = mountain(7 * gameWidth / 12, gameWidth, 0, 2 * gameHeight / 3)
	waterLevel = gameHeight / 12
	waterObject = water(waterLevel)
	moonObject = moon(math.random(gameWidth), math.random(2 * gameHeight / 3, gameHeight))
	stars = {}
	for s = 1, math.random(32, 64) do
		stars[s] = star(math.random(gameWidth), math.random(waterLevel, gameHeight))
	end
	cannon1 = cannon(mountain1, 'right')
	cannon2 = cannon(mountain2, 'left')
	cannonballs = {}
	gravityForce = gravity()
	windForce = wind()
	allForces = {gravityForce, windForce}
	allObjects = {mountain1, mountain2, cannon1, cannon2}
	isGameOver = false
end

function deleteObject(o)
	for ind, obj in pairs(allObjects) do
		if obj == o then
			table.remove(allObjects, ind)
			return true
		end
	end
	return false
end

function addCannonball(ball)
	if ball ~= nil then
		table.insert(cannonballs, ball)
		table.insert(allObjects, ball)
	end
end

function gameOver(cannonHit)
	isGameOver = deleteObject(cannonHit)
end

function love.update(dt)
	dt = timeScale * dt
	if k.isDown('lshift') or k.isDown('rshift') then
		dt = dt / 4
	end
	if k.isDown('lctrl') or k.isDown('rctrl') then
		dt = dt / 16
	end
	windForce:update(dt)
	waterObject:update(dt, windForce)
	local cannonballsToRemove = {}
	for c = 1, #cannonballs do
		if cannonballs[c]:forcePass(dt, allForces, waterLevel) then
			table.insert(cannonballsToRemove, c)
		end
	end
	for c = #cannonballsToRemove, 1, -1 do
		deleteObject(cannonballs[cannonballsToRemove[c]])
		table.remove(cannonballs, cannonballsToRemove[c])
	end
	local allOk
	while true do
		allOk = true
		for c = 1, #cannonballs do
			if cannonballs[c]:collisionPass(dt, allObjects) then
				allOk = false
				break
			end
		end
		break
	end
	if not isGameOver then
		cannon1:update(dt)
		cannon2:update(dt)
		if k.isDown('w') then
			cannon1:angleUp(dt)
		end
		if k.isDown('s') then
			cannon1:angleDown(dt)
		end
		if k.isDown('a') then
			cannon1:powerDown(dt)
		end
		if k.isDown('d') then
			cannon1:powerUp(dt)
		end
		if k.isDown('e') then
			addCannonball(cannon1:fire())
		end
		if k.isDown('up') then
			cannon2:angleUp(dt)
		end
		if k.isDown('down') then
			cannon2:angleDown(dt)
		end
		if k.isDown('left') then
			cannon2:powerDown(dt)
		end
		if k.isDown('right') then
			cannon2:powerUp(dt)
		end
		if k.isDown(' ') then
			addCannonball(cannon2:fire())
		end
	end
end

function love.keypressed(key, unicode)
	if key == 'r' then
		love.load()
	end
end

function love.draw()
	g.scale(1, -1) -- Flip Y axis
	g.translate(0, -gameHeight) -- Translate things back into view
	moonObject:draw()
	waterObject:draw()
	for s = 1, #stars do
		stars[s]:draw()
	end
	for o = 1, #allObjects do
		allObjects[o]:draw()
	end
	for c = 1, #cannonballs do
		cannonballs[c]:draw()
	end
	windForce:draw()
	if isGameOver then
		g.draw(gameOverImage, 0, gameHeight, 0, 1, -1)
	end
	g.draw(overlayImage, 0, gameHeight, 0, 1, -1)
end
