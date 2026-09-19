local shodan = require("shodan")

describe("shodan.api.tools", function()

    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = require("tests.helpers.mock_http").new({
            ["tools/myip"]        = { 200, '1.2.3.4' },
            ["tools/httpheaders"] = { 200, '{"User-Agent": "ShodanLua", "Accept": "application/json"}' },
        })
        client.http = mock
    end)

    describe("myip", function()
        it("returns IP address string", function()
            local ip = client:api("tools"):myip()
            assert.are.equal("1.2.3.4", ip)
        end)
    end)

    describe("httpheaders", function()
        it("returns headers table", function()
            local headers = client:api("tools"):httpheaders()
            assert.is_not_nil(headers["User-Agent"])
        end)
    end)
end)