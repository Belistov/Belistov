local menu = {}
local initiative = require("scripts.initiative")

local selectedPlayers = {}
local numEnemies = 0

local players = {
    { name = "gummi", img = love.graphics.newImage("assets/imgs/players/gummi.png"), selected = false },
    { name = "darri", img = love.graphics.newImage("assets/imgs/players/darri.png"), selected = false },
    { name = "magga", img = love.graphics.newImage("assets/imgs/players/magga.png"), selected = false },
    { name = "nonni", img = love.graphics.newImage("assets/imgs/players/nonni.png"), selected = false },
    { name = "addi", img = love.graphics.newImage("assets/imgs/players/addi.png"), selected = false },
    { name = "thorry", img = love.graphics.newImage("assets/imgs/players/thorry.png"), selected = false }
}

function menu.draw()
    -- Title
    love.graphics.printf("DND Retro Battle Map", love.graphics.getWidth() / 2 - 100, 50, 200, "center")

    -- Player Selection on the Left
    love.graphics.printf("Select Players:", 100, 100, 200, "left")
    for i, player in ipairs(players) do
        local yPos = 200 + (i - 1) * 50
        love.graphics.printf((player.selected and "[X] " or "[ ] ") .. player.name, 100, yPos, 200, "left")
    end

    -- Enemy Selection on the Right
    local enemyXPos = love.graphics.getWidth() - 300
    love.graphics.printf("Number of Enemies:", enemyXPos, 150, 200, "right")
    love.graphics.printf("< " .. numEnemies .. " >", enemyXPos, 220, 200, "center")
    love.graphics.printf("Use UP/DOWN to change", enemyXPos, 250, 200, "center")

    -- Instruction for Starting
    love.graphics.printf("Press Enter to Start Initiative", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() - 100, 200, "center")
end

function menu.keypressed(key)
    if key == "up" then
        numEnemies = numEnemies + 1
    elseif key == "down" then
        numEnemies = math.max(numEnemies - 1, 0)
    elseif key == "return" then
        -- Load selected players and enemies into initiative
        local entities = menu.getPlayerObjects(selectedPlayers)
        for i = 1, numEnemies do
            local enemy = { name = "Enemy " .. i, img = love.graphics.newImage("assets/imgs/enemies/enemy1.png"), initiative = 0, type = "enemy" }
            table.insert(entities, enemy)
        end
        initiative.load(entities)
        gameState = "initiative"
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        -- Check for player selection on the left
        for i, player in ipairs(players) do
            local yPos = 200 + (i - 1) * 50
            if x > 100 and x < 300 and y > yPos and y < yPos + 40 then
                player.selected = not player.selected
                if player.selected then
                    table.insert(selectedPlayers, player.name)
                else
                    for j = #selectedPlayers, 1, -1 do
                        if selectedPlayers[j] == player.name then
                            table.remove(selectedPlayers, j)
                        end
                    end
                end
            end
        end
    end
end

function menu.getPlayerObjects(selectedPlayerNames)
    local selectedObjects = {}
    for _, playerName in ipairs(selectedPlayerNames) do
        for _, player in ipairs(players) do
            if player.name == playerName then
                table.insert(selectedObjects, { name = player.name, img = player.img, x = 0, y = 0 })
            end
        end
    end
    return selectedObjects
end

return menu
