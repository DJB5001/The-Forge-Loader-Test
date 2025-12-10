-- DJ HUB — The Forge Script Loader (TEST VERSION)
-- Loads encoded files from The-Forge-Loader-Test repository
-- Game: The Forge
-- Author: DJB5001
-- Discord: discord.gg/MTXnFfHXW9

local GAME_NAME = "The Forge TEST"
local VERSION = "1.0.0"

-- Multiple game IDs (main game + subplaces)
local ALLOWED_GAME_IDS = {
    76558904092080,
    129009554587176
}


local currentGameId = game.PlaceId
local isAllowed = false

for _, id in ipairs(ALLOWED_GAME_IDS) do
    if currentGameId == id then
        isAllowed = true
        break
    end
end

if not isAllowed then
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "DJ HUB - Wrong Game",
            Text = "This script is for The Forge only!\nYour Game ID: "..tostring(currentGameId),
            Duration = 10
        })
    end)
    error("[DJ HUB] Wrong game! This script is for The Forge only.")
    return
end

print("[DJ HUB TEST] ✅ Game ID verified: The Forge ("..currentGameId..")")

-- ================================================================
-- CONFIG
-- ================================================================
local Config = {
    api = "ef8c4422-f7d4-4b3c-ab4e-c3363317dba9",
    provider = "Keys",
    service = "RaiseAnimal_DJHUB"
}

-- ================================================================
-- BASE64 DECODER (Proven Implementation)
-- ================================================================
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64Decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- ================================================================
-- SAVE SYSTEM (Filesystem-based)
-- ================================================================
local SaveSystem = {}
local SAVE_DIR = "DJHub/Settings"
local HttpService = game:GetService("HttpService")

local function hasFS()
    return typeof(writefile)=="function" and typeof(readfile)=="function" 
        and typeof(makefolder)=="function" and typeof(isfile)=="function" 
        and typeof(isfolder)=="function" and typeof(delfile)=="function"
end

local function ensureDir()
    if not hasFS() then return false end
    pcall(function()
        if not isfolder("DJHub") then makefolder("DJHub") end
        if not isfolder(SAVE_DIR) then makefolder(SAVE_DIR) end
    end)
    return isfolder(SAVE_DIR)
end

function SaveSystem.save(name)
    if not ensureDir() then return false, "Filesystem not available" end
    local data = {
        version = VERSION,
        saved = os.time(),
        settings = {}
    }
    
    for key, val in pairs(_G) do
        if type(key) == "string" and key:match("^__") then
            local t = type(val)
            if t == "boolean" or t == "number" or t == "string" then
                data.settings[key] = val
            elseif t == "table" then
                local ok, encoded = pcall(function() return HttpService:JSONEncode(val) end)
                if ok then data.settings[key] = encoded end
            end
        end
    end
    
    local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false, "Encoding failed" end
    
    local path = ("%s/%s.json"):format(SAVE_DIR, name:gsub("[^%w%-_]", "_"))
    local okw = pcall(function() writefile(path, json) end)
    return okw, okw and nil or "Write failed"
end

function SaveSystem.load(name)
    if not hasFS() then return false, "Filesystem not available" end
    local path = ("%s/%s.json"):format(SAVE_DIR, name:gsub("[^%w%-_]", "_"))
    if not isfile(path) then return false, "File not found" end
    
    local okr, raw = pcall(readfile, path)
    if not okr or type(raw) ~= "string" then return false, "Read failed" end
    
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or type(data) ~= "table" then return false, "Decode failed" end
    
    if data.settings then
        for key, val in pairs(data.settings) do
            if type(val) == "string" and val:match("^[%[{]") then
                local ok2, decoded = pcall(function() return HttpService:JSONDecode(val) end)
                if ok2 then _G[key] = decoded else _G[key] = val end
            else
                _G[key] = val
            end
        end
    end
    
    if _G.__DJ_Notify then _G.__DJ_Notify("settings:applied") end
    return true
end

function SaveSystem.delete(name)
    if not hasFS() then return false end
    local path = ("%s/%s.json"):format(SAVE_DIR, name:gsub("[^%w%-_]", "_"))
    if isfile(path) then pcall(delfile, path) end
    if _G.__DJ_Notify then _G.__DJ_Notify("saves:changed") end
    return true
end

function SaveSystem.list()
    if not hasFS() or not isfolder(SAVE_DIR) then return {} end
    local files = {}
    local ok = pcall(function()
        for _, file in ipairs(listfiles(SAVE_DIR)) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                local okr, raw = pcall(readfile, file)
                if okr and raw then
                    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
                    if ok2 and data then
                        table.insert(files, {
                            name = name,
                            time = data.saved or 0,
                            version = data.version or "?"
                        })
                    end
                end
            end
        end
    end)
    return files
end

_G.saveSettings = SaveSystem.save
_G.loadSettings = SaveSystem.load
_G.deleteSettings = SaveSystem.delete
_G.listSettings = SaveSystem.list

local subscribers = {}
_G.__DJ_Subscribe = function(fn) table.insert(subscribers, fn) end
_G.__DJ_Notify = function(evt) for _, fn in ipairs(subscribers) do pcall(fn, evt) end end

-- ================================================================
-- LOAD ENCODED MODULES FROM PUBLIC REPO
-- ================================================================
local REPO_BASE = "https://raw.githubusercontent.com/DJB5001/The-Forge-Loader-Test/main/encoded/"
local TEST_DIRECT = "https://raw.githubusercontent.com/DJB5001/The-Forge-Test/main/"

