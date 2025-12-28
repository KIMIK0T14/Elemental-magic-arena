-- KIMIKO BETA - Sistema Modular
-- Archivo Principal: Contiene toda la interfaz visual y carga los módulos externos
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalizationService = game:GetService("LocalizationService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then Players:GetPropertyChangedSignal("LocalPlayer"):Wait() LocalPlayer = Players.LocalPlayer end

local guiParent
local success, err = pcall(function() guiParent = gethui and gethui() or game:GetService("CoreGui") end)
if not success then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

if guiParent:FindFirstChild("KimikoHUD") then warn("KIMIKO BETA ya ejecutado!") return end

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURACIÓN GLOBAL (Compartida con los módulos)
-- ═══════════════════════════════════════════════════════════════
local LOGO_IMAGE = "rbxassetid://92089256148621"
local SCRIPTBLOX_URL = "https://scriptblox.com/u/KIMIK0T14"
local ALLOWED_IDS = {7243409883, 13881791568}

local isSpanish = false
pcall(function() isSpanish = (LocalizationService.RobloxLocaleId:sub(1, 2) == "es") end)

-- Textos multi-idioma
local Texts = {
    starting = isSpanish and "Iniciando..." or "Starting...",
    verifyingGame = isSpanish and "Verificando juego..." or "Verifying game...",
    checkingId = isSpanish and "Comprobando ID: " or "Checking ID: ",
    gameVerified = isSpanish and "Juego verificado!" or "Game verified!",
    loadingInterface = isSpanish and "Cargando interfaz..." or "Loading interface...",
    loadingModules = isSpanish and "Cargando módulos..." or "Loading modules...",
    gameNotAllowed = isSpanish and "Juego no permitido!" or "Game not allowed!",
    onlyWorksIn = isSpanish and "Este script solo funciona en Elemental Magic Arena" or "This script only works in Elemental Magic Arena",
    home = "Home", movement = isSpanish and "Movimiento" or "Movement",
    diamonds = isSpanish and "Diamantes" or "Diamonds", gifts = isSpanish and "Regalos" or "Gifts",
    sticky = isSpanish and "Pegajoso" or "Sticky", esp = "ESP",
    myProfile = isSpanish and "Mi perfil en ScriptBlox" or "My ScriptBlox profile",
    visit = isSpanish and "Visitar" or "Visit", copied = isSpanish and "Copiado!" or "Copied!",
    account = isSpanish and "Cuenta: " or "Account: ", days = isSpanish and " dias" or " days",
    realTimeStats = isSpanish and "ESTADISTICAS EN TIEMPO REAL" or "REAL TIME STATS",
    serverInfo = isSpanish and "INFORMACION DEL SERVIDOR" or "SERVER INFORMATION",
    game = isSpanish and "Juego: " or "Game: ", players = isSpanish and "Jugadores: " or "Players: ",
    speed = isSpanish and "Velocidad" or "Speed", defaultSpeed = isSpanish and "Predeterminada" or "Default",
    infiniteJump = isSpanish and "Salto Infinito" or "Infinite Jump",
    noclip = isSpanish and "Atravesar Paredes" or "Noclip", fly = isSpanish and "Volar" or "Fly",
    flySpeed = isSpanish and "Velocidad Volar" or "Fly Speed",
    autoCollect = isSpanish and "Auto Recolectar" or "Auto Collect",
    availableDiamonds = isSpanish and "DIAMANTES DISPONIBLES" or "AVAILABLE DIAMONDS",
    autoGift = isSpanish and "Auto Regalo" or "Auto Gift",
    giftNotifications = isSpanish and "Notificaciones" or "Notifications",
    availableGifts = isSpanish and "REGALOS DISPONIBLES" or "AVAILABLE GIFTS",
    giftAppeared = isSpanish and "Aparecio Regalo " or "Gift appeared ",
    tapToGo = isSpanish and "Toca para ir" or "Tap to go",
    noGifts = isSpanish and "No hay regalos" or "No gifts",
    stickyMode = isSpanish and "MODO PEGAJOSO" or "STICKY MODE",
    free = isSpanish and "Libre" or "Free", lock = isSpanish and "Fijar" or "Lock",
    distance = isSpanish and "Distancia" or "Distance",
    selectPlayer = isSpanish and "SELECCIONAR JUGADOR" or "SELECT PLAYER",
    ayaEsp = "ESP", showName = isSpanish and "Mostrar Nombre" or "Show Name",
    showHealth = isSpanish and "Mostrar Vida" or "Show Health",
    showDistance = isSpanish and "Mostrar Distancia" or "Show Distance",
    showBox = isSpanish and "Mostrar Caja" or "Show Box",
    showTracers = isSpanish and "Mostrar Lineas" or "Show Tracers",
    health = isSpanish and "Vida" or "Health", dist = "Dist", studs = "studs",
    espPlayers = isSpanish and "JUGADORES DETECTADOS" or "DETECTED PLAYERS"
}

-- Colores del tema
local Colors = {
    Primary = Color3.fromRGB(138, 43, 226), Secondary = Color3.fromRGB(75, 0, 130),
    Accent = Color3.fromRGB(186, 85, 211), Background = Color3.fromRGB(17, 17, 27),
    Surface = Color3.fromRGB(25, 25, 35), Text = Color3.new(1, 1, 1),
    TextSecondary = Color3.fromRGB(160, 160, 180), Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15), Danger = Color3.fromRGB(231, 76, 60),
    Home = Color3.fromRGB(0, 191, 255), Diamond = Color3.fromRGB(0, 170, 255),
    Gift = Color3.fromRGB(255, 105, 180), Sticky = Color3.fromRGB(255, 165, 0),
    ScriptBlox = Color3.fromRGB(255, 85, 85), ESP = Color3.fromRGB(0, 255, 127)
}

