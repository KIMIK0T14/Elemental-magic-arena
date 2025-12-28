-- KIMIKO BETA - Módulo Sticky (Pegajoso)
-- Funciones: Seguir jugadores, Modos Libre/Fijar
local Data = _G.KimikoData
local Players = Data.Players
local TweenService = Data.TweenService
local RunService = Data.RunService
local Texts = Data.Texts
local Colors = Data.Colors

local Module = {}

-- Variables locales
local selectedPlayer = nil
local currentStickyMode = nil
local followConn = nil
local stickyDistance = 2
local persistentMode = nil
local persistentTarget = nil
local originalAnimator = nil
local stickyPlayerButtons = {}
local stickyPlayerList = nil

local LocalPlayer = Data.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES DE STICKY
-- ═══════════════════════════════════════════════════════════════
local function freezeAnimations() 
    local c = LocalPlayer.Character 
    if not c then return end 
    local h = c:FindFirstChildOfClass("Humanoid") 
    if not h then return end 
    local a = h:FindFirstChildOfClass("Animator") 
    if a and not originalAnimator then originalAnimator = a:Clone() end 
    for _, t in pairs(h:GetPlayingAnimationTracks()) do t:Stop() end 
    if a then a:Destroy() end 
end

local function restoreAnimations() 
    local c = LocalPlayer.Character 
    if not c then return end 
    local h = c:FindFirstChildOfClass("Humanoid") 
    if not h then return end 
    if originalAnimator and not h:FindFirstChildOfClass("Animator") then 
        originalAnimator:Clone().Parent = h 
    end 
end

local function stopFollowing() 
    if followConn then followConn:Disconnect() followConn = nil end 
    restoreAnimations() 
end

local function setStickyMode(mode) 
    currentStickyMode = mode 
    persistentMode = mode 
    persistentTarget = selectedPlayer 
    stopFollowing() 
    if not selectedPlayer then return end 
    freezeAnimations() 
    
    followConn = RunService.Heartbeat:Connect(function() 
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        local targetHRP = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if not (myHrp and targetHRP) then return end 
        local behindPos = targetHRP.Position - targetHRP.CFrame.LookVector * stickyDistance 
        if currentStickyMode == "Libre" or currentStickyMode == "Free" then 
            myHrp.CFrame = CFrame.new(myHrp.Position:Lerp(behindPos, 0.2)) 
        elseif currentStickyMode == "Fijar" or currentStickyMode == "Lock" then 
            myHrp.CFrame = CFrame.lookAt(myHrp.Position:Lerp(behindPos, 0.2), targetHRP.Position) 
        end 
    end) 
end

local function updatePlayerList()
    if not stickyPlayerList then return end
    
    for _, b in pairs(stickyPlayerButtons) do b:Destroy() end
    table.clear(stickyPlayerButtons)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton") 
            btn.Size = UDim2.new(1, -12, 0, 35) 
            btn.Text = player.DisplayName 
            btn.TextColor3 = Colors.Text 
            btn.BackgroundColor3 = (selectedPlayer == player) and Colors.Success or Color3.fromRGB(50, 50, 65) 
            btn.BorderSizePixel = 0 
            btn.Font = Enum.Font.GothamSemibold 
            btn.TextSize = 12 
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            btn.MouseButton1Click:Connect(function() 
                selectedPlayer = player 
                persistentTarget = player 
                for _, b2 in pairs(stickyPlayerButtons) do 
                    b2.BackgroundColor3 = Color3.fromRGB(50, 50, 65) 
                end 
                btn.BackgroundColor3 = Colors.Success 
                if currentStickyMode then setStickyMode(currentStickyMode) end 
            end)
            
            btn.Parent = stickyPlayerList 
            table.insert(stickyPlayerButtons, btn)
        end
    end
    
    local layout = stickyPlayerList:FindFirstChildOfClass("UIListLayout")
    if layout then
        stickyPlayerList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZACIÓN DEL MÓDULO
