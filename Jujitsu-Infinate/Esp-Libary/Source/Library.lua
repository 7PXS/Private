local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local SimpleESP = {
    Enabled = true,
    Settings = {
        MaxDistance = 2000,
        FontSize = 12,
        RefreshRate = 0, 
        FadeOut = {
            OnDistance = true,
        },

        BoxScaleFactor = 0.7, 
    },
    Players = {
        Enabled = true,
        ShowName = true,
        ShowLevel = true,
        ShowDistance = true,
        ShowChams = true,  
        ShowHealthbar = true,
        TeamCheck = false,
        Color = Color3.fromRGB(255, 100, 100),         
        NameColor = Color3.fromRGB(255, 100, 100),     
        LevelColor = Color3.fromRGB(255, 255, 255),    
        DistanceColor = Color3.fromRGB(200, 200, 200), 
        ChamsColor = Color3.fromRGB(255, 100, 100),    
        ChamsOutlineColor = Color3.fromRGB(255, 0, 0), 
        ChamsFillTransparency = 0.5,                   
        ChamsOutlineTransparency = 0,                  
        HealthbarOutlineColor = Color3.fromRGB(0, 0, 0), 
        HealthGradient = true,
        HealthColors = {
            High = Color3.fromRGB(0, 255, 0),
            Mid = Color3.fromRGB(255, 255, 0),
            Low = Color3.fromRGB(255, 0, 0),
        },
    },
    Mobs = {
        Enabled = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealthbar = true,
        ShowChams = true,  
        Color = Color3.fromRGB(255, 100, 100),         
        NameColor = Color3.fromRGB(255, 100, 100),     
        DistanceColor = Color3.fromRGB(200, 200, 200), 
        ChamsColor = Color3.fromRGB(255, 100, 100),    
        ChamsOutlineColor = Color3.fromRGB(255, 0, 0), 
        ChamsFillTransparency = 0.5,                   
        ChamsOutlineTransparency = 0,                  
        HealthbarOutlineColor = Color3.fromRGB(0, 0, 0), 
        HealthGradient = true,
        HealthColors = {
            High = Color3.fromRGB(0, 255, 0),
            Mid = Color3.fromRGB(255, 255, 0),
            Low = Color3.fromRGB(255, 0, 0),
        },
    },
    Items = {
        Enabled = true,
        ShowName = true,
        ShowDistance = true,
        ShowChams = true,  
        Color = Color3.fromRGB(255, 255, 100),         
        NameColor = Color3.fromRGB(255, 255, 100),     
        DistanceColor = Color3.fromRGB(200, 200, 200), 
        ChamsColor = Color3.fromRGB(255, 255, 100),    
        ChamsOutlineColor = Color3.fromRGB(255, 200, 0), 
        ChamsFillTransparency = 0.5,                   
        ChamsOutlineTransparency = 0,                  
        MaxDistance = 500,
    }
}

local Utils = {}

function Utils:Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

function Utils:FadeOutOnDist(element, distance, maxDistance)
    local maxDist = maxDistance or SimpleESP.Settings.MaxDistance
    local transparency = math.max(0.1, 1 - (distance / maxDist))

    if element:IsA("TextLabel") then
        element.TextTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then
        element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    end
end

function Utils:GetDistanceFromCamera(position)
    return (Cam.CFrame.Position - position).Magnitude
end

function Utils:FormatDistance(distance)
    return string.format("%d m", math.floor(distance))
end

function Utils:GetBoxSize(part)
    if not part then return Vector3.new(4, 5, 0) end

    if part:IsA("Model") and part:FindFirstChildOfClass("Humanoid") then
        local rootPart = part:FindFirstChild("HumanoidRootPart") or part.PrimaryPart
        if rootPart then
            return Vector3.new(4, 5, 0)
        end
    end

    return part.Size
end

