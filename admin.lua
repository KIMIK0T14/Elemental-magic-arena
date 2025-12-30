-- admin.lua - Módulo para funciones de administración

local data = _G.KimikoData
local Texts = data.Texts
local Colors = data.Colors
local adminContent = data.contentFrames.admin
local SUPABASE_URL = "https://tu-proyecto.supabase.co/rest/v1/"  -- Reemplaza
local SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1LXByb3llY3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAwMDAwMDAsImV4cCI6MjAzNTU1NTU1NX0.tu-clave-anon"  -- Reemplaza
local headers = {["apikey"] = SUPABASE_KEY, ["Content-Type"] = "application/json"}

-- Crear UI en adminContent
local adminTitle = Instance.new("TextLabel", adminContent) adminTitle.Size = UDim2.new(1, 0, 0, 30) adminTitle.Position = UDim2.fromOffset(0, 0) adminTitle.Text = Texts.admin adminTitle.TextColor3 = Colors.Text adminTitle.BackgroundTransparency = 1 adminTitle.Font = Enum.Font.GothamBold adminTitle.TextSize = 18

-- Banned users frame
local bannedFrame = Instance.new("Frame", adminContent) bannedFrame.Size = UDim2.new(1, 0, 0, 150) bannedFrame.Position = UDim2.fromOffset(0, 40) bannedFrame.BackgroundColor3 = Colors.Surface Instance.new("UICorner", bannedFrame).CornerRadius = UDim.new(0, 12)
local bannedTitle = Instance.new("TextLabel", bannedFrame) bannedTitle.Size = UDim2.new(1, 0, 0, 25) bannedTitle.Text = Texts.bannedUsers bannedTitle.TextColor3 = Colors.Text bannedTitle.BackgroundTransparency = 1 bannedTitle.Font = Enum.Font.GothamSemibold bannedTitle.TextSize = 14
local bannedListUI = Instance.new("ScrollingFrame", bannedFrame) bannedListUI.Size = UDim2.new(1, 0, 1, -30) bannedListUI.Position = UDim2.fromOffset(0, 30) bannedListUI.BackgroundTransparency = 1 bannedListUI.ScrollBarThickness = 4

-- Ban form
local banFrame = Instance.new("Frame", adminContent) banFrame.Size = UDim2.new(1, 0, 0, 50) banFrame.Position = UDim2.fromOffset(0, 200) banFrame.BackgroundColor3 = Colors.Surface Instance.new("UICorner", banFrame).CornerRadius = UDim.new(0, 12)
local banInput = Instance.new("TextBox", banFrame) banInput.Size = UDim2.new(0.6, 0, 1, 0) banInput.Position = UDim2.fromOffset(10, 10) banInput.PlaceholderText = Texts.enterUserId banInput.TextColor3 = Colors.Text banInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55) Instance.new("UICorner", banInput).CornerRadius = UDim.new(0, 8)
local banButton = Instance.new("TextButton", banFrame) banButton.Size = UDim2.new(0.3, 0, 1, 0) banButton.Position = UDim2.new(0.7, 0, 0, 0) banButton.Text = Texts.banUser banButton.TextColor3 = Colors.Text banButton.BackgroundColor3 = Colors.Danger Instance.new("UICorner", banButton).CornerRadius = UDim.new(0, 8)

-- History frame
local historyFrame = Instance.new("Frame", adminContent) historyFrame.Size = UDim2.new(1, 0, 0, 200) historyFrame.Position = UDim2.fromOffset(0, 260) historyFrame.BackgroundColor3 = Colors.Surface Instance.new("UICorner", historyFrame).CornerRadius = UDim.new(0, 12)
local historyTitle = Instance.new("TextLabel", historyFrame) historyTitle.Size = UDim2.new(1, 0, 0, 25) historyTitle.Text = Texts.usageHistory historyTitle.TextColor3 = Colors.Text historyTitle.BackgroundTransparency = 1 historyTitle.Font = Enum.Font.GothamSemibold historyTitle.TextSize = 14
local searchInput = Instance.new("TextBox", historyFrame) searchInput.Size = UDim2.new(1, 0, 0, 25) searchInput.Position = UDim2.fromOffset(0, 25) searchInput.PlaceholderText = Texts.searchPlayer searchInput.TextColor3 = Colors.Text searchInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55) Instance.new("UICorner", searchInput).CornerRadius = UDim.new(0, 8)
local historyListUI = Instance.new("ScrollingFrame", historyFrame) historyListUI.Size = UDim2.new(1, 0, 1, -50) historyListUI.Position = UDim2.fromOffset(0, 50) historyListUI.BackgroundTransparency = 1 historyListUI.ScrollBarThickness = 4

