-- Direct Loader (Public)
print("[THE FORGE] Loading...")

local success, code = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/DJB5001/The-Forge-Test/main/loader.lua", true)
end)

if success and code then
    print("[THE FORGE] ✅ Loaded!")
    local ok, err = pcall(function()
        loadstring(code)()
    end)
    
    if not ok then
        warn("[THE FORGE] Error:", err)
    end
else
    warn("[THE FORGE] ❌ Failed to load")
    warn(code)
end