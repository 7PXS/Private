Installation 

    Copy the library code above and save it to a file (e.g., KiwiSense.lua) inside your executor's workspace or workspace/KiwiSense. 
    Or paste the code directly into a script if not using external files. 

Basic Usage 
lua
 
  
local Library = loadstring(game:HttpGet("PATH/TO/KiwiSense.lua"))() -- or require()
local Esp = Library()

-- Access Options directly
Esp.Options.Enabled = true
Esp.Options.TeamCheck = false
 
 
 
Configuration Table (Esp.Options) 

You can modify these properties at any time. Changes apply instantly. 

Toggles 

     Enabled (bool): Master toggle for the ESP.
     TeamCheck (bool): Hide teammates.
     

Boxes 

     Boxes (bool): Toggle 2D Boxes.
     BoxType (string): "Box" or "Corner".
     Box Gradient 1/2 (table): { Color = Color3, Transparency = number }.
     Box Gradient Rotation (number).
     Box Fill (bool): Fill the box with background.
     Box Fill 1/2 (table): Gradient colors for the fill.
     Box Fill Rotation (number).
     

Healthbar 

     Healthbar (bool): Toggle health bar.
     Healthbar_Position (string): "Left", "Right", "Top", "Bottom".
     Healthbar_Number (bool): Show HP number text.
     Healthbar_Low/Medium/High (table): Colors for health states.
     Healthbar_Tween (bool): Animate health changes.
     Healthbar_Font (string): Font name (e.g., "Verdana", "UI").
     Healthbar_Thickness (number): Thickness of the bar.
     

Armor Bar 

     ArmorBar (bool): Toggle Armor bar.
     ArmorBar_Color (table): { Color = Color3, Transparency = number }.
     ArmorBar_Background (table): Background color.
     

Text Elements 

     Name_Text, Distance_Text, Weapon_Text (bool): Toggles.
     Name_Text_Position, etc (string): "Top", "Bottom", "Left", "Right".
     Name_Text_Color, etc (table): { Color = Color3 }.
     Name_Text_Font, etc (string): Font name.
     Name_Text_Size, etc (number): Text size.
     

Skeleton 

     Skeleton (bool): Toggle skeleton bones.
     Skeleton_Thickness (number): Thickness of bone lines.
     Skeleton_Transparency (number): 0 (Opaque) to 1 (Invisible).
     Note: Color logic is handled internally (White default, Red if visible).
     

Chams (Highlight) 

     Chams (bool): Toggle 3D Highlight.
     Chams_Fill_Color (table): { Color = Color3, Transparency = number }.
     Chams_Outline_Color (table).
     Chams_Depth_Mode (Enum): Enum.HighlightDepthMode.AlwaysOnTop etc.
     Chams_Animated (bool): "Breathing" animation effect.
     Chams_Anim_Speed (number).
     

Overrides (Esp.Overrides) 

Customize core logic for specific games. You can overwrite these functions. 

Example: Custom Weapon Detection 
lua
 
  
-- Default checks for a part named "Gun"
Esp.Overrides.GetWeapon = function(character, player)
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        return tool.Name
    end
    return "None"
end
 
 
 

Example: Custom Armor Detection 
lua
 
  
Esp.Overrides.GetArmor = function(character, player)
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local armorVal = stats:FindFirstChild("Armor")
        if armorVal then
            return armorVal.Value, 100 -- Value, Max
        end
    end
    return 0, 100
end
 
 
 

Example: Team Check Logic 
lua
 
  
Esp.Overrides.IsTeammate = function(player)
    -- Example: Force team check off for specific players
    if player.Name == "MyFriend" then return false end
    
    -- Default logic
    return player.Team == game.Players.LocalPlayer.Team
end
 
 
 
API Methods 

     Esp:Unload(): Completely removes the ESP, cleans up UI, and stops the loop. Returns nil to the global variable.
     Esp:RemovePlayer(player): Manually remove a specific player from the ESP tracker.
     Esp:AddPlayer(player): Internal use usually, but Esp.CreateObject is the exposed raw method if needed.
     

Visibility Logic 

The library performs Raycasting checks to determine if an enemy is "Visible" (behind a wall).  

     Visible State: Skeleton and Boxes turn Red.
     Hidden State: Skeleton and Boxes remain White (or Team Color).
     The check looks at: Head, Torso, Limbs, Accessories, and custom Workspace parts (Gun, Head, FakeHead) if present in a folder named after the player.
     
