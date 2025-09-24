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

function love.load()
    love.window.setTitle("Room 404")
    love.graphics.setFont(love.graphics.newFont(18))
end

function love.update(dt)
    -- Nothing dynamic here for now
end

function love.draw()
    -- Slight color change based on loop count
    local r = 20 + loopCount * 5
    local g = 20 + loopCount * 3
    local b = 30 + loopCount * 4
    love.graphics.clear(r/255, g/255, b/255)

    -- Draw room text
    love.graphics.printf(roomText, 50, love.graphics.getHeight()/2 - 20, love.graphics.getWidth() - 100, "center")
    love.graphics.printf("[Press any key to leave]", 50, love.graphics.getHeight() - 80, love.graphics.getWidth() - 100, "center")
end

function love.keypressed(key)
    loopCount = loopCount + 1

    -- Update roomText based on loopCount
    if loopCount <= #subtleChanges then
        roomText = subtleChanges[loopCount]
    else
        roomText = "404. Reality not found."
    end
end
