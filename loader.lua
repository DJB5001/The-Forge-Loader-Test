-- The Forge Loader v1.0
-- Loads from private repository with secure token

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("[THE FORGE] Starting loader...")

-- ============================================
-- CONFIGURATION
-- ============================================

-- YOUR GITHUB PERSONAL ACCESS TOKEN HERE!
-- How to get: GitHub -> Settings -> Developer Settings -> Personal Access Tokens -> Generate New Token
-- Required scope: repo (read access)
local GITHUB_TOKEN = "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"

local REPO_OWNER = "DJB5001"
local REPO_NAME = "The-Forge-Test"  -- TESTING REPO!
local BRANCH = "main"

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to fetch file from private repo
local function getPrivateFile(filePath)
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
        REPO_OWNER,
        REPO_NAME,
        filePath,
        BRANCH
    )
    
    local headers = {
        ["Authorization"] = "Bearer " .. GITHUB_TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw"
    }
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, headers)
    end)
    
    if success then
        print("[LOADER] ✅ Loaded:", filePath)
        return response
    else
        warn("[LOADER] ❌ Failed to load:", filePath)
        warn("[LOADER] Error:", response)
        return nil
    end
end

-- ============================================
-- TOKEN VALIDATION
-- ============================================

if GITHUB_TOKEN == "YOUR_TOKEN_HERE" then
    warn("[THE FORGE] ❌ ERROR: GitHub token not configured!")
    warn("[THE FORGE] Please edit loader.lua and add your Personal Access Token")
    warn("[THE FORGE] Guide: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token")
    return
end

print("[THE FORGE] Token configured ✅")

-- ============================================
-- LOAD FILES FROM PRIVATE REPO
-- ============================================

print("[THE FORGE] Loading files from private repository...")

-- Load utilities
local utilsCode = getPrivateFile("dj_utils.lua")
if not utilsCode then
    warn("[THE FORGE] Failed to load utilities!")
    return
end
local Utils = loadstring(utilsCode)()

-- Load UI Base
local uiBaseCode = getPrivateFile("dj_ui_base.lua")
if not uiBaseCode then
    warn("[THE FORGE] Failed to load UI base!")
    return
end
local UIBase = loadstring(uiBaseCode)()

-- Load UI Wrapper
local uiWrapperCode = getPrivateFile("dj_ui_wrapper.lua")
if not uiWrapperCode then
    warn("[THE FORGE] Failed to load UI wrapper!")
    return
end
local UIWrapper = loadstring(uiWrapperCode)()

-- Load Main (Home Tab)
local mainCode = getPrivateFile("main.lua")
if not mainCode then
    warn("[THE FORGE] Failed to load main!")
    return
end
local MainTab = loadstring(mainCode)()

-- Load Ingame Tab
local ingameCode = getPrivateFile("dj_tab_ingame.lua")
if not ingameCode then
    warn("[THE FORGE] Failed to load ingame tab!")
    return
end
local IngameTab = loadstring(ingameCode)()

-- Load Mining Tab
local miningCode = getPrivateFile("dj_tab_mining.lua")
if not miningCode then
    warn("[THE FORGE] Failed to load mining tab!")
    return
end
local MiningTab = loadstring(miningCode)()

-- Load Monster Tab
local monsterCode = getPrivateFile("dj_tab_monster.lua")
if not monsterCode then
    warn("[THE FORGE] Failed to load monster tab!")
    return
end
local MonsterTab = loadstring(monsterCode)()

-- Load Minigame Tab
local minigameCode = getPrivateFile("dj_tab_minigame.lua")
if not minigameCode then
    warn("[THE FORGE] Failed to load minigame tab!")
    return
end
local MinigameTab = loadstring(minigameCode)()

-- Load Extras Tab (Auto Sell)
local extrasCode = getPrivateFile("dj_tab_extras.lua")
if not extrasCode then
    warn("[THE FORGE] Failed to load extras tab!")
    return
end
local ExtrasTab = loadstring(extrasCode)()

-- Load Misc Tab
local miscCode = getPrivateFile("dj_tab_misc.lua")
if not miscCode then
    warn("[THE FORGE] Failed to load misc tab!")
    return
end
local MiscTab = loadstring(miscCode)()

print("[THE FORGE] ✅ All files loaded successfully!")

-- ============================================
-- INITIALIZE UI
-- ============================================

print("[THE FORGE] Initializing UI...")

-- Get Rayfield from UI Base
local Rayfield = UIBase()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🔥 The Forge Hub 🔥",
    LoadingTitle = "DJ HUB",
    LoadingSubtitle = "by DJB5001",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DJHub_TheForge",
        FileName = "TheForge_Config"
    },
    Discord = {
        Enabled = true,
        Invite = "MTXnFfHXW9",
        RememberJoins = true
    },
    KeySystem = false
})

print("[THE FORGE] Window created ✅")

-- ============================================
-- LOAD ALL TABS
-- ============================================

print("[THE FORGE] Loading tabs...")

-- Home Tab
MainTab(Window, Rayfield, Utils)

-- Ingame Tab
IngameTab(Window, Rayfield, Utils)

-- Mining Tab
MiningTab(Window, Rayfield, Utils)

-- Monster Tab
MonsterTab(Window, Rayfield, Utils)

-- Minigame Tab
MinigameTab(Window, Rayfield, Utils)

-- Extras Tab (Auto Sell)
ExtrasTab(Window, Rayfield, Utils)

-- Misc Tab
MiscTab(Window, Rayfield, Utils)

print("[THE FORGE] ✅ All tabs loaded!")
print("[THE FORGE] 🔥 The Forge Hub is ready! 🔥")

-- Notification
Rayfield:Notify({
    Title = "The Forge Hub",
    Content = "Loaded successfully from private repo! 🔥",
    Duration = 5,
    Image = 4483362458
})
