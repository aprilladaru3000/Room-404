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

function inventory:dropItem(index, room, px, py)
    if index < 1 or index > #self.items then return false end
    local item = table.remove(self.items, index)
    -- place the dropped item near the player
    item.x = px + math.random(-30, 30)
    item.y = py + math.random(-30, 30)
    item.width = item.width or 10
    item.height = item.height or 10
    table.insert(room.items, item)
    if self.selected > #self.items then
        self.selected = math.max(1, #self.items)
    end
    return true
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
    love.graphics.printf("Slots: " .. #self.items .. " / " .. self.maxSize, 120, 150, 560, "left")

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
            love.graphics.printf(tostring(i) .. ") " .. item.name, x - 40, 200, 80, "center")
        end

        -- Draw selected item description
        local selectedItem = self.items[self.selected]
        if selectedItem then
            love.graphics.setColor(1, 1, 1)
            local desc = selectedItem.description or "No description."
            love.graphics.printf(desc, 120, 260, 560, "left")
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ENTER to use selected item | D to drop", 100, 350, 600, "center")
    love.graphics.printf("Press I to close inventory | 1-5: quick use", 100, 380, 600, "center")
end