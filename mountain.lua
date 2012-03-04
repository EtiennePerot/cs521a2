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
	local nonSmooth = {}
	local totalNoise
	local gaussian -- Use a gaussian curve to provide the basic shape of the mountain
	local gaussianFactor = 1 / math.sqrt(2 * math.pi)
	local gaussianDenominator = (self.width * self.width / 32)
	local tempWidth
	for i = 0, self.width do
		tempWidth = (i - self.width / 2)
		gaussian = math.exp(- tempWidth * tempWidth / gaussianDenominator) * gaussianFactor
		totalNoise = 0
		for o = 1, self.octaves do
			totalNoise = totalNoise + noise[o][i]
		end
		nonSmooth[self.startX + i] = invY(math.max(self.y, self.y + (totalNoise + gaussian) * height))
	end
	-- Smoothing pass
	self.yValues = {}
	for i = self.startX + 1, self.endX - 1 do
		self.yValues[i] = nonSmooth[i - 1] / 4 + nonSmooth[i] / 2 + nonSmooth[i + 1] / 4
	end
	-- Force values at endpoints
	self.yValues[self.startX] = 3 * nonSmooth[self.startX] / 4 + nonSmooth[self.startX + 1] / 4
	self.yValues[self.endX] = 3 * nonSmooth[self.endX] / 4 + nonSmooth[self.endX - 1] / 4
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
		noise[i] = (rawNoise[noiseBefore] * (1 - sineProgress) + rawNoise[noiseAfter] * sineProgress) * amplitude
	end
	noise[self.width] = rawNoise[totalPeriods]
	return noise
end

function mountain:getStartX()
	return self.startX
end

function mountain:getEndX()
	return self.endX
end

function mountain:draw()
	g.setColor(64, 128, 32)
	-- Sadly concave polygons cannot be drawn in LOVE without artifacts, so we're just gonna draw a ton of lines
	g.setLineWidth(2) -- Necessary to prevent aliasing problems and stars shining through
	for i = self.startX, self.endX do
		g.line(i, self.invY, i, self.yValues[i])
	end
end
