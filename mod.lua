-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- VARIÁVEIS GLOBAIS
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local SNOW_FOV = false
local ESP_COLOR = Color3.fromRGB(0, 255, 255)
local FOV_COLOR = Color3.fromRGB(0, 200, 255)
local FOV_RADIUS = 80
local noclip = false
local shooting = false
local menuOpen = false
local ESP_OBJECTS = {}
local snowCircle

-- CRIA GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "CustomMenu"

local menuButton = Instance.new("TextButton", screenGui)
menuButton.Size = UDim2.new(0, 50, 0, 100)
menuButton.Position = UDim2.new(0, 0, 0.4, 0)
menuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuButton.Text = "Menu"
menuButton.Font = Enum.Font.GothamBold
menuButton.TextColor3 = Color3.new(1,1,1)
menuButton.TextSize = 18

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 0, 0.6, 0)
menuFrame.Position = UDim2.new(0, 50, 0.2, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 12)

local uiList = Instance.new("UIListLayout", menuFrame)
uiList.Padding = UDim.new(0, 10)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top

-- FUNÇÕES
local function toggleMenu()
    menuOpen = not menuOpen
    menuFrame.Visible = true
    local goal = {}
    goal.Size = menuOpen and UDim2.new(0, 200, 0.6, 0) or UDim2.new(0, 0, 0.6, 0)
    local tween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    tween.Completed:Connect(function()
        if not menuOpen then
            menuFrame.Visible = false
        end
    end)
end

menuButton.MouseButton1Click:Connect(toggleMenu)

local function createButton(text, callback)
    local button = Instance.new("TextButton", menuFrame)
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.fromRGB(0, 255, 200)
    button.TextSize = 18
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.MouseButton1Click:Connect(callback)
end

-- BOTÕES
createButton("ESP", function()
    ESP_ENABLED = not ESP_ENABLED
end)

createButton("Aimbot", function()
    AIMBOT_ENABLED = not AIMBOT_ENABLED
end)

createButton("Snow FOV", function()
    SNOW_FOV = not SNOW_FOV
end)

createButton("Noclip", function()
    noclip = not noclip
end)

createButton("Aumentar FOV", function()
    FOV_RADIUS = FOV_RADIUS + 10
end)

-- SELETOR DE COR
local colorPicker = Instance.new("ImageButton", menuFrame)
colorPicker.Size = UDim2.new(0.8, 0, 0, 80)
colorPicker.Image = "rbxassetid://YOUR_IMAGE_ID_HERE" -- Substituir pelo seu ID de imagem
colorPicker.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", colorPicker).CornerRadius = UDim.new(0, 8)

colorPicker.MouseButton1Down:Connect(function(x,y)
    local rel = Vector2.new(x,y) - colorPicker.AbsolutePosition
    local percent = Vector2.new(rel.X / colorPicker.AbsoluteSize.X, rel.Y / colorPicker.AbsoluteSize.Y)
    local h = percent.X
    local s = 1 - percent.Y
    FOV_COLOR = Color3.fromHSV(h, s, 1)
end)

-- SISTEMA DE FOV
RunService.RenderStepped:Connect(function()
    if SNOW_FOV then
        if not snowCircle then
            snowCircle = Drawing.new("Circle")
            snowCircle.Thickness = 2
            snowCircle.Filled = false
        end
        local mouse = LocalPlayer:GetMouse()
        snowCircle.Position = Vector2.new(mouse.X, mouse.Y)
        snowCircle.Radius = FOV_RADIUS
        snowCircle.Color = FOV_COLOR
        snowCircle.Visible = true
    elseif snowCircle then
        snowCircle.Visible = false
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
