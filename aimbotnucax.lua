-- https://github.com/nucax/roblox-lua-aimbot-universal
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

local config = {
    aimbotEnabled = false,
    triggerbotEnabled = false,
    aimSmoothness = 0.1,
    fovRadius = 200,
    wallCheckAimbot = true,
    wallCheckTrigger = true,
    teamCheck = true
}

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 370)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Parent = screenGui

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 20)
minimizeButton.Position = UDim2.new(1, -45, 0, 5)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimizeButton.Parent = frame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(frame:GetChildren()) do
        if child ~= minimizeButton then
            child.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0, 40, 0, 20) or UDim2.new(0, 250, 0, 370)
end)

local function createButton(name, positionY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.Parent = frame
    return button
end

local aimbotButton = createButton("Aimbot: OFF", 30)
local triggerButton = createButton("Triggerbot: OFF", 65)
local wallCheckAButton = createButton("Aimbot WallCheck: ON", 100)
local wallCheckTButton = createButton("Triggerbot WallCheck: ON", 135)
local teamCheckButton = createButton("Team Check: ON", 170)
local closeButton = createButton("Close GUI", 205)

aimbotButton.MouseButton1Click:Connect(function()
    config.aimbotEnabled = not config.aimbotEnabled
    aimbotButton.Text = config.aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

triggerButton.MouseButton1Click:Connect(function()
    config.triggerbotEnabled = not config.triggerbotEnabled
    triggerButton.Text = config.triggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
end)

wallCheckAButton.MouseButton1Click:Connect(function()
    config.wallCheckAimbot = not config.wallCheckAimbot
    wallCheckAButton.Text = config.wallCheckAimbot and "Aimbot WallCheck: ON" or "Aimbot WallCheck: OFF"
end)

wallCheckTButton.MouseButton1Click:Connect(function()
    config.wallCheckTrigger = not config.wallCheckTrigger
    wallCheckTButton.Text = config.wallCheckTrigger and "Triggerbot WallCheck: ON" or "Triggerbot WallCheck: OFF"
end)

teamCheckButton.MouseButton1Click:Connect(function()
    config.teamCheck = not config.teamCheck
    teamCheckButton.Text = config.teamCheck and "Team Check: ON" or "Team Check: OFF"
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -10, 0, 20)
sliderLabel.Position = UDim2.new(0, 5, 0, 240)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.Text = "FOV: "..config.fovRadius
sliderLabel.Parent = frame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, -10, 0, 20)
slider.Position = UDim2.new(0, 5, 0, 260)
slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
slider.Parent = frame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 10, 1, 0)
knob.Position = UDim2.new(config.fovRadius/500, 0, 0, 0)
knob.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
knob.Parent = slider

local dragging = false
local function updateFOV(inputPositionX)
    local mouseX = math.clamp(inputPositionX - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
    config.fovRadius = math.floor((mouseX / slider.AbsoluteSize.X) * 500)
    sliderLabel.Text = "FOV: "..config.fovRadius
    knob.Position = UDim2.new(mouseX / slider.AbsoluteSize.X, 0, 0, 0)
end

local function connectSliderInput(inputType)
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == inputType then
            dragging = true
            updateFOV(input.Position.X)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == inputType then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == inputType then
            updateFOV(input.Position.X)
        end
    end)
end

connectSliderInput(Enum.UserInputType.MouseButton1)
connectSliderInput(Enum.UserInputType.Touch)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -10, 0, 20)
speedLabel.Position = UDim2.new(0, 5, 0, 285)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Text = "Aimbot Speed: "..config.aimSmoothness
speedLabel.Parent = frame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(1, -10, 0, 20)
speedSlider.Position = UDim2.new(0, 5, 0, 305)
speedSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
speedSlider.Parent = frame

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 10, 1, 0)
speedKnob.Position = UDim2.new(config.aimSmoothness, 0, 0, 0)
speedKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
speedKnob.Parent = speedSlider

local speedDragging = false
local function updateSpeed(inputPositionX)
    local mouseX = math.clamp(inputPositionX - speedSlider.AbsolutePosition.X, 0, speedSlider.AbsoluteSize.X)
    config.aimSmoothness = math.clamp(mouseX / speedSlider.AbsoluteSize.X, 0.01, 1)
    speedLabel.Text = "Aimbot Speed: "..string.format("%.2f", config.aimSmoothness)
    speedKnob.Position = UDim2.new(mouseX / speedSlider.AbsoluteSize.X, 0, 0, 0)
end

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        speedDragging = true
        updateSpeed(input.Position.X)
    end
end)
speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        speedDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if speedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSpeed(input.Position.X)
    end
end)

local rainbowText = Instance.new("TextLabel")
rainbowText.Size = UDim2.new(1, 0, 0, 20)
rainbowText.Position = UDim2.new(0, 0, 1, -20)
rainbowText.BackgroundTransparency = 1
rainbowText.Text = "https://github.com/nucax"
rainbowText.TextColor3 = Color3.new(1, 0, 0)
rainbowText.TextScaled = true
rainbowText.Parent = frame

local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.01) % 1
    rainbowText.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Transparency = 0.5
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Thickness = 2
fovCircle.Radius = config.fovRadius
fovCircle.Filled = false

local function getNearestPlayer()
    local closestPlayer = nil
    local closestMagnitude = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not config.teamCheck or (LocalPlayer.Team ~= player.Team) then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local mousePos = Camera.ViewportSize / 2
                    local magnitude = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if magnitude < closestMagnitude and magnitude < config.fovRadius then
                        closestMagnitude = magnitude
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function canHit(target)
    local origin = Camera.CFrame.Position
    local direction = target.Character.Head.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    return rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(target.Character)
end

RunService.RenderStepped:Connect(function()
    local target = getNearestPlayer()
    fovCircle.Position = Camera.ViewportSize/2
    fovCircle.Radius = config.fovRadius

    if config.aimbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") then
        if not config.wallCheckAimbot or canHit(target) then
            local headPos = target.Character.Head.Position
            local camCFrame = Camera.CFrame
            local direction = (headPos - camCFrame.Position).Unit
            Camera.CFrame = camCFrame:Lerp(CFrame.new(camCFrame.Position, camCFrame.Position + direction), config.aimSmoothness)
        end
    end

    if config.triggerbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") then
        if not config.wallCheckTrigger or canHit(target) then
            VirtualUser:Button1Down(Vector2.new(0,0))
            VirtualUser:Button1Up(Vector2.new(0,0))
        end
    end
end)
