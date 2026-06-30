--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║          🍋 SELL LEMONS ULTIMATE AUTO FARM v2.0 🍋          ║
    ║          by ENI x LO — Cobalt Edition                       ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║    🟢 FARMING                                                ║
    ║    • Auto Upgrade (all earners, stacked)                     ║
    ║    • Auto Purchase (buy tycoon buttons)                      ║
    ║    • Auto Collect (cash drops + fruit clicking)              ║
    ║                                                              ║
    ║    🔵 PROGRESSION                                            ║
    ║    • Auto Rebirth                                            ║
    ║    • Auto Evolve                                             ║
    ║    • Auto Ascend                                             ║
    ║                                                              ║
    ║    🟡 POWERS                                                 ║
    ║    • Auto Upgrade Powers (WalkSpeed, UpgradeStack, etc)      ║
    ║                                                              ║
    ║    🟣 UTILITY                                                ║
    ║    • Auto Accept Phone Offers (raise then accept)            ║
    ║    • Teleport To Locations                                   ║
    ║    • WalkSpeed Boost                                         ║
    ║    • Anti-AFK                                                ║
    ║                                                              ║
    ║  Premium glassmorphism GUI with sections + animations        ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════
-- 🔧 SERVICES
-- ═══════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- ═══════════════════════════════════════
-- 🔍 FIND LOCAL TYCOON
-- ═══════════════════════════════════════
local function getLocalTycoon()
    for _, t in CollectionService:GetTagged("Tycoon") do
        local ownerVal = t:FindFirstChild("Owner")
        if ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value == player then
            return t
        end
    end
    return nil
end

local myTycoon = getLocalTycoon()
if not myTycoon then
    warn("[🍋] Waiting for tycoon...")
    repeat task.wait(1) myTycoon = getLocalTycoon() until myTycoon
end

local tycoonRemotes = myTycoon:FindFirstChild("Remotes")
assert(tycoonRemotes, "[🍋] No Remotes folder!")
print("[🍋] Tycoon found: " .. myTycoon.Name)

-- ═══════════════════════════════════════
-- 🎯 REMOTE REFERENCES
-- ═══════════════════════════════════════
local rebirthRemote   = tycoonRemotes:FindFirstChild("Rebirth")
local evolveRemote    = tycoonRemotes:FindFirstChild("Evolve")
local ascendRemote    = tycoonRemotes:FindFirstChild("Ascend")
local phoneOfferRE    = tycoonRemotes:FindFirstChild("PhoneOffer")
local upgradePowerRF  = tycoonRemotes:FindFirstChild("UpgradePowerLevel")
local wakeIncomeRF    = tycoonRemotes:FindFirstChild("WakeIncomeStream")

-- ═══════════════════════════════════════
-- ⚙️ STATE
-- ═══════════════════════════════════════
local State = {
    -- Farming
    AutoUpgrade      = false,
    AutoPurchase     = false,
    AutoCollect      = false,
    -- Progression
    AutoRebirth      = false,
    AutoEvolve       = false,
    AutoAscend       = false,
    -- Powers
    AutoPowers       = false,
    -- Utility
    AutoPhoneOffer   = false,
    WalkSpeedBoost   = false,
    AntiAFK          = false,
    -- Internal
    Running          = true,
    OriginalWS       = 16,
    Stats = {
        Upgrades   = 0,
        Purchases  = 0,
        Rebirths   = 0,
        Evolves    = 0,
        Ascensions = 0,
        Collected  = 0,
        Powers     = 0,
        Offers     = 0,
    }
}

