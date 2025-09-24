player = {
    x = 400,
    y = 300,
    size = 20,
    speed = 200,
    sanity = 100,
    maxSanity = 100
}

function player:initialize()
    self.x = 400
    self.y = 300
    self.sanity = self.maxSanity
end

function player:update(dt, room)
    local dx, dy = 0, 0
    
    if love.keyboard.isDown("w", "up") then
        dy = -1
    elseif love.keyboard.isDown("s", "down") then
        dy = 1
    end
    
    if love.keyboard.isDown("a", "left") then
        dx = -1
    elseif love.keyboard.isDown("d", "right") then
        dx = 1
    end
    
    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        dx, dy = dx * 0.707, dy * 0.707
    end
    
    -- Calculate new position
    local newX = self.x + dx * self.speed * dt
    local newY = self.y + dy * self.speed * dt
    
    -- Check collisions
    local canMoveX, canMoveY = true, true
    
    for _, wall in ipairs(room.walls) do
        if checkCollision(newX, self.y, self.size, self.size, wall.x, wall.y, wall.width, wall.height) then
            canMoveX = false
        end
        if checkCollision(self.x, newY, self.size, self.size, wall.x, wall.y, wall.width, wall.height) then
            canMoveY = false
        end
    end
    
    for _, obj in ipairs(room.objects) do
        if checkCollision(newX, self.y, self.size, self.size, obj.x, obj.y, obj.width, obj.height) then
            canMoveX = false
        end
        if checkCollision(self.x, newY, self.size, self.size, obj.x, obj.y, obj.width, obj.height) then
            canMoveY = false
        end
    end
    
    -- Apply movement
    if canMoveX then self.x = newX end
    if canMoveY then self.y = newY end
    
    -- Sanity drain over time
    self.sanity = math.max(0, self.sanity - 0.5 * dt)
end

function player:draw()
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.circle("fill", self.x, self.y, self.size)
end

function player:reset()
    self.x = 400
    self.y = 300
    self.sanity = self.maxSanity
end