function Utils:GetHealthPercentage(model)
    if not model then return 1 end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health / humanoid.MaxHealth
    end

    local health = model:FindFirstChild("Health")
    local maxHealth = model:FindFirstChild("MaxHealth")

    if health and maxHealth and health:IsA("NumberValue") and maxHealth:IsA("NumberValue") then
        return health.Value / maxHealth.Value
    end

    return 1 
end

function Utils:GetLerpColor(percent, colors)
    if percent >= 0.7 then
        return colors.High
    elseif percent >= 0.3 then
        return colors.Mid
    else
        return colors.Low
    end
end

function Utils:GetPlayerLevel(player)
    if not player then return "?" end

    local levelValue = player:FindFirstChild("ReplicatedData") and 
                      player.ReplicatedData:FindFirstChild("level")

    if levelValue then
        return levelValue.Value or "?"
    end

    local level = player:GetAttribute("Level")
    if level then
        return level
    end

    local character = workspace.Objects.Characters:FindFirstChild(player.Name)
    if character then
        local charLevel = character:GetAttribute("Level") or
                         (character:FindFirstChild("Level") and character.Level.Value)
        if charLevel then
            return charLevel
        end
    end

    return "?"
end

local ScreenGui = Utils:Create("ScreenGui", {
    Parent = CoreGui,
    Name = "SimpleESPHolder",
    ResetOnSpawn = false,
})

local function CreateESPObject(id, objType)
    if ScreenGui:FindFirstChild(id) then
        ScreenGui[id]:Destroy()
    end

    local config = SimpleESP[objType]
    if not config then return nil end

    local ESPContainer = Utils:Create("Folder", {
        Parent = ScreenGui,
        Name = id
    })

    local Highlight = Utils:Create("Highlight", {
        Parent = ESPContainer, 
        FillColor = config.ChamsColor or config.Color,
        OutlineColor = config.ChamsOutlineColor or config.Color,
        FillTransparency = config.ChamsFillTransparency or 0.5,
        OutlineTransparency = config.ChamsOutlineTransparency or 0,
        Enabled = false 
    })

    local Name = Utils:Create("TextLabel", {
        Parent = ESPContainer,
        Position = UDim2.new(0.5, 0, 0, -15),
        Size = UDim2.new(0, 150, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = config.NameColor or config.Color,
        Font = Enum.Font.Code,
        TextSize = SimpleESP.Settings.FontSize,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true, 
        Visible = false
    })

    local Distance = Utils:Create("TextLabel", {
        Parent = ESPContainer,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 100, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = config.DistanceColor or Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Code,
        TextSize = SimpleESP.Settings.FontSize,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false
    })

    local Healthbar = Utils:Create("Frame", {
        Parent = ESPContainer,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        Visible = false
    })

    local BehindHealthbar = Utils:Create("Frame", {
        Parent = ESPContainer,
        ZIndex = -1,
        BackgroundColor3 = config.HealthbarOutlineColor or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0,
        Visible = false
    })

    local HealthOutline = Utils:Create("UIStroke", {
        Parent = BehindHealthbar,
        Transparency = 0,
        Color = config.HealthbarOutlineColor or Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1
    })

    local HealthGradient = Utils:Create("UIGradient", {
        Parent = Healthbar,
        Enabled = config.HealthGradient or true,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
        }
    })

    return {
        Container = ESPContainer,
        Highlight = Highlight, 
        Name = Name,
        Distance = Distance,
        Healthbar = Healthbar,
        BehindHealthbar = BehindHealthbar,
        HealthOutline = HealthOutline,
        HealthGradient = HealthGradient
    }
end