-- Variables globales compartidas con módulos
_G.KimikoData = {
    LocalPlayer = LocalPlayer,
    Players = Players,
    UIS = UIS,
    TweenService = TweenService,
    RunService = RunService,
    Texts = Texts,
    Colors = Colors,
    isSpanish = isSpanish,
    EnabledFeatures = {
        ["InfiniteJump"] = false, ["Speed"] = false, ["Noclip"] = false, 
        ["Fly"] = false, ["AutoCollect"] = false, ["AutoGift"] = false, 
        ["GiftNotifications"] = true, ["AyaESP"] = false, ["ShowName"] = true, 
        ["ShowHealth"] = true, ["ShowDistance"] = true, ["ShowBox"] = true, 
        ["ShowTracers"] = false
    },
    FeatureValues = {["Speed"] = 0, ["FlySpeed"] = 1, ["TeleportTime"] = 0.1},
    connections = {}
}

-- ═══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
local loadingGui = Instance.new("ScreenGui") loadingGui.Name = "KimikoLoading" loadingGui.ResetOnSpawn = false loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling loadingGui.DisplayOrder = 999 loadingGui.Parent = guiParent
local blurEffect = Instance.new("BlurEffect") blurEffect.Size = 24 blurEffect.Parent = game:GetService("Lighting")
local loadingContainer = Instance.new("Frame", loadingGui) loadingContainer.Size = UDim2.fromOffset(400, 200) loadingContainer.Position = UDim2.new(0.5, -200, 0.5, -100) loadingContainer.BackgroundColor3 = Colors.Background loadingContainer.BorderSizePixel = 0
Instance.new("UICorner", loadingContainer).CornerRadius = UDim.new(0, 20)
local loadingLogo = Instance.new("ImageLabel", loadingContainer) loadingLogo.Size = UDim2.fromOffset(60, 60) loadingLogo.Position = UDim2.new(0.5, -30, 0, 25) loadingLogo.Image = LOGO_IMAGE loadingLogo.BackgroundTransparency = 1
local loadingTitle = Instance.new("TextLabel", loadingContainer) loadingTitle.Size = UDim2.new(1, 0, 0, 35) loadingTitle.Position = UDim2.fromOffset(0, 90) loadingTitle.Text = "KIMIKO BETA" loadingTitle.TextColor3 = Colors.Text loadingTitle.BackgroundTransparency = 1 loadingTitle.Font = Enum.Font.GothamBold loadingTitle.TextSize = 28
local loadingBarBg = Instance.new("Frame", loadingContainer) loadingBarBg.Size = UDim2.new(0.8, 0, 0, 8) loadingBarBg.Position = UDim2.new(0.1, 0, 0, 135) loadingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55) loadingBarBg.BorderSizePixel = 0 Instance.new("UICorner", loadingBarBg).CornerRadius = UDim.new(1, 0)
local loadingBarFill = Instance.new("Frame", loadingBarBg) loadingBarFill.Size = UDim2.new(0, 0, 1, 0) loadingBarFill.BackgroundColor3 = Colors.Primary loadingBarFill.BorderSizePixel = 0 Instance.new("UICorner", loadingBarFill).CornerRadius = UDim.new(1, 0)
local loadingStatus = Instance.new("TextLabel", loadingContainer) loadingStatus.Size = UDim2.new(1, 0, 0, 25) loadingStatus.Position = UDim2.fromOffset(0, 150) loadingStatus.Text = Texts.starting loadingStatus.TextColor3 = Colors.TextSecondary loadingStatus.BackgroundTransparency = 1 loadingStatus.Font = Enum.Font.GothamSemibold loadingStatus.TextSize = 14

local function animateLoadingBar(p, d) TweenService:Create(loadingBarFill, TweenInfo.new(d, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(p, 0, 1, 0)}):Play() end

-- ═══════════════════════════════════════════════════════════════
-- URLs DE LOS MÓDULOS (Cambia estas URLs a tu repositorio)
-- ═══════════════════════════════════════════════════════════════
local MODULE_URLS = {
    movement = "https://raw.githubusercontent.com/KIMIK0T14/Elemental-arena/refs/heads/main/modules/movement.lua",
    diamonds = "https://raw.githubusercontent.com/KIMIK0T14/Elemental-arena/refs/heads/main/modules/diamonds.lua",
    gifts = "https://raw.githubusercontent.com/KIMIK0T14/Elemental-arena/refs/heads/main/modules/gifts.lua",
    sticky = "https://raw.githubusercontent.com/KIMIK0T14/Elemental-arena/refs/heads/main/modules/sticky.lua",
    esp = "https://raw.githubusercontent.com/KIMIK0T14/Elemental-arena/refs/heads/main/modules/esp.lua"
}

