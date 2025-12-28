-- KIMIKO BETA - Modulo de Diamantes (Mejorado)
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
local autoCollect = false
local diamondButtons = {}

-- Sistema mejorado de filtro de diamantes falsos (por CFrame)
local FakeCFrames = {
    CFrame.new(864.4, 16.6, 433.6),
    CFrame.new(868.2, 24.9, 429.0),
    CFrame.new(864.4, 16.6, 424.6),
    CFrame.new(817.4, 16.7, -173.3),
    CFrame.new(826.4, 16.7, -173.6),
}

local FAKE_DIAMONDS = {"CyberGiftDiamond", "RGBGiftDiamond", "FrostGiftDiamond", "HealthGiftDiamond", "ExpGiftDiamond", "MegaGiftDiamond", "ExplosionGiftDiamond"}

-- Verificar si es diamante falso por posicion
local function isFakeDiamond(pos)
    for _, cf in ipairs(FakeCFrames) do
        if (pos - cf.Position).Magnitude < 12 then
            return true
        end
    end
    return false
end

-- Verificar si es diamante falso por nombre
local function isFakeDiamondName(obj)
    if not obj or not obj.Parent then return true end
    for _, fake in pairs(FAKE_DIAMONDS) do
        if obj.Name == fake or (obj.Parent and obj.Parent.Name == fake) then return true end
    end
    return false
end

-- Obtener solo diamantes reales
local function getRealDiamonds()
    local diamonds = {}
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name == "Diamond" then
            local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
            if part and not isFakeDiamond(part.Position) and not isFakeDiamondName(part) then
                table.insert(diamonds, part)
            end
        end
    end
    return diamonds
end

-- Funcion touch mejorada usando firetouchinterest
local function touch(part)
    local hrp = Data.hrp
    if not hrp or not part then return end
    pcall(function()
        firetouchinterest(hrp, part, 0)
        task.wait()
        firetouchinterest(hrp, part, 1)
    end)
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
    btn.MouseButton1Click:Connect(function()
        local hrp = Data.hrp
        if hrp and d then
            pcall(function()
                d.CFrame = hrp.CFrame
                touch(d)
            end)
        end
    end)
    btn.Parent = diamondListFrame
    table.insert(diamondButtons, btn)
end

-- Auto collect loop mejorado con firetouchinterest
task.spawn(function()
    while task.wait(0.12) do
        if autoCollect then
            local hrp = Data.hrp
            if hrp then
                for _, d in ipairs(getRealDiamonds()) do
                    pcall(function()
                        d.CFrame = hrp.CFrame
                        touch(d)
                    end)
                end
            end
        end
    end
end)

-- Update list loop
task.spawn(function()
    while Data.gui.Parent do
        clearDiamondList()
        for _, d in ipairs(getRealDiamonds()) do
            addDiamondToList(d)
        end
        task.wait(1)
        diamondListFrame.CanvasSize = UDim2.new(0, 0, 0, diamondListLayout.AbsoluteContentSize.Y + 12)
    end
end)

return {
    getRealDiamonds = getRealDiamonds,
    touch = touch
}
