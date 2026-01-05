-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot Settings
local AimbotEnabled = true -- Master switch for the aimbot
local AimKey = Enum.KeyCode.RightMouseButton -- Key to activate aimbot
local AimRadius = 150 -- The radius (in pixels) around the mouse to search for targets
local TargetPartName = "Head" -- The part to aim at (e.g., "Head", "HumanoidRootPart")

local IsAiming = false
local Target = nil

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Aimbot Menu"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 160, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -80, 0.5, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Aimbot: ON"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

-- GUI Logic
ToggleButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        ToggleButton.Text = "Aimbot: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "Aimbot: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)


-- Function to get the closest target to the mouse
local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = AimRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPartName) and player.Character.Humanoid.Health > 0 then
            local targetPart = player.Character[TargetPartName]
            local screenPosition, onScreen = Camera:WorldToScreenPoint(targetPart.Position)

            if onScreen then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Handle mouse input
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

        if AimbotEnabled and input.KeyCode == AimKey then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimKey then
        IsAiming = false
        Target = nil
    end
end)

-- Main aimbot loop
RunService.RenderStepped:Connect(function()
        if IsAiming and AimbotEnabled then
        if not Target then
            Target = GetClosestTarget()
        end

        if Target and Target.Character and Target.Character:FindFirstChild(TargetPartName) then
            local targetPart = Target.Character[TargetPartName]
            -- Smoothly move the camera towards the target
            local newCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.2) -- Adjust the 0.2 value for more or less smoothing
        else
            -- If target is lost or dead, find a new one on the next frame
            Target = nil
        end
    end
end)

print("Aimbot script loaded.")
