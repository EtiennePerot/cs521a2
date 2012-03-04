water = class('Water')

local waveSize = 10

function water:initialize(waterLevel)
	self.waterLevel = invY(waterLevel - 16)
	self.waveOffset = 0
end

function water:update(dt)
	self.waveOffset = (self.waveOffset + dt * waveSize) % waveSize
end

function water:draw()
	g.setColor(16, 32, 192)
	g.rectangle('fill', 0, self.waterLevel, gameWidth, invY(0))
	local wavePos
	for t = -waveSize, gameWidth, waveSize do
		wavePos = t + self.waveOffset
		g.triangle('fill', wavePos, self.waterLevel, wavePos + waveSize / 2, self.waterLevel - waveSize / 2, wavePos + waveSize, self.waterLevel)
	end
end