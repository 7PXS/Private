local Library = loadstring(game:HttpGet("https://production--skider.netlify.app/celestial.club/Source/Library.lua"))()
local Window = Library:Window({Name = "celestial.club"});

local Tabs = {}; do
    Tabs.Combat = Window:Tab({Name = "Combat"});
    Tabs.Misc = Window:Tab({Name = "Misc"});
    Tabs.Visuals = Window:Tab({Name = "Visuals"});
end

Library:Watermark({Name = "celestial"})
Library:KeybindList();


local Sections = {}; do
    Sections.Aimbot = Tabs.Combat:Section({Name = "Aimbot", Side = "Left"});
    Sections.Aimbot2 = Tabs.Combat:Section({Name = "Aimbot", Side = "Right"});
end

Sections.Aimbot:Toggle({Name = "Toggle", Flag = "Aimbot", Default = false}):Keybind({Name = "Keybind", Flag = "Keybind", Default = Enum.KeyCode.C, Mode = "Toggle", Callback = function() end});
Sections.Aimbot:Button({Name = "Button", Callback = function()print(Library:GetConfig());end})
Sections.Aimbot:Button({Name = "Button", Callback = function()print("Pressed");end}):Sub({Name = "Sub Button", Callback = function() print("Pressed");end})
Sections.Aimbot:Slider({Name = "Slider", Min = 1, Max = 10, Decimals = 0.1, Default = 5, Sub = "s", Flag = "Slider", Callback = function() end});
Sections.Aimbot:Dropdown({Name = "Dropdown", Flag = "Dropdown", Options = {"Option 1", "Option 2", "Option 3"}, Default = "Option 1", Callback = function() end});
Sections.Aimbot:Keybind({Name = "Keybind", Flag = "Keybind", Default = Enum.KeyCode.C, Mode = "Toggle", Callback = function() end});
Sections.Aimbot:Colorpicker({Name = "Colorpicker", Flag = "Colorpicker", Default = Library.Accent, Alpha = 0, Callback = function() end});
Sections.Aimbot:Textbox({Name = "Textbox", Flag = "Textbox", Placeholder = "Type Here...", Compact = false, Default = "lul", Callback = function() end});
Sections.Aimbot:Listbox({Flag = "Listbox", Options = {"Option 1", "Option 2", "Option 3","Option 1"}, Callback = function() end});
Library:Notify("Notification", 3, Library.Accent)
