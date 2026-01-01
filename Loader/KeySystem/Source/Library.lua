-- Credit To Hold4564 For the Ui to Lua Plugin
-- Im So Sigma <3
local KeySystem = {}
KeySystem.__index = KeySystem

local Logger = {}
Logger.__index = Logger

local function CreateUIElements()
    local uiElements = {
        ["KeySystemUI"] = Instance.new("ScreenGui"),
        ["BG"] = Instance.new("Frame"),
        ["Padding"] = Instance.new("Frame"),
        ["Padding_1"] = Instance.new("Frame"),
        ["TextLabel"] = Instance.new("TextLabel"),
        ["KeyPannel"] = Instance.new("Frame"),
        ["Bar"] = Instance.new("Frame"),
        ["TextLabel_1"] = Instance.new("TextLabel"),
        ["Console"] = Instance.new("Frame"),
        ["Bar_1"] = Instance.new("Frame"),
        ["TextLabel_2"] = Instance.new("TextLabel"),
        ["ConsoleBox"] = Instance.new("Frame"),
        ["ScrollingFrame"] = Instance.new("ScrollingFrame"),
        ["TextBox"] = Instance.new("TextBox"),
        ["TextBox_1"] = Instance.new("TextBox"),
        ["TextButton"] = Instance.new("TextButton"),
        ["TextButton_1"] = Instance.new("TextButton"),
        ["UIDragDetector"] = Instance.new("UIDragDetector")
    }

    if syn and syn.protect_gui then
        syn.protect_gui(uiElements["KeySystemUI"])
    end
    uiElements["KeySystemUI"].Name = "KeySystemUI"
    uiElements["KeySystemUI"].Parent = gethui()

    uiElements["BG"].Parent = uiElements["KeySystemUI"]
    uiElements["BG"].Position = UDim2.new(0.275, 0, 0.22, 0)
    uiElements["BG"].Size = UDim2.new(0, 562, 0, 268)
    uiElements["BG"].BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    uiElements["BG"].BorderColor3 = Color3.fromRGB(4, 86, 250)
    uiElements["BG"].SizeConstraint = Enum.SizeConstraint.RelativeYY
    uiElements["BG"].ZIndex = 0
    uiElements["BG"].ClipsDescendants = true
    uiElements["BG"].Active = true

    uiElements["Padding"].Parent = uiElements["BG"]
    uiElements["Padding"].Position = UDim2.new(0.01061294972896576, 0, 0.09010975062847137, 0)
    uiElements["Padding"].Size = UDim2.new(0, 549, 0, 233)
    uiElements["Padding"].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    uiElements["Padding"].BorderColor3 = Color3.fromRGB(46, 46, 46)

    uiElements["Padding_1"].Parent = uiElements["Padding"]
    uiElements["Padding_1"].Position = UDim2.new(0.018068406730890274, 0, 0.04853486642241478, 0)
    uiElements["Padding_1"].Size = UDim2.new(0, 529, 0, 210)
    uiElements["Padding_1"].BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    uiElements["Padding_1"].BorderColor3 = Color3.fromRGB(44, 44, 44)

    uiElements["TextLabel"].Parent = uiElements["BG"]
    uiElements["TextLabel"].Position = UDim2.new(0, 0, 0, 4)
    uiElements["TextLabel"].Size = UDim2.new(0, 65, 0, 12)
    uiElements["TextLabel"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextLabel"].BackgroundTransparency = 1
    uiElements["TextLabel"].Font = Enum.Font.Code
    uiElements["TextLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextLabel"].TextSize = 17
    uiElements["TextLabel"].Text = "System"
    uiElements["TextLabel"].TextWrapped = true

    uiElements["KeyPannel"].Parent = uiElements["Padding_1"]
    uiElements["KeyPannel"].Position = UDim2.new(0.035, 0, 0.05, 0)
    uiElements["KeyPannel"].Size = UDim2.new(0, 305, 0, 190)
    uiElements["KeyPannel"].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    uiElements["KeyPannel"].BorderColor3 = Color3.fromRGB(3, 3, 3)
    uiElements["KeyPannel"].ClipsDescendants = true

    uiElements["Bar"].Parent = uiElements["KeyPannel"]
    uiElements["Bar"].Position = UDim2.new(0, 0, 0, 0)
    uiElements["Bar"].Size = UDim2.new(1, 0, 0, 3)
    uiElements["Bar"].BackgroundColor3 = Color3.fromRGB(0, 85, 255)
    uiElements["Bar"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["Bar"].BorderSizePixel = 0

    uiElements["TextLabel_1"].Parent = uiElements["KeyPannel"]
    uiElements["TextLabel_1"].Position = UDim2.new(0, 0, 0.03, 0)
    uiElements["TextLabel_1"].Size = UDim2.new(0, 54, 0, 12)
    uiElements["TextLabel_1"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextLabel_1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextLabel_1"].BackgroundTransparency = 1
    uiElements["TextLabel_1"].Font = Enum.Font.Code
    uiElements["TextLabel_1"].TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextLabel_1"].TextSize = 15
    uiElements["TextLabel_1"].Text = "Key"
    uiElements["TextLabel_1"].TextWrapped = true

    uiElements["Console"].Parent = uiElements["Padding_1"]
    uiElements["Console"].Position = UDim2.new(0.62, 0, 0.05, 0)
    uiElements["Console"].Size = UDim2.new(0, 194, 0, 190)
    uiElements["Console"].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    uiElements["Console"].BorderColor3 = Color3.fromRGB(3, 3, 3)
    uiElements["Console"].ClipsDescendants = true

    uiElements["Bar_1"].Parent = uiElements["Console"]
    uiElements["Bar_1"].Position = UDim2.new(0, 0, 0, 0)
    uiElements["Bar_1"].Size = UDim2.new(1, 0, 0, 3)
    uiElements["Bar_1"].BackgroundColor3 = Color3.fromRGB(0, 85, 255)
    uiElements["Bar_1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["Bar_1"].BorderSizePixel = 0

    uiElements["TextLabel_2"].Parent = uiElements["Console"]
    uiElements["TextLabel_2"].Position = UDim2.new(0, 0, 0.03, 0)
    uiElements["TextLabel_2"].Size = UDim2.new(0, 54, 0, 12)
    uiElements["TextLabel_2"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextLabel_2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextLabel_2"].BackgroundTransparency = 1
    uiElements["TextLabel_2"].Font = Enum.Font.Code
    uiElements["TextLabel_2"].TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextLabel_2"].TextSize = 15
    uiElements["TextLabel_2"].Text = "Console"
    uiElements["TextLabel_2"].TextWrapped = true

    uiElements["ConsoleBox"].Parent = uiElements["Console"]
    uiElements["ConsoleBox"].Position = UDim2.new(0.03, 0, 0.15, 0)
    uiElements["ConsoleBox"].Size = UDim2.new(0.94, 0, 0.8, 0)
    uiElements["ConsoleBox"].BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    uiElements["ConsoleBox"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["ConsoleBox"].ClipsDescendants = true

    uiElements["ScrollingFrame"].Parent = uiElements["ConsoleBox"]
    uiElements["ScrollingFrame"].Size = UDim2.new(1, 0, 1, 0)
    uiElements["ScrollingFrame"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["ScrollingFrame"].Active = true
    uiElements["ScrollingFrame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["ScrollingFrame"].BorderSizePixel = 0
    uiElements["ScrollingFrame"].BackgroundTransparency = 1
    uiElements["ScrollingFrame"].ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["ScrollingFrame"].ScrollBarThickness = 3
    uiElements["ScrollingFrame"].AutomaticCanvasSize = Enum.AutomaticSize.Y

    uiElements["TextBox"].Parent = uiElements["ScrollingFrame"]
    uiElements["TextBox"].Position = UDim2.new(0.033, 0, 0, 0)
    uiElements["TextBox"].Size = UDim2.new(0.95, 0, 0, 150)
    uiElements["TextBox"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextBox"].BorderColor3 = Color3.fromRGB(0, 0, 0)
    uiElements["TextBox"].BackgroundTransparency = 1
    uiElements["TextBox"].Font = Enum.Font.Code
    uiElements["TextBox"].TextColor3 = Color3.fromRGB(0, 153, 218)
    uiElements["TextBox"].TextSize = 14
    uiElements["TextBox"].Text = ""
    uiElements["TextBox"].PlaceholderText = "Welcome!"
    uiElements["TextBox"].PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
    uiElements["TextBox"].TextWrapped = true
    uiElements["TextBox"].TextXAlignment = Enum.TextXAlignment.Left
    uiElements["TextBox"].TextYAlignment = Enum.TextYAlignment.Top
    uiElements["TextBox"].ClearTextOnFocus = false
    uiElements["TextBox"].TextEditable = false
    uiElements["TextBox"].AutomaticSize = Enum.AutomaticSize.Y

    uiElements["TextBox_1"].Parent = uiElements["KeyPannel"]
    uiElements["TextBox_1"].Position = UDim2.new(0.05, 0, 0.5, 0)
    uiElements["TextBox_1"].Size = UDim2.new(0.9, 0, 0.15, 0)
    uiElements["TextBox_1"].BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    uiElements["TextBox_1"].BorderColor3 = Color3.fromRGB(15, 15, 15)
    uiElements["TextBox_1"].Font = Enum.Font.Code
    uiElements["TextBox_1"].TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextBox_1"].TextSize = 14
    uiElements["TextBox_1"].Text = ""
    uiElements["TextBox_1"].PlaceholderText = "Input Key"
    uiElements["TextBox_1"].PlaceholderColor3 = Color3.fromRGB(178, 178, 178)

    uiElements["TextButton"].Parent = uiElements["KeyPannel"]
    uiElements["TextButton"].Position = UDim2.new(0.1, 0, 0.7, 0)
    uiElements["TextButton"].Size = UDim2.new(0.45, 0, 0.12, 0)
    uiElements["TextButton"].BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    uiElements["TextButton"].BorderColor3 = Color3.fromRGB(15, 15, 15)
    uiElements["TextButton"].Font = Enum.Font.Code
    uiElements["TextButton"].TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextButton"].TextSize = 14
    uiElements["TextButton"].Text = "Check"

    uiElements["TextButton_1"].Parent = uiElements["KeyPannel"]
    uiElements["TextButton_1"].Position = UDim2.new(0.6, 0, 0.7, 0)
    uiElements["TextButton_1"].Size = UDim2.new(0.3, 0, 0.12, 0)
    uiElements["TextButton_1"].BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    uiElements["TextButton_1"].BorderColor3 = Color3.fromRGB(15, 15, 15)
    uiElements["TextButton_1"].Font = Enum.Font.Code
    uiElements["TextButton_1"].TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements["TextButton_1"].TextSize = 14
    uiElements["TextButton_1"].Text = "Exit"

    uiElements["UIDragDetector"].Parent = uiElements["BG"]

    local dragScript = Instance.new("LocalScript")
    dragScript.Parent = uiElements["BG"]
    dragScript.Source = [[
    local UIS = game:GetService("UserInputService")
    local frame = script.Parent
    local dragToggle = nil
    local dragSpeed = 0.25
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
            if input.UnitRay then
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
    ]]

    return uiElements
end

function Logger.new(consoleTextBox)
    local self = setmetatable({}, Logger)
    self.consoleTextBox = consoleTextBox
    self.logHistory = {}
    self.maxLogHistory = 50
    return self
end

function Logger:log(title, message, logType)
    logType = logType or "INFO"

    local colorMap = {
        ["INFO"] = Color3.fromRGB(0, 153, 218),    
        ["SUCCESS"] = Color3.fromRGB(0, 200, 0),   
        ["ERROR"] = Color3.fromRGB(255, 50, 50),   
        ["WARNING"] = Color3.fromRGB(255, 155, 0), 
        ["SYSTEM"] = Color3.fromRGB(175, 100, 255) 
    }

    local color = colorMap[logType] or colorMap["INFO"]
    local timeStamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s][%s] %s: %s\n", timeStamp, logType, title, message)

    table.insert(self.logHistory, {text = logEntry, color = color})

    while #self.logHistory > self.maxLogHistory do
        table.remove(self.logHistory, 1)
    end

    self:updateConsole()

    return logEntry
end

function Logger:updateConsole()
    local fullText = ""

    for _, entry in ipairs(self.logHistory) do
        fullText = fullText .. entry.text
    end

    self.consoleTextBox.Text = fullText

    self.consoleTextBox.Parent.CanvasPosition = Vector2.new(0, self.consoleTextBox.Parent.CanvasSize.Y.Offset)
end

function Logger:clear()
    self.logHistory = {}
    self.consoleTextBox.Text = ""
end

function KeySystem.new(config)
    local self = setmetatable({}, KeySystem)

    self.uiElements = CreateUIElements()

    self.logger = Logger.new(self.uiElements["TextBox"])

    self.config = config or {
        title = "Key System",
        validateKeyCallback = nil, 
        onSuccess = nil,          
        onFail = nil,             
        exitCallback = nil        
    }

    self.uiElements["TextLabel"].Text = self.config.title
    self.uiElements["TextLabel_1"].Text = "Key"

    self:setupCallbacks()

    self.logger:log("System", "Key System initialized", "SYSTEM")
    self.logger:log("System", "Please enter your key", "INFO")

    return self
end

function KeySystem:setupCallbacks()

    self.uiElements["TextButton"].MouseButton1Click:Connect(function()
        local key = self.uiElements["TextBox_1"].Text

        if key and key ~= "" then
            self:validateKey(key)
        else
            self.logger:log("System", "Please enter a key", "WARNING")
        end
    end)

    self.uiElements["TextButton_1"].MouseButton1Click:Connect(function()
        self:exit()
    end)
end

function KeySystem:setConfig(config)
    for key, value in pairs(config) do
        self.config[key] = value
    end

    if config.title then
        self.uiElements["TextLabel"].Text = config.title
    end

    return self
end

function KeySystem:validateKey(key)

    if self.config.validateKeyCallback then
        local success, message = self.config.validateKeyCallback(key)

        if success then
            self.logger:log("System", message or "Key validation successful!", "SUCCESS")

            if self.config.onSuccess then
                task.spawn(function()
                    self.config.onSuccess(key)
                end)
            end

            task.delay(2, function()
                self:exit()
            end)
        else
            self.logger:log("System", message or "Invalid key", "ERROR")

            if self.config.onFail then
                task.spawn(function()
                    self.config.onFail(key)
                end)
            end
        end
    else
        self.logger:log("System", "No key validation function set", "ERROR")
    end
end

function KeySystem:exit()

    if self.config.exitCallback then
        task.spawn(function()
            self.config.exitCallback()
        end)
    end

    if self.uiElements["KeySystemUI"] then
        self.uiElements["KeySystemUI"]:Destroy()
    end
end

function KeySystem:log(title, message, logType)
    return self.logger:log(title, message, logType)
end

local activeKeySystem = nil

local log = {}

function log.console(title, message, logType)
    if activeKeySystem then
        return activeKeySystem:log(title, message, logType)
    else
        warn("KeySystem not initialized yet. Cannot log to console.")
    end
end

local module = {}

function module.new(config)
    local keySystem = KeySystem.new(config)
    activeKeySystem = keySystem
    return keySystem
end

module.log = log

return module