-- Almacén de módulos cargados
local Modules = {}

local isAllowed = false
task.spawn(function()
    loadingStatus.Text = Texts.starting animateLoadingBar(0.15, 0.5) task.wait(0.6)
    loadingStatus.Text = Texts.verifyingGame animateLoadingBar(0.3, 0.8) task.wait(1)
    loadingStatus.Text = Texts.checkingId .. tostring(game.PlaceId) animateLoadingBar(0.45, 0.5) task.wait(0.7)
    
    for _, id in pairs(ALLOWED_IDS) do if game.PlaceId == id or game.GameId == id then isAllowed = true break end end
    
    if isAllowed then
        loadingStatus.Text = Texts.gameVerified loadingStatus.TextColor3 = Colors.Success animateLoadingBar(0.6, 0.5) task.wait(0.5)
        
        -- Cargar módulos externos
        loadingStatus.Text = Texts.loadingModules animateLoadingBar(0.75, 0.5)
        
        -- Cargar cada módulo usando loadstring
        for name, url in pairs(MODULE_URLS) do
            pcall(function()
                loadingStatus.Text = (isSpanish and "Cargando: " or "Loading: ") .. name
                local moduleCode = game:HttpGet(url)
                Modules[name] = loadstring(moduleCode)()
                print("[KIMIKO] Módulo cargado: " .. name)
            end)
            task.wait(0.2)
        end
        
        animateLoadingBar(0.9, 0.3) task.wait(0.3)
        loadingStatus.Text = Texts.loadingInterface animateLoadingBar(1, 0.3) task.wait(0.5)
        
        TweenService:Create(loadingContainer, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(loadingTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(loadingStatus, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(loadingLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        TweenService:Create(blurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
        task.wait(0.6) loadingGui:Destroy() blurEffect:Destroy()
    else
        loadingStatus.Text = Texts.gameNotAllowed loadingStatus.TextColor3 = Colors.Danger loadingBarFill.BackgroundColor3 = Colors.Danger animateLoadingBar(1, 0.3)
        task.wait(1) loadingStatus.Text = Texts.onlyWorksIn task.wait(3)
        TweenService:Create(loadingContainer, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
        task.wait(0.6) loadingGui:Destroy() blurEffect:Destroy() return
    end
end)

repeat task.wait(0.1) until isAllowed or not loadingGui.Parent
if not isAllowed then return end

-- Guardar módulos en _G para acceso global
_G.KimikoModules = Modules

-- ═══════════════════════════════════════════════════════════════
-- VARIABLES DE INTERFAZ
-- ═══════════════════════════════════════════════════════════════
local currentFPS, currentPing, frameCount, lastFPSUpdate = 0, 0, 0, tick()
local isMinimized, currentView = false, "home"

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local defaultWalkSpeed = 16
pcall(function() defaultWalkSpeed = hum.WalkSpeed end)

_G.KimikoData.char = char
_G.KimikoData.hum = hum
_G.KimikoData.hrp = hrp
_G.KimikoData.defaultWalkSpeed = defaultWalkSpeed

-- Actualizar referencias cuando el personaje respawnea
LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar hum = newChar:WaitForChild("Humanoid") hrp = newChar:WaitForChild("HumanoidRootPart")
    _G.KimikoData.char = char
    _G.KimikoData.hum = hum
    _G.KimikoData.hrp = hrp
    
    task.wait(0.5)
    
    -- Llamar a los módulos para que manejen el respawn
    if Modules.movement and Modules.movement.onRespawn then Modules.movement.onRespawn() end
    if Modules.sticky and Modules.sticky.onRespawn then Modules.sticky.onRespawn() end
    if Modules.esp and Modules.esp.onRespawn then Modules.esp.onRespawn() end
end)

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES DE ESTADÍSTICAS
-- ═══════════════════════════════════════════════════════════════
local function updateStats() 
    frameCount = frameCount + 1 
    local ct = tick() 
    if ct - lastFPSUpdate >= 1 then 
        currentFPS = frameCount 
        frameCount = 0 
        lastFPSUpdate = ct 
    end 
    pcall(function() 
        local ns = Stats:FindFirstChild("Network") 
        if ns then 
            local ps = ns:FindFirstChild("ServerStatsItem") 
            if ps then 
                local dp = ps:FindFirstChild("Data Ping") 
                if dp then currentPing = math.floor(dp:GetValue()) end 
            end 
        end 
    end) 
end
RunService.Heartbeat:Connect(updateStats)

local function openURL(url) if setclipboard then setclipboard(url) end end

-- ═══════════════════════════════════════════════════════════════
-- INTERFAZ PRINCIPAL
-- ═══════════════════════════════════════════════════════════════
local fpsLabel, pingLabel, playersLabel, espPlayerCount
local homeContent, movementContent, diamondContent, giftContent, stickyContent, espContent

local gui = Instance.new("ScreenGui") gui.Name = "KimikoHUD" gui.ResetOnSpawn = false gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling gui.Parent = guiParent
_G.KimikoData.gui = gui

-- Notification container (para el módulo de gifts)
local notificationContainer = Instance.new("Frame", gui) notificationContainer.Size = UDim2.new(0, 280, 0, 200) notificationContainer.Position = UDim2.new(1, -290, 0, 10) notificationContainer.BackgroundTransparency = 1 notificationContainer.ZIndex = 100
_G.KimikoData.notificationContainer = notificationContainer

-- Main Window
local mainWindow = Instance.new("Frame", gui) mainWindow.Size = UDim2.fromOffset(450, 350) mainWindow.Position = UDim2.new(0.5, -225, 0.5, -175) mainWindow.BackgroundColor3 = Colors.Background mainWindow.BorderSizePixel = 0 mainWindow.ClipsDescendants = true
Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 20)

-- Title Bar
local titleBar = Instance.new("Frame", mainWindow) titleBar.Size = UDim2.new(1, 0, 0, 60) titleBar.BackgroundColor3 = Colors.Primary titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 20)
local titleGradient = Instance.new("UIGradient", titleBar) titleGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Colors.Primary), ColorSequenceKeypoint.new(1, Colors.Secondary)} titleGradient.Rotation = 45

local titleLogoImage = Instance.new("ImageLabel", titleBar) titleLogoImage.Size = UDim2.fromOffset(40, 40) titleLogoImage.Position = UDim2.fromOffset(15, 10) titleLogoImage.Image = LOGO_IMAGE titleLogoImage.BackgroundTransparency = 1
local titleLabel = Instance.new("TextLabel", titleBar) titleLabel.Size = UDim2.new(1, -120, 0, 30) titleLabel.Position = UDim2.fromOffset(65, 8) titleLabel.Text = "KIMIKO BETA" titleLabel.TextColor3 = Colors.Text titleLabel.BackgroundTransparency = 1 titleLabel.Font = Enum.Font.GothamBold titleLabel.TextSize = 18 titleLabel.TextXAlignment = Enum.TextXAlignment.Left
local subtitleLabel = Instance.new("TextLabel", titleBar) subtitleLabel.Size = UDim2.new(1, -120, 0, 20) subtitleLabel.Position = UDim2.fromOffset(65, 35) subtitleLabel.Text = "Elemental Magic Arena" subtitleLabel.TextColor3 = Colors.TextSecondary subtitleLabel.BackgroundTransparency = 1 subtitleLabel.Font = Enum.Font.Gotham subtitleLabel.TextSize = 12 subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle button (Minimize/Maximize)
local toggleButton = Instance.new("ImageButton", gui) toggleButton.Size = UDim2.fromOffset(50, 50) toggleButton.Position = UDim2.new(1, -70, 0, 20) toggleButton.BackgroundTransparency = 1 toggleButton.Image = LOGO_IMAGE toggleButton.ZIndex = 1000
local dragging, draggingInput, dragStart, startPos = false, nil, nil, nil
toggleButton.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = toggleButton.Position i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
toggleButton.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then draggingInput = i end end)
UIS.InputChanged:Connect(function(i) if i == draggingInput and dragging then local d = i.Position - dragStart toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
toggleButton.MouseButton1Click:Connect(function() isMinimized = not isMinimized mainWindow.Visible = not isMinimized end)

local expandedView = Instance.new("Frame", mainWindow) expandedView.Size = UDim2.new(1, 0, 1, -60) expandedView.Position = UDim2.fromOffset(0, 60) expandedView.BackgroundTransparency = 1

-- ═══════════════════════════════════════════════════════════════
-- SIDEBAR
-- ═══════════════════════════════════════════════════════════════
local sidebar = Instance.new("Frame", expandedView) sidebar.Size = UDim2.new(0, 140, 1, 0) sidebar.BackgroundColor3 = Colors.Surface sidebar.BorderSizePixel = 0 Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 15)

