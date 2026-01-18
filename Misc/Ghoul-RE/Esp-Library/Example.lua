local SimpleESP = loadstring(game:HttpGet("https://production--skider.netlify.app/Ghoul-RE/Esp-Library/Source/Library.lua"))()

repeat wait() until game:IsLoaded()


SimpleESP.Enabled = true 
SimpleESP.TeamCheck = false  
SimpleESP.MaxDistance = 1000  
SimpleESP.FontSize = 12  

SimpleESP.FadeOut.OnDistance = true  

SimpleESP.Drawing.Names.Enabled = true
SimpleESP.Drawing.Names.RGB = Color3.fromRGB(255, 255, 0)  

SimpleESP.Drawing.Distances.Enabled = true
SimpleESP.Drawing.Distances.RGB = Color3.fromRGB(200, 200, 200)  

SimpleESP.Drawing.Healthbar.Enabled = true
SimpleESP.Drawing.Healthbar.HealthText = true
SimpleESP.Drawing.Healthbar.Lerp = true
SimpleESP.Drawing.Healthbar.Width = 3
SimpleESP.Drawing.Healthbar.Gradient = true
SimpleESP.Drawing.Healthbar.GradientRGB1 = Color3.fromRGB(255, 0, 0) 
SimpleESP.Drawing.Healthbar.GradientRGB2 = Color3.fromRGB(255, 255, 0)  
SimpleESP.Drawing.Healthbar.GradientRGB3 = Color3.fromRGB(0, 255, 0) 

SimpleESP.Drawing.Boxes.Filled.Enabled = true
SimpleESP.Drawing.Boxes.Filled.Transparency = 0.2
SimpleESP.Drawing.Boxes.Filled.RGB = Color3.fromRGB(0, 0, 0)

SimpleESP.Drawing.Boxes.Full.Enabled = true
SimpleESP.Drawing.Boxes.Full.RGB = Color3.fromRGB(0, 170, 255)  
