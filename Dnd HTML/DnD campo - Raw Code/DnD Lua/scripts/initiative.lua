-- initiative.lua
local initiative = {}
local entities = {}
local currentEntityIndex = 1
local mapCodeInput = ""  -- For storing pasted map code
local parsedMapLayout = {}  -- Holds the parsed map layout
local mapWidth, mapHeight = 0, 0  -- Dimensions for the map
local settingInitiative = true  -- Tracks whether we're in initiative-setting mode

-- Load images for environment objects
local environmentImages = {
    tree = love.graphics.newImage("assets/imgs/environment/tree.png"),
    chest = love.graphics.newImage("assets/imgs/environment/chest.png")
}

function initiative.load(entityList)
    entities = entityList
    currentEntityIndex = 1
    settingInitiative = true
    mapCodeInput = ""  -- Reset map code input each time
end

function initiative.draw()
    love.graphics.clear()
    love.graphics.printf("Set Initiative", 0, 50, love.graphics.getWidth(), "center")
    
    if settingInitiative then
        -- Display entities for initiative setting
        for i, entity in ipairs(entities) do
            local selected = (i == currentEntityIndex) and ">" or " "
            love.graphics.printf(selected .. entity.name .. ": " .. (entity.initiative or 0), 100, 150 + (i * 40), love.graphics.getWidth(), "left")
        end
        love.graphics.printf("Press Enter to finish and paste map code", 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
    else
        -- Display input field for map code
        love.graphics.printf("Paste Map Code Below:", 100, 200, love.graphics.getWidth(), "left")
        love.graphics.rectangle("line", 100, 240, love.graphics.getWidth() - 200, 100)
        love.graphics.printf(mapCodeInput, 110, 250, love.graphics.getWidth() - 220, "left")
        love.graphics.printf("Press F5 to paste clipboard content", 0, 400, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Enter to Generate Map", 0, 450, love.graphics.getWidth(), "center")
    end
end

function love.textinput(t)
    if not settingInitiative then
        mapCodeInput = mapCodeInput .. t
    end
end

function initiative.keypressed(key)
    if settingInitiative then
        -- Adjust initiative or cycle through entities
        if key == "up" then
            currentEntityIndex = math.max(1, currentEntityIndex - 1)
        elseif key == "down" then
            currentEntityIndex = math.min(#entities, currentEntityIndex + 1)
        elseif key == "right" then
            entities[currentEntityIndex].initiative = (entities[currentEntityIndex].initiative or 0) + 1
        elseif key == "left" then
            entities[currentEntityIndex].initiative = math.max((entities[currentEntityIndex].initiative or 0) - 1, 0)
        elseif key == "return" then
            -- Sort by initiative and finish setting phase
            table.sort(entities, function(a, b) return a.initiative > b.initiative end)
            settingInitiative = false
        end
    else
        -- Paste from clipboard with F5
        if key == "f5" then
            mapCodeInput = mapCodeInput .. love.system.getClipboardText()
        end
        -- Generate map layout from pasted code
        if key == "return" and mapCodeInput ~= "" then
            parsedMapLayout = parseMapCode(mapCodeInput)
            gameState = "map"
        end
    end
end

-- Parse map code into a 2D layout and calculate dimensions
function parseMapCode(code)
    local layout = {}
    for line in code:gmatch("%b()") do
        local row = {}
        for item in line:gmatch("([^,]+)") do
            item = item:match("^%s*(.-)%s*$")  -- Trim whitespace
            table.insert(row, item)
        end
        table.insert(layout, row)
    end
    -- Set dimensions based on layout
    mapHeight = #layout
    mapWidth = #layout[1] or 0
    return layout
end

-- Access function for parsed map layout and dimensions
function initiative.getParsedMapLayout()
    return parsedMapLayout, mapWidth, mapHeight
end

function initiative.getEntities()
    return entities
end

return initiative
