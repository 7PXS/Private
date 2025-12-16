-- Version 2.1
_G.AVOURA_VERSION = _G.AVOURA_VERSION or "release"

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local key = getgenv().AVOURA_KEY

local AUTH_URL = "https://utils32.vercel.app"
local WEBHOOK = "https://discord.com/api/webhooks/1449525733503271023/pSgwXDVwjC8L7FaIq9Z0-45V16kUbSHpKewJojxvF3WXVXdvmikWQTNR7ObJK6aUtWG0"

local Library = loadstring(game:HttpGet("https://production--skider.netlify.app/KiwiSense/Library/Library.lua"))()

local Utils = {}
function Utils.notify(title, desc)
    Library:Notification({
        Name = title, Description = desc, Duration = 4,
        Icon = "116339777575852", IconColor = Color3.fromRGB(52, 255, 164)
    })
end

local marker = ""
print("Avoura " .. marker)

local LoadingLabel = nil
local CurrentProgress = 0.0
local StartTime = os.time() 

local function updateBar(percent, status)
    if LoadingLabel then
        local display = math.min(percent, 100)
        local filled = math.floor(display / 5)
        local bar = ("█"):rep(filled) .. ("░"):rep(20 - filled)
        LoadingLabel.Text = `<font color='rgb(170,110,255)'>[Avoura]</font> <font color='rgb(255,215,0)'>[{bar} {string.format("%.0f", display)}%] {status}</font>`
    end
end

local function setFinalMessage(isSuccess, message)
    if not LoadingLabel then return end
    local color = isSuccess and "rgb(0,255,0)" or "rgb(255,0,0)"
    local prefix = isSuccess and "Successfully loaded" or "Error"
    local elapsed = os.time() - (StartTime or os.time()) 
    local timeDisplay = isSuccess and string.format(" in %ds", elapsed) or ""
    
    LoadingLabel.Text = `<font color='{color}'>[Avoura] {prefix}{timeDisplay}: {message}</font>`
    task.wait(3) 
end

local function advanceBar(targetPercent, status)
    local duration = 0.7 
    repeat task.wait(0.01) until LoadingLabel 
    local startProgress = CurrentProgress
    local t = 0
    while t < duration do
        t = t + task.wait()
        CurrentProgress = startProgress + (targetPercent - startProgress) * (t / duration)
        updateBar(CurrentProgress, status)
    end
    CurrentProgress = targetPercent
    updateBar(targetPercent, status)
end

task.spawn(function()
    local log = CoreGui:WaitForChild("DevConsoleMaster", 5)
    if not log then return end
    log = log:WaitForChild("DevConsoleWindow", 2)
    log = log:WaitForChild("DevConsoleUI", 2)
    log = log:WaitForChild("MainView", 2)
    log = log:WaitForChild("ClientLog", 2)
    if not log then return end

    local function enableRichText(ch)
        if ch:FindFirstChild("msg") then ch.msg.RichText = true end
    end
    for _, v in log:GetChildren() do enableRichText(v) end
    log.ChildAdded:Connect(enableRichText)

    local entry
    repeat task.wait(0.05)
        for _, e in log:GetChildren() do
            if e:FindFirstChild("msg") and e.msg.Text:find(marker, 1, true) then
                entry = e
                break
            end
        end
    until entry
    
    if entry then
        LoadingLabel = entry.msg
        LoadingLabel.RichText = true
    end
end)

repeat task.wait(0.1) until LoadingLabel
updateBar(0, "Initializing...")

local function getHardwareId() 
    local id = RbxAnalyticsService:GetClientId()
    return id or "default_hwid_error" 
end

local function safeAuthRequest(key, hwid, gameId)
    local url = AUTH_URL .. "/auth/v1?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid) .. "&gameId=" .. HttpService:UrlEncode(tostring(gameId))
    local success, res = pcall(function()
        local req = request or http_request or syn.request or http.request
        if req then
            return req({Url = url, Method = "GET", Headers = {["User-Agent"] = "Roblox/WinInet"}})
        end
        return nil
    end)
    
    if not success or not res or not res.Body then 
        return false, success and "Network error: Empty response" or tostring(res) 
    end
    
    local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
    if not decodeSuccess then return false, "Invalid response format" end
    return data.success, data
end

local function generateToken(gameId, playerName, hwid)
    local input = tostring(gameId) .. playerName .. hwid
    local hash = 0
    for i = 1, #input do hash = ((hash * 31) + string.byte(input, i)) % 4294967296 end
    return string.format("%x", hash)
end

local function logToWebhook(successType, successEmoji, titleDesc, color, authInfo)
    local payload = { embeds = {{ title = successType, description = titleDesc or "", color = color }}, username = "Avoura Security" }
    local success, body = pcall(HttpService.JSONEncode, HttpService, payload)
    if not success then return end
    local req = request or http_request or syn.request or http.request
    if req then pcall(function() req({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body}) end) end
end

local function MainLoader()
    local gameId = game.PlaceId
    
    Utils.notify("Loading", "Avoura is starting up...")

    if not key or key == "" then
        logToWebhook("Missing Key", "🔴", "Tried to run without a key", 15158332, nil)
        setFinalMessage(false, "Auth Required: Provide a valid key.")
        player:Kick("Auth Required\n\nProvide a valid key.")
        return
    end

    advanceBar(35, "Authenticating...")

    local hwid = getHardwareId()
    local authOk, authInfo = safeAuthRequest(key, hwid, gameId) 

    if not authOk then
        local errorMsg = authInfo or "Unknown error"
        logToWebhook("Auth Failed", "🔴", errorMsg, 15158332, authInfo)
        setFinalMessage(false, "Authentication Failed: " .. errorMsg)
        player:Kick("Auth Failed\n\n" .. errorMsg)
        return
    end

    local token = generateToken(gameId, player.Name, hwid)
    getgenv().AVOURA_HWID = hwid
    getgenv().AVOURA_KEY = key
    getgenv().AVOURA_TOKEN = token

    logToWebhook("Authenticated", "🟢", "User verified successfully", 3066993, authInfo)

    advanceBar(75, "Fetching script...")

    local scriptSrc = nil
    local fetchUrl = string.format("https://utils32.vercel.app/api/script/%s/%s?token=%s", _G.AVOURA_VERSION, gameId, token)
    local fetchOk, result = pcall(game.HttpGet, game, fetchUrl)

    if fetchOk and result and result ~= "" then
        scriptSrc = result
    else
        logToWebhook("Unsupported Game", "🟡", "No script available", 16776960, authInfo)
        setFinalMessage(false, "Unsupported Game!")
        return
    end

    advanceBar(95, "Executing...")

    local loadOk, loadErr = pcall(loadstring(scriptSrc))

    if not loadOk then
        logToWebhook("Load Error", "🔴", tostring(loadErr), 15158332, authInfo)
        setFinalMessage(false, "Script execution failed: " .. tostring(loadErr))
    else
        logToWebhook("Executed", "🟢", "Script executed successfully", 3447003, authInfo)
        
        advanceBar(100, "Complete!")
        
        setFinalMessage(true, "Script executed successfully.") 
        
        Library:Init()
        Utils.notify("Success", "Avoura is now running!")
    end
end

MainLoader()
