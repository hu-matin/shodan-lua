local shodan = require("shodan")

describe("shodan.api.dns", function()

    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = require("tests.helpers.mock_http").new({
            ["dns/resolve"] = { 200, '{"google.com": "142.250.185.78", "github.com": "140.82.121.3"}' },
            ["dns/reverse"] = { 200, '{"8.8.8.8": ["dns.google"]}' },
        })
        client.http = mock
    end)

    describe("resolve", function()
        it("resolves single hostname", function()
            local result = client:api("dns"):resolve("google.com")
            assert.is_not_nil(result["google.com"])
        end)

        it("resolves multiple hostnames", function()
            local result = client:api("dns"):resolve({ "google.com", "github.com" })
            assert.is_not_nil(result["google.com"])
            assert.is_not_nil(result["github.com"])
        end)
    end)

    describe("reverse", function()
        it("performs reverse DNS lookup", function()
            local result = client:api("dns"):reverse("8.8.8.8")
            assert.is_not_nil(result["8.8.8.8"])
        end)
    end)
end)