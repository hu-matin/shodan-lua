local shodan = require("shodan")

describe("shodan.client", function()

    describe("creation", function()
        it("creates client with API key", function()
            local client = shodan.new("test_api_key_12345678901234")
            assert.is_not_nil(client)
            assert.are.equal("test_api_key_12345678901234", client.config.api_key)
        end)

        it("creates client with options table", function()
            local client = shodan.new({
                api_key = "test_key_12345678901234567",
                timeout = 60,
            })

            assert.are.equal(60, client.config.timeout)
        end)

        it("errors without API key", function()
            -- ۱. ذخیره تابع اصلی os.getenv
            local original_getenv = os.getenv

            os.getenv = function(var)
                if var == "SHODAN_API_KEY" then return nil end
                return original_getenv(var)
            end

            assert.has_error(function()
                shodan.new({})
            end)

            os.getenv = original_getenv
        end)
    end)

    describe("configuration", function()
        it("uses default base URL", function()
            local client = shodan.new("test_key_12345678901234567")
            assert.are.equal("https://api.shodan.io", client.config.base_url)
        end)

        it("allows custom base URL", function()
            local client = shodan.new("test_key_12345678901234567", {
                base_url = "https://custom.api.shodan.io",
            })
            assert.are.equal("https://custom.api.shodan.io", client.config.base_url)
        end)

        it("sets default timeout", function()
            local client = shodan.new("test_key_12345678901234567")
            assert.are.equal(30, client.config.timeout)
        end)
    end)

    describe("API module loading", function()
        it("lazy-loads search module", function()
            local client = shodan.new("test_key_12345678901234567")
            local search = client:api("search")
            assert.is_not_nil(search)
            assert.is_not_nil(search.search)
        end)

        it("caches loaded modules", function()
            local client = shodan.new("test_key_12345678901234567")
            local s1 = client:api("search")
            local s2 = client:api("search")
            assert.are.equal(s1, s2)
        end)
    end)

    describe("version", function()
        it("exposes version string", function()
            assert.are.equal("1.3.1", shodan.VERSION)
        end)
    end)
end)