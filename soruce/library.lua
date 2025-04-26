local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local SimpleESP = {
    Enabled = true,
    TeamCheck = false,
    MaxDistance = 500,
    FontSize = 11,
    FadeOut = {
        OnDistance = false,
    },
    Drawing = {
        Names = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Distances = {
            Enabled = false, 
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Healthbar = {
            Enabled = false,  
            HealthText = false, 
            Lerp = true, 
            HealthTextRGB = Color3.fromRGB(255, 255, 255),
            Width = 2.5,
            Gradient = true, 
            GradientRGB1 = Color3.fromRGB(200, 0, 0), 
            GradientRGB2 = Color3.fromRGB(60, 60, 125), 
            GradientRGB3 = Color3.fromRGB(0, 255, 0), 
        },
        Boxes = {
            Filled = {
                Enabled = false,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = false,
                RGB = Color3.fromRGB(17, 168, 255),
            },
        },
        RaceInfo = {
            Enabled = false,
            CCGColor = Color3.fromRGB(0, 0, 255),
            GhoulColor = Color3.fromRGB(255, 0, 0),
            OtherColor = Color3.fromRGB(0, 248, 112),
        },
        RCCells = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 0, 0),
            UpdateInterval = 10,
        }
    }
}

local Functions = {}

function Functions:Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

function Functions:FadeOutOnDist(element, distance)
    local transparency = math.max(0.1, 1 - (distance / SimpleESP.MaxDistance))
    if element:IsA("TextLabel") then
        element.TextTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then
        element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    end
end

function Functions:AbbreviateNumber(num)
    if not num then return "0" end
    if num < 1000 then return tostring(math.floor(num)) end

    local suffixes = {"", "K", "M", "B", "T"}
    local index = 1

    while num >= 1000 and index < #suffixes do
        num = num / 1000
        index = index + 1
    end

    return string.format("%.1f%s", num, suffixes[index])
end

local ScreenGui = Functions:Create("ScreenGui", {
    Parent = CoreGui,
    Name = "SimpleESPHolder",
    ResetOnSpawn = false,
})

local function DupeCheck(plr)
    if ScreenGui:FindFirstChild(plr.Name) then
        ScreenGui[plr.Name]:Destroy()
    end
end

