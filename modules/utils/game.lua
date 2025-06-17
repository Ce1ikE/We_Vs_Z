local love = require("love")
local Enemy = require("entities.enemy")
local GlobalConfig = require("global_config")
local Player = require("entities.player")
local Camera = require("utils.camera")
--[[
    Game Utilities Module
    It handles serialization and deserialization of game entities, and provides functions to save and load game state.
    Also includes a function to reset the game state.
    This module is essential for managing game state persistence and entity management.
--]]
local Game = {}

function Game:new()
    self.__index = self
    local instance = setmetatable({}, self)

    instance.gameStates = {
        MENU = 1,
        PLAYING = 2,
        GAME_OVER = 3,
    }
    
    instance.gameData = {
        cameraWorld = Camera,
        physicsWorld = love.physics.newWorld(0,0), -- Physics world for the game
        renderCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight()),


        player = Player,   -- Player entity
        enemies = {},   -- Table to hold Enemy entities
        items   = {},   -- Table to hold Item  entities

        level = 1,      -- Current game level
        maxLevel = 10,  -- Maximum game level
        timeElapsed = 0, -- Time elapsed in the current game session
        currentState =  instance.gameStates.MENU, -- Current game state
        previousState = instance.gameStates.MENU, -- Previous game state
    }
    
    return instance
end

function Game:switchState()
    if self.previous ~= self.current then
        self.previous = self.current
    end
end
function Game:isMenu()
    return self.current == self.states.MENU
end
function Game:isPlaying()
    return self.current == self.states.PLAYING
end
function Game:isGameOver()
    return self.current == self.states.GAME_OVER
end

function Game:updateTime(dt)
    -- Update the time elapsed in the game
    self.gameData.timeElapsed = self.gameData.timeElapsed + dt
end

function Game:drawInfo()
    local player = self.gameData.player
    local enemies = self.gameData.enemies

    if not player then
        return
    end

    player:drawHealthBar()
    player:drawBox()
    player:drawBoundingBox()
    player:drawBullets()
    player:drawBulletBar()


    if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
            enemy:drawHealthBar()
            enemy:drawBox()
            enemy:drawBoundingBox()
        end
    end
end

function Game:drawEntities()
    local player = self.gameData.player
    local enemies = self.gameData.enemies

    if not player then
        return
    end

    player:draw()

    if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
            enemy:draw()
        end
    end

end

function Game:drawBackground()
    -- Draw the background
    -- love.graphics.setColor(1, 1, 1,1)
    -- for _, image in ipairs(GlobalConfig.SPRITES.background) do
    --     love.graphics.draw(
    --         image,
    --         -- position X, position Y
    --         0, love.graphics.getHeight() - image:getHeight(), 
    --         -- rotation
    --         0, 
    --         -- scale X
    --         love.graphics.getWidth()/image:getWidth(), 
    --         -- scale Y
    --         1, 
    --         -- offset X
    --         0, 
    --         -- offset Y
    --         0 
    --     )
    -- end
end

function Game:drawDebugInfo()
    local player = self.gameData.player
    local enemies = self.gameData.enemies
    -- Reset color to white for debug info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Player Health: " .. player.health, 10, 10)
    love.graphics.print("Player Position: (" .. player.position.x .. ", " .. player.position.y .. ")", 10, 30)
    love.graphics.print("Time Elapsed: " .. string.format("%.2f", self.gameData.timeElapsed), 10, 50)
    love.graphics.print("Enemies Count: " .. #enemies, 10, 70)
    if player.isDead then
        love.graphics.print("Player is dead!", 10, 90)
    else
        love.graphics.print("Player is alive!", 10, 90)
    end
    love.graphics.print("Player Score: " .. player.score, 10, 110)
    love.graphics.print("Shots fired: " .. player.shotsFired, 10, 130)
    love.graphics.print("Current Game State: " .. self.gameData.currentState, 10, 150)
    -- Draw the FPS counter
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 170)
    -- Draw the current level
    love.graphics.print("Current Level: " .. self.gameData.level, 10, 190)
    -- Draw the maximum level
    love.graphics.print("Max Level: " .. self.gameData.maxLevel, 10, 210)
end

function Game:drawDebugPhysics()
    local world = self.gameData.physicsWorld
    -- Draw physics bodies for debugging
    love.graphics.setColor(1, 1, 0, 0.8) -- Set color for physics bodies
    for _, body in pairs(world:getBodies()) do
        for _, fixture in pairs(body:getFixtures()) do
            local shape = fixture:getShape()

            if shape:typeOf("CircleShape") then
                local cx, cy = body:getWorldPoints(shape:getPoint())
                love.graphics.circle("line", cx, cy, shape:getRadius())
            
            elseif shape:typeOf("PolygonShape") then
                love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
            
            else
                love.graphics.line(body:getWorldPoints(shape:getPoints()))
            end
        end
    end
end

function Game:loadCamera()
    -- Initialize the camera with the game world dimensions
    local newCamera = Camera:new(
        GlobalConfig.GAMEPLAY.camera.x, 
        GlobalConfig.GAMEPLAY.camera.y, 
        GlobalConfig.GAMEPLAY.camera.width, 
        GlobalConfig.GAMEPLAY.camera.height
    )
    self.gameData.cameraWorld = newCamera
    return true
end

function Game:loadPlayerData()
    local newPlayer = Player:new(
        GlobalConfig.GAMEPLAY.player.defaultName,
        GlobalConfig.GAMEPLAY.player.defaultHealth,
        GlobalConfig.GAMEPLAY.player.defaultPosition,
        GlobalConfig.GAMEPLAY.player.defaultDirection
    )
    self.gameData.player = newPlayer 
    newPlayer:setPhysicsBody(self.gameData.physicsWorld)

    self.gameData.player.states[self.gameData.player.currentState].animation:play()
    return true
end

function Game:spawnEnemy()
    -- Check if the maximum number of enemies has been reached
    if #self.gameData.enemies >= GlobalConfig.GAMEPLAY.maxEnemies then
        return false
    end

    local newEnemy = Enemy:new(
        GlobalConfig.GAMEPLAY.zombie.defaultName, 
        GlobalConfig.GAMEPLAY.zombie.defaultHealth, 
        GlobalConfig.GAMEPLAY.zombie.defaultPosition, 
        GlobalConfig.GAMEPLAY.zombie.defaultDirection
    ) 
    table.insert(
        self.gameData.enemies,
        newEnemy
    )
    
    newEnemy:setPhysicsBody(self.gameData.physicsWorld)

    return true
end

function Game:checkEnemyCollision(player,dt)
    for _, enemy in ipairs(self.gameData.enemies) do
        if enemy:collidesWith(player) then
            enemy:attack(player, dt)
            if player.isDead then
                self.currentState = self.gameStates.GAME_OVER
            end
        else 
            enemy:move(player, dt)
        end
    end
end


return Game