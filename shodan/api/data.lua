--- @module "shodan.api.data"

local Data = {}
Data.__index = Data

function Data.new(client)
    return setmetatable({ client = client }, Data)
end

-- Retrieve a list of all available Shodan data products and datasets
--- @return table
function Data:list()
    return self.client:get("/shodan/data")
end

-- Show files in a specific dataset
--- @param dataset string
--- @return table
function Data:dataset(dataset)
    return self.client:get("/shodan/data/" .. dataset)
end

return Data
