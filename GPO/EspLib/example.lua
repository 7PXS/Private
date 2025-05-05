local SimpleESP = loadstring(game:HttpGet("production--skider.netlify.app/GPO/EspLib/source/library.lua"))()

SimpleESP.Enabled = true        
SimpleESP.TeamCheck = false     
SimpleESP.MaxDistance = 1000    
SimpleESP.FontSize = 13         
SimpleESP.ShowPlayers = true    
SimpleESP.ShowMobs = true       
SimpleESP.ShowNPCs = true       

SimpleESP.Drawing.Names.RGB = Color3.fromRGB(0, 255, 255)      
SimpleESP.Drawing.Boxes.Full.RGB = Color3.fromRGB(255, 0, 255) 

SimpleESP.Drawing.Healthbar.Width = 3           
SimpleESP.Drawing.Healthbar.Gradient = true     
SimpleESP.Drawing.Healthbar.GradientRGB1 = Color3.fromRGB(255, 0, 0)   
SimpleESP.Drawing.Healthbar.GradientRGB2 = Color3.fromRGB(255, 255, 0) 
SimpleESP.Drawing.Healthbar.GradientRGB3 = Color3.fromRGB(0, 255, 0)   

SimpleESP.Drawing.MobInfo.RGB = Color3.fromRGB(255, 150, 0)   
SimpleESP.Drawing.NPCInfo.RGB = Color3.fromRGB(0, 255, 150)   

SimpleESP.FadeOut.OnDistance = true

local function cleanupESP()
    SimpleESP:CleanUp()

    if game:GetService("CoreGui"):FindFirstChild("ESP_Controls") then
        game:GetService("CoreGui").ESP_Controls:Destroy()
    end
end

InitializeESP()  