-- Current users frame
local currentFrame = Instance.new("Frame", adminContent) currentFrame.Size = UDim2.new(1, 0, 0, 150) currentFrame.Position = UDim2.fromOffset(0, 470) currentFrame.BackgroundColor3 = Colors.Surface Instance.new("UICorner", currentFrame).CornerRadius = UDim.new(0, 12)
local currentTitle = Instance.new("TextLabel", currentFrame) currentTitle.Size = UDim2.new(1, 0, 0, 25) currentTitle.Text = Texts.currentUsers currentTitle.TextColor3 = Colors.Text currentTitle.BackgroundTransparency = 1 currentTitle.Font = Enum.Font.GothamSemibold currentTitle.TextSize = 14
local currentListUI = Instance.new("ScrollingFrame", currentFrame) currentListUI.Size = UDim2.new(1, 0, 1, -30) currentListUI.Position = UDim2.fromOffset(0, 30) currentListUI.BackgroundTransparency = 1 currentListUI.ScrollBarThickness = 4

-- Función refresh (fetch de Supabase)
local logsData = {}
local function refreshAdminData()
    -- Fetch banned
    bannedListUI:ClearAllChildren()
    local success, response = pcall(function()
        return game.HttpService:GetAsync(SUPABASE_URL .. "banned?select=user_id&order=user_id", false, headers)
    end)
    if success then
        local data = game.HttpService:JSONDecode(response)
        for i, entry in ipairs(data) do
            local label = Instance.new("TextLabel", bannedListUI) label.Size = UDim2.new(1, 0, 0, 20) label.Position = UDim2.fromOffset(0, (i-1)*20) label.Text = Texts.userId .. ": " .. entry.user_id label.TextColor3 = Colors.Danger label.BackgroundTransparency = 1
        end
    end

    -- Fetch logs
    historyListUI:ClearAllChildren()
    currentListUI:ClearAllChildren()
    local success, response = pcall(function()
        return game.HttpService:GetAsync(SUPABASE_URL .. "logs?select=*&order=timestamp.desc&limit=100", false, headers)
    end)
    if success then
        logsData = game.HttpService:JSONDecode(response)
        local now = os.time()
        local currentUsers = {}
        for i, entry in ipairs(logsData) do
            local timeStr = os.date("%Y-%m-%d %H:%M:%S", entry.timestamp)
            local label = Instance.new("TextLabel", historyListUI) label.Size = UDim2.new(1, 0, 0, 20) label.Position = UDim2.fromOffset(0, (i-1)*20) label.Text = Texts.username .. ": " .. entry.username .. " | " .. Texts.server .. ": " .. entry.job_id:sub(1,8) .. " | " .. Texts.time .. ": " .. timeStr label.TextColor3 = Colors.TextSecondary label.BackgroundTransparency = 1
            label.Name = "Log_" .. i

            -- Current if <5 min
            if now - entry.timestamp < 300 then
                local currLabel = label:Clone()
                currLabel.Parent = currentListUI
                currLabel.Position = UDim2.fromOffset(0, (#currentUsers)*20)
                table.insert(currentUsers, entry)
            end
        end
    else
        local errLabel = Instance.new("TextLabel", historyListUI) errLabel.Text = Texts.errorFetch errLabel.TextColor3 = Colors.Danger
    end
end

-- Ban button
banButton.MouseButton1Click:Connect(function()
    local userId = tonumber(banInput.Text)
    if userId then
        local banData = {{user_id = userId}}
        local success, err = pcall(function()
            game.HttpService:PostAsync(SUPABASE_URL .. "banned", game.HttpService:JSONEncode(banData), Enum.HttpContentType.ApplicationJson, false, {["apikey"] = SUPABASE_KEY, ["Prefer"] = "return=minimal"})
        end)
        if success then
            banInput.Text = Texts.bannedSuccess
            task.wait(1)
            refreshAdminData()
        else
            warn("Error banning: " .. err)
        end
    end
end)

-- Buscador
searchInput.FocusLost:Connect(function()
    local search = searchInput.Text:lower()
    for _, child in ipairs(historyListUI:GetChildren()) do
        if child:IsA("TextLabel") then
            child.Visible = (search == "" or child.Text:lower():find(search))
        end
    end
end)

-- Refresh al abrir admin
adminContent:GetPropertyChangedSignal("Visible"):Connect(function()
    if adminContent.Visible then refreshAdminData() end
end)

-- Inicial refresh
refreshAdminData()

return {}  -- Retorna vacío, ya que es módulo