local function UpdateESP(espObj, obj, objType, distance, position)
    local config = SimpleESP[objType]
    if not config then return false end

    local screenPos, onScreen = Cam:WorldToScreenPoint(position)
    if not onScreen or distance > (config.MaxDistance or SimpleESP.Settings.MaxDistance) then

        espObj.Highlight.Enabled = false
        espObj.Name.Visible = false
        espObj.Distance.Visible = false
        espObj.Healthbar.Visible = false
        espObj.BehindHealthbar.Visible = false
        return false
    end

    local size = 15 

    local success, result = pcall(function()
        if obj:IsA("Model") then
            local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                return humanoidRootPart.Size.Y
            end

            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("BasePart") then
                    return child.Size.Y
                end
            end
        elseif obj:IsA("BasePart") then
            return obj.Size.Y
        end

        return 15 
    end)

    if success then
        size = result
    end

    local boxScaleFactor = 0.7

    local scaleFactor = (size * Cam.ViewportSize.Y) / (screenPos.Z * 2) * boxScaleFactor
    local w, h = 3 * scaleFactor, 4.5 * scaleFactor

    if SimpleESP.Settings.FadeOut.OnDistance then
        local fadeTransparency = math.min(1, distance / (config.MaxDistance or SimpleESP.Settings.MaxDistance))

        espObj.Name.TextTransparency = fadeTransparency
        espObj.Name.TextStrokeTransparency = fadeTransparency
        espObj.Distance.TextTransparency = fadeTransparency
        espObj.Distance.TextStrokeTransparency = fadeTransparency
        espObj.Healthbar.BackgroundTransparency = fadeTransparency
        espObj.BehindHealthbar.BackgroundTransparency = fadeTransparency
        espObj.HealthOutline.Transparency = fadeTransparency

        espObj.Highlight.FillTransparency = math.min(1, config.ChamsFillTransparency + fadeTransparency * 0.5)
        espObj.Highlight.OutlineTransparency = math.min(1, config.ChamsOutlineTransparency + fadeTransparency * 0.5)
    else

        espObj.Highlight.FillTransparency = config.ChamsFillTransparency or 0.5
        espObj.Highlight.OutlineTransparency = config.ChamsOutlineTransparency or 0
    end

    if config.ShowChams then

        if espObj.Highlight.Adornee ~= obj then
            espObj.Highlight.Adornee = obj
        end

        espObj.Highlight.FillColor = config.ChamsColor or config.Color
        espObj.Highlight.OutlineColor = config.ChamsOutlineColor or config.Color
        espObj.Highlight.Enabled = true
    else
        espObj.Highlight.Enabled = false
    end

local showName = config.ShowName
local showLevel = (objType == "Players" and config.ShowLevel)

if showName or showLevel then

    espObj.Name.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - h/2 - 15)

    local nameText = ""
    if showName then
        nameText = obj.Name

        if objType == "Mobs" then
            nameText = nameText .. " [Mob]"
        end
    end

    if showLevel then
        local level = Utils:GetPlayerLevel(Players:FindFirstChild(obj.Name))
        local levelText = "[Lv." .. tostring(level) .. "]"

        if nameText ~= "" then
            nameText = nameText .. " " .. levelText
        else
            nameText = levelText
        end
    end

    espObj.Name.Text = nameText
    espObj.Name.TextColor3 = config.NameColor or config.Color
    espObj.Name.Visible = true
else
    espObj.Name.Visible = false
end

    if config.ShowDistance then
        espObj.Distance.Text = Utils:FormatDistance(distance)
        espObj.Distance.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + h/2 + 5)
        espObj.Distance.TextColor3 = config.DistanceColor or Color3.fromRGB(200, 200, 200)
        espObj.Distance.Visible = true
    else
        espObj.Distance.Visible = false
    end

    if config.ShowHealthbar and objType ~= "Items" then
        local healthPercent = Utils:GetHealthPercentage(obj)

        espObj.Healthbar.Position = UDim2.new(0, screenPos.X - w/2 - 6, 0, screenPos.Y - h/2 + h * (1 - healthPercent))
        espObj.Healthbar.Size = UDim2.new(0, 2.5, 0, h * healthPercent)
        espObj.Healthbar.Visible = true

        espObj.BehindHealthbar.Position = UDim2.new(0, screenPos.X - w/2 - 6, 0, screenPos.Y - h/2)
        espObj.BehindHealthbar.Size = UDim2.new(0, 2.5, 0, h)
        espObj.BehindHealthbar.Visible = true

        if config.HealthGradient then
            espObj.HealthGradient.Enabled = true
            espObj.HealthGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, config.HealthColors.Low),
                ColorSequenceKeypoint.new(0.5, config.HealthColors.Mid),
                ColorSequenceKeypoint.new(1, config.HealthColors.High)
            }
        else
            espObj.HealthGradient.Enabled = false
            espObj.Healthbar.BackgroundColor3 = Utils:GetLerpColor(healthPercent, config.HealthColors)
        end
    else
        espObj.Healthbar.Visible = false
        espObj.BehindHealthbar.Visible = false
    end

    return true
