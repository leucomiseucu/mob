-- Carregar a biblioteca Orion UI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

-- Variáveis Globais
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local aimbotEnabled = false
local espEnabled = false
local magicBulletEnabled = false
local wallhackEnabled = false
local ESP_OBJECTS = {}

-- FOV Circle
local FOV_RADIUS = 80
local FOV_CIRCLE = nil

-- Funções Aimbot
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < shortestDistance and distance < FOV_RADIUS then
                    shortestDistance = distance
                    closestPlayer = v
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Funções ESP
RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, v in pairs(ESP_OBJECTS) do
            v.Box.Visible = false
            v.Text.Visible = false
        end
        return
    end

    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not ESP_OBJECTS[plr] then
                    local box = Drawing.new("Square")
                    box.Color = Color3.fromRGB(0, 255, 255)
                    box.Thickness = 2
                    box.Filled = false

                    local healthText = Drawing.new("Text")
                    healthText.Color = Color3.fromRGB(0, 255, 0)
                    healthText.Size = 16
                    healthText.Center = true
                    healthText.Outline = true

                    ESP_OBJECTS[plr] = {Box = box, Text = healthText}
                end

                local pos, onScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)
                local size = (camera:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(2,3,0)) - camera:WorldToViewportPoint(plr.Character.Head.Position - Vector3.new(2,3,0))).Magnitude

                local obj = ESP_OBJECTS[plr]
                obj.Box.Size = Vector2.new(size, size * 1.5)
                obj.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size * 1.5 / 2)
                obj.Box.Visible = onScreen
                obj.Text.Position = Vector2.new(pos.X, pos.Y - size)
                obj.Text.Text = math.floor(humanoid.Health) .. " HP"
                obj.Text.Visible = onScreen
            else
                if ESP_OBJECTS[plr] then
                    ESP_OBJECTS[plr].Box:Remove()
                    ESP_OBJECTS[plr].Text:Remove()
                    ESP_OBJECTS[plr] = nil
                end
            end
        end
    end
end)

-- Função Wallhack
RunService.RenderStepped:Connect(function()
    if wallhackEnabled then
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Silent Aim (Bala Mágica)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if magicBulletEnabled and tostring(self) == "Humanoid" and key == "Health" then
        return math.huge
    end
    return oldIndex(self, key)
end)

-- Definindo a chave para acesso
local key = "9M"

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

-- Função de Key
local KeyFrame = Instance.new("Frame")
KeyFrame.Parent = game.CoreGui
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeyFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
KeyFrame.Size = UDim2.new(0, 300, 0, 200)

local TextBox = Instance.new("TextBox")
TextBox.Parent = KeyFrame
TextBox.PlaceholderText = "Digite a key aqui"
TextBox.Text = ""
TextBox.Size = UDim2.new(0, 200, 0, 40)
TextBox.Position = UDim2.new(0.15, 0, 0.2, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextScaled = true

local SubmitButton = Instance.new("TextButton")
SubmitButton.Parent = KeyFrame
SubmitButton.Text = "Entrar"
SubmitButton.Size = UDim2.new(0, 150, 0, 40)
SubmitButton.Position = UDim2.new(0.25, 0, 0.6, 0)
SubmitButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.Font = Enum.Font.SourceSans
SubmitButton.TextScaled = true

SubmitButton.MouseButton1Click:Connect(function()
    if TextBox.Text == key then
        KeyFrame.Visible = false

        local Tab = Window:MakeTab({
            Name = "Recursos",
            Icon = "rbxassetid://4483345998",
            PremiumOnly = false
        })

        local Section = Tab:AddSection({
            Name = "Ferramentas"
        })

        Section:AddButton({
            Name = "Ativar Aimbot",
            Callback = function()
                aimbotEnabled = not aimbotEnabled
                OrionLib:MakeNotification({
                    Name = "Aimbot",
                    Content = aimbotEnabled and "Aimbot Ativado" or "Aimbot Desativado",
                    Time = 3
                })
            end
        })

        Section:AddButton({
            Name = "Ativar ESP",
            Callback = function()
                espEnabled = not espEnabled
                OrionLib:MakeNotification({
                    Name = "ESP",
                    Content = espEnabled and "ESP Ativado" or "ESP Desativado",
                    Time = 3
                })
            end
        })

        Section:AddButton({
            Name = "Ativar Silent Aim",
            Callback = function()
                magicBulletEnabled = not magicBulletEnabled
                OrionLib:MakeNotification({
                    Name = "Silent Aim",
                    Content = magicBulletEnabled and "Bala mágica Ativada" or "Bala mágica Desativada",
                    Time = 3
                })
            end
        })

        Section:AddButton({
            Name = "Ativar Wallhack",
            Callback = function()
                wallhackEnabled = not wallhackEnabled
                OrionLib:MakeNotification({
                    Name = "Wallhack",
                    Content = wallhackEnabled and "Wallhack Ativado" or "Wallhack Desativado",
                    Time = 3
                })
            end
        })

        Window:Show()
    else
        TextBox.Text = ""
        TextBox.PlaceholderText = "Key incorreta!"
    end
end)
