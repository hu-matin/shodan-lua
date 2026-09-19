--- @module "shodan.utils"

local utils = {}


--- @param str string
--- @return string encoded
function utils.url_encode(str)
    if type(str) ~= "string" then
        str = tostring(str)
    end
    return (str:gsub("([^%w%-%.%_%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

--- @param params table
--- @return string Query
function utils.build_query_string(params)
    if not params or next(params) == nil then
        return ""
    end
    local parts = {}
    local keys = {}

    for k in pairs(params) do
        keys[#keys + 1] = k
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = params[k]
        if v ~= nil then
            if type(v) == "boolean" then
                v = v and "true" or "false"
            elseif type(v) == "table" then
                for _, item in ipairs(v) do
                    parts[#parts + 1] = utils.url_encode(k) .. "=" .. utils.url_encode(item)
                end
                goto continue
            end
            parts[#parts + 1] = utils.url_encode(k) .. "=" .. utils.url_encode(v)
        end
        ::continue::
    end
    return table.concat(parts, "&")
end

--- @param base string
--- @param path string
--- @param params table|nil
--- @return string
function utils.build_url(base, path, params)
    base = base:gsub("/+$", "")

    if path:sub(1, 1) ~= "/" then
        path = "/" .. path
    end
    local url = base .. path
    local qs = utils.build_query_string(params or {})

    if qs ~= "" then
        url = url .. "?" .. qs
    end
    return url
end

--- @param a table
--- @param b table
--- @return table
function utils.deep_merge(a, b)
    local result = {}

    for k, v in pairs(a) do
        if type(v) == "table" and type(b[k]) == "table" then
            result[k] = utils.deep_merge(v, b[k])
        else
            result[k] = v
        end
    end

    for k, v in pairs(b) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = utils.deep_merge(result[k], v)
        else
            result[k] = v
        end
    end

    return result
end

--- @param t table
--- @return table Copy
function utils.shallow_copy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

--- @param ip string
--- @return boolean
function utils.is_valid_ip(ip)
    if type(ip) ~= "string" then return false end
    -- IPv4
    if ip:match("^%d+%.%d+%.%d+%.%d+$") then
        for octet in ip:gmatch("%d+") do
            if tonumber(octet) > 255 then return false end
        end
        return true
    end
    -- IPv6
    if ip:match("^[%x:]+$") then
        return true
    end
    return false
end

--- @param key string
--- @return boolean
function utils.is_valid_api_key(key)
    if type(key) ~= "string" then return false end
    return key:match("^[a-zA-Z0-9]+$") ~= nil and #key >= 16
end


function utils.json_decode(json_lib, str)
    if not str or str == "" then
        return nil, "Empty JSON string"
    end

    local ok, lib = pcall(require, json_lib or "dkjson")
    if not ok then
        return nil, "dkjson library not available. Install via: luarocks install dkjson"
    end

    local data, pos, err = lib.decode(str)
    return data, err
end

function utils.json_encode(json_lib, data)
    local ok, lib = pcall(require, json_lib or "dkjson")
    if not ok then
        return nil, "dkjson library not available. Install via: luarocks install dkjson"
    end

    return lib.encode(data)
end

--- @param str string
--- @return function iterator
function utils.lines(str)
    local pos = 1
    return function()
        if pos > #str then return nil end
        local s, e = str:find("\n", pos, true)
        if not s then
            local line = str:sub(pos)
            pos = #str + 1
            return line
        end
        local line = str:sub(pos, s - 1)
        pos = e + 1
        return line
    end
end

return utils
