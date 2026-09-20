local shodan = require("shodan")
local api = shodan.new(os.getenv("SHODAN_API_KEY"))

print("Search with facets:")
local results = api:api("search"):search("nginx", { page = 1, facets = "country,org" })

if results.facets then
    for name, data in pairs(results.facets) do
        print("\n" .. name .. ":")
        for i = 1, math.min(3, #data) do
            print("  " .. data[i].value .. " (" .. data[i].count .. ")")
        end
    end
end

print("\nCount: " .. api:api("search"):count("nginx").total)

print("\nTokens:")
local tokens = api:api("search"):tokens("apache port:80")
print("  Filters: " .. table.concat(tokens.filters, ", "))
print("  String: " .. tokens.string)