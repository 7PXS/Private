-- Avoura Loader v1.0
-- Check out https://avoura.dev for more info

print("Avoura Loader starting up...")

_G.AVOURA_VERSION = "alpha"  -- temp version, update later

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer

-- Default key for testing, users should override this
getgenv().AVOURA_KEY = "test-key-123456"
local key = getgenv().AVOURA_KEY

local AUTH_URL = "https://utils32.vercel.app"
local WEBHOOK = "https://discord.com/api/webhooks/1448466396030697522/OXfbCUN42gCHyelVFE2lO5ObQ7CvFLTcf6Yvy4OmFm7emyC3rKzDU-TVe11u_fZcx2Os"

-- Load the UI lib
local Library = loadstring(game:HttpGet("https://production--skider.netlify.app/KiwiSense/Library/Library.lua"))()

local Utils = {}

-- Custom notify func with fixed style
function Utils.notify(title, desc)
    Library:Notification({
        Name = title,
        Description = desc,
        Duration = 4,
        Icon = "116339777575852",
        IconColor = Color3.fromRGB(52, 255, 164)
    })
end

-- Grab hardware ID from analytics
local function getHardwareId()
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

-- Detect the executor if possible
local function getExecutorName()
    local ok, name = pcall(identifyexecutor)
    return ok and name or "Unknown"
end

-- Format current date and time with UTC offset
local function getTimestamp()
    local dt = os.date("*t")
    local tz = os.date("%z")
    return string.format("%02d/%02d/%04d %02d:%02d:%02d (UTC%s)",
        dt.month, dt.day, dt.year,
        dt.hour, dt.min, dt.sec,
        tz:sub(1,3) .. ":" .. tz:sub(4,5))
end

local hs = game:GetService("HttpService")
local mps = game:GetService("MarketplaceService")

-- Cache game info early to avoid repeated calls
local gameId = game.PlaceId
local gameName
pcall(function()
    gameName = mps:GetProductInfo(gameId).Name
end)
gameName = gameName or "Unknown Game"

print("Place ID:", gameId)

