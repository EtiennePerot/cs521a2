require 'vector'
require 'shapes'

mountain = class('Mountain')

function mountain:initialize(startX, endX, y, height, octaves)
	self.octaves = octaves or 16
	self.startX = math.floor(startX)
	self.endX = math.floor(endX)
	self.width = self.endX - self.startX + 1
	self.y = y
	self.height = height
	local noise = {}
	for o = 1, self.octaves do
		noise[o] = self:genOctave(o)
	end
	local nonSmooth = {}
	local totalNoise
	local gaussian -- Use a gaussian curve to provide the basic shape of the mountain
	local gaussianFactor = 1 / math.sqrt(doublePi)
	local gaussianDenominator = (self.width * self.width / 32)
	local tempWidth
	for i = 0, self.width do
		tempWidth = (i - self.width / 2)
		gaussian = math.exp(- tempWidth * tempWidth / gaussianDenominator) * gaussianFactor
		totalNoise = 0
		for o = 1, self.octaves do
			totalNoise = totalNoise + noise[o][i]
		end
		nonSmooth[self.startX + i] = math.max(self.y, self.y + (totalNoise + gaussian) * height)
	end
	-- Smoothing pass
	self.yValues = {}
	for i = self.startX + 1, self.endX do
		self.yValues[i] = nonSmooth[i - 1] / 4 + nonSmooth[i] / 2 + nonSmooth[i + 1] / 4
	end
	-- Force values at endpoints
	self.yValues[self.startX - 1] = 0
	self.yValues[self.startX] = 3 * nonSmooth[self.startX] / 4 + nonSmooth[self.startX + 1] / 4
	self.yValues[self.endX] = 3 * nonSmooth[self.endX] / 4 + nonSmooth[self.endX - 1] / 4
	self.yValues[self.endX + 1] = 0
	-- Build geometry segments
	self.segments = {}
	for i = self.startX - 1, self.endX do
		self.segments[i] = segment(vector(i, self.yValues[i]), vector(i + 1, self.yValues[i + 1]))
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
	-- Now generate the full data, with interpolated values
	local noise = {}
	local relativeX, noiseBefore, noiseAfter, progress, sineProgress
	for i = 0, self.width - 1 do
		relativeX = i / waveLength
		noiseBefore = math.floor(relativeX)
		progress = relativeX - noiseBefore
		sineProgress = math.sin(progress * pi) / 2
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

function mountain:getRandomX(face)
	local faceOffset = self.width * 0.3 -- At least 30% from the edge of the mountain, meaning at least 60% from the edge of the face
	local faceWidth = self.width * 0.1 -- 10% range of possible values on the mountain, meaning 20% range of possible values on the face
	if face == 'left' then
		return math.random(math.floor(self.startX + faceOffset), math.floor(self.startX + faceOffset + faceWidth))
	end
	return math.random(math.ceil(self.endX - faceOffset - faceWidth), math.ceil(self.endX - faceOffset))
end

function mountain:getY(x)
	x = math.floor(math.min(self.endX, math.max(self.startX, x)))
	return self.yValues[x]
end

function mountain:getSegments()
	return self.segments
end

function mountain:draw()
	-- Sadly concave polygons cannot be drawn in LOVE without artifacts, so we're just gonna draw a ton of lines
	g.setColor(64, 128, 32)
	g.setLineWidth(2) -- Necessary to prevent aliasing problems and stars shining through
	for i = self.startX, self.endX do
		g.line(i, self.y, i, self.yValues[i])
	end
	-- Now draw the outline
	g.setColor(128, 128, 128)
	g.setLineWidth(3)
	for i = self.startX - 1, self.endX do
		self.segments[i]:draw()
	end
end
