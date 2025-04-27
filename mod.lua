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
    ESP_OBJECTS[player] = box
end

local function removeESP(player)
    if ESP_OBJECTS[player] then
        ESP_OBJECTS[player]:Remove()
        ESP_OBJECTS[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, box in pairs(ESP_OBJECTS) do box.Visible = false end
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
                local box = ESP_OBJECTS[player]
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                box.Color = ESP_COLOR
                box.Visible = visible
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
            snowCircle.Color = Color3.fromRGB(0, 200, 255)
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

-- Criar o Menu Futurista
local function createMenu()
    menuGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    menuGui.Name = "FuturisticMenu"
    menuGui.ResetOnSpawn = false

    local panel = Instance.new("Frame", menuGui)
    panel.Size = UDim2.new(0, 300, 0, 450)
    panel.Position = UDim2.new(0.5, -150, 0.5, -225)
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 0

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 15)
    Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 255, 200)

    -- Botão de fechar
    local closeButton = Instance.new("TextButton", panel)
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeButton.Text = "✖️"
    closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 22
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 8)

    closeButton.MouseButton1Click:Connect(function()
        menuGui.Enabled = not menuGui.Enabled
    end)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "☣ CEIFADOR V2 ☣"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.Font = Enum.Font.SciFi
    title.TextSize = 28

    -- Função para adicionar botões
    local function addButton(text, posY, callback)
        local button = Instance.new("TextButton", panel)
        button.Size = UDim2.new(0, 260, 0, 50)
        button.Position = UDim2.new(0, 20, 0, posY)
        button.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(0, 255, 200)
        button.Font = Enum.Font.SciFi
        button.TextSize = 22
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

        button.MouseButton1Click:Connect(callback)
    end

    addButton("ESP", 70, function()
        ESP_ENABLED = not ESP_ENABLED
    end)

    addButton("AIMBOT", 140, function()
        AIMBOT_ENABLED = not AIMBOT_ENABLED
    end)

    addButton("SNOW FOV", 210, function()
        SNOW_FOV = not SNOW_FOV
    end)

    addButton("NOCLIP", 280, function()
        noclip = not noclip
    end)

    addButton("AUMENTAR FOV", 350, function()
        FOV_RADIUS = FOV_RADIUS + 10
    end)
end

-- Abrir o menu diretamente
createMenu()

-- Mobile shooting
UserInputService.TouchStarted:Connect(function()
    shooting = true
end)

UserInputService.TouchEnded:Connect(function()
    shooting = false
end)
