-- room.lua
-- This module manages the state, text, and visual changes of the room.

local Room = {}
Room.__index = Room

-- Constructor for a new Room object
function Room:new()
    local instance = setmetatable({}, Room)

    instance.loopCount = 0
    instance.currentText = "You wake up in Room 404."
    instance.subtleChanges = {
        "You feel like you've been here before...",
        "The door won't open.",
        "The light flickers.",
        "Something's different...",
        "You hear breathing, but you're alone.",
        "This isn't just a room anymore.",
        "You're part of the room.",
        "Room 404 is inside you now.",
    }

    return instance
end

function Room:update(dt)
    -- This function can be used for animations or time-based events later
end

function Room:draw()
    -- Slight background color change based on the loop count
    -- The color becomes more intense with each loop
    local r = 20 + self.loopCount * 5
    local g = 20 + self.loopCount * 3
    local b = 30 + self.loopCount * 4
    love.graphics.clear(r / 255, g / 255, b / 255)

    -- Draw the current room text and the prompt
    love.graphics.setColor(1, 1, 1) -- Set text color to white
    love.graphics.printf(self.currentText, 50, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth() - 100, "center")
    love.graphics.printf("[Press any key to leave]", 50, love.graphics.getHeight() - 80, love.graphics.getWidth() - 100, "center")
end

function Room:keypressed(key, scancode)
    self.loopCount = self.loopCount + 1

    -- Update the room's text based on how many times a key has been pressed
    if self.loopCount <= #self.subtleChanges then
        self.currentText = self.subtleChanges[self.loopCount]
    else
        -- The final state when all changes have been cycled through
        self.currentText = "404. Reality not found."
    end
end

return Room
