--- @module "shodan.http.luasocket"

local luasocket = {}
luasocket.__index = luasocket

function luasocket.new(config)
    local self = setmetatable({}, luasocket)
    self.config = config
    self.timeout = config.timeout or 30
    self.user_agent = config.user_agent or "ShodanLua/1.0.0"
    self.verify_ssl = config.verify_ssl ~= false
    return self
end

-- Perform an HTTP request
--- @param method string GET, POST, PUT, DELETE)
--- @param url string
--- @param opts table|nil { headers, body, query }
--- @return number status_code
--- @return string response_body
--- @return table response_headers
function luasocket:request(method, url, opts)
    opts = opts or {}
    local http_mod = require("socket.http")
    local ltn12 = require("ltn12")
    local is_https = url:match("^https://")

    local request_body = opts.body
    local response_body = {}

    local req = {
        url     = url,
        method  = method:upper(),
        headers = {
            ["User-Agent"] = self.user_agent,
            ["Accept"]     = "application/json",
        },
        sink    = ltn12.sink.table(response_body),
        timeout = self.timeout,
    }

    -- merge custom headers
    if opts.headers then
        for k, v in pairs(opts.headers) do
            req.headers[k] = v
        end
    end

    -- handle body
    if request_body then
        req.source = ltn12.source.string(request_body)
        req.headers["Content-Length"] = tostring(#request_body)
        if not req.headers["Content-Type"] then
            req.headers["Content-Type"] = "application/json"
        end
    end

    local status_code, headers

    if is_https then
        local https_mod = require("ssl.https")
        if self.verify_ssl then
            req.verify = "peer"
        else
            req.verify = "none"
        end
        local res, code, resp_headers = https_mod.request(req)
        status_code = code
        headers = resp_headers or {}
    else
        local res, code, resp_headers = http_mod.request(req)
        status_code = code
        headers = resp_headers or {}
    end

    local body_str = table.concat(response_body)
    return status_code, body_str, headers
end

--- GET method
function luasocket:get(url, opts)
    return self:request("GET", url, opts)
end

--- POST method
function luasocket:post(url, opts)
    return self:request("POST", url, opts)
end

--- PUT method
function luasocket:put(url, opts)
    return self:request("PUT", url, opts)
end

--- DELETE method
function luasocket:delete(url, opts)
    return self:request("DELETE", url, opts)
end

return luasocket
