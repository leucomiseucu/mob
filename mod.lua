-- Carregar a biblioteca Orion UI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

-- Variáveis iniciais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local AIMBOT_ENABLED = false
local ESP_ENABLED = false
local SNOW_FOV = false
local noclip = false
local shooting = false
local ESP_OBJECTS = {}
local ESP_COLOR = Color3.fromRGB(255, 0, 0)
local FOV_RADIUS = 100

-- Funções
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouse = LocalPlayer:GetMouse()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos = camera:WorldToViewportPoint(player.Character.Head.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
            if magnitude < shortestDistance then
                closestPlayer = player
                shortestDistance = magnitude
            end
        end
    end
    return closestPlayer
end

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

-- Listeners
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if AIMBOT_ENABLED and shooting then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if target.Team ~= LocalPlayer.Team then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end

    -- ESP
    if not ESP_ENABLED then
        for _, box in pairs(ESP_OBJECTS) do box.Visible = false end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not ESP_OBJECTS[player] then createESP(player) end
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
        end
    end
end)

local snowCircle
RunService.RenderStepped:Connect(function()
    if SNOW_FOV then
        if not snowCircle then
            snowCircle = Drawing.new("Circle")
            snowCircle.Color = Color3.fromRGB(200, 200, 255)
            snowCircle.Thickness = 1.5
            snowCircle.Radius = FOV_RADIUS
            snowCircle.Transparency = 0.6
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

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- Criar a janela principal do menu
local Window = OrionLib:MakeWindow({
    Name = "Ceifador Hub V3",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CeifadorHubV3",
    IntroEnabled = true,
    IntroText = "Bem-vindo ao Ceifador Hub V3!",
    Icon = "rbxassetid://4483345998"
})

-- Criar a aba principal do menu
local Tab = Window:MakeTab({
    Name = "Menu",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = Tab:AddSection({
    Name = "Recursos"
})

Section:AddButton({
    Name = "Ativar Aimbot",
    Callback = function()
        AIMBOT_ENABLED = not AIMBOT_ENABLED
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = AIMBOT_ENABLED and "Aimbot Ativado" or "Aimbot Desativado",
            Time = 3
        })
    end
})

Section:AddButton({
    Name = "Ativar ESP",
    Callback = function()
        ESP_ENABLED = not ESP_ENABLED
        OrionLib:MakeNotification({
            Name = "ESP",
            Content = ESP_ENABLED and "ESP Ativado" or "ESP Desativado",
            Time = 3
        })
    end
})

Section:AddButton({
    Name = "Ativar Silent Aim",
    Callback = function()
        shooting = not shooting
        OrionLib:MakeNotification({
            Name = "Silent Aim",
            Content = shooting and "Silent Aim Ativado" or "Silent Aim Desativado",
            Time = 3
        })
    end
})

Section:AddButton({
    Name = "Ativar Wallhack (NoClip)",
    Callback = function()
        noclip = not noclip
        OrionLib:MakeNotification({
            Name = "Wallhack",
            Content = noclip and "Wallhack Ativado" or "Wallhack Desativado",
            Time = 3
        })
    end
})
