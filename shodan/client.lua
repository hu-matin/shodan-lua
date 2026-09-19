--- @module "shodan.client"

local config_mod = require("shodan.config")
local errors = require("shodan.errors")
local utils = require("shodan.utils")
local time = require("luatime")
local http_mod = require("shodan.http")

--- @class Client
--- @field config table
--- @field http table
--- @field _api_cache table
local Client = {}
Client.__index = Client

-- create a new shodan client
--- @param api_key string|nil
--- @param opts table|nil
--- @return Client
function Client.new(api_key, opts)
    opts = opts or {}

    if type(api_key) == "table" then
        opts = api_key
        api_key = nil
    end
    if api_key then
        opts.api_key = api_key
    end

    if not opts.api_key then
        opts.api_key = os.getenv("SHODAN_API_KEY")
    end

    if not opts.api_key then
        error("API key is required. Set via opts.api_key or SHODAN_API_KEY env var.")
    end

    local cfg = config_mod.new(opts)
    local ok, err = config_mod.validate(cfg)
    if not ok then
        error(errors.ShodanError.new(err))
    end

    local self = setmetatable({}, Client)
    self.config = cfg
    self.http = http_mod.create(cfg.http, cfg)

    self._api_cache = {}

    return self
end

--- @return number status, string body, table|nil headers
function Client:_do_request(method, url, opts)
    if not self.http then
        return 500, "HTTP not available"
    end
    return self.http:request(method, url, opts)
end

-- perform an API request with retry logic
--- @param method string
--- @param base_url string base URL to use
--- @param path string API path
--- @param params table|nil query parameters
--- @param body table|nil request body
--- @return table Decoded json response
function Client:_request(method, base_url, path, params, body)
    params = params or {}
    params.key = self.config.api_key

    local url = utils.build_url(base_url, path, params)

    local opts = {}
    if body then
        local json_str, err = utils.json_encode(self.config.json_library, body)
        if not json_str then
            error(errors.ShodanError.new("JSON encode error: " .. tostring(err)))
        end
        opts.body = json_str
        opts.headers = { ["Content-Type"] = "application/json" }
    end

    local last_err
    local max_attempts = self.config.max_retries + 1

    for attempt = 1, max_attempts do
        local status, resp_body, resp_headers = self:_do_request(method, url, opts)

        if not status then
            last_err = errors.HTTPError.new("Request failed: " .. tostring(resp_body))
            if attempt < max_attempts then
                time.sleep(self.config.retry_delay * attempt)
            end
        else
            local data, parse_err = utils.json_decode(self.config.json_library, resp_body)

            if not data then
                if status >= 200 and status < 300 then
                    return { _raw = resp_body }
                end
                error(errors.from_response(status, resp_body))
            end

            if status >= 400 then
                local api_err = errors.from_response(status, data)

                if status == 429 and attempt < max_attempts then
                    last_err = api_err
                    time.sleep(self.config.retry_delay * attempt * 2)

                elseif status >= 500 and attempt < max_attempts then
                    last_err = api_err
                    time.sleep(self.config.retry_delay * attempt)
                else
                    error(tostring(api_err))
                end
            else
                return data
            end
        end
    end

    error(tostring(last_err or errors.ShodanError.new("Max retries exceeded")))
end

-- GET request to main API
--- @param path string
--- @param params table|nil
--- @return table
function Client:get(path, params)
    return self:_request("GET", self.config.base_url, path, params)
end

-- POST request to main API
--- @param path string
--- @param params table|nil
--- @param body table|nil
--- @return table
function Client:post(path, params, body)
    return self:_request("POST", self.config.base_url, path, params, body)
end

function Client:put(path, params, body)
    return self:_request("PUT", self.config.base_url, path, params, body)
end

function Client:delete(path, params)
    return self:_request("DELETE", self.config.base_url, path, params)
end

function Client:get_exploits(path, params)
    return self:_request("GET", self.config.exploits_url, path, params)
end

function Client:get_stream(path, params)
    return self:_request("GET", self.config.stream_url, path, params)
end

--- @param name string module name (e.g., "search", "host")
--- @return table API
function Client:api(name)
    if not self._api_cache[name] then
        local mod = require("shodan.api." .. name)
        self._api_cache[name] = mod.new(self)
    end
    return self._api_cache[name]
end

function Client:__index(key)
    -- check raw table first
    local raw = rawget(Client, key)
    if raw ~= nil then return raw end

    -- check API modules
    local api_modules = {
        search = true, host = true, exploits = true, dns = true,
        tools = true, scan = true, alerts = true, data = true,
        org = true, queries = true, directory = true, stream = true,
        notifiers = true, account = true, on_demand = true,
    }
    if api_modules[key] then
        return Client.api(rawget(self, "_api_cache") and self or rawget(self, "config") and self, key)
    end

    return nil
end

return Client
