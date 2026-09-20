local shodan = require("shodan")
local api = shodan.new(os.getenv("SHODAN_API_KEY"))

print("Your IP: " .. api:api("tools"):myip())

print("\nHTTP Headers:")
local headers = api:api("tools"):httpheaders()
for k, v in pairs(headers) do
    print("  " .. k .. ": " .. v)
end