end

local ESPObjects = {}

local function CreatePlayerESP()

    for id, obj in pairs(ESPObjects) do
        if id:find("Player_") then
            obj.Container:Destroy()
            ESPObjects[id] = nil
        end
    end

    local charactersFolder = workspace.Objects:FindFirstChild("Characters")
    if not charactersFolder then return end

    for _, playerChar in pairs(charactersFolder:GetChildren()) do
        local playerName = playerChar.Name
        if playerName ~= LocalPlayer.Name then
            local id = "Player_" .. playerName
            ESPObjects[id] = CreateESPObject(id, "Players")
        end
    end
end

local function CreateMobESP()

    for id, obj in pairs(ESPObjects) do
        if id:find("Mob_") then
            obj.Container:Destroy()
            ESPObjects[id] = nil
        end
    end

    local mobsFolder = workspace.Objects:FindFirstChild("Mobs")
    if not mobsFolder then return end

    for _, mob in pairs(mobsFolder:GetChildren()) do
        local id = "Mob_" .. mob.Name .. "_" .. mob:GetDebugId()
        ESPObjects[id] = CreateESPObject(id, "Mobs")
    end
end

local function CreateItemESP()

    for id, obj in pairs(ESPObjects) do
        if id:find("Item_") then
            obj.Container:Destroy()
            ESPObjects[id] = nil
        end
    end

    local dropsFolder = workspace.Objects:FindFirstChild("Drops")
    if not dropsFolder then return end

    for _, item in pairs(dropsFolder:GetChildren()) do
        local id = "Item_" .. item.Name .. "_" .. item:GetDebugId()
        ESPObjects[id] = CreateESPObject(id, "Items")
    end
end

local function UpdateAllESP()
    if not SimpleESP.Enabled then
        for _, obj in pairs(ESPObjects) do
            obj.Container.Visible = false
        end
        return
    end

    if SimpleESP.Players.Enabled then
        local charactersFolder = workspace.Objects:FindFirstChild("Characters")
        if charactersFolder then
            for _, playerChar in pairs(charactersFolder:GetChildren()) do
                if playerChar.Name ~= LocalPlayer.Name then
                    local id = "Player_" .. playerChar.Name
                    local espObj = ESPObjects[id]

                    if espObj then

                        local rootPart = playerChar:FindFirstChild("HumanoidRootPart") or 
                                         playerChar:FindFirstChild("Torso") or
                                         playerChar:FindFirstChild("UpperTorso") or
                                         playerChar.PrimaryPart or
                                         playerChar:FindFirstChildOfClass("BasePart")

                        if rootPart then
                            local position = rootPart.Position
                            local distance = Utils:GetDistanceFromCamera(position)
                            UpdateESP(espObj, playerChar, "Players", distance, position)
                        else
                            espObj.Container.Visible = false
                        end
                    end
                end
            end
        end
    end

    if SimpleESP.Mobs.Enabled then
        local mobsFolder = workspace.Objects:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in pairs(mobsFolder:GetChildren()) do
                local id = "Mob_" .. mob.Name .. "_" .. mob:GetDebugId()
                local espObj = ESPObjects[id]

                if espObj then

                    local primaryPart = mob.PrimaryPart or 
                                       mob:FindFirstChild("HumanoidRootPart") or
                                       mob:FindFirstChild("Torso") or
                                       mob:FindFirstChild("UpperTorso") or
                                       mob:FindFirstChildOfClass("BasePart")

                    if primaryPart then
                        local position = primaryPart.Position
                        local distance = Utils:GetDistanceFromCamera(position)
                        UpdateESP(espObj, mob, "Mobs", distance, position)
                    else
                        espObj.Container.Visible = false
                    end
                else

                    ESPObjects[id] = CreateESPObject(id, "Mobs")
                end
            end
        end
    end

    if SimpleESP.Items.Enabled then
        local dropsFolder = workspace.Objects:FindFirstChild("Drops")
        if dropsFolder then
            for _, item in pairs(dropsFolder:GetChildren()) do
                local id = "Item_" .. item.Name .. "_" .. item:GetDebugId()
                local espObj = ESPObjects[id]

                if espObj then

                    local primaryPart = item.PrimaryPart or
                                       item:FindFirstChildOfClass("BasePart") or
                                       (item:IsA("BasePart") and item)

                    if primaryPart then
                        local position = primaryPart.Position
                        local distance = Utils:GetDistanceFromCamera(position)
                        UpdateESP(espObj, item, "Items", distance, position)
                    else
                        espObj.Container.Visible = false
                    end
                else

                    ESPObjects[id] = CreateESPObject(id, "Items")
                end
            end
        end
    end