local function createSideBtn(name, icon, pos, color)
    local btn = Instance.new("TextButton", sidebar) btn.Size = UDim2.new(1, -20, 0, 35) btn.Position = UDim2.fromOffset(10, pos) btn.Text = "" btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55) btn.BorderSizePixel = 0 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local ic = Instance.new("TextLabel", btn) ic.Size = UDim2.fromOffset(20, 20) ic.Position = UDim2.fromOffset(8, 7) ic.Text = icon ic.TextColor3 = Colors.TextSecondary ic.BackgroundTransparency = 1 ic.Font = Enum.Font.GothamBold ic.TextSize = 12
    local tx = Instance.new("TextLabel", btn) tx.Size = UDim2.new(1, -35, 1, 0) tx.Position = UDim2.fromOffset(30, 0) tx.Text = name tx.TextColor3 = Colors.TextSecondary tx.BackgroundTransparency = 1 tx.Font = Enum.Font.GothamSemibold tx.TextSize = 11 tx.TextXAlignment = Enum.TextXAlignment.Left
    return btn, ic, tx, color
end

local sidebarHome, sideHomeIcon, sideHomeText = createSideBtn(Texts.home, "H", 8, Colors.Home)
local sidebarMovimiento, sideMovIcon, sideMovText = createSideBtn(Texts.movement, "M", 48, Colors.Primary)
local sidebarDiamond, sideDiamondIcon, sideDiamondText = createSideBtn(Texts.diamonds, "D", 88, Colors.Diamond)
local sidebarGift, sideGiftIcon, sideGiftText = createSideBtn(Texts.gifts, "R", 128, Colors.Gift)
local sidebarSticky, sideStickyIcon, sideStickyText = createSideBtn(Texts.sticky, "P", 168, Colors.Sticky)
local sidebarESP, sideESPIcon, sideESPText = createSideBtn(Texts.esp, "E", 208, Colors.ESP)

