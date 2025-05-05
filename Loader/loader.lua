local player = game.Players.LocalPlayer
local script_key = getgenv().scriptkey
local repo = "https://production--skider.netlify.app/ObsidianUI/Source/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local function gethwid()

    return game:GetService("RbxAnalyticsService"):GetClientId()
end

local function getExecutor()
    local success, executor = pcall(identifyexecutor)
    return success and executor or "Unknown"
end

local function getDateTime()
    local date = os.date("*t")
    local timezone = os.date("%z")
    return string.format("%02d/%02d/%04d %02d:%02d:%02d (UTC%s)", 
        date.month, date.day, date.year, 
        date.hour, date.min, date.sec, 
        timezone:sub(1,3) .. ":" .. timezone:sub(4,5))
end

local function sendDiscordEmbed(title, description, fields)
    local url = "https://discord.com/api/webhooks/1334681587308040202/uxj_MahNb_Pj5Yxph-qNNa_xwva9vNVrOdc3QWVkFVzc1vJP2P3UyRSUQy7v5QsqB9jY"

    local embed = {
        ["title"] = title,
        ["description"] = description,
        ["color"] = 16711680, 
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = "Alert Time: " .. getDateTime()
        }
    }

    local data = {
        ["embeds"] = {embed}
    }

    local headers = {
        ["Content-Type"] = "application/json"
    }

    local body = game:GetService("HttpService"):JSONEncode(data)

    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
end

local function sendNotification(title, description, type)
    local typeColors = {
        success = "43,255,112",
        info = "71,177,255",
        warning = "255,203,107",
        error = "255,129,129"
    }

    local color = typeColors[type or "info"]
    local formattedTitle = string.format("<font color='rgb(%s)'><b>%s</b></font>", color, title)
    local formattedDesc = string.format("<font color='rgb(220,220,220)'>%s</font>", description)

    Library:Notify({
        Title = formattedTitle,
        Description = formattedDesc,
        Time = 5,
    })
end

local gameScripts = {
    [8941319767] = {
        Name = "Ghoul Re",
        Url = "https://api.luarmor.net/files/v3/loaders/33b73adf41e86b60864d731dc77f9150.lua"
    },

    [6284881984] = {
        Name = "Anime Maina",
        Url = "https://api.luarmor.net/files/v3/loaders/8f41814e63c105bb37d501fd27d5d28e.lua"
    },

    [15646364136] = {
        Name = "Absolvement",
        Url = "https://api.luarmor.net/files/v3/loaders/5ee3abb5d44c7a1669fd8a94ccf5f911.lua"
    }
}

print("Game Place ID:", game.PlaceId)

if not script_key or script_key == "" then
    sendNotification("Authentication Error", "Script key is missing! Please enter a valid key.", "error")

    local fields = {
        {["name"] = "Alert Type", ["value"] = "Missing Script Key", ["inline"] = true},
        {["name"] = "HWID", ["value"] = gethwid(), ["inline"] = true},
        {["name"] = "Executor", ["value"] = getExecutor(), ["inline"] = true},
        {["name"] = "Game", ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, ["inline"] = true},
        {["name"] = "Game ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
        {["name"] = "Player ID", ["value"] = tostring(player.UserId), ["inline"] = true},
        {["name"] = "Player Name", ["value"] = player.Name, ["inline"] = true},
        {["name"] = "Display Name", ["value"] = player.DisplayName, ["inline"] = true}
    }

    sendDiscordEmbed("Missing Script Key Alert", "A user attempted to use the script without providing a key", fields)

    wait(3) 
    player:Kick("Enter Key Please")

    return
end

local placeId = game.PlaceId
local scriptData = gameScripts[placeId]

if not scriptData then
    sendNotification("Incompatible Game", "No script available for this game ID: " .. tostring(placeId), "warning")

    local gameName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end) and 
                    game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"

    local fields = {
        {["name"] = "Alert Type", ["value"] = "Unsupported Game", ["inline"] = true},
        {["name"] = "Script Key", ["value"] = script_key, ["inline"] = true},
        {["name"] = "HWID", ["value"] = gethwid(), ["inline"] = true},
        {["name"] = "Executor", ["value"] = getExecutor(), ["inline"] = true},
        {["name"] = "Game", ["value"] = gameName, ["inline"] = true},
        {["name"] = "Game ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
        {["name"] = "Player ID", ["value"] = tostring(player.UserId), ["inline"] = true},
        {["name"] = "Player Name", ["value"] = player.Name, ["inline"] = true},
        {["name"] = "Display Name", ["value"] = player.DisplayName, ["inline"] = true}
    }

    sendDiscordEmbed("Unsupported Game Alert", "A user attempted to use the script in an unsupported game", fields)

    wait(3) 
    player:Kick("Game not supported")

    return 
end

sendNotification("Game Detected", "Loading script for <font color='rgb(255,255,150)'>" .. scriptData.Name .. "</font>", "success")

getgenv().script_key = script_key

local success, result = pcall(function()
    return loadstring(game:HttpGet(scriptData.Url))()
end)

if not success then
    sendNotification("Script Error", "Failed to load script: " .. tostring(result), "error")

    local fields = {
        {["name"] = "Alert Type", ["value"] = "Script Load Error", ["inline"] = true},
        {["name"] = "Script Key", ["value"] = script_key, ["inline"] = true},
        {["name"] = "HWID", ["value"] = gethwid(), ["inline"] = true},
        {["name"] = "Executor", ["value"] = getExecutor(), ["inline"] = true},
        {["name"] = "Game", ["value"] = scriptData.Name, ["inline"] = true},
        {["name"] = "Game ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
        {["name"] = "Player ID", ["value"] = tostring(player.UserId), ["inline"] = true},
        {["name"] = "Player Name", ["value"] = player.Name, ["inline"] = true},
        {["name"] = "Display Name", ["value"] = player.DisplayName, ["inline"] = true},
        {["name"] = "Error", ["value"] = tostring(result), ["inline"] = false}
    }

    sendDiscordEmbed("Script Error Alert", "An error occurred while loading the script", fields)
else
    sendNotification("Script Loaded", scriptData.Name .. " has been successfully loaded!", "success")
end
