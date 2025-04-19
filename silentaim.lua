— snoopy silent script is so cool
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Enabled = true,
    TargetPart = "Head",
    TeamCheck = true,
    MaxRange = 1000,
    Prediction = 0.13,
    FieldOfView = 90
}

local function IsEnemy(player)
    return player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.TargetPart)
        and (not Settings.TeamCheck or player.Team ~= LocalPlayer.Team)
end

local function GetClosestTarget()
    local closest = nil
    local closestDist = Settings.FieldOfView

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local char = player.Character
            local targetPart = char:FindFirstChild(Settings.TargetPart)
            local root = char:FindFirstChild("HumanoidRootPart")

            if targetPart and root then
                local predicted = targetPart.Position + (root.Velocity * Settings.Prediction)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predicted)

                if onScreen then
                    local dist = (Camera.CFrame.Position - targetPart.Position).Magnitude
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

                    if dist <= Settings.MaxRange and screenDist < closestDist then
                        closestDist = screenDist
                        closest = predicted
                    end
                end
            end
        end
    end

    return closest
end

local namecall
namecall = hookmetamethod(game, "namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if Settings.Enabled and tostring(method) == "FireServer" and self.Name == "Shoot" then
        local target = GetClosestTarget()
        if target then
            local origin = Camera.CFrame.Position
            local direction = (target - origin).Unit * Settings.MaxRange

            if typeof(args[1]) == "CFrame" then
                args[1] = CFrame.new(origin, target)
            elseif typeof(args[1]) == "Vector3" then
                args[1] = direction
            end

            return namecall(self, unpack(args))
        end
    end

    return __namecall(self, ...)
end)
