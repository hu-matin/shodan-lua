local shodan = require("shodan")

print("Test 1: Invalid API key")
local bad = shodan.new("invalid_key")
local ok, error = pcall(function()
    return bad:api("account"):profile()
end)

if not ok and shodan.errors.is_shodan_error(error) then
    print("  Caught: " .. error.message .. " (Status: " .. error.code .. ")")
end

print("\nTest 2: Premium feature")
local api = shodan.new(os.getenv("SHODAN_API_KEY"))
local ok, error = pcall(function()
    return api:api("alerts"):create("Test", {ip = {"1.1.1.1"}})
end)

if not ok then
    print("  Caught: " .. (error.message or error))
end