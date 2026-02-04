function love.load()
    grid = {}

    rows = nil
    cols = nil
    cellSize = 32
    mines = nil
    firstCellRevealed = false
    difficultyChosen = false
    directions = {
        {-1,-1}, {0,-1}, {1,-1},
        {-1, 0},         {1, 0},
        {-1, 1}, {0, 1}, {1, 1}
    }

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

function setValues()
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

    love.window.setMode(
        cols * cellSize,
        rows * cellSize
    )
end

function love.draw()
    if difficultyChosen == false then
        love.graphics.setColor(1.0, 0.74, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Choose difficulty", 200, 200)

        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", 50, 300, 100, 50)
        love.graphics.rectangle("fill", 200, 300, 100, 50)
        love.graphics.rectangle("fill", 350, 300, 100, 50)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Easy", 85, 315)
        love.graphics.print("Normal", 230, 315)
        love.graphics.print("Hard", 385, 315)
    end

    if difficultyChosen == true then
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
end

function love.mousepressed(mx, my, button)
    if difficultyChosen == false then
        if button == 1 then
            if mx >= 50 and mx <= 150 and my >=300 and my <= 350 then
                rows = 8
                cols = 8
                mines = 10
                difficultyChosen = true
                setValues()
                return
            elseif mx >= 200 and mx <= 300 and my >=300 and my <= 350 then
                rows = 16
                cols = 16
                mines = 40
                difficultyChosen = true
                setValues()
                return
            elseif mx >= 350 and mx <= 450 and my >=300 and my <= 350 then
                rows = 16
                cols = 30
                mines = 99
                difficultyChosen = true
                setValues()
                return
            end
        end
    end

    if difficultyChosen == true then
        local x = math.floor(mx / cellSize) + 1
        local y = math.floor(my / cellSize) + 1
    
        if not grid[y] or not grid[y][x] then return end
        local cell = grid[y][x]
    
        if button == 1 then
            if firstCellRevealed == false then
                cell.first = true
                firstCellRevealed = true
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
        love.window.setMode(
        16 * cellSize,
        16 * cellSize
    )
    end
end