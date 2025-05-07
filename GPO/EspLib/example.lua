local SimpleESP = loadstring(game:HttpGet("production--skider.netlify.app/GPO/EspLib/source/library.lua"))()

SimpleESP.Enabled = true              -- Master toggle for the entire ESP system
    SimpleESP.TeamCheck = false           -- Whether to show ESP for teammates
    SimpleESP.MaxDistance = 500           -- Maximum distance to render ESP elements (in meters)
    SimpleESP.FontSize = 11               -- Font size for all text elements
    
    -- Category Toggles
    SimpleESP.ShowPlayers = true          -- Whether to show ESP for players
    SimpleESP.ShowMobs = true             -- Whether to show ESP for mobs/enemies
    SimpleESP.ShowNPCs = true             -- Whether to show ESP for NPCs
    
    -- Distance Fade Settings
    SimpleESP.FadeOut.OnDistance = false  -- Whether ESP elements should fade out with distance
    
    -- Player ESP Configuration
    -- Name Tag Settings
    SimpleESP.ESP.Player.Name.Enabled = true
    SimpleESP.ESP.Player.Name.Position = SimpleESP.Position.TOP
    SimpleESP.ESP.Player.Name.RGB = Color3.fromRGB(255, 255, 255)
    SimpleESP.ESP.Player.Name.Offset = 0
    
    -- Distance Display Settings
    SimpleESP.ESP.Player.Distance.Enabled = true
    SimpleESP.ESP.Player.Distance.Position = SimpleESP.Position.BOTTOM
    SimpleESP.ESP.Player.Distance.RGB = Color3.fromRGB(255, 255, 255)
    SimpleESP.ESP.Player.Distance.Offset = 0
    
    -- Weapon Display Settings
    SimpleESP.ESP.Player.Weapon.Enabled = true
    SimpleESP.ESP.Player.Weapon.Position = SimpleESP.Position.BOTTOM
    SimpleESP.ESP.Player.Weapon.RGB = Color3.fromRGB(255, 230, 0)
    SimpleESP.ESP.Player.Weapon.Offset = 8
    
    -- Box Settings
    SimpleESP.ESP.Player.Box.Style = SimpleESP.BoxStyle.CORNERS
    SimpleESP.ESP.Player.Box.RGB = Color3.fromRGB(17, 168, 255)
    SimpleESP.ESP.Player.Box.FilledTransparency = 0.75
    SimpleESP.ESP.Player.Box.FilledRGB = Color3.fromRGB(0, 0, 0)
    
    -- Health Bar Settings
    SimpleESP.ESP.Player.Healthbar.Enabled = true
    SimpleESP.ESP.Player.Healthbar.Position = SimpleESP.Position.LEFT
    SimpleESP.ESP.Player.Healthbar.Offset = 6
    SimpleESP.ESP.Player.Healthbar.Width = 2.5
    
    -- Health Text Settings
    SimpleESP.ESP.Player.Healthbar.HealthText.Enabled = true
    SimpleESP.ESP.Player.Healthbar.HealthText.Position = SimpleESP.Position.LEFT
    SimpleESP.ESP.Player.Healthbar.HealthText.Offset = 0
    SimpleESP.ESP.Player.Healthbar.HealthText.RGB = Color3.fromRGB(255, 255, 255)
    
    -- Health Bar Gradient Settings
    SimpleESP.ESP.Player.Healthbar.Gradient = true
    SimpleESP.ESP.Player.Healthbar.GradientRGB1 = Color3.fromRGB(200, 0, 0)
    SimpleESP.ESP.Player.Healthbar.GradientRGB2 = Color3.fromRGB(60, 60, 125)
    SimpleESP.ESP.Player.Healthbar.GradientRGB3 = Color3.fromRGB(0, 255, 0)
    SimpleESP.ESP.Player.Healthbar.Lerp = true
    
    -- Mob/Enemy ESP Configuration
    -- Name Tag Settings
    SimpleESP.ESP.Mob.Name.Enabled = true
    SimpleESP.ESP.Mob.Name.Position = SimpleESP.Position.TOP
    SimpleESP.ESP.Mob.Name.RGB = Color3.fromRGB(255, 100, 100)
    SimpleESP.ESP.Mob.Name.Offset = 0
    
    -- Distance Display Settings
    SimpleESP.ESP.Mob.Distance.Enabled = true
    SimpleESP.ESP.Mob.Distance.Position = SimpleESP.Position.BOTTOM
    SimpleESP.ESP.Mob.Distance.RGB = Color3.fromRGB(255, 255, 255)
    SimpleESP.ESP.Mob.Distance.Offset = 0
    
    -- Box Settings
    SimpleESP.ESP.Mob.Box.Style = SimpleESP.BoxStyle.CORNERS
    SimpleESP.ESP.Mob.Box.RGB = Color3.fromRGB(255, 100, 100)
    SimpleESP.ESP.Mob.Box.FilledTransparency = 0.75
    SimpleESP.ESP.Mob.Box.FilledRGB = Color3.fromRGB(0, 0, 0)
    
    -- Health Bar Settings
    SimpleESP.ESP.Mob.Healthbar.Enabled = true
    SimpleESP.ESP.Mob.Healthbar.Position = SimpleESP.Position.LEFT
    SimpleESP.ESP.Mob.Healthbar.Offset = 6
    SimpleESP.ESP.Mob.Healthbar.Width = 2.5
    
    -- Health Text Settings
    SimpleESP.ESP.Mob.Healthbar.HealthText.Enabled = true
    SimpleESP.ESP.Mob.Healthbar.HealthText.Position = SimpleESP.Position.LEFT
    SimpleESP.ESP.Mob.Healthbar.HealthText.Offset = 0
    SimpleESP.ESP.Mob.Healthbar.HealthText.RGB = Color3.fromRGB(255, 255, 255)
    
    -- Health Bar Gradient Settings
    SimpleESP.ESP.Mob.Healthbar.Gradient = true
    SimpleESP.ESP.Mob.Healthbar.GradientRGB1 = Color3.fromRGB(200, 0, 0)
    SimpleESP.ESP.Mob.Healthbar.GradientRGB2 = Color3.fromRGB(60, 60, 125)
    SimpleESP.ESP.Mob.Healthbar.GradientRGB3 = Color3.fromRGB(0, 255, 0)
    SimpleESP.ESP.Mob.Healthbar.Lerp = true
    
    -- NPC ESP Configuration
    -- Name Tag Settings
    SimpleESP.ESP.NPC.Name.Enabled = true
    SimpleESP.ESP.NPC.Name.Position = SimpleESP.Position.TOP
    SimpleESP.ESP.NPC.Name.RGB = Color3.fromRGB(0, 255, 100)
    SimpleESP.ESP.NPC.Name.Offset = 0
    
    -- Distance Display Settings
    SimpleESP.ESP.NPC.Distance.Enabled = true
    SimpleESP.ESP.NPC.Distance.Position = SimpleESP.Position.BOTTOM
    SimpleESP.ESP.NPC.Distance.RGB = Color3.fromRGB(255, 255, 255)
    SimpleESP.ESP.NPC.Distance.Offset = 0
    
    -- Box Settings
    SimpleESP.ESP.NPC.Box.Style = SimpleESP.BoxStyle.CORNERS
    SimpleESP.ESP.NPC.Box.RGB = Color3.fromRGB(0, 255, 100)
    SimpleESP.ESP.NPC.Box.FilledTransparency = 0.75
    SimpleESP.ESP.NPC.Box.FilledRGB = Color3.fromRGB(0, 0, 0)
    
    -- Health Bar Settings
    SimpleESP.ESP.NPC.Healthbar.Enabled = true
    SimpleESP.ESP.NPC.Healthbar.Position = SimpleESP.Position.LEFT
    SimpleESP.ESP.NPC.Healthbar.Offset = 6
    SimpleESP.ESP.NPC.Healthbar.Width = 2.5
    
    -- Health Text Settings
    SimpleESP.ESP.NPC.Healthbar.HealthText.Enabled = true
    SimpleESP.ESP.NPC.Healthbar.HealthText.Position = SimpleESP.Position.LEFT
    SimpleESP.ESP.NPC.Healthbar.HealthText.Offset = 0
    SimpleESP.ESP.NPC.Healthbar.HealthText.RGB = Color3.fromRGB(255, 255, 255)
    
    -- Health Bar Gradient Settings
    SimpleESP.ESP.NPC.Healthbar.Gradient = true
    SimpleESP.ESP.NPC.Healthbar.GradientRGB1 = Color3.fromRGB(200, 0, 0)
    SimpleESP.ESP.NPC.Healthbar.GradientRGB2 = Color3.fromRGB(60, 60, 125)
    SimpleESP.ESP.NPC.Healthbar.GradientRGB3 = Color3.fromRGB(0, 255, 0)
    SimpleESP.ESP.NPC.Healthbar.Lerp = true

InitializeESP()  
