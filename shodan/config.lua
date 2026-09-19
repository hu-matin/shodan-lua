--- @module "shodan.config"

local config = {}

-- default configs
config.defaults = {
    api_key = nil,
    base_url = "https://api.shodan.io",
    exploits_url = "https://cvedb.shodan.io",
    stream_url = "https://stream.shodan.io",
    timeout = 30,
    max_retries = 3,
    retry_delay = 1.0,
    user_agent = "ShodanLua/1.3.1",
    http = "curl",
    json_library = "dkjson",
    proxies = nil,
    verify_ssl = true,
    debug = false,
}

-- Create a new configuration by merging defaults with overrides
--- @param opts table|nil
--- @return table
function config.new(opts)
    opts = opts or {}
    local cfg = {}

    for k, v in pairs(config.defaults) do
        cfg[k] = v
    end

    for k, v in pairs(opts) do
        if cfg[k] ~= nil or k == "api_key" then
            cfg[k] = v
        end
    end

    if not cfg.api_key then
        cfg.api_key = os.getenv("SHODAN_API_KEY")
    end

    return cfg
end

-- validate configuration
--- @param cfg table your configs
--- @return boolean ok
--- @return string|nil
function config.validate(cfg)
    if not cfg.api_key or cfg.api_key == "" then
        return false, "API key is required. Set via opts.api_key or SHODAN_API_KEY env var."
    end

    if cfg.timeout and cfg.timeout < 1 then
        return false, "Timeout must be greator than 1 second"
    end

    if cfg.max_retries and cfg.max_retries < 0 then
        return false, "max_retries must be greator than 0"
    end

   local valid_backends = { luasocket = true, lua_http = true, curl = true }
    if not valid_backends[cfg.http] then
        return false, "Invalid http: " .. tostring(cfg.http)
    end

    local valid_json = { cjson = true, dkjson = true }
    if not valid_json[cfg.json_library] then
        return false, "Invalid json_library: " .. tostring(cfg.json_library)
    end

    return true, nil
end

return config
