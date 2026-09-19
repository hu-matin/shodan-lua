--- @module "shodan.errors"

local errors = {}

local ShodanError = {}
ShodanError.__index = ShodanError
ShodanError.__name = "ShodanError"
ShodanError.__is_shodan_error = true

function ShodanError.new(message, code, raw)
    local self = setmetatable({}, ShodanError)
    self.message = message or "Unknown Shodan error"
    self.code = code
    self.raw = raw
    return self
end

function ShodanError:__tostring()
    if self.code then
        return string.format("[%s %d] %s", self.__name, self.code, self.message)
    end
    return string.format("[%s] %s", self.__name, self.message)
end

errors.ShodanError = ShodanError

--- @class APIError
local APIError = setmetatable({}, { __index = ShodanError })
APIError.__index = APIError
APIError.__name = "APIError"
APIError.__tostring = ShodanError.__tostring 

function APIError.new(message, code, raw)
    local self = ShodanError.new(message, code, raw)
    setmetatable(self, APIError)
    return self
end

errors.APIError = APIError

local AuthError = setmetatable({}, { __index = APIError })
AuthError.__index = AuthError
AuthError.__name = "AuthError"
AuthError.__tostring = ShodanError.__tostring

function AuthError.new(message, raw)
    local self = APIError.new(message or "Invalid API key", 401, raw)
    setmetatable(self, AuthError)
    return self
end

errors.AuthError = AuthError

local RateLimitError = setmetatable({}, { __index = APIError })
RateLimitError.__index = RateLimitError
RateLimitError.__name = "RateLimitError"
RateLimitError.__tostring = ShodanError.__tostring

function RateLimitError.new(message, raw)
    local self = APIError.new(message or "Rate limit exceeded", 429, raw)
    setmetatable(self, RateLimitError)
    return self
end

errors.RateLimitError = RateLimitError

local NotFoundError = setmetatable({}, { __index = APIError })
NotFoundError.__index = NotFoundError
NotFoundError.__name = "NotFoundError"
NotFoundError.__tostring = ShodanError.__tostring

function NotFoundError.new(message, raw)
    local self = APIError.new(message or "Resource not found", 404, raw)
    setmetatable(self, NotFoundError)
    return self
end

errors.NotFoundError = NotFoundError

local ValidationError = setmetatable({}, { __index = APIError })
ValidationError.__index = ValidationError
ValidationError.__name = "ValidationError"
ValidationError.__tostring = ShodanError.__tostring

function ValidationError.new(message, raw)
    local self = APIError.new(message or "Invalid request parameters", 400, raw)
    setmetatable(self, ValidationError)
    return self
end

errors.ValidationError = ValidationError

--- @class HTTPError
local HTTPError = setmetatable({}, { __index = ShodanError })
HTTPError.__index = HTTPError
HTTPError.__name = "HTTPError"
HTTPError.__tostring = ShodanError.__tostring

function HTTPError.new(message, code, raw)
    local self = ShodanError.new(message, code, raw)
    setmetatable(self, HTTPError)
    return self
end

errors.HTTPError = HTTPError

--- @class StreamError
local StreamError = setmetatable({}, { __index = ShodanError })
StreamError.__index = StreamError
StreamError.__name = "StreamError"
StreamError.__tostring = ShodanError.__tostring

function StreamError.new(message)
    local self = ShodanError.new(message or "Stream connection failed")
    setmetatable(self, StreamError)
    return self
end

errors.StreamError = StreamError

function errors.from_response(status, body)
    local message
    if type(body) == "table" then
        message = body.error or body.message or "Unknown error"
    else
        message = tostring(body or "Unknown error")
    end

    if status == 401 then
        return AuthError.new(message, body)
    elseif status == 403 then
        return AuthError.new("Access forbidden: " .. message, body)
    elseif status == 404 then
        return NotFoundError.new(message, body)
    elseif status == 400 then
        return ValidationError.new(message, body)
    elseif status == 429 then
        return RateLimitError.new(message, body)
    elseif status >= 500 then
        return APIError.new("Server error: " .. message, status, body)
    else
        return APIError.new(message, status, body)
    end
end

function errors.is_shodan_error(obj)
    if type(obj) ~= "table" then return false end

    local mt = getmetatable(obj)
    while type(mt) == "table" do
        if mt.__is_shodan_error or mt.__name == "ShodanError" then
            return true
        end
        mt = getmetatable(mt.__index)
    end

    return false
end

return errors