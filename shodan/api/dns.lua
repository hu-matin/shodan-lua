--- @module "shodan.api.dns"

local Dns = {}
Dns.__index = Dns

function Dns.new(client)
    return setmetatable({ client = client }, Dns)
end

-- Resolve hostnames to ip addresses
--- @param hostnames table|string
--- @return table
function Dns:resolve(hostnames)
    if type(hostnames) == "string" then
        hostnames = { hostnames }
    end
    return self.client:get("/dns/resolve", {
        hostnames = table.concat(hostnames, ","),
    })
end

-- Reverse dns lookup (ip to hostname)
--- @param ips table | string
--- @return table 
function Dns:reverse(ips)
    if type(ips) == "string" then
        ips = { ips }
    end
    return self.client:get("/dns/reverse", {
        ips = table.concat(ips, ","),
    })
end

return Dns
