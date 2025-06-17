local love = require("love")

local Config = {}

Config.GAME_VERSION = "0.1"
Config.DEBUG_MODE = true
Config.FPS = 30
Config.INPUT = {
    JOYSTICK_ENABLED = false,
    KEYBOARD_ENABLED = true,
    MOUSE_ENABLED = true,
}
--[[
         _______    ______   ________  __    __   ______  
        /       \  /      \ /        |/  |  /  | /      \ 
        $$$$$$$  |/$$$$$$  |$$$$$$$$/ $$ |  $$ |/$$$$$$  |
        $$ |__$$ |$$ |__$$ |   $$ |   $$ |__$$ |$$ \__$$/ 
        $$    $$/ $$    $$ |   $$ |   $$    $$ |$$      \ 
        $$$$$$$/  $$$$$$$$ |   $$ |   $$$$$$$$ | $$$$$$  |
        $$ |      $$ |  $$ |   $$ |   $$ |  $$ |/  \__$$ |
        $$ |      $$ |  $$ |   $$ |   $$ |  $$ |$$    $$/ 
        $$/       $$/   $$/    $$/    $$/   $$/  $$$$$$/  
--]]
Config.ASSETS_PATH = "assets/"
Config.ASSETS_SPRITES_PATH = Config.ASSETS_PATH .. "sprites/"
Config.ASSETS_SPRITES_CHARACTERS_PATH = Config.ASSETS_SPRITES_PATH .. "Characters/"
Config.ASSETS_SPRITES_ITEMS_PATH = Config.ASSETS_SPRITES_PATH .. "Items/"
Config.ASSETS_SPRITES_BACKGROUND_PATH = Config.ASSETS_SPRITES_PATH .. "Background/"

Config.SOUNDS_PATH = Config.ASSETS_PATH .. "sounds/"
Config.FONTS_PATH = Config.ASSETS_PATH .. "fonts/"

Config.LOGS_PATH = "logs/"

Config.MODULES_PATH = "modules/"

