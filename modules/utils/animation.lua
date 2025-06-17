local love = require("love")

local Animation = {}

function Animation:new(image, frameWidth, frameHeight, frames, duration)
    local anim = {
        image = image,
        frameWidth = frameWidth,
        frameHeight = frameHeight,
        frames = frames, -- Table of {x, y} coordinates of top-left for each frame
        duration = duration, -- Total duration for one cycle of the animation
        currentTime = 0,
        currentFrameIndex = 1,
        quads = {}, -- Store Quads for performance
        isPlaying = false
    }
    setmetatable(anim, self)
    self.__index = self

    -- Pre-calculate quads
    for i, frameCoords in ipairs(anim.frames) do
        local x = frameCoords[1]
        local y = frameCoords[2]
        anim.quads[i] = love.graphics.newQuad(x, y, anim.frameWidth, anim.frameHeight, anim.image:getWidth(), anim.image:getHeight())
    end

    return anim
end

function Animation:play()
    self.isPlaying = true
end

function Animation:pause()
    self.isPlaying = false
end

function Animation:stop()
    self.isPlaying = false
    self.currentTime = 0
    self.currentFrameIndex = 1
end

function Animation:update(dt)
    if not self.isPlaying or #self.frames == 0 then
        return
    end

    self.currentTime = self.currentTime + dt
    local frameDuration = self.duration / #self.frames

    if self.currentTime >= self.duration then
        self.currentTime = self.currentTime % self.duration -- Loop the animation
        self.currentFrameIndex = 1
    end

    self.currentFrameIndex = math.floor(self.currentTime / frameDuration) + 1
    -- Ensure currentFrameIndex is within bounds (in case of floating point inaccuracies near end)
    if self.currentFrameIndex > #self.frames then
        self.currentFrameIndex = #self.frames
    end
end

function Animation:isAnimationFinished()
    return not self.isPlaying or self.currentFrameIndex >= #self.frames
end

function Animation:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    local quad = self.quads[self.currentFrameIndex]
    if quad then
        love.graphics.draw(
            self.image, quad, 
            x, y, 
            r or 0, 
            sx or 1, sy or 1, 
            ox or 0, oy or 0, 
            kx or 0, ky or 0
        )
    end
end

return Animation