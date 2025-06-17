local love = require("love")
local GlobalConfig = require("global_config")
local Utils = require("utils")
local shader = require("shaders")
local Game = Utils.Game

function love.conf(t)
    -- Set the window title and dimensions
    t.window.title = GlobalConfig.WINDOW.WINDOW_TITLE
    t.window.width = GlobalConfig.WINDOW.WINDOW_WIDTH
    t.window.height = GlobalConfig.WINDOW.WINDOW_HEIGHT
    -- Set the window icon (optional, if you have an icon file)
    -- t.window.icon = love.image.newImageData(GlobalConfig.gameConfig.WINDOW_ICON)

    -- Enable VSync for smoother rendering
    t.window.vsync = true 
    -- Set the target FPS
    t.window.fps = GlobalConfig.FPS 
    -- Enable console for debugging (if running in a terminal)
    t.console = GlobalConfig.DEBUG_MODE 
    -- Set the game to be resizable
    t.window.resizable = GlobalConfig.WINDOW.RESIZABLE

    t.modules.joystick = GlobalConfig.INPUT.JOYSTICK_ENABLED
    t.modules.mouse = GlobalConfig.INPUT.MOUSE_ENABLED
end
--[[
         __         ______    ______   _______  
        /  |       /      \  /      \ /       \ 
        $$ |      /$$$$$$  |/$$$$$$  |$$$$$$$  |
        $$ |      $$ |  $$ |$$ |__$$ |$$ |  $$ |
        $$ |      $$ |  $$ |$$    $$ |$$ |  $$ |
        $$ |      $$ |  $$ |$$$$$$$$ |$$ |  $$ |
        $$ |_____ $$ \__$$ |$$ |  $$ |$$ |__$$ |
        $$       |$$    $$/ $$ |  $$ |$$    $$/ 
        $$$$$$$$/  $$$$$$/  $$/   $$/ $$$$$$$/  
--]]
-- This is the main entry point for the game
-- It initializes the game, loads assets, and starts the main loop
-- It is called by the LOVE2D framework when the game starts
function love.load()
    -- @MAIN INITIALIZATION =========================================================================
    love.window.setMode(800, 600, {resizable = false, vsync = true})

    -- @MAIN ASSETS      ==================================================================================================================================================
    -- Load assets such as images, fonts, sounds, etc.
    -- This is where you load all the assets you need for the gameData
    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    -- Set the default filter for images to nearest neighbor for pixel art style
    love.graphics.setDefaultFilter("nearest", "nearest") 
    
    -- Load the shader for lighting effects
    shader = love.graphics.newShader(shader.lightShader)
    shader:send("globalAmbientColor", {0.1, 0.1, 0.1, 1.0})

    -- @MAIN GAME        ==================================================================================================================================================
    -- Initialize game 
    Game = Game:new()

    --@MAIN PLAYER       ==================================================================================================================================================
    -- Initialize player
    Game:loadPlayerData()
    print("Game initialized with player: " .. Game.gameData.player.name)    
    -- @MAIN CAMERA      ==================================================================================================================================================
    -- Initialize camera
    Game:loadCamera()
    print("Camera initialized at position: " .. Game.gameData.cameraWorld:getPosition())
end
--[[
         __    __  _______   _______    ______   ________  ________ 
        /  |  /  |/       \ /       \  /      \ /        |/        |
        $$ |  $$ |$$$$$$$  |$$$$$$$  |/$$$$$$  |$$$$$$$$/ $$$$$$$$/ 
        $$ |  $$ |$$ |__$$ |$$ |  $$ |$$ |__$$ |   $$ |   $$ |__    
        $$ |  $$ |$$    $$/ $$ |  $$ |$$    $$ |   $$ |   $$    |   
        $$ |  $$ |$$$$$$$/  $$ |  $$ |$$$$$$$$ |   $$ |   $$$$$/    
        $$ \__$$ |$$ |      $$ |__$$ |$$ |  $$ |   $$ |   $$ |_____ 
        $$    $$/ $$ |      $$    $$/ $$ |  $$ |   $$ |   $$       |
         $$$$$$/  $$/       $$$$$$$/  $$/   $$/    $$/    $$$$$$$$/ 
--]]
-- dt is the delta time since the last frame
-- This is used to update the game state and animations
-- It is called every frame by the LOVE2D framework
function love.update(dt)

    -- @GAME STATE UPDATE  ==================================================================================================================================================
    Game:updateTime(dt)
    
    
    local player = Game.gameData.player
    if not player then
        return 
    end
    local enemies = Game.gameData.enemies
    local world = Game.gameData.physicsWorld
    local camera = Game.gameData.cameraWorld
    if not world or not camera then
        return 
    end

    world:update(dt)
    Game:checkEnemyCollision(player,dt)

    player:handleInput()
    player:update(dt, world)

    for i = #enemies, 1, -1 do 
        local enemy = enemies[i]
        enemy:moveTowardsPlayer(player.position.x)
        enemy:update(dt, world)
        if enemy.isDead and not enemy.isFinished and enemy.physicsBody ~= nil then    
            enemy.physicsBody:destroy()
            enemy.physicsBody = nil
            enemy.physicsFixture = nil
        elseif enemy.isDead and enemy.isFinished then
            table.remove(enemies, i)
            player.score = player.score + GlobalConfig.GAMEPLAY.scorePerKill
        end
    end

    if GlobalConfig.GAMEPLAY.enemySpawnRate > 0 then
        if Game.gameData.timeElapsed >= GlobalConfig.GAMEPLAY.enemySpawnRate then
            -- Spawn a new enemy every "enemySpawnRate" seconds
            Game:spawnEnemy()
            Game.gameData.timeElapsed = 0
        end
    end

    -- @MAIN CAMERA         ==================================================================================================================================================
    -- Update camera position based on player position
    -- such that when drawing the player is always centered in the camera view
    camera:setPosition(
        player.position.x - camera:getSize() / 2, 
        player.position.y - camera:getSize() / 2
    )

