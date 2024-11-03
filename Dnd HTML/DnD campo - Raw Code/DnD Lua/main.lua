-- main.lua
local menu = require("scripts.menu")
local initiative = require("scripts.initiative")

gameState = "menu"  -- Global game state, starts in "menu"
local selectedMapLayout = nil  -- Holds the map layout to be drawn
local entities = {}  -- List of players and enemies
local selectedEntityIndex = 1  -- Tracks the currently selected entity
local mapWidth, mapHeight = 0, 0  -- Width and height of the loaded map

-- Load images for environment objects
local environmentImages = {
    tree = love.graphics.newImage("assets/imgs/environment/tree.png"),
    chest = love.graphics.newImage("assets/imgs/environment/chest.png")
}

function love.load()
    -- Set fullscreen mode
    love.window.setMode(0, 0, {fullscreen=true})
    
    -- Load and set the custom font
    local arcadeFont = love.graphics.newFont("assets/fonts/ARCADECLASSIC2.TTF", 32)
    love.graphics.setFont(arcadeFont)
end

function startMap()
    local layout, width, height = initiative.getParsedMapLayout()
    selectedMapLayout = layout
    mapWidth = width
    mapHeight = height
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "initiative" then
        initiative.draw()
    elseif gameState == "map" then
        drawMap(selectedMapLayout)  -- Draw the selected map layout
        drawEntities()  -- Draw entities on the map
    end
end

function love.update(dt)
    -- Any update logic can go here if needed
end

function love.keypressed(key)
    if gameState == "menu" then
        menu.keypressed(key)
    elseif gameState == "initiative" then
        initiative.keypressed(key)
        
        -- Transition to map after initiative setup
        if gameState == "map" then
            startMap()  -- Load map layout and dimensions
            entities = initiative.getEntities()  -- Retrieve entities after initiative setup
            positionEntitiesOnMap(entities, selectedMapLayout)  -- Place entities on the map
        end
    elseif gameState == "map" then
        handleMapKeyInput(key)  -- Handle entity selection and movement on the map
    end
end

function love.mousepressed(x, y, button)
    if gameState == "menu" then
        menu.mousepressed(x, y, button)
    end
end

-- Handle map key input for entity selection and movement
function handleMapKeyInput(key)
    if key == "t" then
        -- Cycle through entities
        selectedEntityIndex = (selectedEntityIndex % #entities) + 1
    elseif key == "up" then
        moveSelectedEntity(0, -1)
    elseif key == "down" then
        moveSelectedEntity(0, 1)
    elseif key == "left" then
        moveSelectedEntity(-1, 0)
    elseif key == "right" then
        moveSelectedEntity(1, 0)
    end
end

-- Move the selected entity by grid steps (no movement restrictions)
function moveSelectedEntity(dx, dy)
    local entity = entities[selectedEntityIndex]
    entity.row = entity.row + dy
    entity.col = entity.col + dx
end

-- Draws the map based on the layout and dimensions
function drawMap(mapLayout)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local cellSize = math.min(screenWidth / mapWidth, screenHeight / mapHeight)

    -- Calculate offsets to center the map precisely
    local offsetX = (screenWidth - (mapWidth * cellSize)) / 2
    local offsetY = (screenHeight - (mapHeight * cellSize)) / 2

    for row = 1, mapHeight do
        for col = 1, mapWidth do
            local tile = mapLayout[row][col]
            local x = offsetX + (col - 1) * cellSize
            local y = offsetY + (row - 1) * cellSize

            -- Set a background color for each tile type
            if tile == "tree" then
                love.graphics.setColor(0.5, 0.8, 0.5)  -- Light green for trees
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                love.graphics.setColor(1, 1, 1)  -- Reset color
                love.graphics.draw(environmentImages.tree, x, y, 0, cellSize / environmentImages.tree:getWidth(), cellSize / environmentImages.tree:getHeight())
            elseif tile == "chest" then
                love.graphics.setColor(0.7, 0.5, 0.3)  -- Brownish background for chests
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                love.graphics.setColor(1, 1, 1)  -- Reset color
                love.graphics.draw(environmentImages.chest, x, y, 0, cellSize / environmentImages.chest:getWidth(), cellSize / environmentImages.chest:getHeight())
            elseif tile == "0" then
                love.graphics.setColor(0.2, 0.2, 0.2) -- Dark color for empty space
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
            else
                love.graphics.setColor(0.7, 0.7, 0.7) -- Default color for other tiles
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
            end
            love.graphics.setColor(1, 1, 1)  -- Reset color for other draws
        end
    end
end


-- Draws all entities on the map
function drawEntities()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local cellSize = math.min(screenWidth / mapWidth, screenHeight / mapHeight)  -- Same cell size as map

    -- Draw each entity
    for i, entity in ipairs(entities) do
        local x = (entity.col * cellSize) + (screenWidth - (mapWidth * cellSize)) / 2
        local y = (entity.row * cellSize) + (screenHeight - (mapHeight * cellSize)) / 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(entity.img, x, y, 0, cellSize / entity.img:getWidth(), cellSize / entity.img:getHeight())

        -- Draw selection indicator for the currently selected entity
        if i == selectedEntityIndex then
            love.graphics.setColor(1, 1, 0)  -- Yellow color for selection
            love.graphics.rectangle("line", x - 5, y - 5, cellSize + 10, cellSize + 10, 4)
        end
    end
end

-- Positions entities on the map
function positionEntitiesOnMap(entityList, mapLayout)
    local entityIndex = 1
    for row = 1, mapHeight do
        for col = 1, mapWidth do
            if entityIndex > #entityList then break end
            if mapLayout[row][col] == "0" then  -- Place entities only on floor tiles
                entityList[entityIndex].row = row - 1
                entityList[entityIndex].col = col - 1
                entityIndex = entityIndex + 1
            end
        end
    end
end