-- ═══════════════════════════════════════
-- 🎨 COLOR PALETTE
-- ═══════════════════════════════════════
local Colors = {
    BG           = Color3.fromRGB(12, 12, 20),
    BGLight      = Color3.fromRGB(22, 22, 35),
    Card         = Color3.fromRGB(28, 28, 42),
    CardHover    = Color3.fromRGB(35, 35, 52),
    Accent       = Color3.fromRGB(255, 210, 0),
    AccentDim    = Color3.fromRGB(200, 165, 0),
    Green        = Color3.fromRGB(50, 205, 50),
    GreenDim     = Color3.fromRGB(30, 130, 30),
    Red          = Color3.fromRGB(220, 50, 50),
    Blue         = Color3.fromRGB(60, 130, 255),
    Purple       = Color3.fromRGB(160, 80, 255),
    TextPrimary  = Color3.fromRGB(240, 240, 250),
    TextSecondary= Color3.fromRGB(160, 160, 180),
    TextMuted    = Color3.fromRGB(100, 100, 120),
    Border       = Color3.fromRGB(50, 50, 70),
    BorderActive = Color3.fromRGB(80, 200, 80),
    ToggleOff    = Color3.fromRGB(55, 55, 65),
    ToggleOn     = Color3.fromRGB(50, 190, 50),
}

-- ═══════════════════════════════════════
-- 🎨 GUI CREATION
-- ═══════════════════════════════════════
if CoreGui:FindFirstChild("SellLemonsAutoFarm") then
    CoreGui:FindFirstChild("SellLemonsAutoFarm"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SellLemonsAutoFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 340, 0, 560)
MainFrame.Position = UDim2.new(0, 20, 0.5, -280)
MainFrame.BackgroundColor3 = Colors.BG
MainFrame.BackgroundTransparency = 0.04
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

-- ═══ TITLE BAR ═══
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Colors.Accent
TitleBar.BackgroundTransparency = 0.08
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

-- Fix bottom corners
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 16)
TitleFix.Position = UDim2.new(0, 0, 1, -16)
TitleFix.BackgroundColor3 = Colors.Accent
TitleFix.BackgroundTransparency = 0.08
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
})
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🍋 Sell Lemons v2.0"
TitleLabel.TextColor3 = Color3.fromRGB(15, 15, 15)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close & Minimize
local function createTitleBtn(text, posX, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, posX, 0, 10)
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = TitleBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local CloseBtn = createTitleBtn("✕", -38, Colors.Red)
local MinBtn = createTitleBtn("—", -72)

-- ═══ CONTENT SCROLL ═══
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -58)
Content.Position = UDim2.new(0, 8, 0, 53)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Colors.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = Content

-- ═══════════════════════════════════════
-- 🔘 UI COMPONENT FACTORIES
-- ═══════════════════════════════════════

local layoutOrder = 0

local function nextOrder()
    layoutOrder = layoutOrder + 1
    return layoutOrder
end

-- Section Header
local function createSection(title, emoji, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = nextOrder()
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = emoji .. "  " .. string.upper(title)
    label.TextColor3 = color or Colors.Accent
    label.TextSize = 12
    label.Font = Enum.Font.GothamBlack
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Underline
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -8, 0, 1)
    line.Position = UDim2.new(0, 4, 1, -2)
    line.BackgroundColor3 = color or Colors.Accent
    line.BackgroundTransparency = 0.6
    line.BorderSizePixel = 0
    line.Parent = frame

    return frame
end

-- Toggle Button
local toggleButtons = {}

