local StreamClient = require("shodan.stream")

describe("shodan.stream", function()

    describe("creation", function()
        it("creates with API key", function()
            local sc = StreamClient.new("test_key_12345678901234567")
            assert.is_not_nil(sc)
            assert.are.equal("test_key_12345678901234567", sc.api_key)
        end)

        it("uses default stream URL", function()
            local sc = StreamClient.new("test_key_12345678901234567")
            assert.are.equal("https://stream.shodan.io", sc.stream_url)
        end)
    end)
end)