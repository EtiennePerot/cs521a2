mountain = class('Mountain')

function mountain:initialize(startX, endX, y, height, octaves)
	self.octaves = octaves or 16
	self.startX = math.floor(startX)
	self.endX = math.floor(endX)
	self.width = self.endX - self.startX + 1
	self.y = y
	self.invY = invY(self.y)
	self.height = height
	local noise = {}
	for o = 1, self.octaves do
		noise[o] = self:genOctave(o)
	end
	self.yValues = {}
	local totalNoise
	local gaussian -- Use a gaussian curve to provide the basic shape of the mountain
	local gaussianFactor = 1 / math.sqrt(2 * math.pi)
	local gaussianDenominator = (self.width * self.width / 32)
	local tempWidth
	local noiseFactor = 4
	for i = 0, self.width do
		tempWidth = (i - self.width / 2)
		gaussian = math.exp(- tempWidth * tempWidth / gaussianDenominator) * gaussianFactor
		totalNoise = 0
		for o = 1, self.octaves do
			totalNoise = totalNoise + noise[o][i]
		end
		self.yValues[self.startX + i] = invY(math.max(self.y, self.y + (totalNoise + gaussian) * height))
	end
end

function mountain:genOctave(octave)
	local waveLength = self.width / math.pow(2, octave)
	local totalPeriods = math.ceil(self.width / waveLength)
	local amplitude = math.pow(2, - octave)
	-- Generate random noise
	local rawNoise = {}
	for i = 1, totalPeriods - 1 do
		rawNoise[i] = math.random()
	end
	-- Force 0 noise at endpoints so that we don't have sharp edges
	rawNoise[0] = 0
	rawNoise[totalPeriods] = 0
	-- Smoothing pass
	local smoothNoise = {}
	for i = 1, totalPeriods - 1 do
		smoothNoise[i] = rawNoise[i - 1] / 4 + rawNoise[i] / 2 + rawNoise[i + 1] / 4
	end
	-- Force 0 noise at endpoints again
	smoothNoise[0] = 0
	smoothNoise[totalPeriods] = 0
	-- Now generate the full data, with interpolated values
	local noise = {}
	local relativeX, noiseBefore, noiseAfter, progress, sineProgress
	for i = 0, self.width - 1 do
		relativeX = i / waveLength
		noiseBefore = math.floor(relativeX)
		progress = relativeX - noiseBefore
		sineProgress = math.sin(progress * math.pi) / 2
		if progress > 0.5 then
			sineProgress = 1 - sineProgress
		end
		noiseAfter = noiseBefore + 1
		noise[i] = (smoothNoise[noiseBefore] * (1 - sineProgress) + smoothNoise[noiseAfter] * sineProgress) * amplitude
	end
	noise[self.width] = smoothNoise[totalPeriods]
	return noise
end

function mountain:draw()
	g.setColor(64, 128, 32)
	g.setLineWidth(2)
	for i = self.startX, self.endX do
		g.line(i, self.invY, i, self.yValues[i])
	end
end
