-- The Forge Loader v2
local HttpService = game:GetService("HttpService")

print("[THE FORGE] Starting...")

-- Token decoder
local function getToken()
    local p = {"Z2l0aHViX3BhdF8xMUJJMlA0","S0EwdFAyUVJaR0oxamtQXzll","YVRKZVFBM1Y2WUVTWEg3Sm5z","R1IxTHRVWEZ0cHZhWW9QV1dV","RGNMSkFKV1ZNVkFXVHdCZEQzVEJ2"}
    local encoded = table.concat(p, "")
    local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = ""
    
    for i = 1, #encoded, 4 do
        local n = 0
        for j = 1, 4 do
            local c = encoded:sub(i+j-1, i+j-1)
            local pos = b64:find(c, 1, true)
            if pos then n = n * 64 + (pos - 1) end
        end
        result = result .. string.char(bit32.rshift(n, 16))
        result = result .. string.char(bit32.band(bit32.rshift(n, 8), 0xFF))
        result = result .. string.char(bit32.band(n, 0xFF))
    end
    
    return result:sub(1, -4)
end

-- Fetch from private repo
local function fetch(path)
    local token = getToken()
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
        "DJB5001",
        "The-Forge-Test",
        path,
        "main"
    )
    
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

-- Main execution
local code = fetch("loader.lua")

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