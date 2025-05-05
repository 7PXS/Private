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
    Drawing = {
        Names = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Distances = {
            Enabled = true, 
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Healthbar = {
            Enabled = true,  
            HealthText = true, 
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
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(17, 168, 255),
            },
        },
        Weapon = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 230, 0)
        },
        MobInfo = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 100, 100),
        },
        NPCInfo = {
            Enabled = true,
            RGB = Color3.fromRGB(0, 255, 100),
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
        return "npc"
    elseif Players:GetPlayerFromCharacter(entity) then
        return "player"
    else
        return "mob"
    end
end

local function GetEntityName(entity, entityType)
    if entityType == "player" then
        return entity.Name
    elseif entityType == "mob" then
        return entity.Name .. " [Mob]"
    elseif entityType == "npc" then
        return entity.Name .. " [NPC]"
    else
        return entity.Name
    end
end

local function ApplyESPToEntity(entity, entityType)

    entityType = entityType or GetEntityType(entity)

    if entityType == "player" and entity.Name == LocalPlayer.Name then return end

    local entityName = GetEntityName(entity, entityType)
    local uniqueId = entity.Name .. "_" .. (math.random(1000, 9999))
    coroutine.wrap(DupeCheck)(uniqueId)

    local ESPContainer = Functions:Create("Folder", {
        Parent = ScreenGui,
        Name = uniqueId
    })

    local Box, Outline
    if entityType ~= "npc" then
        Box = Functions:Create("Frame", {
            Parent = ESPContainer, 
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
            BackgroundTransparency = 0.75, 
            BorderSizePixel = 0
        })

        local outlineColor
        if entityType == "player" then
            outlineColor = SimpleESP.Drawing.Boxes.Full.RGB
        else 
            outlineColor = SimpleESP.Drawing.MobInfo.RGB
        end

        Outline = Functions:Create("UIStroke", {
            Parent = Box, 
            Transparency = 0, 
            Color = outlineColor, 
            LineJoinMode = Enum.LineJoinMode.Miter
        })
    end

    local nameColor
    if entityType == "player" then
        nameColor = SimpleESP.Drawing.Names.RGB
    elseif entityType == "mob" then
        nameColor = SimpleESP.Drawing.MobInfo.RGB
    elseif entityType == "npc" then
        nameColor = SimpleESP.Drawing.NPCInfo.RGB
    else
        nameColor = Color3.fromRGB(255, 255, 255)
    end

    local Name = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, -11), 
        Size = UDim2.new(0, 150, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = nameColor, 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Center 
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
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Center 
    })

    local Healthbar, BehindHealthbar, HealthbarGradient, HealthText
    if entityType ~= "npc" then
        Healthbar = Functions:Create("Frame", {
            Parent = ESPContainer, 
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
            BackgroundTransparency = 0
        })

        BehindHealthbar = Functions:Create("Frame", {
            Parent = ESPContainer, 
            ZIndex = -1, 
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
            BackgroundTransparency = 0
        })

        HealthbarGradient = Functions:Create("UIGradient", {
            Parent = Healthbar, 
            Enabled = SimpleESP.Drawing.Healthbar.Gradient, 
            Rotation = -90, 
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, SimpleESP.Drawing.Healthbar.GradientRGB1), 
                ColorSequenceKeypoint.new(0.5, SimpleESP.Drawing.Healthbar.GradientRGB2), 
                ColorSequenceKeypoint.new(1, SimpleESP.Drawing.Healthbar.GradientRGB3)
            }
        })

        HealthText = Functions:Create("TextLabel", {
            Parent = ESPContainer, 
            Position = UDim2.new(0.5, 0, 0, 31), 
            Size = UDim2.new(0, 100, 0, 20), 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundTransparency = 1, 
            TextColor3 = SimpleESP.Drawing.Healthbar.HealthTextRGB, 
            Font = Enum.Font.Code, 
            TextSize = SimpleESP.FontSize, 
            TextStrokeTransparency = 0, 
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center 
        })
    end

    local WeaponInfo = Functions:Create("TextLabel", {
        Parent = ESPContainer, 
        Position = UDim2.new(0.5, 0, 0, 48), 
        Size = UDim2.new(0, 120, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = SimpleESP.Drawing.Weapon.RGB, 
        Font = Enum.Font.Code, 
        TextSize = SimpleESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center 
    })

    local function HideESP()
        Name.Visible = false
        Distance.Visible = false
        WeaponInfo.Visible = false

        if entityType ~= "npc" then
            Box.Visible = false
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            HealthText.Visible = false
        end

        if not entity or not entity.Parent then
            ESPContainer:Destroy()
        end
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not SimpleESP.Enabled then 
            HideESP()
            return
        end

        if entityType == "player" and not SimpleESP.ShowPlayers then
            HideESP()
            return
        end

        if entityType == "mob" and not SimpleESP.ShowMobs then
            HideESP()
            return
        end

        if entityType == "npc" and not SimpleESP.ShowNPCs then
            HideESP()
            return
        end

        if entity and entity:FindFirstChild("HumanoidRootPart") then
            local HRP = entity.HumanoidRootPart
            local Humanoid = entity:FindFirstChild("Humanoid")

            if not Humanoid then
                HideESP()
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

                if SimpleESP.FadeOut.OnDistance then
                    Functions:FadeOutOnDist(Name, Dist)
                    Functions:FadeOutOnDist(Distance, Dist)
                    Functions:FadeOutOnDist(WeaponInfo, Dist)

                    if entityType ~= "npc" then
                        Functions:FadeOutOnDist(Box, Dist)
                        Functions:FadeOutOnDist(Outline, Dist)
                        Functions:FadeOutOnDist(Healthbar, Dist)
                        Functions:FadeOutOnDist(BehindHealthbar, Dist)
                        Functions:FadeOutOnDist(HealthText, Dist)
                    end
                end

                if entityType ~= "npc" then
                    Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                    Box.Size = UDim2.new(0, w, 0, h)
                    Box.Visible = SimpleESP.Drawing.Boxes.Full.Enabled

                    if SimpleESP.Drawing.Boxes.Filled.Enabled then
                        Box.BackgroundTransparency = SimpleESP.Drawing.Boxes.Filled.Transparency
                        Box.BackgroundColor3 = SimpleESP.Drawing.Boxes.Filled.RGB
                    else
                        Box.BackgroundTransparency = 1
                    end
                end

                if entityType ~= "npc" then
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
                end

                Name.Visible = SimpleESP.Drawing.Names.Enabled
                Name.Text = GetEntityName(entity, entityType)
                Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 15)

                Distance.Visible = SimpleESP.Drawing.Distances.Enabled
                Distance.Text = string.format("%d meters", math.floor(Dist))
                Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)

                if entityType == "player" and SimpleESP.Drawing.Weapon.Enabled then
                    local weaponName = GetWeaponName(entity)
                    WeaponInfo.Text = "Weapon: " .. weaponName
                    WeaponInfo.Visible = true
                    WeaponInfo.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 24)
                else
                    WeaponInfo.Visible = false
                end

            else
                HideESP()
            end
        else
            HideESP()
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
                    coroutine.wrap(ApplyESPToEntity)(character, "player")
                end
            end

            workspace.PlayerCharacters.ChildAdded:Connect(function(character)
                if character.Name ~= LocalPlayer.Name then
                    wait(0.5) 
                    coroutine.wrap(ApplyESPToEntity)(character, "player")
                end
            end)
        else
            print("PlayerCharacters folder not found, checking Players service...")

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    coroutine.wrap(ApplyESPToEntity)(player.Character, "player")
                end
            end

            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    wait(0.5)
                    coroutine.wrap(ApplyESPToEntity)(character, "player")
                end)
            end)
        end

        local function ProcessEntity(entity)
            if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") then
                local entityType = GetEntityType(entity)
                if entityType ~= "player" then 
                    coroutine.wrap(ApplyESPToEntity)(entity, entityType)
                end
            end
        end

        local possibleFolders = {
            workspace:FindFirstChild("Mobs"),
            workspace:FindFirstChild("Enemies"),
            workspace:FindFirstChild("Monsters"),
            workspace:FindFirstChild("NPCs"),
            workspace:FindFirstChild("NPC"),
            workspace:FindFirstChild("NonPlayerCharacters")
        }

        for _, folder in pairs(possibleFolders) do
            if folder then
                print("Found entities in folder: " .. folder.Name)
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

function SimpleESP:CleanUp()
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

print("Init")

return SimpleESP
