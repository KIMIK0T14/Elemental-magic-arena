-- KIMIKO BETA - Modulo de Regalos
-- gifts.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local TweenService = Data.TweenService
local Colors = Data.Colors
local Texts = Data.Texts
local EnabledFeatures = Data.EnabledFeatures

local parent = Data.contentFrames.gift
local notificationContainer = Data.notificationContainer
if not parent then return end

-- Variables
local autoGift = false
local giftNotifications = true
local giftButtons = {}
local notificationQueue = {}
local activeNotifications = {}
local MAX_VISIBLE_NOTIFICATIONS = 2
local knownGifts = {}

-- Zona del lobby
local LOBBY_MIN = Vector3.new(math.min(882, 686), math.min(-4, 95), math.min(492, -232))
local LOBBY_MAX = Vector3.new(math.max(882, 686), math.max(-4, 95), math.max(492, -232))

local function isInLobbyZone(pos)
    return pos.X >= LOBBY_MIN.X and pos.X <= LOBBY_MAX.X and
           pos.Y >= LOBBY_MIN.Y and pos.Y <= LOBBY_MAX.Y and
           pos.Z >= LOBBY_MIN.Z and pos.Z <= LOBBY_MAX.Z
end

local function teleportToGift(part) 
    local hrp = Data.hrp
    if not part or not part.Parent or not hrp or not hrp.Parent then return end 
    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0) 
end

-- Notification system
local function updateNotificationPositions() 
    for i, n in ipairs(activeNotifications) do 
        if n and n.Parent then 
            TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(0, (i - 1) * 75)}):Play() 
        end 
    end 
end

local function removeNotification(n) 
    for i, x in ipairs(activeNotifications) do 
        if x == n then table.remove(activeNotifications, i) break end 
    end 
    if n and n.Parent then 
        TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, n.Position.Y.Scale, n.Position.Y.Offset), BackgroundTransparency = 1}):Play() 
        task.delay(0.3, function() if n and n.Parent then n:Destroy() end end) 
    end 
    updateNotificationPositions() 
    if #notificationQueue > 0 and #activeNotifications < MAX_VISIBLE_NOTIFICATIONS then 
        local nxt = table.remove(notificationQueue, 1) 
        if nxt then nxt() end 
    end 
end