-- ═══════════════════════════════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════════════════════════════
local contentArea = Instance.new("ScrollingFrame", expandedView) contentArea.Size = UDim2.new(1, -150, 1, 0) contentArea.Position = UDim2.fromOffset(145, 0) contentArea.BackgroundTransparency = 1 contentArea.ScrollBarThickness = 6 contentArea.ScrollBarImageColor3 = Colors.Primary contentArea.CanvasSize = UDim2.fromOffset(0, 600) contentArea.BorderSizePixel = 0

homeContent = Instance.new("Frame", contentArea) homeContent.Size = UDim2.new(1, 0, 0, 550) homeContent.BackgroundTransparency = 1 homeContent.Visible = true
movementContent = Instance.new("Frame", contentArea) movementContent.Size = UDim2.new(1, 0, 0, 400) movementContent.BackgroundTransparency = 1 movementContent.Visible = false
diamondContent = Instance.new("Frame", contentArea) diamondContent.Size = UDim2.new(1, 0, 0, 500) diamondContent.BackgroundTransparency = 1 diamondContent.Visible = false
giftContent = Instance.new("Frame", contentArea) giftContent.Size = UDim2.new(1, 0, 0, 500) giftContent.BackgroundTransparency = 1 giftContent.Visible = false
stickyContent = Instance.new("Frame", contentArea) stickyContent.Size = UDim2.new(1, 0, 0, 500) stickyContent.BackgroundTransparency = 1 stickyContent.Visible = false
espContent = Instance.new("Frame", contentArea) espContent.Size = UDim2.new(1, 0, 0, 400) espContent.BackgroundTransparency = 1 espContent.Visible = false

-- Guardar referencias para los módulos
_G.KimikoData.contentFrames = {
    home = homeContent,
    movement = movementContent,
    diamond = diamondContent,
    gift = giftContent,
    sticky = stickyContent,
    esp = espContent
}

-- ═══════════════════════════════════════════════════════════════
-- FUNCIÓN PARA CAMBIAR DE VISTA
-- ═══════════════════════════════════════════════════════════════
local function switchView(view)
    if currentView == view then return end
    currentView = view
    sidebarHome.BackgroundColor3 = Color3.fromRGB(40, 40, 55) sideHomeIcon.TextColor3 = Colors.TextSecondary sideHomeText.TextColor3 = Colors.TextSecondary
    sidebarMovimiento.BackgroundColor3 = Color3.fromRGB(40, 40, 55) sideMovIcon.TextColor3 = Colors.TextSecondary sideMovText.TextColor3 = Colors.TextSecondary
    sidebarDiamond.BackgroundColor3 = Color3.fromRGB(40, 40, 55) sideDiamondIcon.TextColor3 = Colors.TextSecondary sideDiamondText.TextColor3 = Colors.TextSecondary
    sidebarGift.BackgroundColor3 = Color3.fromRGB(40, 40, 55) sideGiftIcon.TextColor3 = Colors.TextSecondary sideGiftText.TextColor3 = Colors.TextSecondary
    sidebarSticky.BackgroundColor3 = Color3.fromRGB(40, 40, 55) sideStickyIcon.TextColor3 = Colors.TextSecondary sideStickyText.TextColor3 = Colors.TextSecondary
    sidebarESP.BackgroundColor3 = Color3.fromRGB(40, 40, 55) sideESPIcon.TextColor3 = Colors.TextSecondary sideESPText.TextColor3 = Colors.TextSecondary
    homeContent.Visible = false movementContent.Visible = false diamondContent.Visible = false giftContent.Visible = false stickyContent.Visible = false espContent.Visible = false
    
    if view == "home" then sidebarHome.BackgroundColor3 = Colors.Home sideHomeIcon.TextColor3 = Colors.Text sideHomeText.TextColor3 = Colors.Text homeContent.Visible = true
    elseif view == "movement" then sidebarMovimiento.BackgroundColor3 = Colors.Primary sideMovIcon.TextColor3 = Colors.Text sideMovText.TextColor3 = Colors.Text movementContent.Visible = true
    elseif view == "diamond" then sidebarDiamond.BackgroundColor3 = Colors.Diamond sideDiamondIcon.TextColor3 = Colors.Text sideDiamondText.TextColor3 = Colors.Text diamondContent.Visible = true
    elseif view == "gift" then sidebarGift.BackgroundColor3 = Colors.Gift sideGiftIcon.TextColor3 = Colors.Text sideGiftText.TextColor3 = Colors.Text giftContent.Visible = true
    elseif view == "sticky" then 
        sidebarSticky.BackgroundColor3 = Colors.Sticky sideStickyIcon.TextColor3 = Colors.Text sideStickyText.TextColor3 = Colors.Text stickyContent.Visible = true
        if Modules.sticky and Modules.sticky.updatePlayerList then Modules.sticky.updatePlayerList() end
    elseif view == "esp" then sidebarESP.BackgroundColor3 = Colors.ESP sideESPIcon.TextColor3 = Colors.Text sideESPText.TextColor3 = Colors.Text espContent.Visible = true end
