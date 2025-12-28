-- KIMIKO BETA - Modulo de Movimiento
-- movements.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local UIS = Data.UIS
local TweenService = Data.TweenService
local RunService = Data.RunService
local Colors = Data.Colors
local Texts = Data.Texts
local EnabledFeatures = Data.EnabledFeatures
local FeatureValues = Data.FeatureValues
local connections = Data.connections

local parent = Data.contentFrames.movement
if not parent then return end

-- Variables locales
local tpwalking, nowe, speeds, bg, bv = false, false, 1, nil, nil
local customSpeedEnabled = false

-- UI Helpers
local function createSlider(parentFrame, label, val, minV, maxV, pos, color, isDef, defText)
    local c = Instance.new("Frame", parentFrame) c.Size = UDim2.new(1, -20, 0, 65) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, 0, 0, 22) l.BackgroundTransparency = 1 l.Text = label .. ": " .. (isDef and val <= minV and (defText or Texts.defaultSpeed) or tostring(math.floor(val)) .. "x") l.TextColor3 = Colors.Text l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("Frame", c) bg.Size = UDim2.new(1, 0, 0, 30) bg.Position = UDim2.fromOffset(0, 30) bg.BackgroundColor3 = Color3.fromRGB(40, 40, 55) bg.BorderSizePixel = 0 Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local fl = Instance.new("Frame", bg) fl.Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0) fl.BackgroundColor3 = color fl.BorderSizePixel = 0 Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 10)
    local btn = Instance.new("TextButton", bg) btn.Size = UDim2.new(1, 0, 1, 0) btn.Text = "" btn.BackgroundTransparency = 1
    return {container = c, label = l, bg = bg, fill = fl, button = btn, minVal = minV, maxVal = maxV, value = val}
end

local function createToggle(parentFrame, label, pos, active, color)
    local c = Instance.new("Frame", parentFrame) c.Size = UDim2.new(1, -20, 0, 40) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, -65, 1, 0) l.Text = label l.TextColor3 = Colors.Text l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("TextButton", c) sw.Size = UDim2.fromOffset(55, 28) sw.Position = UDim2.new(1, -60, 0.5, -14) sw.Text = "" sw.BackgroundColor3 = active and color or Color3.fromRGB(40, 40, 55) sw.BorderSizePixel = 0 Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame", sw) kn.Size = UDim2.fromOffset(22, 22) kn.Position = UDim2.fromOffset(active and 30 or 3, 3) kn.BackgroundColor3 = Colors.Text kn.BorderSizePixel = 0 Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    return {container = c, label = l, switch = sw, knob = kn}
end

