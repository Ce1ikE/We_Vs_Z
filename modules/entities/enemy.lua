local love = require("love")
local GlobalConfig = require("global_config")
local Entity = require("entities.entity")
local Animation = require("utils.animation")

--[[
    Enemy entity module
    This module defines the enemy entity with properties and methods for movement, attacking, and state management.
    It extends the base `Entity` class and includes specific enemy behaviors.
    The enemy can walk towards the player, attack, and die. It also manages its own state animations.
    The enemy has different states such as walking, dead, and attacking.
--]]
local Enemy = {}

Enemy.__index = Enemy 
setmetatable(Enemy, {
    -- Inherit from Entity class
    __index = Entity,
    __call = function(cls, ...)
        return cls:new(...)
    end,
})

-- Constructor for enemy entityType
function Enemy:new(name, health, position, direction)
    local instance = {}
    setmetatable(instance, self)
    -- Initialize Enemy properties
    instance.entityType = "enemy"
    instance.name = name or "Enemy"
    instance.health = health or 100
    instance.position = {x = love.math.random(0,100) , y = position.y} or {x = 0, y = love.graphics.getHeight()}
    -- 1 for right, -1 for left
    instance.direction = direction or 1
    instance.width = GlobalConfig.GAMEPLAY.zombie.width
    instance.height = GlobalConfig.GAMEPLAY.zombie.height
    instance.speed = 20 -- Speed in pixels per second
    instance.currentAttackCooldown = 0 -- Cooldown time in seconds between attacks
    instance.attackCooldown = GlobalConfig.GAMEPLAY.zombie.attackCooldown
    instance.isAttacking = false
    instance.isFinished = false
    instance.isMoving = false
    instance.currentState = 1
    instance.STATES = {
        WALKING = 1,
        DEAD = 2,
        ATTACKING = 3
    }
    
    -- Possible states: walking, dead, attacking
    instance.states = {
        {
            -- State walking
            stateIndex = 1,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.zombieAnimations.walkAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.zombieAnimations.walkAnimation[2],
                GlobalConfig.ANIMATIONS.zombieAnimations.walkAnimation[3]
            )
        },
        {
            -- State dead
            stateIndex = 2,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.zombieAnimations.deadAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.zombieAnimations.deadAnimation[2],
                GlobalConfig.ANIMATIONS.zombieAnimations.deadAnimation[3]
            )
        },
        {
            -- State attacking
            stateIndex = 3,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.zombieAnimations.attackAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.zombieAnimations.attackAnimation[2],
                GlobalConfig.ANIMATIONS.zombieAnimations.attackAnimation[3]
            )
        },
    }

    -- Start the walking animation by default
    instance.states[instance.currentState].animation:play() 

    return instance
end

function Enemy:clone()
    local clone = Enemy:new(self.name, self.health, {x = self.position.x, y = self.position.y}, self.direction)
    clone.speed = self.speed
    clone.currentState = self.currentState
    return clone
end

function Enemy:moveTowardsPlayer(playerX)
    -- Move the enemy towards the player
    if self.position.x < playerX then
        self.direction = 1
    elseif self.position.x > playerX then
        self.direction = -1
    end
end

function Enemy:updatePosition(dt)
    self.position.x = self.position.x + (self.speed * dt * self.direction)
    self.physicsBody:setLinearVelocity(self.speed * self.direction, 0)
    self.physicsBody:setPosition(self.position.x, self.position.y)

    -- Clamp enemy position to screen bounds
    -- local screenWidth = love.graphics.getWidth()
    -- Assuming position.x is the center of the player for clamping
    -- self.position.x = math.max(self.width / 2, math.min(self.position.x, screenWidth - self.width / 2))

    
end

function Enemy:die()
    -- Change state to dead and play dead animation
    self:updateState(self.STATES.DEAD)
    self.isDead = true
    self.speed = 0
end

function Enemy:attack(player,dt)
    self.isAttacking = true
    self.isMoving = false
    self.currentAttackCooldown = self.currentAttackCooldown - dt
    if self.currentAttackCooldown <= 0 then
        -- Perform attack logic here, e.g., reduce player's health
        player:takeDamage(GlobalConfig.GAMEPLAY.zombie.damage)
        self.currentAttackCooldown = self.attackCooldown -- Reset cooldown
        self.isAttacking = false -- Reset attacking state after attack
    end
end

function Enemy:move(player,dt)
    self.isMoving = true
    self.isAttacking = false
end

function Enemy:updateState(newState)
    if self.currentState ~= newState then
        -- Pause old animation (important if you have non-looping animations)
        local oldStateData = self.states[self.currentState]
        if oldStateData and oldStateData.animation then
            oldStateData.animation:pause()
            oldStateData.animation:stop()
        end

        self.currentState = newState
        local newStateData = self.states[self.currentState]
        if newStateData and newStateData.animation then
            newStateData.animation:play()
        end

        self.physicsBody:setLinearVelocity(0, 0) -- Reset velocity when changing state
    end
end

function Enemy:update(dt,world)
    -- Update enemy position and state
    if self.isDead then
        self:updateState(self.STATES.DEAD)
        if self.states[self.currentState].animation:isAnimationFinished() then
            self.isFinished = true 
        end
    elseif self.isAttacking then
        self:updateState(self.STATES.ATTACKING)
    elseif self.isMoving then
        self:updateState(self.STATES.WALKING)
        self:updatePosition(dt)
    end
    -- Update the current state animation
    self.states[self.currentState].animation:update(dt)
end

function Enemy:draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the enemy based on its current state
    local currentState = self.states[self.currentState]
    if currentState and currentState.animation then
        local diff_heightFrame_heightEnemy = (GlobalConfig.ANIMATIONS.frameConfig.frameHeight - self.height)/2
        currentState.animation:draw(
            self.position.x, 
            self.position.y - diff_heightFrame_heightEnemy, 
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

        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.print("Frame box", 
            self.position.x - GlobalConfig.ANIMATIONS.frameConfig.frameWidth/2, 
            self.position.y - diff_heightFrame_heightEnemy - GlobalConfig.ANIMATIONS.frameConfig.frameHeight/2 - 20
        )
        love.graphics.rectangle("line", 
            self.position.x  - GlobalConfig.ANIMATIONS.frameConfig.frameWidth/2, 
            self.position.y  - GlobalConfig.ANIMATIONS.frameConfig.frameHeight/2 - diff_heightFrame_heightEnemy, 
            GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
            GlobalConfig.ANIMATIONS.frameConfig.frameHeight
        ) 
        love.graphics.setColor(1, 1, 1, 1)
    end
end


return Enemy