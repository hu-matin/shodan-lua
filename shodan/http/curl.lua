--- @module "shodan.curl"

local curl = {}
curl.__index = curl

function curl.new(config)
    local self = setmetatable({}, curl)
    self.config = config
    return self
end

--- @param method "GET" | "POST" | "PUT" | "DELETE" | string
--- @param url string
--- @param opts table|nil
--- @return number status, string body, table|nil headers
function curl:request(method, url, opts)
    opts = opts or {}

    local cmd = 'curl -s -i -L -X ' .. method .. ' "' .. url .. '"'

    if opts.headers then
        for k, v in pairs(opts.headers) do
            cmd = cmd .. ' -H "' .. k .. ': ' .. v .. '"'
        end
    end

    if opts.body then
        local escaped_body = opts.body:gsub('"', '\\"')
        cmd = cmd .. ' -d "' .. escaped_body .. '"'
    end

    local handle = io.popen(cmd)
    if not handle then
        return 0, "Failed to execute curl command"
    end

    local result = handle:read("*a")
    handle:close()

    local header_str, body = result:match("(.-)\r?\n\r?\n(.*)")
    if not header_str then
        header_str = result
        body = ""
    end

    local status = tonumber(header_str:match("HTTP/%d%.%d (%d+)")) or 200

    local headers = {}
    for line in header_str:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^:]+):%s*(.+)$")
        if k then
            headers[k] = v
        end
    end

    return status, body, headers
end

return curl
