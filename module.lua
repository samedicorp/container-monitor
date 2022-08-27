-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local json = require('dkjson')

local Module = { }

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop", "onContentUpdate", "onContentTick")
end

-- ---------------------------------------------------------------------
-- Example event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Container Monitor started.")

    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end

    self:registerContainers("ContainerSmallGroup", "ContainerMediumGroup", "ContainerLargeGroup", "ContainerXLGroup")
    self:updateContainers()
    self:refreshContainers()
    modula:addTimer("onContentTick", 30.0)
end

function Module:onStop()
    debugf("Container Monitor stopped.")
end

function Module:onContentUpdate()
    printf("content update")
    self:updateContainers()
end

function Module:onContentTick()
    self:refreshContainers()
end

function Module:onCommand(command, arguments)
    if command == "test" then
        printf("Hello from the test module")
    end
end

function Module:onScreenReply(reply)
    printf("reply: %s", reply)
end

-- ---------------------------------------------------------------------

function Module:registerContainers(...)
    local containers = {}
    for i,class in ipairs({ ... }) do
        modula:withElements(class, function(element)
            table.insert(containers, element)
            debugf("Found container %s", element:name())
        end)
    end
    self.containers = containers
end

function Module:updateContainers()
    for i,container in ipairs(self.containers) do
        local element = container.element
        local content = element.getContent()
        local fullPercent = element.getItemsVolume() / element.getMaxVolume()
        local encoded = json.encode({ name = container:name(), full = fullPercent })
        self.screen:send("full", encoded)
    end
end

function Module:refreshContainers()
    for i,container in ipairs(self.containers) do
        local element = container.element
        element.updateContent()
    end
end

-- updateContent
-- onContentUpdate
-- getMaxVolume
-- getItemsVolume
-- getItemsMass
-- getSelfMass


Module.renderScript = [[

local json = require('dkjson')

containers = containers or {}

if command == "full" then
    lastCommand = command
    params = json.decode(payload)
    local name = params.name
    if name then
        containers[name] = params.full
    end
    reply = "done"
end

local render = require('samedicorp.modula.render')
local layer = render.Layer()
local y = 20
for name,container in pairs(containers) do
    layer:addLabel(string.format("%s: %s", name, container), 10, y)
    y = y + 20
end

layer:render()

rate = layer:scheduleRefresh()
]]

return Module