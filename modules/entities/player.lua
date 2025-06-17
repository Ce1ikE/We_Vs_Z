local love = require("love")
local GlobalConfig = require("global_config")
local Entity = require("entities.entity")
local Animation = require("utils.animation")

--[[
    Player entity module
    This module defines the player entity with properties and methods for movement, shooting, and state management.
    It extends the base `Entity` class and includes specific player behaviors.
    The player can walk, run, and shoot bullets. It also manages its own state animations.
    The player has an inventory and a bullet buffer to manage collected items and fired bullets.
    The player can be in different states such as idle, moving, shooting, and running.  
    Each state has its own animation defined in the GlobalConfig.
    The player can update its position based on the current speed and direction.
--]]
local Player = {}

Player.__index = Player
setmetatable(Player, {
    -- Inherit from Entity class
    __index = Entity, 
    __call = function(cls, ...)
        return cls:new(...)
    end,
})
-- Constructor for player entity
function Player:new(name, health, position, direction)
    local instance = {}
    -- this will create a new instance of Player
    -- and set the metatable to Player
    -- This allows us to use Player:method() syntax
    -- Player itself is a table with methods and properties
    -- Player also inherits from Entity
    -- which also has methods and properties
    setmetatable(instance, self)
    -- Initialize Player properties
    instance.entityType = "player"
    instance.name = name or "Hero"
    instance.health = health or 100
    instance.position = position or {x = 0, y = love.graphics.getHeight()}
    -- 1 for right, -1 for left
    instance.direction = direction or 1
    instance.inventory = {}
    instance.isRunning = false
    instance.isMoving = false
    instance.isShooting = false
    instance.isRecharging = false
    instance.canShoot = true 
    instance.shootCooldown = GlobalConfig.GAMEPLAY.player.shootCooldown or 0.5
    instance.currentShootCooldown = 0
    instance.lastShot = nil -- Store last shot details for drawing
    instance.shotsFired = 0 -- Count of shots fired by the player
    -- Initialize score
    instance.score = 0
    -- Possible states: idle, moving, shooting
    instance.STATES = {
        IDLE = 1,
        MOVING = 2,
        SHOOTING = 3,
        RUNNING = 4,
        RECHARGE = 5
    }
    instance.states = {
        {
            -- State idle
            stateIndex = 1,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.playerAnimations.idleAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.playerAnimations.idleAnimation[2],
                GlobalConfig.ANIMATIONS.playerAnimations.idleAnimation[3]
            )
        },
        {
            -- State moving
            stateIndex = 2,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.playerAnimations.walkAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.playerAnimations.walkAnimation[2],
                GlobalConfig.ANIMATIONS.playerAnimations.walkAnimation[3]
            )
        },
        {
            -- State shooting
            stateIndex = 3,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.playerAnimations.shotAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.playerAnimations.shotAnimation[2],
                GlobalConfig.ANIMATIONS.playerAnimations.shotAnimation[3]
            )
        },
        {
            -- State running
            stateIndex = 4,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.playerAnimations.runAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.playerAnimations.runAnimation[2],
                GlobalConfig.ANIMATIONS.playerAnimations.runAnimation[3]
            )
        },
        {
            -- State recharge
            stateIndex = 5,
            animation = Animation:new(
                GlobalConfig.ANIMATIONS.playerAnimations.rechargeAnimation[1],
                GlobalConfig.ANIMATIONS.frameConfig.frameWidth,
                GlobalConfig.ANIMATIONS.frameConfig.frameHeight,
                GlobalConfig.ANIMATIONS.playerAnimations.rechargeAnimation[2],
                GlobalConfig.ANIMATIONS.playerAnimations.rechargeAnimation[3]
            )
        }

    }
    instance.width =  GlobalConfig.GAMEPLAY.player.width
    instance.height =  GlobalConfig.GAMEPLAY.player.height
    -- Speed in pixels per second
    instance.speed = {
        walkSpeed = GlobalConfig.GAMEPLAY.player.walkSpeed,
        runSpeed = GlobalConfig.GAMEPLAY.player.runSpeed,
    }
    -- Default to idle state
    instance.currentState = 1 
    instance.previousState = 1 
    return instance
end

