-- KIMIKO BETA - Modulo ESP
-- esp.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local TweenService = Data.TweenService
local RunService = Data.RunService
local Colors = Data.Colors
local Texts = Data.Texts
local EnabledFeatures = Data.EnabledFeatures

local parent = Data.contentFrames.esp
if not parent then return end

-- Variables
local espObjects = {}
local espColor = Colors.ESP

-- Funcion para obtener los diamantes de un jugador desde su leaderstats
local function getPlayerDiamonds(player)
    local diamonds = 0
    pcall(function()
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local diamondsStat = leaderstats:FindFirstChild("Diamonds") or leaderstats:FindFirstChild("diamonds") or leaderstats:FindFirstChild("💎")
            if diamondsStat then
                diamonds = tonumber(diamondsStat.Value) or 0
            end
        end
    end)
    return diamonds
end

-- Mejorada validacion para evitar jugadores "fantasma"
local function isValidPlayer(player)
    if not player or not player.Parent or player == LocalPlayer then return false end
    local character = player.Character
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not humanoid or not rootPart or not head then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

-- ESP Functions
local function removeESPForPlayer(player)
    local d = espObjects[player]
    if not d then return end
    if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
    if d.highlight and d.highlight.Parent then d.highlight:Destroy() end
    if d.tracer and d.tracer.Parent then d.tracer:Destroy() end
    if d.conn then d.conn:Disconnect() end
    espObjects[player] = nil
end

local function createESPForPlayer(player)
    -- Usar la nueva validacion mejorada
    if not isValidPlayer(player) or espObjects[player] then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    local bb = Instance.new("BillboardGui") bb.Name = "KimikoESP" bb.Adornee = head bb.Size = UDim2.new(0, 200, 0, 120) bb.StudsOffset = Vector3.new(0, 2.5, 0) bb.AlwaysOnTop = true bb.LightInfluence = 0 bb.MaxDistance = 1000 bb.Parent = character
    local fr = Instance.new("Frame", bb) fr.Size = UDim2.new(1, 0, 1, 0) fr.BackgroundTransparency = 1
    local nm = Instance.new("TextLabel", fr) nm.Size = UDim2.new(1, 0, 0, 20) nm.BackgroundTransparency = 1 nm.Text = player.DisplayName nm.TextColor3 = espColor nm.TextStrokeColor3 = Color3.new(0, 0, 0) nm.TextStrokeTransparency = 0.3 nm.Font = Enum.Font.GothamBold nm.TextSize = 14
    local un = Instance.new("TextLabel", fr) un.Size = UDim2.new(1, 0, 0, 14) un.Position = UDim2.fromOffset(0, 18) un.BackgroundTransparency = 1 un.Text = "@" .. player.Name un.TextColor3 = Colors.TextSecondary un.TextStrokeColor3 = Color3.new(0, 0, 0) un.TextStrokeTransparency = 0.3 un.Font = Enum.Font.Gotham un.TextSize = 10
    local hbg = Instance.new("Frame", fr) hbg.Size = UDim2.new(0.8, 0, 0, 6) hbg.Position = UDim2.new(0.1, 0, 0, 38) hbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40) hbg.BorderSizePixel = 0 Instance.new("UICorner", hbg).CornerRadius = UDim.new(1, 0)
    local hbf = Instance.new("Frame", hbg) hbf.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0) hbf.BackgroundColor3 = Color3.fromRGB(0, 255, 0) hbf.BorderSizePixel = 0 Instance.new("UICorner", hbf).CornerRadius = UDim.new(1, 0)
    local hl = Instance.new("TextLabel", fr) hl.Size = UDim2.new(1, 0, 0, 14) hl.Position = UDim2.fromOffset(0, 46) hl.BackgroundTransparency = 1 hl.Text = Texts.health .. ": " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) hl.TextColor3 = Colors.Text hl.TextStrokeColor3 = Color3.new(0, 0, 0) hl.TextStrokeTransparency = 0.3 hl.Font = Enum.Font.Gotham hl.TextSize = 11
    local dl = Instance.new("TextLabel", fr) dl.Size = UDim2.new(1, 0, 0, 14) dl.Position = UDim2.fromOffset(0, 62) dl.BackgroundTransparency = 1 dl.Text = Texts.dist .. ": 0 " .. Texts.studs dl.TextColor3 = Colors.TextSecondary dl.TextStrokeColor3 = Color3.new(0, 0, 0) dl.TextStrokeTransparency = 0.3 dl.Font = Enum.Font.Gotham dl.TextSize = 11
    
    local diamLabel = Instance.new("TextLabel", fr) diamLabel.Name = "DiamondsLabel" diamLabel.Size = UDim2.new(1, 0, 0, 14) diamLabel.Position = UDim2.fromOffset(0, 78) diamLabel.BackgroundTransparency = 1 diamLabel.Text = "💎 " .. getPlayerDiamonds(player) diamLabel.TextColor3 = Colors.Diamond diamLabel.TextStrokeColor3 = Color3.new(0, 0, 0) diamLabel.TextStrokeTransparency = 0.3 diamLabel.Font = Enum.Font.GothamBold diamLabel.TextSize = 12
    
    local hi = Instance.new("Highlight") hi.Name = "KimikoHighlight" hi.Adornee = character hi.FillColor = espColor hi.OutlineColor = espColor hi.FillTransparency = 0.7 hi.OutlineTransparency = 0 hi.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hi.Parent = character
    local tr = Instance.new("Part") tr.Name = "KimikoTracer" tr.Anchored = true tr.CanCollide = false tr.Transparency = 0.5 tr.Material = Enum.Material.Neon tr.Color = espColor tr.Parent = workspace
    
    local hrp = Data.hrp
    local conn conn = RunService.Heartbeat:Connect(function()
        -- Mejorada verificacion para limpiar ESP de jugadores muertos o invalidos
        if not player or not player.Parent then conn:Disconnect() removeESPForPlayer(player) return end
        local char = player.Character
        if not char or not char.Parent then conn:Disconnect() removeESPForPlayer(player) return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local rp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not rp or hum.Health <= 0 then conn:Disconnect() removeESPForPlayer(player) return end
        
        if EnabledFeatures["ShowHealth"] then
            hl.Text = Texts.health .. ": " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. " (" .. math.floor((hum.Health / hum.MaxHealth) * 100) .. "%)"
            hbf.Size = UDim2.new(math.max(0, hum.Health / hum.MaxHealth), 0, 1, 0)
            local p = hum.Health / hum.MaxHealth
            hbf.BackgroundColor3 = p > 0.5 and Color3.fromRGB(0, 255, 0) or p > 0.25 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
        -- Usar la variable rp en lugar de rootPart y verificar que Data.hrp existe
        local myHrp = Data.hrp
        if EnabledFeatures["ShowDistance"] and rp and myHrp then dl.Text = Texts.dist .. ": " .. math.floor((rp.Position - myHrp.Position).Magnitude) .. " " .. Texts.studs end
        if EnabledFeatures["ShowTracers"] and rp and myHrp then 
            local d = (rp.Position - myHrp.Position).Magnitude 
            tr.Size = Vector3.new(0.2, 0.2, d) 
            tr.CFrame = CFrame.new((myHrp.Position + rp.Position) / 2, rp.Position) 
            tr.Parent = workspace 
        else 
            tr.Parent = nil 
        end
        if EnabledFeatures["ShowDiamonds"] then
            diamLabel.Text = "💎 " .. getPlayerDiamonds(player)
            diamLabel.Visible = true
        else
            diamLabel.Visible = false
        end
        nm.Visible = EnabledFeatures["ShowName"] un.Visible = EnabledFeatures["ShowName"] hl.Visible = EnabledFeatures["ShowHealth"] hbg.Visible = EnabledFeatures["ShowHealth"] dl.Visible = EnabledFeatures["ShowDistance"] hi.Enabled = EnabledFeatures["ShowBox"]
    end)
    espObjects[player] = {billboard = bb, highlight = hi, tracer = tr, conn = conn}