-- Funciones de movimiento
local function startFly()
    local char = Data.char
    local hum = Data.hum
    local hrp = Data.hrp
    if not char or not hrp or nowe then return end
    nowe = true
    for i = 1, speeds do spawn(function() local hb = RunService.Heartbeat tpwalking = true local chr, humm = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") while tpwalking and hb:Wait() and chr and humm and humm.Parent do if humm.MoveDirection.Magnitude > 0 then chr:TranslateBy(humm.MoveDirection) end end end) end
    pcall(function() char.Animate.Disabled = true end)
    pcall(function() for _, v in next, hum:GetPlayingAnimationTracks() do v:AdjustSpeed(0) end end)
    for _, s in pairs({Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming}) do hum:SetStateEnabled(s, false) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    local torso = char:FindFirstChild(hum.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")
    if torso then
        local ctrl, lastctrl, maxspeed, speed = {f = 0, b = 0, l = 0, r = 0}, {f = 0, b = 0, l = 0, r = 0}, 50, 0
        bg = Instance.new("BodyGyro", torso) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = torso.CFrame
        bv = Instance.new("BodyVelocity", torso) bv.velocity = Vector3.new(0, 0.1, 0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        hum.PlatformStand = true
        local fib = UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.W then ctrl.f = 1 elseif i.KeyCode == Enum.KeyCode.S then ctrl.b = -1 elseif i.KeyCode == Enum.KeyCode.A then ctrl.l = -1 elseif i.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end end)
        local fie = UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.W then ctrl.f = 0 elseif i.KeyCode == Enum.KeyCode.S then ctrl.b = 0 elseif i.KeyCode == Enum.KeyCode.A then ctrl.l = 0 elseif i.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end end)
        while nowe and hum and hum.Parent and hum.Health > 0 do
            RunService.RenderStepped:Wait()
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then speed = speed + 0.5 + (speed / maxspeed) if speed > maxspeed then speed = maxspeed end elseif speed ~= 0 then speed = speed - 1 if speed < 0 then speed = 0 end end
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
            else bv.velocity = Vector3.new(0, 0, 0) end
            bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
        end
        fib:Disconnect() fie:Disconnect()
        if bg then bg:Destroy() bg = nil end if bv then bv:Destroy() bv = nil end
        if hum and hum.Parent then hum.PlatformStand = false end
        pcall(function() char.Animate.Disabled = false end)
        tpwalking = false
    end
end

local function stopFly()
    local char = Data.char
    local hum = Data.hum
    nowe = false tpwalking = false
    if bg then bg:Destroy() bg = nil end if bv then bv:Destroy() bv = nil end
    if hum and hum.Parent then
        hum.PlatformStand = false
        for _, s in pairs({Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming}) do hum:SetStateEnabled(s, true) end
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
    pcall(function() if char then char.Animate.Disabled = false end end)
end

local function updateFlySpeed(n) speeds = n if nowe then tpwalking = false task.wait(0.1) for i = 1, speeds do spawn(function() local hb = RunService.Heartbeat tpwalking = true local chr, humm = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") while tpwalking and hb:Wait() and chr and humm and humm.Parent do if humm.MoveDirection.Magnitude > 0 then chr:TranslateBy(humm.MoveDirection) end end end) end end end

local function ToggleSpeed(v) 
    if v <= 0 then 
        customSpeedEnabled = false 
        FeatureValues["Speed"] = 0 
        EnabledFeatures["Speed"] = false 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.WalkSpeed = Data.defaultWalkSpeed 
        end 
    else 
        customSpeedEnabled = true 
        FeatureValues["Speed"] = v 
        EnabledFeatures["Speed"] = true 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end 
    end 
end

local function InfiniteJump(e) 
    EnabledFeatures["InfiniteJump"] = e 
    if connections["InfiniteJump"] then connections["InfiniteJump"]:Disconnect() connections["InfiniteJump"] = nil end 
    if e then 
        connections["InfiniteJump"] = UIS.JumpRequest:Connect(function() 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end) 
    end 
end

local function Noclip(e) 
    EnabledFeatures["Noclip"] = e 
    if connections["Noclip"] then connections["Noclip"]:Disconnect() connections["Noclip"] = nil end 
    if e then 
        connections["Noclip"] = RunService.Stepped:Connect(function() 
            if LocalPlayer.Character then 
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end 
                end 
            end 
        end) 
    else 
        if LocalPlayer.Character then 
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end 
            end 
        end 
    end 
end

-- Crear UI
local velocidadSlider = createSlider(parent, Texts.speed, 0, 0, 200, UDim2.fromOffset(10, 15), Colors.Primary, true, Texts.defaultSpeed)
local infiniteJumpToggle = createToggle(parent, Texts.infiniteJump, UDim2.fromOffset(10, 90), EnabledFeatures["InfiniteJump"], Colors.Primary)
local noclipToggle = createToggle(parent, Texts.noclip, UDim2.fromOffset(10, 140), EnabledFeatures["Noclip"], Colors.Primary)
local flyToggle = createToggle(parent, Texts.fly, UDim2.fromOffset(10, 190), EnabledFeatures["Fly"], Colors.Accent)
local flySpeedSlider = createSlider(parent, Texts.flySpeed, 1, 1, 10, UDim2.fromOffset(10, 240), Colors.Accent, false)

-- Slider setup
local function setupSlider(slider, callback) 
    slider.button.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            local moveConn 
            moveConn = UIS.InputChanged:Connect(function(i2) 
                if i2.UserInputType == Enum.UserInputType.MouseMovement or i2.UserInputType == Enum.UserInputType.Touch then 
                    local pos = i2.Position.X - slider.bg.AbsolutePosition.X 
                    local pct = math.clamp(pos / slider.bg.AbsoluteSize.X, 0, 1) 
                    local val = slider.minVal + (slider.maxVal - slider.minVal) * pct 
                    slider.value = val 
                    slider.fill.Size = UDim2.new(pct, 0, 1, 0) 
                    callback(val, pct) 
                end 
            end) 
            local relConn 
            relConn = UIS.InputEnded:Connect(function(i3) 
                if i3.UserInputType == Enum.UserInputType.MouseButton1 or i3.UserInputType == Enum.UserInputType.Touch then 
                    moveConn:Disconnect() 
                    relConn:Disconnect() 
                end 
            end) 
        end 
    end) 
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
    FeatureValues["FlySpeed"] = v 
    updateFlySpeed(v) 
end)

setupToggle(infiniteJumpToggle, "InfiniteJump", Colors.Primary, InfiniteJump)
setupToggle(noclipToggle, "Noclip", Colors.Primary, Noclip)
setupToggle(flyToggle, "Fly", Colors.Accent, function(e) if e then task.spawn(startFly) else stopFly() end end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if customSpeedEnabled and FeatureValues["Speed"] > 0 then 
        pcall(function() newChar:WaitForChild("Humanoid").WalkSpeed = FeatureValues["Speed"] end) 
    end
    if EnabledFeatures["Noclip"] then Noclip(true) end
    if EnabledFeatures["Fly"] then nowe = false tpwalking = false task.wait(0.3) startFly() end
end)

return {
    startFly = startFly,
    stopFly = stopFly,
    ToggleSpeed = ToggleSpeed,
    InfiniteJump = InfiniteJump,
    Noclip = Noclip
}
