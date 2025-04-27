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
local FOV_COLOR = Color3.fromRGB(200, 200, 255)
local ESP_OBJECTS = {}
local FOV_RADIUS = 80
local noclip = false
local menuOpen = false
local menuGui
local snowCircle
local KEY_CORRETA = "9M"
local shooting = false

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
RunService.RenderStepped:Connect(function()
    if SNOW_FOV then
        if not snowCircle then
            snowCircle = Drawing.new("Circle")
            snowCircle.Thickness = 1.5
            snowCircle.Transparency = 0.6
            snowCircle.Filled = false
        end
        local viewportSize = camera.ViewportSize
        snowCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        snowCircle.Radius = FOV_RADIUS
        snowCircle.Color = FOV_COLOR
        snowCircle.Visible = true
    elseif snowCircle then
        snowCircle.Visible = false
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- Menu Futurista
local function createMenu()
    menuGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    menuGui.Name = "FuturisticMenu"
    menuGui.ResetOnSpawn = false

    local panel = Instance.new("Frame", menuGui)
    panel.Size = UDim2.new(0, 300, 0, 500)
    panel.Position = UDim2.new(0, 20, 0, 20)
    panel.BackgroundTransparency = 0.25
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    panel.BorderSizePixel = 0

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 255, 255)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "☣ CEIFADOR GUI ☣"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeTransparency = 0.6
    title.Font = Enum.Font.SciFi
    title.TextSize = 28

    local dragging, dragStart, startPos
    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    panel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    panel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local function addButton(name, yPos, refVar, onClick)
        local btn = Instance.new("TextButton", panel)
        btn.Size = UDim2.new(0, 260, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, yPos)
        btn.Text = name .. ": OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        btn.Font = Enum.Font.SciFi
        btn.TextSize = 22
        btn.AutoButtonColor = false

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(255, 50, 50)
        stroke.Thickness = 1.5

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        btn.MouseButton1Click:Connect(function()
            refVar = not refVar
            btn.Text = name .. ": " .. (refVar and "ON" or "OFF")
            stroke.Color = refVar and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            onClick(refVar)
        end)
    end

    addButton("ESP", 60, ESP_ENABLED, function(v) ESP_ENABLED = v end)
    addButton("AIMBOT", 120, AIMBOT_ENABLED, function(v) AIMBOT_ENABLED = v end)
    addButton("SNOW FOV", 180, SNOW_FOV, function(v) SNOW_FOV = v end)

    local fovButton = Instance.new("TextButton", panel)
    fovButton.Size = UDim2.new(0, 260, 0, 50)
    fovButton.Position = UDim2.new(0, 20, 0, 240)
    fovButton.Text = "Aumentar FOV"
    fovButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fovButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovButton.Font = Enum.Font.GothamBlack
    fovButton.TextSize = 18

    fovButton.MouseButton1Click:Connect(function()
        FOV_RADIUS = FOV_RADIUS + 10
    end)

    local colorButton = Instance.new("TextButton", panel)
    colorButton.Size = UDim2.new(0, 260, 0, 50)
    colorButton.Position = UDim2.new(0, 20, 0, 300)
    colorButton.Text = "Mudar Cor FOV"
    colorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorButton.Font = Enum.Font.GothamBlack
    colorButton.TextSize = 18

    colorButton.MouseButton1Click:Connect(function()
        FOV_COLOR = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
    end)

    menuGui.Enabled = false
end

-- Painel de Key
local function createKeySystem()
    local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    screenGui.Name = "KeySystemMenu"
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 400, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(150, 0, 255)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🧅 Ceifador Menu v1 - 9M Vazamentos🧅"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1

    local keyInput = Instance.new("TextBox", mainFrame)
    keyInput.Size = UDim2.new(0, 300, 0, 40)
    keyInput.Position = UDim2.new(0.5, -150, 0, 60)
    keyInput.PlaceholderText = "Coloque a key..."
    keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.Font = Enum.Font.Gotham
    keyInput.TextSize = 18

    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

    local checkButton = Instance.new("TextButton", mainFrame)
    checkButton.Size = UDim2.new(0, 300, 0, 40)
    checkButton.Position = UDim2.new(0.5, -150, 0, 120)
    checkButton.Text = "🔒 Checkar Key"
    checkButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    checkButton.TextColor3 = Color3.fromRGB(0, 255, 0)
    checkButton.Font = Enum.Font.GothamBold
    checkButton.TextSize = 18

    Instance.new("UICorner", checkButton).CornerRadius = UDim.new(0, 8)

    checkButton.MouseButton1Click:Connect(function()
        if keyInput.Text == KEY_CORRETA then
            screenGui:Destroy()
            createMenu()
        else
            keyInput.Text = ""
            keyInput.PlaceholderText = "❌ Key Incorreta!"
        end
    end)
end

-- Começar chamando o Key System
createKeySystem()

-- Input para abrir/fechar o menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.N then
            if menuGui then menuGui.Enabled = true end
        elseif input.KeyCode == Enum.KeyCode.H then
            if menuGui then menuGui.Enabled = false end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            shooting = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            shooting = false
        end
    end
end)
