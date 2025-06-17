local love = require("love")
local GlobalConfig = require("global_config")

--[[
    The Camera module is resoponsible for managing the camera view in the game.
    It handles camera movement, zooming, and panning to provide a dynamic view of the game world.
    REF : https://ebens.me/posts/cameras-in-love2d-part-1-the-basics/
--]]
local Camera = {}

Camera.__index = Camera
function Camera:new(x, y, width, height)
    local instance = setmetatable({}, self)
    instance.x = x or 0
    instance.y = y or 0
    instance.width = width or love.graphics.getWidth()
    instance.height = height or love.graphics.getHeight()
    instance.scale = 1
    return instance
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end
function Camera:zoom(factor)
    self.scale = self.scale * factor
end
function Camera:panTo(x, y)
    self.x = x - self.width / 2
    self.y = y - self.height / 2
end
function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end
function Camera:unapply()
    love.graphics.pop()
    -- Reset the graphics transformation to the origin
end
function Camera:reset()
    self.x = 0
    self.y = 0
    self.scale = 1
end

-- Setters and Getters ======================================================================
function Camera:setSize(width, height)
    self.width = width
    self.height = height
end
function Camera:getSize()
    return self.width, self.height
end
function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end
function Camera:getPosition()
    return self.x, self.y
end
function Camera:setScale(scale)
    self.scale = scale
end
function Camera:getScale()
    return self.scale
end

return Camera