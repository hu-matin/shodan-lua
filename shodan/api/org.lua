--- @module "shodan.api.org"

local Organization = {}
Organization.__index = Organization

function Organization.new(client)
    return setmetatable({ client = client }, Organization)
end

-- Get organization info
--- @return table
function Organization:info()
    return self.client:get("/org")
end

-- Add a member to the organization
--- @param user string Username or email
--- @param notify boolean|nil
--- @return table
function Organization:add_member(user, notify)
    return self.client:put("/org/member/" .. user, { notify = notify })
end

-- Remove a member from the organization
--- @param user string Username or email
--- @return table
function Organization:remove_member(user)
    return self.client:delete("/org/member/" .. user)
end

return Organization
