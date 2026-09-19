--- @module "shodan.api.host"

local Host = {}
Host.__index = Host

function Host.new(client)
    return setmetatable({ client = client }, Host)
end

-- Get all available information for an IP
--- @param ip string
--- @param opts table | nil
--- @return table Host
function Host:lookup(ip, opts)
    opts = opts or {}
    local params = {
        history = opts.history,
        minify  = opts.minify,
    }
    return self.client:get("/shodan/host/" .. ip, params)
end

-- Count results for a host search 
--- @param query string
--- @return table
function Host:count(query)
    return self.client:get("/shodan/host/search/count", { query = query })
end

return Host
