--- @module "shodan.http.lua_http"

local http_handler = {}
http_handler.__index = http_handler

function http_handler.new(config)
    local self = setmetatable({}, http_handler)
    self.config = config
    self.timeout = config.timeout or 30
    self.user_agent = config.user_agent or "ShodanLua/1.0.0"
    return self
end

function http_handler:request(method, url, opts)
    opts = opts or {}
    local http_request = require("http.request")

    local headers = {
        [":method"]    = method:upper(),
        ["user-agent"] = self.user_agent,
        ["accept"]     = "application/json",
    }

    if opts.headers then
        for k, v in pairs(opts.headers) do
            headers[k:lower()] = v
        end
    end

    local req = http_request.new_from_uri(url)
    for k, v in pairs(headers) do
        req.headers:upsert(k, v)
    end

    if opts.body then
        req:set_body(opts.body)
        req.headers:upsert("content-type", opts.headers and opts.headers["Content-Type"] or "application/json")
    end

    local resp_headers, stream = req:go(self.timeout)
    if not resp_headers then
        return nil, tostring(stream), {}
    end

    local status_code = resp_headers:get(":status")
    local body = stream:get_body_as_string()
    local flat_headers = {}
    for k, v in resp_headers:each() do
        flat_headers[k] = v
    end

    return tonumber(status_code), body, flat_headers
end

function http_handler:get(url, opts)
    return self:request("GET", url, opts)
end

function http_handler:post(url, opts)
    return self:request("POST", url, opts)
end

function http_handler:put(url, opts)
    return self:request("PUT", url, opts)
end

function http_handler:delete(url, opts)
    return self:request("DELETE", url, opts)
end

return http_handler
