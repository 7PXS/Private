local script_key = getgenv().scriptkey

local gameScripts = {
    [4483381587] = {
        name = "TEst",
        scriptUrl = "https://api.luarmor.net/files/v3/loaders/33b73adf41e86b60864d731dc77f9150.lua"
    }
}

local function loadGameScript()
    if not script_key then
        game.Players.LocalPlayer:Kick("Invalid script key")
        return
    end
    
    local placeId = game.PlaceId
    local scriptData = gameScripts[placeId]
    
    if not scriptData then
        game.Players.LocalPlayer:Kick("No script available for this game")
        return
    end
    
    loadstring(game:HttpGet(scriptData.scriptUrl))(script_key)
end

loadGameScript()