local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if not ok then
        warn("[DJ HUB TEST] HTTP GET failed for: " .. url)
        warn("[DJ HUB TEST] Error: " .. tostring(res))
    end
    return ok and res or nil
end

local function loadEncodedModule(name)
    print("[DJ HUB TEST] Loading " .. name .. "...")
    
    local url = REPO_BASE .. name .. ".b64"
    local encoded = httpGet(url)
    if not encoded or encoded == "" then 
        warn("[DJ HUB TEST] Failed to download " .. name)
        return nil
    end
    
    print("[DJ HUB TEST] Downloaded: " .. #encoded .. " bytes (base64)")
    print("[DJ HUB TEST] Decoding...")
    
    local ok, decoded = pcall(base64Decode, encoded)
    if not ok then
        warn("[DJ HUB TEST] Decode error: " .. tostring(decoded))
        return nil
    end
    
    if not decoded or #decoded == 0 then
        warn("[DJ HUB TEST] Decode returned empty string")
        return nil
    end
    
    print("[DJ HUB TEST] Decoded: " .. #decoded .. " bytes")
    print("[DJ HUB TEST] Compiling...")
    
    local ok2, chunk = pcall(loadstring, decoded)
    if not ok2 or not chunk then 
        warn("[DJ HUB TEST] Compile error: " .. tostring(chunk))
        return nil
    end
    
    print("[DJ HUB TEST] Executing...")
    local ok3, module = pcall(chunk)
    if not ok3 then 
        warn("[DJ HUB TEST] Execute error: " .. tostring(module))
        return nil
    end
    
    print("[DJ HUB TEST] ✅ " .. name .. " loaded successfully")
    return module
end

-- Load directly from Test repo (no encoding)
local function loadDirectModule(filename)
    print("[DJ HUB TEST] 📥 Loading " .. filename .. " (direct)...")
    local url = TEST_DIRECT .. filename .. "?" .. tick()
    local code = httpGet(url)
    if not code or code == "" then
        warn("[DJ HUB TEST] ❌ Failed to fetch " .. filename)
        return nil
    end
    print("[DJ HUB TEST] 📦 Downloaded " .. #code .. " bytes")
    local ok, chunk = pcall(loadstring, code)
    if not ok or not chunk then
        warn("[DJ HUB TEST] ❌ Compile failed: " .. tostring(chunk))
        return nil
    end
    local ok2, module = pcall(chunk)
    if not ok2 then
        warn("[DJ HUB TEST] ❌ Execute failed: " .. tostring(module))
        return nil
    end
    print("[DJ HUB TEST] ✅ " .. filename .. " loaded")
    return module
end

print("[DJ HUB TEST] Loading The Forge Script...")

local Utils = loadEncodedModule("dj_utils.lua")
if not Utils then 
    warn("[DJ HUB TEST] ❌ Utils failed to load")
else
    print("[DJ HUB TEST] ✅ Utils loaded")
end

local Overlay = loadEncodedModule("dj_overlay.lua")
if Overlay and Overlay.showDiscordProgress then
    Overlay.showDiscordProgress(
        "Loading DJ HUB " .. VERSION .. "\nGame: " .. GAME_NAME,
        6
    )
end

local UIBase = loadEncodedModule("dj_ui_base.lua")
if not UIBase then 
    error("[DJ HUB TEST] ❌ Failed to load UI base") 
    return
end

local Rayfield, Window = UIBase.createWindow()
if not Rayfield or not Window then 
    error("[DJ HUB TEST] ❌ Failed to create window") 
    return
end

local KeyTabReference = nil
local keyVerified = false

local function onKeyVerified()
    keyVerified = true
    task.wait(0.2)
    
    print("[DJ HUB TEST] Loading main tabs...")
    
    local tabs = {
        {"main.lua", "Home", true},
        {"dj_tab_ingame.lua", "Ingame", true},
        {"dj_tab_mining.lua", "Mining", false}, -- Direct from Test repo
        {"dj_tab_monster.lua", "Monster Farm", false}, -- Direct from Test repo  
        {"dj_tab_minigame.lua", "Minigame", false}, -- Direct from Test repo
        {"dj_tab_extras.lua", "Extras", true},
        {"dj_tab_misc.lua", "Misc", true}
    }
    
    for _, tab in ipairs(tabs) do
        local buildTab
        if tab[3] then
            -- Load encoded
            buildTab = loadEncodedModule(tab[1])
        else
            -- Load direct
            buildTab = loadDirectModule(tab[1])
        end
        
        if buildTab then
            local ok, err = pcall(buildTab, Window, Rayfield, Utils)
            if ok then
                print("[DJ HUB TEST] ✅ " .. tab[2] .. " tab loaded")
            else
                warn("[DJ HUB TEST] ❌ " .. tab[2] .. " tab error:", tostring(err))
            end
        end
    end
    
    Rayfield:Notify({
        Title = "DJ HUB TEST Loaded!",
        Content = "The Forge Script ready!",
        Duration = 6
    })
    
    print("[DJ HUB TEST] ✅ The Forge Script loaded successfully!")
end

local buildKey = loadEncodedModule("dj_tab_key.lua")
if buildKey then
    local ok, result = pcall(buildKey, Window, Rayfield, Utils, Config, onKeyVerified)
    if ok and result then
        KeyTabReference = result
    end
else
    warn("[DJ HUB TEST] Key tab failed to load")
    onKeyVerified()
end

print("[DJ HUB TEST] The Forge Script loader complete!")