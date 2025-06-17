-- modules/building.lua
local love = require("love")
local GlobalConfig = require("global_config")
local Entity = require("entities.entity") 

local Building = {}
Building.__index = Building

setmetatable(Building, {
    __index = Entity, -- Inherit from your base Entity class
    __call = function(cls, ...)
        return cls:new(...)
    end,
})

function Building:new(world, x, y, type)
    local instance = {}
    setmetatable(instance, self)

    instance.world = world
    instance.entityType = "building" -- Important for user data filtering
    instance.buildingType = type or "default"
    instance.sprite = GlobalConfig.SPRITES.buildings[instance.buildingType] or GlobalConfig.SPRITES.buildings.default

    -- For now, all buildings are enterable
    instance.isEnterable = true 
    instance.isBarricaded = false
    instance.barricadeLevel = 0
    instance.maxBarricadeLevel = 3
    -- Actual health of the barricade
    instance.barricadeHealth = 0 

    -- Physics body for the building (static by default)
    -- 'x' and 'y' are assumed to be the center of the building sprite
    instance.physicsBody = love.physics.newBody(world, x, y, "static")
    instance.physicsShape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physicsFixture = love.physics.newFixture(instance.physicsBody, instance.physicsShape)
    instance.physicsFixture:setUserData(instance) -- Link back to building object

    -- Define a specific 'door' area for player interaction
    instance.doorArea = {
        x = instance.position.x - instance.width / 4,
        y = instance.position.y + instance.height / 2 - 30, -- Bottom part of building
        width = instance.width / 2,
        height = 60
    }

    return instance
end

function Building:update(dt)
    -- Logic for building (e.g., if it can be damaged, change visual state)
    -- If barricade health drops to zero, set isBarricaded = false
    if self.isBarricaded and self.barricadeHealth <= 0 then
        self.isBarricaded = false
        self.barricadeLevel = 0
        print("Barricade broken!")
    end
end

function Building:draw()
    -- Adjust draw position from center of physics body to top-left of sprite
    local drawX = self.position.x - self.width / 2
    local drawY = self.position.y - self.height / 2

    love.graphics.draw(self.sprite, drawX, drawY, 0, self.width / self.sprite:getWidth(), self.height / self.sprite:getHeight())

    if self.isBarricaded then
        -- Draw barricade visuals (e.g., different sprite based on barricadeLevel)
        local barricadeSprite = GlobalConfig.SPRITES.barricades.level1 -- Example
        love.graphics.draw(barricadeSprite, self.doorArea.x, self.doorArea.y, 0, self.doorArea.width / barricadeSprite:getWidth(), self.doorArea.height / barricadeSprite:getHeight())
    end

    -- Debug draw physics body
    if GlobalConfig.DEBUG_MODE then
        love.graphics.setColor(0.8, 0, 0.8, 0.5) -- Purple transparent
        local bodyX, bodyY = self.physicsBody:getPosition()
        local shape = self.physicsFixture:getShape()
        local vertices = {shape:getVertices()}
        local worldVertices = {}
        for i = 1, #vertices, 2 do
            local vx, vy = vertices[i], vertices[i+1]
            local wx, wy = self.physicsBody:getWorldPoint(vx, vy)
            table.insert(worldVertices, wx)
            table.insert(worldVertices, wy)
        end
        love.graphics.polygon("line", worldVertices)
        love.graphics.setColor(1, 1, 1, 1)

        -- Debug draw door area
        love.graphics.setColor(0, 0, 1, 0.5) -- Blue for door area
        love.graphics.rectangle("line", self.doorArea.x, self.doorArea.y, self.doorArea.width, self.doorArea.height)
        love.graphics.setColor(1,1,1,1)
    end
end

function Building:barricade()
    if not self.isBarricaded and self.barricadeLevel < self.maxBarricadeLevel then
        self.barricadeLevel = self.barricadeLevel + 1
        self.isBarricaded = true -- Set to true once the first level is applied
        self.barricadeHealth = self.barricadeHealth + GlobalConfig.BUILDING.barricadeHealthBoost
        print("Building barricaded to level " .. self.barricadeLevel .. ", health: " .. self.barricadeHealth)
        return true
    elseif self.isBarricaded and self.barricadeLevel < self.maxBarricadeLevel then
        self.barricadeLevel = self.barricadeLevel + 1
        self.barricadeHealth = self.barricadeHealth + GlobalConfig.BUILDING.barricadeHealthBoost
        print("Building barricaded to level " .. self.barricadeLevel .. ", health: " .. self.barricadeHealth)
        return true
    else
        print("Building already fully barricaded!")
        return false
    end
end

function Building:takeDamage(amount)
    if self.isBarricaded then
        self.barricadeHealth = self.barricadeHealth - amount
        print("Barricade took " .. amount .. " damage, remaining health: " .. self.barricadeHealth)
    else
        -- Implement damage to the building itself if not barricaded, or if barricade is gone
        print("Building cannot take direct damage yet (no health system for non-barricade).")
    end
end

function Building:destroy()
    if self.physicsBody then
        self.physicsBody:destroy()
        self.physicsBody = nil
        self.physicsFixture = nil
    end
end

return Building