-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = { }

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop", "onContentUpdate", "onContentTick", "onSlowUpdate")
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Container Monitor started.")

    self:findContainers("ContainerSmallGroup", "ContainerMediumGroup", "ContainerLargeGroup", "ContainerXLGroup")
    self:attachToScreen()
    self:sendContainersToScreen()
    self:requestContainerContent()
    modula:addTimer("onContentTick", 30.0)
end

function Module:onStop()
    debugf("Container Monitor stopped.")
end

function Module:onContentUpdate()
    self:sendContainersToScreen()
end

function Module:onContentTick()
    self:requestContainerContent()
end

function Module:onScreenReply(reply)
end

function Module:onSlowUpdate()
    self:sendContainersToScreen()
end


-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function Module:attachToScreen()
    -- TODO: send initial container data as part of render script
    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end
end

function Module:findContainers(...)
    local containers = {}
    for i,class in ipairs({ ... }) do
        modula:withElements(class, function(element)
            table.insert(containers, element)
            debugf("Found container %s", element:name())
        end)
    end
    self.containers = containers
end

function Module:sendContainersToScreen()
    for i,container in ipairs(self.containers) do
        local element = container.element
        local content = element.getContent()
        local fullPercent = element.getItemsVolume() / element.getMaxVolume()
        if container.fullPercent ~= fullPercent then
            container.fullPercent = fullPercent
            self.screen:send({ name = container:name(), value = fullPercent })
        end
    end
end

function Module:requestContainerContent()
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

containers = containers or {}

if payload then
    local name = payload.name
    if name then
        containers[name] = payload
    end
    reply = { name = name, result = "ok" }
end

local toolkit = require('samedicorp.toolkit.toolkit')
local Layer = require('samedicorp.toolkit.layer')
local Chart = require('samedicorp.toolkit.chart')
local layer = Layer.new()

local rect = layer.rect:inset(10)
local chart = Chart.new(rect, containers, "Play")
layer:addWidget(chart)

layer:render()

rate = layer:scheduleRefresh()
]]

return Module