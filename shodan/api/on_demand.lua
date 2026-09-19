--- @module "shodan.api.on_demand"

local OnDemand = {}
OnDemand.__index = OnDemand

function OnDemand.new(client)
    return setmetatable({ client = client }, OnDemand)
end

-- Request an on-demand scan for specific IPs and protocols
--- @param ips table | string
--- @param protocol string
--- @param port number
--- @return table
function OnDemand:scan(ips, protocol, port)
    if type(ips) == "string" then
        ips = { ips }
    end
    return self.client:post("/shodan/scan", nil, {
        ips      = table.concat(ips, ","),
        protocol = protocol,
        port     = port,
    })

end

return OnDemand
