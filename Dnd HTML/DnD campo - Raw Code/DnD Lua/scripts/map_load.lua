local mapLoad = {}
local maps = {
    {
        name = "Basic Grid",
        layout = { "000000", "0A0B00", "00C000", "0000D0", "000000" },
        entities = {}
    },
    {
        name = "Dungeon Maze",
        layout = { "111110", "1A0B10", "101C10", "101D10", "111111", "101D10", "111111", },
        entities = {}
    }
}

local tileImages = {
    A = love.graphics.newImage("assets/imgs/tiles/a.png"),
    B = love.graphics.newImage("assets/imgs/tiles/b.png"),
    C = love.graphics.newImage("assets/imgs/tiles/c.png"),
    D = love.graphics.newImage("assets/imgs/tiles/d.png")
}

function mapLoad.load()
    print("Map loader initialized")
end

function mapLoad.getAvailableMaps()
    return maps
end

function mapLoad.drawMap(entities)
    local cellSize = 64
    local layout = maps[selectedMapIndex].layout

    for i, row in ipairs(layout) do
        for j = 1, #row do
            local tile = row:sub(j, j)
            if tile == "1" then
                love.graphics.setColor(0.6, 0.6, 0.6)
                love.graphics.rectangle("fill", (j - 1) * cellSize, (i - 1) * cellSize, cellSize, cellSize)
            elseif tile == "0" then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (j - 1) * cellSize, (i - 1) * cellSize, cellSize, cellSize)
            elseif tileImages[tile] then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(tileImages[tile], (j - 1) * cellSize, (i - 1) * cellSize, 0, cellSize / tileImages[tile]:getWidth(), cellSize / tileImages[tile]:getHeight())
            end
        end
    end

    for _, entity in ipairs(entities) do
        love.graphics.draw(entity.img, entity.x, entity.y)
    end
end

function mapLoad.positionEntities(entities)
    local layout = maps[selectedMapIndex].layout
    for _, entity in ipairs(entities) do
        local emptyCells = {}
        for i, row in ipairs(layout) do
            for j = 1, #row do
                if row:sub(j, j) == "0" then
                    table.insert(emptyCells, {x = (j - 1) * 64, y = (i - 1) * 64})
                end
            end
        end

        if #emptyCells > 0 then
            local pos = emptyCells[math.random(#emptyCells)]
            entity.x = pos.x
            entity.y = pos.y
        end
    end
end

return mapLoad
