-- KIMIKO BETA - Modulo de Combate
-- combat.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local TweenService = Data.TweenService
local Colors = Data.Colors
local Texts = Data.Texts
local EnabledFeatures = Data.EnabledFeatures
local Workspace = game:GetService("Workspace")

local parent = Data.contentFrames.combat
if not parent then return end

-- Estados
local AUTO_CHAOS = false
local AUTO_FIRE_Q = false
local AUTO_FIRE_X = false
-- Nuevos estados para Dark Chains
local AUTO_DARK_CHAINS = false
local DARK_CHAINS_AUTO_TP = false

local ATTACK_RANGE = 150
local lastFireQTarget = nil
local lastFireXTarget = nil

local CHAOS_INTERVAL = 0.5
local FIRE_Q_INTERVAL = 0.4
local FIRE_X_INTERVAL = 0.5
-- Intervalo para Dark Chains
local DARK_CHAINS_INTERVAL = 0.3

-- Variables locales para evitar problemas con obfuscador
local stringFind = string.find
local stringLower = string.lower

-- Helper para crear toggles
local function createToggle(parentFrame, label, pos, active, color)
    local c = Instance.new("Frame", parentFrame) c.Size = UDim2.new(1, -20, 0, 40) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, -65, 1, 0) l.Text = label l.TextColor3 = Colors.Text l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("TextButton", c) sw.Size = UDim2.fromOffset(55, 28) sw.Position = UDim2.new(1, -60, 0.5, -14) sw.Text = "" sw.BackgroundColor3 = active and color or Color3.fromRGB(40, 40, 55) sw.BorderSizePixel = 0 Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame", sw) kn.Size = UDim2.fromOffset(22, 22) kn.Position = UDim2.fromOffset(active and 30 or 3, 3) kn.BackgroundColor3 = Colors.Text kn.BorderSizePixel = 0 Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    return {container = c, label = l, switch = sw, knob = kn}
end

-- Titulo de seccion
local combatTitle = Instance.new("TextLabel", parent)
combatTitle.Size = UDim2.new(1, -20, 0, 25)
combatTitle.Position = UDim2.fromOffset(10, 10)
combatTitle.Text = Data.isSpanish and "HABILIDADES DE COMBATE" or "COMBAT SKILLS"
combatTitle.TextColor3 = Colors.Text
combatTitle.BackgroundTransparency = 1
combatTitle.Font = Enum.Font.GothamBold
combatTitle.TextSize = 13
combatTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Crear toggles
local chaosToggle = createToggle(parent, Texts.chaosSkill, UDim2.fromOffset(10, 45), AUTO_CHAOS, Colors.Combat)
local fireQToggle = createToggle(parent, Texts.fireSwordQ, UDim2.fromOffset(10, 95), AUTO_FIRE_Q, Colors.Combat)
local fireXToggle = createToggle(parent, Texts.fireSwordX, UDim2.fromOffset(10, 145), AUTO_FIRE_X, Colors.Combat)

-- Toggle para Dark Chains
local darkChainsToggle = createToggle(parent, "Darkness...", UDim2.fromOffset(10, 195), AUTO_DARK_CHAINS, Colors.Combat)

-- Sub-opcion Auto TP (mas pequena, indentada)
local autoTpContainer = Instance.new("Frame", parent)
autoTpContainer.Size = UDim2.new(1, -40, 0, 30)
autoTpContainer.Position = UDim2.fromOffset(30, 240)
autoTpContainer.BackgroundTransparency = 1

local autoTpLabel = Instance.new("TextLabel", autoTpContainer)
autoTpLabel.Size = UDim2.new(1, -55, 1, 0)
autoTpLabel.Text = Data.isSpanish and "└ Auto TP (150 studs)" or "└ Auto TP (150 studs)"
autoTpLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
autoTpLabel.BackgroundTransparency = 1
autoTpLabel.Font = Enum.Font.Gotham
autoTpLabel.TextSize = 12
autoTpLabel.TextXAlignment = Enum.TextXAlignment.Left

local autoTpSwitch = Instance.new("TextButton", autoTpContainer)
autoTpSwitch.Size = UDim2.fromOffset(45, 22)
autoTpSwitch.Position = UDim2.new(1, -50, 0.5, -11)
autoTpSwitch.Text = ""
autoTpSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
autoTpSwitch.BorderSizePixel = 0
Instance.new("UICorner", autoTpSwitch).CornerRadius = UDim.new(1, 0)

