-- The Forge Simple Loader
local HttpService = game:GetService("HttpService")

print("[THE FORGE] Starting...")

-- Token parts
local function getToken()
    local p = {"Z2l0aHViX3BhdF8xMUJJMlA0","S0EwdFAyUVJaR0oxamtQXzll","YVRKZVFBM1Y2WUVTWEg3Sm5z","R1IxTHRVWEZ0cHZhWW9QV1dV","RGNMSkFKV1ZNVkFXVHdCZEQzVEJ2"}
    local encoded = table.concat(p, "")
    local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = ""
    encoded = encoded:gsub('=', '')
    
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

-- Fetch
local function fetch(path)
    local url = "https://api.github.com/repos/DJB5001/The-Forge-Test/contents/" .. path .. "?ref=main"
    local token = getToken()
    
    local success, response = pcall(function()
        return game:HttpGet(url, false, {
            ["Authorization"] = "Bearer " .. token,
            ["Accept"] = "application/vnd.github.v3.raw"
        })
    end)
    
    if success then
        print("[THE FORGE] ✅ Loaded:", path)
        return response
    else
        warn("[THE FORGE] ❌ Failed:", path)
        return nil
    end
end

-- Load
local code = fetch("loader.lua")
if code then
    local success, err = pcall(function()
        loadstring(code)()
    end)
    if success then
        print("[THE FORGE] ✅ Success!")
    else
        warn("[THE FORGE] Error:", err)
    end
end