--- @module "shodan"

--[[
    Shodan API Wrapper for Lua
    This module provides an easy-to-use interface to interact with the
    Shodan search engine API, including both REST and Streaming clients.

    Author: Matin
    License: MIT
    Year: 2026
]]


local Client = require("shodan.client")
local StreamClient = require("shodan.stream")
local errors = require("shodan.errors")
local version = require("shodan.version")
local config_mod = require("shodan.config")

local shodan = {}

shodan.VERSION = version.STRING

-- Create a new Shodan API client
--- @param api_key string|nil Shodan API key or set SHODAN_API_KEY env
--- @param opts table|nil Configuration options
--- @return Client
function shodan.new(api_key, opts)
    return Client.new(api_key, opts)
end

-- Create a streaming client
--- @param api_key string|nil
--- @param opts table|nil
--- @return StreamClient
function shodan.stream(api_key, opts)
    return StreamClient.new(api_key, opts)
end


shodan.errors = errors
shodan.config = config_mod
shodan.version = version


return shodan
