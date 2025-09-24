require("player")
require("room")
require("inventory")

local loopCount = 0
local roomText = "You wake up in Room 404."
local subtleChanges = {
    "You feel like you've been here before...",
    "The door won't open.",
    "The light flickers.",
    "Something's different...",
    "You hear breathing, but you're alone.",
    "This isn't just a room anymore.",
    "You're part of the room.",
    "Room 404 is inside you now.",
}

-- Game states
local gameState = "exploring" -- exploring, examining, inventory
local examineObject = nil
local message = ""
local messageTimer = 0

function love.load()
    love.window.setTitle("Room 404")
    love.window.setMode(room.width, room.height)
    love.graphics.setFont(love.graphics.newFont(18))
    
    player:initialize()
    room:initialize()
    inventory:initialize()
end

function love.update(dt)
    -- Update message timer
    if messageTimer > 0 then
        messageTimer = messageTimer - dt
        if messageTimer <= 0 then
            message = ""
        end
    end
    
    if gameState == "exploring" then
        player:update(dt, room)
        checkItemProximity()
    end
end

function love.draw()
    -- Background color based on loop count and sanity
    local r = 20 + loopCount * 5 + (100 - player.sanity) * 0.5
    local g = 20 + loopCount * 3
    local b = 30 + loopCount * 4 + (100 - player.sanity) * 0.3
    love.graphics.clear(r/255, g/255, b/255)
    
    room:draw()
    player:draw()
    drawUI()
    
    -- Game state specific draws
    if gameState == "inventory" then
        inventory:draw()
    elseif gameState == "examining" and examineObject then
        drawExamineScreen()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if gameState == "exploring" then
        handleExploringInput(key)
    elseif gameState == "inventory" then
        handleInventoryInput(key)
    elseif gameState == "examining" then
        handleExaminingInput(key)
    end
end

function checkItemProximity()
    for i, item in ipairs(room.items) do
        if checkCollision(player.x, player.y, player.size, player.size, 
                         item.x - 20, item.y - 20, item.width + 40, item.height + 40) then
            message = "Press E to pick up " .. item.name
            messageTimer = 2
            return
        end
    end
end

function drawUI()
    love.graphics.setColor(1, 1, 1)
    
    -- Room text
    love.graphics.printf(roomText, 50, 20, love.graphics.getWidth() - 100, "center")
    
    -- Sanity meter
    love.graphics.printf("Sanity: " .. math.floor(player.sanity), 20, 20, 200, "left")
    love.graphics.rectangle("line", 20, 45, 200, 20)
    love.graphics.rectangle("fill", 20, 45, player.sanity * 2, 20)
    
    -- Loop counter
    love.graphics.printf("Loop: " .. loopCount, love.graphics.getWidth() - 120, 20, 100, "right")
    
    -- Controls
    love.graphics.printf("WASD: Move | E: Interact | I: Inventory | SPACE: Examine", 
                        50, love.graphics.getHeight() - 60, love.graphics.getWidth() - 100, "center")
    
    -- Message display
    if message ~= "" then
        love.graphics.printf(message, 50, love.graphics.getHeight() - 100, love.graphics.getWidth() - 100, "center")
    end
end

function drawExamineScreen()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 100, 100, 600, 400)
    love.graphics.setColor(1, 1, 1)
    
    if examineObject.type == "door" then
        if room.doorLocked then
            love.graphics.printf("A solid metal door. It's locked tight.\n\nThere's a small keyhole.", 120, 200, 560, "center")
        else
            love.graphics.printf("The door is unlocked. It leads... somewhere else.\n\nOr does it lead back here?", 120, 200, 560, "center")
        end
    elseif examineObject.type == "bed" then
        love.graphics.printf("A simple bed. The sheets are rumpled.\n\nYou don't remember sleeping.", 120, 200, 560, "center")
    elseif examineObject.type == "lamp" then
        love.graphics.printf("A flickering lamp. The light seems to pulse\n\nin time with your heartbeat.", 120, 200, 560, "center")
    elseif examineObject.type == "table" then
        love.graphics.printf("A small wooden table. It's covered in dust\n\nexcept for one clean spot.", 120, 200, 560, "center")
    elseif examineObject.type == "note" then
        love.graphics.printf(examineObject.description .. "\n\n'The loops continue. Each time feels familiar,\n\nyet something changes. Stop trying to escape.'", 120, 180, 560, "center")
    end
    
    love.graphics.printf("Press SPACE to continue", 100, 350, 600, "center")
end

function handleExploringInput(key)
    if key == "e" then
        tryPickupItem()
    elseif key == "i" then
        gameState = "inventory"
    elseif key == "space" then
        tryExamineObject()
    end
end

function handleInventoryInput(key)
    if key == "i" or key == "escape" then
        gameState = "exploring"
    elseif key == "left" then
        inventory:selectPrevious()
    elseif key == "right" then
        inventory:selectNext()
    elseif key == "return" and #inventory.items > 0 then
        useItem(inventory.items[inventory.selected])
    end
end

function handleExaminingInput(key)
    if key == "space" or key == "escape" then
        gameState = "exploring"
        examineObject = nil
    end
end

function tryPickupItem()
    for i, item in ipairs(room.items) do
        if checkCollision(player.x, player.y, player.size, player.size, 
                         item.x - 10, item.y - 10, item.width + 20, item.height + 20) then
            if inventory:addItem(item) then
                table.remove(room.items, i)
                message = "Picked up: " .. item.name
                messageTimer = 2
                return
            else
                message = "Inventory full!"
                messageTimer = 2
                return
            end
        end
    end
    message = "Nothing to pick up here"
    messageTimer = 2
end

function tryExamineObject()
    -- Check room objects
    for _, obj in ipairs(room.objects) do
        if checkCollision(player.x, player.y, player.size, player.size, 
                         obj.x - 20, obj.y - 20, obj.width + 40, obj.height + 40) then
            examineObject = obj
            gameState = "examining"
            obj.examined = true
            
            -- Special door handling
            if obj.type == "door" then
                handleDoorExamination()
            end
            return
        end
    end
    
    message = "Nothing to examine here"
    messageTimer = 2
end

function handleDoorExamination()
    -- Try to use key on door
    for i, item in ipairs(inventory.items) do
        if item.type == "key" then
            room.doorLocked = false
            message = "The key fits! The door is unlocked."
            messageTimer = 3
            inventory:removeItem(i)
            break
        end
    end
    
    if not room.doorLocked then
        -- Advance loop when door is unlocked and examined
        loopCount = loopCount + 1
        if loopCount <= #subtleChanges then
            roomText = subtleChanges[loopCount]
        else
            roomText = "404. Reality not found."
        end
        
        -- Reset room but keep inventory
        room:reset(loopCount)
        player:reset()
    end
end

function useItem(item)
    if item.type == "note" then
        examineObject = item
        gameState = "examining"
    elseif item.type == "bulb" then
        message = "The bulb grows warmer in your hand..."
        messageTimer = 3
        player.sanity = math.min(player.maxSanity, player.sanity + 20)
    end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end