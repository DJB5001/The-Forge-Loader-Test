-- The Forge Private Loader
-- Loads loader.lua from private repository

local HttpService = game:GetService("HttpService")

print("[THE FORGE] Private Loader Starting...")

-- Configuration
local GITHUB_TOKEN = "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"
local REPO_OWNER = "DJB5001"
local REPO_NAME = "The-Forge-Test"
local BRANCH = "main"
local FILE = "loader.lua"

-- Fetch file from private repo
local function getPrivateFile(path)
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
        REPO_OWNER,
        REPO_NAME,
        path,
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
    print("[THE FORGE] ✅ Loaded successfully!")
end
