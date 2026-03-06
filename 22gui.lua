local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Testing Variables
local ESPEnabled = false
local LockOnEnabled = false
local ShowFOV = false
local FOVRadius = 100
local LockKey = Enum.UserInputType.MouseButton2

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "AC-Testing Framework v2",
    LoadingTitle = "Loading Debugger...",
    LoadingSubtitle = "FOV & Locking",
})

local MainTab = Window:CreateTab("Main Settings", 4483362458)

-- ESP Toggle
MainTab:CreateToggle({
    Name = "Enable ESP Highlight",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
    end,
})

-- Lock-On Toggle
MainTab:CreateToggle({
    Name = "Enable Head-Lock",
    CurrentValue = false,
    Callback = function(Value)
        LockOnEnabled = Value
    end,
})

-- FOV Circle Toggle
MainTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(Value)
        ShowFOV = Value
    end,
})

-- FOV Size Slider
MainTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Flag = "FOVSlider", 
    Callback = function(Value)
        FOVRadius = Value
    end,
})

-- Keybind for Toggling Lock-On
MainTab:CreateKeybind({
    Name = "Toggle Feature Lock",
    CurrentKeybind = "L",
    HoldToInteract = false,
    Callback = function()
        LockOnEnabled = not LockOnEnabled
    end,
})

--- LOGIC FUNCTIONS ---

local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                -- Check if player is within the FOV circle radius
                if distance <= FOVRadius and distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("TestHighlight")
            if ESPEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "TestHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.Parent = player.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

--- MAIN LOOP ---
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle Position/Visibility
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = FOVRadius
    FOVCircle.Visible = ShowFOV

    -- ESP Check
    UpdateESP()

    -- Lock-On Check
    if LockOnEnabled and UserInputService:IsMouseButtonPressed(LockKey) then
        local target = GetClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
