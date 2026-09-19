<br>

<div align="center">
    <a href="#donate">Buy Me a Coffee</a>
</div>

<br>

---

<br>

# Shodan: Lua Library For Shodan API

<br>

## Introduction

Shodan is the most papular search engine for devicse which are connected to the internet around the world. it lets pentesters and hackers to gather information and find specfic target. I decided to develop an easy-to-use wrapper for this amazing tool that Lua developers and those who know Lua can use it.<br/>I hope this would be helpful for you. I my self use it every day as a hunter.

<br>

## Installation

**Clone repository:**
```bash
git clone https://github.com/hu-matin/shodan-lua.git
cd shodan-lua
```

**Lua package manager (luarocks):**
```bash
luarocks install shodan
```
<br>

## API Key Setup

Before using the library, you need a Shodan API key.

- Create an account in [**shodan.io**](https://account.shodan.io/login)
- Go to your `API Key` column
- Click on `Show` link
- Copy your Key

- ### Environment Variable
The client reads SHODAN_API_KEY automatically when no key is passed.

<br>

Windows (CMD):
```bash
set SHODAN_API_KEY=your_api_key
```

Windows (PowerShell):
```bash
$env:SHODAN_API_KEY="your_api_key"
```

Linux / macOS:
```bash
export SHODAN_API_KEY="your_api_key"
```
<br>

- ### Pass Directly

```lua
local shodan = require("shodan")
local api = shodan.new("your_api_key")
```

## Quick Start

```lua
local shodan = require("shodan")
local api = shodan.new()  -- reads SHODAN_API_KEY from environment

local results = api:api("search"):search("apache country:IR", { page = 1, minify = true })

print("Total: " .. results.total)
for i, match in ipairs(results.matches) do
    print(string.format("[%d] %s:%d - %s", i, match.ip_str, match.port, match.org or "Unknown"))
end
```

## Test
The library includes a full test suite and
all HTTP calls are mocked, so tests run offline and finish in under a second.

Windows:
```bash
busted --verbose tests
```

MacOS / Linux:
```bash
make install
make test
```

## API Modules Reference

| Module | Methodes |
| :--- | :--- |
| `search` | `search(q, opts)`, `count(q)`, `tokens(q)`, `cursor(q, opts)` |
| `host` | `lookup(ip, opts)` |
| `exploits` | `search(q, opts)`, `count(q)` |
| `dns` | `resolve(hostnames)`, `reverse(ips)` |
| `tools` | `myip()`, `httpheaders()` |
| `scan` | `scan(ips)`, `status(id)`, `internet(port, proto)` |
| `alerts` | `create(name, filters)`, `info(id)`, `list()`, `delete(id)` |
| `data` | `list()`, `dataset(name)` |
| `org` | `info()`,` add_member(user)`, `remove_member(user)` |
| `queries` | `list(opts)`, `search(q)`, `tags(opts)` |
| `directory` | `ports()`,` protocols()`, `services()` |
| `stream` | `banners(opts)`, `ports(list)`, `asn(list)`, `countries(list)` |
| `notifiers` | `providers()`, `list()`, `create(provider, desc, params)`, `delete(id)` |
| `account` | `profile()`, `info()` |

<br>


## Features

### Complete Shodan API Coverage
- **Search API**: Full-text search with pagination, facets, and token parsing
- **Host Lookup**: Detailed information about any IP address
- **Exploits Database**: Search for known vulnerabilities and exploits
- **DNS Resolution**: Forward and reverse DNS lookups
- **Network Scanning**: On-demand port scanning with credit tracking
- **Alerts & Monitoring**: Real-time network monitoring with customizable triggers
- **Streaming**: Real-time banner data feed
- **Bulk Data Access**: Download large datasets
- **Organization Management**: Manage team members and permissions
- **Saved Queries**: Browse and search community queries
- **Directory**: Access crawled ports, protocols, and services
- **Notifiers**: Configure alerts via email, Slack, and other channels
- **Account Info**: Check API usage, credits, and plan details
- **Tools**: Free utilities like public IP lookup and HTTP headers inspection

###  Other
- **Cross-Platform**: Works on Windows, Linux, and macOS
- **Lua 5.1+ Compatible**: Supports Lua 5.1, 5.2, 5.3, 5.4, 5.5, and LuaJIT
- **Pluggable HTTP Handlers**: Choose between `curl` (default), `luasocket`, or `lua_http`
- **Structured Error Handling**: Dedicated error types for HTTP 401, 404, 429, 500, etc.
- **Automatic Retries**: Built-in exponential backoff for transient failures
- **Pure Lua JSON**: Uses `dkjson` for maximum compatibility
- [**Luatime**](https://github.com/hu-matin/luatime)
- **System `curl` by Default**: No extra dependencies on Windows 10/11 and macOS
- **User-Agent Identification**: Proper API attribution (`ShodanLua/{latest-version}`)
- **SSL Verification**: Secure by default, optional for debugging

<br>

## [API Features & Pricing](https://account.shodan.io/billing)

Shodan restricts certain endpoints based on your account plan.

| Module | Free | Membership | Enterprise |
|--------|------|------------|------------|
| `tools` | ✓  | ✓  | ✓  |
| `host` | ✓  (limited results) | ✓  | ✓  |
| `search` | ✓  (1 req/sec) | ✓  (unlimited) | ✓  |
| `exploits` | ✓  (limited) | ✓  | ✓  |
| `dns` | ✗ | ✓  | ✓  |
| `scan` | ✗ | ✓  (uses credits) | ✓  |
| `alerts` | ✗ | ✓  | ✓  |
| `org` | ✗ | ✗ | ✓  |
| `queries` | ✓  | ✓  | ✓  |
| `directory` | ✓  | ✓  | ✓  |
| `stream` | ✗ | ✗ | ✓  |
| `data` | ✗ |  | ✓  |

## Donate

- [**TON:**](https://app.tonkeeper.com/transfer/UQCnl2n83p_BSXPKnX1wATFNVcgn8eefruUveFTjZ14AmARe)
```UQCnl2n83p_BSXPKnX1wATFNVcgn8eefruUveFTjZ14AmARe```

<p id='donate'></p>