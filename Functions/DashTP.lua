local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local ccgBase = workspace.Warps.Warps.CCG
local ccgLab = workspace.Warps.Warps.CCGLaboratory
local Anteiku = workspace.Warps.Warps.Anteiku
local AogiriBase = workspace.Warps.Warps.AogiriBase
local Helter_Shelter = workspace.Warps.Warps["Helter Shelter"]
local Hospital = workspace.Warps.Warps.Hospital
local Clothing Store = workspace.Warps.Warps["Clothing Store"]

function DashTP(target)
    local localPlayer = game:GetService("Players").LocalPlayer
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Action Failed", "Character not available")
        return
    end
    
    local targetCFrame
    
    if typeof(target) == "Instance" and target:IsA("Player") then
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            targetCFrame = target.Character.HumanoidRootPart.CFrame
        else
            Notify("Action Failed", "Target unavailable")
            return
        end
    
    elseif typeof(target) == "string" then
        local foundPlayer
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player.Name:lower() == target:lower() or player.DisplayName:lower() == target:lower() then
                foundPlayer = player
                break
            end
        end
        
        if foundPlayer and foundPlayer.Character and foundPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetCFrame = foundPlayer.Character.HumanoidRootPart.CFrame
        else
            Notify("Action Failed", "Target unavailable")
            return
        end
    
    elseif typeof(target) == "Vector3" then
        targetCFrame = CFrame.new(target)
    
    elseif typeof(target) == "CFrame" then
        targetCFrame = target
    
    elseif typeof(target) == "Instance" then
        if target:IsA("BasePart") then
            targetCFrame = target.CFrame
        elseif target:IsA("Model") and target.PrimaryPart then
            targetCFrame = target.PrimaryPart.CFrame
        elseif target:FindFirstChildWhichIsA("BasePart") then
            targetCFrame = target:FindFirstChildWhichIsA("BasePart").CFrame
        else
            Notify("Action Failed", "Invalid target")
            return
        end
    else
        Notify("Action Failed", "Invalid target type")
        return
    end
    

    localPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
    
    -- AFTER teleporting, fire the dash remote (for animation only)
    local args = {
        [1] = {
            [1] = {
                ["Module"] = "Dash"
            },
            [2] = "\5"
        }
    }
    
    -- Use direct reference instead of WaitForChild to avoid delays
    local remoteEvent = game:GetService("ReplicatedStorage").Bridgenet2Main.dataRemoteEvent
    remoteEvent:FireServer(unpack(args))
end

DashTP(ccgBase)
