local SimpleESP = loadstring(game:HttpGet("https://production--skider.netlify.app/GPO/EspLib/source/library.lua"))()

-- Wait for game and character to load
repeat wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
repeat wait() until LocalPlayer.Character

-- Master toggle for ESP
SimpleESP.Enabled = true

-- Basic settings
SimpleESP.MaxDistance = 2000
SimpleESP.FontSize = 13
SimpleESP.TeamCheck = false -- Don't filter by team

-- Configure fade out settings
SimpleESP.FadeOut = {
    OnDistance = true
}

-- Configure what types to show
SimpleESP.ShowPlayers = true
SimpleESP.ShowMobs = true
SimpleESP.ShowNPCs = true

-- Player ESP settings
SimpleESP.ESP.Player.Name.Enabled = true
SimpleESP.ESP.Player.Name.Position = SimpleESP.Position.TOP
SimpleESP.ESP.Player.Name.RGB = Color3.fromRGB(255, 255, 255)
SimpleESP.ESP.Player.Name.Offset = 0

SimpleESP.ESP.Player.Distance.Enabled = true
SimpleESP.ESP.Player.Distance.Position = SimpleESP.Position.BOTTOM
SimpleESP.ESP.Player.Distance.RGB = Color3.fromRGB(200, 200, 200)
SimpleESP.ESP.Player.Distance.Offset = 0

SimpleESP.ESP.Player.Weapon.Enabled = true
SimpleESP.ESP.Player.Weapon.Position = SimpleESP.Position.BOTTOM
SimpleESP.ESP.Player.Weapon.RGB = Color3.fromRGB(255, 230, 0)
SimpleESP.ESP.Player.Weapon.Offset = 15

-- Box settings
SimpleESP.ESP.Player.Box.Style = SimpleESP.BoxStyle.CORNERS -- Options: NONE, FULL, CORNERS, FILLED
SimpleESP.ESP.Player.Box.RGB = Color3.fromRGB(17, 168, 255)
SimpleESP.ESP.Player.Box.FilledTransparency = 0.75
SimpleESP.ESP.Player.Box.FilledRGB = Color3.fromRGB(0, 0, 0)

-- Health bar settings
SimpleESP.ESP.Player.Healthbar.Enabled = true
SimpleESP.ESP.Player.Healthbar.Position = SimpleESP.Position.LEFT
SimpleESP.ESP.Player.Healthbar.Offset = 6
SimpleESP.ESP.Player.Healthbar.Width = 2.5

-- Health text settings
SimpleESP.ESP.Player.Healthbar.HealthText.Enabled = true
SimpleESP.ESP.Player.Healthbar.HealthText.Position = SimpleESP.Position.LEFT
SimpleESP.ESP.Player.Healthbar.HealthText.RGB = Color3.fromRGB(255, 255, 255)
SimpleESP.ESP.Player.Healthbar.HealthText.Offset = 0

-- Health gradient
SimpleESP.ESP.Player.Healthbar.Gradient = true
SimpleESP.ESP.Player.Healthbar.GradientRGB1 = Color3.fromRGB(200, 0, 0)    -- Low health
SimpleESP.ESP.Player.Healthbar.GradientRGB2 = Color3.fromRGB(60, 60, 125)  -- Mid health
SimpleESP.ESP.Player.Healthbar.GradientRGB3 = Color3.fromRGB(0, 255, 0)    -- High health

-- Mob ESP settings
SimpleESP.ESP.Mob.Name.Enabled = true
SimpleESP.ESP.Mob.Name.Position = SimpleESP.Position.TOP
SimpleESP.ESP.Mob.Name.RGB = Color3.fromRGB(255, 100, 100)
SimpleESP.ESP.Mob.Name.Offset = 0

SimpleESP.ESP.Mob.Distance.Enabled = true
SimpleESP.ESP.Mob.Distance.Position = SimpleESP.Position.BOTTOM
SimpleESP.ESP.Mob.Distance.RGB = Color3.fromRGB(200, 200, 200)
SimpleESP.ESP.Mob.Distance.Offset = 0

SimpleESP.ESP.Mob.Box.Style = SimpleESP.BoxStyle.CORNERS
SimpleESP.ESP.Mob.Box.RGB = Color3.fromRGB(255, 100, 100)
SimpleESP.ESP.Mob.Box.FilledTransparency = 0.75
SimpleESP.ESP.Mob.Box.FilledRGB = Color3.fromRGB(0, 0, 0)

SimpleESP.ESP.Mob.Healthbar.Enabled = true
SimpleESP.ESP.Mob.Healthbar.Position = SimpleESP.Position.LEFT
SimpleESP.ESP.Mob.Healthbar.Offset = 6
SimpleESP.ESP.Mob.Healthbar.Width = 2.5

-- NPC ESP settings
SimpleESP.ESP.NPC.Name.Enabled = true
SimpleESP.ESP.NPC.Name.Position = SimpleESP.Position.TOP
SimpleESP.ESP.NPC.Name.RGB = Color3.fromRGB(0, 255, 100)
SimpleESP.ESP.NPC.Name.Offset = 0

SimpleESP.ESP.NPC.Distance.Enabled = true
SimpleESP.ESP.NPC.Distance.Position = SimpleESP.Position.BOTTOM
SimpleESP.ESP.NPC.Distance.RGB = Color3.fromRGB(200, 200, 200)
SimpleESP.ESP.NPC.Distance.Offset = 0
