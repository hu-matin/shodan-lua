local shodan = require("shodan")

describe("integration", function()

    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = require("tests.helpers.mock_http").new({
            ["host/search"]       = { 200, '{"matches": [{"ip_str": "93.184.216.34", "port": 80, "org": "Edgecast"}], "total": 1}' },
            ["host/93"]           = { 200, '{"ip_str": "93.184.216.34", "ports": [80, 443], "hostnames": ["example.com"]}' },
            ["dns/resolve"]       = { 200, '{"example.com": "93.184.216.34"}' },
            ["tools/myip"]        = { 200, '203.0.113.1' },
            ["api%-info"]         = { 200, '{"scan_credits": 100, "usage_limits": {"scan_credits": 100}, "plan": "oss"}' },
            ["account/profile"]   = { 200, '{"member": true, "display_name": "testuser", "credits": 500}' },
            ["shodan/ports"]      = { 200, '[21, 22, 23, 25, 80, 443, 8080]' },
            ["shodan/protocols"]  = { 200, '{"http": {"port": 80}, "ssh": {"port": 22}}' },
            ["shodan/services"]   = { 200, '{"http": {}, "ssh": {}, "ftp": {}}' },
        })
        client.http = mock
    end)

    it("full search workflow", function()
        -- Search
        local results = client:api("search"):search("apache country:US")
        assert.are.equal(1, results.total)

        -- Lookup host from results
        local ip = results.matches[1].ip_str
        local host = client:api("host"):lookup(ip)
        assert.are.equal(ip, host.ip_str)
        assert.is_table(host.ports)

        -- Resolve hostname
        local dns = client:api("dns"):resolve("example.com")
        assert.are.equal(ip, dns["example.com"])
    end)

    it("account and API info", function()
        local info = client:api("account"):info()
        assert.are.equal("oss", info.plan)
        assert.are.equal(100, info.scan_credits)

        local profile = client:api("account"):profile()
        assert.is_true(profile.member)
        assert.are.equal("testuser", profile.display_name)
    end)

    it("directory queries", function()
        local ports = client:api("directory"):ports()
        assert.is_table(ports)
        assert.are.equal(7, #ports)

        local protocols = client:api("directory"):protocols()
        assert.is_not_nil(protocols.http)
        assert.is_not_nil(protocols.ssh)

        local services = client:api("directory"):services()
        assert.is_not_nil(services.http)
    end)

    it("tools", function()
        local ip = client:api("tools"):myip()
        assert.are.equal("203.0.113.1", ip)
    end)
end)