end

local function enableAllESP() 
    for _, p in pairs(Players:GetPlayers()) do 
        if isValidPlayer(p) then 
            createESPForPlayer(p) 
        end 
    end 
end
local function disableAllESP() for p, _ in pairs(espObjects) do removeESPForPlayer(p) end espObjects = {} end

-- ESP connections
local function setupESPConnections()
    Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                if EnabledFeatures["AyaESP"] then
                    task.wait(0.5)
                    removeESPForPlayer(p)
                    if isValidPlayer(p) then createESPForPlayer(p) end
                end
            end)
            if EnabledFeatures["AyaESP"] then
                task.wait(1)
                if isValidPlayer(p) then createESPForPlayer(p) end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(p) removeESPForPlayer(p) end)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                if EnabledFeatures["AyaESP"] then
                    task.wait(0.5)
                    removeESPForPlayer(p)
                    if isValidPlayer(p) then createESPForPlayer(p) end
                end
            end)
        end
    end
end
setupESPConnections()

-- UI Helpers
local function createToggle(parentFrame, label, pos, active, color)
    local c = Instance.new("Frame", parentFrame) c.Size = UDim2.new(1, -20, 0, 40) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, -65, 1, 0) l.Text = label l.TextColor3 = Colors.Text l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("TextButton", c) sw.Size = UDim2.fromOffset(55, 28) sw.Position = UDim2.new(1, -60, 0.5, -14) sw.Text = "" sw.BackgroundColor3 = active and color or Color3.fromRGB(40, 40, 55) sw.BorderSizePixel = 0 Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame", sw) kn.Size = UDim2.fromOffset(22, 22) kn.Position = UDim2.fromOffset(active and 30 or 3, 3) kn.BackgroundColor3 = Colors.Text kn.BorderSizePixel = 0 Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    return {container = c, label = l, switch = sw, knob = kn}
end

