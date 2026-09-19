--- @module "shodan.api.tools"

local Tools = {}
Tools.__index = Tools

function Tools.new(client)
    return setmetatable({ client = client }, Tools)
end

--Get your current public IP address
--- @return string IP
function Tools:myip()
    local result = self.client:get("/tools/myip")
    if result._raw then
        return result._raw:match("^%s*(.-)%s*$")
    end
    return tostring(result)
end


--- @return table HTTP
function Tools:httpheaders()
    return self.client:get("/tools/httpheaders")
end

return Tools