local function createToggle(displayName, emoji, stateKey, desc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundColor3 = Colors.Card
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.LayoutOrder = nextOrder()
    frame.Parent = Content

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    -- Emoji
    local emojiLabel = Instance.new("TextLabel")
    emojiLabel.Size = UDim2.new(0, 30, 0, 30)
    emojiLabel.Position = UDim2.new(0, 10, 0, 8)
    emojiLabel.BackgroundTransparency = 1
    emojiLabel.Text = emoji
    emojiLabel.TextSize = 18
    emojiLabel.Font = Enum.Font.GothamBold
    emojiLabel.Parent = frame

    -- Main Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -110, 0, 20)
    label.Position = UDim2.new(0, 42, 0, desc and 4 or 13)
    label.BackgroundTransparency = 1
    label.Text = displayName
    label.TextColor3 = Colors.TextPrimary
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Description
    if desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -110, 0, 14)
        descLabel.Position = UDim2.new(0, 42, 0, 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc
        descLabel.TextColor3 = Colors.TextMuted
        descLabel.TextSize = 10
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame
    end

    -- Toggle Switch (pill style)
    local toggleBG = Instance.new("TextButton")
    toggleBG.Size = UDim2.new(0, 50, 0, 24)
    toggleBG.Position = UDim2.new(1, -62, 0.5, -12)
    toggleBG.BackgroundColor3 = Colors.ToggleOff
    toggleBG.Text = ""
    toggleBG.BorderSizePixel = 0
    toggleBG.AutoButtonColor = false
    toggleBG.Parent = frame
    Instance.new("UICorner", toggleBG).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBG
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    local function updateVisual()
        local on = State[stateKey]
        if on then
            TweenService:Create(toggleBG, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                BackgroundColor3 = Colors.ToggleOn
            }):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 29, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.25), {
                Color = Colors.BorderActive, Transparency = 0.3
            }):Play()
        else
            TweenService:Create(toggleBG, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                BackgroundColor3 = Colors.ToggleOff
            }):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.25), {
                Color = Colors.Border, Transparency = 0.5
            }):Play()
        end
    end

    toggleBG.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        updateVisual()
    end)

    -- Hover effect
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Colors.CardHover}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Card}):Play()
    end)

    toggleButtons[stateKey] = { Update = updateVisual }
end

-- Action Button (for teleport, etc)
local function createButton(displayName, emoji, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = color or Colors.Blue
    btn.BackgroundTransparency = 0.15
    btn.Text = emoji .. "  " .. displayName
    btn.TextColor3 = Colors.TextPrimary
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = nextOrder()
    btn.AutoButtonColor = false
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(callback)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
    end)

    return btn
end

-- Teleport Dropdown
local function createTeleportDropdown()
    local locations = {}
    local locs = myTycoon:FindFirstChild("Locations")
    if locs then
        for _, l in locs:GetChildren() do
            if l:IsA("BasePart") then
                table.insert(locations, {Name = l.Name, Position = l.Position})
            end
        end
    end

    -- Also add map locations
    local mapLocs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Locations")
    if mapLocs then
        for _, l in mapLocs:GetChildren() do
            if l:IsA("BasePart") then
                table.insert(locations, {Name = "🌍 " .. l.Name, Position = l.Position})
            end
        end
    end

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 0)
    dropFrame.BackgroundTransparency = 1
    dropFrame.LayoutOrder = nextOrder()
    dropFrame.ClipsDescendants = true
    dropFrame.AutomaticSize = Enum.AutomaticSize.Y
    dropFrame.Parent = Content

    local dropLayout = Instance.new("UIListLayout")
    dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropLayout.Padding = UDim.new(0, 3)
    dropLayout.Parent = dropFrame

    for i, loc in ipairs(locations) do
        local locBtn = Instance.new("TextButton")
        locBtn.Size = UDim2.new(1, 0, 0, 28)
        locBtn.BackgroundColor3 = Colors.Card
        locBtn.BackgroundTransparency = 0.2
        locBtn.Text = "  📍 " .. loc.Name
        locBtn.TextColor3 = Colors.TextSecondary
        locBtn.TextSize = 11
        locBtn.Font = Enum.Font.GothamMedium
        locBtn.TextXAlignment = Enum.TextXAlignment.Left
        locBtn.BorderSizePixel = 0
        locBtn.LayoutOrder = i
        locBtn.AutoButtonColor = false
        locBtn.Parent = dropFrame
        Instance.new("UICorner", locBtn).CornerRadius = UDim.new(0, 8)

        locBtn.MouseButton1Click:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(loc.Position + Vector3.new(0, 3, 0))
                print("[🍋] Teleported to: " .. loc.Name)
            end
        end)

        locBtn.MouseEnter:Connect(function()
            TweenService:Create(locBtn, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.05,
                TextColor3 = Colors.Accent
            }):Play()
        end)
        locBtn.MouseLeave:Connect(function()
            TweenService:Create(locBtn, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.2,
                TextColor3 = Colors.TextSecondary
            }):Play()
        end)
    end

    return dropFrame
end