end
--[[
         _______   ________   ______   ______  ________  ________ 
        /       \ /        | /      \ /      |/        |/        |
        $$$$$$$  |$$$$$$$$/ /$$$$$$  |$$$$$$/ $$$$$$$$/ $$$$$$$$/ 
        $$ |__$$ |$$ |__    $$ \__$$/   $$ |      /$$/  $$ |__    
        $$    $$< $$    |   $$      \   $$ |     /$$/   $$    |   
        $$$$$$$  |$$$$$/     $$$$$$  |  $$ |    /$$/    $$$$$/    
        $$ |  $$ |$$ |_____ /  \__$$ | _$$ |_  /$$/____ $$ |_____ 
        $$ |  $$ |$$       |$$    $$/ / $$   |/$$      |$$       |
        $$/   $$/ $$$$$$$$/  $$$$$$/  $$$$$$/ $$$$$$$$/ $$$$$$$$/ 
--]]
-- This function is called when the game window is resized
-- It is called by the LOVE2D framework when the window size changes
function love.resize(w, h)
    -- Update the game state or UI if necessary
    print("Window resized to: " .. w .. "x" .. h)
end
--[[
         __    __  ________  __      __  _______   _______   ________   ______    ______  
        /  |  /  |/        |/  \    /  |/       \ /       \ /        | /      \  /      \ 
        $$ | /$$/ $$$$$$$$/ $$  \  /$$/ $$$$$$$  |$$$$$$$  |$$$$$$$$/ /$$$$$$  |/$$$$$$  |
        $$ |/$$/  $$ |__     $$  \/$$/  $$ |__$$ |$$ |__$$ |$$ |__    $$ \__$$/ $$ \__$$/ 
        $$  $$<   $$    |     $$  $$/   $$    $$/ $$    $$< $$    |   $$      \ $$      \ 
        $$$$$  \  $$$$$/       $$$$/    $$$$$$$/  $$$$$$$  |$$$$$/     $$$$$$  | $$$$$$  |
        $$ |$$  \ $$ |_____     $$ |    $$ |      $$ |  $$ |$$ |_____ /  \__$$ |/  \__$$ |
        $$ | $$  |$$       |    $$ |    $$ |      $$ |  $$ |$$       |$$    $$/ $$    $$/ 
        $$/   $$/ $$$$$$$$/     $$/     $$/       $$/   $$/ $$$$$$$$/  $$$$$$/   $$$$$$/  
--]]
-- This function is called when a key is pressed
-- It is used to handle input from the player
-- It is called by the LOVE2D framework when a key is pressed
function love.keypressed(key)
    if key == "escape" then
        print("Game exited by user.")
        love.event.quit()

    elseif key == "f" then
        -- Toggle fullscreen mode
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen, "desktop")

        print("Fullscreen mode toggled: " .. tostring(not isFullscreen))
    end
