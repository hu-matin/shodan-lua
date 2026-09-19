--- @module "shodan.api.alerts"

local Alerts = {}
Alerts.__index = Alerts

function Alerts.new(client)
    return setmetatable({ client = client }, Alerts)
end

-- Create a network alert
--- @param name string Alert name
--- @param filters table { ip = { "1.2.3.0/24", ... } }
--- @param opts table | nil { expires }
--- @return table { id, name, filters, ... }
function Alerts:create(name, filters, opts)
    opts = opts or {}
    local body = {
        name    = name,
        filters = filters,
    }
    if opts.expires then
        body.expires = opts.expires
    end
    return self.client:post("/shodan/alert", nil, body)
end

-- Get info about a specific alert
--- @param alert_id string
--- @return table
function Alerts:info(alert_id)
    return self.client:get("/shodan/alert/" .. alert_id .. "/info")
end

-- List all active alerts (or a specific one)
--- @param alert_id string|nil If nil, lists all
--- @return table
function Alerts:list(alert_id)
    if alert_id then
        return self.client:get("/shodan/alert/" .. alert_id .. "/info")
    end
    return self.client:get("/shodan/alert/info")
end

-- Delete an alert
--- @param alert_id string
--- @return table
function Alerts:delete(alert_id)
    return self.client:delete("/shodan/alert/" .. alert_id)
end

-- Add a notifier to an alert
--- @param alert_id string
--- @param notifier_id string
--- @return table
function Alerts:add_notifier(alert_id, notifier_id)
    return self.client:put("/shodan/alert/" .. alert_id .. "/notifier/" .. notifier_id)
end

-- Remove a notifier from an alert
--- @param alert_id string
--- @param notifier_id string
--- @return table
function Alerts:remove_notifier(alert_id, notifier_id)
    return self.client:delete("/shodan/alert/" .. alert_id .. "/notifier/" .. notifier_id)
end

-- Add a trigger to an alert
--- @param alert_id string
--- @param trigger string Trigger name (e.g., "malware", "open_database")
--- @return table
function Alerts:add_trigger(alert_id, trigger)
    return self.client:put("/shodan/alert/" .. alert_id .. "/trigger/" .. trigger)
end

-- Remove a trigger from an alert
function Alerts:remove_trigger(alert_id, trigger)
    return self.client:delete("/shodan/alert/" .. alert_id .. "/trigger/" .. trigger)
end

-- Ignore a service for a trigger
function Alerts:ignore_trigger(alert_id, trigger, service_id)
    return self.client:put(
        "/shodan/alert/" .. alert_id .. "/trigger/" .. trigger .. "/ignore/" .. service_id
    )
end

-- Un-ignore a service for a trigger
function Alerts:unignore_trigger(alert_id, trigger, service_id)
    return self.client:delete(
        "/shodan/alert/" .. alert_id .. "/trigger/" .. trigger .. "/ignore/" .. service_id
    )
end

return Alerts
