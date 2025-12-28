-- KIMIKO BETA - Modulo Sticky (Pegajoso)
-- sticky.lua

local Data = _G.KimikoData
local Players = Data.Players
local LocalPlayer = Data.LocalPlayer
local TweenService = Data.TweenService
local RunService = Data.RunService
local UIS = Data.UIS
local Colors = Data.Colors
local Texts = Data.Texts

local parent = Data.contentFrames.sticky
if not parent then return end

-- Variables
local selectedPlayer = nil
local currentStickyMode = nil
local followConn = nil
local stickyDistance = 2
local persistentMode = nil
local persistentTarget = nil
local originalAnimator = nil
local stickyPlayerButtons = {}

-- Funciones auxiliares
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
    if originalAnimator and not h:FindFirstChildOfClass("Animator") then originalAnimator:Clone().Parent = h end 
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

-- UI Helpers
local function createSlider(parentFrame, label, val, minV, maxV, pos, color)
    local c = Instance.new("Frame", parentFrame) c.Size = UDim2.new(1, -20, 0, 65) c.Position = pos c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c) l.Size = UDim2.new(1, 0, 0, 22) l.BackgroundTransparency = 1 l.Text = label .. ": " .. tostring(math.floor(val)) .. " studs" l.TextColor3 = Colors.Text l.Font = Enum.Font.GothamSemibold l.TextSize = 14 l.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("Frame", c) bg.Size = UDim2.new(1, 0, 0, 30) bg.Position = UDim2.fromOffset(0, 30) bg.BackgroundColor3 = Color3.fromRGB(40, 40, 55) bg.BorderSizePixel = 0 Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local fl = Instance.new("Frame", bg) fl.Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0) fl.BackgroundColor3 = color fl.BorderSizePixel = 0 Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 10)
    local btn = Instance.new("TextButton", bg) btn.Size = UDim2.new(1, 0, 1, 0) btn.Text = "" btn.BackgroundTransparency = 1
    return {container = c, label = l, bg = bg, fill = fl, button = btn, minVal = minV, maxVal = maxV, value = val}
end

-- Crear UI
local stickyTitle = Instance.new("TextLabel", parent) stickyTitle.Size = UDim2.new(1, -20, 0, 25) stickyTitle.Position = UDim2.fromOffset(10, 10) stickyTitle.Text = Texts.stickyMode stickyTitle.TextColor3 = Colors.Text stickyTitle.BackgroundTransparency = 1 stickyTitle.Font = Enum.Font.GothamBold stickyTitle.TextSize = 14 stickyTitle.TextXAlignment = Enum.TextXAlignment.Left

local stickyModeButtons = {} 
local stickyModeNames = {Texts.free, Texts.lock}
for i, name in ipairs(stickyModeNames) do
    local btn = Instance.new("TextButton", parent) 
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
            for _, b in pairs(stickyModeButtons) do b.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end 
            btn.BackgroundColor3 = Colors.Success 
            setStickyMode(name) 
        end 
    end)
    stickyModeButtons[i] = btn
end

local distanceSlider = createSlider(parent, Texts.distance, stickyDistance, 1, 10, UDim2.fromOffset(10, 80), Colors.Sticky)
local stickyPlayerTitle = Instance.new("TextLabel", parent) stickyPlayerTitle.Size = UDim2.new(1, -20, 0, 25) stickyPlayerTitle.Position = UDim2.fromOffset(10, 155) stickyPlayerTitle.Text = Texts.selectPlayer stickyPlayerTitle.TextColor3 = Colors.Text stickyPlayerTitle.BackgroundTransparency = 1 stickyPlayerTitle.Font = Enum.Font.GothamBold stickyPlayerTitle.TextSize = 13 stickyPlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
local stickyPlayerList = Instance.new("ScrollingFrame", parent) stickyPlayerList.Size = UDim2.new(1, -20, 0, 200) stickyPlayerList.Position = UDim2.fromOffset(10, 185) stickyPlayerList.BackgroundColor3 = Colors.Surface stickyPlayerList.BorderSizePixel = 0 stickyPlayerList.ScrollBarThickness = 6 stickyPlayerList.ScrollBarImageColor3 = Colors.Sticky Instance.new("UICorner", stickyPlayerList).CornerRadius = UDim.new(0, 12)
local stickyPlayerLayout = Instance.new("UIListLayout", stickyPlayerList) stickyPlayerLayout.Padding = UDim.new(0, 6) stickyPlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder
local stickyPlayerPadding = Instance.new("UIPadding", stickyPlayerList) stickyPlayerPadding.PaddingTop = UDim.new(0, 6) stickyPlayerPadding.PaddingBottom = UDim.new(0, 6) stickyPlayerPadding.PaddingLeft = UDim.new(0, 6) stickyPlayerPadding.PaddingRight = UDim.new(0, 6)

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

