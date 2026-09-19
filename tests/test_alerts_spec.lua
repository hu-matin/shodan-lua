local shodan = require("shodan")
local mock_http = require("tests.helpers.mock_http")

describe("shodan.api.alerts", function()
    local client

    before_each(function()
        client = shodan.new("test_key_12345678901234567")
        local mock = mock_http.new({
            ["shodan/alert"] = { 200, '{"id": "alert-123", "name": "Test Alert"}' },
            ["shodan/alert/alert%-123"] = { 200, '{"id": "alert-123", "name": "Test Alert", "filters": {"ip": ["192.168.1.0/24"]}}' },
            ["shodan/alert/alert%-123/notifier"] = { 200, '{"success": true}' },
            ["shodan/alert/alert%-123/triggers"] = { 200, '{"success": true}' },
        })
        client.http = mock
    end)

    describe("list", function()
        it("lists all alerts", function()
            local result = client:api("alerts"):list()
            assert.is_table(result)
        end)

        it("gets specific alert info", function()
            local result = client:api("alerts"):info("alert-123")
            assert.is_table(result)
            assert.are.equal("alert-123", result.id)
        end)
    end)

    describe("create", function()
        it("creates a new alert", function()
            local result = client:api("alerts"):create("Test Alert", {
                ip = { "192.168.1.0/24" }
            })
            assert.is_not_nil(result.id)
            assert.are.equal("Test Alert", result.name)
        end)

        it("creates alert with optional parameters", function()
            local result = client:api("alerts"):create("Test Alert", {
                ip = { "10.0.0.0/8" }
            }, {
                ports = { 80, 443 },
                tags = { "web", "critical" }
            })
            assert.is_not_nil(result.id)
        end)
    end)

    describe("delete", function()
        it("deletes an alert", function()
            local result = client:api("alerts"):delete("alert-123")
            assert.is_table(result)
        end)
    end)

    describe("notifiers", function()
        it("adds notifier to alert", function()
            local result = client:api("alerts"):add_notifier("alert-123", "notifier-456")
            assert.is_table(result)
        end)

        it("removes notifier from alert", function()
            local result = client:api("alerts"):remove_notifier("alert-123", "notifier-456")
            assert.is_table(result)
        end)
    end)

    describe("triggers", function()
        it("adds trigger to alert", function()
            local result = client:api("alerts"):add_trigger("alert-123", "vulnerable")
            assert.is_table(result)
        end)

        it("removes trigger from alert", function()
            local result = client:api("alerts"):remove_trigger("alert-123", "trigger-789")
            assert.is_table(result)
        end)
    end)
end)