-- Log events to Discord via webhook
local function logToWebhook(title, desc, fields, color)
    local embed = {
        title = title,
        description = desc,
        color = color or 16711680,
        fields = fields,
        footer = { text = "Avoura Auth • " .. getTimestamp() },
        thumbnail = { url = "https://cdn.discordapp.com/icons/1404649365263356015/b55a8de3b2eaf52740b520d5cb3e0b25.webp?size=1024" }
    }

    local payload = {
        embeds = { embed },
        username = "Avoura Security",
        avatar_url = "https://cdn.discordapp.com/icons/1404649365263356015/b55a8de3b2eaf52740b520d5cb3e0b25.webp?size=1024"
    }

    local headers = { ["Content-Type"] = "application/json" }
    local body = hs:JSONEncode(payload)

    pcall(function()
        request({
            Url = WEBHOOK,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
end

-- Authenticate against the server
local function authRequest(key, hwid, gameId)
    local url = string.format("%s/auth/v1?key=%s&hwid=%s&gameId=%s",
        AUTH_URL,
        hs:UrlEncode(key),
        hs:UrlEncode(hwid),
        hs:UrlEncode(tostring(gameId)))

    local ok, res = pcall(function()
        return request({
            Url = url,
            Method = "GET",
            Headers = { ["User-Agent"] = "Roblox/WinInet" }
        })
    end)

    if not ok then
        return false, "Couldn't reach auth server"
    end

    local data = hs:JSONDecode(res.Body)
    return data.success, data
end

-- Quick check for missing key
if not key or key == "" then
    Utils.notify("Auth Error", "Missing script key! Need a valid one to proceed.")

    local logFields = {
        { name = "Type", value = "Missing Key", inline = true },
        { name = "HWID", value = "`" .. getHardwareId() .. "`", inline = true },
        { name = "Executor", value = getExecutorName(), inline = true },
        { name = "Game", value = gameName, inline = true },
        { name = "Game ID", value = "`" .. tostring(gameId) .. "`", inline = true },
        { name = "Player", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true }
    }

    logToWebhook("Missing Key Alert", "Tried to run without a key", logFields, 15158332)

    wait(3)
    player:Kick("Auth Required\n\nProvide a valid key.")
    return
end

-- Get HWID and try auth
local hwid = getHardwareId()
local authOk, authInfo = authRequest(key, hwid, gameId)

if not authOk then
    Utils.notify("Auth Failed", authInfo.error or "Invalid key or sub expired.")

    local logFields = {
        { name = "Type", value = "Auth Failed", inline = true },
        { name = "Key", value = "`" .. key:sub(1, 8) .. "...`", inline = true },
        { name = "HWID", value = "`" .. hwid .. "`", inline = true },
        { name = "Error", value = authInfo.error or "Unknown", inline = false },
        { name = "Executor", value = getExecutorName(), inline = true },
        { name = "Game", value = gameName, inline = true },
        { name = "Player", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true }
    }

    logToWebhook("Auth Failed", "Rejected auth attempt", logFields, 15158332)

    wait(3)
    player:Kick("Auth Failed\n\n" .. (authInfo.error or "Key invalid or expired."))
    return
end

-- Simple hash to generate unique token per player/game/hwid combo
local function generateToken(gameId, playerName, hwid)
    local input = tostring(gameId) .. playerName .. hwid
    local hashVal = 0
    for i = 1, #input do
        local byte = string.byte(input, i)
        hashVal = ((hashVal * 31) + byte) % 4294967296
    end
    return string.format("%x", hashVal)
end

-- Gen and save token, plus other globals
local token = generateToken(gameId, player.Name, hwid)
getgenv().AVOURA_HWID = hwid
getgenv().AVOURA_KEY = key
getgenv().AVOURA_TOKEN = token

-- Calc sub status
local daysLeft = math.floor((authInfo.endTime - os.time()) / 86400)
local subStatus = daysLeft <= 3 and "Critical" or daysLeft <= 7 and "Warning" or "Active"

Utils.notify("Auth Success", "Welcome back, " .. authInfo.username .. "!")

-- Log the successful auth
local authLog = {
    { name = "Status", value = "Authenticated", inline = true },
    { name = "Username", value = authInfo.username, inline = true },
    { name = "Discord ID", value = "`" .. authInfo.discordId .. "`", inline = true },
    { name = "Key", value = "`" .. key:sub(1, 8) .. "...`", inline = true },
    { name = "HWID", value = "`" .. hwid .. "`", inline = true },
    { name = "Sub", value = subStatus .. " - " .. daysLeft .. " days", inline = true },
    { name = "Executor", value = getExecutorName(), inline = true },
    { name = "Game", value = gameName, inline = true },
    { name = "Player", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true }
}

logToWebhook("Auth Success", "User verified", authLog, 3066993)

-- Pull the actual script from server
local function getGameScript()
    local version = _G.AVOURA_VERSION
    local url = string.format("https://utils32.vercel.app/api/script/%s/%s?token=%s", version, tostring(gameId), token)  -- using token here for logging

    print("Fetching script for game " .. gameId)

    local ok, content = pcall(game.HttpGet, game, url)
    return ok and content or nil
end

Utils.notify("Loading", "Grabbing script for this game...")

local scriptSrc = getGameScript()

if not scriptSrc then
    Utils.notify("No Support", "No script for game ID: " .. tostring(gameId))

    local unsupLog = {
        { name = "Type", value = "Unsupported Game", inline = true },
        { name = "Username", value = authInfo.username, inline = true },
        { name = "Key", value = "`" .. key:sub(1, 8) .. "...`", inline = true },
        { name = "HWID", value = "`" .. hwid .. "`", inline = true },
        { name = "Executor", value = getExecutorName(), inline = true },
        { name = "Game", value = gameName, inline = true },
        { name = "Game ID", value = "`" .. tostring(gameId) .. "`", inline = true },
        { name = "Player", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true }
    }

    logToWebhook("Unsupported Game", "Tried unsupported game", unsupLog, 16776960)
    return  -- just bail, no kick
end

-- Run the fetched script
local loadOk, err = pcall(loadstring(scriptSrc))

if not loadOk then
    Utils.notify("Load Error", "Couldn't load script: " .. tostring(err))

    local errLog = {
        { name = "Type", value = "Load Error", inline = true },
        { name = "Username", value = authInfo.username, inline = true },
        { name = "Key", value = "`" .. key:sub(1, 8) .. "...`", inline = true },
        { name = "HWID", value = "`" .. hwid .. "`", inline = true },
        { name = "Executor", value = getExecutorName(), inline = true },
        { name = "Game", value = gameName, inline = true },
        { name = "Game ID", value = "`" .. tostring(gameId) .. "`", inline = true },
        { name = "Player", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true },
        { name = "Error", value = "```" .. tostring(err):sub(1, 500) .. "```", inline = false }
    }

    logToWebhook("Script Error", "Load failed", errLog, 15158332)
else
    Utils.notify("Loaded", "Avoura is up and running!")

    local execLog = {
        { name = "Status", value = "Executed", inline = true },
        { name = "Username", value = authInfo.username, inline = true },
        { name = "Key", value = "`" .. key:sub(1, 8) .. "...`", inline = true },
        { name = "HWID", value = "`" .. hwid .. "`", inline = true },
        { name = "Days Left", value = daysLeft .. " days", inline = true },
        { name = "Executor", value = getExecutorName(), inline = true },
        { name = "Game", value = gameName, inline = true },
        { name = "Player", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true }
    }

    logToWebhook("Script Ran", "Loaded and executed fine", execLog, 3447003)
end

-- Init lib last for autoload
Library:Init()
