--[[
    KiwiSense ESP Library
    Theme: Preset (Purple/Dark Grey)
    
    Updates:
        - Cleanup: Fixed memory leaks in Skeleton Bones and Chams.
        - Skeleton: Added Black UIStroke outline to bones.
        - Skeleton Color: White (Default) -> Red (Visible). Outline always Black.
        - Visibility Check: Added Accessories and custom Workspace objects (Gun, Head, FakeHead).
]]

local function LoadLibrary()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")

    -- Safe service getters
    local function get_hui()
        return gethui and gethui() or CoreGui
    end

    local function clone_ref(instance)
        return cloneref and cloneref(instance) or instance
    end

    -- Unload existing instance to prevent conflicts
    if getgenv().KiwiSenseEsp then 
        local OldEsp = getgenv().KiwiSenseEsp
        if type(OldEsp.Unload) == "function" then
            task.spawn(OldEsp.Unload)
        end
        getgenv().KiwiSenseEsp = nil 
    end 

    local ESPFonts = {}

    -- Theme
    local Theme = {
        Accent = Color3.fromRGB(170, 110, 255),
        Background = Color3.fromRGB(15, 15, 20),
        Text = Color3.fromRGB(235, 225, 255),
        Border = Color3.fromRGB(40, 38, 48),
        Shadow = Color3.fromRGB(0, 0, 0)
    }

    local Options = {} 
    local MiscOptions = {
        ["Enabled"] = true;
        ["TeamCheck"] = true;

        -- Boxes
        ["Boxes"] = false;
        ["BoxType"] = "Box";
        
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
        ["Healthbar_Tween"] = true;
        ["Healthbar_EasingStyle"] = "Circular";
        ["Healthbar_EasingDirection"] = "InOut";
        ["Healthbar_Easing_Speed"] = 1;

        -- Armor Bar
        ["ArmorBar"] = false;
        ["ArmorBar_Color"] = { Color = Color3.fromRGB(50, 150, 255), Transparency = 1 }; -- Fixed Blue
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

        -- Weapon Text
        ["Weapon_Text"] = false; 
        ["Weapon_Text_Color"] = { Color = Theme.Text };
        ["Weapon_Text_Position"] = "Bottom";
        ["Weapon_Text_Font"] = "Verdana";
        ["Weapon_Text_Size"] = 11;

        -- NEW: Skeleton Options
        ["Skeleton"] = false;
        ["Skeleton_Thickness"] = 1.5;
        ["Skeleton_Color"] = { Color = Color3.new(1,1,1), Transparency = 0 }; -- White Default
        ["Skeleton_Transparency"] = 0;

        -- NEW: Chams Options (Reference Style)
        ["Chams"] = false;
        ["Chams_Fill_Color"] = { Color = Theme.Accent, Transparency = 0.5 };
        ["Chams_Outline_Color"] = { Color = Theme.Accent, Transparency = 0 };
        ["Chams_Depth_Mode"] = Enum.HighlightDepthMode.AlwaysOnTop;
        ["Chams_Animated"] = false; 
        ["Chams_Anim_Style"] = "Linear"; 
        ["Chams_Anim_Speed"] = 2,
    }

    Options = setmetatable({}, {
        __index = MiscOptions, 
        __newindex = function(self, key, value) 
            MiscOptions[key] = value
            local Esp = getgenv().KiwiSenseEsp
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
        
        -- Assign to global for internal metatable access
        getgenv().KiwiSenseEsp = Esp

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

        -- ARMOR BAR FIX
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
                local Distance = (torso.Position - camera.CFrame.p).Magnitude
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

            -- Skeleton Helper: Create a line frame with Outline (UIStroke)
            function Esp:CreateBone(parent)
                local f = Instance.new("Frame")
                f.BorderSizePixel = 0
                f.BackgroundColor3 = Color3.new(1,1,1) -- White default
                f.BackgroundTransparency = 0
                f.ZIndex = 1
                f.AnchorPoint = Vector2.new(0.5, 0.5)
                
                -- ADD BLACK OUTLINE
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
                        TeamColor = player.TeamColor.Color
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
                            Enabled = true
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

                            Items.HealthbarTextsLeft = Esp:Create( "Frame", {
                                Visible = true;
                                BorderColor3 = rgb(0, 0, 0);
                                Parent = Esp.Cache;
                                Name = "\0";
                                BackgroundTransparency = 1;
                                LayoutOrder = -100;
                                BorderSizePixel = 0;
                                ZIndex = 0;
                                AutomaticSize = Enum.AutomaticSize.X;
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

                            -- ARMOR BAR
                            Items.ArmorBar = Esp:Create("Frame", {
                                Parent = Items.Bottom, 
                                Name = "ArmorBar", 
                                BackgroundTransparency = 0, 
                                BackgroundColor3 = rgb(0,0,0),
                                Size = dim2(1, 0, 0, 4), 
                                BorderSizePixel = 0, 
                                ZIndex = 1,
                                LayoutOrder = 0
                            })
                            Items.ArmorBarAccent = Esp:Create("Frame", {
                                Parent = Items.ArmorBar, 
                                Name = "Accent", 
                                BackgroundTransparency = 0, 
                                BackgroundColor3 = rgb(50, 150, 255), -- Fixed Blue
                                Size = dim2(0, 0, 1, 0), 
                                BorderSizePixel = 0, 
                                ZIndex = 2
                            })
                            Esp:Create("UIStroke", { Parent = Items.ArmorBar, Thickness = 1, Color = rgb(0,0,0) })

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

                            Items.HealthbarTextsRight = Esp:Create( "Frame", {
                                Visible = true;
                                BorderColor3 = rgb(0, 0, 0);
                                Parent = Esp.Cache;
                                Name = "\0";
                                BackgroundTransparency = 1;
                                LayoutOrder = 99;
                                BorderSizePixel = 0;
                                ZIndex = 0;
                                AutomaticSize = Enum.AutomaticSize.X;
                                BackgroundColor3 = rgb(255, 255, 255)
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

                        local function Corner(anch, pos, rot)
                            local img = Esp:Create("ImageLabel", {
                                Parent = Items.Corners,
                                BackgroundTransparency = 1,
                                AnchorPoint = anch,
                                Position = pos,
                                Size = dim2(0.4, 0, 0.25, 0),
                                Image = "rbxassetid://83548615999411",
                                ScaleType = Enum.ScaleType.Slice,
                                SliceCenter = rect(vec2(1,1), vec2(99,2)),
                                ZIndex = 2
                            })
                            Esp:Create("UIGradient", {Rotation = rot or 0, Parent = img})
                        end
                        
                        Corner(vec2(0,0), dim2(0,0,0,2))
                        Corner(vec2(1,0), dim2(1,0,0,2), -90)
                        Corner(vec2(0,1), dim2(0,0,1,0), 90)
                        Corner(vec2(1,1), dim2(1,0,1,0), 180)

                        local function Line(anch, pos, rot, id)
                            local img = Esp:Create("ImageLabel", {
                                Parent = Items.Corners,
                                BackgroundTransparency = 1,
                                AnchorPoint = anch,
                                Position = pos,
                                Size = dim2(0, 3, 0.25, 0),
                                Image = "rbxassetid://101715268403902",
                                ScaleType = Enum.ScaleType.Slice,
                                SliceCenter = rect(vec2(1,0), vec2(2,96)),
                                ZIndex = 500
                            })
                            if rot then Esp:Create("UIGradient", {Rotation = rot, Parent = img}) end
                        end
                        Line(vec2(0,1), dim2(0,0,1,-2), -90)
                        Line(vec2(1,1), dim2(1,0,1,-2), 90)
                        Line(vec2(0,0), dim2(0,0,0,2), 90)
                        Line(vec2(1,0), dim2(1,0,0,2), -90)

                    -- Normal Box 
                        Items.Box = Esp:Create( "Frame" , {
                            Parent = Esp.Cache; 
                            Name = "\0";
                            BackgroundTransparency = 0.8500000238418579;
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

                        Items.Inner2 = Esp:Create( "Frame" , {
                            Parent = Items.Inner;
                            Name = "\0";
                            BackgroundTransparency = 1;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Esp:Create( "UIStroke" , {
                            Parent = Items.Inner2;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });
                    -- 
                    
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
                            BackgroundColor3 = rgb(255, 255, 255)
                        });

                        Esp:Create( "UIStroke", {
                            Parent = Items.HealthbarText;
                            LineJoinMode = Enum.LineJoinMode.Miter
                        });
                    -- 

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
                    -- 
                    
                    -- NEW: Chams Instance
                    Items.Chams = Instance.new("Highlight")
                    Items.Chams.Name = "KiwiChams"
                    Items.Chams.Enabled = false
                    Items.Chams.DepthMode = MiscOptions.Chams_Depth_Mode
                    Items.Chams.FillColor = MiscOptions.Chams_Fill_Color.Color
                    Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency
                    Items.Chams.OutlineColor = MiscOptions.Chams_Outline_Color.Color
                    Items.Chams.OutlineTransparency = MiscOptions.Chams_Outline_Color.Transparency
                    
                    -- NEW: Skeleton Bones (Pool of 15 for R15 complexity)
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
                        
                        task.spawn(function() Items.HealthbarText.Text = math.floor(Value) end)
                    else 
                        Items.HealthbarAccent.Size = dim2(isHorizontal and Multiplier or 1, -2, isHorizontal and 1 or Multiplier, -2)
                        Items.HealthbarAccent.Position = dim2(0, 1, isHorizontal and 0 or 1 - Multiplier, 1)
                        Items.HealthbarText.Text = math.floor(Value)
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

                    -- Parent Chams
                    if Items.Chams then
                        Items.Chams.Parent = Character
                    end

                    Esp:Connection(Humanoid.HealthChanged, Data.HealthChanged)
                    Esp:Connection(Character.ChildAdded, Data.ToolAdded)
                    Esp:Connection(Character.ChildRemoved, Data.ToolAdded)

                    Data.HealthChanged(Data.Info.Humanoid.Health)
                end 

                -- ROBUST CLEANUP
                Data.Destroy = function()
                    -- Remove Holder (removes all UI children safely)
                    if Items["Holder"] then 
                        Items["Holder"]:Destroy()
                    end 
                    
                    -- Remove Chams
                    if Items["Chams"] and Items["Chams"].Parent then
                        Items["Chams"]:Destroy()
                    end
                    
                    -- Remove Bones (Specific manual cleanup required)
                    for i, bone in pairs(Data.Bones) do
                        if bone then
                            bone:Destroy()
                            Data.Bones[i] = nil
                        end
                    end
                    
                    -- Remove from Registry
                    if Esp.Players[player.Name] then 
                        Esp.Players[player.Name] = nil
                    end 
                end 

                task.spawn(Data.RefreshDescendants)
                Esp:Connection(player.CharacterAdded, Data.RefreshDescendants)
                
                -- UI Parenting logic
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

                for _,HealthHolder in pairs({"Right", "Left"}) do
                    local Parent = Items["HealthbarTexts" .. HealthHolder]
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

                Esp.Players[ player.Name ] = Data
                return Data
            end

            -- Helper to update Skeleton Bone Frames
            local function UpdateBone(frame, part1, part2, targetColor)
                -- FIX GHOSTING: Temporarily set visibility to false to force a clean re-render.
                -- This often solves ghosting artifacts in some execution environments.
                frame.Visible = false 

                if not part1 or not part2 or not part1.Parent or not part2.Parent then
                    return
                end
                
                local p1Pos, onScreen1 = camera:WorldToViewportPoint(part1.Position)
                local p2Pos, onScreen2 = camera:WorldToViewportPoint(part2.Position)
                
                if onScreen1 and onScreen2 then
                    frame.Position = UDim2.fromOffset((p1Pos.X + p2Pos.X)/2, (p1Pos.Y + p2Pos.Y)/2)
                    local dist = math.sqrt((p2Pos.X - p1Pos.X)^2 + (p2Pos.Y - p1Pos.Y)^2)
                    frame.Size = UDim2.fromOffset(dist, MiscOptions.Skeleton_Thickness)
                    frame.Rotation = math.deg(math.atan2(p2Pos.Y - p1Pos.Y, p2Pos.X - p1Pos.X))
                    
                    -- Apply Colors
                    frame.BackgroundColor3 = targetColor
                    frame.BackgroundTransparency = MiscOptions.Skeleton_Transparency
                    
                    -- Stroke Color
                    local stroke = frame:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        stroke.Color = Color3.new(0,0,0) -- Always Black Outline
                    end

                    -- Make visible only after all properties are set
                    frame.Visible = true 
                -- If off-screen, it remains false from the start of the function
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
                        for _, bone in pairs(Data.Bones) do bone.Visible = false end
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

                    -- CLEANUP
                    if not Character or not Humanoid or not RootPart or Humanoid.Health <= 0 then
                        Items.Holder.Visible = false
                        Items.Chams.Enabled = false
                        for _, bone in pairs(Data.Bones) do bone.Visible = false end
                        continue
                    end

                    -- TEAM CHECK
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
                        for _, bone in pairs(Data.Bones) do bone.Visible = false end
                        continue
                    end

                    -- Toggle Visibility Fixes
                    if Holder.Visible ~= true then Holder.Visible = true end 
                    
                    -- Box Type Logic
                    if Items.Box then Items.Box.Visible = MiscOptions.Boxes and MiscOptions.BoxType == "Box" end
                    if Items.Corners then Items.Corners.Visible = MiscOptions.Boxes and MiscOptions.BoxType == "Corner" end
                    
                    -- [FIXED] Box Fill Logic
                    -- 1. If Box Fill is OFF, ensure main container is transparent
                    if not MiscOptions["Box Fill"] then
                        Items.Holder.BackgroundTransparency = 1
                        -- 2. If Box Type is standard "Box", also make the inner box background transparent
                        if Items.Box and MiscOptions.BoxType == "Box" then
                            Items.Box.BackgroundTransparency = 1
                        end
                    else
                        -- If Box Fill is ON, RefreshElements handles the transparency value for Holder.
                        -- But we must ensure the inner Box background is transparent so it doesn't conflict/overlay weirdly,
                        -- or set it to what RefreshElements intends.
                        -- The Box itself (Items.Box) usually acts as the border. 
                        -- We leave Items.Box.BackgroundTransparency alone here so RefreshElements controls it.
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

                    local targetColor = isVisible and Color3.fromRGB(255, 0, 0) or (player.TeamColor.Color or Color3.new(1,1,1))
                    local skeletonColor = isVisible and Color3.new(1,0,0) or Color3.new(1,1,1)

                    -- Color Updates (Box, Text, Distance)
                    if Items.BoxGradient then
                        Items.BoxGradient.Color = rgbseq{rgbkey(0, targetColor), rgbkey(1, targetColor)}
                    end
                    -- Update Corner Colors
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
                        Items.Chams.FillColor = MiscOptions.Chams_Fill_Color.Color
                        Items.Chams.OutlineColor = MiscOptions.Chams_Outline_Color.Color

                        if MiscOptions.Chams_Animated then
                            local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
                            Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency * breathe_effect * 0.01
                            Items.Chams.OutlineTransparency = MiscOptions.Chams_Outline_Color.Transparency * breathe_effect * 0.01
                        else
                            Items.Chams.FillTransparency = MiscOptions.Chams_Fill_Color.Transparency
                            Items.Chams.OutlineTransparency = MiscOptions.Chams_Outline_Color.Transparency
                        end
                    end

                    -- SKELETON
                    if MiscOptions.Skeleton then
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
                                        frame.Visible = true
                                        frame.Position = UDim2.fromOffset((p1Pos.X + p2Pos.X)/2, (p1Pos.Y + p2Pos.Y)/2)
                                        local dist = math.sqrt((p2Pos.X - p1Pos.X)^2 + (p2Pos.Y - p1Pos.Y)^2)
                                        frame.Size = UDim2.fromOffset(dist, MiscOptions.Skeleton_Thickness)
                                        frame.Rotation = math.deg(math.atan2(p2Pos.Y - p1Pos.Y, p2Pos.X - p1Pos.X))
                                        
                                        frame.BackgroundColor3 = skeletonColor
                                        local stroke = frame:FindFirstChildOfClass("UIStroke")
                                        if stroke then stroke.Color = Color3.new(0,0,0) end
                                    else
                                        Data.Bones[boneIdx].Visible = false
                                    end
                                else
                                    UpdateBone(Data.Bones[boneIdx], pair[1], pair[2], skeletonColor)
                                end
                                boneIdx = boneIdx + 1
                            end
                        end
                        
                        for i = boneIdx, #Data.Bones do
                            Data.Bones[i].Visible = false
                        end
                    else
                        for _, bone in pairs(Data.Bones) do bone.Visible = false end
                    end

                    -- Update Text
                    local Text = tostring( math.round(Distance) )  .. "m"
                    if Items.Distance.Text ~= Text then Items.Distance.Text = Text end 

                    if MiscOptions.Weapon_Text then
                        local wName = Esp.Overrides.GetWeapon(Character, player)
                        if Items.Weapon.Text ~= wName then Items.Weapon.Text = wName end
                    end

                    -- ARMOR BAR
                    if MiscOptions.ArmorBar then
                        local armor, maxArmor = Esp.Overrides.GetArmor(Character, player)
                        local percent = math.clamp(armor / maxArmor, 0, 1)
                        
                        Items.ArmorBarAccent.Size = dim2(percent, 0, 1, 0)
                        Items.ArmorBarAccent.BackgroundColor3 = rgb(50, 150, 255) 
                        Items.ArmorBar.Visible = true
                    else
                        Items.ArmorBar.Visible = false
                    end
                end
            end 
            
            function Esp.RefreshElements(key, value)
                for _,Data in pairs(Esp.Players) do
                    local Items = Data and Data.Items 
                    if not Items then continue end 
                    if not Items.Holder then continue end 
                    if not Items.Holder.Parent and not Esp.Cache then continue end

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
                            for _,corner in pairs(Items.Corners:GetChildren()) do 
                                if corner:IsA("ImageLabel") then
                                    local grad = corner:FindFirstChildOfClass("UIGradient")
                                    if grad then grad.Color = Color end
                                end
                            end     
                            Items.BoxGradient.Color = Color
                        end 
                        
                        if key == "Box Gradient 2" then 
                            local Color = rgbseq{
                                rgbkey(0, value.Color), 
                                Items.BoxGradient.Color.Keypoints[2]
                            }
                            for _,corner in pairs(Items.Corners:GetChildren()) do 
                                 if corner:IsA("ImageLabel") then
                                    local grad = corner:FindFirstChildOfClass("UIGradient")
                                    if grad then grad.Color = Color end
                                end
                            end
                            Items.BoxGradient.Color = Color
                        end 

                        if key == "Box Gradient Rotation" then 
                            Items.BoxGradient.Rotation = value
                        end 

                        if key == "Box Fill" then 
                            Items.Holder.BackgroundTransparency = value and 0 or 1
                        end

                        if key == "Box Fill 1" then 
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

                        if key == "Box Fill 2" then 
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

                        if key == "Box Fill Rotation" then 
                            Items.HolderGradient.Rotation = value
                        end 
                    -- 

                    -- Bars 
                        if key == "Healthbar" then 
                             Items.Healthbar.Parent = value and Items[Items.Healthbar.Name] or Esp.Cache  
                             Items.HealthbarText.Parent = (value and Items.HealthbarNumber) and Items["HealthbarTexts" .. Items.Healthbar.Name] or Esp.Cache  
                        end 

                        if key == "Healthbar_Position" then 
                            local isEnabled = MiscOptions.Healthbar
                            Items.Healthbar.Parent = isEnabled and Items[value] or Esp.Cache
                            Items.Healthbar.Name = value 
                            Items.HealthbarText.Parent = isEnabled and Items["HealthbarTexts" .. Items.Healthbar.Name] or Esp.Cache

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
                            local Parent = Items["HealthbarTexts" .. Items.Healthbar.Name]
                            Items.HealthbarText.Parent = value and Parent or Esp.Cache
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

                    -- Armor Bar
                        if key == "ArmorBar" then 
                            Items.ArmorBar.Visible = value
                        end
                        if key == "ArmorBar_Background" then
                            Items.ArmorBar.BackgroundColor3 = value.Color
                            Items.ArmorBar.BackgroundTransparency = value.Transparency
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

                    -- NEW: Skeleton & Chams Options
                    if key == "Chams" then
                        Items.Chams.Enabled = value
                    end
                    if key == "Chams_Fill_Color" then
                        if not MiscOptions.Chams_Animated then
                            Items.Chams.FillColor = value.Color
                        end
                    end
                    if key == "Chams_Outline_Color" then
                        if not MiscOptions.Chams_Animated then
                            Items.Chams.OutlineColor = value.Color
                        end
                    end
                    if key == "Skeleton" then
                        for _, bone in pairs(Data.Bones) do bone.Visible = false end
                    end
                    if key == "Skeleton_Thickness" then
                        for _, bone in pairs(Data.Bones) do 
                            -- Size is updated in Update loop via Width logic
                        end
                    end
                    if key == "Skeleton_Transparency" then
                        for _, bone in pairs(Data.Bones) do bone.BackgroundTransparency = value end
                    end
                end 
            end; 
            
            function Esp.Unload() 
                -- Unload all players safely
                for name, data in pairs(Esp.Players) do
                    if data.Destroy then
                        pcall(data.Destroy)
                    end
                    Esp.Players[name] = nil
                end
                -- Unbind loop
                if Esp.Loop then 
                    RunService:UnbindFromRenderStep("EspLoop")
                    Esp.Loop = nil
                end 
                -- Destroy UIs
                if Esp.Cache then pcall(function() Esp.Cache:Destroy() end) end
                if Esp.ScreenGui then pcall(function() Esp.ScreenGui:Destroy() end) end
                getgenv().KiwiSenseEsp = nil
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

        Esp.Loop = RunService:BindToRenderStep("EspLoop", Enum.RenderPriority.Camera.Value + 1, Esp.Update)

        for index,value in pairs(MiscOptions) do 
            Esp.RefreshElements(index, value)
        end
    end

    return getgenv().KiwiSenseEsp
end

return LoadLibrary