local function showGiftNotification(num, part)
    local function create()
        local n = Instance.new("TextButton", notificationContainer) n.Size = UDim2.new(1, 0, 0, 70) n.Position = UDim2.new(1, 50, 0, #activeNotifications * 75) n.BackgroundColor3 = Colors.Gift n.BorderSizePixel = 0 n.Text = "" n.ZIndex = 101 Instance.new("UICorner", n).CornerRadius = UDim.new(0, 12)
        local ic = Instance.new("TextLabel", n) ic.Size = UDim2.fromOffset(40, 40) ic.Position = UDim2.fromOffset(10, 15) ic.Text = "🎁" ic.TextSize = 28 ic.BackgroundTransparency = 1 ic.ZIndex = 102
        local tl = Instance.new("TextLabel", n) tl.Size = UDim2.new(1, -70, 0, 25) tl.Position = UDim2.fromOffset(55, 10) tl.Text = Texts.giftAppeared .. num tl.TextColor3 = Colors.Text tl.BackgroundTransparency = 1 tl.Font = Enum.Font.GothamBold tl.TextSize = 14 tl.TextXAlignment = Enum.TextXAlignment.Left tl.ZIndex = 102
        local sl = Instance.new("TextLabel", n) sl.Size = UDim2.new(1, -70, 0, 20) sl.Position = UDim2.fromOffset(55, 38) sl.Text = Texts.tapToGo sl.TextColor3 = Color3.fromRGB(230, 230, 230) sl.BackgroundTransparency = 1 sl.Font = Enum.Font.Gotham sl.TextSize = 12 sl.TextXAlignment = Enum.TextXAlignment.Left sl.ZIndex = 102
        table.insert(activeNotifications, n)
        TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(0, (#activeNotifications - 1) * 75)}):Play()
        n.MouseButton1Click:Connect(function() if part and part.Parent then teleportToGift(part) end removeNotification(n) end)
        task.delay(5, function() removeNotification(n) end)
    end
    if #activeNotifications < MAX_VISIBLE_NOTIFICATIONS then create() else table.insert(notificationQueue, create) end
end

-- UI Helpers
local function createToggle(parentFrame, label, pos, active, color)
    local c = Instance.new("Frame", parentFrame) c.Size = UDim2.new(1, -20, 0, 40) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, -65, 1, 0) l.Text = label l.TextColor3 = Colors.Text l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("TextButton", c) sw.Size = UDim2.fromOffset(55, 28) sw.Position = UDim2.new(1, -60, 0.5, -14) sw.Text = "" sw.BackgroundColor3 = active and color or Color3.fromRGB(40, 40, 55) sw.BorderSizePixel = 0 Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame", sw) kn.Size = UDim2.fromOffset(22, 22) kn.Position = UDim2.fromOffset(active and 30 or 3, 3) kn.BackgroundColor3 = Colors.Text kn.BorderSizePixel = 0 Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    return {container = c, label = l, switch = sw, knob = kn}
end

-- Crear UI
local autoGiftToggle = createToggle(parent, Texts.autoGift, UDim2.fromOffset(10, 15), autoGift, Colors.Gift)
local notificationToggle = createToggle(parent, Texts.giftNotifications, UDim2.fromOffset(10, 65), giftNotifications, Colors.Gift)
local giftListTitle = Instance.new("TextLabel", parent) giftListTitle.Size = UDim2.new(1, -20, 0, 25) giftListTitle.Position = UDim2.fromOffset(10, 115) giftListTitle.Text = Texts.availableGifts giftListTitle.TextColor3 = Colors.Text giftListTitle.BackgroundTransparency = 1 giftListTitle.Font = Enum.Font.GothamBold giftListTitle.TextSize = 13 giftListTitle.TextXAlignment = Enum.TextXAlignment.Left
local giftListFrame = Instance.new("ScrollingFrame", parent) giftListFrame.Size = UDim2.new(1, -20, 0, 280) giftListFrame.Position = UDim2.fromOffset(10, 145) giftListFrame.BackgroundColor3 = Colors.Surface giftListFrame.BorderSizePixel = 0 giftListFrame.ScrollBarThickness = 6 giftListFrame.ScrollBarImageColor3 = Colors.Gift Instance.new("UICorner", giftListFrame).CornerRadius = UDim.new(0, 12)
local giftListLayout = Instance.new("UIListLayout", giftListFrame) giftListLayout.Padding = UDim.new(0, 6) giftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local giftListPadding = Instance.new("UIPadding", giftListFrame) giftListPadding.PaddingTop = UDim.new(0, 6) giftListPadding.PaddingBottom = UDim.new(0, 6) giftListPadding.PaddingLeft = UDim.new(0, 6) giftListPadding.PaddingRight = UDim.new(0, 6)

-- Toggle connections
autoGiftToggle.switch.MouseButton1Click:Connect(function() 
    autoGift = not autoGift 
    EnabledFeatures["AutoGift"] = autoGift 
    if autoGift then 
        autoGiftToggle.switch.BackgroundColor3 = Colors.Gift 
        TweenService:Create(autoGiftToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play() 
    else 
        autoGiftToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
        TweenService:Create(autoGiftToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play() 
    end 
end)

notificationToggle.switch.MouseButton1Click:Connect(function() 
    giftNotifications = not giftNotifications 
    EnabledFeatures["GiftNotifications"] = giftNotifications 
    if giftNotifications then 
        notificationToggle.switch.BackgroundColor3 = Colors.Gift 
        TweenService:Create(notificationToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play() 
    else 
        notificationToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
        TweenService:Create(notificationToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play() 
    end 
end)

-- List functions
local function clearGiftList() for _, b in pairs(giftButtons) do b:Destroy() end table.clear(giftButtons) end
local function addGiftToList(g, n) 
    local btn = Instance.new("TextButton") 
    btn.Size = UDim2.new(1, -12, 0, 42) 
    btn.Text = "" 
    btn.BackgroundColor3 = Colors.Gift 
    btn.BorderSizePixel = 0 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10) 
    local ic = Instance.new("TextLabel", btn) ic.Size = UDim2.fromOffset(25, 25) ic.Position = UDim2.fromOffset(8, 8) ic.Text = "🎁" ic.TextSize = 18 ic.BackgroundTransparency = 1 
    local nm = Instance.new("TextLabel", btn) nm.Size = UDim2.new(1, -45, 0, 20) nm.Position = UDim2.fromOffset(38, 5) nm.Text = (Data.isSpanish and "Regalo " or "Gift ") .. n nm.TextColor3 = Colors.Text nm.BackgroundTransparency = 1 nm.Font = Enum.Font.GothamBold nm.TextSize = 12 nm.TextXAlignment = Enum.TextXAlignment.Left 
    local tp = Instance.new("TextLabel", btn) tp.Size = UDim2.new(1, -45, 0, 15) tp.Position = UDim2.fromOffset(38, 24) tp.Text = Texts.tapToGo tp.TextColor3 = Color3.fromRGB(230, 230, 230) tp.BackgroundTransparency = 1 tp.Font = Enum.Font.Gotham tp.TextSize = 10 tp.TextXAlignment = Enum.TextXAlignment.Left 
    btn.MouseButton1Click:Connect(function() teleportToGift(g) end) 
    btn.Parent = giftListFrame 
    table.insert(giftButtons, btn) 
end

local function checkForGifts()
    local found = {}
    for i = 1, 4 do
        local gn = "Gift" .. i
        for _, g in pairs(workspace:GetChildren()) do
            if g.Name == gn then
                local pos = g:IsA("BasePart") and g.Position or (g:IsA("Model") and g.PrimaryPart and g.PrimaryPart.Position)
                if pos and not isInLobbyZone(pos) then
                    local uniqueId = tostring(g)
                    if not found[uniqueId] then
                        found[uniqueId] = {obj = g, num = i}
                        if not knownGifts[uniqueId] then
                            knownGifts[uniqueId] = true
                            if giftNotifications then showGiftNotification(i, g) end
                            if autoGift then teleportToGift(g) end
                        end
                    end
                end
            end
        end
    end
    for id, _ in pairs(knownGifts) do
        local stillExists = false
        for _, data in pairs(found) do
            if tostring(data.obj) == id then stillExists = true break end
        end
        if not stillExists then knownGifts[id] = nil end
    end
    return found
end

-- Update list loop
task.spawn(function() 
    while Data.gui.Parent do 
        clearGiftList() 
        local gifts = checkForGifts() 
        local hasG = false 
        for _, data in pairs(gifts) do 
            hasG = true 
            addGiftToList(data.obj, data.num) 
        end 
        if not hasG then 
            local ng = Instance.new("TextLabel") 
            ng.Size = UDim2.new(1, -12, 0, 30) 
            ng.Text = Texts.noGifts 
            ng.TextColor3 = Colors.TextSecondary 
            ng.BackgroundTransparency = 1 
            ng.Font = Enum.Font.Gotham 
            ng.TextSize = 12 
            ng.Parent = giftListFrame 
            table.insert(giftButtons, ng) 
        end 
        task.wait(0.5) 
        giftListFrame.CanvasSize = UDim2.new(0, 0, 0, giftListLayout.AbsoluteContentSize.Y + 12) 
    end 
end)

return {
    teleportToGift = teleportToGift,
    showGiftNotification = showGiftNotification
}