-- ═══════════════════════════════════════════════════════════════
function Module.init(contentFrame)
    local createSlider = Data.createSlider
    local setupSlider = Data.setupSlider
    
    -- Título
    local stickyTitle = Instance.new("TextLabel", contentFrame) 
    stickyTitle.Size = UDim2.new(1, -20, 0, 25) 
    stickyTitle.Position = UDim2.fromOffset(10, 10) 
    stickyTitle.Text = Texts.stickyMode 
    stickyTitle.TextColor3 = Colors.Text 
    stickyTitle.BackgroundTransparency = 1 
    stickyTitle.Font = Enum.Font.GothamBold 
    stickyTitle.TextSize = 14 
    stickyTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botones de modo
    local stickyModeButtons = {} 
    local stickyModeNames = {Texts.free, Texts.lock}
    
    for i, name in ipairs(stickyModeNames) do
        local btn = Instance.new("TextButton", contentFrame) 
        btn.Size = UDim2.new(0.45, -5, 0, 30) 
        btn.Position = UDim2.fromOffset(10 + (i - 1) * 80, 40) 
        btn.Text = name 
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55) 
        btn.TextColor3 = Colors.Text 
        btn.Font = Enum.Font.GothamSemibold 
        btn.TextSize = 13 
        btn.BorderSizePixel = 0 
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function() 
            if currentStickyMode == name then 
                stopFollowing() 
                currentStickyMode = nil 
                persistentMode = nil 
                persistentTarget = nil 
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55) 
            else 
                for _, b in pairs(stickyModeButtons) do 
                    b.BackgroundColor3 = Color3.fromRGB(45, 45, 55) 
                end 
                btn.BackgroundColor3 = Colors.Success 
                setStickyMode(name) 
            end 
        end)
        
        stickyModeButtons[i] = btn
    end
    
    -- Slider de distancia
    local distanceSlider = createSlider(contentFrame, Texts.distance, stickyDistance, 1, 10, UDim2.fromOffset(10, 80), Colors.Sticky, false)
    
    setupSlider(distanceSlider, function(val, pct) 
        distanceSlider.label.Text = Texts.distance .. ": " .. tostring(math.floor(val)) .. " studs" 
        stickyDistance = math.floor(val) 
    end)
    
    -- Título lista de jugadores
    local stickyPlayerTitle = Instance.new("TextLabel", contentFrame) 
    stickyPlayerTitle.Size = UDim2.new(1, -20, 0, 25) 
    stickyPlayerTitle.Position = UDim2.fromOffset(10, 155) 
    stickyPlayerTitle.Text = Texts.selectPlayer 
    stickyPlayerTitle.TextColor3 = Colors.Text 
    stickyPlayerTitle.BackgroundTransparency = 1 
    stickyPlayerTitle.Font = Enum.Font.GothamBold 
    stickyPlayerTitle.TextSize = 13 
    stickyPlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Lista de jugadores
    stickyPlayerList = Instance.new("ScrollingFrame", contentFrame) 
    stickyPlayerList.Size = UDim2.new(1, -20, 0, 200) 
    stickyPlayerList.Position = UDim2.fromOffset(10, 185) 
    stickyPlayerList.BackgroundColor3 = Colors.Surface 
    stickyPlayerList.BorderSizePixel = 0 
    stickyPlayerList.ScrollBarThickness = 6 
    stickyPlayerList.ScrollBarImageColor3 = Colors.Sticky 
    Instance.new("UICorner", stickyPlayerList).CornerRadius = UDim.new(0, 12)
    
    local stickyPlayerLayout = Instance.new("UIListLayout", stickyPlayerList) 
    stickyPlayerLayout.Padding = UDim.new(0, 6) 
    stickyPlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local stickyPlayerPadding = Instance.new("UIPadding", stickyPlayerList) 
    stickyPlayerPadding.PaddingTop = UDim.new(0, 6) 
    stickyPlayerPadding.PaddingBottom = UDim.new(0, 6) 
    stickyPlayerPadding.PaddingLeft = UDim.new(0, 6) 
    stickyPlayerPadding.PaddingRight = UDim.new(0, 6)
    
    print("[KIMIKO] Módulo Sticky inicializado")
end

function Module.updatePlayerList()
    updatePlayerList()
end

function Module.onRespawn()
    if persistentMode and persistentTarget and persistentTarget.Parent then 
        selectedPlayer = persistentTarget 
        task.wait(0.5) 
        setStickyMode(persistentMode) 
    end
end

return Module