end
--[[
         _______   _______    ______   __       __ 
        /       \ /       \  /      \ /  |  _  /  |
        $$$$$$$  |$$$$$$$  |/$$$$$$  |$$ | / \ $$ |
        $$ |  $$ |$$ |__$$ |$$ |__$$ |$$ |/$  \$$ |
        $$ |  $$ |$$    $$< $$    $$ |$$ /$$$  $$ |
        $$ |  $$ |$$$$$$$  |$$$$$$$$ |$$ $$/$$ $$ |
        $$ |__$$ |$$ |  $$ |$$ |  $$ |$$$$/  $$$$ |
        $$    $$/ $$ |  $$ |$$ |  $$ |$$$/    $$$ |
        $$$$$$$/  $$/   $$/ $$/   $$/ $$/      $$/ 
--]]
-- This function is called to draw the game state to the screen
-- It is called every frame by the LOVE2D framework
function love.draw()
    
    local canvas = Game.gameData.renderCanvas
    love.graphics.setCanvas(canvas)
    -- Clear the canvas with a dark color
    love.graphics.clear(0.15, 0.15, 0.15,0.9) 
    love.graphics.push()
    

    -- @MAIN DRAWING        ==================================================================================================================================================
    -- Apply camera transformations
    Game.gameData.cameraWorld:apply()
    
    -- draw background
    -- Game:drawBackground()

    -- Draw the game entities info (like health)
    Game:drawInfo()
    
    -- Draw the game world
    -- Game:drawWorld()
    
    -- Draw player
    -- Draw enemies
    Game:drawEntities()
    
    if GlobalConfig.DEBUG_MODE then
        Game:drawDebugPhysics()
    end

    -- Unapply camera transformations
    Game.gameData.cameraWorld:unapply()
    -- @MAIN DRAWING        ==================================================================================================================================================
    
    -- Reset the canvas to the default framebuffer
    love.graphics.pop()
    -- Reset the canvas to the default framebuffer
    love.graphics.setCanvas()

    -- @MAIN LIGHTING       ==================================================================================================================================================
    love.graphics.setColor(1, 1, 1, 1) 
    -- Set the shader for lighting effects
    love.graphics.setShader(shader) 
    
    -- Set the shader parameters for lighting
    -- Send the camera position to the shader
    local lights = {}

    -- Send the lights to the shader (player light and other lights)
    -- Add player light (a flashlight effect)
    -- same as the struct Light in the shader
    table.insert(lights, {
        -- Position of the light in canvas coordinates (x, y, z)
        -- light is moving along with the camera
        position = {
            Game.gameData.player.position.x - Game.gameData.cameraWorld.x, 
            Game.gameData.player.position.y - Game.gameData.cameraWorld.y,
            0
        },
        -- Color of the light (RGBA) 
        color = {1.0, 0.9, 0.6, 0.25},
        -- innerCutOff angle that specifies the spotlight's radius
        -- outerCutOff angle that specifies the spotlight's outer radius
        -- 45 degree
        outerCutOff = math.cos(math.rad(35)),
        innerCutOff = math.cos(math.rad(15)),
        -- Direction of the light (for spotlight effect)
        direction = {
            Game.gameData.player.direction, 
            0, 
            0
        },
        -- Constants for light attenuation
        constant = 10.0,
        linear = 0.045,
        quadratic = 0.0075,
        -- Constants for light strength
        ambientStrength = 1.5,
        diffuseStrength = 1.0,
        specularStrength = 1.0,
    })
    -- Add other lights (if any)
    -- Example of adding a static light (e.g., street light)
    for i = 1, 10 do
        -- Static lights can be positioned at fixed locations in the game world
        -- Here we add a static light at a fixed position
        -- You can modify the position and color as needed
        table.insert(lights, {
            position = {200*i - Game.gameData.cameraWorld.x, 50 + Game.gameData.cameraWorld.y,0}, 
            color = {1.0, 1.0, 1.0, 0.5},
            outerCutOff = math.cos(math.rad(17.5)),
            innerCutOff = math.cos(math.rad(12.5)),
            direction = {0, 1, 0},
            constant = 1.0,
            linear = 0.09,
            quadratic = 0.032,
            ambientStrength = 0.2,
            diffuseStrength = 0.5,
            specularStrength = 0.5,
        })
    end

    -- Send the number of lights to the shader
    shader:send("num_lights", #lights) 
    -- Send the lights to the shader
    for i, light in ipairs(lights) do
        shader:send("spotLights[" .. (i - 1) .. "].position", light.position)
        shader:send("spotLights[" .. (i - 1) .. "].color", light.color)
        shader:send("spotLights[" .. (i - 1) .. "].outerCutOff", light.outerCutOff)
        shader:send("spotLights[" .. (i - 1) .. "].innerCutOff", light.innerCutOff)
        shader:send("spotLights[" .. (i - 1) .. "].direction", light.direction)
        shader:send("spotLights[" .. (i - 1) .. "].constant", light.constant)
        shader:send("spotLights[" .. (i - 1) .. "].linear", light.linear)
        shader:send("spotLights[" .. (i - 1) .. "].quadratic", light.quadratic)
        shader:send("spotLights[" .. (i - 1) .. "].ambientStrength", light.ambientStrength)
        shader:send("spotLights[" .. (i - 1) .. "].diffuseStrength", light.diffuseStrength)
        shader:send("spotLights[" .. (i - 1) .. "].specularStrength", light.specularStrength)
    end

    -- Draw the canvas with the shader applied
    love.graphics.draw(canvas, 0, 0)
    
    -- Reset shader to default
    love.graphics.setShader() 
    -- @MAIN LIGHTING       ==================================================================================================================================================


    -- @MAIN UI           ==================================================================================================================================================
    -- Draw the UI elements (not affected by the shader or camera)
    -- Game:drawUI()
    -- @MAIN UI           ==================================================================================================================================================
    
   
    -- @DEBUG_INFO          ==================================================================================================================================================
    if GlobalConfig.DEBUG_MODE then
        Game:drawDebugInfo()
    end
    -- @DEBUG_INFO          ==================================================================================================================================================
end