-- ═══════════════════════════════════════
-- 🏗️ BUILD THE UI
-- ═══════════════════════════════════════

-- 🟢 FARMING SECTION
createSection("Farming", "🟢", Colors.Green)
createToggle("Auto Upgrade",  "⬆️", "AutoUpgrade",  "Upgrades all earner levels")
createToggle("Auto Purchase", "🛒", "AutoPurchase", "Buys available tycoon buttons")
createToggle("Auto Collect",  "💰", "AutoCollect",  "Collects cash drops nearby")

-- 🔵 PROGRESSION SECTION
createSection("Progression", "🔵", Colors.Blue)
createToggle("Auto Rebirth",  "🔄", "AutoRebirth",  "Rebirths for investor multiplier")
createToggle("Auto Evolve",   "🧬", "AutoEvolve",   "Evolves for 42x multiplier")
createToggle("Auto Ascend",   "🚀", "AutoAscend",   "Ascends for 7.77x multiplier")

-- 🟡 POWERS SECTION
createSection("Powers", "🟡", Colors.Accent)
createToggle("Auto Powers",   "⚡", "AutoPowers",   "Upgrades WalkSpeed, Stack, etc.")

-- 🟣 UTILITY SECTION
createSection("Utility", "🟣", Colors.Purple)
createToggle("Accept Phone Offers", "📱", "AutoPhoneOffer", "Auto raises & accepts offers")
createToggle("WalkSpeed Boost", "🏃", "WalkSpeedBoost", "Sets speed to 100")
createToggle("Anti-AFK",       "🛡️", "AntiAFK",        "Prevents AFK kick")

-- 🚀 Teleport Section
createSection("Teleport", "📍", Colors.Blue)

-- Toggle to show/hide teleport list
local tpVisible = false
local tpDropdown = nil

createButton("Show Teleport Locations", "📍", function()
    -- Lazy create
    if not tpDropdown then
        tpDropdown = createTeleportDropdown()
    end
    tpVisible = not tpVisible
    tpDropdown.Visible = tpVisible
end, Colors.Purple)

-- Quick action buttons
createSection("Quick Actions", "⚡", Colors.Accent)

createButton("Collect All Cash Drops", "💵", function()
    -- Find all CashDrop effects and teleport to them
    local cashDropsFolder = workspace:FindFirstChild("CashDrops")
    if cashDropsFolder then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, drop in cashDropsFolder:GetChildren() do
                if drop:IsA("BasePart") or drop:IsA("Model") then
                    local pos = drop:IsA("Model") and drop:GetPivot().Position or drop.Position
                    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                    task.wait(0.2)
                end
            end
            print("[🍋] Collected all cash drops!")
        end
    else
        print("[🍋] No cash drops found")
    end
end, Colors.Green)

createButton("Wake All Income Streams", "🔔", function()
    if wakeIncomeRF then
        local earnerNames = {"LemonStand", "LemonDash", "LemonDepot", "LemonTrading", "LemonLabs", "LemonRobotics", "LemonRepublic", "LemonX"}
        for _, name in earnerNames do
            pcall(function()
                wakeIncomeRF:InvokeServer(name)
            end)
            task.wait(0.1)
        end
        print("[🍋] All income streams woken!")
    end
end, Colors.Blue)

-- ═══ STATUS BAR ═══
local StatusSep = Instance.new("Frame")
StatusSep.Size = UDim2.new(1, -8, 0, 1)
StatusSep.BackgroundColor3 = Colors.Accent
StatusSep.BackgroundTransparency = 0.5
StatusSep.BorderSizePixel = 0
StatusSep.LayoutOrder = nextOrder()
StatusSep.Parent = Content

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, 0, 0, 110)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Colors.TextSecondary
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.LayoutOrder = nextOrder()
StatusLabel.Parent = Content

