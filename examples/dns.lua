local shodan = require("shodan")
local api = shodan.new(os.getenv("SHODAN_API_KEY"))

print("Forward DNS:")
local dns = api:api("dns"):resolve({"google.com", "github.com"})
for host, ip in pairs(dns) do
    print("  " .. host .. " -> " .. ip)
end

print("\nReverse DNS:")
local reverse = api:api("dns"):reverse({"8.8.8.8"})
for ip, hosts in pairs(reverse) do
    print("  " .. ip .. " -> " .. table.concat(hosts, ", "))
end