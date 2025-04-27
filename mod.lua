-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat wait() until LocalPlayer:FindFirstChild("PlayerGui")

-- Variáveis globais
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local SNOW_FOV = false
local ESP_COLOR = Color3.fromRGB(0, 255, 255)
local ESP_OBJECTS = {}
local FOV_RADIUS = 80
local noclip = false
local shooting = false
local menuGui
local dragging, dragInput, dragStart, startPos

-- Funções auxiliares
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mouse = LocalPlayer:GetMouse()
                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < dist and distance <= FOV_RADIUS then
                    closest = player
                    dist = distance
                end
            end
        end
    end
    return closest
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED and shooting then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if target.Team ~= LocalPlayer.Team then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

-- ESP
local function createESP(player)
    local box = Drawing.new("Square")
    box.Color = ESP_COLOR
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false

    local healthText = Drawing.new("Text")
    healthText.Color = Color3.fromRGB(0, 255, 0)
    healthText.Size = 16
    healthText.Center = true
    healthText.Outline = true

    ESP_OBJECTS[player] = {Box = box, Health = healthText}
end

local function removeESP(player)
    if ESP_OBJECTS[player] then
        ESP_OBJECTS[player].Box:Remove()
        ESP_OBJECTS[player].Health:Remove()
        ESP_OBJECTS[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, obj in pairs(ESP_OBJECTS) do
            obj.Box.Visible = false
            obj.Health.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not ESP_OBJECTS[player] then
                    createESP(player)
                end
                local head = player.Character.Head
                local pos, visible = camera:WorldToViewportPoint(head.Position)
                local size = (camera:WorldToViewportPoint(head.Position + Vector3.new(2, 3, 0)) - camera:WorldToViewportPoint(head.Position - Vector3.new(2, 3, 0))).Magnitude
                local obj = ESP_OBJECTS[player]
                obj.Box.Size = Vector2.new(size, size * 1.5)
                obj.Box.Position = Vector2.new(pos.X - obj.Box.Size.X/2, pos.Y - obj.Box.Size.Y/2)
                obj.Box.Color = ESP_COLOR
                obj.Box.Visible = visible

                obj.Health.Position = Vector2.new(pos.X, pos.Y - obj.Box.Size.Y/2 - 10)
                obj.Health.Text = math.floor(humanoid.Health) .. " HP"
                obj.Health.Visible = visible
            else
                removeESP(player)
            end
        else
            removeESP(player)
        end
    end
end)

-- Snow FOV
local snowCircle
RunService.RenderStepped:Connect(function()
    if SNOW_FOV then
        if not snowCircle then
            snowCircle = Drawing.new("Circle")
            snowCircle.Color = ESP_COLOR
            snowCircle.Thickness = 2
            snowCircle.Transparency = 0.5
            snowCircle.Filled = false
        end
        local mouse = LocalPlayer:GetMouse()
        snowCircle.Position = Vector2.new(mouse.X, mouse.Y)
        snowCircle.Radius = FOV_RADIUS
        snowCircle.Visible = true
    elseif snowCircle then
        snowCircle.Visible = false
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Criar Menu
local function createMenu()
    menuGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    menuGui.Name = "MobileMenu"
    menuGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 180, 0, 300)
    mainFrame.Position = UDim2.new(0, 10, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local menuButton = Instance.new("TextButton", menuGui)
    menuButton.Size = UDim2.new(0, 60, 0, 30)
    menuButton.Position = UDim2.new(0, 10, 0.25, 0)
    menuButton.Text = "Menu"
    menuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 60)
    menuButton.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", menuButton).CornerRadius = UDim.new(0, 8)

    menuButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    local function addButton(text, posY, callback)
        local button = Instance.new("TextButton", mainFrame)
        button.Size = UDim2.new(0.9, 0, 0, 40)
        button.Position = UDim2.new(0.05, 0, 0, posY)
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        button.Text = text
        button.TextColor3 = Color3.new(0,1,1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 18
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

        button.MouseButton1Click:Connect(callback)
    end

    addButton("ESP", 10, function()
        ESP_ENABLED = not ESP_ENABLED
    end)

    addButton("AIMBOT", 60, function()
        AIMBOT_ENABLED = not AIMBOT_ENABLED
    end)

    addButton("SNOW FOV", 110, function()
        SNOW_FOV = not SNOW_FOV
    end)

    addButton("NOCLIP", 160, function()
        noclip = not noclip
    end)

    addButton("AUMENTAR FOV", 210, function()
        FOV_RADIUS = FOV_RADIUS + 10
    end)

    local colorPicker = Instance.new("TextButton", mainFrame)
    colorPicker.Size = UDim2.new(0.9, 0, 0, 40)
    colorPicker.Position = UDim2.new(0.05, 0, 0, 260)
    colorPicker.BackgroundColor3 = ESP_COLOR
    colorPicker.Text = "Mudar Cor FOV"
    colorPicker.TextColor3 = Color3.new(1,1,1)
    colorPicker.Font = Enum.Font.Gotham
    colorPicker.TextSize = 16
    Instance.new("UICorner", colorPicker).CornerRadius = UDim.new(0,8)

    colorPicker.MouseButton1Click:Connect(function()
        ESP_COLOR = Color3.fromHSV(math.random(), 1, 1)
        if snowCircle then snowCircle.Color = ESP_COLOR end
        colorPicker.BackgroundColor3 = ESP_COLOR
    end)
end

-- Disparo Mobile
UserInputService.TouchStarted:Connect(function()
    shooting = true
end)
UserInputService.TouchEnded:Connect(function()
    shooting = false
end)

-- Rodar tudo
createMenu()
