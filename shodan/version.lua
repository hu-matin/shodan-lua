--- @module "shodan.version"

local version = {
    MAJOR = 1,
    MINOR = 3,
    PATCH = 1,
}

version.STRING = string.format("%d.%d.%d", version.MAJOR, version.MINOR, version.PATCH)

--- @param other string
--- @return number
function version.compare(other)
    local o_major, o_minor, o_patch = other:match("(%d+)%.(%d+)%.(%d+)")
    if not o_major then return -1 end

    o_major, o_minor, o_patch = tonumber(o_major), tonumber(o_minor), tonumber(o_patch)

    if version.MAJOR ~= o_major then
        return version.MAJOR < o_major and -1 or 1
    end
    if version.MINOR ~= o_minor then
        return version.MINOR < o_minor and -1 or 1
    end
    if version.PATCH ~= o_patch then
        return version.PATCH < o_patch and -1 or 1
    end
    return 0
end

return version
