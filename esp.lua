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

-- Obtener Diamonds del jugador
local function getDiamonds(player)
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local d = ls:FindFirstChild("Diamonds") or ls:FindFirstChild("diamonds")
        if d and d:IsA("NumberValue") or d:IsA("IntValue") then
            return d.Value
        end
    end
    local d2 = player:FindFirstChild("Diamonds")
    if d2 and (d2:IsA("NumberValue") or d2:IsA("IntValue")) then
        return d2.Value
    end
    return 0
end

-- ESP Functions
local function removeESPForPlayer(player)
    local d = espObjects[player]
    if not d then return end
    if d.billboard then d.billboard:Destroy() end
    if d.highlight then d.highlight:Destroy() end
    if d.tracer then d.tracer:Destroy() end
    if d.conn then d.conn:Disconnect() end
    espObjects[player] = nil
end

local function createESPForPlayer(player)
    if player == LocalPlayer or espObjects[player] then return end
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not (humanoid and rootPart and head) then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "KimikoESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 120)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = 1000
    bb.Parent = character

    local fr = Instance.new("Frame", bb)
    fr.Size = UDim2.new(1, 0, 1, 0)
    fr.BackgroundTransparency = 1

    local nm = Instance.new("TextLabel", fr)
    nm.Size = UDim2.new(1, 0, 0, 20)
    nm.BackgroundTransparency = 1
    nm.Text = player.DisplayName
    nm.TextColor3 = espColor
    nm.TextStrokeTransparency = 0.3
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 14

    local un = Instance.new("TextLabel", fr)
    un.Size = UDim2.new(1, 0, 0, 14)
    un.Position = UDim2.fromOffset(0, 18)
    un.BackgroundTransparency = 1
    un.Text = "@" .. player.Name
    un.TextColor3 = Colors.TextSecondary
    un.TextStrokeTransparency = 0.3
    un.Font = Enum.Font.Gotham
    un.TextSize = 10

    local hbg = Instance.new("Frame", fr)
    hbg.Size = UDim2.new(0.8, 0, 0, 6)
    hbg.Position = UDim2.new(0.1, 0, 0, 38)
    hbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hbg.BorderSizePixel = 0
    Instance.new("UICorner", hbg).CornerRadius = UDim.new(1, 0)

    local hbf = Instance.new("Frame", hbg)
    hbf.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
    hbf.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hbf.BorderSizePixel = 0
    Instance.new("UICorner", hbf).CornerRadius = UDim.new(1, 0)

    local hl = Instance.new("TextLabel", fr)
    hl.Size = UDim2.new(1, 0, 0, 14)
    hl.Position = UDim2.fromOffset(0, 46)
    hl.BackgroundTransparency = 1
    hl.TextColor3 = Colors.Text
    hl.TextStrokeTransparency = 0.3
    hl.Font = Enum.Font.Gotham
    hl.TextSize = 11

    local dl = Instance.new("TextLabel", fr)
    dl.Size = UDim2.new(1, 0, 0, 14)
    dl.Position = UDim2.fromOffset(0, 62)
    dl.BackgroundTransparency = 1
    dl.TextColor3 = Colors.TextSecondary
    dl.TextStrokeTransparency = 0.3
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 11

    -- 🔥 DIAMONDS
    local dia = Instance.new("TextLabel", fr)
    dia.Size = UDim2.new(1, 0, 0, 14)
    dia.Position = UDim2.fromOffset(0, 78)
    dia.BackgroundTransparency = 1
    dia.TextColor3 = Color3.fromRGB(0, 255, 255)
    dia.TextStrokeTransparency = 0.3
    dia.Font = Enum.Font.GothamBold
    dia.TextSize = 11

    local hi = Instance.new("Highlight")
    hi.Adornee = character
    hi.FillColor = espColor
    hi.OutlineColor = espColor
    hi.FillTransparency = 0.7
    hi.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hi.Parent = character

    local tr = Instance.new("Part")
    tr.Anchored = true
    tr.CanCollide = false
    tr.Transparency = 0.5
    tr.Material = Enum.Material.Neon
    tr.Color = espColor
    tr.Parent = workspace

    local hrp = Data.hrp
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not player.Parent or humanoid.Health <= 0 then
            conn:Disconnect()
            removeESPForPlayer(player)
            return
        end

        hl.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        dl.Text = Texts.dist .. ": " .. math.floor((rootPart.Position - hrp.Position).Magnitude) .. " " .. Texts.studs
        dia.Text = "💎 Diamonds: " .. tostring(getDiamonds(player))

        local p = humanoid.Health / humanoid.MaxHealth
        hbf.Size = UDim2.new(p, 0, 1, 0)

        if EnabledFeatures["ShowTracers"] then
            local d = (rootPart.Position - hrp.Position).Magnitude
            tr.Size = Vector3.new(0.2, 0.2, d)
            tr.CFrame = CFrame.new((hrp.Position + rootPart.Position) / 2, rootPart.Position)
            tr.Parent = workspace
        else
            tr.Parent = nil
        end

        nm.Visible = EnabledFeatures["ShowName"]
        un.Visible = EnabledFeatures["ShowName"]
        hl.Visible = EnabledFeatures["ShowHealth"]
        hbg.Visible = EnabledFeatures["ShowHealth"]
        dl.Visible = EnabledFeatures["ShowDistance"]
        hi.Enabled = EnabledFeatures["ShowBox"]
        dia.Visible = true
    end)

    espObjects[player] = {
        billboard = bb,
        highlight = hi,
        tracer = tr,
        conn = conn
    }
end

-- RESTO DEL SCRIPT IGUAL (NO MODIFICADO)
