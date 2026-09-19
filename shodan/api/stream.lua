--- @module "shodan.api.stream"

--[[
Real streaming requires a persistent connection.
This returns a single batch for non-blocking use.
For true streaming, use shodan.stream.
]]

local Stream = {}
Stream.__index = Stream

function Stream.new(client)
    return setmetatable({ client = client }, Stream)
end

-- Stream all banners
--- @param opts table | nil { timeout, callback }
--- @return function Iterator
function Stream:banners(opts)
    opts = opts or {}
    local params = {}

    if opts.timeout then
        params.timeout = opts.timeout
    end

    return self.client:get_stream("/shodan/banners", params)
end

-- Stream banners for specific ports
--- @param ports table | number
--- @return table
function Stream:ports(ports)
    if type(ports) == "number" then
        ports = { ports }
    end
    return self.client:get_stream("/shodan/ports/" .. table.concat(ports, ","))
end

-- Stream banners for specific ASNs
--- @param asns table|number
--- @return table
function Stream:asn(asns)
    if type(asns) == "number" then
        asns = { asns }
    end
    return self.client:get_stream("/shodan/asn/" .. table.concat(asns, ","))
end

-- Stream banners for specific countries
--- @param countries table|string
--- @return table
function Stream:countries(countries)
    if type(countries) == "string" then
        countries = { countries }
    end
    return self.client:get_stream("/shodan/countries/" .. table.concat(countries, ","))
end

-- Stream banners matching a network alert
--- @param alert_id string|nil 
--- @return table
function Stream:alert(alert_id)
    if alert_id then
        return self.client:get_stream("/shodan/alert/" .. alert_id)
    end
    return self.client:get_stream("/shodan/alert")
end

-- Stream banners for a specific vulnerability
--- @param vuln string CVE ID (e.g., "CVE-2021-44228")
--- @return table
function Stream:vulns(vuln)
    return self.client:get_stream("/shodan/alert/" .. vuln)
end

return Stream
