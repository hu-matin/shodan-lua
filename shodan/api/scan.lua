--- @module "shodan.api.scan"

local Scan = {}
Scan.__index = Scan

function Scan.new(client)
    return setmetatable({ client = client }, Scan)
end

-- Request a network scan
--- @param ips table|string
--- @return table
function Scan:scan(ips)
    if type(ips) == "string" then
        ips = { ips }
    end
    return self.client:post("/shodan/scan", nil, {
        ips = table.concat(ips, ","),
    })
end

-- Check scan status
--- @param scan_id string
--- @return table
function Scan:status(scan_id)
    return self.client:get("/shodan/scan/" .. scan_id)
end

-- Request an Internet-wide scan on a specific port
--- @param port number
--- @param protocol string|nil
--- @return table
function Scan:internet(port, protocol)
    return self.client:post("/shodan/scan/internet", nil, {
        port     = port,
        protocol = protocol or "tcp",
    })
end

return Scan
