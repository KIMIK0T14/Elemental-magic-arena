-- KIMIKO BETA - Modulo de Combate
-- combat.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local TweenService = Data.TweenService
local Colors = Data.Colors
local Texts = Data.Texts
local EnabledFeatures = Data.EnabledFeatures

local parent = Data.contentFrames.combat
if not parent then return end

-- Estados
local AUTO_CHAOS = false
local AUTO_FIRE_Q = false
local AUTO_FIRE_X = false

local ATTACK_RANGE = 150
local lastFireQTarget = nil
local lastFireXTarget = nil

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

-- Funciones de utilidad
local function getNearestPlayer()
    local hrp = Data.hrp
    if not hrp then return nil end
    
    local nearest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = plr
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

-- CHAOS AUTO ATTACK
task.spawn(function()
    while task.wait(0.35) do
        if not AUTO_CHAOS then continue end
        
        local char = Data.char
        if not char then continue end
        
        local dragon = char:FindFirstChild("Chaotic Dragon", true)
        local event = dragon and dragon:FindFirstChild("Event", true)
        local target = getNearestPlayer()
        
        if event and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                event:FireServer("FIRE_ATTACK", target.Character.HumanoidRootPart.Position)
            end)
        end
    end
end)

-- FIRE SKILL Q
task.spawn(function()
    while task.wait(0.2) do
        if not AUTO_FIRE_Q then continue end
        
        local char = Data.char
        local hrp = Data.hrp
        if not char or not hrp then continue end
        
        local sword = char:FindFirstChild("Fire GreatSword")
        local qevent = sword and sword:FindFirstChild("Qevent")
        if not qevent then continue end
        
        local target = getNearbyAlivePlayer()
        if not target or target == lastFireQTarget then continue end
        
        local tChar = target.Character
        local hum = tChar:FindFirstChildOfClass("Humanoid")
        local tHRP = tChar:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 then continue end
        
        lastFireQTarget = target
        local savedCF = hrp.CFrame
        
        for _ = 1, 4 do
            if not AUTO_FIRE_Q or hum.Health <= 0 then break end
            pcall(function() qevent:FireServer() end)
            task.wait(0.1)
        end
        
        local followTime = tick() + 0.5
        while tick() < followTime and AUTO_FIRE_Q and hum.Health > 0 do
            pcall(function() hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -2) end)
            task.wait(0.05)
        end
        
        task.wait(5)
        if hrp then pcall(function() hrp.CFrame = savedCF end) end
    end
end)

-- FIRE SKILL X
task.spawn(function()
    while task.wait(0.3) do
        if not AUTO_FIRE_X then continue end
        
        local char = Data.char
        local hrp = Data.hrp
        if not char or not hrp then continue end
        
        local sword = char:FindFirstChild("Fire GreatSword")
        local xevent = sword and sword:FindFirstChild("Xevent")
        if not xevent then continue end
        
        local target = getNearestPlayer()
        if not target or target == lastFireXTarget then
            lastFireXTarget = nil
            continue
        end
        
        local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then continue end
        
        lastFireXTarget = target
        pcall(function() hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -5) end)
        task.wait(0.15)
        
        for _ = 1, 4 do
            if not AUTO_FIRE_X then break end
            pcall(function() xevent:FireServer(tHRP.Position) end)
            task.wait(0.1)
        end
        
        task.wait(8)
    end
end)

return {
    getNearestPlayer = getNearestPlayer,
    getNearbyAlivePlayer = getNearbyAlivePlayer
}