Config.PATHS = {
    logs = {
        info    = Config.LOGS_PATH .. "info.log",
        error   = Config.LOGS_PATH .. "error.log",
        debug   = Config.LOGS_PATH .. "debug.log",
    },
    modules = {
        entities = Config.MODULES_PATH .. "entities/",
        utils    = Config.MODULES_PATH .. "utils/",
    },
    assets = {
        fonts   = {
            default = Config.FONTS_PATH .. "default.ttf",
            title   = Config.FONTS_PATH .. "title_font.ttf",
        },
        sounds  = {
            music = Config.ASSETS_PATH .. "music/game_music.mp3",
            shoot = Config.ASSETS_PATH .. "sounds/shoot.wav",
            zombieGroan = Config.ASSETS_PATH .. "sounds/zombie_groan.wav",
        },
        sprites = {
            player = {
                idle     = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Soldier_1/Idle.png",
                walk     = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Soldier_1/Walk.png",
                shot     = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Soldier_1/Shot_1.png",
                run      = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Soldier_1/Run.png",
                recharge = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Soldier_1/Recharge.png",
            },
            zombie = {
                walk    = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Zombie_1/Walk.png",
                attack  = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Zombie_1/Attack.png",
                dead    = Config.ASSETS_SPRITES_CHARACTERS_PATH .. "Zombie_1/Dead.png",
            },
            itemset = {
                ammoPack    = Config.ASSETS_SPRITES_ITEMS_PATH .. "AmmoPack.png",
                bullet      = Config.ASSETS_SPRITES_ITEMS_PATH .. "Bullet.png",
            },
            background = {
                sky         = Config.ASSETS_SPRITES_BACKGROUND_PATH .. "Sky.png",
                ground      = Config.ASSETS_SPRITES_BACKGROUND_PATH .. "Ground.png",
                front_view  = Config.ASSETS_SPRITES_BACKGROUND_PATH .. "Front.png",
                middle_view = Config.ASSETS_SPRITES_BACKGROUND_PATH .. "Middle.png",
                back_view   = Config.ASSETS_SPRITES_BACKGROUND_PATH .. "Back.png",
                street_atlas = Config.ASSETS_SPRITES_BACKGROUND_PATH .. "Street_Atlas.png",
            } 
        }
    }
}
--[[
         __       __  ______  __    __  _______    ______   __       __ 
        /  |  _  /  |/      |/  \  /  |/       \  /      \ /  |  _  /  |
        $$ | / \ $$ |$$$$$$/ $$  \ $$ |$$$$$$$  |/$$$$$$  |$$ | / \ $$ |
        $$ |/$  \$$ |  $$ |  $$$  \$$ |$$ |  $$ |$$ |  $$ |$$ |/$  \$$ |
        $$ /$$$  $$ |  $$ |  $$$$  $$ |$$ |  $$ |$$ |  $$ |$$ /$$$  $$ |
        $$ $$/$$ $$ |  $$ |  $$ $$ $$ |$$ |  $$ |$$ |  $$ |$$ $$/$$ $$ |
        $$$$/  $$$$ | _$$ |_ $$ |$$$$ |$$ |__$$ |$$ \__$$ |$$$$/  $$$$ |
        $$$/    $$$ |/ $$   |$$ | $$$ |$$    $$/ $$    $$/ $$$/    $$$ |
        $$/      $$/ $$$$$$/ $$/   $$/ $$$$$$$/   $$$$$$/  $$/      $$/ 
--]]
Config.WINDOW = {
    WINDOW_WIDTH = 800,
    WINDOW_HEIGHT = 600,
    WINDOW_TITLE = "Horrific Zombie Shooter",
    WINDOW_ICON = Config.ASSETS_PATH .. "icon.png",
    RESIZABLE = true,
    VSYNC = true,
    GRAPHICS = {
        FILTER = "nearest",
    },
}
--[[
          ______    ______   __       __  ________  _______   __         ______   __      __ 
         /      \  /      \ /  \     /  |/        |/       \ /  |       /      \ /  \    /  |
        /$$$$$$  |/$$$$$$  |$$  \   /$$ |$$$$$$$$/ $$$$$$$  |$$ |      /$$$$$$  |$$  \  /$$/ 
        $$ | _$$/ $$ |__$$ |$$$  \ /$$$ |$$ |__    $$ |__$$ |$$ |      $$ |__$$ | $$  \/$$/  
        $$ |/    |$$    $$ |$$$$  /$$$$ |$$    |   $$    $$/ $$ |      $$    $$ |  $$  $$/   
        $$ |$$$$ |$$$$$$$$ |$$ $$ $$/$$ |$$$$$/    $$$$$$$/  $$ |      $$$$$$$$ |   $$$$/    
        $$ \__$$ |$$ |  $$ |$$ |$$$/ $$ |$$ |_____ $$ |      $$ |_____ $$ |  $$ |    $$ |    
        $$    $$/ $$ |  $$ |$$ | $/  $$ |$$       |$$ |      $$       |$$ |  $$ |    $$ |    
         $$$$$$/  $$/   $$/ $$/      $$/ $$$$$$$$/ $$/       $$$$$$$$/ $$/   $$/     $$/     
--]]
Config.GAMEPLAY = {
    MAP = {
        -- Width of each procedural map chunk in pixels
        chunkWidth = 1024, 
        -- Number of quads in a chunk canvas
        chunkQuads = 1024 / 32, -- 32 pixels per quad resulting in 32 quads per chunk
        -- Visual height of the ground texture
        groundHeight = 64, 
        -- Y-coordinate of the top of the ground
        groundY = love.graphics.getHeight() - 64,
        -- How many chunks to generate at game start
        initialChunks = 3, 
        -- Chunks this far behind player are removed
        cullDistance = 1.5 * love.graphics.getWidth(), 
        -- Generate new chunk when player is this far from end
        spawnDistance = 0.5 * love.graphics.getWidth(),
        -- Basic types for now
        chunkTypes = {
            "street", 
            "building_zone"
        }, 
        -- Probability weights for chunk types
        chunkWeights = {
            building_zone = 0.3,
            street = 0.7,
            streetWeights = {
                streetLight = 0.25,
                streetFlat  = 0.25,
                streetUp    = 0.25,
                streetDown  = 0.25,
            },
        }, 
    },
    BUILDING = {
        defaultWidth = 256,
        defaultHeight = 256,
        barricadeHealthBoost = 100, -- Health gained per barricade level
        -- Add more building-specific properties
    },
    camera = {
        -- Speed in pixels per second
        speed = 100,
        defaultSize = {
            -- Width of the camera view
            width = love.graphics.getWidth(),  
            -- Height of the camera view
            height = love.graphics.getHeight(), 
        },
        -- Default position of the camera
        defaultPosition = {x = 0, y = 0},
    },
    player = {
        initialHealth = 100,
        initialScore = 0,
        -- Speed in pixels per second
        walkSpeed = 25,
        -- Speed in pixels per second
        runSpeed = 175,    
        -- Cooldown time in seconds between shots
        shootCooldown = 0.05,
        -- Width of the player's bounding box
        width = 64,  
        -- Height of the player's bouding box
        height = 64, 
        -- Default health for the player
        defaultHealth = 100,
        -- Default score for the player
        defaultScore = 0,   
        -- Default direction (1 for right, -1 for left)
        defaultDirection = 1, 
        -- Default position of the player
        defaultPosition = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() - 64},
        -- Default name of the player
        defaultName = "Hero",
        -- Maximum number of shots the player can shoot before recharging
        maxShots = 30, 
    },
    zombie = {
        initialHealth = 50,
        damage = 10,
        -- Speed in pixels per second
        speed = 20, 
        -- Cooldown time in seconds between attacks
        attackCooldown = 1.2,
        -- Width of the zombie sprite
        width = 64,  
        -- Height of the zombie sprite
        height = 64, 
        -- Default health for the zombie
        defaultHealth = 140,
        -- Default position of the zombie
        defaultPosition = {x = 0, y = love.graphics.getHeight() - 64},
        -- Default direction (1 for right, -1 for left)
        defaultDirection = 1,
        -- Default name of the zombie
        defaultName = "Zombie",
    },
    bullet = {
        -- Speed in pixels per second
        bulletSpeed = 300, 
        width = 10,
        height = 10,
        -- Damage dealt by each bullet
        damage = 20, 
    },
    -- Enemies per second
    enemySpawnRate = 2.5,
    -- Maximum number of enemies on screen at once
    maxEnemies = 10, 
    -- Points awarded for each enemy killed
    scorePerKill = 100, 
}
--[[
         __    __  ______ 
        /  |  /  |/      |
        $$ |  $$ |$$$$$$/ 
        $$ |  $$ |  $$ |  
        $$ |  $$ |  $$ |  
        $$ |  $$ |  $$ |  
        $$ \__$$ | _$$ |_ 
        $$    $$/ / $$   |
         $$$$$$/  $$$$$$/ 
--]]
Config.UI = {
    -- Empty table for UI configurations
}
--[[
         ______  __    __  _______   __    __  ________ 
        /      |/  \  /  |/       \ /  |  /  |/        |
        $$$$$$/ $$  \ $$ |$$$$$$$  |$$ |  $$ |$$$$$$$$/ 
          $$ |  $$$  \$$ |$$ |__$$ |$$ |  $$ |   $$ |   
          $$ |  $$$$  $$ |$$    $$/ $$ |  $$ |   $$ |   
          $$ |  $$ $$ $$ |$$$$$$$/  $$ |  $$ |   $$ |   
         _$$ |_ $$ |$$$$ |$$ |      $$ \__$$ |   $$ |   
        / $$   |$$ | $$$ |$$ |      $$    $$/    $$ |   
        $$$$$$/ $$/   $$/ $$/        $$$$$$/     $$/    
--]]
Config.INPUT = {
    -- Empty table for input configurations
}
--[[
         ________  ______  __        ________   ______  
        /        |/      |/  |      /        | /      \ 
        $$$$$$$$/ $$$$$$/ $$ |      $$$$$$$$/ /$$$$$$  |
        $$ |__      $$ |  $$ |      $$ |__    $$ \__$$/ 
        $$    |     $$ |  $$ |      $$    |   $$      \ 
        $$$$$/      $$ |  $$ |      $$$$$/     $$$$$$  |
        $$ |       _$$ |_ $$ |_____ $$ |_____ /  \__$$ |
        $$ |      / $$   |$$       |$$       |$$    $$/ 
        $$/       $$$$$$/ $$$$$$$$/ $$$$$$$$/  $$$$$$/  
--]]
Config.FILES = {
    writeDebugInfo = function(message)
        if Config.PATHS.logs.info then
            local file = io.open(Config.PATHS.logs.info, "a")
            if file then
                file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - INFO: " .. message .. "\n")
                file:close()
            end
        end
    end,
    writeDebugError = function(message)
        if Config.PATHS.logs.error then
            local file = io.open(Config.PATHS.logs.error, "a")
            if file then
                file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - ERROR: " .. message .. "\n")
                file:close()
            end
        end
    end,
    writeDebugDebug = function(message)
        if Config.PATHS.logs.debug then
            local file = io.open(Config.PATHS.logs.debug, "a")
            if file then
                file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - DEBUG: " .. message .. "\n")
                file:close()
            end
        end
    end
}
--[[
          ______   __    __  ______  __       __   ______   ________  ______   ______   __    __ 
         /      \ /  \  /  |/      |/  \     /  | /      \ /        |/      | /      \ /  \  /  |
        /$$$$$$  |$$  \ $$ |$$$$$$/ $$  \   /$$ |/$$$$$$  |$$$$$$$$/ $$$$$$/ /$$$$$$  |$$  \ $$ |
        $$ |__$$ |$$$  \$$ |  $$ |  $$$  \ /$$$ |$$ |__$$ |   $$ |     $$ |  $$ |  $$ |$$$  \$$ |
        $$    $$ |$$$$  $$ |  $$ |  $$$$  /$$$$ |$$    $$ |   $$ |     $$ |  $$ |  $$ |$$$$  $$ |
        $$$$$$$$ |$$ $$ $$ |  $$ |  $$ $$ $$/$$ |$$$$$$$$ |   $$ |     $$ |  $$ |  $$ |$$ $$ $$ |
        $$ |  $$ |$$ |$$$$ | _$$ |_ $$ |$$$/ $$ |$$ |  $$ |   $$ |    _$$ |_ $$ \__$$ |$$ |$$$$ |
        $$ |  $$ |$$ | $$$ |/ $$   |$$ | $/  $$ |$$ |  $$ |   $$ |   / $$   |$$    $$/ $$ | $$$ |
        $$/   $$/ $$/   $$/ $$$$$$/ $$/      $$/ $$/   $$/    $$/    $$$$$$/  $$$$$$/  $$/   $$/ 
--]]

