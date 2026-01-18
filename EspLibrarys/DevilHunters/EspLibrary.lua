local function LoadLibrary()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")

    local function get_hui()
        return gethui and gethui() or CoreGui
    end

    local function clone_ref(instance)
        return cloneref and cloneref(instance) or instance
    end

    if getgenv and getgenv().RoESP then 
        local OldEsp = getgenv().RoESP
        if type(OldEsp.Unload) == "function" then
            task.spawn(OldEsp.Unload)
        end
        getgenv().RoESP = nil 
    end 

    local ESPFonts = {}

    local Theme = {
        Accent = Color3.fromRGB(170, 110, 255),
        Background = Color3.fromRGB(15, 15, 20),
        Text = Color3.fromRGB(235, 225, 255),
        Border = Color3.fromRGB(40, 38, 48),
        Shadow = Color3.fromRGB(0, 0, 0)
    }

    local PlayerOptions = {
        ["Enabled"] = true,
        ["TeamCheck"] = false,
        ["Boxes"] = true,
        ["BoxType"] = "Corner",
        ["Box Gradient 1"] = { Color = Theme.Accent, Transparency = 0.8 },
        ["Box Gradient 2"] = { Color = Theme.Accent, Transparency = 0.8 },
        ["Box Fill"] = false,
        ["Box Fill 1"] = { Color = Theme.Background, Transparency = 0.5 },
        ["Box Fill 2"] = { Color = Theme.Background, Transparency = 0.5 },
        ["Healthbar"] = true,
        ["Healthbar_Position"] = "Left",
        ["Healthbar_Width"] = 3,
        ["PostureBar"] = true,
        ["PostureBar_Width"] = 3,
        ["Name_Text"] = true,
        ["Name_Text_Size"] = 11,
        ["Rank_Text"] = true,
        ["Distance_Text"] = true,
        ["Distance_Text_Size"] = 11,
        ["Weapon_Text"] = true,
        ["Weapon_Text_Size"] = 11,
        ["Chams"] = false,
        ["Chams_Fill_Color"] = { Color = Theme.Accent, Transparency = 0.5 },
        ["Skeleton"] = false,
        ["Skeleton_Thickness"] = 1.5,
        ["Skeleton_Color"] = { Color = Color3.new(1,1,1), Transparency = 0 },
    }

    local MobOptions = {
        ["Enabled"] = true,
        ["Filters"] = {
            ["Yakuza"] = true,
            ["Devils"] = true,
            ["Disciples"] = true,
        },
        ["Boxes"] = true,
        ["BoxType"] = "Corner",
        ["Box Gradient 1"] = { Color = Color3.fromRGB(255, 50, 50), Transparency = 0.8 },
        ["Box Gradient 2"] = { Color = Color3.fromRGB(255, 50, 50), Transparency = 0.8 },
        ["Box Fill"] = false,
        ["Box Fill 1"] = { Color = Theme.Background, Transparency = 0.5 },
        ["Healthbar"] = true,
        ["Healthbar_Position"] = "Left",
        ["Healthbar_Width"] = 3,
        ["Name_Text"] = true,
        ["Name_Text_Size"] = 11,
        ["Distance_Text"] = true,
        ["Distance_Text_Size"] = 11,
        ["Chams"] = false,
        ["Chams_Fill_Color"] = { Color = Color3.fromRGB(255, 50, 50), Transparency = 0.5 },
    }

    local Workspace = clone_ref(game:GetService("Workspace"))
    local RunService = clone_ref(game:GetService("RunService"))
    local HttpService = clone_ref(game:GetService("HttpService"))
    local Players = clone_ref(game:GetService("Players"))
    local TweenService = clone_ref(game:GetService("TweenService"))

    local vec2 = Vector2.new
    local vec3 = Vector3.new
    local dim2 = UDim2.new
    local dim = UDim.new 
    local rect = Rect.new
    local cfr = CFrame.new
    local dim_offset = UDim2.fromOffset
    local rgb = Color3.fromRGB
    local rgbseq = ColorSequence.new
    local rgbkey = ColorSequenceKeypoint.new
    local numseq = NumberSequence.new
    local numkey = NumberSequenceKeypoint.new
    local camera = Workspace.CurrentCamera

    local Fonts = {}
    do
        local function RegisterFont(Name, Weight, Style, Asset)
            if not isfile(Asset.Id) then
                writefile(Asset.Id, Asset.Font)
            end

            local Data = {
                name = Name,
                faces = {
                    {
                        name = "Normal",
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Asset.Id),
                    },
                },
            }

            if not isfile(Name .. ".font") then
                writefile(Name .. ".font", HttpService:JSONEncode(Data))
            end

            return getcustomasset(Name .. ".font")
        end

        local FontNames = {
            ["Verdana"] = "Verdana-Font.ttf",
        }

        for name, suffix in pairs(FontNames) do 
            local success, result = pcall(function()
                return game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/" .. suffix)
            end)

            if success then
                local RegisteredFont = RegisterFont(name, 400, "Normal", {
                    Id = suffix,
                    Font = result,
                }) 
                Fonts[name] = Font.new(RegisteredFont, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                ESPFonts[name] = Font.new(RegisteredFont, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            else
                Fonts[name] = Font.fromEnum(Enum.Font.SourceSans)
                ESPFonts[name] = Font.fromEnum(Enum.Font.SourceSans)
            end
        end
    end

    local Esp = { 
        PlayerESPs = {},
        MobESPs = {},
        ScreenGui = Instance.new("ScreenGui", get_hui()), 
        Cache = Instance.new("ScreenGui", get_hui()), 
        Connections = {}, 
        PlayerOptions = PlayerOptions,
        MobOptions = MobOptions,
    }
    
    if getgenv then getgenv().RoESP = Esp end

    Esp.ScreenGui.IgnoreGuiInset = true
    Esp.ScreenGui.Name = "RoESP"
    Esp.Cache.Enabled = false

    function Esp:Create(instance, options)
        local Ins = Instance.new(instance) 
        for prop, value in pairs(options) do 
            Ins[prop] = value
        end
        return Ins 
    end

    function Esp:ConvertScreenPoint(world_position)
        local ViewportSize = camera.ViewportSize
        local LocalPos = camera.CFrame:pointToObjectSpace(world_position) 
        local AspectRatio = ViewportSize.X / ViewportSize.Y
        local HalfY = -LocalPos.Z * math.tan(math.rad(camera.FieldOfView / 2))
        local HalfX = AspectRatio * HalfY
        local FarPlaneCorner = Vector3.new(-HalfX, HalfY, LocalPos.Z)
        local RelativePos = LocalPos - FarPlaneCorner
        local ScreenX = RelativePos.X / (HalfX * 2)
        local ScreenY = -RelativePos.Y / (HalfY * 2)
        local OnScreen = -LocalPos.Z > 0 and ScreenX >= 0 and ScreenX <= 1 and ScreenY >= 0 and ScreenY <= 1
        return Vector3.new(ScreenX * ViewportSize.X, ScreenY * ViewportSize.Y, -LocalPos.Z), OnScreen
    end

    function Esp:Connection(signal, callback)
        local Connection = signal:Connect(callback)
        Esp.Connections[#Esp.Connections + 1] = Connection
        return Connection 
    end

    function Esp:BoxSolve(torso)
        if not torso then return nil, nil, nil end 
        local ViewportTop = torso.Position + (torso.CFrame.UpVector * 1.8) + camera.CFrame.UpVector
        local ViewportBottom = torso.Position - (torso.CFrame.UpVector * 2.5) - camera.CFrame.UpVector
        local Distance = (torso.Position - camera.CFrame.p).Magnitude / 3.5714285714
        local NewDistance = math.floor(Distance * 0.333)
        local Top, TopIsRendered = Esp:ConvertScreenPoint(ViewportTop)
        local Bottom, BottomIsRendered = Esp:ConvertScreenPoint(ViewportBottom)
        local Width = math.max(math.floor(math.abs(Top.X - Bottom.X)), 3)
        local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 3)
        local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
        local BoxPosition = Vector2.new(math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5), math.floor(math.min(Top.Y, Bottom.Y)))
        return BoxSize, BoxPosition, TopIsRendered, NewDistance 
    end

    function Esp:CreateBone(parent)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        f.BackgroundColor3 = Color3.new(1,1,1)
        f.BackgroundTransparency = 0
        f.ZIndex = 1
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0,0,0)
        stroke.Thickness = 1
        stroke.Parent = f
        
        f.Parent = parent
        return f
    end

    function Esp.CreatePlayerESP(player)
        local Data = { 
            Items = {}, 
            Info = {
                Character = nil,
                Humanoid = nil,
                Health = 0,
                Player = player,
                OldHealth = 0,
                TeamColor = player.TeamColor and player.TeamColor.Color or Color3.new(1,1,1),
                Posture = 0,
                MaxPosture = 100,
                Rank = nil,
            },
            Type = "player",
            Bones = {},
            RigType = nil 
        }

        local Items = Data.Items

        Items.Holder = Esp:Create("Frame", {
            Parent = Esp.ScreenGui,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0.5, 0, 0.5, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 211, 0, 240),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Items.HolderGradient = Esp:Create("UIGradient", {
            Rotation = 0,
            Name = "\0",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(255, 255, 255))},
            Parent = Items.Holder,
            Enabled = false
        })

        Items.Left = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(0, 0, 1, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, -1, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Left,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items.LeftTexts = Esp:Create("Frame", {
            LayoutOrder = -100,
            Parent = Items.Left,
            BackgroundTransparency = 1,
            Name = "\0",
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            Parent = Items.LeftTexts,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items.Right = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(0, 0, 1, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(1, 1, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Right,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items.Bottom = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(1, 0, 0, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 1, 1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255),
            AutomaticSize = Enum.AutomaticSize.Y 
        })

        Esp:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Bottom,
            Padding = dim(0, 1)
        })

        Items.BottomTexts = Esp:Create("Frame", {
            LayoutOrder = 1, 
            Parent = Items.Bottom,
            BackgroundTransparency = 1,
            Name = "\0",
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            Parent = Items.BottomTexts,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        Items.Top = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(1, 0, 0, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, -1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Top,
            Padding = dim(0, 1)
        })

        Items.TopTexts = Esp:Create("Frame", {
            LayoutOrder = -100,
            Parent = Items.Top,
            BackgroundTransparency = 1,
            Name = "\0",
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            Parent = Items.TopTexts,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        Items.Corners = Esp:Create("Frame", {
            Parent = Esp.Cache,
            Name = "\0",
            BackgroundTransparency = 1,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local function CreateCornerLine(name, pos, size, anchor)
            local f = Esp:Create("Frame", {
                Parent = Items.Corners,
                Name = name,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = pos,
                Size = size,
                AnchorPoint = anchor,
                ZIndex = 2
            })
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.new(0,0,0)
            stroke.Thickness = 1
            stroke.Parent = f
            Esp:Create("UIGradient", {Parent = f, Color = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(255,255,255))}})
        end

        local cornerSize = 0.2
        CreateCornerLine("TL_H", dim2(0,0,0,0), dim2(cornerSize, 0, 0, 1), Vector2.new(0,0))
        CreateCornerLine("TL_V", dim2(0,0,0,0), dim2(0, 1, cornerSize, 0), Vector2.new(0,0))
        CreateCornerLine("TR_H", dim2(1,0,0,0), dim2(cornerSize, 0, 0, 1), Vector2.new(1,0))
        CreateCornerLine("TR_V", dim2(1,0,0,0), dim2(0, 1, cornerSize, 0), Vector2.new(1,0))
        CreateCornerLine("BL_H", dim2(0,0,1,0), dim2(cornerSize, 0, 0, 1), Vector2.new(0,1))
        CreateCornerLine("BL_V", dim2(0,0,1,0), dim2(0, 1, cornerSize, 0), Vector2.new(0,1))
        CreateCornerLine("BR_H", dim2(1,0,1,0), dim2(cornerSize, 0, 0, 1), Vector2.new(1,1))
        CreateCornerLine("BR_V", dim2(1,0,1,0), dim2(0, 1, cornerSize, 0), Vector2.new(1,1))

        Items.Box = Esp:Create("Frame", {
            Parent = Esp.Cache,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIStroke", {
            Parent = Items.Box,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Inner = Esp:Create("Frame", {
            Parent = Items.Box,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Items.UIStroke = Esp:Create("UIStroke", {
            Color = rgb(255,255,255),
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = Items.Inner
        })

        Items.BoxGradient = Esp:Create("UIGradient", {
            Parent = Items.UIStroke
        })

        Items.Healthbar = Esp:Create("Frame", {
            Name = "Left",
            Parent = Esp.Cache,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, PlayerOptions.Healthbar_Width + 2, 0, PlayerOptions.Healthbar_Width + 2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(0, 0, 0),
            LayoutOrder = 100 
        })

        Items.HealthbarAccent = Esp:Create("Frame", {
            Parent = Items.Healthbar,
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Items.HealthbarGradient = Esp:Create("UIGradient", {
            Enabled = true,
            Parent = Items.HealthbarAccent,
            Rotation = 90,
            Color = rgbseq{rgbkey(0, rgb(0, 255, 0)), rgbkey(0.5, rgb(255, 125, 0)), rgbkey(1, rgb(255, 0, 0))}
        })

        Items.PostureBar = Esp:Create("Frame", {
            Name = "Right",
            Parent = Esp.Cache,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, PlayerOptions.PostureBar_Width + 2, 0, PlayerOptions.PostureBar_Width + 2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(0, 0, 0),
            LayoutOrder = 100 
        })

        Items.PostureBarAccent = Esp:Create("Frame", {
            Parent = Items.PostureBar,
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(100, 150, 255)
        })

        Items.Text = Esp:Create("TextLabel", {
            FontFace = Fonts.Verdana or Font.fromEnum(Enum.Font.SourceSans),
            TextColor3 = rgb(255, 255, 255),
            BorderColor3 = rgb(0, 0, 0),
            Parent = Esp.Cache,
            Name = "Top",
            Text = player.Name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = PlayerOptions.Name_Text_Size,
            BackgroundColor3 = rgb(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Center
        })

        Esp:Create("UIStroke", {
            Parent = Items.Text,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Weapon = Esp:Create("TextLabel", {
            FontFace = Fonts.Verdana or Font.fromEnum(Enum.Font.SourceSans),
            TextColor3 = rgb(255, 255, 255),
            BorderColor3 = rgb(0, 0, 0),
            Parent = Esp.Cache,
            Name = "Bottom",
            Text = "",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = PlayerOptions.Weapon_Text_Size,
            BackgroundColor3 = rgb(255, 255, 255),
            LayoutOrder = 1,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        Esp:Create("UIStroke", {
            Parent = Items.Weapon,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Distance = Esp:Create("TextLabel", {
            FontFace = Fonts.Verdana or Font.fromEnum(Enum.Font.SourceSans),
            TextColor3 = rgb(255,255, 255),
            BorderColor3 = rgb(0, 0, 0),
            Parent = Esp.Cache,
            Name = "Bottom",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = PlayerOptions.Distance_Text_Size,
            BackgroundColor3 = rgb(255, 255, 255),
            LayoutOrder = 2,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        Esp:Create("UIStroke", {
            Parent = Items.Distance,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Chams = Instance.new("Highlight")
        Items.Chams.Name = "RoESPChams"
        Items.Chams.Enabled = false
        Items.Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Items.Chams.FillColor = PlayerOptions.Chams_Fill_Color.Color
        Items.Chams.FillTransparency = PlayerOptions.Chams_Fill_Color.Transparency
        Items.Chams.OutlineColor = Color3.new(0,0,0)
        Items.Chams.OutlineTransparency = 1

        for i = 1, 15 do
            table.insert(Data.Bones, Esp:CreateBone(Esp.ScreenGui))
        end

        Data.RefreshDescendants = function()
            local Character = player.Character
            if not Character then
                player.CharacterAdded:Wait()
                Character = player.Character
            end

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")

            if not Humanoid or not RootPart then return end

            Data.Info.Character = Character
            Data.Info.Humanoid = Humanoid
            Data.Info.rootpart = RootPart
            Data.Info.TeamColor = player.TeamColor.Color
            Data.RigType = Humanoid.RigType

            if Items.Chams then
                Items.Chams.Parent = Character
            end

            local rank = player:GetAttribute("Rank")
            if not rank then
                local leaderstats = player:FindFirstChild("leaderstats")
                if leaderstats then
                    local rankValue = leaderstats:FindFirstChild("Rank")
                    if rankValue then
                        rank = tostring(rankValue.Value)
                    end
                end
            end
            Data.Info.Rank = rank

            Esp:Connection(Humanoid.HealthChanged, function(health)
                Data.Info.Health = health
            end)
        end

        Data.Destroy = function()
            if Items.Holder then 
                Items.Holder:Destroy()
            end 
            if Items.Chams and Items.Chams.Parent then
                Items.Chams:Destroy()
            end
            for i, bone in pairs(Data.Bones) do
                if bone then
                    bone:Destroy()
                end
            end
        end

        task.spawn(Data.RefreshDescendants)
        Esp:Connection(player.CharacterAdded, Data.RefreshDescendants)

        return Data
    end

    function Esp.CreateMobESP(mobEntity)
        local mobName = mobEntity:GetAttribute("Mob") or mobEntity.Name
        local mobGroup = mobEntity:GetAttribute("Group") or "Unknown"

        local Data = { 
            Items = {}, 
            Info = {
                Character = mobEntity,
                Humanoid = nil,
                Health = 0,
                Entity = mobEntity,
                Name = mobName,
                Group = mobGroup,
                TeamColor = Color3.fromRGB(255, 50, 50),
            },
            Type = "mob",
        }

        local Items = Data.Items

        Items.Holder = Esp:Create("Frame", {
            Parent = Esp.ScreenGui,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0.5, 0, 0.5, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 211, 0, 240),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Items.HolderGradient = Esp:Create("UIGradient", {
            Rotation = 0,
            Name = "\0",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(255, 255, 255))},
            Parent = Items.Holder,
            Enabled = false
        })

        Items.Left = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(0, 0, 1, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, -1, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Left,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items.Bottom = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(1, 0, 0, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 1, 1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255),
            AutomaticSize = Enum.AutomaticSize.Y 
        })

        Esp:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Bottom,
            Padding = dim(0, 1)
        })

        Items.BottomTexts = Esp:Create("Frame", {
            LayoutOrder = 1, 
            Parent = Items.Bottom,
            BackgroundTransparency = 1,
            Name = "\0",
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            Parent = Items.BottomTexts,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        Items.Top = Esp:Create("Frame", {
            Parent = Items.Holder,
            Size = dim2(1, 0, 0, 0),
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, -1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = Items.Top,
            Padding = dim(0, 1)
        })

        Items.TopTexts = Esp:Create("Frame", {
            LayoutOrder = -100,
            Parent = Items.Top,
            BackgroundTransparency = 1,
            Name = "\0",
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIListLayout", {
            Parent = Items.TopTexts,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        Items.Corners = Esp:Create("Frame", {
            Parent = Esp.Cache,
            Name = "\0",
            BackgroundTransparency = 1,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        local function CreateCornerLine(name, pos, size, anchor)
            local f = Esp:Create("Frame", {
                Parent = Items.Corners,
                Name = name,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = pos,
                Size = size,
                AnchorPoint = anchor,
                ZIndex = 2
            })
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.new(0,0,0)
            stroke.Thickness = 1
            stroke.Parent = f
            Esp:Create("UIGradient", {Parent = f, Color = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(255,255,255))}})
        end

        local cornerSize = 0.2
        CreateCornerLine("TL_H", dim2(0,0,0,0), dim2(cornerSize, 0, 0, 1), Vector2.new(0,0))
        CreateCornerLine("TL_V", dim2(0,0,0,0), dim2(0, 1, cornerSize, 0), Vector2.new(0,0))
        CreateCornerLine("TR_H", dim2(1,0,0,0), dim2(cornerSize, 0, 0, 1), Vector2.new(1,0))
        CreateCornerLine("TR_V", dim2(1,0,0,0), dim2(0, 1, cornerSize, 0), Vector2.new(1,0))
        CreateCornerLine("BL_H", dim2(0,0,1,0), dim2(cornerSize, 0, 0, 1), Vector2.new(0,1))
        CreateCornerLine("BL_V", dim2(0,0,1,0), dim2(0, 1, cornerSize, 0), Vector2.new(0,1))
        CreateCornerLine("BR_H", dim2(1,0,1,0), dim2(cornerSize, 0, 0, 1), Vector2.new(1,1))
        CreateCornerLine("BR_V", dim2(1,0,1,0), dim2(0, 1, cornerSize, 0), Vector2.new(1,1))

        Items.Box = Esp:Create("Frame", {
            Parent = Esp.Cache,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Esp:Create("UIStroke", {
            Parent = Items.Box,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Inner = Esp:Create("Frame", {
            Parent = Items.Box,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Items.UIStroke = Esp:Create("UIStroke", {
            Color = rgb(255,255,255),
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = Items.Inner
        })

        Items.BoxGradient = Esp:Create("UIGradient", {
            Parent = Items.UIStroke
        })

        Items.Healthbar = Esp:Create("Frame", {
            Name = "Left",
            Parent = Esp.Cache,
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, MobOptions.Healthbar_Width + 2, 0, MobOptions.Healthbar_Width + 2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(0, 0, 0),
            LayoutOrder = 100 
        })

        Items.HealthbarAccent = Esp:Create("Frame", {
            Parent = Items.Healthbar,
            Name = "\0",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        Items.HealthbarGradient = Esp:Create("UIGradient", {
            Enabled = true,
            Parent = Items.HealthbarAccent,
            Rotation = 90,
            Color = rgbseq{rgbkey(0, rgb(0, 255, 0)), rgbkey(0.5, rgb(255, 125, 0)), rgbkey(1, rgb(255, 0, 0))}
        })

        Items.Text = Esp:Create("TextLabel", {
            FontFace = Fonts.Verdana or Font.fromEnum(Enum.Font.SourceSans),
            TextColor3 = rgb(255, 50, 50),
            BorderColor3 = rgb(0, 0, 0),
            Parent = Esp.Cache,
            Name = "Top",
            Text = mobName,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = MobOptions.Name_Text_Size,
            BackgroundColor3 = rgb(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Center
        })

        Esp:Create("UIStroke", {
            Parent = Items.Text,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Distance = Esp:Create("TextLabel", {
            FontFace = Fonts.Verdana or Font.fromEnum(Enum.Font.SourceSans),
            TextColor3 = rgb(255, 50, 50),
            BorderColor3 = rgb(0, 0, 0),
            Parent = Esp.Cache,
            Name = "Bottom",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = MobOptions.Distance_Text_Size,
            BackgroundColor3 = rgb(255, 255, 255),
            LayoutOrder = 1,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        Esp:Create("UIStroke", {
            Parent = Items.Distance,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        Items.Chams = Instance.new("Highlight")
        Items.Chams.Name = "RoESPChams"
        Items.Chams.Enabled = false
        Items.Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Items.Chams.FillColor = MobOptions.Chams_Fill_Color.Color
        Items.Chams.FillTransparency = MobOptions.Chams_Fill_Color.Transparency
        Items.Chams.OutlineColor = Color3.new(0,0,0)
        Items.Chams.OutlineTransparency = 1
        Items.Chams.Parent = mobEntity

        Data.RefreshDescendants = function()
            local Humanoid = mobEntity:FindFirstChildOfClass("Humanoid")
            local RootPart = mobEntity:FindFirstChild("HumanoidRootPart") or mobEntity:FindFirstChild("Torso")

            if Humanoid then
                Data.Info.Humanoid = Humanoid
                Data.Info.rootpart = RootPart

                Esp:Connection(Humanoid.HealthChanged, function(health)
                    Data.Info.Health = health
                end)
            end
        end

        Data.Destroy = function()
            if Items.Holder then 
                Items.Holder:Destroy()
            end 
            if Items.Chams and Items.Chams.Parent then
                Items.Chams:Destroy()
            end
        end

        task.spawn(Data.RefreshDescendants)

        return Data
    end

    function Esp.UpdatePlayerESP()
        if not PlayerOptions.Enabled then
            for _, Data in pairs(Esp.PlayerESPs) do
                if Data.Items and Data.Items.Holder then
                    Data.Items.Holder.Visible = false
                end
                if Data.Items and Data.Items.Chams then
                    Data.Items.Chams.Enabled = false
                end
                if Data.Bones then
                    for _, bone in pairs(Data.Bones) do 
                        if bone then bone.Visible = false end
                    end
                end
            end
            return
        end

        for _, Data in pairs(Esp.PlayerESPs) do
            local player = Data.Info.Player
            local Items = Data.Items
            local Character = Data.Info.Character
            local Humanoid = Data.Info.Humanoid
            local RootPart = Data.Info.rootpart

            if not Items or not Items.Holder then continue end
            if not Character or not Humanoid or not RootPart or Humanoid.Health <= 0 then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                if Data.Bones then
                    for _, bone in pairs(Data.Bones) do 
                        if bone then bone.Visible = false end
                    end
                end
                continue
            end

            if PlayerOptions.TeamCheck and player.Team and Players.LocalPlayer.Team and player.Team == Players.LocalPlayer.Team then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                continue
            end

            local BoxSize, BoxPos, OnScreen, Distance = Esp:BoxSolve(RootPart)

            if not OnScreen then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                if Data.Bones then
                    for _, bone in pairs(Data.Bones) do 
                        if bone then bone.Visible = false end
                    end
                end
                continue
            end

            Items.Holder.Visible = true
            Items.Holder.Position = dim_offset(BoxPos.X, BoxPos.Y)
            Items.Holder.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)

            if PlayerOptions.Boxes then
                if PlayerOptions.BoxType == "Corner" then
                    Items.Corners.Parent = Items.Holder
                    Items.Box.Parent = Esp.Cache
                else
                    Items.Box.Parent = Items.Holder
                    Items.Corners.Parent = Esp.Cache
                end

                local targetColor = player.TeamColor.Color
                if Items.BoxGradient then
                    Items.BoxGradient.Color = rgbseq{rgbkey(0, targetColor), rgbkey(1, targetColor)}
                end
                if Items.Corners then
                    for _, corner in pairs(Items.Corners:GetChildren()) do
                        if corner:IsA("Frame") then
                            local grad = corner:FindFirstChildOfClass("UIGradient")
                            if grad then grad.Color = rgbseq{rgbkey(0, targetColor), rgbkey(1, targetColor)} end
                        end
                    end
                end
            else
                Items.Box.Parent = Esp.Cache
                Items.Corners.Parent = Esp.Cache
            end

            if PlayerOptions.Healthbar then
                Items.Healthbar.Parent = Items.Left
                Items.Healthbar.Size = dim2(0, PlayerOptions.Healthbar_Width + 2, 0, PlayerOptions.Healthbar_Width + 2)
                local healthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
                Items.HealthbarAccent.Size = dim2(1, -2, healthPercent, -2)
                Items.HealthbarAccent.Position = dim2(0, 1, 1 - healthPercent, 1)
            else
                Items.Healthbar.Parent = Esp.Cache
            end

            if PlayerOptions.PostureBar then
                local info = Character:FindFirstChild("Info")
                if info then
                    local posture = info:FindFirstChild("Posture")
                    if posture and (posture:IsA("IntValue") or posture:IsA("NumberValue")) then
                        Data.Info.Posture = posture.Value
                        Items.PostureBar.Parent = Items.Right
                        Items.PostureBar.Size = dim2(0, PlayerOptions.PostureBar_Width + 2, 0, PlayerOptions.PostureBar_Width + 2)
                        local posturePercent = math.clamp(Data.Info.Posture / Data.Info.MaxPosture, 0, 1)
                        Items.PostureBarAccent.Size = dim2(1, -2, posturePercent, -2)
                        Items.PostureBarAccent.Position = dim2(0, 1, 1 - posturePercent, 1)
                    else
                        Items.PostureBar.Parent = Esp.Cache
                    end
                else
                    Items.PostureBar.Parent = Esp.Cache
                end
            else
                Items.PostureBar.Parent = Esp.Cache
            end

            if PlayerOptions.Name_Text then
                local displayName = player.Name
                if PlayerOptions.Rank_Text and Data.Info.Rank then
                    displayName = player.Name .. " [" .. Data.Info.Rank .. "]"
                end
                Items.Text.Text = displayName
                Items.Text.TextSize = PlayerOptions.Name_Text_Size
                Items.Text.Parent = Items.TopTexts
            else
                Items.Text.Parent = Esp.Cache
            end

            if PlayerOptions.Distance_Text then
                Items.Distance.Text = tostring(math.round(Distance)) .. "m"
                Items.Distance.TextSize = PlayerOptions.Distance_Text_Size
                Items.Distance.Parent = Items.BottomTexts
            else
                Items.Distance.Parent = Esp.Cache
            end

            if PlayerOptions.Weapon_Text then
                local weaponName = "None"
                local info = Character:FindFirstChild("Info")
                if info then
                    local weapon = info:FindFirstChild("Weapon")
                    if weapon and weapon:IsA("StringValue") then
                        weaponName = weapon.Value ~= "" and weapon.Value or "None"
                    end
                end
                Items.Weapon.Text = weaponName
                Items.Weapon.TextSize = PlayerOptions.Weapon_Text_Size
                Items.Weapon.Parent = Items.BottomTexts
            else
                Items.Weapon.Parent = Esp.Cache
            end

            Items.Chams.Enabled = PlayerOptions.Chams

            if PlayerOptions.Skeleton and Data.Bones then
                local connections = {}
                if Data.RigType == Enum.HumanoidRigType.R15 then
                    local Head = Character:FindFirstChild("Head")
                    local UpperTorso = Character:FindFirstChild("UpperTorso")
                    local LowerTorso = Character:FindFirstChild("LowerTorso")
                    
                    if UpperTorso and LowerTorso then
                        connections = {
                            {Head, UpperTorso},
                            {UpperTorso, LowerTorso},
                            {UpperTorso, Character:FindFirstChild("LeftUpperArm")},
                            {Character:FindFirstChild("LeftUpperArm"), Character:FindFirstChild("LeftLowerArm")},
                            {Character:FindFirstChild("LeftLowerArm"), Character:FindFirstChild("LeftHand")},
                            {UpperTorso, Character:FindFirstChild("RightUpperArm")},
                            {Character:FindFirstChild("RightUpperArm"), Character:FindFirstChild("RightLowerArm")},
                            {Character:FindFirstChild("RightLowerArm"), Character:FindFirstChild("RightHand")},
                            {LowerTorso, Character:FindFirstChild("LeftUpperLeg")},
                            {Character:FindFirstChild("LeftUpperLeg"), Character:FindFirstChild("LeftLowerLeg")},
                            {Character:FindFirstChild("LeftLowerLeg"), Character:FindFirstChild("LeftFoot")},
                            {LowerTorso, Character:FindFirstChild("RightUpperLeg")},
                            {Character:FindFirstChild("RightUpperLeg"), Character:FindFirstChild("RightLowerLeg")},
                            {Character:FindFirstChild("RightLowerLeg"), Character:FindFirstChild("RightFoot")}
                        }
                    end
                elseif Data.RigType == Enum.HumanoidRigType.R6 then
                    local Head = Character:FindFirstChild("Head")
                    local Torso = Character:FindFirstChild("Torso")
                    connections = {
                        {Head, Torso},
                        {Torso, Character:FindFirstChild("Left Arm")},
                        {Torso, Character:FindFirstChild("Right Arm")},
                        {Torso, Character:FindFirstChild("Left Leg")},
                        {Torso, Character:FindFirstChild("Right Leg")}
                    }
                end

                local boneIdx = 1
                for _, pair in pairs(connections) do
                    if boneIdx <= #Data.Bones and pair[1] and pair[2] then
                        local frame = Data.Bones[boneIdx]
                        local p1Pos, onScreen1 = camera:WorldToViewportPoint(pair[1].Position)
                        local p2Pos, onScreen2 = camera:WorldToViewportPoint(pair[2].Position)
                        
                        if onScreen1 and onScreen2 then
                            frame.Visible = true
                            frame.Position = UDim2.fromOffset((p1Pos.X + p2Pos.X)/2, (p1Pos.Y + p2Pos.Y)/2)
                            local dist = math.sqrt((p2Pos.X - p1Pos.X)^2 + (p2Pos.Y - p1Pos.Y)^2)
                            frame.Size = UDim2.fromOffset(dist, PlayerOptions.Skeleton_Thickness)
                            frame.Rotation = math.deg(math.atan2(p2Pos.Y - p1Pos.Y, p2Pos.X - p1Pos.X))
                            frame.BackgroundColor3 = PlayerOptions.Skeleton_Color.Color
                        else
                            frame.Visible = false
                        end
                        boneIdx = boneIdx + 1
                    end
                end

                for i = boneIdx, #Data.Bones do
                    if Data.Bones[i] then
                        Data.Bones[i].Visible = false
                    end
                end
            else
                if Data.Bones then
                    for _, bone in pairs(Data.Bones) do 
                        if bone then bone.Visible = false end
                    end
                end
            end
        end
    end

    function Esp.UpdateMobESP()
        if not MobOptions.Enabled then
            for _, Data in pairs(Esp.MobESPs) do
                if Data.Items and Data.Items.Holder then
                    Data.Items.Holder.Visible = false
                end
                if Data.Items and Data.Items.Chams then
                    Data.Items.Chams.Enabled = false
                end
            end
            return
        end

        for _, Data in pairs(Esp.MobESPs) do
            local Items = Data.Items
            local mobEntity = Data.Info.Entity
            local Humanoid = Data.Info.Humanoid
            local RootPart = Data.Info.rootpart

            if not Items or not Items.Holder then continue end
            if not mobEntity or not mobEntity.Parent then
                Data.Destroy()
                Esp.MobESPs[_] = nil
                continue
            end

            if not Humanoid or not RootPart then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                continue
            end

            if Humanoid.Health <= 0 then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                continue
            end

            if not MobOptions.Filters[Data.Info.Group] then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                continue
            end

            local BoxSize, BoxPos, OnScreen, Distance = Esp:BoxSolve(RootPart)

            if not OnScreen then
                Items.Holder.Visible = false
                Items.Chams.Enabled = false
                continue
            end

            Items.Holder.Visible = true
            Items.Holder.Position = dim_offset(BoxPos.X, BoxPos.Y)
            Items.Holder.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)

            if MobOptions.Boxes then
                if MobOptions.BoxType == "Corner" then
                    Items.Corners.Parent = Items.Holder
                    Items.Box.Parent = Esp.Cache
                else
                    Items.Box.Parent = Items.Holder
                    Items.Corners.Parent = Esp.Cache
                end

                local targetColor = Color3.fromRGB(255, 50, 50)
                if Items.BoxGradient then
                    Items.BoxGradient.Color = rgbseq{rgbkey(0, targetColor), rgbkey(1, targetColor)}
                end
                if Items.Corners then
                    for _, corner in pairs(Items.Corners:GetChildren()) do
                        if corner:IsA("Frame") then
                            local grad = corner:FindFirstChildOfClass("UIGradient")
                            if grad then grad.Color = rgbseq{rgbkey(0, targetColor), rgbkey(1, targetColor)} end
                        end
                    end
                end
            else
                Items.Box.Parent = Esp.Cache
                Items.Corners.Parent = Esp.Cache
            end

            if MobOptions.Healthbar then
                Items.Healthbar.Parent = Items.Left
                Items.Healthbar.Size = dim2(0, MobOptions.Healthbar_Width + 2, 0, MobOptions.Healthbar_Width + 2)
                local healthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
                Items.HealthbarAccent.Size = dim2(1, -2, healthPercent, -2)
                Items.HealthbarAccent.Position = dim2(0, 1, 1 - healthPercent, 1)
            else
                Items.Healthbar.Parent = Esp.Cache
            end

            if MobOptions.Name_Text then
                Items.Text.TextSize = MobOptions.Name_Text_Size
                Items.Text.Parent = Items.TopTexts
            else
                Items.Text.Parent = Esp.Cache
            end

            if MobOptions.Distance_Text then
                Items.Distance.Text = tostring(math.round(Distance)) .. "m"
                Items.Distance.TextSize = MobOptions.Distance_Text_Size
                Items.Distance.Parent = Items.BottomTexts
            else
                Items.Distance.Parent = Esp.Cache
            end

            Items.Chams.Enabled = MobOptions.Chams
        end
    end

    function Esp.ScanForMobs()
        local entitiesFolder = Workspace:FindFirstChild("World")
        if entitiesFolder then
            entitiesFolder = entitiesFolder:FindFirstChild("Entities")
        end

        if not entitiesFolder then return end

        for _, entity in pairs(entitiesFolder:GetChildren()) do
            if entity:GetAttribute("Mob") then
                local group = entity:GetAttribute("Group")
                if group and not Esp.MobESPs[entity.Name] then
                    Esp.MobESPs[entity.Name] = Esp.CreateMobESP(entity)
                end
            end
        end
    end

    for _, player in pairs(Players:GetPlayers()) do 
        if player ~= Players.LocalPlayer then
            Esp.PlayerESPs[player.Name] = Esp.CreatePlayerESP(player)
        end
    end

    Esp:Connection(Players.PlayerAdded, function(player)
        Esp.PlayerESPs[player.Name] = Esp.CreatePlayerESP(player)
    end)

    Esp:Connection(Players.PlayerRemoving, function(player)
        local data = Esp.PlayerESPs[player.Name]
        if data then
            data.Destroy()
            Esp.PlayerESPs[player.Name] = nil
        end
    end)

    Esp.ScanForMobs()
    local entitiesFolder = Workspace:FindFirstChild("World")
    if entitiesFolder then
        entitiesFolder = entitiesFolder:FindFirstChild("Entities")
    end

    if entitiesFolder then
        Esp:Connection(entitiesFolder.ChildAdded, function(child)
            task.wait(0.1)
            if child:GetAttribute("Mob") then
                local group = child:GetAttribute("Group")
                if group and not Esp.MobESPs[child.Name] then
                    Esp.MobESPs[child.Name] = Esp.CreateMobESP(child)
                end
            end
        end)

        Esp:Connection(entitiesFolder.ChildRemoved, function(child)
            local data = Esp.MobESPs[child.Name]
            if data then
                data.Destroy()
                Esp.MobESPs[child.Name] = nil
            end
        end)
    end

    if Esp.Loop then RunService:UnbindFromRenderStep("RoESPLoop") end
    Esp.Loop = RunService:BindToRenderStep("RoESPLoop", Enum.RenderPriority.Camera.Value + 1, function()
        Esp.UpdatePlayerESP()
        Esp.UpdateMobESP()
    end)

    function Esp.Unload()
        for name, data in pairs(Esp.PlayerESPs) do
            if data.Destroy then data.Destroy() end
        end
        for name, data in pairs(Esp.MobESPs) do
            if data.Destroy then data.Destroy() end
        end
        for _, conn in pairs(Esp.Connections) do
            conn:Disconnect()
        end
        if Esp.Loop then 
            RunService:UnbindFromRenderStep("RoESPLoop")
        end
        if Esp.Cache then Esp.Cache:Destroy() end
        if Esp.ScreenGui then Esp.ScreenGui:Destroy() end
        if getgenv then getgenv().RoESP = nil end
    end

    return Esp
end

return LoadLibrary()
