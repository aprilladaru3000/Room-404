inventory = {
    items = {},
    maxSize = 5,
    selected = 1
}

function inventory:initialize()
    self.items = {}
    self.selected = 1
end

function inventory:addItem(item)
    if #self.items < self.maxSize then
        table.insert(self.items, item)
        return true
    end
    return false
end

function inventory:removeItem(index)
    table.remove(self.items, index)
    if self.selected > #self.items then
        self.selected = math.max(1, #self.items)
    end
end

function inventory:selectNext()
    self.selected = math.min(#self.items, self.selected + 1)
end

function inventory:selectPrevious()
    self.selected = math.max(1, self.selected - 1)
end

function inventory:draw()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 100, 100, 600, 400)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("INVENTORY", 100, 120, 600, "center")
    
    if #self.items == 0 then
        love.graphics.printf("Empty", 100, 200, 600, "center")
    else
        for i, item in ipairs(self.items) do
            local x = 150 + (i-1) * 100
            if i == self.selected then
                love.graphics.setColor(1, 0.5, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(item.name, x - 40, 200, 80, "center")
        end
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ENTER to use selected item", 100, 350, 600, "center")
    love.graphics.printf("Press I to close inventory", 100, 380, 600, "center")
end