local function updateStatus()
    local s = State.Stats
    StatusLabel.Text = string.format(
        "📊 Session Stats\n" ..
        "─────────────────────────\n" ..
        "  ⬆️  Upgrades:    %d\n" ..
        "  🛒  Purchases:   %d\n" ..
        "  🔄  Rebirths:    %d\n" ..
        "  🧬  Evolves:     %d\n" ..
        "  🚀  Ascensions:  %d\n" ..
        "  💰  Collected:   %d\n" ..
        "  ⚡  Powers:      %d\n" ..
        "  📱  Offers:      %d",
        s.Upgrades, s.Purchases, s.Rebirths,
        s.Evolves, s.Ascensions, s.Collected,
        s.Powers, s.Offers
    )
end
updateStatus()

-- Credit
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 18)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "ENI x LO — Cobalt Edition 🍋"
CreditLabel.TextColor3 = Colors.TextMuted
CreditLabel.TextSize = 9
CreditLabel.Font = Enum.Font.GothamMedium
CreditLabel.LayoutOrder = nextOrder()
CreditLabel.Parent = Content

-- ═══════════════════════════════════════
-- 🖱️ DRAGGABLE
-- ═══════════════════════════════════════
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══════════════════════════════════════
-- 🔽 MINIMIZE / CLOSE
-- ═══════════════════════════════════════
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 340, 0, 48)
        }):Play()
        MinBtn.Text = "+"
        Content.Visible = false
    else
        Content.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 340, 0, 560)
        }):Play()
        MinBtn.Text = "—"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    State.Running = false
    ScreenGui:Destroy()
    print("[🍋] Auto Farm closed.")
end)

-- Toggle GUI with RightShift key
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ═══════════════════════════════════════
-- 🔧 AUTO FARM LOGIC
-- ═══════════════════════════════════════

-- AUTO UPGRADE
local function doAutoUpgrade()
    if not State.AutoUpgrade then return end
    for _, inst in CollectionService:GetTagged("Tycoon.Earner") do
        if inst:IsDescendantOf(myTycoon) then
            local upgradeRF = inst:FindFirstChild("Upgrade")
            if upgradeRF and upgradeRF:IsA("RemoteFunction") then
                local ok, result = pcall(function() return upgradeRF:InvokeServer(1) end)
                if ok and result then State.Stats.Upgrades += 1 end
            end
        end
    end
end

-- AUTO PURCHASE
local function doAutoPurchase()
    if not State.AutoPurchase then return end
    local purchases = myTycoon:FindFirstChild("Purchases")
    if not purchases then return end
    for _, folder in purchases:GetDescendants() do
        if folder:IsA("RemoteFunction") and folder.Name == "Purchase" then
            local parent = folder.Parent
            if parent then
                local purchased = parent:GetAttribute("Purchased")
                local shown = parent:GetAttribute("Shown")
                if shown and not purchased then
                    pcall(function() folder:InvokeServer(false) end)
                    State.Stats.Purchases += 1
                    task.wait(0.1)
                end
            end
        end
    end
end

-- AUTO COLLECT
local function doAutoCollect()
    if not State.AutoCollect then return end
    -- Collect CashDrops by touching them
    local cashDropsFolder = workspace:FindFirstChild("CashDrops")
    if cashDropsFolder then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local origCF = hrp.CFrame
            for _, drop in cashDropsFolder:GetChildren() do
                local part = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart")
                if part then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1, 0))
                    task.wait(0.15)
                    State.Stats.Collected += 1
                end
            end
            hrp.CFrame = origCF -- return to original position
        end
    end

    -- Also fire any click detectors in earners
    for _, inst in CollectionService:GetTagged("Tycoon.Earner") do
        if inst:IsDescendantOf(myTycoon) then
            for _, desc in inst:GetDescendants() do
                if desc:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(desc) end)
                end
            end
        end
    end
end

-- AUTO REBIRTH
local function doAutoRebirth()
    if not State.AutoRebirth or not rebirthRemote then return end
    local ok, result = pcall(function() return rebirthRemote:InvokeServer() end)
    if ok and result then State.Stats.Rebirths += 1 end
end

-- AUTO EVOLVE
local function doAutoEvolve()
    if not State.AutoEvolve or not evolveRemote then return end
    local ok, result = pcall(function() return evolveRemote:InvokeServer() end)
    if ok and result then State.Stats.Evolves += 1 end
