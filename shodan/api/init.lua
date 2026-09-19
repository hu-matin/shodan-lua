--- @module "shodan.api"

local api = {}

local modules = {
    "search", "host", "exploits", "dns", "tools",
    "scan", "alerts", "data", "org", "queries",
    "directory", "stream", "notifiers", "account", "on_demand",
}

--- @param client table
--- @return table
function api.load_all(client)
    local loaded = {}
    for _, name in ipairs(modules) do
        local mod = require("shodan.api." .. name)
        loaded[name] = mod.new(client)
    end
    return loaded
end

return api
