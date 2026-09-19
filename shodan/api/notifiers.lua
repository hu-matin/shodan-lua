--- @module "shodan.api.notifiers"

local Notifiers = {}
Notifiers.__index = Notifiers

function Notifiers.new(client)
    return setmetatable({ client = client }, Notifiers)
end

-- List available notification providers
--- @return table
function Notifiers:providers()
    return self.client:get("/notifier/provider")
end

-- List all configured notifiers
--- @return table
function Notifiers:list()
    return self.client:get("/notifier")
end

-- Get info about a specific notifier
--- @param notifier_id string
--- @return table
function Notifiers:info(notifier_id)
    return self.client:get("/notifier/" .. notifier_id)
end


-- Create
--- @param provider string
--- @param description string
--- @param params table
--- @return table
function Notifiers:create(provider, description, params)
    local body = {
        provider    = provider,
        description = description,
        parameters  = params or {},
    }
    return self.client:post("/notifier", nil, body)
end

-- edit
--- @param notifier_id string
--- @param params table Updated parameters
--- @return table
function Notifiers:edit(notifier_id, params)
    return self.client:put("/notifier/" .. notifier_id, nil, params)
end

-- delete
--- @param notifier_id string
--- @return table
function Notifiers:delete(notifier_id)
    return self.client:delete("/notifier/" .. notifier_id)
end

return Notifiers
