-- The Forge Multi-File Loader (TEST VERSION)
print("[THE FORGE TEST] Loading from Test Repository...")

-- Cache for loaded modules
local LoadedModules = {}

-- Load module DIRECTLY from The-Forge-Test repo (no encoding)
local function loadModule(filename)
    if LoadedModules[filename] then
        print("[THE FORGE TEST] 👍 Using cached:", filename)
        return LoadedModules[filename]
    end
    
    print("[THE FORGE TEST] 📥 Loading:", filename)
    
    local url = string.format(
        "https://raw.githubusercontent.com/DJB5001/The-Forge-Test/main/%s?%d",
        filename,
        tick()
    )
    
    local success, code = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success or not code or code == "" then
        warn("[THE FORGE TEST] ❌ Failed to fetch:", filename)
        warn("Error:", tostring(code))
        return nil
    end
    
    print("[THE FORGE TEST] 📦 Downloaded:", filename, "(", #code, "bytes)")
    
    local ok, chunk = pcall(loadstring, code)
    if not ok or not chunk then
        warn("[THE FORGE TEST] ❌ Compile failed:", filename)
        warn("Error:", tostring(chunk))
        return nil
    end
    
    print("[THE FORGE TEST] 🔧 Compiled:", filename)
    
    local ok2, module = pcall(chunk)
    if not ok2 then
        warn("[THE FORGE TEST] ❌ Execute failed:", filename)
        warn("Error:", tostring(module))
        return nil
    end
    
    print("[THE FORGE TEST] ✅", filename, "loaded successfully")
    
    LoadedModules[filename] = module
    return module
end

print("[THE FORGE TEST] Exposing module loader...")

-- Expose module loader globally FIRST
_G.DJLoadModule = loadModule

print("[THE FORGE TEST] Loading main script...")

-- Load main loader.lua directly
local url = string.format(
    "https://raw.githubusercontent.com/DJB5001/The-Forge-Test/main/loader.lua?%d",
    tick()
)

local success, code = pcall(function()
    return game:HttpGet(url, true)
end)

if not success or not code or code == "" then
    warn("[THE FORGE TEST] Failed to load main script")
    warn("Error:", tostring(code))
    return
end

print("[THE FORGE TEST] Downloaded loader.lua:", #code, "bytes")

local ok, chunk = pcall(loadstring, code)
if not ok or not chunk then
    warn("[THE FORGE TEST] Compile failed!")
    warn("Error:", tostring(chunk))
    return
end

print("[THE FORGE TEST] Executing main loader...")

local ok2, err = pcall(chunk)

if not ok2 then
    warn("[THE FORGE TEST] Error:")
    warn(err)
else
    print("[THE FORGE TEST] ✅ Success!")
end