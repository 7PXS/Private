getgenv().Settings = {

    AutoRaid = {
        enabled = true,
        BossSelected = "Noro"
    },

    Misc = {
        TweenTpspeed = 175
    }
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, Root
local LastRespawnTime = 0
local RaidStartTime = 0
local IsTeleportingToVoid = false
local VoidTeleportStartTime = 0

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

if not game:IsLoaded() then
    repeat wait() until game:IsLoaded()
end

local notifyCooldown = false
local function notify(title, description, time)
    if notifyCooldown then return end
    notifyCooldown = true

    Library:Notify({
        Title = title,
        Description = description,
        Time = time or 5,
    })

    task.delay(time or 5, function()
        notifyCooldown = false
    end)
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%05.2f", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%d:%05.2f", minutes, secs)
    else
        return string.format("%.2f", secs)
    end
end

local function pressButton(Button)
    game:GetService('VirtualInputManager'):SendMouseButtonEvent(
        Button.AbsolutePosition.X + Button.AbsoluteSize.X / 2, 
        Button.AbsolutePosition.Y + Button.AbsoluteSize.Y / 2 + game.GuiService:GetGuiInset().Y, 
        0, true, nil, 1
    )
    game:GetService('VirtualInputManager'):SendMouseButtonEvent(
        Button.AbsolutePosition.X + Button.AbsoluteSize.X / 2, 
        Button.AbsolutePosition.Y + Button.AbsoluteSize.Y / 2 + game.GuiService:GetGuiInset().Y, 
        0, false, nil, 1
    )
end

local function teleportTo(position)
    if Root then
        Root.CFrame = position
    end
end

local function CalculateTime(targetPosition)
    if not Root then return TweenInfo.new(1, Enum.EasingStyle.Linear) end
    local distance = (targetPosition - Root.Position).Magnitude
    local time = distance / getgenv().Settings.Misc.TweenTpspeed 
    return TweenInfo.new(time, Enum.EasingStyle.Linear)
end

local function tweenTo(targetPosition)
    if not Root then return end

    local targetCFrame = CFrame.new(targetPosition) * CFrame.Angles(Root.CFrame:ToOrientation())
    local tweenInfo = CalculateTime(targetPosition)

    local tween = TweenService:Create(Root, tweenInfo, {CFrame = targetCFrame})

    local tweenComplete = false
    tween.Completed:Connect(function()
        tweenComplete = true
    end)

    tween:Play()

    local startTime = tick()
    local maxWaitTime = tweenInfo.Time + 1
    while not tweenComplete do
        if tick() - startTime > maxWaitTime then
            break
        end
        task.wait()
    end

    return tweenComplete
end

local function setupCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")

    local currentTime = tick()
    local timeSinceLastRespawn = currentTime - LastRespawnTime

    if LastRespawnTime > 0 then
        notify(
            "<font color='#66FF99'>Character Respawned</font>",
            "<font color='#FFCC66'>" .. formatTime(timeSinceLastRespawn) .. "</font>",
            3
        )
    end

    LastRespawnTime = currentTime
    IsTeleportingToVoid = false
end

LocalPlayer.CharacterAdded:Connect(function()
    setupCharacter()
end)

if not LocalPlayer.Character then
    local gui = LocalPlayer.PlayerGui:WaitForChild("LoadingGui")
    pressButton(gui.Loading)
    repeat task.wait(1) until LocalPlayer.Character
end
setupCharacter()

local function tweenToVoid()
    if IsTeleportingToVoid then return end
    IsTeleportingToVoid = true
    VoidTeleportStartTime = tick()

    notify(
        "<font color='#FF9966'>Respawning</font>",
        "<font color='#99CCFF'>Starting Auto Fix</font>",
        3
    )

    local teleportLoop = coroutine.create(function()
        while IsTeleportingToVoid and getgenv().Settings.AutoRaid.enabled do 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local bossFound = false
                for _, v in pairs(workspace.Entities:GetChildren()) do
                    if v.Name ~= LocalPlayer.Name and v:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(v) then
                        bossFound = true
                        local voidPosition = Vector3.new(Root.Position.X, Root.Position.Y - 300, Root.Position.Z)
                        tweenTo(voidPosition)
                        wait(2)
                        break
                    end
                end

                if not bossFound or (tick() - VoidTeleportStartTime > 10 and IsTeleportingToVoid) then
                    notify(
                        "<font color='#FF6666'>Auto Fix</font>",
                        "<font color='#99CCFF'>Starting Auto Fix</font>",
                        5
                    )

                    local deeperVoidPosition = Vector3.new(Root.Position.X, Root.Position.Y - 350, Root.Position.Z)
                    tweenTo(deeperVoidPosition)
                end
            else
                IsTeleportingToVoid = false
                break
            end

            task.wait(2.5)
        end
    end)

    coroutine.resume(teleportLoop)
