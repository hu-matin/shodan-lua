--- @module "shodan.api.account"

local Account = {}
Account.__index = Account

function Account.new(client)
    return setmetatable({ client = client }, Account)
end

-- getting the account profile
--- @return table 
function Account:profile()
    return self.client:get("/account/profile")
end

-- getting api usage info
--- @return table
function Account:info()
    return self.client:get("/api-info")
end

return Account