local autoTpKnob = Instance.new("Frame", autoTpSwitch)
autoTpKnob.Size = UDim2.fromOffset(16, 16)
autoTpKnob.Position = UDim2.fromOffset(3, 3)
autoTpKnob.BackgroundColor3 = Colors.Text
autoTpKnob.BorderSizePixel = 0
Instance.new("UICorner", autoTpKnob).CornerRadius = UDim.new(1, 0)

-- Funciones de utilidad
local function getNearestPlayer()
    local hrp = Data.hrp
    if not hrp then return nil end
    
    local nearest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local dist = (targetHrp.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = plr
                end
            end
        end
    end
    return nearest
end

local function getNearbyAlivePlayer()
    local hrp = Data.hrp
    if not hrp then return nil end
    
    local best, range = nil, ATTACK_RANGE
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local targetHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and targetHrp and hum.Health > 0 then
                local dist = (targetHrp.Position - hrp.Position).Magnitude
                if dist <= range then
                    range = dist
                    best = plr
                end
            end
        end
    end
    return best
end

-- Funcion helper para buscar objetos de forma segura (resistente a obfuscador)
local function findChildByPattern(parent, pattern)
    if not parent then return nil end
    local patternLower = stringLower(pattern)
    for _, child in ipairs(parent:GetChildren()) do
        local nameLower = stringLower(child.Name)
        if stringFind(nameLower, patternLower) then
            return child
        end
    end
    return nil
end

-- Busqueda recursiva segura
local function findDescendantByPattern(parent, pattern)
    if not parent then return nil end
    local patternLower = stringLower(pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        local nameLower = stringLower(desc.Name)
        if stringFind(nameLower, patternLower) then
            return desc
        end
    end
    return nil
end

-- Toggle connections
chaosToggle.switch.MouseButton1Click:Connect(function()
    AUTO_CHAOS = not AUTO_CHAOS
    EnabledFeatures["AutoChaos"] = AUTO_CHAOS
    if AUTO_CHAOS then
        chaosToggle.switch.BackgroundColor3 = Colors.Combat
        TweenService:Create(chaosToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play()
    else
        chaosToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TweenService:Create(chaosToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
    end
end)

fireQToggle.switch.MouseButton1Click:Connect(function()
    AUTO_FIRE_Q = not AUTO_FIRE_Q
    EnabledFeatures["AutoFireQ"] = AUTO_FIRE_Q
    if AUTO_FIRE_Q then
        fireQToggle.switch.BackgroundColor3 = Colors.Combat
        TweenService:Create(fireQToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play()
    else
        fireQToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TweenService:Create(fireQToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
    end
end)

fireXToggle.switch.MouseButton1Click:Connect(function()
    AUTO_FIRE_X = not AUTO_FIRE_X
    EnabledFeatures["AutoFireX"] = AUTO_FIRE_X
    if AUTO_FIRE_X then
        fireXToggle.switch.BackgroundColor3 = Colors.Combat
        TweenService:Create(fireXToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play()
    else
        fireXToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TweenService:Create(fireXToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
    end
end)

-- Toggle connection para Dark Chains
darkChainsToggle.switch.MouseButton1Click:Connect(function()
    AUTO_DARK_CHAINS = not AUTO_DARK_CHAINS
    EnabledFeatures["AutoDarkChains"] = AUTO_DARK_CHAINS
    if AUTO_DARK_CHAINS then
        darkChainsToggle.switch.BackgroundColor3 = Colors.Combat
        TweenService:Create(darkChainsToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play()
    else
        darkChainsToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TweenService:Create(darkChainsToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
    end
end)

-- Toggle connection para Auto TP
autoTpSwitch.MouseButton1Click:Connect(function()
    DARK_CHAINS_AUTO_TP = not DARK_CHAINS_AUTO_TP
    EnabledFeatures["DarkChainsAutoTP"] = DARK_CHAINS_AUTO_TP
    if DARK_CHAINS_AUTO_TP then
        autoTpSwitch.BackgroundColor3 = Colors.Combat
        TweenService:Create(autoTpKnob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(26, 3)}):Play()
    else
        autoTpSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TweenService:Create(autoTpKnob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play()
    end
end)

-- CHAOS AUTO ATTACK optimizado con task.defer y mayor intervalo
task.defer(function()
    while true do
        task.wait(CHAOS_INTERVAL)
        
        if AUTO_CHAOS then
            local char = Data.char
            if char then
                -- Buscar dragon de forma segura
                local dragon = findDescendantByPattern(char, "chaotic")
                if dragon then
                    local event = findChildByPattern(dragon, "event")
                    if not event then
                        event = findDescendantByPattern(dragon, "event")
                    end
                    
                    local target = getNearestPlayer()
                    if event and target and target.Character then
                        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if targetHrp then
                            pcall(function()
                                event:FireServer("FIRE_ATTACK", targetHrp.Position)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- FIRE SKILL Q optimizado
task.defer(function()
    while true do
        task.wait(FIRE_Q_INTERVAL)
        
        if AUTO_FIRE_Q then
            local char = Data.char
            local hrp = Data.hrp
            if char and hrp then
                -- Buscar espada de forma segura
                local sword = findChildByPattern(char, "fire")
                if not sword then
                    sword = findDescendantByPattern(char, "greatsword")
                end
                
                if sword then
                    local qevent = findChildByPattern(sword, "qevent")
                    if not qevent then
                        qevent = findChildByPattern(sword, "q")
                    end
                    
                    if qevent then
                        local target = getNearbyAlivePlayer()
                        if target and target ~= lastFireQTarget then
                            local tChar = target.Character
                            if tChar then
                                local hum = tChar:FindFirstChildOfClass("Humanoid")
                                local tHRP = tChar:FindFirstChild("HumanoidRootPart")
                                
                                if hum and tHRP and hum.Health > 0 then
                                    lastFireQTarget = target
                                    local savedCF = hrp.CFrame
                                    
                                    for i = 1, 4 do
                                        if AUTO_FIRE_Q and hum.Health > 0 then
                                            pcall(function() qevent:FireServer() end)
                                            task.wait(0.15)
                                        end
                                    end
                                    
                                    local followTime = tick() + 0.5
                                    while tick() < followTime do
                                        if not AUTO_FIRE_Q or hum.Health <= 0 then break end
                                        pcall(function() hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -2) end)
                                        task.wait(0.1)
                                    end
                                    
                                    task.wait(5)
                                    if hrp then pcall(function() hrp.CFrame = savedCF end) end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- FIRE SKILL X optimizado
task.defer(function()
    while true do
        task.wait(FIRE_X_INTERVAL)
        
        if AUTO_FIRE_X then
            local char = Data.char
            local hrp = Data.hrp
            if char and hrp then
                -- Buscar espada de forma segura
                local sword = findChildByPattern(char, "fire")
                if not sword then
                    sword = findDescendantByPattern(char, "greatsword")
                end
                
                if sword then
                    local xevent = findChildByPattern(sword, "xevent")
                    if not xevent then
                        xevent = findChildByPattern(sword, "x")
                    end
                    
                    if xevent then
                        local target = getNearestPlayer()
                        if target and target ~= lastFireXTarget then
                            local tChar = target.Character
                            if tChar then
                                local tHRP = tChar:FindFirstChild("HumanoidRootPart")
                                if tHRP then
                                    lastFireXTarget = target
                                    pcall(function() hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -5) end)
                                    task.wait(0.2)
                                    
                                    for i = 1, 4 do
                                        if AUTO_FIRE_X then
                                            pcall(function() xevent:FireServer(tHRP.Position) end)
                                            task.wait(0.15)
                                        end
                                    end
                                    
                                    task.wait(8)
                                    lastFireXTarget = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- DARK CHAINS AUTO ATTACK con Auto TP
task.defer(function()
    while true do
        task.wait(DARK_CHAINS_INTERVAL)
        
        if AUTO_DARK_CHAINS then
            local playerName = LocalPlayer.Name
            local hrp = Data.hrp
            
            -- Buscar el Dark Chains del jugador en Workspace
            local playerFolder = Workspace:FindFirstChild(playerName)
            if playerFolder then
                local darkChains = findChildByPattern(playerFolder, "dark")
                if not darkChains then
                    darkChains = findDescendantByPattern(playerFolder, "chain")
                end
                
                if darkChains then
                    local remoteEvent = darkChains:FindFirstChildOfClass("RemoteEvent")
                    if not remoteEvent then
                        remoteEvent = findChildByPattern(darkChains, "event")
                    end
                    if not remoteEvent then
                        remoteEvent = findDescendantByPattern(darkChains, "remote")
                    end
                    
                    if remoteEvent then
                        -- Auto TP si esta activado
                        if DARK_CHAINS_AUTO_TP and hrp then
                            local target = getNearbyAlivePlayer()
                            if target and target.Character then
                                local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                                if targetHrp then
                                    pcall(function()
                                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -3)
                                    end)
                                end
                            end
                        end
                        
                        -- Disparar el evento infinitamente
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                end
            end
        end
    end
end)

return {
    getNearestPlayer = getNearestPlayer,
    getNearbyAlivePlayer = getNearbyAlivePlayer
}
