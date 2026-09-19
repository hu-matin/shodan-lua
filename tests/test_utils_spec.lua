local utils = require("shodan.utils")

describe("shodan.utils", function()

    describe("url_encode", function()
        it("encodes special characters", function()
            assert.are.equal("hello%20world", utils.url_encode("hello world"))
            assert.are.equal("a%26b%3Dc", utils.url_encode("a&b=c"))
            assert.are.equal("test%2Fpath", utils.url_encode("test/path"))
        end)

        it("preserves safe characters", function()
            assert.are.equal("hello-world_123", utils.url_encode("hello-world_123"))
            assert.are.equal("abc", utils.url_encode("abc"))
        end)

        it("handles empty string", function()
            assert.are.equal("", utils.url_encode(""))
        end)

        it("converts non-string to string", function()
            assert.are.equal("123", utils.url_encode(123))
        end)
    end)

    describe("build_query_string", function()
        it("builds from simple table", function()
            local qs = utils.build_query_string({ key = "abc", page = 1 })
            assert.truthy(qs:find("key=abc"))
            assert.truthy(qs:find("page=1"))
        end)

        it("handles boolean values", function()
            local qs = utils.build_query_string({ minify = true })
            assert.are.equal("minify=true", qs)
        end)

        it("returns empty for nil/empty table", function()
            assert.are.equal("", utils.build_query_string(nil))
            assert.are.equal("", utils.build_query_string({}))
        end)

        it("skips nil values", function()
            local qs = utils.build_query_string({ a = 1, b = nil, c = 3 })
            assert.falsy(qs:find("b="))
            assert.truthy(qs:find("a=1"))
            assert.truthy(qs:find("c=3"))
        end)
    end)

    describe("build_url", function()
        it("combines base, path, and params", function()
            local url = utils.build_url("https://api.shodan.io", "/shodan/host/search", { query = "apache" })
            assert.are.equal("https://api.shodan.io/shodan/host/search?query=apache", url)
        end)

        it("strips trailing slash from base", function()
            local url = utils.build_url("https://api.shodan.io/", "/test", {})
            assert.are.equal("https://api.shodan.io/test", url)
        end)

        it("adds leading slash to path", function()
            local url = utils.build_url("https://api.shodan.io", "test", {})
            assert.are.equal("https://api.shodan.io/test", url)
        end)
    end)

    describe("is_valid_ip", function()
        it("validates IPv4", function()
            assert.is_true(utils.is_valid_ip("192.168.1.1"))
            assert.is_true(utils.is_valid_ip("0.0.0.0"))
            assert.is_true(utils.is_valid_ip("255.255.255.255"))
        end)

        it("rejects invalid IPv4", function()
            assert.is_false(utils.is_valid_ip("256.1.1.1"))
            assert.is_false(utils.is_valid_ip("not-an-ip"))
            assert.is_false(utils.is_valid_ip(""))
        end)

        it("validates IPv6 (simplified)", function()
            assert.is_true(utils.is_valid_ip("::1"))
            assert.is_true(utils.is_valid_ip("2001:db8::1"))
        end)
    end)

    describe("is_valid_api_key", function()
        it("accepts valid keys", function()
            assert.is_true(utils.is_valid_api_key("abcdefghijklmnopqrstuvwxyz123456"))
        end)

        it("rejects short keys", function()
            assert.is_false(utils.is_valid_api_key("short"))
        end)

        it("rejects nil", function()
            assert.is_false(utils.is_valid_api_key(nil))
        end)
    end)

    describe("deep_merge", function()
        it("merges nested tables", function()
            local a = { x = 1, nested = { a = 1, b = 2 } }
            local b = { y = 2, nested = { b = 3, c = 4 } }
            local result = utils.deep_merge(a, b)
            assert.are.equal(1, result.x)
            assert.are.equal(2, result.y)
            assert.are.equal(1, result.nested.a)
            assert.are.equal(3, result.nested.b)  -- overridden
            assert.are.equal(4, result.nested.c)
        end)
    end)

    describe("lines", function()
        it("iterates over lines", function()
            local result = {}
            for line in utils.lines("a\nb\nc") do
                table.insert(result, line)
            end
            assert.are.same({ "a", "b", "c" }, result)
        end)

        it("handles trailing newline", function()
            local result = {}
            for line in utils.lines("a\nb\n") do
                table.insert(result, line)
            end
            assert.are.same({ "a", "b" }, result)
        end)
    end)
end)