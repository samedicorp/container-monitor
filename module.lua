-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = { }

function Module:register(modula, parameters)
    modula:registerForEvents(self, "onStart", "onStop")
end

-- ---------------------------------------------------------------------
-- Example event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Container Monitor started.")

    local service = self.modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
            screen:send("test", "hello world")
        end
    end

end

function Module:onStop()
    printf("Container Monitor stopped.")
end

function Module:onCommand(command, arguments)
    if command == "test" then
        printf("Hello from the test module")
    end
end

function Module:onScreenReply(reply)
    printf("reply: %s", reply)
end

Module.renderScript = [[
if command then
    lastCommand = command
    lastPayload = payload
    reply = "done"
end

local render = require('samedicorp.modula.render')
local layer = render.Layer()
layer:addButton("test", render.Rect(100, 100, 60, 20), function()
    message = "test pressed"
end)
layer:addButton("other", render.Rect(100, 200, 60, 20), { 
    style = "lineStyle", 
    onMouseUp = function()
        message = "other pressed"
    end
})

startRect = startRect or render.Rect(100, 300, 60, 20)
layer:addButton("dragme", startRect, {
    onMouseDrag = function(pos, button)
        if not buttonOffset then
            buttonOffset = startRect:topLeft():minus(pos)
        else
            local newPos = pos:plus(buttonOffset)
            startRect.x = newPos.x
            startRect.y = newPos.y
        end
    end
})

layer:addLabel(string.format("screen: %s", name), 10, 20)
if lastCommand then
    layer:addLabel(string.format("command: %s", lastCommand), 10, 40)
    layer:addLabel(string.format("payload: %s", lastPayload), 10, 60)
    if rate then
        layer:addLabel(string.format("refresh: %s", rate), 10, 100)
    end
    if message then
        layer:addLabel(message, 10, 80)
    end
end
layer:render()

rate = layer:scheduleRefresh()
]]

return Module