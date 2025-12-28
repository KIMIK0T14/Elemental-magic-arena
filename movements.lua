-- KIMIKO BETA - Módulo de Movimiento
-- Funciones: Speed, Infinite Jump, Noclip, Fly
local Data = _G.KimikoData
local Players = Data.Players
local UIS = Data.UIS
local TweenService = Data.TweenService
local RunService = Data.RunService
local Texts = Data.Texts
local Colors = Data.Colors

local Module = {}

-- Variables locales del módulo
local customSpeedEnabled = false
local tpwalking, nowe, speeds = false, false, 1
local bg, bv = nil, nil

-- Referencias
local LocalPlayer = Data.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES DE MOVIMIENTO
-- ═══════════════════════════════════════════════════════════════
local function ToggleSpeed(v) 
    if v <= 0 then 
        customSpeedEnabled = false 
        Data.FeatureValues["Speed"] = 0 
        Data.EnabledFeatures["Speed"] = false 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.WalkSpeed = Data.defaultWalkSpeed 
        end 
    else 
        customSpeedEnabled = true 
        Data.FeatureValues["Speed"] = v 
        Data.EnabledFeatures["Speed"] = true 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end 
    end 
end

local function InfiniteJump(e) 
    Data.EnabledFeatures["InfiniteJump"] = e 
    if Data.connections["InfiniteJump"] then 
        Data.connections["InfiniteJump"]:Disconnect() 
        Data.connections["InfiniteJump"] = nil 
    end 
    if e then 
        Data.connections["InfiniteJump"] = UIS.JumpRequest:Connect(function() 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end) 
    end 
end

local function Noclip(e) 
    Data.EnabledFeatures["Noclip"] = e 
    if Data.connections["Noclip"] then 
        Data.connections["Noclip"]:Disconnect() 
        Data.connections["Noclip"] = nil 
    end 
    if e then 
        Data.connections["Noclip"] = RunService.Stepped:Connect(function() 
            if LocalPlayer.Character then 
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") and p.CanCollide then 
                        p.CanCollide = false 
                    end 
                end 
            end 
        end) 
    else 
        if LocalPlayer.Character then 
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
                    p.CanCollide = true 
                end 
            end 
        end 
    end 
end