end

-- ═══════════════════════════════════════════════════════════════
-- UI HELPERS (Compartidos con módulos)
-- ═══════════════════════════════════════════════════════════════
local function createSlider(parent, label, val, minV, maxV, pos, color, isDef, defText)
    local c = Instance.new("Frame", parent) c.Size = UDim2.new(1, -20, 0, 65) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, 0, 0, 22) l.BackgroundTransparency = 1 l.Text = label .. ": " .. (isDef and val <= minV and (defText or Texts.defaultSpeed) or tostring(math.floor(val)) .. "x") l.TextColor3 = Colors.Text l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("Frame", c) bg.Size = UDim2.new(1, 0, 0, 30) bg.Position = UDim2.fromOffset(0, 30) bg.BackgroundColor3 = Color3.fromRGB(40, 40, 55) bg.BorderSizePixel = 0 Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local fl = Instance.new("Frame", bg) fl.Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0) fl.BackgroundColor3 = color fl.BorderSizePixel = 0 Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 10)
    local btn = Instance.new("TextButton", bg) btn.Size = UDim2.new(1, 0, 1, 0) btn.Text = "" btn.BackgroundTransparency = 1
    return {container = c, label = l, bg = bg, fill = fl, button = btn, minVal = minV, maxVal = maxV, value = val, isDef = isDef, labelText = label, defText = defText or Texts.defaultSpeed}
end

local function createToggle(parent, label, pos, active, color)
    local c = Instance.new("Frame", parent) c.Size = UDim2.new(1, -20, 0, 40) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, -65, 1, 0) l.Text = label l.TextColor3 = Colors.Text l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("TextButton", c) sw.Size = UDim2.fromOffset(55, 28) sw.Position = UDim2.new(1, -60, 0.5, -14) sw.Text = "" sw.BackgroundColor3 = active and color or Color3.fromRGB(40, 40, 55) sw.BorderSizePixel = 0 Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame", sw) kn.Size = UDim2.fromOffset(22, 22) kn.Position = UDim2.fromOffset(active and 30 or 3, 3) kn.BackgroundColor3 = Colors.Text kn.BorderSizePixel = 0 Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    return {container = c, label = l, switch = sw, knob = kn}
end

_G.KimikoData.createSlider = createSlider
_G.KimikoData.createToggle = createToggle

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
        _G.KimikoData.EnabledFeatures[feature] = not _G.KimikoData.EnabledFeatures[feature] 
        if _G.KimikoData.EnabledFeatures[feature] then 
            toggle.switch.BackgroundColor3 = color 
            TweenService:Create(toggle.knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(30, 3)}):Play() 
        else 
            toggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
            TweenService:Create(toggle.knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(3, 3)}):Play() 
        end 
        if callback then callback(_G.KimikoData.EnabledFeatures[feature]) end 
    end) 
end

_G.KimikoData.setupSlider = setupSlider
_G.KimikoData.setupToggle = setupToggle

-- ═══════════════════════════════════════════════════════════════
-- HOME CONTENT
-- ═══════════════════════════════════════════════════════════════
local scriptBloxFrame = Instance.new("Frame", homeContent) scriptBloxFrame.Size = UDim2.new(1, -20, 0, 70) scriptBloxFrame.Position = UDim2.fromOffset(10, 10) scriptBloxFrame.BackgroundColor3 = Colors.Surface scriptBloxFrame.BorderSizePixel = 0 Instance.new("UICorner", scriptBloxFrame).CornerRadius = UDim.new(0, 12)
local sbIcon = Instance.new("ImageLabel", scriptBloxFrame) sbIcon.Size = UDim2.fromOffset(45, 45) sbIcon.Position = UDim2.fromOffset(12, 12) sbIcon.Image = LOGO_IMAGE sbIcon.BackgroundTransparency = 1
local sbTitle = Instance.new("TextLabel", scriptBloxFrame) sbTitle.Size = UDim2.new(1, -140, 0, 22) sbTitle.Position = UDim2.fromOffset(65, 12) sbTitle.Text = "KIMIK0T14" sbTitle.TextColor3 = Colors.Text sbTitle.BackgroundTransparency = 1 sbTitle.Font = Enum.Font.GothamBold sbTitle.TextSize = 15 sbTitle.TextXAlignment = Enum.TextXAlignment.Left
local sbSub = Instance.new("TextLabel", scriptBloxFrame) sbSub.Size = UDim2.new(1, -140, 0, 18) sbSub.Position = UDim2.fromOffset(65, 35) sbSub.Text = Texts.myProfile sbSub.TextColor3 = Colors.TextSecondary sbSub.BackgroundTransparency = 1 sbSub.Font = Enum.Font.Gotham sbSub.TextSize = 11 sbSub.TextXAlignment = Enum.TextXAlignment.Left
local sbBtn = Instance.new("TextButton", scriptBloxFrame) sbBtn.Size = UDim2.fromOffset(60, 30) sbBtn.Position = UDim2.new(1, -75, 0.5, -15) sbBtn.Text = Texts.visit sbBtn.TextColor3 = Colors.Text sbBtn.BackgroundColor3 = Colors.ScriptBlox sbBtn.Font = Enum.Font.GothamBold sbBtn.TextSize = 12 sbBtn.BorderSizePixel = 0 Instance.new("UICorner", sbBtn).CornerRadius = UDim.new(0, 8)
sbBtn.MouseButton1Click:Connect(function() openURL(SCRIPTBLOX_URL) sbBtn.Text = Texts.copied sbBtn.BackgroundColor3 = Colors.Success task.wait(1.5) sbBtn.Text = Texts.visit sbBtn.BackgroundColor3 = Colors.ScriptBlox end)