local frameWidth  = 128
local frameHeight = 128

-- Soldier_1
local soldierIdleSpriteSheet         = love.graphics.newImage(Config.PATHS.assets.sprites.player.idle)
local soldierWalkSpriteSheet         = love.graphics.newImage(Config.PATHS.assets.sprites.player.walk)
local soldierShotSpriteSheet         = love.graphics.newImage(Config.PATHS.assets.sprites.player.shot)
local soldierRunSpriteSheet          = love.graphics.newImage(Config.PATHS.assets.sprites.player.run)
local soldierRechargeSpriteSheet     = love.graphics.newImage(Config.PATHS.assets.sprites.player.recharge)

local idleAnimationDuration         = 1.2
local walkAnimationDuration         = 0.6
local shotAnimationDuration         = 0.2
local runAnimationDuration          = 0.7
local rechargeAnimationDuration     = 3.5


local idleFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
    {5 * frameWidth, 0},
    {6 * frameWidth, 0},
}


local walkFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
    {5 * frameWidth, 0},
    {6 * frameWidth, 0},
}

local shotFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
}

local runFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
    {5 * frameWidth, 0},
    {6 * frameWidth, 0},
    {7 * frameWidth, 0},
}

local rechargeFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
    {5 * frameWidth, 0},
    {6 * frameWidth, 0},
    {7 * frameWidth, 0},
    {8 * frameWidth, 0},
    {9 * frameWidth, 0},
    {10 * frameWidth, 0},
    {11 * frameWidth, 0},
    {12 * frameWidth, 0},
}