local function startFly()
    local char = Data.char
    local hrp = Data.hrp
    local hum = Data.hum
    
    if not char or not hrp or nowe then return end
    nowe = true
    
    for i = 1, speeds do 
        spawn(function() 
            local hb = RunService.Heartbeat 
            tpwalking = true 
            local chr, humm = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") 
            while tpwalking and hb:Wait() and chr and humm and humm.Parent do 
                if humm.MoveDirection.Magnitude > 0 then 
                    chr:TranslateBy(humm.MoveDirection) 
                end 
            end 
        end) 
    end
    
    pcall(function() char.Animate.Disabled = true end)
    pcall(function() for _, v in next, hum:GetPlayingAnimationTracks() do v:AdjustSpeed(0) end end)
    
    for _, s in pairs({Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming}) do 
        hum:SetStateEnabled(s, false) 
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    
    local torso = char:FindFirstChild(hum.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")
    if torso then
        local ctrl, lastctrl, maxspeed, speed = {f = 0, b = 0, l = 0, r = 0}, {f = 0, b = 0, l = 0, r = 0}, 50, 0
        bg = Instance.new("BodyGyro", torso) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = torso.CFrame
        bv = Instance.new("BodyVelocity", torso) bv.velocity = Vector3.new(0, 0.1, 0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        hum.PlatformStand = true
        
        local fib = UIS.InputBegan:Connect(function(i) 
            if i.KeyCode == Enum.KeyCode.W then ctrl.f = 1 
            elseif i.KeyCode == Enum.KeyCode.S then ctrl.b = -1 
            elseif i.KeyCode == Enum.KeyCode.A then ctrl.l = -1 
            elseif i.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end 
        end)
        local fie = UIS.InputEnded:Connect(function(i) 
            if i.KeyCode == Enum.KeyCode.W then ctrl.f = 0 
            elseif i.KeyCode == Enum.KeyCode.S then ctrl.b = 0 
            elseif i.KeyCode == Enum.KeyCode.A then ctrl.l = 0 
            elseif i.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end 
        end)
        
        while nowe and hum and hum.Parent and hum.Health > 0 do
            RunService.RenderStepped:Wait()
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
                speed = speed + 0.5 + (speed / maxspeed) 
                if speed > maxspeed then speed = maxspeed end 
            elseif speed ~= 0 then 
                speed = speed - 1 
                if speed < 0 then speed = 0 end 
            end
            
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
                bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed 
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
                bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
            else 
                bv.velocity = Vector3.new(0, 0, 0) 
            end
            bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
        end
        
        fib:Disconnect() fie:Disconnect()
        if bg then bg:Destroy() bg = nil end 
        if bv then bv:Destroy() bv = nil end
        if hum and hum.Parent then hum.PlatformStand = false end
        pcall(function() char.Animate.Disabled = false end)
        tpwalking = false
    end
end

local function stopFly()
    local char = Data.char
    local hum = Data.hum
    
    nowe = false tpwalking = false
    if bg then bg:Destroy() bg = nil end 
    if bv then bv:Destroy() bv = nil end
    if hum and hum.Parent then
        hum.PlatformStand = false
        for _, s in pairs({Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming}) do 
            hum:SetStateEnabled(s, true) 
        end
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
    pcall(function() if char then char.Animate.Disabled = false end end)
end

local function updateFlySpeed(n) 
    speeds = n 
    if nowe then 
        tpwalking = false 
        task.wait(0.1) 
        for i = 1, speeds do 
            spawn(function() 
                local hb = RunService.Heartbeat 
                tpwalking = true 
                local chr, humm = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") 
                while tpwalking and hb:Wait() and chr and humm and humm.Parent do 
                    if humm.MoveDirection.Magnitude > 0 then 
                        chr:TranslateBy(humm.MoveDirection) 
                    end 
                end 
            end) 
        end 
    end 
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZACIÓN DEL MÓDULO
-- ═══════════════════════════════════════════════════════════════
function Module.init(contentFrame)
    local createSlider = Data.createSlider
    local createToggle = Data.createToggle
    local setupSlider = Data.setupSlider
    local setupToggle = Data.setupToggle
    
    -- Crear UI
    local velocidadSlider = createSlider(contentFrame, Texts.speed, 0, 0, 200, UDim2.fromOffset(10, 15), Colors.Primary, true, Texts.defaultSpeed)
    local infiniteJumpToggle = createToggle(contentFrame, Texts.infiniteJump, UDim2.fromOffset(10, 90), Data.EnabledFeatures["InfiniteJump"], Colors.Primary)
    local noclipToggle = createToggle(contentFrame, Texts.noclip, UDim2.fromOffset(10, 140), Data.EnabledFeatures["Noclip"], Colors.Primary)
    local flyToggle = createToggle(contentFrame, Texts.fly, UDim2.fromOffset(10, 190), Data.EnabledFeatures["Fly"], Colors.Accent)
    local flySpeedSlider = createSlider(contentFrame, Texts.flySpeed, 1, 1, 10, UDim2.fromOffset(10, 240), Colors.Accent, false)
    
    -- Configurar eventos
    setupSlider(velocidadSlider, function(val, pct) 
        if val <= 5 then 
            velocidadSlider.label.Text = Texts.speed .. ": " .. Texts.defaultSpeed 
            ToggleSpeed(0) 
        else 
            velocidadSlider.label.Text = Texts.speed .. ": " .. tostring(math.floor(val)) .. "x" 
            ToggleSpeed(val) 
        end 
    end)
    
    setupSlider(flySpeedSlider, function(val, pct) 
        local v = math.floor(val) 
        if v < 1 then v = 1 end 
        flySpeedSlider.label.Text = Texts.flySpeed .. ": " .. tostring(v) .. "x" 
        Data.FeatureValues["FlySpeed"] = v 
        updateFlySpeed(v) 
    end)
    
    setupToggle(infiniteJumpToggle, "InfiniteJump", Colors.Primary, InfiniteJump)
    setupToggle(noclipToggle, "Noclip", Colors.Primary, Noclip)
    setupToggle(flyToggle, "Fly", Colors.Accent, function(e) 
        if e then task.spawn(startFly) else stopFly() end 
    end)
    
    print("[KIMIKO] Módulo Movement inicializado")
end

-- Manejar respawn del personaje
function Module.onRespawn()
    task.wait(0.5)
    if customSpeedEnabled and Data.FeatureValues["Speed"] > 0 then 
        pcall(function() Data.hum.WalkSpeed = Data.FeatureValues["Speed"] end) 
    end
    if Data.EnabledFeatures["Noclip"] then Noclip(true) end
    if Data.EnabledFeatures["Fly"] then 
        nowe = false tpwalking = false 
        task.wait(0.3) 
        startFly() 
    end
end

return Module
