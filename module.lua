-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = { }

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop", "onContentUpdate", "onContentTick", "onSlowUpdate")
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
    self:updateContainers()
end

function Module:onContentTick()
    self:refreshContainers()
end

function Module:onScreenReply(reply)
end

function Module:onSlowUpdate()
    self:updateContainers()
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
        self.screen:send({ name = container:name(), full = fullPercent })
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

containers = containers or {}

if payload then
    local name = payload.name
    if name then
        containers[name] = payload
    end
    reply = { name = name, result = "ok" }
end

local render = require('samedicorp.modula.render')
local layer = render.Layer()
layer.rect = layer.rect:inset(10)

local count = 0
for _,_ in pairs(containers) do
    count = count + 1
end

local rect = layer.rect
local y = 0
local labelSize = rect.height / (5 * count)
local labelFont = render.Font("Play", labelSize)
local barHeight = (rect.height / (count)) - labelFont.size
local barWidth = rect.width

for name,container in pairs(containers) do
    local percent = math.floor(container.full * 100)
    layer:addBar(render.Rect(0, y, barWidth, barHeight), container.full)
    y = y + barHeight + labelFont.size
    layer:addLabel(render.Text(name, labelFont), 0, y - 4)
    layer:addLabel(render.Text(string.format("%d%%", percent), labelFont), rect.width - (barWidth / 2), y)
end

layer:render()

rate = layer:scheduleRefresh()
]]

return Module