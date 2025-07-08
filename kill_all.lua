local Ragebot = {
    ["Reloading"] = false;
    ["Enabled"] = true;
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local E_Tech = game:GetService("ReplicatedStorage").eTech

local Status_Indicator = Drawing.new('Text')
Status_Indicator.Text = 'Status: None'
Status_Indicator.Center = true
Status_Indicator.Position = workspace.CurrentCamera.ViewportSize / 2
Status_Indicator.Color = Color3.new(1, 1, 1)
Status_Indicator.Visible = true
Status_Indicator.Outline = true
Status_Indicator.Size = 15
Status_Indicator.ZIndex = 1500


Ragebot.Reload = function(Tool)
    if Ragebot.Reloading then return end
    Ragebot.Reloading = true
    Status_Indicator.Text = "Status: Reloading..."
    E_Tech.Remotes.BlasterReload:FireServer()
    local connection
    connection = Tool.ServerAmmo:GetPropertyChangedSignal("Value"):Connect(function()
        if Tool.ServerAmmo.Value > 0 then
            Ragebot.Reloading = false
            Status_Indicator.Text = "Status: Ready"
            if connection then connection:Disconnect() end
        end
    end)
end

Ragebot.Inflict_Target = function(Target, Tool)
    if Ragebot.Reloading then
        Status_Indicator.Text = "Status: Reloading..."
        return
    end
    if not Target.Character or not Target.Character:FindFirstChild("Head") then return end
    if Tool:FindFirstChild("ServerAmmo") and Tool.ServerAmmo.Value <= 0 then
        Ragebot.Reload(Tool)
        return
    end

    Status_Indicator.Text = "Status: Shooting"
    local Args = {
        [1] = 1,
        [2] = Tool.Emitter.Position,
        [3] = Vector3.new(-0.8963058590888977, 0.053877294063568115, -0.44196367263793945),
        [4] = Tool.BlasterSettings.Stats.ProjectileSpeed.Value,
        [7] = 49.04999923706055,
        [8] = Color3.new(1, 0.6666666865348816, 0),
        [9] = {
            [1] = LocalPlayer.Character,
            [2] = workspace:WaitForChild("Ignore")
        },
        [10] = 534.9458643151447,
        [11] = Tool.BlasterSettings.Stats.FireRate.Value,
        [12] = Tool.Ammo
    }
    E_Tech.Remotes.ProjectileReplicate:FireServer(unpack(Args))

    local Args2 = {
        [1] = Tool,
        [2] = Tool.Emitter.Position,
        [3] = workspace.Ignore.Projectiles:FindFirstChild("Bullet"),
        [4] = Target.Character.Head,
        [5] = Target.Character.Head.Position,
        [6] = Vector3.new(0.5746085047721863, -0.6533564329147339, 0.4929002821445465),
        [7] = Enum.Material.Fabric
    }
    E_Tech.Remotes.PH:FireServer(unpack(Args2))
    return
end

while Ragebot.Enabled do 
    task.wait(0.1)
    local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")

    if Tool and Tool:FindFirstChild("Ammo") then 
        for Index, Value in next, Players:GetChildren() do 
            local Success, Error = pcall(function()
                if Value and Value.Character and Value.Team ~= LocalPlayer.Team then 
                    Ragebot.Inflict_Target(Value, Tool)
                end
            end) if Error then print(tostring(Error)) end
        end
    end
end