-- Zombie_1
local zombieWalkSpriteSheet     = love.graphics.newImage(Config.PATHS.assets.sprites.zombie.walk)
local zombieAttackSpriteSheet   = love.graphics.newImage(Config.PATHS.assets.sprites.zombie.attack)
local zombieDeadSpriteSheet     = love.graphics.newImage(Config.PATHS.assets.sprites.zombie.dead)

local zombieWalkAnimationDuration   = 1.5
local zombieAttackAnimationDuration = 0.8
local zombieDeadAnimationDuration   = 1.2

local zombieWalkFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
    {5 * frameWidth, 0},
    {6 * frameWidth, 0},
    {7 * frameWidth, 0},
    {8 * frameWidth, 0},
    {9 * frameWidth, 0},
}

local zombieAttackFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
}

local zombieDeadFrames = {
    {0 * frameWidth, 0},
    {1 * frameWidth, 0},
    {2 * frameWidth, 0},
    {3 * frameWidth, 0},
    {4 * frameWidth, 0},
}

Config.ANIMATIONS = {
    -- Player animations
    playerAnimations = {
        shotAnimation   = {
            soldierShotSpriteSheet, 
            shotFrames, 
            shotAnimationDuration
        },
        walkAnimation   = {
            soldierWalkSpriteSheet , 
            walkFrames, 
            walkAnimationDuration
        },
        idleAnimation   = {
            soldierIdleSpriteSheet , 
            idleFrames, 
            idleAnimationDuration
        },
        runAnimation    = {
            soldierRunSpriteSheet , 
            runFrames, 
            runAnimationDuration
        },
        rechargeAnimation = {
            soldierRechargeSpriteSheet, 
            rechargeFrames, 
            rechargeAnimationDuration
        },
    },

    -- Zombie animations
    zombieAnimations = {
        walkAnimation   = {
            zombieWalkSpriteSheet,
            zombieWalkFrames,
            zombieWalkAnimationDuration
        },
        attackAnimation = {
            zombieAttackSpriteSheet,
            zombieAttackFrames,
            zombieAttackAnimationDuration
        },
        deadAnimation   = {
            zombieDeadSpriteSheet,
            zombieDeadFrames,
            zombieDeadAnimationDuration
        },
    },

    frameConfig = {
        frameWidth = frameWidth,
        frameHeight = frameHeight,
    },
}
--[[
          ______   _______   _______   ______  ________  ________   ______  
         /      \ /       \ /       \ /      |/        |/        | /      \ 
        /$$$$$$  |$$$$$$$  |$$$$$$$  |$$$$$$/ $$$$$$$$/ $$$$$$$$/ /$$$$$$  |
        $$ \__$$/ $$ |__$$ |$$ |__$$ |  $$ |     $$ |   $$ |__    $$ \__$$/ 
        $$      \ $$    $$/ $$    $$<   $$ |     $$ |   $$    |   $$      \ 
         $$$$$$  |$$$$$$$/  $$$$$$$  |  $$ |     $$ |   $$$$$/     $$$$$$  |
        /  \__$$ |$$ |      $$ |  $$ | _$$ |_    $$ |   $$ |_____ /  \__$$ |
        $$    $$/ $$ |      $$ |  $$ |/ $$   |   $$ |   $$       |$$    $$/ 
         $$$$$$/  $$/       $$/   $$/ $$$$$$/    $$/    $$$$$$$$/  $$$$$$/  
--]]