end

function SimpleESP:Initialize()

    CreatePlayerESP()
    CreateMobESP()
    CreateItemESP()

    workspace.Objects.ChildAdded:Connect(function(child)
        if child.Name == "Characters" then
            CreatePlayerESP()
        elseif child.Name == "Mobs" then
            CreateMobESP()
        elseif child.Name == "Drops" then
            CreateItemESP()
        end
    end)

    if workspace.Objects:FindFirstChild("Characters") then
        workspace.Objects.Characters.ChildAdded:Connect(function(child)
            if child.Name ~= LocalPlayer.Name then
                local id = "Player_" .. child.Name
                ESPObjects[id] = CreateESPObject(id, "Players")
            end
        end)

        workspace.Objects.Characters.ChildRemoved:Connect(function(child)
            local id = "Player_" .. child.Name
            if ESPObjects[id] then
                ESPObjects[id].Container:Destroy()
                ESPObjects[id] = nil
            end
        end)
    end

    if workspace.Objects:FindFirstChild("Mobs") then
        workspace.Objects.Mobs.ChildAdded:Connect(function(child)
            local id = "Mob_" .. child.Name .. "_" .. child:GetDebugId()
            ESPObjects[id] = CreateESPObject(id, "Mobs")
        end)

        workspace.Objects.Mobs.ChildRemoved:Connect(function(child)
            for id, obj in pairs(ESPObjects) do
                if id:find("Mob_" .. child.Name .. "_" .. child:GetDebugId()) then
                    obj.Container:Destroy()
                    ESPObjects[id] = nil
                    break
                end
            end
        end)
    end

    if workspace.Objects:FindFirstChild("Drops") then
        workspace.Objects.Drops.ChildAdded:Connect(function(child)
            local id = "Item_" .. child.Name .. "_" .. child:GetDebugId()
            ESPObjects[id] = CreateESPObject(id, "Items")
        end)

        workspace.Objects.Drops.ChildRemoved:Connect(function(child)
            for id, obj in pairs(ESPObjects) do
                if id:find("Item_" .. child.Name .. "_" .. child:GetDebugId()) then
                    obj.Container:Destroy()
                    ESPObjects[id] = nil
                    break
                end
            end
        end)
    end

    local lastUpdate = 0
    RunService:BindToRenderStep("SimpleESP", Enum.RenderPriority.Camera.Value + 1, function()
        if tick() - lastUpdate >= SimpleESP.Settings.RefreshRate then
            lastUpdate = tick()
            UpdateAllESP()
        end
    end)

    print("Init")
end

return SimpleESP
