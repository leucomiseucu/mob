-- Dependências
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variáveis Globais
local ESP_COLOR = Color3.fromRGB(255, 0, 0)
local FOV_RADIUS = 50
local snowCircle = nil
local showFov = false
local showESP = false
local espObjects = {}

-- Função para criar o FOV
function createFOV()
    if snowCircle then snowCircle:Destroy() end

    snowCircle = Drawing.new("Circle")
    snowCircle.Color = ESP_COLOR
    snowCircle.Thickness = 2
    snowCircle.Filled = false
    snowCircle.Radius = FOV_RADIUS
    snowCircle.Visible = true
end

-- Função para atualizar o FOV a cada frame
RunService.RenderStepped:Connect(function()
    if snowCircle and showFov then
        local mouse = UserInputService:GetMouseLocation()
        snowCircle.Position = Vector2.new(mouse.X, mouse.Y)
        snowCircle.Radius = FOV_RADIUS
        snowCircle.Color = ESP_COLOR
        snowCircle.Visible = true
    elseif snowCircle then
        snowCircle.Visible = false
    end
end)

-- Função para criar ESP
function createESP(player)
    if player == Players.LocalPlayer then return end
    local espBox = Drawing.new("Square")
    espBox.Color = ESP_COLOR
    espBox.Thickness = 2
    espBox.Filled = false
    espObjects[player] = espBox

    RunService.RenderStepped:Connect(function()
        if not showESP or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            espBox.Visible = false
            return
        end

        local hrp = player.Character.HumanoidRootPart
        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            espBox.Size = Vector2.new(50, 50)
            espBox.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 25)
            espBox.Color = ESP_COLOR
            espBox.Visible = true
        else
            espBox.Visible = false
        end
    end)
end

-- Função para remover ESP
function removeESP()
    for _, box in pairs(espObjects) do
        box:Remove()
    end
    espObjects = {}
end

-- Função para criar o menu
function createMenu()
    local menu = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

    local panel = Instance.new("Frame", menu)
    panel.Size = UDim2.new(0, 300, 0, 500)
    panel.Position = UDim2.new(0, 20, 0, 100)
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(0, 260, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão Show FOV
    local fovButton = Instance.new("TextButton", panel)
    fovButton.Size = UDim2.new(0, 260, 0, 40)
    fovButton.Position = UDim2.new(0, 20, 0, 80)
    fovButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fovButton.Text = "Show FOV"
    fovButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovButton.Font = Enum.Font.Gotham
    fovButton.TextSize = 18
    Instance.new("UICorner", fovButton).CornerRadius = UDim.new(0, 8)

    fovButton.MouseButton1Click:Connect(function()
        showFov = not showFov
        if showFov then
            fovButton.Text = "Hide FOV"
            createFOV()
        else
            fovButton.Text = "Show FOV"
            if snowCircle then
                snowCircle.Visible = false
            end
        end
    end)

    -- Botão Show ESP
    local espButton = Instance.new("TextButton", panel)
    espButton.Size = UDim2.new(0, 260, 0, 40)
    espButton.Position = UDim2.new(0, 20, 0, 130)
    espButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    espButton.Text = "Show ESP"
    espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espButton.Font = Enum.Font.Gotham
    espButton.TextSize = 18
    Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 8)

    espButton.MouseButton1Click:Connect(function()
        showESP = not showESP
        if showESP then
            espButton.Text = "Hide ESP"
            for _, player in pairs(Players:GetPlayers()) do
                createESP(player)
            end
            Players.PlayerAdded:Connect(createESP)
        else
            espButton.Text = "Show ESP"
            removeESP()
        end
    end)

    -- FOV Label
    local fovLabel = Instance.new("TextLabel", panel)
    fovLabel.Size = UDim2.new(0, 260, 0, 20)
    fovLabel.Position = UDim2.new(0, 20, 0, 380)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV: " .. FOV_RADIUS
    fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovLabel.Font = Enum.Font.Gotham
    fovLabel.TextSize = 16
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- FOV Slider
    local fovSlider = Instance.new("Frame", panel)
    fovSlider.Size = UDim2.new(0, 260, 0, 20)
    fovSlider.Position = UDim2.new(0, 20, 0, 400)
    fovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", fovSlider).CornerRadius = UDim.new(0, 10)

    local fovFill = Instance.new("Frame", fovSlider)
    fovFill.Size = UDim2.new(FOV_RADIUS/200, 0, 1, 0)
    fovFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Instance.new("UICorner", fovFill).CornerRadius = UDim.new(0, 10)

    fovSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local function updateFOV()
                local mouse = UserInputService:GetMouseLocation()
                local relativeX = math.clamp(mouse.X - fovSlider.AbsolutePosition.X, 0, fovSlider.AbsoluteSize.X)
                local percent = relativeX / fovSlider.AbsoluteSize.X
                FOV_RADIUS = math.clamp(math.floor(percent * 200), 10, 200)
                fovFill.Size = UDim2.new(percent, 0, 1, 0)
                fovLabel.Text = "FOV: " .. FOV_RADIUS
            end

            updateFOV()

            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    updateFOV()
                end
            end)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    moveConn:Disconnect()
                end
            end)
        end
    end)

    -- Cor do ESP/FOV
    local colorLabel = Instance.new("TextLabel", panel)
    colorLabel.Size = UDim2.new(0, 260, 0, 20)
    colorLabel.Position = UDim2.new(0, 20, 0, 420)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Cor do ESP/FOV"
    colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextSize = 16
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left

    local colorPicker = Instance.new("TextButton", panel)
    colorPicker.Size = UDim2.new(0, 260, 0, 30)
    colorPicker.Position = UDim2.new(0, 20, 0, 445)
    colorPicker.BackgroundColor3 = ESP_COLOR
    colorPicker.Text = "Selecionar Cor"
    colorPicker.TextColor3 = Color3.fromRGB(0, 0, 0)
    colorPicker.Font = Enum.Font.Gotham
    colorPicker.TextSize = 16
    Instance.new("UICorner", colorPicker).CornerRadius = UDim.new(0, 8)

    colorPicker.MouseButton1Click:Connect(function()
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
        ESP_COLOR = Color3.fromRGB(r, g, b)
        if snowCircle then
            snowCircle.Color = ESP_COLOR
        end
        for _, box in pairs(espObjects) do
            box.Color = ESP_COLOR
        end
        colorPicker.BackgroundColor3 = ESP_COLOR
    end)
end

-- Criar menu
createMenu()
