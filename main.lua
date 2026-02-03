function love.load()
    grid = {}
    rows = 16
    cols = 16
    cellSize = 32
    mines = 40
    begin = false
    directions = {
        {-1,-1}, {0,-1}, {1,-1},
        {-1, 0},         {1, 0},
        {-1, 1}, {0, 1}, {1, 1}
    }
    for y = 1, rows do
        grid[y] = {}
        for x = 1, cols do
            grid[y][x] = {
                mine = false,
                revealed = false,
                flagged = false,
                neighborMines = 0,
                first = false
            }
        end
    end

    sound = love.audio.newSource('sound_effects/explosion.mp3','static')
end

function createMines()
    local placed = 0
    while placed < mines do
        local x = love.math.random(1, cols)
        local y = love.math.random(1, rows)
        if not grid[y][x].mine and not grid[y][x].first then
            grid[y][x].mine = true
            placed = placed + 1
        end
    end

    for y = 1, rows do
        for x = 1, cols do
            if not grid[y][x].mine then
                local count = 0
                for _, d in ipairs(directions) do
                    local nx, ny = x + d[1], y + d[2]
                    if grid[ny] and grid[ny][nx] and grid[ny][nx].mine then
                        count = count + 1
                    end
                end
                grid[y][x].neighborMines = count
            end
        end
    end
end

function love.draw()
     for y = 1, rows do
        for x = 1, cols do
        local cell = grid[y][x]
        local px = (x-1) * cellSize
        local py = (y-1) * cellSize

        if cell.revealed then
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.rectangle("fill", px, py, cellSize, cellSize)

            if cell.mine then
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("fill", px + 16, py + 16, 8)
            elseif cell.neighborMines > 0 then
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(cell.neighborMines, px + 12, py + 8)
            end
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.rectangle("fill", px, py, cellSize, cellSize)

            if cell.flagged then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("F", px + 12, py + 8)
            end
        end

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line", px, py, cellSize, cellSize)
        end
    end
end

function love.mousepressed(mx, my, button)
    local x = math.floor(mx / cellSize) + 1
    local y = math.floor(my / cellSize) + 1

    if not grid[y] or not grid[y][x] then return end
    local cell = grid[y][x]

    if button == 1 then
        if begin == false then
            cell.first = true
            begin = true
            createMines()
        end
        if cell.mine then
            sound:play()
            revealAll()
        end
        revealCell(x, y)
    elseif button == 2 then
        cell.flagged = not cell.flagged
    end
end

function revealAll()
    for y = 1, rows do
        for x = 1, cols do
            grid[y][x].revealed = true
        end 
    end
end

function revealCell(x, y)
    local cell = grid[y][x]
    if cell.revealed or cell.flagged then return end
    cell.revealed = true

    if cell.neighborMines == 0 and not cell.mine then
    for _, d in ipairs(directions) do
      local nx, ny = x + d[1], y + d[2]
      if grid[ny] and grid[ny][nx] then
        revealCell(nx, ny)
      end
    end
  end
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.load()
    end
end