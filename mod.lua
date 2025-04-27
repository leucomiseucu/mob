-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat wait() until LocalPlayer:FindFirstChild("PlayerGui")

-- Variáveis
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local SNOW_FOV = false
local ESP_COLOR = Color3.fromRGB(0, 255, 255)
local ESP_OBJECTS = {}
local FOV_RADIUS = 80
local noclip = false
local shooting = false
local menuGui
local minimizedGui
local dragging, dragInput, dragStart, startPos
local snowCircle

-- Funções auxiliares
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local touch = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(touch.X, touch.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < dist and distance <= FOV_RADIUS then
                    closest = player
                    dist = distance
                end
            end
        end
    end
    return closest
end

-- Aimbot MOBILE
RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED and shooting then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if not target.Team or target.Team ~= LocalPlayer.Team then
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
RunService.RenderStepped:Connect(function()
    if SNOW_FOV then
        if not snowCircle then
            snowCircle = Drawing.new("Circle")
            snowCircle.Color = Color3.fromRGB(0, 200, 255)
            snowCircle.Thickness = 2
            snowCircle.Transparency = 0.5
            snowCircle.Filled = false
        end
        local touch = UserInputService:GetMouseLocation()
        snowCircle.Position = Vector2.new(touch.X, touch.Y)
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

-- Função para arrastar (draggable)
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Menu
local function createMenu()
    menuGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    menuGui.Name = "FuturisticMenu"
    menuGui.ResetOnSpawn = false

    local panel = Instance.new("Frame", menuGui)
    panel.Size = UDim2.new(0, 300, 0, 500)
    panel.Position = UDim2.new(0.5, -150, 0.5, -250)
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 0
    makeDraggable(panel)

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 15)

    local stroke = Instance.new("UIStroke", panel)
    stroke.Thickness = 2

    RunService.RenderStepped:Connect(function()
        local t = tick() * 100
        stroke.Color = Color3.fromHSV((t % 255) / 255, 1, 1)
    end)

    local minimizeButton = Instance.new("TextButton", panel)
    minimizeButton.Size = UDim2.new(0, 40, 0, 40)
    minimizeButton.Position = UDim2.new(1, -50, 0, 10)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 22
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 8)

    minimizeButton.MouseButton1Click:Connect(function()
        menuGui.Enabled = false
        minimizedGui.Enabled = true
    end)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "☣ CEIFADOR V2 ☣"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.Font = Enum.Font.SciFi
    title.TextSize = 28

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

    addButton("ESP", 70, function() ESP_ENABLED = not ESP_ENABLED end)
    addButton("AIMBOT", 140, function() AIMBOT_ENABLED = not AIMBOT_ENABLED end)
    addButton("SNOW FOV", 210, function() SNOW_FOV = not SNOW_FOV end)
    addButton("NOCLIP", 280, function() noclip = not noclip end)
    addButton("AUMENTAR FOV", 350, function() FOV_RADIUS = FOV_RADIUS + 10 end)

    -- Color Picker para FOV
    local colorPickerLabel = Instance.new("TextLabel", panel)
    colorPickerLabel.Size = UDim2.new(0, 260, 0, 20)
    colorPickerLabel.Position = UDim2.new(0, 20, 0, 420)
    colorPickerLabel.BackgroundTransparency = 1
    colorPickerLabel.Text = "Mudar Cor do FOV"
    colorPickerLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    colorPickerLabel.Font = Enum.Font.SciFi
    colorPickerLabel.TextSize = 18

    local colorPicker = Instance.new("TextBox", panel)
    colorPicker.Size = UDim2.new(0, 260, 0, 30)
    colorPicker.Position = UDim2.new(0, 20, 0, 450)
    colorPicker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    colorPicker.PlaceholderText = "Digite RGB: exemplo 255,0,0"
    colorPicker.Text = ""
    colorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorPicker.Font = Enum.Font.Gotham
    colorPicker.TextSize = 16
    Instance.new("UICorner", colorPicker).CornerRadius = UDim.new(0, 8)

    colorPicker.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = colorPicker.Text
            local r, g, b = text:match("(%d+),%s*(%d+),%s*(%d+)")
            if r and g and b then
                r, g, b = tonumber(r), tonumber(g), tonumber(b)
                if snowCircle then
                    snowCircle.Color = Color3.fromRGB(r, g, b)
                end
            end
        end
    end)
end

local function createMinimizedGui()
    minimizedGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    minimizedGui.Name = "MinimizedMenu"
    minimizedGui.Enabled = false

    local bar = Instance.new("TextButton", minimizedGui)
    bar.Size = UDim2.new(0, 80, 0, 30)
    bar.Position = UDim2.new(0.5, -40, 0.5, -15)
    bar.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
    bar.Text = "+"
    bar.TextColor3 = Color3.fromRGB(255, 255, 255)
    bar.Font = Enum.Font.GothamBold
    bar.TextSize = 24
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

    makeDraggable(bar)

    bar.MouseButton1Click:Connect(function()
        minimizedGui.Enabled = false
        menuGui.Enabled = true
    end)
end

-- Inicializar o Menu
createMenu()
createMinimizedGui()
