-- Dependências
local UserInputService = game:GetService("UserInputService")

-- Variáveis Globais
local ESP_COLOR = Color3.fromRGB(255, 0, 0)
local FOV_RADIUS = 50
local snowCircle = nil

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
        colorPicker.BackgroundColor3 = ESP_COLOR
    end)
end

-- Criar menu
createMenu()
