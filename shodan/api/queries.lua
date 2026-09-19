--- @module "shodan.api.queries"

local Queries = {}
Queries.__index = Queries

function Queries.new(client)
    return setmetatable({ client = client }, Queries)
end

-- List popular saved queries
--- @param opts table | nil
--- @return table
function Queries:list(opts)
    opts = opts or {}
    return self.client:get("/shodan/query", {
        page  = opts.page,
        sort  = opts.sort,
        order = opts.order,
    })
end

-- Search saved queries
--- @param query string
--- @param opts table|nil { page }
--- @return table
function Queries:search(query, opts)
    opts = opts or {}
    return self.client:get("/shodan/query/search", {
        query = query,
        page  = opts.page,
    })
end

-- List popular query tags
--- @param opts table|nil { size }
--- @return table
function Queries:tags(opts)
    opts = opts or {}
    return self.client:get("/shodan/query/tags", {
        size = opts.size,
    })
end

return Queries
