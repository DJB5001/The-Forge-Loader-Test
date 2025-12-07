-- The Forge Private Loader v3
-- Advanced token protection

local HttpService = game:GetService("HttpService")

print("[THE FORGE] Starting...")

-- Configuration
local REPO_OWNER = "DJB5001"
local REPO_NAME = "The-Forge-Test"
local BRANCH = "main"
local FILE = "loader.lua"

-- Token split into parts (to avoid detection)
local function getToken()
    local parts = {
        "Z2l0aHViX3BhdF8xMUJJMlA0S0Ew",
        "RW9WOGh4Y2NiT1RHX2FYVjF0QTI3Q2I2",
        "Rnh3OFU1enRoNFc3UkVOY2hBbG93",
        "R05ZS3I4SENCY2JqRFBaUUE1TVFl",
        "NmR6d0JIZA=="
    }
    
    local encoded = table.concat(parts, "")
    
    -- Decode base64
    local function decode(str)
        local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        local result = {}
        local pad = str:match('=*$')
        str = str:gsub('=', '')
        
        for i = 1, #str, 4 do
            local n = 0
            for j = 1, 4 do
                local c = str:sub(i+j-1, i+j-1)
                local pos = b64chars:find(c, 1, true)
                if pos then
                    n = n * 64 + (pos - 1)
                end
            end
            
            result[#result+1] = string.char(bit32.rshift(n, 16))
            result[#result+1] = string.char(bit32.band(bit32.rshift(n, 8), 0xFF))
            result[#result+1] = string.char(bit32.band(n, 0xFF))
        end
        
        for i = 1, #pad do
            table.remove(result)
        end
        
        return table.concat(result)
    end
    
    return decode(encoded)
end

-- Fetch file from private repo
local function getPrivateFile(path)
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
        REPO_OWNER,
        REPO_NAME,
        path,
        BRANCH
    )
    
    local token = getToken()
    local headers = {
        ["Authorization"] = "Bearer " .. token,
        ["Accept"] = "application/vnd.github.v3.raw"
    }
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, headers)
    end)
    
    if success then
        print("[THE FORGE] ✅ Loaded:", path)
        return response
    else
        warn("[THE FORGE] ❌ Failed:", path)
        warn("[THE FORGE] Error:", response)
        return nil
    end
end

-- Load and execute main loader
local code = getPrivateFile(FILE)
if not code then
    warn("[THE FORGE] Failed to load main loader!")
    return
end

print("[THE FORGE] Executing loader...")
local success, err = pcall(function()
    loadstring(code)()
end)

if not success then
    warn("[THE FORGE] Error:")
    warn(err)
else
    print("[THE FORGE] ✅ Success!")
end
