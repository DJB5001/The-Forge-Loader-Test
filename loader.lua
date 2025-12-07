-- The Forge Loader (Private Repo Support)
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

-- Fetch encoded script
local success, encoded = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/DJB5001/The-Forge-Loader/main/encoded.txt?" .. tick(), true)
end)

if not success or not encoded then
    warn("[THE FORGE] Failed to fetch encoded script")
    warn(encoded)
    return
end

print("[THE FORGE] Decoding...")
local decoded = base64Decode(encoded)

if not decoded or #decoded == 0 then
    warn("[THE FORGE] Decode failed")
    return
end

print("[THE FORGE] Executing...")
local ok, err = pcall(function()
    loadstring(decoded)()
end)

if not ok then
    warn("[THE FORGE] Error:")
    warn(err)
else
    print("[THE FORGE] ✅ Success!")
end