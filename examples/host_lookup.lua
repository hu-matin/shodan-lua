local shodan = require("shodan")
local api = shodan.new(os.getenv("SHODAN_API_KEY"))

local host = api:api("host"):lookup("8.8.8.8")

print("IP: " .. host.ip_str)
print("Org: " .. (host.org or "N/A"))
print("Country: " .. (host.country_name or "N/A"))
print("Ports: " .. table.concat(host.ports, ", "))
print("Hostnames: " .. table.concat(host.hostnames or {}, ", "))