function Player:updatePosition(dt)
    if self.isRunning then
        self.position.x = self.position.x + (self.speed.runSpeed * dt * self.direction)
        self.physicsBody:setLinearVelocity(self.speed.runSpeed * self.direction, 0)
    else
        self.position.x = self.position.x + (self.speed.walkSpeed * dt * self.direction)
        self.physicsBody:setLinearVelocity(self.speed.walkSpeed * self.direction, 0)
    end
    self.physicsBody:setPosition(self.position.x, self.position.y)

    -- Clamp player position to screen bounds
    -- local screenWidth = love.graphics.getWidth()
    -- Assuming position.x is the center of the player for clamping
    -- self.position.x = math.max(self.width / 2, math.min(self.position.x, screenWidth - self.width / 2))

end

function Player:handleInput()
    self.isMoving = false 
    self.isShooting = false

    -- Determine intended movement direction
    local moveLeft = love.keyboard.isDown("a") or love.keyboard.isDown("left")
    local moveRight = love.keyboard.isDown("d") or love.keyboard.isDown("right")

    if moveLeft then
        self.direction = -1
        self.isMoving = true
    elseif moveRight then
        self.direction = 1
        self.isMoving = true
    end

    -- Determine if running
    self.isRunning = (moveLeft or moveRight) and (love.keyboard.isDown("lshift"))

    -- Determine if recharging
    if love.keyboard.isDown("r") then
        self.isRecharging = true
        -- Stop shooting while recharging
        self.isShooting = false 
    elseif love.keyboard.isDown("space") then
        self.isShooting = true
        -- Stop recharging while shooting
        self.isRecharging = false
    end

end