local spriteWidth_32 = 32
local spriteHeight_128 = 128

Config.SPRITES = {
    -- Item sprites
    itemset = {
        ammoPack    = love.graphics.newImage(Config.PATHS.assets.sprites.itemset.ammoPack),
        bullet      = love.graphics.newImage(Config.PATHS.assets.sprites.itemset.bullet),
    },

    map = {
        love.graphics.newImage(Config.PATHS.assets.sprites.background.sky),
        love.graphics.newImage(Config.PATHS.assets.sprites.background.back_view),
        love.graphics.newImage(Config.PATHS.assets.sprites.background.middle_view),
        love.graphics.newImage(Config.PATHS.assets.sprites.background.front_view),
        love.graphics.newImage(Config.PATHS.assets.sprites.background.ground),
    },

    street = {
        streetAtlas = love.graphics.newImage(Config.PATHS.assets.sprites.background.street_atlas),
        quads = 4,
        spriteWidth = spriteWidth_32,
        spriteHeight = spriteHeight_128,
    },

    buildings = {
        -- Placeholder for building sprites
        -- You can add specific building sprites here
        -- Example: building1 = love.graphics.newImage(Config.PATHS.assets.sprites.buildings.building1),
    },

    barricades = {
        -- Placeholder for barricade sprites
        -- You can add specific barricade sprites here
        -- Example: barricade1 = love.graphics.newImage(Config.PATHS.assets.sprites.barricades.barricade1),
    },


}



local rootDir = love.filesystem.getWorkingDirectory()

-- Add 'modules' directory to the search path
-- The '?' is a placeholder for the module name
package.path = package.path .. ";" .. rootDir .. "/modules/?.lua"
package.path = package.path .. ";" .. rootDir .. "/modules/?/init.lua" -- For directory modules
package.path = package.path .. ";" .. rootDir .. "/modules/?.lua"

-- You can add other paths too if you have deeply nested modules
-- Example: if you had 'modules/entities/player.lua'
-- package.path = package.path .. ";" .. rootDir .. "/modules/entities/?.lua"
-- Config.FILES.writeDebugInfo("Current package.path: " .. package.path)

return Config
   