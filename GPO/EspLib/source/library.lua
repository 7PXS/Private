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
    ShowPlayers = true,
    ShowMobs = true,
    ShowNPCs = true,

    Position = {
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT",
        RIGHT = "RIGHT"
    },

    BoxStyle = {
        NONE = "NONE",
        FULL = "FULL",
        CORNERS = "CORNERS",
        FILLED = "FILLED"
    },

    ESP = {
        Player = {
            Name = {
                Enabled = true,
                Position = "TOP", 
                RGB = Color3.fromRGB(255, 255, 255),
                Offset = 0, 
            },
            Distance = {
                Enabled = true,
                Position = "BOTTOM", 
                RGB = Color3.fromRGB(255, 255, 255),
                Offset = 0, 
            },
            Weapon = {
                Enabled = true,
                Position = "BOTTOM", 
                RGB = Color3.fromRGB(255, 230, 0),
                Offset = 8, 
            },
            Box = {
                Style = "CORNERS", 
                RGB = Color3.fromRGB(17, 168, 255),
                FilledTransparency = 0.75,
                FilledRGB = Color3.fromRGB(0, 0, 0),
            },
            Healthbar = {
                Enabled = true,
                Position = "LEFT", 
                Offset = 6, 
                Width = 2.5,
                HealthText = {
                    Enabled = true,
                    Position = "LEFT", 
                    Offset = 0, 
                    RGB = Color3.fromRGB(255, 255, 255),
                },
                Gradient = true,
                GradientRGB1 = Color3.fromRGB(200, 0, 0),
                GradientRGB2 = Color3.fromRGB(60, 60, 125),
                GradientRGB3 = Color3.fromRGB(0, 255, 0),
                Lerp = true,
            }
        },
        Mob = {
            Name = {
                Enabled = true,
                Position = "TOP",
                RGB = Color3.fromRGB(255, 100, 100),
                Offset = 0,
            },
            Distance = {
                Enabled = true,
                Position = "BOTTOM",
                RGB = Color3.fromRGB(255, 255, 255),
                Offset = 0,
            },
            Box = {
                Style = "CORNERS",
                RGB = Color3.fromRGB(255, 100, 100),
                FilledTransparency = 0.75,
                FilledRGB = Color3.fromRGB(0, 0, 0),
            },
            Healthbar = {
                Enabled = true,
                Position = "LEFT",
                Offset = 6,
                Width = 2.5,
                HealthText = {
                    Enabled = true,
                    Position = "LEFT",
                    Offset = 0,
                    RGB = Color3.fromRGB(255, 255, 255),
                },
                Gradient = true,
                GradientRGB1 = Color3.fromRGB(200, 0, 0),
                GradientRGB2 = Color3.fromRGB(60, 60, 125),
                GradientRGB3 = Color3.fromRGB(0, 255, 0),
                Lerp = true,
            }
        },
        NPC = {
            Name = {
                Enabled = true,
                Position = "TOP",
                RGB = Color3.fromRGB(0, 255, 100),
                Offset = 0,
            },
            Distance = {
                Enabled = true,
                Position = "BOTTOM", 
                RGB = Color3.fromRGB(255, 255, 255),
                Offset = 0,
            }

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

local function DupeCheck(name)
    if ScreenGui:FindFirstChild(name) then
        ScreenGui[name]:Destroy()
    end
end

local function GetWeaponName(character)
    if not character then return "None" end

    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            return tool.Name
        end
    end

    return "None"
end

local function IsNPC(entity)
    return entity:FindFirstChild("ForceField") and entity.ForceField:IsA("ForceField")
end

local function GetEntityType(entity)
    if IsNPC(entity) then
        return "NPC"
    elseif Players:GetPlayerFromCharacter(entity) then
        return "Player"
    else
        return "Mob"
    end
end

local function GetEntityName(entity, entityType)
    if entityType == "Player" then
        return entity.Name
    elseif entityType == "Mob" then
        return entity.Name .. " [Mob]"
    elseif entityType == "NPC" then
        return entity.Name .. " [NPC]"
    else
        return entity.Name
    end
end

local function GetYOffsetForPosition(config, position, offset)
    local baseY = 0

    if position == SimpleESP.Position.TOP then
        baseY = -15 - offset
    elseif position == SimpleESP.Position.BOTTOM then
        baseY = 7 + offset
    end

    return baseY
end

local function GetHealthbarPosition(config, boxPosX, boxPosY, boxWidth, boxHeight)
    local pos = config.Position
    local offset = config.Offset

    if pos == SimpleESP.Position.LEFT then
        return UDim2.new(0, boxPosX - offset, 0, boxPosY)
    elseif pos == SimpleESP.Position.RIGHT then
        return UDim2.new(0, boxPosX + boxWidth + offset - config.Width, 0, boxPosY)
    end

    return UDim2.new(0, boxPosX - offset, 0, boxPosY)
end

local function CreateCornerBox(container, color)
    local corners = {}
    local cornerLength = 5

    for i = 1, 8 do

        corners[i] = Functions:Create("Frame", {
            Parent = container,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 1, 
            BackgroundTransparency = 0,
            Visible = false 
        })

        corners[i + 8] = Functions:Create("Frame", {
            Parent = container,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 2, 
            BackgroundTransparency = 0,
            Visible = false 
        })
    end

    return corners
end

local function UpdateCornerBox(corners, x, y, w, h)
    local cornerLength = math.min(w, h) * 0.2 
    local outlineThickness = 1.5 

    corners[1].Position = UDim2.new(0, x - outlineThickness, 0, y - outlineThickness)
    corners[1].Size = UDim2.new(0, cornerLength + outlineThickness * 2, 0, outlineThickness * 2)

    corners[2].Position = UDim2.new(0, x - outlineThickness, 0, y - outlineThickness)
    corners[2].Size = UDim2.new(0, outlineThickness * 2, 0, cornerLength + outlineThickness * 2)

    corners[3].Position = UDim2.new(0, x + w - cornerLength - outlineThickness, 0, y - outlineThickness)
    corners[3].Size = UDim2.new(0, cornerLength + outlineThickness * 2, 0, outlineThickness * 2)

    corners[4].Position = UDim2.new(0, x + w - outlineThickness, 0, y - outlineThickness)
    corners[4].Size = UDim2.new(0, outlineThickness * 2, 0, cornerLength + outlineThickness * 2)

    corners[5].Position = UDim2.new(0, x - outlineThickness, 0, y + h - outlineThickness)
    corners[5].Size = UDim2.new(0, cornerLength + outlineThickness * 2, 0, outlineThickness * 2)

    corners[6].Position = UDim2.new(0, x - outlineThickness, 0, y + h - cornerLength - outlineThickness)
    corners[6].Size = UDim2.new(0, outlineThickness * 2, 0, cornerLength + outlineThickness * 2)

    corners[7].Position = UDim2.new(0, x + w - cornerLength - outlineThickness, 0, y + h - outlineThickness)
    corners[7].Size = UDim2.new(0, cornerLength + outlineThickness * 2, 0, outlineThickness * 2)

    corners[8].Position = UDim2.new(0, x + w - outlineThickness, 0, y + h - cornerLength - outlineThickness)
    corners[8].Size = UDim2.new(0, outlineThickness * 2, 0, cornerLength + outlineThickness * 2)

    corners[9].Position = UDim2.new(0, x, 0, y)
    corners[9].Size = UDim2.new(0, cornerLength, 0, 1)

    corners[10].Position = UDim2.new(0, x, 0, y)
    corners[10].Size = UDim2.new(0, 1, 0, cornerLength)

    corners[11].Position = UDim2.new(0, x + w - cornerLength, 0, y)
    corners[11].Size = UDim2.new(0, cornerLength, 0, 1)

    corners[12].Position = UDim2.new(0, x + w - 1, 0, y)
    corners[12].Size = UDim2.new(0, 1, 0, cornerLength)

    corners[13].Position = UDim2.new(0, x, 0, y + h - 1)
    corners[13].Size = UDim2.new(0, cornerLength, 0, 1)

    corners[14].Position = UDim2.new(0, x, 0, y + h - cornerLength)
    corners[14].Size = UDim2.new(0, 1, 0, cornerLength)

    corners[15].Position = UDim2.new(0, x + w - cornerLength, 0, y + h - 1)
    corners[15].Size = UDim2.new(0, cornerLength, 0, 1)

    corners[16].Position = UDim2.new(0, x + w - 1, 0, y + h - cornerLength)
    corners[16].Size = UDim2.new(0, 1, 0, cornerLength)

    for i = 1, 16 do
        corners[i].Visible = true
    end
end

local function ApplyESPToEntity(entity)

    local entityType = GetEntityType(entity)

    if entityType == "Player" and entity.Name == LocalPlayer.Name then return end

    local config = SimpleESP.ESP[entityType]
    if not config then return end

    local entityName = GetEntityName(entity, entityType)
    local uniqueId = entity.Name .. "_" .. (math.random(1000, 9999))
    coroutine.wrap(DupeCheck)(uniqueId)

    local ESPContainer = Functions:Create("Folder", {
        Parent = ScreenGui,
        Name = uniqueId
    })

    local components = {}

    components.Box = Functions:Create("Frame", {
        Parent = ESPContainer, 
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
        BackgroundTransparency = 1, 
        BorderSizePixel = 0,
        Visible = false 
    })

    components.BoxOutline = Functions:Create("UIStroke", {
        Parent = components.Box, 
        Transparency = 1, 
        Color = config.Box and config.Box.RGB or Color3.fromRGB(255, 255, 255), 
        LineJoinMode = Enum.LineJoinMode.Miter
    })

    components.BoxBlackOutline = Functions:Create("UIStroke", {
        Parent = components.Box, 
        Transparency = 1, 
        Color = Color3.fromRGB(0, 0, 0), 
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1.5 
    })

    components.Corners = config.Box and config.Box.Style == SimpleESP.BoxStyle.CORNERS and 
        CreateCornerBox(ESPContainer, config.Box.RGB) or {}

    components.Name = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 0), 
        Size = UDim2.new(0, 150, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = config.Name and config.Name.RGB or Color3.fromRGB(255, 255, 255), 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false 
    })

    components.Distance = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 0), 
        Size = UDim2.new(0, 100, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = config.Distance and config.Distance.RGB or Color3.fromRGB(255, 255, 255), 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false 
    })

    components.Weapon = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 0), 
        Size = UDim2.new(0, 120, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = config.Weapon and config.Weapon.RGB or Color3.fromRGB(255, 230, 0), 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false 
    })

    if entityType ~= "NPC" and config.Healthbar then
        components.Healthbar = Functions:Create("Frame", {
            Parent = ESPContainer, 
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
            BackgroundTransparency = 1, 
            Visible = false 
        })

        components.BehindHealthbar = Functions:Create("Frame", {
            Parent = ESPContainer, 
            ZIndex = -1, 
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
            BackgroundTransparency = 1, 
            Visible = false 
        })

        if config.Healthbar.Gradient then
            components.HealthbarGradient = Functions:Create("UIGradient", {
                Parent = components.Healthbar, 
                Enabled = true, 
                Rotation = -90, 
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, config.Healthbar.GradientRGB1), 
                    ColorSequenceKeypoint.new(0.5, config.Healthbar.GradientRGB2), 
                    ColorSequenceKeypoint.new(1, config.Healthbar.GradientRGB3)
                }
            })
        end

        if config.Healthbar.HealthText and config.Healthbar.HealthText.Enabled then
            components.HealthText = Functions:Create("TextLabel", {
                Parent = ESPContainer, 
                Position = UDim2.new(0.5, 0, 0, 0), 
                Size = UDim2.new(0, 100, 0, 20), 
                AnchorPoint = Vector2.new(0.5, 0.5), 
                BackgroundTransparency = 1, 
                TextColor3 = config.Healthbar.HealthText.RGB, 
                Font = Enum.Font.Code, 
                TextSize = SimpleESP.FontSize, 
                TextStrokeTransparency = 0, 
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Center,
                Visible = false 
            })
        end
    end

    local function HideAllComponents()
        for name, component in pairs(components) do
            if typeof(component) == "Instance" then

                if component:IsA("GuiObject") then  
                    component.Visible = false
                elseif component:IsA("UIStroke") then
                    component.Transparency = 1  
                end
            elseif type(component) == "table" then
                for _, part in pairs(component) do
                    if typeof(part) == "Instance" and part:IsA("GuiObject") then
                        part.Visible = false
                    end
                end
            end
        end

        if not entity or not entity.Parent then
            ESPContainer:Destroy()
        end
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not SimpleESP.Enabled then 
            HideAllComponents()
            return
        end

        if entityType == "Player" and not SimpleESP.ShowPlayers then
            HideAllComponents()
            return
        end

        if entityType == "Mob" and not SimpleESP.ShowMobs then
            HideAllComponents()
            return
        end

        if entityType == "NPC" and not SimpleESP.ShowNPCs then
            HideAllComponents()
            return
        end

        if entity and entity:FindFirstChild("HumanoidRootPart") then
            local HRP = entity.HumanoidRootPart
            local Humanoid = entity:FindFirstChild("Humanoid")

            if not Humanoid then
                HideAllComponents()
                return
            end

            local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)

            local playerPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
                and LocalPlayer.Character.HumanoidRootPart.Position
                or Cam.CFrame.Position 

            local Dist = (playerPosition - HRP.Position).Magnitude / 3.5714285714

            if OnScreen and Dist <= SimpleESP.MaxDistance then
                local Size = HRP.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                local boxX, boxY = Pos.X - w / 2, Pos.Y - h / 2

                if SimpleESP.FadeOut.OnDistance then
                    for _, component in pairs(components) do
                        if typeof(component) == "Instance" then
                            Functions:FadeOutOnDist(component, Dist)
                        elseif type(component) == "table" then
                            for _, part in pairs(component) do
                                if typeof(part) == "Instance" then
                                    Functions:FadeOutOnDist(part, Dist)
                                end
                            end
                        end
                    end
                end

                if config.Box then
                    local boxStyle = config.Box.Style

                    if boxStyle == SimpleESP.BoxStyle.FULL or boxStyle == SimpleESP.BoxStyle.FILLED then
                        components.Box.Position = UDim2.new(0, boxX, 0, boxY)
                        components.Box.Size = UDim2.new(0, w, 0, h)
                        components.Box.Visible = true

                        if boxStyle == SimpleESP.BoxStyle.FILLED then
                            components.Box.BackgroundTransparency = config.Box.FilledTransparency
                            components.Box.BackgroundColor3 = config.Box.FilledRGB
                        else
                            components.Box.BackgroundTransparency = 1
                        end

                        if boxStyle == SimpleESP.BoxStyle.FULL then

                            components.BoxOutline.Transparency = 0
                            components.BoxOutline.Color = config.Box.RGB
                            components.BoxBlackOutline.Transparency = 0
                            components.BoxOutline.Thickness = 1
                            components.BoxBlackOutline.Thickness = 1.5
                        else
                            components.BoxOutline.Transparency = 1
                            components.BoxBlackOutline.Transparency = 1
                        end
                    else
                        components.Box.Visible = false
                        components.BoxOutline.Transparency = 1
                        components.BoxBlackOutline.Transparency = 1
                    end

                    if boxStyle == SimpleESP.BoxStyle.CORNERS then
                        UpdateCornerBox(components.Corners, boxX, boxY, w, h)
                    else
                        for _, corner in pairs(components.Corners) do
                            corner.Visible = false
                        end
                    end
                end

                local topComponents = {}
                local bottomComponents = {}

                if config.Name and config.Name.Enabled then
                    if config.Name.Position == SimpleESP.Position.TOP then
                        table.insert(topComponents, {component = components.Name, offset = config.Name.Offset, text = GetEntityName(entity, entityType)})
                    else 
                        table.insert(bottomComponents, {component = components.Name, offset = config.Name.Offset, text = GetEntityName(entity, entityType)})
                    end
                end

                if config.Distance and config.Distance.Enabled then
                    if config.Distance.Position == SimpleESP.Position.TOP then
                        table.insert(topComponents, {component = components.Distance, offset = config.Distance.Offset, text = string.format("%d meters", math.floor(Dist))})
                    else 
                        table.insert(bottomComponents, {component = components.Distance, offset = config.Distance.Offset, text = string.format("%d meters", math.floor(Dist))})
                    end
                end

                if entityType == "Player" and config.Weapon and config.Weapon.Enabled then
                    local weaponName = GetWeaponName(entity)
                    if config.Weapon.Position == SimpleESP.Position.TOP then
                        table.insert(topComponents, {component = components.Weapon, offset = config.Weapon.Offset, text = "Weapon: " .. weaponName})
                    else 
                        table.insert(bottomComponents, {component = components.Weapon, offset = config.Weapon.Offset, text = "Weapon: " .. weaponName})
                    end
                end

                table.sort(topComponents, function(a, b) return a.offset < b.offset end)
                table.sort(bottomComponents, function(a, b) return a.offset < b.offset end)

                local topOffset = 15
                for i, compInfo in ipairs(topComponents) do
                    compInfo.component.Visible = true
                    compInfo.component.Text = compInfo.text
                    compInfo.component.Position = UDim2.new(0, Pos.X, 0, boxY - topOffset - compInfo.offset)
                    topOffset = topOffset + 17  
                end

                local bottomOffset = -3
                for i, compInfo in ipairs(bottomComponents) do
                    compInfo.component.Visible = true
                    compInfo.component.Text = compInfo.text
                    compInfo.component.Position = UDim2.new(0, Pos.X, 0, boxY + h + bottomOffset + compInfo.offset)
                    bottomOffset = bottomOffset 
                end

                if entityType ~= "NPC" and config.Healthbar and config.Healthbar.Enabled then
                    local health = Humanoid.Health / Humanoid.MaxHealth
                    local healthbarConfig = config.Healthbar
                    local healthbarWidth = healthbarConfig.Width

                    local healthbarPos = healthbarConfig.Position == SimpleESP.Position.LEFT and 
                        UDim2.new(0, boxX - healthbarConfig.Offset - healthbarWidth, 0, boxY) or
                        UDim2.new(0, boxX + w + healthbarConfig.Offset, 0, boxY)

                    local healthbarHeight = h * health
                    local behindHealthbarHeight = h

                    components.Healthbar.Visible = true
                    components.Healthbar.Position = UDim2.new(0, healthbarPos.X.Offset, 0, boxY + h - healthbarHeight)
                    components.Healthbar.Size = UDim2.new(0, healthbarWidth, 0, healthbarHeight)
                    components.Healthbar.BackgroundTransparency = 0

                    components.BehindHealthbar.Visible = true
                    components.BehindHealthbar.Position = UDim2.new(0, healthbarPos.X.Offset, 0, boxY)
                    components.BehindHealthbar.Size = UDim2.new(0, healthbarWidth, 0, behindHealthbarHeight)
                    components.BehindHealthbar.BackgroundTransparency = 0

                    if healthbarConfig.HealthText and healthbarConfig.HealthText.Enabled and components.HealthText then
                        local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                        components.HealthText.Visible = true
                        components.HealthText.Text = tostring(healthPercentage)

                        local healthTextPos = healthbarConfig.HealthText.Position
                        local healthTextX, healthTextY

                        if healthTextPos == SimpleESP.Position.LEFT then
                            healthTextX = healthbarPos.X.Offset - 13
                            healthTextY = boxY + h - healthbarHeight + 3
                        elseif healthTextPos == SimpleESP.Position.RIGHT then
                            healthTextX = healthbarPos.X.Offset + healthbarWidth + 13
                            healthTextY = boxY + h - healthbarHeight + 3
                        elseif healthTextPos == SimpleESP.Position.TOP then
                            healthTextX = healthbarPos.X.Offset + healthbarWidth / 2
                            healthTextY = boxY - 15
                        elseif healthTextPos == SimpleESP.Position.BOTTOM then
                            healthTextX = healthbarPos.X.Offset + healthbarWidth / 2
                            healthTextY = boxY + h + 15
                        end

                        components.HealthText.Position = UDim2.new(0, healthTextX, 0, healthTextY)

                        if healthbarConfig.Lerp then
                            local color = health >= 0.75 and Color3.fromRGB(0, 255, 0) or 
                                        health >= 0.5 and Color3.fromRGB(255, 255, 0) or 
                                        health >= 0.25 and Color3.fromRGB(255, 170, 0) or 
                                        Color3.fromRGB(255, 0, 0)
                            components.HealthText.TextColor3 = color
                        else
                            components.HealthText.TextColor3 = healthbarConfig.HealthText.RGB
                        end
                    end
                end
            else
                HideAllComponents()
            end
        else
            HideAllComponents()
        end
    end)

    if entity then
        entity.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                Connection:Disconnect()
                ESPContainer:Destroy()
            end
        end)
    end