local playerInfoFrame = Instance.new("Frame", homeContent) playerInfoFrame.Size = UDim2.new(1, -20, 0, 100) playerInfoFrame.Position = UDim2.fromOffset(10, 90) playerInfoFrame.BackgroundColor3 = Colors.Surface playerInfoFrame.BorderSizePixel = 0 Instance.new("UICorner", playerInfoFrame).CornerRadius = UDim.new(0, 12)
local playerImage = Instance.new("ImageLabel", playerInfoFrame) playerImage.Size = UDim2.fromOffset(70, 70) playerImage.Position = UDim2.fromOffset(12, 15) playerImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png" playerImage.BackgroundColor3 = Colors.Primary playerImage.BorderSizePixel = 0 Instance.new("UICorner", playerImage).CornerRadius = UDim.new(0, 12)
local playerName = Instance.new("TextLabel", playerInfoFrame) playerName.Size = UDim2.new(1, -100, 0, 25) playerName.Position = UDim2.fromOffset(95, 20) playerName.Text = LocalPlayer.DisplayName playerName.TextColor3 = Colors.Text playerName.BackgroundTransparency = 1 playerName.Font = Enum.Font.GothamBold playerName.TextSize = 16 playerName.TextXAlignment = Enum.TextXAlignment.Left
local playerUsername = Instance.new("TextLabel", playerInfoFrame) playerUsername.Size = UDim2.new(1, -100, 0, 20) playerUsername.Position = UDim2.fromOffset(95, 45) playerUsername.Text = "@" .. LocalPlayer.Name playerUsername.TextColor3 = Colors.TextSecondary playerUsername.BackgroundTransparency = 1 playerUsername.Font = Enum.Font.Gotham playerUsername.TextSize = 12 playerUsername.TextXAlignment = Enum.TextXAlignment.Left
local accountAge = Instance.new("TextLabel", playerInfoFrame) accountAge.Size = UDim2.new(1, -100, 0, 18) accountAge.Position = UDim2.fromOffset(95, 68) accountAge.Text = Texts.account .. tostring(LocalPlayer.AccountAge) .. Texts.days accountAge.TextColor3 = Colors.TextSecondary accountAge.BackgroundTransparency = 1 accountAge.Font = Enum.Font.Gotham accountAge.TextSize = 11 accountAge.TextXAlignment = Enum.TextXAlignment.Left

local statsFrame = Instance.new("Frame", homeContent) statsFrame.Size = UDim2.new(1, -20, 0, 70) statsFrame.Position = UDim2.fromOffset(10, 200) statsFrame.BackgroundColor3 = Colors.Surface statsFrame.BorderSizePixel = 0 Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 12)
local statsTitle = Instance.new("TextLabel", statsFrame) statsTitle.Size = UDim2.new(1, -20, 0, 22) statsTitle.Position = UDim2.fromOffset(10, 5) statsTitle.Text = Texts.realTimeStats statsTitle.TextColor3 = Colors.Text statsTitle.BackgroundTransparency = 1 statsTitle.Font = Enum.Font.GothamBold statsTitle.TextSize = 13 statsTitle.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel = Instance.new("TextLabel", statsFrame) fpsLabel.Size = UDim2.new(0.5, -10, 0, 22) fpsLabel.Position = UDim2.fromOffset(10, 35) fpsLabel.Text = "FPS: 0" fpsLabel.TextColor3 = Colors.Success fpsLabel.BackgroundTransparency = 1 fpsLabel.Font = Enum.Font.GothamSemibold fpsLabel.TextSize = 14 fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel = Instance.new("TextLabel", statsFrame) pingLabel.Size = UDim2.new(0.5, -10, 0, 22) pingLabel.Position = UDim2.new(0.5, 5, 0, 35) pingLabel.Text = "PING: 0ms" pingLabel.TextColor3 = Colors.Warning pingLabel.BackgroundTransparency = 1 pingLabel.Font = Enum.Font.GothamSemibold pingLabel.TextSize = 14 pingLabel.TextXAlignment = Enum.TextXAlignment.Left

