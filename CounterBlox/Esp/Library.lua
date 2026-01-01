--[[
    KiwiSense ESP Library v2.1 - FIXED
    Theme: Preset (Purple/Dark Grey)
    
    Fixes Applied:
        - Fixed HealthbarTexts container references (now properly created)
        - Fixed Chams_Anim_Speed trailing comma syntax
        - Fixed Box Fill gradient enabling logic
        - Fixed healthbar text parenting
        - Added nil checks for bone updates
        - Fixed ArmorBar implementation (stub for future use)
]]

local function LoadLibrary()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local Lighting = game:GetService("Lighting")

    local function get_hui()
        return gethui and gethui() or CoreGui
    end

    local function clone_ref(instance)
        return cloneref and cloneref(instance) or instance
    end

    -- Safety check for getgenv
    if getgenv and getgenv().KiwiSenseEsp then 
        local OldEsp = getgenv().KiwiSenseEsp
        if type(OldEsp.Unload) == "function" then
            task.spawn(OldEsp.Unload)
        end
        getgenv().KiwiSenseEsp = nil 
    end 

    local ESPFonts = {}

    local Theme = {
        Accent = Color3.fromRGB(170, 110, 255),
        Background = Color3.fromRGB(15, 15, 20),
        Text = Color3.fromRGB(235, 225, 255),
        Border = Color3.fromRGB(40, 38, 48),
        Shadow = Color3.fromRGB(0, 0, 0)
    }

    local Options = {} 
    local MiscOptions = {
        ["Enabled"] = false;
        ["TeamCheck"] = false;

        -- Boxes
        ["Boxes"] = false;
        ["BoxType"] = "Corner";
        
        ["Box Gradient 1"] = { Color = Theme.Accent, Transparency = 0.8 }; 
        ["Box Gradient 2"] = { Color = Theme.Accent, Transparency = 0.8 };
        ["Box Gradient Rotation"] = 90;
        
        ["Box Fill"] = false; 
        ["Box Fill 1"] = { Color = Theme.Background, Transparency = 0.5 };
        ["Box Fill 2"] = { Color = Theme.Background, Transparency = 0.5 };
        ["Box Fill Rotation"] = 0;

        -- Healthbar
        ["Healthbar"] = false;
        ["Healthbar_Position"] = "Left";
        ["Healthbar_Number"] = false;
        ["Healthbar_Low"] = { Color = Color3.fromRGB(255, 0, 0), Transparency = 1};
        ["Healthbar_Medium"] = { Color = Color3.fromRGB(255, 255, 0), Transparency = 1};
        ["Healthbar_High"] = { Color = Color3.fromRGB(0, 255, 0), Transparency = 1};
        ["Healthbar_Animations"] = false; 
        ["Healthbar_Font"] = "Verdana";
        ["Healthbar_Text_Size"] = 11;
        ["Healthbar_Thickness"] = 3; 
        ["Healthbar_Tween"] = false;
        ["Healthbar_EasingStyle"] = "Circular";
        ["Healthbar_EasingDirection"] = "InOut";
        ["Healthbar_Easing_Speed"] = 1;

        -- Armor Bar
        ["ArmorBar"] = false;
        ["ArmorBar_Color"] = { Color = Color3.fromRGB(50, 150, 255), Transparency = 1 };
        ["ArmorBar_Background"] = { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.5 };

        -- Text Elements
        ["Name_Text"] = false; 
        ["Name_Text_Color"] = { Color = Theme.Text };
        ["Name_Text_Position"] = "Top";
        ["Name_Text_Font"] = "Verdana";
        ["Name_Text_Size"] = 11;
        
        ["Distance_Text"] = false; 
        ["Distance_Text_Color"] = { Color = Theme.Text };
        ["Distance_Text_Position"] = "Bottom";
        ["Distance_Text_Font"] = "Verdana";
        ["Distance_Text_Size"] = 11;

        ["Weapon_Text"] = false; 
        ["Weapon_Text_Color"] = { Color = Theme.Text };
        ["Weapon_Text_Position"] = "Bottom";
        ["Weapon_Text_Font"] = "Verdana";
        ["Weapon_Text_Size"] = 11;

        -- Visibility Check Toggle
        ["VisCheck_Colors"] = false;

        -- Skeleton Options
        ["Skeleton"] = false;
        ["Skeleton_Thickness"] = 1.5;
        ["Skeleton_Color"] = { Color = Color3.new(1,1,1), Transparency = 0 };
        ["Skeleton_Transparency"] = 0;

        -- CHAMS (Fixed trailing comma)
        ["Chams"] = false;
        ["Chams_Fill_Color"] = { Color = Theme.Accent, Transparency = 0.5 };
        ["Chams_Depth_Mode"] = Enum.HighlightDepthMode.AlwaysOnTop;
        ["Chams_Anim_Style"] = "Rainbow";
        ["Chams_Anim_Speed"] = 2;
        
        -- FLAGS
        ["Flags_Enabled"] = false;
        ["Flags_Visible"] = false;
    }

    Options = setmetatable({}, {
        __index = MiscOptions, 
        __newindex = function(self, key, value) 
            MiscOptions[key] = value
            local Esp = getgenv and getgenv().KiwiSenseEsp
            if Esp then
                Esp.RefreshElements(key, value) 
            end
        end
    })

    -- Main Logic
    do
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

        -- Font Loading
        local Fonts = {}; do
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

                return getcustomasset(Name .. ".font");
            end

            local FontNames = {
                ["ProggyClean"] = "ProggyClean.ttf",
                ["Tahoma"] = "fs-tahoma-8px.ttf",
                ["Verdana"] = "Verdana-Font.ttf",
                ["SmallestPixel"] = "smallest_pixel-7.ttf",
                ["ProggyTiny"] = "ProggyTiny.ttf",
                ["Minecraftia"] = "Minecraftia-Regular.ttf",
                ["Tahoma Bold"] = "tahoma_bold.ttf"
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
            Players = {}, 
            ScreenGui = Instance.new("ScreenGui", get_hui()), 
            Cache = Instance.new("ScreenGui", get_hui()), 
            Connections = {}, 
            Options = Options,
            Overrides = {} 
        }
        
        if getgenv then getgenv().KiwiSenseEsp = Esp end

        -- Overrides
        Esp.Overrides.GetCharacter = function(player)
            return player.Character
        end

        Esp.Overrides.GetWeapon = function(model, player)
            if model then
                local gunPart = model:FindFirstChild("Gun")
                if gunPart and gunPart:IsA("BasePart") then
                    local gunName = gunPart:GetAttribute("GunName")
                    if gunName then return tostring(gunName) end
                end
            end
            return "Fists"
        end

        Esp.Overrides.GetArmor = function(model, player)
            if player then
                local kevlar = player:FindFirstChild("Kevlar")
                if kevlar and kevlar:IsA("IntValue") then 
                    return kevlar.Value, 100 
                end
            end
            return 0, 100
        end

        Esp.Overrides.IsTeammate = function(player)
            if Players.LocalPlayer and player.Team and Players.LocalPlayer.Team then
                return player.Team == Players.LocalPlayer.Team
            end
            return false
        end
        
        do 
            Esp.ScreenGui.IgnoreGuiInset = true
            Esp.ScreenGui.Name = "EspObject"
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

            function Esp:Lerp(start, finish, t)
                t = t or 1 / 8
                return start * (1 - t) + finish * t
            end

            function Esp:Tween(Object, Properties, Info)
                local tween = TweenService:Create(Object, Info, Properties)
                tween:Play()
                return tween
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

            function Esp.CreateObject( player, typechar )
                local Data = { 
                    Items = { }, 
                    Info = {
                        Character = nil; 
                        Humanoid = nil; 
                        Health = 0; 
                        Player = player;
                        OldHealth = 0;
                        TeamColor = player.TeamColor.Color;
                        Flags = {};
                    },
                    Drawings = { }, 
                    Type = typechar or "player",
                    ChamsTween = nil,
                    Bones = {},
                    RigType = nil 
                } 

                local Items = Data.Items; do
                    -- Holder
                        Items.Holder = Esp:Create( "Frame" , {
                            Parent = Esp.ScreenGui;
                            Name = "\0";
                            BackgroundTransparency = 1;
                            Position = dim2(0.4332570433616638, 0, 0.3255814015865326, 0);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 211, 0, 240);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Items.HolderGradient = Esp:Create( "UIGradient" , {
                            Rotation = 0;
                            Name = "\0";
                            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(255, 255, 255))};
                            Parent = Items.Holder;
                            Enabled = false
                        });

                        -- Directions 
                            Items.Left = Esp:Create( "Frame" , {
                                Parent = Items.Holder;
                                Size = dim2(0, 0, 1, 0);
                                Name = "\0";
                                BackgroundTransparency = 1;
                                Position = dim2(0, -1, 0, 0);
                                BorderColor3 = rgb(0, 0, 0);
                                ZIndex = 2;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create( "UIListLayout" , {
                                FillDirection = Enum.FillDirection.Horizontal;
                                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                                VerticalFlex = Enum.UIFlexAlignment.Fill;
                                Parent = Items.Left;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            Items.LeftTexts = Esp:Create( "Frame" , {
                                LayoutOrder = -100;
                                Parent = Items.Left;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.X;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create( "UIListLayout" , {
                                Parent = Items.LeftTexts;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            -- FIXED: Create HealthbarTextsLeft container
                            Items.HealthbarTextsLeft = Esp:Create("Frame", {
                                LayoutOrder = 100;
                                Parent = Esp.Cache;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.X;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create("UIListLayout", {
                                Parent = Items.HealthbarTextsLeft;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            Items.Bottom = Esp:Create( "Frame" , {
                                Parent = Items.Holder;
                                Size = dim2(1, 0, 0, 0);
                                Name = "\0";
                                BackgroundTransparency = 1;
                                Position = dim2(0, 0, 1, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                ZIndex = 2;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255),
                                AutomaticSize = Enum.AutomaticSize.Y 
                            });

                            Esp:Create( "UIListLayout" , {
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                                Parent = Items.Bottom;
                                Padding = dim(0, 1)
                            });

                            Items.BottomTexts = Esp:Create( "Frame", {
                                LayoutOrder = 1, 
                                Parent = Items.Bottom;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.XY;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create( "UIListLayout", {
                                Parent = Items.BottomTexts;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            -- FIXED: Create HealthbarTextsBottom container
                            Items.HealthbarTextsBottom = Esp:Create("Frame", {
                                LayoutOrder = 100;
                                Parent = Esp.Cache;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.XY;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create("UIListLayout", {
                                Parent = Items.HealthbarTextsBottom;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            Items.Top = Esp:Create( "Frame" , {
                                Parent = Items.Holder;
                                Size = dim2(1, 0, 0, 0);
                                Name = "\0";
                                BackgroundTransparency = 1;
                                Position = dim2(0, 0, 0, -1);
                                BorderColor3 = rgb(0, 0, 0);
                                ZIndex = 2;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create( "UIListLayout" , {
                                VerticalAlignment = Enum.VerticalAlignment.Bottom;
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                                Parent = Items.Top;
                                Padding = dim(0, 1)
                            });

                            Items.TopTexts = Esp:Create( "Frame", {
                                LayoutOrder = -100;
                                Parent = Items.Top;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.XY;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create( "UIListLayout", {
                                Parent = Items.TopTexts;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            -- FIXED: Create HealthbarTextsTop container
                            Items.HealthbarTextsTop = Esp:Create("Frame", {
                                LayoutOrder = 100;
                                Parent = Esp.Cache;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.XY;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create("UIListLayout", {
                                Parent = Items.HealthbarTextsTop;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            Items.Right = Esp:Create( "Frame" , {
                                Parent = Esp.Cache;
                                Size = dim2(0, 0, 1, 0);
                                Name = "\0";
                                BackgroundTransparency = 1;
                                Position = dim2(1, 1, 0, 0);
                                BorderColor3 = rgb(0, 0, 0);
                                ZIndex = 2;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create( "UIListLayout" , {
                                FillDirection = Enum.FillDirection.Horizontal;
                                VerticalFlex = Enum.UIFlexAlignment.Fill;
                                Parent = Items.Right;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });
                            
                            Items.RightTexts = Esp:Create( "Frame" , {
                                LayoutOrder = 100;
                                Parent = Items.Right;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.X;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                            
                            Esp:Create( "UIListLayout" , {
                                Parent = Items.RightTexts;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });

                            -- FIXED: Create HealthbarTextsRight container
                            Items.HealthbarTextsRight = Esp:Create("Frame", {
                                LayoutOrder = 100;
                                Parent = Esp.Cache;
                                BackgroundTransparency = 1;
                                Name = "\0";
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.X;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });

                            Esp:Create("UIListLayout", {
                                Parent = Items.HealthbarTextsRight;
                                Padding = dim(0, 1);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });
                        
                    -- Corner Boxes
                        Items.Corners = Esp:Create( "Frame", {
                            Parent = Esp.Cache; 
                            Name = "\0";
                            BackgroundTransparency = 1;
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, 0, 1, 0);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

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

                    -- Normal Box 
                        Items.Box = Esp:Create( "Frame" , {
                            Parent = Esp.Cache; 
                            Name = "\0";
                            BackgroundTransparency = 1;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Esp:Create( "UIStroke" , {  
                            Parent = Items.Box;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });

                        Items.Inner = Esp:Create( "Frame" , {
                            Parent = Items.Box;
                            Name = "\0";
                            BackgroundTransparency = 1;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Items.UIStroke = Esp:Create( "UIStroke" , {
                            Color = rgb(255, 255, 255);
                            LineJoinMode = Enum.LineJoinMode.Miter;
                            Parent = Items.Inner
                        });

                        Items.BoxGradient = Esp:Create( "UIGradient" , {
                            Parent = Items.UIStroke
                        });

                    -- Healthbar
                        Items.Healthbar = Esp:Create( "Frame" , {
                            Name = "Left";
                            Parent = Esp.Cache;
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 3, 0, 3);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(0, 0, 0)
                        });

                        Items.HealthbarAccent = Esp:Create( "Frame" , {
                            Parent = Items.Healthbar;
                            Name = "\0";
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Items.HealthbarGradient = Esp:Create( "UIGradient" , {
                            Enabled = true;
                            Parent = Items.HealthbarAccent;
                            Rotation = 90;
                            Color = rgbseq{rgbkey(0, rgb(0, 255, 0)), rgbkey(0.5, rgb(255, 125, 0)), rgbkey(1, rgb(255, 0, 0))}
                        });

                        Items.HealthbarText = Esp:Create( "TextLabel", {
                            FontFace = Fonts.ProggyClean or Font.fromEnum(Enum.Font.SourceSans);
                            TextColor3 = rgb(255, 255, 255);
                            BorderColor3 = rgb(0, 0, 0);
                            Parent = Esp.Cache;
                            Name = "\0";
                            BackgroundTransparency = 1;
                            Size = dim2(0, 0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255);
                            Text = ""
                        });

                        Esp:Create( "UIStroke", {
                            Parent = Items.HealthbarText;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });
                    
                    -- Texts
                        Items.Text = Esp:Create( "TextLabel", {
                            FontFace = Fonts.ProggyClean or Font.fromEnum(Enum.Font.SourceSans);
                            TextColor3 = rgb(255, 255, 255);
                            BorderColor3 = rgb(0, 0, 0);
                            Parent = Esp.Cache;
                            Name = "Left";
                            Text = player.Name;
                            BackgroundTransparency = 1;
                            Size = dim2(1, 0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 9;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Esp:Create( "UIStroke", {
                            Parent = Items.Text;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });

                        Items.Weapon = Esp:Create( "TextLabel", {
                            FontFace = Fonts.ProggyClean or Font.fromEnum(Enum.Font.SourceSans);
                            TextColor3 = rgb(255, 255, 255);
                            BorderColor3 = rgb(0, 0, 0);
                            Parent = Esp.Cache;
                            Name = "Bottom";
                            Text = "";
                            BackgroundTransparency = 1;
                            Size = dim2(1, 0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 9;
                            BackgroundColor3 = rgb(255, 255, 255);
                            LayoutOrder = 1
                        });

                        Esp:Create( "UIStroke", {
                            Parent = Items.Weapon;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });

                        Items.Distance = Esp:Create( "TextLabel", {
                            FontFace = Fonts.ProggyClean or Font.fromEnum(Enum.Font.SourceSans);
                            TextColor3 = rgb(255, 255, 255);
                            BorderColor3 = rgb(0, 0, 0);
                            Parent = Esp.Cache;
                            Name = "Bottom";
                            BackgroundTransparency = 1;
                            Size = dim2(1, 0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 9;
                            BackgroundColor3 = rgb(255, 255, 255);
                            LayoutOrder = 2
                        });

                        Esp:Create( "UIStroke", {
                            Parent = Items.Distance;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });

                    -- FLAGS
                        Items.Flags = Esp:Create("Frame", {
                            Parent = Esp.Cache,
                            Name = "Flags",
                            BackgroundTransparency = 1,
                            Size = dim2(0, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BorderSizePixel = 0,
                            Position = dim2(0.5, 0, 1, 0),
                            AnchorPoint = Vector2.new(0.5, 1)
                        })
                        
                        Esp:Create("UIListLayout", {
                            Parent = Items.Flags,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = dim(0, 2),
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center
                        })

                    -- Chams
                    Items.Chams = Instance.new("Highlight")
                    Items.Chams.Name = "KiwiChams"
                    Items.Chams.Enabled = false
                    Items.Chams.DepthMode = MiscOptions.Chams_Depth_Mode
                    Items.Chams.FillColor = MiscOptions.Chams_Fill_Color.Color
                    Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency
                    Items.Chams.OutlineColor = Color3.new(0,0,0) 
                    Items.Chams.OutlineTransparency = 1 
                    
                    for i = 1, 15 do
                        table.insert(Data.Bones, Esp:CreateBone(Esp.ScreenGui))
                    end
                end
            
                Data.ToolAdded = function(item) end

                Data.HealthChanged = function(Value)
                    if not MiscOptions.Healthbar then return end 

                    local Humanoid = Data.Info.Humanoid
                    local MaxHealth = Humanoid and Humanoid.MaxHealth or 100
                    
                    local TweenSpeed = MiscOptions.Healthbar_Easing_Speed
                    if Data.Info.OldHealth then
                        local DamageTaken = math.abs(Data.Info.OldHealth - Value)
                        local PercentDamage = math.clamp(DamageTaken / MaxHealth, 0, 1)
                        TweenSpeed = math.clamp(1.0 - PercentDamage, 0.1, 1.0)
                    end
                    Data.Info.OldHealth = Value

                    local Multiplier = math.clamp(Value / MaxHealth, 0, 1)
                    local isHorizontal = MiscOptions.Healthbar_Position == "Top" or MiscOptions.Healthbar_Position == "Bottom"

                    local Color = MiscOptions.Healthbar_Low.Color:Lerp(MiscOptions.Healthbar_Medium.Color, Multiplier)
                    local Color_2 = Color:Lerp(MiscOptions.Healthbar_High.Color, Multiplier)

                    if MiscOptions.Healthbar_Tween then  
                        Esp:Tween(Items.HealthbarAccent, {
                            Size = dim2(isHorizontal and Multiplier or 1, -2, isHorizontal and 1 or Multiplier, -2), 
                            Position = dim2(0, 1, isHorizontal and 0 or 1 - Multiplier, 1)
                        }, TweenInfo.new(TweenSpeed, Enum.EasingStyle[MiscOptions.Healthbar_EasingStyle], Enum.EasingDirection[MiscOptions.Healthbar_EasingDirection], 0, false, 0))
                        
                        Esp:Tween(Items.HealthbarText, {Position = dim2(0, 0, isHorizontal and 0 or 1 - Multiplier, 0), TextColor3 = Color_2}, TweenInfo.new(TweenSpeed, Enum.EasingStyle[MiscOptions.Healthbar_EasingStyle], Enum.EasingDirection[MiscOptions.Healthbar_EasingDirection], 0, false, 0))
                        
                        task.spawn(function() Items.HealthbarText.Text = tostring(math.floor(Value)) end)
                    else 
                        Items.HealthbarAccent.Size = dim2(isHorizontal and Multiplier or 1, -2, isHorizontal and 1 or Multiplier, -2)
                        Items.HealthbarAccent.Position = dim2(0, 1, isHorizontal and 0 or 1 - Multiplier, 1)
                        Items.HealthbarText.Text = tostring(math.floor(Value))
                        Items.HealthbarText.Position = dim2(0, 0, isHorizontal and 0 or 1 - Multiplier, 0)
                        Items.HealthbarText.TextColor3 = Color_2
                    end 
                end

                Data.RefreshDescendants = function() 
                    local Character = (typechar and player) or player.Character or player.CharacterAdded:Wait()
                    local Humanoid = Character:WaitForChild("Humanoid", 10)
                    local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
                    
                    if not Humanoid or not RootPart then return end

                    Data.Info.Character = typechar and player or Character
                    Data.Info.Humanoid = Humanoid
                    Data.Info.rootpart = RootPart
                    Data.Info.TeamColor = player.TeamColor.Color
                    Data.RigType = Humanoid.RigType

                    if Items.Chams then
                        Items.Chams.Parent = Character
                    end

                    Esp:Connection(Humanoid.HealthChanged, Data.HealthChanged)
                    Esp:Connection(Character.ChildAdded, Data.ToolAdded)
                    Esp:Connection(Character.ChildRemoved, Data.ToolAdded)

                    Data.HealthChanged(Data.Info.Humanoid.Health)
                end 

                Data.Destroy = function()
                    if Items["Holder"] then 
                        Items["Holder"]:Destroy()
                    end 
                    if Items["Chams"] and Items["Chams"].Parent then
                        Items["Chams"]:Destroy()
                    end
                    for i, bone in pairs(Data.Bones) do
                        if bone then
                            bone:Destroy()
                            Data.Bones[i] = nil
                        end
                    end
                    if Esp.Players[player.Name] then 
                        Esp.Players[player.Name] = nil
                    end 
                end 

                task.spawn(Data.RefreshDescendants)
                Esp:Connection(player.CharacterAdded, Data.RefreshDescendants)
                
                for _,ItemParentor in pairs({Items.Left, Items.Right, Items.Top, Items.Bottom}) do  
                    Esp:Connection(ItemParentor.ChildAdded, function()
                        task.wait(.1)
                        if ItemParentor.Parent == nil then return end
                        ItemParentor.Parent = Items.Holder
                    end)    

                    Esp:Connection(ItemParentor.ChildRemoved, function()
                        task.wait(.1)
                        if #ItemParentor:GetChildren() == 0 then
                            if ItemParentor.Parent == nil then return end 
                            ItemParentor.Parent = Esp.Cache
                        end 
                    end)
                end     

                -- FIXED: Proper healthbar text container management
                for _,HealthHolder in pairs({"Right", "Left", "Top", "Bottom"}) do
                    local Parent = Items["HealthbarTexts" .. HealthHolder]
                    if Parent then
                        Esp:Connection(Parent.ChildAdded, function()
                            task.wait(.1)
                            if Parent.Parent == nil then return end
                            Parent.Parent = Items[HealthHolder]
                        end)    

                        Esp:Connection(Parent.ChildRemoved, function()
                            task.wait(.1)
                            if #Parent:GetChildren() == 0 then
                                if Parent.Parent == nil then return end 
                                Parent.Parent = Esp.Cache
                            end 
                        end)
                    end
                end 

                Esp.Players[ player.Name ] = Data
                return Data
            end

            -- Helper to update Skeleton Bone Frames
            local function UpdateBone(frame, part1, part2, targetColor)
                if not frame then return end
                frame.Visible = false 
                if not part1 or not part2 or not part1.Parent or not part2.Parent then return end
                
                local p1Pos, onScreen1 = camera:WorldToViewportPoint(part1.Position)
                local p2Pos, onScreen2 = camera:WorldToViewportPoint(part2.Position)
                
                if onScreen1 and onScreen2 then
                    frame.Position = UDim2.fromOffset((p1Pos.X + p2Pos.X)/2, (p1Pos.Y + p2Pos.Y)/2)
                    local dist = math.sqrt((p2Pos.X - p1Pos.X)^2 + (p2Pos.Y - p1Pos.Y)^2)
                    frame.Size = UDim2.fromOffset(dist, MiscOptions.Skeleton_Thickness)
                    frame.Rotation = math.deg(math.atan2(p2Pos.Y - p1Pos.Y, p2Pos.X - p1Pos.X))
                    
                    frame.BackgroundColor3 = targetColor
                    frame.BackgroundTransparency = MiscOptions.Skeleton_Transparency
                    
                    local stroke = frame:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Color = Color3.new(0,0,0) end

                    frame.Visible = true 
                end
            end

            function Esp.Update() 
                if not Esp then return end 
                if not Options.Enabled then 
                     for _, Data in pairs(Esp.Players) do
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

                for _,Data in pairs(Esp.Players) do
                    local player = Data.Info.Player or Data.Info.Character 
                    local Items = Data and Data.Items 
                    
                    if not player then continue end 
                    if not Data.Info then continue end 
                
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

                    if MiscOptions.TeamCheck and Esp.Overrides.IsTeammate(player) then
                         Items.Holder.Visible = false
                         Items.Chams.Enabled = false
                         continue
                    end

                    local BoxSize, BoxPos, OnScreen, Distance = Esp:BoxSolve(RootPart)
                    local Holder = Items["Holder"]

                    if not OnScreen then
                        Holder.Visible = false
                        Items.Chams.Enabled = false
                        if Data.Bones then
                            for _, bone in pairs(Data.Bones) do 
                                if bone then bone.Visible = false end
                            end
                        end
                        continue
                    end

                    if Holder.Visible ~= true then Holder.Visible = true end 
                    
                    -- BOX & FILL LOGIC FIX
                    if Items.Box then Items.Box.Visible = MiscOptions.Boxes and MiscOptions.BoxType == "Box" end
                    if Items.Corners then Items.Corners.Visible = MiscOptions.Boxes and MiscOptions.BoxType == "Corner" end
                    
                    -- FIXED: Box Fill gradient enabling
                    if MiscOptions.Boxes then
                        if MiscOptions.BoxType == "Box" then
                            if Items.Box then
                                Items.Box.BackgroundTransparency = MiscOptions["Box Fill"] and MiscOptions["Box Fill 1"].Transparency or 1
                            end
                        elseif MiscOptions.BoxType == "Corner" then
                            Items.Holder.BackgroundTransparency = MiscOptions["Box Fill"] and MiscOptions["Box Fill 1"].Transparency or 1
                            Items.HolderGradient.Enabled = MiscOptions["Box Fill"]
                        end
                    else
                        Items.Holder.BackgroundTransparency = 1
                        Items.HolderGradient.Enabled = false
                        if Items.Box then Items.Box.BackgroundTransparency = 1 end
                    end

                    if Items.Chams.Enabled ~= MiscOptions.Chams then Items.Chams.Enabled = MiscOptions.Chams end

                    local Pos = dim_offset(BoxPos.X, BoxPos.Y)
                    if Pos ~= Holder.Position then Holder.Position = Pos end 
                    local Size = dim2(0, BoxSize.X, 0, BoxSize.Y)
                    if Size ~= Holder.Size then Holder.Size = Size end 

                    -- VISIBILITY CHECK
                    local isVisible = false
                    local Origin = camera.CFrame.p
                    
                    local partsToCheck = {}
                    
                    if Data.RigType == Enum.HumanoidRigType.R15 then
                        partsToCheck = {
                            Character:FindFirstChild("Head"),
                            Character:FindFirstChild("UpperTorso"),
                            Character:FindFirstChild("LeftUpperArm"),
                            Character:FindFirstChild("RightUpperArm"),
                            Character:FindFirstChild("LeftUpperLeg"),
                            Character:FindFirstChild("RightUpperLeg")
                        }
                    elseif Data.RigType == Enum.HumanoidRigType.R6 then
                        partsToCheck = {
                            Character:FindFirstChild("Head"),
                            Character:FindFirstChild("Torso"),
                            Character:FindFirstChild("Left Arm"),
                            Character:FindFirstChild("Right Arm"),
                            Character:FindFirstChild("Left Leg"),
                            Character:FindFirstChild("Right Leg")
                        }
                    end

                    for _, acc in pairs(Character:GetDescendants()) do
                        if acc:IsA("Accessory") then
                            local handle = acc:FindFirstChild("Handle")
                            if handle then table.insert(partsToCheck, handle) end
                        end
                    end

                    local playerFolder = Workspace:FindFirstChild(player.Name)
                    if playerFolder then
                        local customParts = {
                            playerFolder:FindFirstChild("Gun"),
                            playerFolder:FindFirstChild("Head"),
                            playerFolder:FindFirstChild("FakeHead")
                        }
                        for _, customPart in pairs(customParts) do
                            if customPart and customPart:IsA("BasePart") then
                                table.insert(partsToCheck, customPart)
                            end
                        end
                    end

                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {Players.LocalPlayer.Character or Workspace, camera}

                    for _, part in pairs(partsToCheck) do
                        if part then
                            local Direction = (part.Position - Origin)
                            if Direction.Magnitude > 0 then
                                local Result = Workspace:Raycast(Origin, Direction, rayParams)
                                if Result and Result.Instance:IsDescendantOf(Character) or Result and Result.Instance:IsDescendantOf(playerFolder) then
                                    isVisible = true
                                    break 
                                end
                            end
                        end
                    end

                    -- COLORS
                    local targetColor = (isVisible and MiscOptions.VisCheck_Colors) and Color3.fromRGB(255, 0, 0) or (player.TeamColor.Color or Color3.new(1,1,1))
                    local skeletonColor = (isVisible and MiscOptions.VisCheck_Colors) and Color3.new(1,0,0) or Color3.new(1,1,1)

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
                    if Items.Text then Items.Text.TextColor3 = targetColor end
                    if Items.Distance then Items.Distance.TextColor3 = targetColor end

                    -- CHAMS LOGIC
                    if MiscOptions.Chams then
                        Items.Chams.OutlineTransparency = 1
                        local animStyle = MiscOptions.Chams_Anim_Style
                        local speed = MiscOptions.Chams_Anim_Speed
                        
                        if animStyle == "Rainbow" then
                            local hue = (tick() * speed * 50) % 360
                            Items.Chams.FillColor = Color3.fromHSV(hue/360, 1, 1)
                            Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency
                        elseif animStyle == "Breathe" then
                            local breathe_effect = math.atan(math.sin(tick() * speed)) * 2 / math.pi
                            Items.Chams.FillColor = MiscOptions.Chams_Fill_Color.Color
                            Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency * (breathe_effect * 0.5 + 0.5)
                        elseif animStyle == "Pulse" then
                            local pulse = (math.sin(tick() * speed * 2) + 1) / 2
                            Items.Chams.FillColor = MiscOptions.Chams_Fill_Color.Color
                            Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency * pulse
                        else
                            Items.Chams.FillColor = MiscOptions.Chams_Fill_Color.Color
                            Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency
                        end
                    end

                    -- SKELETON
                    if MiscOptions.Skeleton and Data.Bones then
                        local boneIdx = 1
                        local connections = {}

                        if Data.RigType == Enum.HumanoidRigType.R15 then
                            local Head = Character:FindFirstChild("Head")
                            local UpperTorso = Character:FindFirstChild("UpperTorso")
                            local LowerTorso = Character:FindFirstChild("LowerTorso")
                            local LUA = Character:FindFirstChild("LeftUpperArm")
                            local LLA = Character:FindFirstChild("LeftLowerArm")
                            local LH = Character:FindFirstChild("LeftHand")
                            local RUA = Character:FindFirstChild("RightUpperArm")
                            local RLA = Character:FindFirstChild("RightLowerArm")
                            local RH = Character:FindFirstChild("RightHand")
                            local LUL = Character:FindFirstChild("LeftUpperLeg")
                            local LLL = Character:FindFirstChild("LeftLowerLeg")
                            local LF = Character:FindFirstChild("LeftFoot")
                            local RUL = Character:FindFirstChild("RightUpperLeg")
                            local RLL = Character:FindFirstChild("RightLowerLeg")
                            local RF = Character:FindFirstChild("RightFoot")

                            if UpperTorso and LowerTorso then
                                connections = {
                                    {Head, UpperTorso},
                                    {UpperTorso, LowerTorso},
                                    {UpperTorso, LUA},
                                    {LUA, LLA},
                                    {LLA, LH},
                                    {UpperTorso, RUA},
                                    {RUA, RLA},
                                    {RLA, RH},
                                    {LowerTorso, LUL},
                                    {LUL, LLL},
                                    {LLL, LF},
                                    {LowerTorso, RUL},
                                    {RUL, RLL},
                                    {RLL, RF}
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

                        for _, pair in pairs(connections) do
                            if boneIdx <= #Data.Bones and pair[1] and pair[2] then
                                local p2 = pair[2]
                                if string.find(pair[2].Name, "Arm") and Data.RigType == Enum.HumanoidRigType.R6 then
                                    local offsetPos = pair[2].Position + Vector3.new(0, 0.5, 0)
                                    local p2Pos, onScreen2 = camera:WorldToViewportPoint(offsetPos)
                                    local p1Pos, onScreen1 = camera:WorldToViewportPoint(pair[1].Position)
                                    
                                    if onScreen1 and onScreen2 then
                                        local frame = Data.Bones[boneIdx]
                                        if frame then
                                            frame.Visible = true
                                            frame.Position = UDim2.fromOffset((p1Pos.X + p2Pos.X)/2, (p1Pos.Y + p2Pos.Y)/2)
                                            local dist = math.sqrt((p2Pos.X - p1Pos.X)^2 + (p2Pos.Y - p1Pos.Y)^2)
                                            frame.Size = UDim2.fromOffset(dist, MiscOptions.Skeleton_Thickness)
                                            frame.Rotation = math.deg(math.atan2(p2Pos.Y - p1Pos.Y, p2Pos.X - p1Pos.X))
                                            
                                            frame.BackgroundColor3 = skeletonColor
                                            local stroke = frame:FindFirstChildOfClass("UIStroke")
                                            if stroke then stroke.Color = Color3.new(0,0,0) end
                                        end
                                    else
                                        if Data.Bones[boneIdx] then
                                            Data.Bones[boneIdx].Visible = false
                                        end
                                    end
                                else
                                    UpdateBone(Data.Bones[boneIdx], pair[1], pair[2], skeletonColor)
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

                    -- Update Text
                    local Text = tostring( math.round(Distance) )  .. "m"
                    if Items.Distance.Text ~= Text then Items.Distance.Text = Text end 

                    if MiscOptions.Weapon_Text then
                        local wName = Esp.Overrides.GetWeapon(Character, player)
                        if Items.Weapon.Text ~= wName then Items.Weapon.Text = wName end
                    end

                    -- FLAGS LOGIC
                    if MiscOptions.Flags_Enabled then
                        Items.Flags.Parent = Items.Holder
                        for _, flag in pairs(Items.Flags:GetChildren()) do 
                            if flag:IsA("GuiObject") then flag:Destroy() end
                        end
                        Data.Info.Flags = {}
                        
                        local function AddFlag(text, color)
                            table.insert(Data.Info.Flags, {Text = text, Color = color})
                        end

                        if isVisible and MiscOptions.Flags_Visible then
                            AddFlag("VIS", Color3.fromRGB(0, 255, 0))
                        end

                        for i, flagData in pairs(Data.Info.Flags) do
                            local flag = Esp:Create("TextLabel", {
                                Parent = Items.Flags,
                                Text = flagData.Text,
                                TextColor3 = flagData.Color,
                                BackgroundColor3 = rgb(0,0,0),
                                BackgroundTransparency = 0.3,
                                Size = dim2(0, 0, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.XY,
                                TextSize = 10,
                                Font = Enum.Font.Code,
                                BorderSizePixel = 0,
                                LayoutOrder = i
                            })
                            Esp:Create("UIGradient", {Parent = flag, Rotation = 90, Color = rgbseq{rgbkey(0, flagData.Color), rgbkey(1, rgb(0,0,0))}})
                        end
                    else
                         Items.Flags.Parent = Esp.Cache
                         for _, flag in pairs(Items.Flags:GetChildren()) do 
                            if flag:IsA("GuiObject") then flag:Destroy() end
                        end
                    end
                end
            end 
            
            function Esp.RefreshElements(key, value)
                for _,Data in pairs(Esp.Players) do
                    local Items = Data and Data.Items 
                    if not Items then continue end 
                    if not Items.Holder then continue end 

                    if key == "Enabled" then
                        Items.Holder.Visible = value
                        Items.Chams.Enabled = value and MiscOptions.Chams
                    end 

                    -- Boxes
                        if key == "BoxType" then
                            local isCorner = value == "Corner"
                            Items.Box.Parent = (value == "Box") and Items.Holder or Esp.Cache
                            Items.Corners.Parent = isCorner and Items.Holder or Esp.Cache
                        end 

                        if key == "Boxes" then 
                            local isCorner = MiscOptions.BoxType == "Corner"
                            local Enabled = value and Items.Holder or Esp.Cache
                            if isCorner then 
                                Items.Corners.Parent = Enabled
                            else 
                                Items.Box.Parent = Enabled
                            end
                        end 

                        if key == "Box Gradient 1" then 
                            local Color = rgbseq{
                                Items.BoxGradient.Color.Keypoints[1], 
                                rgbkey(1, value.Color)
                            }
                            if Items.Corners then
                                for _,corner in pairs(Items.Corners:GetChildren()) do 
                                    if corner:IsA("Frame") then
                                        local grad = corner:FindFirstChildOfClass("UIGradient")
                                        if grad then grad.Color = Color end
                                    end
                                end     
                            end
                            if Items.BoxGradient then Items.BoxGradient.Color = Color end
                        end 
                        
                        if key == "Box Gradient 2" then 
                            local Color = rgbseq{
                                rgbkey(0, value.Color), 
                                Items.BoxGradient.Color.Keypoints[2]
                            }
                            if Items.Corners then
                                for _,corner in pairs(Items.Corners:GetChildren()) do 
                                    if corner:IsA("Frame") then
                                        local grad = corner:FindFirstChildOfClass("UIGradient")
                                        if grad then grad.Color = Color end
                                    end
                                end
                            end
                            if Items.BoxGradient then Items.BoxGradient.Color = Color end
                        end 

                        if key == "Box Gradient Rotation" then 
                            if Items.BoxGradient then Items.BoxGradient.Rotation = value end
                        end 

                        if key == "Box Fill" then 
                            -- FIXED: Enable/disable gradient properly
                            if Items.HolderGradient then
                                Items.HolderGradient.Enabled = value
                            end
                        end

                        if key == "Box Fill 1" then 
                            if Items.HolderGradient then
                                local Path = Items.HolderGradient
                                Path.Transparency = numseq{
                                    numkey(0, 1 - value.Transparency), 
                                    Path.Transparency.Keypoints[2]
                                };

                                Path.Color = rgbseq{
                                    rgbkey(0, value.Color), 
                                    Path.Color.Keypoints[2]
                                }
                            end
                        end 

                        if key == "Box Fill 2" then 
                            if Items.HolderGradient then
                                local Path = Items.HolderGradient
                                Path.Transparency = numseq{
                                    Path.Transparency.Keypoints[1],
                                    numkey(1, 1 - value.Transparency)
                                };

                                Path.Color = rgbseq{
                                    Path.Color.Keypoints[1],
                                    rgbkey(1, value.Color)
                                };
                            end
                        end 

                        if key == "Box Fill Rotation" then 
                            if Items.HolderGradient then Items.HolderGradient.Rotation = value end
                        end 
                    -- 

                    -- Bars 
                        if key == "Healthbar" then 
                             Items.Healthbar.Parent = value and Items[Items.Healthbar.Name] or Esp.Cache  
                             if not value then
                                Items.HealthbarText.Parent = MiscOptions.Healthbar_Number and Items[Items.Healthbar.Name] or Esp.Cache
                             else
                                local containerName = "HealthbarTexts" .. Items.Healthbar.Name
                                if Items[containerName] then
                                    Items.HealthbarText.Parent = MiscOptions.Healthbar_Number and Items[containerName] or Esp.Cache
                                end
                             end
                        end 

                        if key == "Healthbar_Position" then 
                            local isEnabled = MiscOptions.Healthbar
                            Items.Healthbar.Parent = isEnabled and Items[value] or Esp.Cache
                            Items.Healthbar.Name = value 
                            
                            local containerName = "HealthbarTexts" .. value
                            if Items[containerName] then
                                Items.HealthbarText.Parent = isEnabled and MiscOptions.Healthbar_Number and Items[containerName] or Esp.Cache
                            end

                            if value == "Bottom" or value == "Top" then 
                                Items.HealthbarGradient.Rotation = 0 
                            else 
                                Items.HealthbarGradient.Rotation = 90
                            end 
                            
                            if Data.HealthChanged and Data.Info.Humanoid then
                                 Data.HealthChanged(Data.Info.Humanoid.Health)
                            end
                        end
                        
                        if key == "Healthbar_Number" then  
                            local containerName = "HealthbarTexts" .. Items.Healthbar.Name
                            if Items[containerName] then
                                Items.HealthbarText.Parent = value and Items[containerName] or Esp.Cache
                            end
                            Items.HealthbarText.Visible = value
                        end

                        if key == "Healthbar_Low" then 
                            local Color = rgbseq{
                                Items.HealthbarGradient.Color.Keypoints[1], 
                                Items.HealthbarGradient.Color.Keypoints[2], 
                                rgbkey(1, value.Color)
                            }
                            Items.HealthbarGradient.Color = Color
                        end 

                        if key == "Healthbar_Medium" then 
                            local Color = rgbseq{
                                Items.HealthbarGradient.Color.Keypoints[1], 
                                rgbkey(0.5, value.Color), 
                                Items.HealthbarGradient.Color.Keypoints[3]
                            }
                            Items.HealthbarGradient.Color = Color
                        end

                        if key == "Healthbar_High" then 
                            local Color = rgbseq{
                                rgbkey(0, value.Color), 
                                Items.HealthbarGradient.Color.Keypoints[2], 
                                Items.HealthbarGradient.Color.Keypoints[3]
                            }
                            Items.HealthbarGradient.Color = Color
                        end

                        if key == "Healthbar_Thickness" then 
                            local Bar = Items.Healthbar
                            Bar.Size = dim2(0, value + 2, 0, value + 2)
                        end

                        if key == "Healthbar_Text_Size" then 
                            Items.HealthbarText.TextSize = value
                        end

                        if key == "Healthbar_Font" then 
                            if Fonts[value] then
                                Items.HealthbarText.FontFace = Fonts[value]
                            end
                        end
                    -- 

                    -- Texts
                        local Text;
                        local Match;
                        if string.match(key, "Name") then 
                            Text = Items.Text
                            Match = "Name"
                        elseif string.match(key, "Distance") then 
                            Text = Items.Distance
                            Match = "Distance"
                        elseif string.match(key, "Weapon") then
                            Text = Items.Weapon
                            Match = "Weapon"
                        end 

                        if Text then 
                            if key == Match .. "_Text" then  
                                Text.Parent = value and Items[Text.Name .. "Texts"] or Esp.Cache
                            end 

                            if key == Match .. "_Text_Position" then 
                                local isEnabled = MiscOptions[Match .. "_Text"]
                                Text.Parent = isEnabled and Items[value .. "Texts"] or Esp.Cache
                                Text.Name = tostring(value) 

                                if value == "Top" or value == "Bottom" then 
                                    Text.AutomaticSize = Enum.AutomaticSize.Y 
                                    Text.TextXAlignment = Enum.TextXAlignment.Center
                                else 
                                    Text.AutomaticSize = Enum.AutomaticSize.XY 
                                    Text.TextXAlignment = Enum.TextXAlignment[value == "Right" and "Left" or "Right"]
                                end     
                            end 

                            if key == Match .. "_Text_Color" then 
                                Text.TextColor3 = value.Color
                            end 

                            if key == Match .. "_Text_Font" then 
                                if Fonts[value] then
                                    Text.FontFace = Fonts[value]
                                end
                            end 

                            if key == Match .. "_Text_Size" then 
                                Text.TextSize = value
                            end
                        end 
                    -- 

                    if key == "Chams" then
                        Items.Chams.Enabled = value
                    end
                    if key == "Chams_Fill_Color" then
                        Items.Chams.FillColor = value.Color
                    end
                    if key == "Skeleton" then
                        if Data.Bones then
                            for _, bone in pairs(Data.Bones) do 
                                if bone then bone.Visible = false end
                            end
                        end
                    end
                    if key == "Skeleton_Transparency" then
                        if Data.Bones then
                            for _, bone in pairs(Data.Bones) do 
                                if bone then bone.BackgroundTransparency = value end
                            end
                        end
                    end
                end 
            end; 
            
            function Esp.Unload() 
                for name, data in pairs(Esp.Players) do
                    if data.Destroy then
                        pcall(data.Destroy)
                    end
                    Esp.Players[name] = nil
                end
                if Esp.Loop then 
                    RunService:UnbindFromRenderStep("EspLoop")
                    Esp.Loop = nil
                end 
                if Esp.Cache then pcall(function() Esp.Cache:Destroy() end) end
                if Esp.ScreenGui then pcall(function() Esp.ScreenGui:Destroy() end) end
                if getgenv then getgenv().KiwiSenseEsp = nil end
            end 

            function Esp.RemovePlayer(player)
                local Path = Esp.Players[player.Name]
                if Path then
                    Path.Destroy()
                end
            end 
        end

        for _,player in pairs(Players:GetPlayers()) do 
            if player ~= Players.LocalPlayer then
                Esp.CreateObject(player)
            end
        end 

        Esp:Connection(Players.PlayerRemoving, Esp.RemovePlayer)
        Esp:Connection(Players.PlayerAdded, function(player)
            Esp.CreateObject(player)
            for index,value in pairs(MiscOptions) do 
                Esp.RefreshElements(index, value)
            end 
        end)

        if Esp.Loop then RunService:UnbindFromRenderStep("EspLoop") end
        Esp.Loop = RunService:BindToRenderStep("EspLoop", Enum.RenderPriority.Camera.Value + 1, Esp.Update)

        for index,value in pairs(MiscOptions) do 
            Esp.RefreshElements(index, value)
        end
    end

    return getgenv and getgenv().KiwiSenseEsp
end

return LoadLibrary()