local function setupToggle(toggle, feature, color, callback) 
    toggle.switch.MouseButton1Click:Connect(function() 
        EnabledFeatures[feature] = not EnabledFeatures[feature] 
        if EnabledFeatures[feature] then 
            toggle.switch.BackgroundColor3 = color 
            TweenService:Create(toggle.knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(30, 3)}):Play() 
        else 
            toggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
            TweenService:Create(toggle.knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(3, 3)}):Play() 
        end 
        if callback then callback(EnabledFeatures[feature]) end 
    end) 
end

-- Funcion para actualizar visualmente un toggle sin disparar su callback
local function updateToggleVisual(toggle, active, color)
    if active then
        toggle.switch.BackgroundColor3 = color
        toggle.knob.Position = UDim2.fromOffset(30, 3)
    else
        toggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        toggle.knob.Position = UDim2.fromOffset(3, 3)
    end
end

-- Crear UI
local ayaEspToggle = createToggle(parent, Texts.ayaEsp, UDim2.fromOffset(10, 15), EnabledFeatures["AyaESP"], Colors.ESP)
local showNameToggle = createToggle(parent, Texts.showName, UDim2.fromOffset(10, 65), EnabledFeatures["ShowName"], Colors.ESP)
local showHealthToggle = createToggle(parent, Texts.showHealth, UDim2.fromOffset(10, 115), EnabledFeatures["ShowHealth"], Colors.ESP)
local showDistanceToggle = createToggle(parent, Texts.showDistance, UDim2.fromOffset(10, 165), EnabledFeatures["ShowDistance"], Colors.ESP)
local showBoxToggle = createToggle(parent, Texts.showBox, UDim2.fromOffset(10, 215), EnabledFeatures["ShowBox"], Colors.ESP)
local showTracersToggle = createToggle(parent, Texts.showTracers, UDim2.fromOffset(10, 265), EnabledFeatures["ShowTracers"], Colors.ESP)
-- Cambiado color de diamantes a verde (Colors.ESP) para que combine con los otros
local showDiamondsToggle = createToggle(parent, Texts.showDiamonds, UDim2.fromOffset(10, 315), EnabledFeatures["ShowDiamonds"], Colors.ESP)

local espPlayerCount = Instance.new("TextLabel", parent) espPlayerCount.Size = UDim2.new(1, -20, 0, 25) espPlayerCount.Position = UDim2.fromOffset(10, 370) espPlayerCount.Text = "0 " .. Texts.espPlayers espPlayerCount.TextColor3 = Colors.ESP espPlayerCount.BackgroundTransparency = 1 espPlayerCount.Font = Enum.Font.GothamBold espPlayerCount.TextSize = 14 espPlayerCount.TextXAlignment = Enum.TextXAlignment.Left

-- ESP Toggle ahora activa todas las sub-opciones automaticamente
ayaEspToggle.switch.MouseButton1Click:Connect(function() 
    EnabledFeatures["AyaESP"] = not EnabledFeatures["AyaESP"] 
    if EnabledFeatures["AyaESP"] then 
        ayaEspToggle.switch.BackgroundColor3 = Colors.ESP 
        TweenService:Create(ayaEspToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play() 
        -- Activar todas las sub-opciones
        EnabledFeatures["ShowName"] = true
        EnabledFeatures["ShowHealth"] = true
        EnabledFeatures["ShowDistance"] = true
        EnabledFeatures["ShowBox"] = true
        EnabledFeatures["ShowTracers"] = true
        EnabledFeatures["ShowDiamonds"] = true
        -- Actualizar visualmente todos los toggles
        updateToggleVisual(showNameToggle, true, Colors.ESP)
        updateToggleVisual(showHealthToggle, true, Colors.ESP)
        updateToggleVisual(showDistanceToggle, true, Colors.ESP)
        updateToggleVisual(showBoxToggle, true, Colors.ESP)
        updateToggleVisual(showTracersToggle, true, Colors.ESP)
        updateToggleVisual(showDiamondsToggle, true, Colors.ESP)
        enableAllESP() 
    else 
        ayaEspToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
        TweenService:Create(ayaEspToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play() 
        disableAllESP() 
    end 
end)

setupToggle(showNameToggle, "ShowName", Colors.ESP)
setupToggle(showHealthToggle, "ShowHealth", Colors.ESP)
setupToggle(showDistanceToggle, "ShowDistance", Colors.ESP)
setupToggle(showBoxToggle, "ShowBox", Colors.ESP)
setupToggle(showTracersToggle, "ShowTracers", Colors.ESP)
-- Cambiado color a Colors.ESP (verde) para consistencia
setupToggle(showDiamondsToggle, "ShowDiamonds", Colors.ESP)

-- Update player count
task.spawn(function() 
    while Data.gui.Parent do 
        local c = 0 
        for _ in pairs(espObjects) do c = c + 1 end 
        espPlayerCount.Text = c .. " " .. Texts.espPlayers 
        task.wait(0.5) 
    end 
end)

return {
    enableAllESP = enableAllESP,
    disableAllESP = disableAllESP,
    createESPForPlayer = createESPForPlayer,
    removeESPForPlayer = removeESPForPlayer
}