end

local function runRaidBot()
    while getgenv().Settings.AutoRaid.enabled do 
        if game.PlaceId == 91797414023830 then  
            pcall(function()
                local npcPosition = Vector3.new(7716.9052734375, -6.458414077758789, -982.3650512695312)
                local targetPosition = npcPosition + Vector3.new(0, 2, 0)

                local success = tweenTo(targetPosition)

                if not success then
                    if Root then
                        Root.CFrame = CFrame.new(targetPosition)
                    end
                end

                task.wait(0.5)

                local args = {
                    [1] = {
                        [1] = {
                            ["Name"] = "Boss Arenas",
                            ["Position"] = Vector3.new(npcPosition)
                        },
                        [2] = "\4"
                    }
                }
                ReplicatedStorage:WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                task.wait(0.5)

                local args = {
                    [1] = {
                        [1] = {
                            ["Message"] = "You looking for a real fight? It'll Cost you 5k.",
                            ["Choice"] = getgenv().Settings.AutoRaid.BossSelected,
                            ["Name"] = "Boss Arenas",
                            ["Choices"] = {
                                [1] = "Noro",
                                [2] = "Eto",
                                [3] = "Tatara",
                                [4] = "Kuzen",
                                [5] = "..."
                            },
                            ["Properties"] = {
                                ["RegularDelay"] = 0.02,
                                ["DotDelay"] = 0,
                                ["Name"] = "?",
                                ["Sound"] = "rbxassetid://6929790120"
                            },
                            ["Part"] = 1,
                            ["NPCName"] = ""
                        },
                        [2] = "\3"
                    }
                }
                ReplicatedStorage:WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                task.wait(3)
            end)
        elseif game.PlaceId == 89413197677760 then  
            if IsTeleportingToVoid then
                task.wait(1)
                continue
            end

            task.spawn(function()
                while getgenv().Settings.AutoRaid.enabled and game.PlaceId == 89413197677760 and not IsTeleportingToVoid do 
                    if Character and Character:FindFirstChild("Toggle") and Character.Toggle.Value == false then
                        local args = {
                            [1] = {
                                [1] = {
                                    ["Module"] = "Toggle",
                                    ["IsHolding"] = true
                                },
                                [2] = "\5"
                            }
                        }
                        ReplicatedStorage:WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                    end
                    task.wait(2)
                end
            end)

            pcall(function()
                RaidStartTime = tick()
                while tick() - RaidStartTime < 20 and getgenv().Settings.AutoRaid.enabled and not IsTeleportingToVoid do 
                    local foundBoss = false

                    for _, v in pairs(workspace.Entities:GetChildren()) do
                        if v.Name ~= LocalPlayer.Name and v:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(v) then
                            foundBoss = true
                            local boss = v.HumanoidRootPart
                            local distance = (boss.Position - Root.Position).Magnitude

                            if distance > 10 then
                                teleportTo(boss.CFrame)
                            else
                                Root.CFrame = boss.CFrame

                                local args = {
                                    [1] = {
                                        [1] = {
                                            ["Module"] = "M1"
                                        },
                                        [2] = "\5"
                                    }
                                }
                                ReplicatedStorage:WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                            end
                            break
                        end
                    end

                    if not foundBoss then
                        task.wait(0.5)
                    else
                        task.wait(0.1)
                    end
                end

                if getgenv().Settings.AutoRaid.enabled and not IsTeleportingToVoid then 
                    local timeSpentRaiding = tick() - RaidStartTime

                    notify(
                        "<font color='#FF9966'>Respawning Player</font>",
                        "<font color='#FFCC66'>" .. formatTime(timeSpentRaiding) .. "</font>",
                        3
                    )

                    tweenToVoid()
                end
            end)
        end

        task.wait(1)
    end
end

getgenv().ChangeBossTarget = function(bossName)
    if bossName and (bossName == "Noro" or bossName == "Eto" or bossName == "Tatara" or bossName == "Kuzen") then
        getgenv().Settings.AutoRaid.BossSelected = bossName
        notify(
            "<font color='#66FF99'>Boss Changed</font>",
            "<font color='#FFCC66'>" .. bossName .. "</font>",
            3
        )
    else
        notify(
            "<font color='#FF6666'>Invalid Boss</font>",
            "<font color='#FFCC66'>Valid: Noro, Eto, Tatara, Kuzen</font>",
            3
        )
    end
end

notify(
    "<font color='#FF99CC'>Raid Bot Started</font>",
    "<font color='#FFCC66'>" .. getgenv().Settings.AutoRaid.BossSelected .. "</font>",
    5
)

coroutine.wrap(runRaidBot)()
