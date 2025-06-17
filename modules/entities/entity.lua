local love = require("love")
local GlobalConfig = require("global_config")
--[[ 
    a class representing a generic entity in the game.
    This class serves as a base for all entities in the game, such as players, enemies, and items.    
--]]
local Entity = {}

Entity.__index = Entity
function Entity:new()
    print("Entity:new() should not be called directly. Use Entity:new(name, health, damage, speed, width, height) instead.")
    -- Default constructor for Entity, should be overridden by subclasses
    -- Initialize with default values, can be overridden by subclasses
    local entity = {
        name = nil,
        entityType = nil,
        health = nil,
        -- Speed in pixels per second
        -- allow speed to be a number or a table for more complex speed handling
        speed = nil,
        position = {x = 0, y = 0},
        width = nil,
        height = nil,
        -- 1 for right, -1 for left
        direction = nil,
        currentState = nil,
        isDead = false,
        -- Placeholder for states, can be set later
        states = {},
        physicsBody = nil,
        physicsShape = nil,
        physicsFixture = nil,
    }
    setmetatable(entity, self)
    return entity
end

-- Setters and Getters ======================================================================
function Entity:setPhysicsBody(world)
    self.physicsBody = love.physics.newBody(
        world,
        self.position.x,
        self.position.y,
        -- Dynamic body for player
        "static"
    )
    -- Set the shape of the physics body to a rectangle
    self.physicsBody:setFixedRotation(true) -- Prevent rotation
    self.physicsBody:setMass(1) -- Set mass to 1 for simplicity

    self.physicsShape = love.physics.newRectangleShape(
        self.width,
        self.height
    )
    -- Create a fixture for the physics body
    self.physicsFixture = love.physics.newFixture(
        self.physicsBody,
        self.physicsShape
    )

    self.physicsFixture:setUserData(self) -- Set user data to the entity itself

end
function Entity:setPosition(x, y)
    self.position.x = x
    self.position.y = y
end
function Entity:getPosition()
    return self.position.x, self.position.y
end
function Entity:setDirection(direction)
    if direction == "left" then
        self.direction = -1
    elseif direction == "right" then
        self.direction = 1
    end
end
function Entity:getDirection()
    return self.direction
end
function Entity:setSpeed(speed)
    self.speed = speed
end
function Entity:getSpeed()
    return self.speed
end
function Entity:setHealth(health)
    self.health = health
end
function Entity:getHealth()
    return self.health
end
function Entity:setDamage(damage)
    self.damage = damage
end
function Entity:getDamage()
    return self.damage
end
function Entity:setSize(width, height)
    self.width = width
    self.height = height
end
function Entity:getSize()
    return self.width, self.height
end
function Entity:setName(name)
    self.name = name
end
function Entity:getName()
    return self.name
end
function Entity:setCurrentState(state)
    self.currentState = state
end
function Entity:getCurrentState()
    return self.currentState
end
function Entity:getBoundingBox()
    return self.position.x - self.width/2, self.position.y - self.height/2, self.width, self.height
end
-- Setters and Getters ======================================================================

-- Methods =================================================================================
function Entity:update(dt)
    -- Default update method, can be overridden by subclasses
    if not self.isDead then
        self:updatePosition(dt)
    end
end
function Entity:updatePosition(dt)
    -- Default implementation, can be overridden by subclasses
    self.position.x = self.position.x + (self.speed * dt * self.direction)
end
function Entity:takeDamage(amount)
    if self.health <= 0 and not self.isDead then
        self:die()
    else 
        self.health = self.health - amount
    end
end
function Entity:die()
    -- Default death behavior, can be overridden by subclasses
    print(self.name .. " has died.")
    self.isDead = true
    self.speed = 0
end
function Entity:draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the enemy based on its current state
    local currentState = self.states[self.currentState]
    if currentState and currentState.animation then
        local diff_heightFrame_heightEntity = (GlobalConfig.ANIMATIONS.frameConfig.frameHeight - self.height)/2
        currentState.animation:draw(
            self.position.x, 
            self.position.y - diff_heightFrame_heightEntity, 
            -- rotation
            0,
            -- scale X
            self.direction,
            -- scale Y
            1,
            -- offset X
            GlobalConfig.ANIMATIONS.frameConfig.frameWidth / 2,
            -- offset Y
            GlobalConfig.ANIMATIONS.frameConfig.frameHeight / 2,
            -- shear X
            0,
            -- shear Y
            0
        )
    end

    
end
function Entity:drawHealthBar()
    -- Draw the health bar above the entity
    local x, y = self:getPosition()
    local healthPercentage = self.health / GlobalConfig.GAMEPLAY.player.defaultHealth
    local barWidth = 50
    local barHeight = 5
    local barOffset = 10

    -- Draw the background of the health bar
    love.graphics.setColor(0.2, 0.2, 0.2, 1) -- Dark gray for background
    love.graphics.rectangle("fill", x - barWidth / 2, y - self.height / 2 - barOffset, barWidth, barHeight)

    -- Draw the health bar
    love.graphics.setColor(0, 1, 0, 1) -- Green for health
    love.graphics.rectangle("fill", x - barWidth / 2, y - self.height / 2 - barOffset, barWidth * healthPercentage, barHeight)

    -- Reset color to white
    love.graphics.setColor(1, 1, 1, 1)
end
function Entity:drawBox()
    local diff_heightFrame_heightEntity = (GlobalConfig.ANIMATIONS.frameConfig.frameHeight - self.height)/2

    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.print("Frame box", 
        self.position.x - GlobalConfig.ANIMATIONS.frameConfig.frameWidth/2, 
        self.position.y - diff_heightFrame_heightEntity - GlobalConfig.ANIMATIONS.frameConfig.frameHeight/2 - 20
    )
    love.graphics.rectangle("line", 
        self.position.x  - GlobalConfig.ANIMATIONS.frameConfig.frameWidth/2, 
        self.position.y  - GlobalConfig.ANIMATIONS.frameConfig.frameHeight/2 - diff_heightFrame_heightEntity, 
        GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
        GlobalConfig.ANIMATIONS.frameConfig.frameHeight
    ) 
    love.graphics.setColor(1, 1, 1, 1)
end
function Entity:drawBoundingBox()
    -- Draw the bounding box for debugging purposes
    local x, y, w, h = self:getBoundingBox()
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
end
function Entity:collidesWith(otherEntity)
    local x1, y1, w1, h1 = self:getBoundingBox()
    local x2, y2, w2, h2 = otherEntity:getBoundingBox()
    -- 2 entities collide if their centers overlap
    -- AABB collision detection
    -- x1, y1 are the top-left corner of the first entity
    -- x2, y2 are the top-left corner of the second entity
    -- w1, h1 are the width and height of the first entity
    -- w2, h2 are the width and height of the second entity
    -- Check if the bounding boxes overlap
    -- Return true if they overlap, false otherwise
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end


-- Metamethods for string representation and comparison
function Entity:__tostring()
    return string.format("Entity: %s, Health: %d, Position: (%.2f, %.2f)", self.name, self.health, self.position.x, self.position.y)
end
function Entity:__lt(other)
    return self.health < other.health
end
function Entity:__le(other)
    return self.health <= other.health
end
function Entity:__gt(other)
    return self.health > other.health
end
function Entity:__ge(other)
    return self.health >= other.health
end


return Entity