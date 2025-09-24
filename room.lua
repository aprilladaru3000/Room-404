room = {
    width = 800,
    height = 600,
    doorLocked = true,
    walls = {},
    objects = {},
    items = {}
}

function room:initialize()
    self:setupWalls()
    self:setupObjects()
    self:setupItems()
end

function room:setupWalls()
    self.walls = {
        {x = 50, y = 50, width = 700, height = 20},    -- top
        {x = 50, y = 50, width = 20, height = 500},    -- left
        {x = 50, y = 530, width = 700, height = 20},   -- bottom
        {x = 730, y = 50, width = 20, height = 500},   -- right
    }
end

function room:setupObjects()
    self.objects = {
        {x = 200, y = 200, width = 50, height = 50, type = "bed", examined = false},
        {x = 500, y = 200, width = 30, height = 80, type = "lamp", examined = false},
        {x = 350, y = 400, width = 40, height = 40, type = "table", examined = false},
        {x = 600, y = 400, width = 100, height = 20, type = "door", examined = false}
    }
end

function room:setupItems()
    self.items = {
        {x = 365, y = 410, width = 10, height = 10, type = "key", name = "Rusty Key", description = "A small, rusty key. It might fit the door."},
        {x = 220, y = 220, width = 10, height = 10, type = "note", name = "Strange Note", description = "The writing is fading: 'The door only opens when you stop trying to leave.'"},
        {x = 510, y = 220, width = 10, height = 10, type = "bulb", name = "Light Bulb", description = "A flickering light bulb. It feels warm."}
    }
end

function room:draw()
    love.graphics.setColor(0.8, 0.8, 0.8)
    for _, obj in ipairs(self.objects) do
        love.graphics.rectangle("fill", obj.x, obj.y, obj.width, obj.height)
    end
    
    -- Draw room items
    for _, item in ipairs(self.items) do
        if item.type == "key" then
            love.graphics.setColor(0.7, 0.5, 0.2)
        elseif item.type == "note" then
            love.graphics.setColor(1, 1, 0.8)
        elseif item.type == "bulb" then
            love.graphics.setColor(1, 1, 0.5)
        end
        love.graphics.rectangle("fill", item.x, item.y, item.width, item.height)
    end
end

function room:reset(loopCount)
    -- Reset room objects examination status
    for _, obj in ipairs(self.objects) do
        obj.examined = false
    end
    
    -- Relock door (except after certain loops)
    if loopCount < 5 then
        self.doorLocked = true
    else
        self.doorLocked = false
    end
    
    -- Occasionally add new items in later loops
    if loopCount == 3 and #self.items < 3 then
        table.insert(self.items, {
            x = math.random(100, 700), y = math.random(100, 500),
            width = 10, height = 10, type = "mirror", 
            name = "Cracked Mirror", 
            description = "Your reflection looks tired. Very tired."
        })
    end
end