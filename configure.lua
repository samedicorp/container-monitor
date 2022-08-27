-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local useLocal = true --export: Use require() to load local scripts if present. Useful during development.
local logging = true --export: Enable controller debug output.

modulaSettings = { 
    name = "Container Monitor",
    version = "1.0",
    logging = logging, 
    useLocal = useLocal,
    modules = {
        ["samedicorp.container-monitor.module"] = { },
        ["samedicorp.modula.modules.screen"] = { }
    }
}


