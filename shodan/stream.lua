--- @module "shodan.stream"

local utils = require("shodan.utils")
local errors = require("shodan.errors")

--- @class StreamClient
--- @field api_key string|nil
--- @field stream_url string
--- @field json_lib string
--- @field timeout number
local StreamClient = {}
StreamClient.__index = StreamClient

--- @param api_key string|nil
--- @param opts table|nil
--- @return StreamClient
function StreamClient.new(api_key, opts)
    opts = opts or {}
    local self = setmetatable({}, StreamClient)
    self.api_key = api_key or os.getenv("SHODAN_API_KEY")
    self.stream_url = opts.stream_url or "https://stream.shodan.io"
    self.json_lib = opts.json_library or "cjson"
    self.timeout = opts.timeout or 0  -- 0 = infinite
    return self
end

-- Connect to a stream endpoint and process banners via callback
--- @param path string Stream path (eg:"/shodan/banners")
--- @param callback function
--- @param opts table|nil { params, max_banners }
function StreamClient:connect(path, callback, opts)
    opts = opts or {}
    local params = opts.params or {}
    params.key = self.api_key

    local url = utils.build_url(self.stream_url, path, params)

    local ok_https, https = pcall(require, "ssl.https")
    local ok_socket, socket = pcall(require, "socket")
    local ok_ltn12, ltn12 = pcall(require, "ltn12")

    if not ok_https then
        error(errors.StreamError.new("ssl.https required for streaming"))
    end

    local response_body = {}
    local banner_count = 0
    local max_banners = opts.max_banners or math.huge

    -- use a custom sink that processes linee by line
    local sink = function(chunk, err)
        if chunk then
            response_body[#response_body + 1] = chunk

            local full = table.concat(response_body)
            local last_newline = full:find("\n[^\n]*$")

            if last_newline then
                local complete = full:sub(1, last_newline - 1)
                response_body = { full:sub(last_newline + 1) }
                for raw_line in utils.lines(complete) do
                    local line = raw_line:match("^%s*(.-)%s*$")
                    if line ~= "" then
                        local banner, parse_err = utils.json_decode(self.json_lib, line)
                        if banner then
                            callback(banner)
                            banner_count = banner_count + 1
                            if banner_count >= max_banners then
                                return nil, "max_banners reached"
                            end
                        end
                    end
                end
            end
        end
        return 1
    end

    local req = {
        url     = url,
        method  = "GET",
        headers = {
            ["User-Agent"] = "ShodanLua/1.3.1",
            ["Accept"] = "application/x-ndjson",
        },
        sink    = sink,
        timeout = self.timeout,
    }

    local res, code, headers = https.request(req)
    return banner_count, code
end

-- Stream all banners
function StreamClient:banners(callback, opts)
    return self:connect("/shodan/banners", callback, opts)
end

-- Stream banners for specific ports
function StreamClient:ports(ports, callback, opts)
    opts = opts or {}
    if type(ports) == "number" then ports = { ports } end
    return self:connect("/shodan/ports/" .. table.concat(ports, ","), callback, opts)
end

-- Stream banners for specific ASNs
function StreamClient:asn(asns, callback, opts)
    opts = opts or {}
    if type(asns) == "number" then asns = { asns } end
    return self:connect("/shodan/asn/" .. table.concat(asns, ","), callback, opts)
end

-- Stream banners matching an alert
function StreamClient:alert(alert_id, callback, opts)
    local path = alert_id
        and "/shodan/alert/" .. alert_id
        or "/shodan/alert"
    return self:connect(path, callback, opts)
end

return StreamClient
