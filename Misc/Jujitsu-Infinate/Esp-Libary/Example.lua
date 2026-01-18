-- Load the ESP library
local SimpleESP = loadstring(game:HttpGet("https://production--skider.netlify.app/Jujitsu-Infinate/Esp-Libary/Source/Library.lua"))()

-- Wait for game and character to load
repeat wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
repeat wait() until LocalPlayer.Character

-- Enable ESP
SimpleESP.Enabled = true

-- Settings
SimpleESP.Settings.MaxDistance = 2000
SimpleESP.Settings.FontSize = 12
SimpleESP.Settings.RefreshRate = 0
SimpleESP.Settings.FadeOut.OnDistance = true
SimpleESP.Settings.BoxScaleFactor = 0.7

-- Players
SimpleESP.Players.Enabled = true
SimpleESP.Players.ShowName = true
SimpleESP.Players.ShowLevel = true
SimpleESP.Players.ShowDistance = true
SimpleESP.Players.ShowChams = true
SimpleESP.Players.ShowHealthbar = true
SimpleESP.Players.TeamCheck = false
SimpleESP.Players.Color = Color3.fromRGB(255, 100, 100)
SimpleESP.Players.NameColor = Color3.fromRGB(255, 100, 100)
SimpleESP.Players.LevelColor = Color3.fromRGB(255, 255, 255)
SimpleESP.Players.DistanceColor = Color3.fromRGB(200, 200, 200)
SimpleESP.Players.ChamsColor = Color3.fromRGB(255, 100, 100)
SimpleESP.Players.ChamsOutlineColor = Color3.fromRGB(255, 0, 0)
SimpleESP.Players.ChamsFillTransparency = 0.5
SimpleESP.Players.ChamsOutlineTransparency = 0
SimpleESP.Players.HealthbarOutlineColor = Color3.fromRGB(0, 0, 0)
SimpleESP.Players.HealthGradient = true
SimpleESP.Players.HealthColors.High = Color3.fromRGB(0, 255, 0)
SimpleESP.Players.HealthColors.Mid = Color3.fromRGB(255, 255, 0)
SimpleESP.Players.HealthColors.Low = Color3.fromRGB(255, 0, 0)

-- Mobs
SimpleESP.Mobs.Enabled = true
SimpleESP.Mobs.ShowName = true
SimpleESP.Mobs.ShowDistance = true
SimpleESP.Mobs.ShowHealthbar = true
SimpleESP.Mobs.ShowChams = true
SimpleESP.Mobs.Color = Color3.fromRGB(255, 100, 100)
SimpleESP.Mobs.NameColor = Color3.fromRGB(255, 100, 100)
SimpleESP.Mobs.DistanceColor = Color3.fromRGB(200, 200, 200)
SimpleESP.Mobs.ChamsColor = Color3.fromRGB(255, 100, 100)
SimpleESP.Mobs.ChamsOutlineColor = Color3.fromRGB(255, 0, 0)
SimpleESP.Mobs.ChamsFillTransparency = 0.5
SimpleESP.Mobs.ChamsOutlineTransparency = 0
SimpleESP.Mobs.HealthbarOutlineColor = Color3.fromRGB(0, 0, 0)
SimpleESP.Mobs.HealthGradient = true
SimpleESP.Mobs.HealthColors.High = Color3.fromRGB(0, 255, 0)
SimpleESP.Mobs.HealthColors.Mid = Color3.fromRGB(255, 255, 0)
SimpleESP.Mobs.HealthColors.Low = Color3.fromRGB(255, 0, 0)

-- Items
SimpleESP.Items.Enabled = true
SimpleESP.Items.ShowName = true
SimpleESP.Items.ShowDistance = true
SimpleESP.Items.ShowChams = true
SimpleESP.Items.Color = Color3.fromRGB(255, 255, 100)
SimpleESP.Items.NameColor = Color3.fromRGB(255, 255, 100)
SimpleESP.Items.DistanceColor = Color3.fromRGB(200, 200, 200)
SimpleESP.Items.ChamsColor = Color3.fromRGB(255, 255, 100)
SimpleESP.Items.ChamsOutlineColor = Color3.fromRGB(255, 200, 0)
SimpleESP.Items.ChamsFillTransparency = 0.5
SimpleESP.Items.ChamsOutlineTransparency = 0
SimpleESP.Items.MaxDistance = 500

-- Initialize ESP
SimpleESP:Initialize()
