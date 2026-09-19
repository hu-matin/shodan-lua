local shodan = require("shodan")

describe("shodan.api.scan", function()

    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = require("tests.helpers.mock_http").new({
            ["shodan/scan/internet%?"] = { 200, '{"id": "scan-123"}' },
            ["shodan/scan%?"]          = { 200, '{"id": "scan-456", "count": 1, "credits_left": 99}' },
        })
        client.http = mock
    end)

    describe("scan", function()
        it("requests a scan", function()
            local result = client:api("scan"):scan("192.168.1.0/24")
            assert.is_not_nil(result.id)
            assert.are.equal(99, result.credits_left)
        end)

        it("accepts multiple IPs", function()
            local result = client:api("scan"):scan({ "1.2.3.4", "5.6.7.8" })
            assert.is_not_nil(result.id)
        end)
    end)

    describe("status", function()
        it("checks scan status", function()
            client.http:add_response("shodan/scan/scan%-456%?", 200, '{"id": "scan-456", "status": "DONE"}')
            local result = client:api("scan"):status("scan-456")
            assert.are.equal("DONE", result.status)
        end)
    end)
end)