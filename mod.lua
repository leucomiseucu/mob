-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat wait() until LocalPlayer:FindFirstChild("PlayerGui")

-- VARIÁVEIS
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local SNOW_FOV = false
local noclip = false
local shooting = false
local MAGIC_BULLET = false
local FOV_RADIUS = 80
local ESP_COLOR = Color3.fromRGB(0, 255, 255)
local ESP_OBJECTS = {}
local menuGui
local minimizedGui
local dragging, dragInput, dragStart, startPos
local snowCircle

-- FUNÇÕES
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

-- AIMBOT
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

-- MAGIC BULLET
local function magicBullet()
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if MAGIC_BULLET then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    for _,v in pairs(tool:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            v:FireServer(target.Character.Head.Position)
                        end
                    end
                end
            end
        end
    end)
end
magicBullet()

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

-- SNOW FOV
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

-- DRAGGABLE
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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

-- MENU
local function createMenu()
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "FuturisticMenu"
    menuGui.ResetOnSpawn = false
    menuGui.Parent = LocalPlayer.PlayerGui

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
    addButton("BALA MÁGICA", 350, function()
        MAGIC_BULLET = not MAGIC_BULLET
    end)
    addButton("AUMENTAR FOV", 420, function()
        FOV_RADIUS = FOV_RADIUS + 10
    end)
end

createMenu()

-- MOBILE SHOOTING
UserInputService.TouchStarted:Connect(function()
    shooting = true
end)
UserInputService.TouchEnded:Connect(function()
    shooting = false
end)
