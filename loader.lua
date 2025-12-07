-- The Forge Loader v2.0
-- Loads complete loader.lua from private repository

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("[THE FORGE LOADER] Starting...")

-- ============================================
-- CONFIGURATION
-- ============================================

-- YOUR GITHUB PERSONAL ACCESS TOKEN HERE!
local GITHUB_TOKEN = "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"

local REPO_OWNER = "DJB5001"
local REPO_NAME = "The-Forge-Test"  -- TESTING REPO!
local BRANCH = "main"
local LOADER_FILE = "loader.lua"  -- Main loader file to execute

-- ============================================
-- HELPER FUNCTION
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
    warn("[THE FORGE LOADER] ❌ ERROR: GitHub token not configured!")
    warn("[THE FORGE LOADER] Please edit loader.lua and add your Personal Access Token")
    return
end

print("[THE FORGE LOADER] Token configured ✅")

-- ============================================
-- LOAD MAIN LOADER FROM PRIVATE REPO
-- ============================================

print("[THE FORGE LOADER] Loading main loader from private repository...")

local loaderCode = getPrivateFile(LOADER_FILE)
if not loaderCode then
    warn("[THE FORGE LOADER] Failed to load main loader!")
    warn("[THE FORGE LOADER] Make sure", LOADER_FILE, "exists in", REPO_NAME)
    return
end

print("[THE FORGE LOADER] ✅ Main loader loaded successfully!")
print("[THE FORGE LOADER] Executing...")

-- Execute the main loader
local success, err = pcall(function()
    loadstring(loaderCode)()
end)

if not success then
    warn("[THE FORGE LOADER] ❌ Error executing loader:")
    warn(err)
else
    print("[THE FORGE LOADER] ✅ Loader executed successfully!")
end
