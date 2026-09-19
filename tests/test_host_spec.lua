local shodan = require("shodan")

describe("shodan.api.host", function()

    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = require("tests.helpers.mock_http").new({
            ["host/8%.8%.8%.8"] = { 200, '{"ip_str": "8.8.8.8", "ports": [53, 443], "org": "Google LLC", "data": []}' },
        })
        client.http = mock
    end)

    describe("lookup", function()
        it("returns host information", function()
            local result = client:api("host"):lookup("8.8.8.8")
            assert.are.equal("8.8.8.8", result.ip_str)
            assert.are.equal("Google LLC", result.org)
            assert.is_not_nil(result.ports)
        end)

        it("includes history parameter", function()
            client:api("host"):lookup("8.8.8.8", { history = true })
            local req = client.http:last_request()
            assert.truthy(req.url:find("history=true"))
        end)
    end)
end)