--- @module "tests.helpers.mock_http"

local mock_http = {}
mock_http.__index = mock_http

function mock_http.new(responses)
    local self = setmetatable({}, mock_http)
    self.requests = {}
    self.responses = responses or {}
    return self
end

function mock_http:add_response(pattern, status, body)
    self.responses[pattern] = { status, body }
end

function mock_http:request(method, url, opts)
    table.insert(self.requests, { method = method, url = url, opts = opts or {} })

    for pattern, response in pairs(self.responses) do
        if url:find(pattern) then
            return table.unpack(response)
        end
    end

    return nil, "Mock HTTP Error: No response configured for URL: " .. url
end

function mock_http:last_request()
    return self.requests[#self.requests]
end

function mock_http:all_requests()
    return self.requests
end

function mock_http:clear_requests()
    self.requests = {}
end

function mock_http:clear_responses()
    self.responses = {}
end

return mock_http