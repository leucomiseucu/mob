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
local currentTab = "main"

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

-- Menu
local function dragify(frame)
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.Heartbeat:Connect(function()
        if dragToggle and dragInput then
            update(dragInput)
        end
    end)
end

local function createMenu()
    menuGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    menuGui.Name = "FuturisticMenu"
    menuGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

    local tabFolder = Instance.new("Frame", mainFrame)
    tabFolder.Size = UDim2.new(1, 0, 1, 0)
    tabFolder.Position = UDim2.new(0, 0, 0, 0)
    tabFolder.BackgroundTransparency = 1

    local mainTab = Instance.new("Frame", tabFolder)
    mainTab.Name = "Main"
    mainTab.Size = UDim2.new(1, 0, 1, 0)
    mainTab.BackgroundTransparency = 1

    local creditsTab = Instance.new("Frame", tabFolder)
    creditsTab.Name = "Credits"
    creditsTab.Size = UDim2.new(1, 0, 1, 0)
    creditsTab.BackgroundTransparency = 1
    creditsTab.Visible = false

    local function switchTab(tabName)
        mainTab.Visible = (tabName == "main")
        creditsTab.Visible = (tabName == "credits")
    end

    local function addButton(parent, text, posY, callback)
        local button = Instance.new("TextButton", parent)
        button.Size = UDim2.new(0, 260, 0, 40)
        button.Position = UDim2.new(0, 30, 0, posY)
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(200, 200, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 18
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

        button.MouseButton1Click:Connect(callback)
    end

    addButton(mainTab, "ESP", 20, function() ESP_ENABLED = not ESP_ENABLED end)
    addButton(mainTab, "AIMBOT", 70, function() AIMBOT_ENABLED = not AIMBOT_ENABLED end)
    addButton(mainTab, "SNOW FOV", 120, function() SNOW_FOV = not SNOW_FOV end)
    addButton(mainTab, "NOCLIP", 170, function() noclip = not noclip end)

    local fovSlider = Instance.new("TextLabel", mainTab)
    fovSlider.Size = UDim2.new(0, 280, 0, 40)
    fovSlider.Position = UDim2.new(0, 20, 0, 220)
    fovSlider.BackgroundTransparency = 1
    fovSlider.Text = "FOV: " .. FOV_RADIUS
    fovSlider.TextColor3 = Color3.fromRGB(0, 200, 255)
    fovSlider.Font = Enum.Font.Gotham
    fovSlider.TextSize = 18

    addButton(mainTab, "CRÉDITOS", 270, function() switchTab("credits") end)

    local creditsText = Instance.new("TextLabel", creditsTab)
    creditsText.Size = UDim2.new(1, 0, 1, 0)
    creditsText.TextWrapped = true
    creditsText.BackgroundTransparency = 1
    creditsText.Text = "9M - 16M\nFeito por @dzsists - Ceifador o melhor de todos\nQuer comprar hacks personalizáveis por apenas 6$?\nVem pv @dzsists!"
    creditsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditsText.Font = Enum.Font.GothamBold
    creditsText.TextSize = 18

    -- Botão Flutuante 🔥
    local toggleButton = Instance.new("TextButton", menuGui)
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 100, 0, 100)
    toggleButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
    toggleButton.Text = "🔥"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBlack
    toggleButton.TextSize = 30
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

    toggleButton.MouseButton1Click:Connect(function()
        menuGui.Enabled = not menuGui.Enabled
    end)

    dragify(toggleButton)
end

-- Inicializar
createMenu()

-- Mobile shooting
UserInputService.TouchStarted:Connect(function()
    shooting = true
end)

UserInputService.TouchEnded:Connect(function()
    shooting = false
end)
