local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/refs/heads/main/Library.lua'))()

-- Create a custom Console addon
local Console = {}
Console.__index = Console

-- Create a new console instance
function Console.new(title, parent)
    local self = setmetatable({}, Console)
    
    -- Create the main console frame
    self.Frame = Library:Create('Frame', {
        Name = 'Console',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    -- Create the layout
    self.Layout = Library:Create('UIListLayout', {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Frame
    })
    
    -- Create the console title
    self.Title = Library:Create('TextLabel', {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title or 'Console',
        TextColor3 = Library.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        TextSize = 15,
        LayoutOrder = 1,
        Parent = self.Frame
    })
    
    -- Create the console output frame
    self.OutputFrame = Library:Create('ScrollingFrame', {
        Size = UDim2.new(1, 0, 1, -20),
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        BorderSizePixel = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        LayoutOrder = 2,
        Parent = self.Frame
    })
    
    -- Create console output layout
    self.OutputLayout = Library:Create('UIListLayout', {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.OutputFrame
    })
    
    -- Create a padding
    self.Padding = Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = self.OutputFrame
    })
    
    return self
end

-- Function to add text to the console
function Console:Print(text, color)
    color = color or Color3.fromRGB(255, 255, 255) -- Default white text
    
    local textLabel = Library:Create('TextLabel', {
        Size = UDim2.new(1, -10, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        TextSize = 14,
        LayoutOrder = #self.OutputFrame:GetChildren(),
        Parent = self.OutputFrame
    })
    
    -- Update canvas size
    self.OutputFrame.CanvasSize = UDim2.new(0, 0, 0, self.OutputLayout.AbsoluteContentSize.Y + 10)
    
    -- Auto scroll to bottom
    self.OutputFrame.CanvasPosition = Vector2.new(0, self.OutputLayout.AbsoluteContentSize.Y)
    
    return textLabel
end

-- Shorthand functions for different message types
function Console:Info(text)
    return self:Print(string.format("[Info]: %s", text), Color3.fromRGB(85, 170, 255)) -- Blue
end

function Console:Warning(text)
    return self:Print(string.format("[Warning]: %s", text), Color3.fromRGB(255, 230, 0)) -- Yellow
end

function Console:Error(text)
    return self:Print(string.format("[Error]: %s", text), Color3.fromRGB(255, 50, 50)) -- Red
end

function Console:Clear()
    for _, child in pairs(self.OutputFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    self.OutputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- Create a key input system
local KeySystem = {}
KeySystem.__index = KeySystem

function KeySystem.new(title, parent)
    local self = setmetatable({}, KeySystem)
    
    -- Create the main frame
    self.Frame = Library:Create('Frame', {
        Name = 'KeySystem',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    -- Create the layout
    self.Layout = Library:Create('UIListLayout', {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Frame
    })
    
    -- Create the title
    self.Title = Library:Create('TextLabel', {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title or 'System',
        TextColor3 = Library.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        TextSize = 15,
        LayoutOrder = 1,
        Parent = self.Frame
    })
    
    -- Create the input frame
    self.InputFrame = Library:Create('Frame', {
        Size = UDim2.new(1, 0, 1, -20),
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        BorderSizePixel = 1,
        LayoutOrder = 2,
        Parent = self.Frame
    })
    
    -- Create the input box
    self.InputBox = Library:Create('TextBox', {
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 25),
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderSizePixel = 1,
        Text = "",
        PlaceholderText = "Input Key",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
        Font = Library.Font,
        TextSize = 14,
        Parent = self.InputFrame
    })
    
    -- Create button container
    self.ButtonFrame = Library:Create('Frame', {
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.InputFrame
    })
    
    -- Create button layout
    self.ButtonLayout = Library:Create('UIGridLayout', {
        CellSize = UDim2.new(0.5, -5, 1, 0),
        CellPadding = UDim2.new(0, 10, 0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.ButtonFrame
    })
    
    -- Create Check button
    self.CheckButton = Library:Create('TextButton', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderSizePixel = 1,
        Text = "Check",
        TextColor3 = Library.FontColor,
        Font = Library.Font,
        TextSize = 14,
        LayoutOrder = 1,
        Parent = self.ButtonFrame
    })
    
    -- Create Exit button
    self.ExitButton = Library:Create('TextButton', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderSizePixel = 1,
        Text = "Exit",
        TextColor3 = Library.FontColor,
        Font = Library.Font,
        TextSize = 14,
        LayoutOrder = 2,
        Parent = self.ButtonFrame
    })
    
    -- Create info text
    self.InfoLabel = Library:Create('TextLabel', {
        Size = UDim2.new(1, -10, 0, 40),
        Position = UDim2.new(0, 5, 0, 100),
        BackgroundTransparency = 1,
        Text = "This is a Custom addon to Linoria's Addons, this was made by _seasonal_.",
        TextColor3 = Library.FontColor,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        TextSize = 14,
        Parent = self.InputFrame
    })
    
    -- Button hover effects
    local function ApplyButtonHoverEffect(button)
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Library.AccentColor
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Library.MainColor
        end)
    end
    
    ApplyButtonHoverEffect(self.CheckButton)
    ApplyButtonHoverEffect(self.ExitButton)
    
    return self
end

-- Function to set callback for check button
function KeySystem:OnCheck(callback)
    self.CheckButton.MouseButton1Click:Connect(function()
        if callback then
            callback(self.InputBox.Text)
        end
    end)
end

-- Function to set callback for exit button
function KeySystem:OnExit(callback)
    self.ExitButton.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
end

-- Create function for example system
local function CreateExampleKeySystem()
    -- Create a window
    local Window = Library:NewWindow({
        Title = "Example Key System",
        Center = true,
        AutoShow = true,
        Size = UDim2.new(0, 550, 0, 300),
    })
    
    -- Create tabs
    local SystemTab = Window:AddTab('System')
    local ConsoleTab = Window:AddTab('Console')
    
    -- Create the key system in the first tab
    local KeySystemSection = SystemTab:AddLeftGroupbox('Key System')
    local keySystem = KeySystem.new("", KeySystemSection.Container)
    
    -- Create console in the second tab
    local ConsoleSection = ConsoleTab:AddLeftGroupbox('Console Output')
    local console = Console.new("", ConsoleSection.Container)
    
    -- Add some example text to the console
    console:Print("This is white text")
    console:Error("This is red text")
    console:Warning("This is yellow text")
    console:Info("This is blue text")
    
    -- Set up key system callbacks
    keySystem:OnCheck(function(key)
        console:Info("Key checked: " .. key)
        if key == "correct_key" then
            console:Print("Key is correct!")
        else
            console:Error("Invalid key!")
        end
    end)
    
    keySystem:OnExit(function()
        console:Warning("Exiting application...")
        task.wait(1)
        Library:Unload()
    end)
    
    return Window
end

-- Return the addon components directly
local ConsoleAddon = {
    Console = Console,
    KeySystem = KeySystem,
    CreateExampleKeySystem = CreateExampleKeySystem
}

-- Auto-execute example if this script is run directly
if not game:GetService("RunService"):IsStudio() then
    local Window = CreateExampleKeySystem()
end

return ConsoleAddon