end

local function InitializeESP()

    if workspace:FindFirstChild("PlayerCharacters") then
        for _, character in pairs(workspace.PlayerCharacters:GetChildren()) do
            if character.Name ~= LocalPlayer.Name then
                coroutine.wrap(ApplyESPToEntity)(character)
            end
        end

        workspace.PlayerCharacters.ChildAdded:Connect(function(character)
            if character.Name ~= LocalPlayer.Name then
                wait(0.5)
                coroutine.wrap(ApplyESPToEntity)(character)
            end
        end)
    end

    local function ProcessEntity(entity)
        if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") then
            local entityType = GetEntityType(entity)
            if entityType ~= "Player" then 
                coroutine.wrap(ApplyESPToEntity)(entity)
            end
        end
    end

    local possibleFolders = {
        workspace:FindFirstChild("NPC")
    }

    for _, folder in pairs(possibleFolders) do
        if folder then
            for _, entity in pairs(folder:GetChildren()) do
                ProcessEntity(entity)
            end

            folder.ChildAdded:Connect(function(entity)
                wait(0.5)
                ProcessEntity(entity)
            end)
        end
    end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then

            ProcessEntity(obj)
        end
    end

    workspace.ChildAdded:Connect(function(obj)
        wait(0.5)
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
            ProcessEntity(obj)
        end
    end)
end

print("init")
InitializeESP()
