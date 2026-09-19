--- @module "shodan.http"

local http = {}

function http.create(handler_name, config)
    local handler

    if handler_name == "curl" then
        handler = require("shodan.http.curl")

    elseif handler_name == "luasocket" then
        handler = require("shodan.http.luasocket")

    elseif handler_name == "lua_http" then
        handler = require("shodan.http.lua_http")

    else
        error("Unknown HTTP handler: " .. tostring(handler_name))
    end

    return handler.new(config)
end

return http
