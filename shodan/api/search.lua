--- @module "shodan.api.search"

local Search = {}
Search.__index = Search

function Search.new(client)
    return setmetatable({ client = client }, Search)
end

-- Search with shodan dorks
--- @param query string
--- @param opts table|nil { page, facets, minify }
--- @return table
function Search:search(query, opts)
    opts = opts or {}
    local params = {
        query  = query,
        page   = opts.page or 1,
        minify = opts.minify,
    }
    if opts.facets then
        if type(opts.facets) == "table" then
            params.facets = table.concat(opts.facets, ",")
        else
            params.facets = opts.facets
        end
    end
    return self.client:get("/shodan/host/search", params)
end

--- @param query string
--- @param opts table|nil { facets }
--- @return table
function Search:count(query, opts)
    opts = opts or {}
    local params = { query = query }
    if opts.facets then
        if type(opts.facets) == "table" then
            params.facets = table.concat(opts.facets, ",")
        else
            params.facets = opts.facets
        end
    end
    return self.client:get("/shodan/host/count", params)
end

-- Parse a search query into tokens
--- @param query string
--- @return table
function Search:tokens(query)
    return self.client:get("/shodan/host/search/tokens", { query = query })
end

-- Iterator for paginated search results
--- @param query string
--- @param opts table|nil { minify, max_pages }
--- @return function Iterator 
function Search:cursor(query, opts)
    opts = opts or {}
    local page = 1
    local max_pages = opts.max_pages or math.huge
    local matches = {}
    local idx = 0

    return function()
        while true do
            idx = idx + 1
            if idx <= #matches then
                return matches[idx]
            end
            if page > max_pages then
                return nil
            end
            local result = self:search(query, {
                page   = page,
                minify = opts.minify,
            })
            matches = result.matches or {}
            idx = 1
            page = page + 1
            if #matches == 0 then
                return nil
            end
            return matches[idx]
        end
    end
end

return Search
