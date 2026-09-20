local shodan = require("shodan")
local api = shodan.new(os.getenv("SHODAN_API_KEY"))

print("Searching for 'apache'...")
local results = api:api("search"):search("apache", { page = 1, minify = true })

print("Total: " .. results.total)
for i = 1, math.min(5, #results.matches) do
    local m = results.matches[i]
    print(string.format("[%d] %s:%d (%s)", i, m.ip_str, m.port, m.org or "Unknown"))
end