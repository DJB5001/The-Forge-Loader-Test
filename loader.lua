-- The Forge Multi-File Loader
print("[THE FORGE] Loading...")

-- Base64 decoder
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64Decode(data)
    data = string.gsub(data, '[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b64chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Cache for loaded modules
local LoadedModules = {}

-- Load module from encoded file
local function loadModule(filename)
    if LoadedModules[filename] then
        return LoadedModules[filename]
    end
    
    local url = string.format(
        "https://raw.githubusercontent.com/DJB5001/The-Forge-Loader/main/encoded/%s.b64?%d",
        filename,
        tick()
    )
    
    local success, encoded = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success or not encoded or encoded == "" then
        warn("[THE FORGE] Failed to fetch:", filename)
        return nil
    end
    
    local decoded = base64Decode(encoded)
    
    if not decoded or #decoded == 0 then
        warn("[THE FORGE] Decode failed:", filename)
        return nil
    end
    
    local ok, chunk = pcall(loadstring, decoded)
    if not ok or not chunk then
        warn("[THE FORGE] Compile failed:", filename)
        return nil
    end
    
    local ok2, module = pcall(chunk)
    if not ok2 then
        warn("[THE FORGE] Execute failed:", filename)
        return nil
    end
    
    LoadedModules[filename] = module
    return module
end

print("[THE FORGE] Decoding...")

-- Load main loader script
local mainLoader = loadModule("loader.lua")

if not mainLoader then
    warn("[THE FORGE] Failed to load main script")
    return
end

print("[THE FORGE] Executing...")

-- Execute with module loader available globally
_G.DJLoadModule = loadModule

local ok, err = pcall(function()
    if type(mainLoader) == "function" then
        mainLoader()
    else
        -- If it's not a function, just execute the loaded code
        loadstring(mainLoader)()
    end
end)

if not ok then
    warn("[THE FORGE] Error:")
    warn(err)
else
    print("[THE FORGE] ✅ Success!")
end