function Player:fireHitscanShot(world)
    local startX, startY = self.position.x, self.position.y -- Origin of the shot
    local endX, endY -- Calculated end point far away

    -- Calculate end point: Extend ray far in player's direction
    -- How far the shot can travel
    local rayLength = 1000 
    -- Assuming direction is 1 for right, -1 for left
    endX = startX + rayLength * self.direction 
    -- Straight shot add cos or sin if you want to shoot at an angle + random to make it more realistic
    -- Slightly randomize vertical angle
    endY = startY  + 3*self.height * math.sin(
        math.rad(
            love.math.random(-15,15) 
        )
    ) 

    local closestFraction = 1 -- Fraction of the ray to the hit point (1 means no hit)
    local hitFixture = nil
    local hitX, hitY = nil, nil
    local hitNormalX, hitNormalY = nil, nil

    -- Perform the raycast
    -- https://love2d.org/wiki/World:rayCast
    -- callback: function(fixture, x, y, nx, ny, fraction)
    -- returns 'fraction' for closest hit, or 1 to continue, or -1 to stop
    world:rayCast(startX, startY, endX, endY, function(fixture, x, y, nx, ny, fraction)
        -- Filter out self-collision if player has a physics body
        -- Assuming player has self.physicsBody
        if fixture:getBody() == self.physicsBody then
            return 1 -- Continue, ignore self
        end

        -- Only consider valid targets (e.g., enemies)
        -- You might store a reference to the actual Enemy object in the fixture's userData
        local entity = fixture:getUserData()

        if entity then
            if fraction < closestFraction then
                closestFraction = fraction
                hitFixture = fixture
                hitX, hitY = x, y
                hitNormalX, hitNormalY = nx, ny
            end
        end
        return fraction -- Return fraction to find the closest hit
    end)

    if hitFixture then
        local hitEnemy = hitFixture:getUserData()
        hitEnemy:takeDamage(GlobalConfig.GAMEPLAY.bullet.damage)
        -- Optional: Add visual effect at hitX, hitY (e.g., spark, blood splatter)
        self.lastShot = {
            hit = true,
            startX = startX,
            startY = startY,
            endX = hitX,
            endY = hitY
        }

    else
        -- No hit, shot went into the void (or hit environment that doesn't count as enemy)
        self.lastShot = {
            hit = false,
            startX = startX,
            startY = startY,
            endX = endX,
            endY = endY
        }
    end
end

function Player:update(dt,world)

    if self.isRecharging and 0 < self.shotsFired  then
        self:updateState(self.STATES.RECHARGE)
        if self.states[self.currentState].animation:isAnimationFinished() then
            self:updateState(self.STATES.IDLE)
            self.isRecharging = false
            -- Reset shots fired after recharging
            self.shotsFired = 0 
            -- Reset cooldown after recharging
            self.currentShootCooldown = 0 
        end

    elseif self.isShooting and self.shotsFired < GlobalConfig.GAMEPLAY.player.maxShots then
        self:updateState(self.STATES.SHOOTING)
        if self.currentShootCooldown <= 0  then
            self.shotsFired = self.shotsFired + 1
            -- Fire a hitscan shot
            self:fireHitscanShot(world) 
            -- Reset cooldown
            self.currentShootCooldown = self.shootCooldown 
        else
            self.currentShootCooldown = self.currentShootCooldown - dt
        end
    -- Update position only if moving
    elseif self.isMoving then
        if self.isRunning then
            self:updateState(self.STATES.RUNNING)
        else
            self:updateState(self.STATES.MOVING)
        end
        self:updatePosition(dt) 
    else
        self:updateState(self.STATES.IDLE)
    end

    -- Update the current state animation
    local currentStateData = self.states[self.currentState]
    if currentStateData and currentStateData.animation then
        currentStateData.animation:update(dt)
    end
end

function Player:drawBullets()
                
    if self.lastShot then
        if self.lastShot.hit then
            love.graphics.setColor(0, 1, 0, 0.5) -- Green color for hit
            love.graphics.line(self.lastShot.startX, self.lastShot.startY, self.lastShot.endX, self.lastShot.endY)
            love.graphics.circle("line", self.lastShot.endX, self.lastShot.endY, 5) -- Draw a small circle at the hit point
        else
            love.graphics.setColor(1, 0, 0, 0.5) -- Red color for missed shot
            love.graphics.line(self.lastShot.startX, self.lastShot.startY, self.lastShot.endX, self.lastShot.endY)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Player:drawBulletBar()
    -- Draw a simple bullet count bar
    local x, y = self:getPosition()
    local bulletPercentage = self.shotsFired / GlobalConfig.GAMEPLAY.player.maxShots
    local barWidth = 50
    local barHeight = 5
    local barOffset = 20 

    -- Draw the background of the bullet bar
    love.graphics.setColor(0.2, 0.2, 0.2, 1) -- Dark gray for background
    love.graphics.rectangle("fill", x - barWidth / 2, y - self.height / 2 - barOffset, barWidth, barHeight)

    -- Draw the bullet bar
    love.graphics.setColor(0, 0, 1, 1) -- Blue for health
    love.graphics.rectangle("fill", x - barWidth / 2, y - self.height / 2 - barOffset, barWidth * (1 - bulletPercentage), barHeight)

    -- Reset color to white
    love.graphics.setColor(1, 1, 1, 1)
end

function Player:rechargeWeapon(amount)
    self.currentShootCooldown = 0
    self.isRecharging = true
end

function Player:die()
    -- Default death behavior, can be overridden by subclasses
    print(self.name .. " has died.")
    self.isDead = true
    -- Reset player state or handle game over logic here
end

function Player:reset()
    self.health = 100
    self.position = {x = 0, y = love.graphics.getHeight() - 100}
    self.direction = 1
    self.currentState = 1
    self.score = 0
end

function Player:clone()
    local clone = Player:new(self.name, self.health, {x = self.position.x, y = self.position.y}, self.direction)
    clone.inventory = self.inventory
    clone.isRunning = self.isRunning
    clone.score = self.score
    clone.currentState = self.currentState
    return clone
end
function Player:addToInventory(item)
    table.insert(self.inventory, item)
end
function Player:removeFromInventory(item)
    for i, invItem in ipairs(self.inventory) do
        if invItem == item then
            table.remove(self.inventory, i)
            return true
        end
    end
    return false
end
function Player:clearInventory()
    self.inventory = {}
end
function Player:resetState()
    self.currentState = 1 -- Reset to idle state
    self.isRunning = false
end
function Player:updateState(newState)
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

-- Setters and Getters ======================================================================
function Player:setSpeed(speed)
    self.speed.walkSpeed = speed.walkSpeed or self.speed.walkSpeed
    self.speed.runSpeed = speed.runSpeed or self.speed.runSpeed
end
function Player:getScore()
    return self.score
end
function Player:setScore(score)
    self.score = score
end
function Player:getInventory()
    return self.inventory
end
function Player:setRunning(isRunning)
    self.isRunning = isRunning
end
function Player:getRunning()
    return self.isRunning
end
function Player:getState()
    return self.currentState
end
-- Setters and Getters ======================================================================


return Player