local serverFrame = Instance.new("Frame", homeContent) serverFrame.Size = UDim2.new(1, -20, 0, 140) serverFrame.Position = UDim2.fromOffset(10, 280) serverFrame.BackgroundColor3 = Colors.Surface serverFrame.BorderSizePixel = 0 Instance.new("UICorner", serverFrame).CornerRadius = UDim.new(0, 12)
local serverTitle = Instance.new("TextLabel", serverFrame) serverTitle.Size = UDim2.new(1, -20, 0, 25) serverTitle.Position = UDim2.fromOffset(10, 5) serverTitle.Text = Texts.serverInfo serverTitle.TextColor3 = Colors.Text serverTitle.BackgroundTransparency = 1 serverTitle.Font = Enum.Font.GothamBold serverTitle.TextSize = 13 serverTitle.TextXAlignment = Enum.TextXAlignment.Left
local gameNameLabel = Instance.new("TextLabel", serverFrame) gameNameLabel.Size = UDim2.new(1, -20, 0, 18) gameNameLabel.Position = UDim2.fromOffset(10, 35) gameNameLabel.TextColor3 = Colors.TextSecondary gameNameLabel.BackgroundTransparency = 1 gameNameLabel.Font = Enum.Font.Gotham gameNameLabel.TextSize = 11 gameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
pcall(function() gameNameLabel.Text = Texts.game .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
playersLabel = Instance.new("TextLabel", serverFrame) playersLabel.Size = UDim2.new(1, -20, 0, 18) playersLabel.Position = UDim2.fromOffset(10, 55) playersLabel.Text = Texts.players .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers playersLabel.TextColor3 = Colors.TextSecondary playersLabel.BackgroundTransparency = 1 playersLabel.Font = Enum.Font.Gotham playersLabel.TextSize = 11 playersLabel.TextXAlignment = Enum.TextXAlignment.Left
local gameIdLabel = Instance.new("TextLabel", serverFrame) gameIdLabel.Size = UDim2.new(1, -20, 0, 18) gameIdLabel.Position = UDim2.fromOffset(10, 75) gameIdLabel.Text = "Game ID: " .. game.GameId gameIdLabel.TextColor3 = Colors.TextSecondary gameIdLabel.BackgroundTransparency = 1 gameIdLabel.Font = Enum.Font.Gotham gameIdLabel.TextSize = 11 gameIdLabel.TextXAlignment = Enum.TextXAlignment.Left
local placeIdLabel = Instance.new("TextLabel", serverFrame) placeIdLabel.Size = UDim2.new(1, -20, 0, 18) placeIdLabel.Position = UDim2.fromOffset(10, 95) placeIdLabel.Text = "Place ID: " .. game.PlaceId placeIdLabel.TextColor3 = Colors.TextSecondary placeIdLabel.BackgroundTransparency = 1 placeIdLabel.Font = Enum.Font.Gotham placeIdLabel.TextSize = 11
local jobIdLabel = Instance.new("TextLabel", serverFrame) jobIdLabel.Size = UDim2.new(1, -20, 0, 18) jobIdLabel.Position = UDim2.fromOffset(10, 115) jobIdLabel.Text = "Job ID: " .. game.JobId:sub(1, 8) .. "..." jobIdLabel.TextColor3 = Colors.TextSecondary jobIdLabel.BackgroundTransparency = 1 jobIdLabel.Font = Enum.Font.Gotham jobIdLabel.TextSize = 11 jobIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ═══════════════════════════════════════════════════════════════
-- SIDEBAR EVENTS
-- ═══════════════════════════════════════════════════════════════
sidebarHome.MouseButton1Click:Connect(function() switchView("home") end)
sidebarMovimiento.MouseButton1Click:Connect(function() switchView("movement") end)
sidebarDiamond.MouseButton1Click:Connect(function() switchView("diamond") end)
sidebarGift.MouseButton1Click:Connect(function() switchView("gift") end)
sidebarSticky.MouseButton1Click:Connect(function() switchView("sticky") end)
sidebarESP.MouseButton1Click:Connect(function() switchView("esp") end)

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZAR MÓDULOS (crean su propia UI en los content frames)
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(0.5) -- Esperar a que todo esté listo
    
    if Modules.movement and Modules.movement.init then 
        Modules.movement.init(movementContent) 
    end
    if Modules.diamonds and Modules.diamonds.init then 
        Modules.diamonds.init(diamondContent) 
    end
    if Modules.gifts and Modules.gifts.init then 
        Modules.gifts.init(giftContent) 
    end
    if Modules.sticky and Modules.sticky.init then 
        Modules.sticky.init(stickyContent) 
    end
    if Modules.esp and Modules.esp.init then 
        Modules.esp.init(espContent) 
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- UPDATE LOOPS
-- ═══════════════════════════════════════════════════════════════
task.spawn(function() 
    while gui.Parent do 
        if fpsLabel then fpsLabel.Text = "FPS: " .. tostring(currentFPS) end 
        if pingLabel then pingLabel.Text = "PING: " .. tostring(currentPing) .. "ms" end 
        if playersLabel then playersLabel.Text = Texts.players .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers end 
        task.wait(0.5) 
    end 
end)

switchView("home")

print("═══════════════════════════════════════")
print("     KIMIKO BETA - SISTEMA MODULAR     ")
print("═══════════════════════════════════════")
print("Módulos cargados:")
for name, _ in pairs(Modules) do
    print("  ✓ " .. name)
end
print("Idioma: " .. (isSpanish and "Español" or "English"))
print("═══════════════════════════════════════")
