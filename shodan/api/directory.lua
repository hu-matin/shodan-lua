--- @module "shodan.api.directory"

local Directory = {}
Directory.__index = Directory

function Directory.new(client)
    return setmetatable({ client = client }, Directory)
end

-- List all ports shodan crawls
--- @return table
function Directory:ports()
    return self.client:get("/shodan/ports")
end

-- List all protocols available for on-demand scanning
--- @return table
function Directory:protocols()
    return self.client:get("/shodan/protocols")
end

-- List all services Shodan indexes
--- @return table
function Directory:services()
    return self.client:get("/shodan/services")
end

return Directory