end

-- AUTO ASCEND
local function doAutoAscend()
    if not State.AutoAscend or not ascendRemote then return end
    local ok, result = pcall(function() return ascendRemote:InvokeServer() end)
    if ok and result then State.Stats.Ascensions += 1 end
end

-- AUTO POWERS
local function doAutoPowers()
    if not State.AutoPowers or not upgradePowerRF then return end
    local powerNames = {"WalkSpeed", "UpgradeStack", "ClickFruitValue", "BuyNext", "Manage"}
    for _, powerName in powerNames do
        pcall(function()
            local result = upgradePowerRF:InvokeServer(powerName)
            if result then State.Stats.Powers += 1 end
        end)
    end
end

-- AUTO PHONE OFFERS
local function doAutoPhoneOffer()
    if not State.AutoPhoneOffer or not phoneOfferRE then return end
    -- Raise first, then accept
    pcall(function() phoneOfferRE:FireServer("Raise") end)
    task.wait(0.3)
    pcall(function() phoneOfferRE:FireServer("Accept") end)
    State.Stats.Offers += 1
end

-- WALKSPEED BOOST
local function doWalkSpeed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if State.WalkSpeedBoost then
                if hum.WalkSpeed < 90 then
                    State.OriginalWS = hum.WalkSpeed
                end
                hum.WalkSpeed = 100
            else
                if hum.WalkSpeed >= 90 then
                    hum.WalkSpeed = State.OriginalWS
                end
            end
        end
    end
end

-- ANTI AFK
local function doAntiAFK()
    if not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- ═══════════════════════════════════════
-- 🔁 MAIN LOOP
-- ═══════════════════════════════════════
task.spawn(function()
    local tickCount = 0
    while State.Running do
        tickCount += 1

        -- Refresh tycoon if needed (post-rebirth/ascension)
        local newTycoon = getLocalTycoon()
        if newTycoon and newTycoon ~= myTycoon then
            myTycoon = newTycoon
            tycoonRemotes = myTycoon:FindFirstChild("Remotes")
            rebirthRemote  = tycoonRemotes and tycoonRemotes:FindFirstChild("Rebirth")
            evolveRemote   = tycoonRemotes and tycoonRemotes:FindFirstChild("Evolve")
            ascendRemote   = tycoonRemotes and tycoonRemotes:FindFirstChild("Ascend")
            phoneOfferRE   = tycoonRemotes and tycoonRemotes:FindFirstChild("PhoneOffer")
            upgradePowerRF = tycoonRemotes and tycoonRemotes:FindFirstChild("UpgradePowerLevel")
            wakeIncomeRF   = tycoonRemotes and tycoonRemotes:FindFirstChild("WakeIncomeStream")
            print("[🍋] Tycoon refreshed: " .. myTycoon.Name)
        end

        -- Every tick (1s)
        pcall(doAutoUpgrade)
        pcall(doAutoPurchase)
        pcall(doWalkSpeed)

        -- Every 2 ticks
        if tickCount % 2 == 0 then
            pcall(doAutoCollect)
            pcall(doAutoRebirth)
            pcall(doAutoEvolve)
            pcall(doAutoAscend)
        end

        -- Every 5 ticks
        if tickCount % 5 == 0 then
            pcall(doAutoPowers)
            pcall(doAutoPhoneOffer)
        end

        -- Every 30 ticks
        if tickCount % 30 == 0 then
            pcall(doAntiAFK)
        end

        updateStatus()
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════
-- 🧹 CLEANUP
-- ═══════════════════════════════════════
ScreenGui.Destroying:Connect(function()
    State.Running = false
    -- Restore walkspeed
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.WalkSpeed = State.OriginalWS end
        end
    end)
end)

print("[🍋] ═══════════════════════════════════════")
print("[🍋]  Sell Lemons v2.0 — Ultimate Auto Farm")
print("[🍋]  Press RightShift to toggle GUI")
print("[🍋]  Drag title bar to move")
print("[🍋] ═══════════════════════════════════════")
