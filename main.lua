require 'globals'
require 'middleclass'
require 'conf'
require 'star'
require 'moon'
require 'water'
require 'mountain'

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

function love.load()
	g.setBackgroundColor(8, 16, 48)
end

function love.update(dt)
	water:update(dt)
end

function love.draw()
	moon:draw()
	water:draw()
	for s = 1, #stars do
		stars[s]:draw()
	end
	mountain1:draw()
	mountain2:draw()
end
