local shodan = require("shodan")
local mock_http = require("tests.helpers.mock_http")

describe("shodan.api.search", function()
    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = mock_http.new({
            ["shodan/host/count%?"] = { 200, '{"total": 12345, "facets": {}}' },
            ["search/tokens%?"] = { 200, '{"filters": ["port"], "string": "apache", "errors": [], "attributes": {}}' },
            ["shodan/host/search%?"] = { 200, '{"matches": [{"ip_str": "1.2.3.4", "port": 80}], "total": 1, "facets": {}}' },
        })
        client.http = mock
    end)

    describe("search", function()
        it("performs a basic search", function()
            local result = client:api("search"):search("apache")
            assert.is_not_nil(result.matches)
            assert.are.equal(1, result.total)
            assert.are.equal("1.2.3.4", result.matches[1].ip_str)
        end)

        it("passes page parameter", function()
            client:api("search"):search("apache", { page = 2 })
            local req = client.http:last_request()
            assert.truthy(req.url:find("page=2"))
        end)

        it("includes API key in request", function()
            client:api("search"):search("apache")
            local req = client.http:last_request()
            assert.truthy(req.url:find("key=test_key"))
        end)
    end)

    describe("count", function()
        it("returns total count", function()
            local result = client:api("search"):count("apache")
            assert.are.equal(12345, result.total)
        end)
    end)

    describe("tokens", function()
        it("parses query into tokens", function()
            local result = client:api("search"):tokens("apache port:80")
            assert.is_not_nil(result.filters)
            assert.is_not_nil(result.string)
        end)
    end)
end)