-- KIMIKO BETA - Modulo de Diamantes
-- diamonds.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local TweenService = Data.TweenService
local Colors = Data.Colors
local Texts = Data.Texts
local EnabledFeatures = Data.EnabledFeatures

local parent = Data.contentFrames.diamond
if not parent then return end

-- Variables
local collectedDiamonds = {}
local autoCollect = false
local diamondButtons = {}

-- Zona del lobby
local LOBBY_MIN = Vector3.new(math.min(882, 686), math.min(-4, 95), math.min(492, -232))
local LOBBY_MAX = Vector3.new(math.max(882, 686), math.max(-4, 95), math.max(492, -232))

local FAKE_DIAMONDS = {"CyberGiftDiamond", "RGBGiftDiamond", "FrostGiftDiamond", "HealthGiftDiamond", "ExpGiftDiamond", "MegaGiftDiamond", "ExplosionGiftDiamond"}

local function isInLobbyZone(pos)
    return pos.X >= LOBBY_MIN.X and pos.X <= LOBBY_MAX.X and
           pos.Y >= LOBBY_MIN.Y and pos.Y <= LOBBY_MAX.Y and
           pos.Z >= LOBBY_MIN.Z and pos.Z <= LOBBY_MAX.Z
end

local function isFakeDiamond(obj) 
    if not obj or not obj.Parent then return true end 
    for _, fake in pairs(FAKE_DIAMONDS) do 
        if obj.Name == fake or (obj.Parent and obj.Parent.Name == fake) then return true end 
    end 
    return false 
end

local function bringDiamond(obj)
    local hrp = Data.hrp
    if not obj or not obj.Parent or not hrp or not hrp.Parent then return end
    if isFakeDiamond(obj) then return end
    local id = tostring(obj)
    if collectedDiamonds[id] then return end
    collectedDiamonds[id] = true
    pcall(function()
        if obj:IsA("BasePart") then
            obj.CFrame = hrp.CFrame
        elseif obj:IsA("Model") and obj.PrimaryPart then
            obj:SetPrimaryPartCFrame(hrp.CFrame)
        end
    end)
    task.delay(1, function() collectedDiamonds[id] = nil end)
end

local function touchDiamond(part) 
    if not part or not part.Parent then return end 
    bringDiamond(part) 
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
local autoCollectToggle = createToggle(parent, Texts.autoCollect, UDim2.fromOffset(10, 15), autoCollect, Colors.Diamond)
local diamondListTitle = Instance.new("TextLabel", parent) diamondListTitle.Size = UDim2.new(1, -20, 0, 25) diamondListTitle.Position = UDim2.fromOffset(10, 65) diamondListTitle.Text = Texts.availableDiamonds diamondListTitle.TextColor3 = Colors.Text diamondListTitle.BackgroundTransparency = 1 diamondListTitle.Font = Enum.Font.GothamBold diamondListTitle.TextSize = 13 diamondListTitle.TextXAlignment = Enum.TextXAlignment.Left
local diamondListFrame = Instance.new("ScrollingFrame", parent) diamondListFrame.Size = UDim2.new(1, -20, 0, 350) diamondListFrame.Position = UDim2.fromOffset(10, 95) diamondListFrame.BackgroundColor3 = Colors.Surface diamondListFrame.BorderSizePixel = 0 diamondListFrame.ScrollBarThickness = 6 diamondListFrame.ScrollBarImageColor3 = Colors.Diamond Instance.new("UICorner", diamondListFrame).CornerRadius = UDim.new(0, 12)
local diamondListLayout = Instance.new("UIListLayout", diamondListFrame) diamondListLayout.Padding = UDim.new(0, 6) diamondListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local diamondListPadding = Instance.new("UIPadding", diamondListFrame) diamondListPadding.PaddingTop = UDim.new(0, 6) diamondListPadding.PaddingBottom = UDim.new(0, 6) diamondListPadding.PaddingLeft = UDim.new(0, 6) diamondListPadding.PaddingRight = UDim.new(0, 6)

-- Toggle connection
autoCollectToggle.switch.MouseButton1Click:Connect(function() 
    autoCollect = not autoCollect 
    EnabledFeatures["AutoCollect"] = autoCollect
    if autoCollect then 
        autoCollectToggle.switch.BackgroundColor3 = Colors.Diamond 
        TweenService:Create(autoCollectToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(30, 3)}):Play() 
    else 
        autoCollectToggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
        TweenService:Create(autoCollectToggle.knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(3, 3)}):Play() 
    end 
end)

-- List functions
local function clearDiamondList() for _, b in pairs(diamondButtons) do b:Destroy() end table.clear(diamondButtons) end
local function addDiamondToList(d) 
    local btn = Instance.new("TextButton") 
    btn.Size = UDim2.new(1, -12, 0, 38) 
    btn.Text = "Diamond" 
    btn.TextColor3 = Colors.Text 
    btn.BackgroundColor3 = Colors.Diamond 
    btn.BorderSizePixel = 0 
    btn.Font = Enum.Font.GothamBold 
    btn.TextSize = 13 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10) 
    btn.MouseButton1Click:Connect(function() touchDiamond(d) end) 
    btn.Parent = diamondListFrame 
    table.insert(diamondButtons, btn) 
end

-- Auto collect loop
task.spawn(function()
    while true do
        if autoCollect then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "Diamond" and not isInLobbyZone(obj.Position) and not isFakeDiamond(obj) then
                    task.spawn(function()
                        bringDiamond(obj)
                    end)
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Update list loop
task.spawn(function() 
    while Data.gui.Parent do 
        clearDiamondList() 
        for _, o in pairs(workspace:GetDescendants()) do 
            if o:IsA("BasePart") and o.Name == "Diamond" and not isInLobbyZone(o.Position) and not isFakeDiamond(o) then 
                addDiamondToList(o) 
            end 
        end 
        task.wait(1) 
        diamondListFrame.CanvasSize = UDim2.new(0, 0, 0, diamondListLayout.AbsoluteContentSize.Y + 12) 
    end 
end)

return {
    bringDiamond = bringDiamond,
    touchDiamond = touchDiamond
}