local function ApplyESP(plr)
    if plr == LocalPlayer then return end

    coroutine.wrap(DupeCheck)(plr)

    local ESPContainer = Functions:Create("Folder", {
        Parent = ScreenGui,
        Name = plr.Name
    })

    local Box = Functions:Create("Frame", {
        Parent = ESPContainer, 
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
        BackgroundTransparency = 0.75, 
        BorderSizePixel = 0
    })

    local Outline = Functions:Create("UIStroke", {
        Parent = Box, 
        Transparency = 0, 
        Color = SimpleESP.Drawing.Boxes.Full.RGB, 
        LineJoinMode = Enum.LineJoinMode.Miter
    })

    local Name = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, -11), 
        Size = UDim2.new(0, 100, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = SimpleESP.Drawing.Names.RGB, 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
        RichText = true
    })

    local Distance = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 11), 
        Size = UDim2.new(0, 100, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = SimpleESP.Drawing.Distances.RGB, 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
        RichText = true
    })

    local Healthbar = Functions:Create("Frame", {
        Parent = ESPContainer, 
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
        BackgroundTransparency = 0
    })

    local BehindHealthbar = Functions:Create("Frame", {
        Parent = ESPContainer, 
        ZIndex = -1, 
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
        BackgroundTransparency = 0
    })

    local HealthbarGradient = Functions:Create("UIGradient", {
        Parent = Healthbar, 
        Enabled = SimpleESP.Drawing.Healthbar.Gradient, 
        Rotation = -90, 
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, SimpleESP.Drawing.Healthbar.GradientRGB1), 
            ColorSequenceKeypoint.new(0.5, SimpleESP.Drawing.Healthbar.GradientRGB2), 
            ColorSequenceKeypoint.new(1, SimpleESP.Drawing.Healthbar.GradientRGB3)
        }
    })

    local HealthText = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 31), 
        Size = UDim2.new(0, 100, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = SimpleESP.Drawing.Healthbar.HealthTextRGB, 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    })

    local RaceInfo = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 10), 
        Size = UDim2.new(0, 100, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = Color3.fromRGB(255, 255, 255), 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    })

    local RCCells = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 71), 
        Size = UDim2.new(0, 100, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = SimpleESP.Drawing.RCCells.RGB, 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    })

    local lastRCUpdate = 0
    local rcCellsValue = "0"

    local function HideESP()
        Box.Visible = false
        Name.Visible = false
        Distance.Visible = false
        Healthbar.Visible = false
        BehindHealthbar.Visible = false
        HealthText.Visible = false
        RaceInfo.Visible = false
        RCCells.Visible = false

        if not plr then
            ESPContainer:Destroy()
        end
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not SimpleESP.Enabled then 
            HideESP()
            return
        end

        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = plr.Character.HumanoidRootPart
            local Humanoid = plr.Character:WaitForChild("Humanoid");
            local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
            local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714

            if OnScreen and Dist <= SimpleESP.MaxDistance then
                local Size = HRP.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                if SimpleESP.FadeOut.OnDistance then
                    Functions:FadeOutOnDist(Box, Dist)
                    Functions:FadeOutOnDist(Outline, Dist)
                    Functions:FadeOutOnDist(Name, Dist)
                    Functions:FadeOutOnDist(Distance, Dist)
                    Functions:FadeOutOnDist(Healthbar, Dist)
                    Functions:FadeOutOnDist(BehindHealthbar, Dist)
                    Functions:FadeOutOnDist(HealthText, Dist)
                    Functions:FadeOutOnDist(RaceInfo, Dist)
                    Functions:FadeOutOnDist(RCCells, Dist)
                end

                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                Box.Size = UDim2.new(0, w, 0, h)
                Box.Visible = SimpleESP.Drawing.Boxes.Full.Enabled

                if SimpleESP.Drawing.Boxes.Filled.Enabled then
                    Box.BackgroundTransparency = SimpleESP.Drawing.Boxes.Filled.Transparency
                    Box.BackgroundColor3 = SimpleESP.Drawing.Boxes.Filled.RGB
                else
                    Box.BackgroundTransparency = 1
                end

                local health = Humanoid.Health / Humanoid.MaxHealth
                Healthbar.Visible = SimpleESP.Drawing.Healthbar.Enabled
                Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))
                Healthbar.Size = UDim2.new(0, SimpleESP.Drawing.Healthbar.Width, 0, h * health)

                BehindHealthbar.Visible = SimpleESP.Drawing.Healthbar.Enabled
                BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)
                BehindHealthbar.Size = UDim2.new(0, SimpleESP.Drawing.Healthbar.Width, 0, h)

                if SimpleESP.Drawing.Healthbar.HealthText then
                    local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                    HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 20, 0, Pos.Y - h / 2 + h * (1 - healthPercentage / 100) + 3)
                    HealthText.Text = tostring(healthPercentage)
                    HealthText.Visible = SimpleESP.Drawing.Healthbar.Enabled

                    if SimpleESP.Drawing.Healthbar.Lerp then
                        local color = health >= 0.75 and Color3.fromRGB(0, 255, 0) or 
                                     health >= 0.5 and Color3.fromRGB(255, 255, 0) or 
                                     health >= 0.25 and Color3.fromRGB(255, 170, 0) or 
                                     Color3.fromRGB(255, 0, 0)
                        HealthText.TextColor3 = color
                    else
                        HealthText.TextColor3 = SimpleESP.Drawing.Healthbar.HealthTextRGB
                    end
                end

                Name.Visible = SimpleESP.Drawing.Names.Enabled
                local rankValue = plr.Character:FindFirstChild("Rank") and tonumber(plr.Character.Rank.Value) or 0
                local Race = plr.Character:FindFirstChild("Race") and plr.Character.Race.Value or "Unknown"
                local maxRank = (Race == "Ghoul") and 10 or 9
                local rankText = ""

                if rankValue > 0 then
                    if rankValue >= maxRank then
                        rankText = " [Max Rank]"
                    else
                        rankText = " [R" .. rankValue .. "/" .. maxRank .. "]"
                    end
                end

                Name.Text = plr.Name .. rankText
                Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 15)

                Distance.Visible = SimpleESP.Drawing.Distances.Enabled
                Distance.Text = string.format("%d meters", math.floor(Dist))
                Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)

                -- Race Info handling
                RaceInfo.Visible = SimpleESP.Drawing.RaceInfo.Enabled
                if SimpleESP.Drawing.RaceInfo.Enabled then
                    local raceDisplayText = Race
                    local raceColor = SimpleESP.Drawing.RaceInfo.OtherColor

                    if Race == "Ghoul" then
                        raceColor = SimpleESP.Drawing.RaceInfo.GhoulColor
                    elseif Race == "Human" then
                        raceDisplayText = "CCG" 
                        raceColor = SimpleESP.Drawing.RaceInfo.CCGColor
                    end

                    RaceInfo.Text = raceDisplayText
                    RaceInfo.TextColor3 = raceColor
                    RaceInfo.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 24)
                end

                -- RC Cells handling
                RCCells.Visible = SimpleESP.Drawing.RCCells.Enabled
                if SimpleESP.Drawing.RCCells.Enabled then
                    if tick() - lastRCUpdate > SimpleESP.Drawing.RCCells.UpdateInterval then
                        lastRCUpdate = tick()
                        rcCellsValue = Functions:AbbreviateNumber(plr.Character:GetAttribute("RCCells") or 0)
                    end

                    RCCells.Text = "RC: " .. rcCellsValue
                    RCCells.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 34)
                    RCCells.TextColor3 = SimpleESP.Drawing.RCCells.RGB
                end

            else
                HideESP()
            end
        else
            HideESP()
        end
    end)

    plr.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            Connection:Disconnect()
            ESPContainer:Destroy()
        end
    end)
end

function SimpleESP:Initialize()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            coroutine.wrap(ApplyESP)(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        coroutine.wrap(ApplyESP)(player)
    end)
end

function SimpleESP:Toggle(state)
    self.Enabled = state or not self.Enabled
    return self.Enabled
end

SimpleESP:Initialize()
print("Ran Script")

return SimpleESP
