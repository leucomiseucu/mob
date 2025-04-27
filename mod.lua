RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, box in pairs(ESP_OBJECTS) do
            box.Visible = false
        end
        return
    end

    -- Remove ESPs de jogadores inválidos
    for player, box in pairs(ESP_OBJECTS) do
        if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("Head") or not player.Character:FindFirstChildWhichIsA("Humanoid") then
            removeESP(player)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local head = character and character:FindFirstChild("Head")
            if character and humanoid and head and humanoid.Health > 0 then
                if not ESP_OBJECTS[player] then
                    createESP(player)
                end
                local pos, visible = camera:WorldToViewportPoint(head.Position)
                local sizeVec = camera:WorldToViewportPoint(head.Position + Vector3.new(2, 3, 0)) - camera:WorldToViewportPoint(head.Position - Vector3.new(2, 3, 0))
                local size = Vector2.new(math.abs(sizeVec.X), math.abs(sizeVec.Y))
                local box = ESP_OBJECTS[player]
                box.Size = size
                box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                box.Color = ESP_COLOR
                box.Visible = visible
            else
                removeESP(player)
            end
        end
    end
end)
