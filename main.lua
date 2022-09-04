-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- If setting up manually, add the following handler to any connected screens:
--     local failure = modula:call("onScreenReply", output)
--     if failure then 
--         error(failure) 
--     end

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
        local volume = element.getItemsVolume()
        local max = element.getMaxVolume()
        if max > 0 then
            debugf("%s %s %s", container:name(), volume, max)
            local fullPercent = volume / max 
            if container.fullPercent ~= fullPercent then
                container.fullPercent = fullPercent
                self.screen:send({ name = container:name(), value = fullPercent })
            end
        else
            debug("Max is zero for %s %s -- is it a container?", container:name(), element.getClass())
            for k,v in pairs(element) do
                print("%s", k)
            end
        end
    end
end

function Module:requestContainerContent()
    for i,container in ipairs(self.containers) do
        local element = container.element
        element.updateContent()
    end
end



Module.renderScript = [[

containers = containers or {}

if payload then
    local name = payload.name
    if name then
        containers[name] = payload
    end
    reply = { name = name, result = "ok" }
end

local screen = toolkit.Screen.new()
local layer = screen:addLayer()
local chart = layer:addChart(layer.rect:inset(10), containers, "Play")

layer:render()
screen:scheduleRefresh()
]]

return Module