setupSlider(distanceSlider, function(val, pct) 
    distanceSlider.label.Text = Texts.distance .. ": " .. tostring(math.floor(val)) .. " studs" 
    stickyDistance = math.floor(val) 
end)

-- Player list update
local function updateStickyPlayerList()
    for _, b in pairs(stickyPlayerButtons) do b:Destroy() end
    table.clear(stickyPlayerButtons)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Container frame for player info
            local container = Instance.new("Frame") 
            container.Size = UDim2.new(1, -12, 0, 50) 
            container.BackgroundColor3 = (selectedPlayer == player) and Colors.Success or Color3.fromRGB(50, 50, 65) 
            container.BorderSizePixel = 0 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            
            -- Player thumbnail
            local thumbnail = Instance.new("ImageLabel", container)
            thumbnail.Size = UDim2.new(0, 40, 0, 40)
            thumbnail.Position = UDim2.fromOffset(5, 5)
            thumbnail.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            thumbnail.BorderSizePixel = 0
            Instance.new("UICorner", thumbnail).CornerRadius = UDim.new(0, 20)
            
            -- Load player avatar
            local success, thumbId = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if success then
                thumbnail.Image = thumbId
            end
            
            -- Display name (nickname)
            local displayNameLabel = Instance.new("TextLabel", container)
            displayNameLabel.Size = UDim2.new(1, -60, 0, 22)
            displayNameLabel.Position = UDim2.fromOffset(52, 5)
            displayNameLabel.Text = player.DisplayName
            displayNameLabel.TextColor3 = Colors.Text
            displayNameLabel.BackgroundTransparency = 1
            displayNameLabel.Font = Enum.Font.GothamBold
            displayNameLabel.TextSize = 13
            displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            displayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Username (search name)
            local usernameLabel = Instance.new("TextLabel", container)
            usernameLabel.Size = UDim2.new(1, -60, 0, 18)
            usernameLabel.Position = UDim2.fromOffset(52, 26)
            usernameLabel.Text = "@" .. player.Name
            usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
            usernameLabel.BackgroundTransparency = 1
            usernameLabel.Font = Enum.Font.Gotham
            usernameLabel.TextSize = 11
            usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
            usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Invisible button overlay for click detection
            local btn = Instance.new("TextButton", container)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            
            btn.MouseButton1Click:Connect(function() 
                selectedPlayer = player 
                persistentTarget = player 
                for _, b2 in pairs(stickyPlayerButtons) do b2.BackgroundColor3 = Color3.fromRGB(50, 50, 65) end 
                container.BackgroundColor3 = Colors.Success 
                if currentStickyMode then setStickyMode(currentStickyMode) end 
            end)
            
            container.Parent = stickyPlayerList 
            table.insert(stickyPlayerButtons, container)
        end
    end
    stickyPlayerList.CanvasSize = UDim2.new(0, 0, 0, stickyPlayerLayout.AbsoluteContentSize.Y + 12)
end

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function()
    if persistentMode and persistentTarget and persistentTarget.Parent then 
        selectedPlayer = persistentTarget 
        task.wait(0.5) 
        setStickyMode(persistentMode) 
    end
end)

return {
    updatePlayerList = updateStickyPlayerList,
    setStickyMode = setStickyMode,
    stopFollowing = stopFollowing
}
