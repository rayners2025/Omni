    local UIS = game:GetService("UserInputService")
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local SoundService = game:GetService("SoundService")
    local HttpService = game:GetService("HttpService")
    local Lighting = game:GetService("Lighting")
    local Random = Random.new() 
    local CLICK_SOUND_PRESETS = {
        { name = "AWP", id = "2753888131" },
        { name = "Bonk", id = "140110603417819" },
        { name = "Bow", id = "135482046225041" },
        { name = "Deagle", id = "18302188791" },
        { name = "G3SG1", id = "18512294165" },
        { name = "M4A1 Suppressed", id = "8922741062" },
        { name = "MK23-S", id = "6117082165" },
        { name = "MSR", id = "2546411325" },
        { name = "R8 Revolver", id = "18302097184" },
        { name = "SCAR-20", id = "9151093313450" },
        { name = "SPAS-12", id = "6163224960" },
        { name = "Scout", id = "24765717379" },
    }
    local customClickSounds = {}
    local refreshClickSoundMenu
    local UI_CLICK_SOUND_ID = "rbxassetid://8922741062"
    local uiClickSoundsEnabled = true
    local uiClickSound = Instance.new("Sound")
    uiClickSound.Name = "OmniUIClick"
    uiClickSound.SoundId = UI_CLICK_SOUND_ID
    uiClickSound.Volume = 0.22
    uiClickSound.Parent = SoundService

    local function playUIClickSound(volume)
        if not uiClickSoundsEnabled then return end
        if uiClickSound.SoundId ~= UI_CLICK_SOUND_ID then
            uiClickSound.SoundId = UI_CLICK_SOUND_ID
        end
        uiClickSound.Volume = volume or 0.22
        uiClickSound.TimePosition = 0
        uiClickSound:Play()
    end

    local MENU_SONGS = {
        { name = "Hardtekk 1", id = "rbxassetid://128715303988843" },
        { name = "Hardtekk 2", id = "rbxassetid://78625674962793" },
        { name = "Hardtekk 3", id = "rbxassetid://88462099891108" },
        { name = "Hardtekk 4", id = "rbxassetid://78478068056253" },
    }
    local selectedSongIndex = 1
    local menuMusicEnabled = true
    local menuMusicOnlyWithUI = true
    local menuMusicPausedByToggle = false
    local menuMusic = Instance.new("Sound")
    menuMusic.Name = "OmniMenuMusic"
    menuMusic.SoundId = MENU_SONGS[selectedSongIndex].id
    menuMusic.Volume = 0.4
    menuMusic.Looped = true
    menuMusic.Parent = SoundService

    local animationBlur = Instance.new("BlurEffect")
    animationBlur.Name = "OmniAnimationBlur"
    animationBlur.Size = 14
    animationBlur.Enabled = false
    animationBlur.Parent = Lighting

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MainUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 10000
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    local HudGui = Instance.new("ScreenGui")
    HudGui.Name = "OmniHUD"
    HudGui.ResetOnSpawn = false
    HudGui.IgnoreGuiInset = true
    HudGui.DisplayOrder = 10001
    HudGui.Parent = Player:WaitForChild("PlayerGui")

    local espGui = nil

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")

    local reportState = { count = 0, known = false, alerts = false }

    local reportDing = Instance.new("Sound")
    reportDing.Name = "OmniReportDing"
    reportDing.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    reportDing.Volume = 0.55
    reportDing.PlaybackSpeed = 1.1
    reportDing.Parent = SoundService

    local reportDingHigh = reportDing:Clone()
    reportDingHigh.Name = "OmniReportDingHigh"
    reportDingHigh.Volume = 0.4
    reportDingHigh.PlaybackSpeed = 1.55
    reportDingHigh.Parent = SoundService

    local reportPopup = Instance.new("Frame")
    reportPopup.Name = "OmniReportPopup"
    reportPopup.Parent = HudGui
    reportPopup.AnchorPoint = Vector2.new(0.5, 0)
    reportPopup.Position = UDim2.new(0.5, 0, 0, 46)
    reportPopup.Size = UDim2.fromOffset(340, 56)
    reportPopup.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    reportPopup.BackgroundTransparency = 0.05
    reportPopup.BorderSizePixel = 0
    reportPopup.Visible = false
    reportPopup.ZIndex = 20

    local reportPopupCorner = Instance.new("UICorner")
    reportPopupCorner.CornerRadius = UDim.new(0, 8)
    reportPopupCorner.Parent = reportPopup

    local reportPopupStroke = Instance.new("UIStroke")
    reportPopupStroke.Parent = reportPopup
    reportPopupStroke.Color = Color3.fromRGB(255, 64, 72)
    reportPopupStroke.Thickness = 1.5

    local reportPopupTitle = Instance.new("TextLabel")
    reportPopupTitle.Parent = reportPopup
    reportPopupTitle.Position = UDim2.fromOffset(0, 7)
    reportPopupTitle.Size = UDim2.new(1, 0, 0, 18)
    reportPopupTitle.BackgroundTransparency = 1
    reportPopupTitle.Text = "YOU HAVE BEEN REPORTED"
    reportPopupTitle.TextColor3 = Color3.fromRGB(255, 96, 104)
    reportPopupTitle.Font = Enum.Font.GothamBold
    reportPopupTitle.TextSize = 13
    reportPopupTitle.ZIndex = 21

    local reportPopupBody = Instance.new("TextLabel")
    reportPopupBody.Parent = reportPopup
    reportPopupBody.Position = UDim2.fromOffset(0, 27)
    reportPopupBody.Size = UDim2.new(1, 0, 0, 20)
    reportPopupBody.BackgroundTransparency = 1
    reportPopupBody.Text = "+1 new report  |  1 total"
    reportPopupBody.TextColor3 = Color3.fromRGB(238, 238, 246)
    reportPopupBody.Font = Enum.Font.Code
    reportPopupBody.TextSize = 12
    reportPopupBody.ZIndex = 21

    local reportCounterLabel = Instance.new("TextLabel")
    reportCounterLabel.Name = "OmniReportCounter"
    reportCounterLabel.Parent = HudGui
    reportCounterLabel.Position = UDim2.new(0, 16, 1, -46)
    reportCounterLabel.Size = UDim2.fromOffset(150, 28)
    reportCounterLabel.BackgroundColor3 = Color3.fromRGB(22, 8, 12)
    reportCounterLabel.BackgroundTransparency = 0.1
    reportCounterLabel.BorderSizePixel = 0
    reportCounterLabel.Text = "REPORTS: 0"
    reportCounterLabel.TextColor3 = Color3.fromRGB(255, 80, 90)
    reportCounterLabel.Font = Enum.Font.Code
    reportCounterLabel.TextSize = 12
    reportCounterLabel.Visible = false
    reportCounterLabel.ZIndex = 20

    local reportCounterCorner = Instance.new("UICorner")
    reportCounterCorner.CornerRadius = UDim.new(0, 6)
    reportCounterCorner.Parent = reportCounterLabel

    local reportCounterStroke = Instance.new("UIStroke")
    reportCounterStroke.Parent = reportCounterLabel
    reportCounterStroke.Color = Color3.fromRGB(255, 64, 72)
    reportCounterStroke.Thickness = 1

    local reportPopupToken = 0

    local function playReportDing()
        pcall(function()
            reportDing.TimePosition = 0
            reportDing:Play()
        end)
        task.delay(0.16, function()
            pcall(function()
                reportDingHigh.TimePosition = 0
                reportDingHigh:Play()
            end)
        end)
    end

    local function showReportPopup(delta, total)
        reportPopupToken = reportPopupToken + 1
        local token = reportPopupToken
        reportPopupBody.Text = string.format("+%d new report%s  |  %d total", delta, delta == 1 and "" or "s", total)
        reportPopup.Visible = true
        reportPopup.BackgroundTransparency = 0.05
        reportPopupStroke.Transparency = 0
        reportPopupTitle.TextTransparency = 0
        reportPopupBody.TextTransparency = 0
        task.delay(4.2, function()
            if token ~= reportPopupToken then
                return
            end
            pcall(function()
                TweenService:Create(reportPopup, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(reportPopupStroke, TweenInfo.new(0.4), { Transparency = 1 }):Play()
                TweenService:Create(reportPopupTitle, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
                TweenService:Create(reportPopupBody, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
            end)
            task.delay(0.45, function()
                if token == reportPopupToken then
                    reportPopup.Visible = false
                end
            end)
        end)
    end

    local function readReportCount()
        local count = 0
        local reports
        pcall(function()
            local playersFolder = ReplicatedStorage:FindFirstChild("Players")
            local myData = playersFolder and playersFolder:FindFirstChild(Player.Name)
            local status = myData and myData:FindFirstChild("Status")
            local uac = status and status:FindFirstChild("UAC")
            reports = uac and uac:FindFirstChild("Reports")
        end)
        if not reports then
            return 0
        end
        pcall(function()
            local total = reports:GetAttribute("Count")
            if type(total) == "number" then
                count = total
            else
                for _, value in pairs(reports:GetAttributes()) do
                    if type(value) == "number" then
                        count = count + value
                    end
                end
            end
        end)
        return math.max(0, math.floor(count))
    end

    task.spawn(function()
        local known = false
        while HudGui.Parent do
            local current = readReportCount()
            if known and current > reportState.count and reportState.alerts then
                local delta = current - reportState.count
                showReportPopup(delta, current)
                playReportDing()
            end
            reportState.count = current
            reportState.known = true
            known = true
            reportCounterLabel.Visible = reportState.alerts
            if reportState.alerts then
                reportCounterLabel.Text = "REPORTS: " .. tostring(current)
            end
            task.wait(0.5)
        end
    end)

    local hideChatName = false
    local chatOriginalText = setmetatable({}, { __mode = "k" })

    local function findChatWindows()
        local windows = {}
        local playerGui = Player:FindFirstChildOfClass("PlayerGui")
        if not playerGui then
            return windows
        end
        local function scan(instance, depth)
            if depth > 8 then
                return
            end
            for _, child in ipairs(instance:GetChildren()) do
                if child.Name == "ChatWindow" then
                    table.insert(windows, child)
                elseif child:IsA("GuiObject") or child:IsA("ScreenGui") or child:IsA("Folder") then
                    scan(child, depth + 1)
                end
            end
        end
        scan(playerGui, 0)
        return windows
    end

    local function scrubChatWindow()
        local names = { Player.Name }
        if Player.DisplayName ~= Player.Name then
            table.insert(names, Player.DisplayName)
        end
        local windows = findChatWindows()
        for windowIndex = 1, #windows do
            local window = windows[windowIndex]
            for _, line in ipairs(window:GetChildren()) do
                local message = line:IsA("TextLabel") and line:FindFirstChild("Message")
                if message and message:IsA("TextLabel") then
                    local original = chatOriginalText[message]
                    if hideChatName then
                        if original and message.Text ~= original and not string.find(message.Text, "Hidden", 1, true) then
                            original = nil
                            chatOriginalText[message] = nil
                        end
                        if not original then
                            chatOriginalText[message] = message.Text
                            original = message.Text
                        end
                        local replaced = original
                        for nameIndex = 1, #names do
                            local pattern = names[nameIndex]:gsub("%p", "%%%0")
                            replaced = string.gsub(replaced, pattern, "Hidden")
                        end
                        if replaced ~= message.Text then
                            message.Text = replaced
                        end
                    elseif original then
                        message.Text = original
                        chatOriginalText[message] = nil
                    end
                end
            end
        end
    end

    task.spawn(function()
        while HudGui.Parent do
            pcall(scrubChatWindow)
            task.wait(0.5)
        end
    end)

    if type(setfpscap) == "function" then pcall(setfpscap, 240) end

    local uiAccentColor = Color3.fromRGB(0, 255, 0)
    local accentStrokes = {}
    local accentGradients = {}
    local function bindAccent(stroke)
        stroke.Color = uiAccentColor
        table.insert(accentStrokes, stroke)
    end
    local function bindAccentGradient(gradient)
        gradient.Color = ColorSequence.new(uiAccentColor, Color3.fromRGB(223, 57, 137))
        table.insert(accentGradients, gradient)
    end
    local function setUIAccent(color)
        uiAccentColor = color
        for index = #accentStrokes, 1, -1 do
            local stroke = accentStrokes[index]
            if stroke.Parent then stroke.Color = color else table.remove(accentStrokes, index) end
        end
        for index = #accentGradients, 1, -1 do
            local gradient = accentGradients[index]
            if gradient.Parent then
                gradient.Color = ColorSequence.new(color, Color3.fromRGB(223, 57, 137))
            else
                table.remove(accentGradients, index)
            end
        end
    end


    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 10, 0.5, -4)
    Main.Size = UDim2.fromOffset(600, 800)
    Main.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    Main.ZIndex = 1
    Main.BorderSizePixel = 0

    local uiScale = Instance.new("UIScale")
    uiScale.Name = "OmniScale"
    uiScale.Parent = Main

    local function refreshUIScale()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local fit = math.min(viewport.X / 640, viewport.Y / 880)
        uiScale.Scale = math.clamp(fit, 0.6, 1)
    end
    refreshUIScale()

    local function clampToViewport(frame)
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local size = frame.AbsoluteSize
        local position = frame.AbsolutePosition
        local targetX = math.clamp(position.X, 48 - size.X, viewport.X - 48)
        local targetY = math.clamp(position.Y, 0, viewport.Y - 48)
        if targetX ~= position.X then
            frame.Position = UDim2.new(
                frame.Position.X.Scale + (targetX - position.X) / math.max(viewport.X, 1),
                frame.Position.X.Offset,
                frame.Position.Y.Scale,
                frame.Position.Y.Offset
            )
        end
        if targetY ~= position.Y then
            frame.Position = UDim2.new(
                frame.Position.X.Scale,
                frame.Position.X.Offset,
                frame.Position.Y.Scale + (targetY - position.Y) / math.max(viewport.Y, 1),
                frame.Position.Y.Offset
            )
        end
    end

    local SnowLayer = Instance.new("Frame")
    SnowLayer.Name = "SnowLayer"
    SnowLayer.Size = UDim2.fromScale(1, 1)
    SnowLayer.BackgroundTransparency = 1
    SnowLayer.BorderSizePixel = 0
    SnowLayer.ClipsDescendants = true
    SnowLayer.ZIndex = 2
    SnowLayer.Active = false
    SnowLayer.Parent = ScreenGui

    local snowflakes = {}
    for i = 1, 70 do
        local flake = Instance.new("Frame")
        flake.Name = "Snowflake"
        flake.Parent = SnowLayer
        flake.AnchorPoint = Vector2.new(0.5, 0.5)
        local size = Random:NextInteger(2, 5)
        flake.Size = UDim2.fromOffset(size, size)
        flake.Position = UDim2.fromScale(Random:NextNumber(), Random:NextNumber())
        flake.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        flake.BackgroundTransparency = Random:NextNumber(0.85, 0.95)
        flake.BorderSizePixel = 0
        flake.ZIndex = 60
        local round = Instance.new("UICorner")
        round.CornerRadius = UDim.new(1, 0)
        round.Parent = flake
        snowflakes[i] = { frame = flake, speed = Random:NextNumber(0.12, 0.35), drift = Random:NextNumber(-0.08, 0.08) }
    end
    local effectsEnabled = false
    local menuOpen = true
    local function updateMenuMusic()
        local menuVisible = menuOpen and ScreenGui.Enabled and ScreenGui.Parent ~= nil and Main.Visible
        local shouldPlay = menuMusicEnabled and (not menuMusicOnlyWithUI or menuVisible) and menuMusic.SoundId ~= ""
        if shouldPlay then
            if menuMusicPausedByToggle then
                menuMusic:Resume()
                menuMusicPausedByToggle = false
            elseif not menuMusic.IsPlaying then
                menuMusic:Play()
            end
        elseif menuMusic.IsPlaying then
            menuMusic:Pause()
            menuMusicPausedByToggle = true
        end
    end
    ScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        menuOpen = ScreenGui.Enabled
        updateMenuMusic()
    end)
    Main:GetPropertyChangedSignal("Visible"):Connect(updateMenuMusic)
    menuMusic.Ended:Connect(function()
        local menuVisible = menuOpen and ScreenGui.Enabled and ScreenGui.Parent ~= nil and Main.Visible
        if menuMusicEnabled and (not menuMusicOnlyWithUI or menuVisible) and menuMusic.SoundId ~= "" then
            menuMusic.TimePosition = 0
            menuMusic:Play()
        end
    end)


    local selectedTheme = "Snow"
    local rainDrops = {}
    local lightningRainDrops = {}
    local fireFlames = {}
    local starFlakes = {}
    local lightningFlash = Instance.new("Frame")
    lightningFlash.Name = "LightningFlash"
    lightningFlash.Parent = SnowLayer
    lightningFlash.Size = UDim2.fromScale(1, 1)
    lightningFlash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    lightningFlash.BackgroundTransparency = 0.58
    lightningFlash.BorderSizePixel = 0
    lightningFlash.Visible = false
    lightningFlash.ZIndex = 60
    local lightningBolt
    local function addBoltSegment(parent, x1, y1, x2, y2, thickness, color, transparency)
        local viewport = parent.AbsoluteSize
        local dx = (x2 - x1) * viewport.X
        local dy = (y2 - y1) * viewport.Y
        local line = Instance.new("Frame")
        line.Parent = parent
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Position = UDim2.fromScale((x1 + x2) / 2, (y1 + y2) / 2)
        line.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), thickness)
        line.Rotation = math.deg(math.atan2(dy, dx))
        line.BackgroundColor3 = color
        line.BackgroundTransparency = transparency or 0
        line.BorderSizePixel = 0
        line.ZIndex = 61
    end


    local function makeLightningBolt()
        if lightningBolt then lightningBolt:Destroy() end
        lightningBolt = Instance.new("Frame")
        lightningBolt.Name = "LightningBolt"
        lightningBolt.Parent = lightningFlash
        lightningBolt.Size = UDim2.fromScale(1, 1)
        lightningBolt.BackgroundTransparency = 1
        lightningBolt.ZIndex = 60
        local x, y = Random:NextNumber(0.25, 0.75), 0
        local points = { {x, y} }
        while y < 1 do
            y = math.min(1, y + Random:NextNumber(0.07, 0.13))
            x = math.clamp(x + Random:NextNumber(-0.09, 0.09), 0.05, 0.95)
            table.insert(points, {x, y})
        end
        for index = 1, #points - 1 do
            local from, to = points[index], points[index + 1]
            addBoltSegment(lightningBolt, from[1], from[2], to[1], to[2], 8, Color3.fromRGB(115, 185, 255), 0.28)
            addBoltSegment(lightningBolt, from[1], from[2], to[1], to[2], 3, Color3.fromRGB(255, 255, 255), 0)
            if index < #points - 2 and index % 2 == 0 and Random:NextNumber() < 0.8 then
                local bx, by = to[1], to[2]
                local direction = Random:NextNumber() < 0.5 and -1 or 1
                for branch = 1, Random:NextInteger(2, 4) do
                    local nx = math.clamp(bx + direction * Random:NextNumber(0.035, 0.08), 0.02, 0.98)
                    local ny = math.min(1, by + Random:NextNumber(0.045, 0.085))
                    addBoltSegment(lightningBolt, bx, by, nx, ny, 4, Color3.fromRGB(150, 205, 255), 0.15)
                    addBoltSegment(lightningBolt, bx, by, nx, ny, 1.5, Color3.fromRGB(255, 255, 255), 0)
                    bx, by = nx, ny
                    if ny >= 1 then break end
                end
            end
        end
    end

 
    for i = 1, 70 do
        local drop = Instance.new("Frame")
        drop.Name = "RainDrop"
        drop.Parent = SnowLayer
        drop.Size = UDim2.fromOffset(2, Random:NextInteger(10, 20))
        drop.Position = UDim2.fromScale(Random:NextNumber(), Random:NextNumber())
        drop.Rotation = 8
        drop.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        drop.BackgroundTransparency = Random:NextNumber(0.15, 0.4)
        drop.BorderSizePixel = 0
        drop.Visible = false
        drop.ZIndex = 60
        rainDrops[i] = { frame = drop, speed = Random:NextNumber(0.55, 1.1) }

        local star = Instance.new("Frame")
        star.Name = "StarOfDavid"
        star.Parent = SnowLayer
        star.AnchorPoint = Vector2.new(0.5, 0.5)
        star.Size = UDim2.fromOffset(18, 18)
        star.Position = UDim2.fromScale(Random:NextNumber(), Random:NextNumber())
        star.BackgroundTransparency = 1
        star.BorderSizePixel = 0
        star.Visible = false
        star.ZIndex = 60
        local points = { {0.50,0.04}, {0.96,0.82}, {0.04,0.82}, {0.50,0.96}, {0.04,0.18}, {0.96,0.18} }
        local edges = { {1,2}, {2,3}, {3,1}, {4,5}, {5,6}, {6,4} }
        for i = 1, #edges do
            local edge = edges[i]
            local a, b = points[edge[1]], points[edge[2]]
            local dx, dy = (b[1]-a[1])*18, (b[2]-a[2])*18
            local line = Instance.new("Frame")
            line.Name = "StarLine"
            line.Parent = star
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Position = UDim2.fromScale((a[1]+b[1])/2, (a[2]+b[2])/2)
            line.Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy), 1.5)
            line.Rotation = math.deg(math.atan2(dy, dx))
            line.BackgroundColor3 = Color3.fromRGB(45, 145, 255)
            line.BorderSizePixel = 0
            line.ZIndex = 60
        end
        starFlakes[i] = { frame = star, speed = Random:NextNumber(0.12, 0.3), drift = Random:NextNumber(-0.06, 0.06) }
    end

   
    for i = 1, 180 do
        local drop = Instance.new("Frame")
        drop.Name = "LightningRainDrop"
        drop.Parent = SnowLayer
        drop.AnchorPoint = Vector2.new(0.5, 0.5)
        drop.Size = UDim2.fromOffset(Random:NextInteger(2, 3), Random:NextInteger(22, 38))
        drop.Position = UDim2.fromScale(Random:NextNumber(), Random:NextNumber())
        drop.Rotation = 10
        drop.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        drop.BackgroundTransparency = Random:NextNumber(0.08, 0.3)
        drop.BorderSizePixel = 0
        drop.Visible = false
        drop.ZIndex = 60
        lightningRainDrops[i] = { frame = drop, speed = Random:NextNumber(1.35, 2.15), drift = -0.06 }
    end


    local fireGlow = Instance.new("Frame")
    fireGlow.Name = "FireGlow"
    fireGlow.Parent = SnowLayer
    fireGlow.Position = UDim2.new(0, 0, 0.76, 0)
    fireGlow.Size = UDim2.new(1, 0, 0.24, 0)
    fireGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fireGlow.BackgroundTransparency = 0.94
    fireGlow.BorderSizePixel = 0
    fireGlow.Visible = false
    fireGlow.ZIndex = 60
    local fireGlowGradient = Instance.new("UIGradient")
    fireGlowGradient.Rotation = 90
    fireGlowGradient.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 100, 0))
    fireGlowGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.65, 0.96), NumberSequenceKeypoint.new(1, 0.72) })
    fireGlowGradient.Parent = fireGlow
    local FIRE_TEXTURE = "rbxasset://textures/particles/fire_main.dds"
    for i = 1, 54 do
        local width, height = Random:NextInteger(48, 96), Random:NextInteger(130, 250)
        local flame = Instance.new("ImageLabel")
        flame.Name = "FireFlame"
        flame.Parent = SnowLayer
        flame.AnchorPoint = Vector2.new(0.5, 0.5)
        flame.Size = UDim2.fromOffset(width, height)
        flame.Position = UDim2.fromScale(Random:NextNumber(), Random:NextNumber(1.01, 1.18))
        flame.Rotation = Random:NextInteger(-10, 10)
        flame.BackgroundTransparency = 1
        flame.Image = FIRE_TEXTURE
        flame.ImageColor3 = Color3.fromRGB(255, Random:NextInteger(62, 110), Random:NextInteger(10, 28))
        flame.ImageTransparency = 0.08
        flame.ScaleType = Enum.ScaleType.Stretch
        flame.Visible = false
        flame.ZIndex = 60
        local core = Instance.new("ImageLabel")
        core.Name = "FireCore"
        core.Parent = flame
        core.AnchorPoint = Vector2.new(0.5, 1)
        core.Position = UDim2.new(0.5, 0, 1, -5)
        core.Size = UDim2.new(0.52, 0, 0.64, 0)
        core.BackgroundTransparency = 1
        core.Image = FIRE_TEXTURE
        core.ImageColor3 = Color3.fromRGB(255, Random:NextInteger(158, 218), Random:NextInteger(55, 95))
        core.ImageTransparency = 0.32
        core.ScaleType = Enum.ScaleType.Stretch
        core.ZIndex = 61
        fireFlames[#fireFlames + 1] = { frame = flame, core = core, speed = Random:NextNumber(0.12, 0.22), drift = Random:NextNumber(-0.018, 0.018), rise = true, flicker = true, baseWidth = width, baseHeight = height, phase = Random:NextNumber(0, math.pi * 2) }
    end
    for i = 1, 64 do
        local ember = Instance.new("Frame")
        ember.Name = "FireEmber"
        ember.Parent = SnowLayer
        ember.AnchorPoint = Vector2.new(0.5, 0.5)
        local size = Random:NextInteger(2, 4)
        ember.Size = UDim2.fromOffset(size, size)
        ember.Position = UDim2.fromScale(Random:NextNumber(), Random:NextNumber(0.82, 1.08))
        ember.BackgroundColor3 = Random:NextNumber() < 0.75 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 100, 0)
        ember.BackgroundTransparency = Random:NextNumber(0.08, 0.3)
        ember.BorderSizePixel = 0
        ember.Visible = false
        ember.ZIndex = 61
        local emberCorner = Instance.new("UICorner")
        emberCorner.CornerRadius = UDim.new(1, 0)
        emberCorner.Parent = ember
        fireFlames[#fireFlames + 1] = { frame = ember, speed = Random:NextNumber(0.22, 0.5), drift = Random:NextNumber(-0.045, 0.045), rise = true, ember = true }
    end

    local Content, TopBar
    local function applyTheme()
        SnowLayer.Visible = effectsEnabled
        animationBlur.Enabled = effectsEnabled and menuOpen
        fireGlow.Visible = effectsEnabled and selectedTheme == "Fire"
        for i = 1, #snowflakes do
            local item = snowflakes[i]
            item.frame.Visible = effectsEnabled and selectedTheme == "Snow"
        end
        for index = 1, #rainDrops do
            local item = rainDrops[index]
            item.frame.Visible = effectsEnabled and selectedTheme == "Rain"
            item.frame.BackgroundColor3 = Color3.fromRGB(100, 175, 255)
        end
        for i = 1, #lightningRainDrops do
            local item = lightningRainDrops[i]
            item.frame.Visible = effectsEnabled and selectedTheme == "Lightning"
        end
        for i = 1, #fireFlames do
            local item = fireFlames[i]
            item.frame.Visible = effectsEnabled and selectedTheme == "Fire"
        end
        for i = 1, #starFlakes do
            local item = starFlakes[i]
            item.frame.Visible = effectsEnabled and selectedTheme == "Star of David"
        end
        lightningFlash.Visible = false
    end
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Main
    bindAccent(Stroke)
    Stroke.Thickness = 2

    local InnerBorder = Instance.new("Frame")
    InnerBorder.Parent = Main
    InnerBorder.BackgroundTransparency = 1
    InnerBorder.BorderSizePixel = 0
    InnerBorder.Position = UDim2.fromOffset(4, 4)
    InnerBorder.Size = UDim2.new(1, -8, 1, -8)

    local InnerStroke = Instance.new("UIStroke")
    InnerStroke.Parent = InnerBorder
    bindAccent(InnerStroke)
    InnerStroke.Thickness = 1

    TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.Size = UDim2.new(1, 0, 0, 68)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    TopBar.BorderSizePixel = 0

    local TopStroke = Instance.new("UIStroke")
    TopStroke.Parent = TopBar
    bindAccent(TopStroke)
    TopStroke.Thickness = 1

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "OmniTitle"
    titleLabel.Parent = TopBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Size = UDim2.new(1, 0, 0, 31)
    titleLabel.Text = "OMNI"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 19
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.ZIndex = 10
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 125, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 125, 0)), ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 75, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)) })
    titleGradient.Parent = titleLabel

    local TabHolder = Instance.new("Frame")
    TabHolder.Parent = TopBar
    TabHolder.BackgroundTransparency = 1
    TabHolder.Size = UDim2.new(1, -10, 0, 30)
    TabHolder.Position = UDim2.new(0, 5, 0, 34)
    TabHolder.ZIndex = 10

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = TabHolder
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 6)

    Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = Main
    Content.Position = UDim2.fromOffset(10, 78)
    Content.Size = UDim2.new(1, -20, 1, -88)
    Content.BackgroundTransparency = 1

    local tabDefinitions = {
			Combat = { "Combat" },
			Visuals = { "ESP" },
			Player = { "Player" },
			Misc = { "Features", "Crosshair", "Player Visuals", "Skin Changer" },
			Settings = { "Save Manager", "Theme" },
    }

    local snowConnection
    local uiUnloaded = false
    local managedConnections = {}
    local tabConnections = {}

    local function trackCameraViewport()
        refreshUIScale()
        local camera = workspace.CurrentCamera
        if camera then
            table.insert(managedConnections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshUIScale))
        end
    end
    table.insert(managedConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(trackCameraViewport))
    trackCameraViewport()
    local watermarkEnabled = true
    local watermarkOptions = { Title = true, FPS = true, Ping = false }
    local watermarkRefreshRate = 0.1
    local currentThemePalette = {}
    local applyLoadedPalette
    local hudKeybindEnabled = true
    local watermarkRoot = Instance.new("Frame")
    watermarkRoot.Name = "OmniWatermark"
    watermarkRoot.Parent = HudGui
    watermarkRoot.Position = UDim2.fromOffset(12, 64)
    watermarkRoot.Size = UDim2.fromOffset(250, 26)
    watermarkRoot.BackgroundTransparency = 1
    watermarkRoot.BorderSizePixel = 0
    watermarkRoot.Active = true
    watermarkRoot.Visible = watermarkEnabled
    watermarkRoot.ZIndex = 20

    local watermarkRootCorner = Instance.new("UICorner")
    watermarkRootCorner.CornerRadius = UDim.new(0, 5)
    watermarkRootCorner.Parent = watermarkRoot

    local watermarkGlow = Instance.new("UIStroke")
    watermarkGlow.Parent = watermarkRoot
    bindAccent(watermarkGlow)
    watermarkGlow.Thickness = 1.5
    watermarkGlow.Transparency = 0.7

    local watermarkOutline = Instance.new("Frame")
    watermarkOutline.Name = "WatermarkOutline"
    watermarkOutline.Parent = watermarkRoot
    watermarkOutline.Size = UDim2.fromScale(1, 1)
    watermarkOutline.BorderSizePixel = 0
    watermarkOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    watermarkOutline.ZIndex = 20
    local watermarkOutlineGradient = Instance.new("UIGradient")
    watermarkOutlineGradient.Rotation = 45
    bindAccentGradient(watermarkOutlineGradient)
    watermarkOutlineGradient.Parent = watermarkOutline
    local watermarkOutlineCorner = Instance.new("UICorner")
    watermarkOutlineCorner.CornerRadius = UDim.new(0, 5)
    watermarkOutlineCorner.Parent = watermarkOutline

    local watermarkBackground = Instance.new("Frame")
    watermarkBackground.Name = "WatermarkBackground"
    watermarkBackground.Parent = watermarkRoot
    watermarkBackground.Position = UDim2.fromOffset(1, 1)
    watermarkBackground.Size = UDim2.new(1, -2, 1, -2)
    watermarkBackground.BorderSizePixel = 0
    watermarkBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    watermarkBackground.ClipsDescendants = true
    watermarkBackground.ZIndex = 21
    local watermarkBackgroundCorner = Instance.new("UICorner")
    watermarkBackgroundCorner.CornerRadius = UDim.new(0, 4)
    watermarkBackgroundCorner.Parent = watermarkBackground
    local watermarkBackgroundGradient = Instance.new("UIGradient")
    watermarkBackgroundGradient.Rotation = 90
    watermarkBackgroundGradient.Color = ColorSequence.new(Color3.fromRGB(30, 30, 40), Color3.fromRGB(11, 11, 17))
    watermarkBackgroundGradient.Parent = watermarkBackground

    local watermarkSheen = Instance.new("Frame")
    watermarkSheen.Name = "WatermarkSheen"
    watermarkSheen.Parent = watermarkBackground
    watermarkSheen.Size = UDim2.new(1, 0, 1, 0)
    watermarkSheen.BorderSizePixel = 0
    watermarkSheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    watermarkSheen.BackgroundTransparency = 0
    watermarkSheen.ZIndex = 21
    local watermarkSheenGradient = Instance.new("UIGradient")
    watermarkSheenGradient.Rotation = 90
    watermarkSheenGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.86),
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 1),
    })
    watermarkSheenGradient.Parent = watermarkSheen

    local watermarkAccent = Instance.new("Frame")
    watermarkAccent.Name = "WatermarkAccent"
    watermarkAccent.Parent = watermarkBackground
    watermarkAccent.Size = UDim2.new(0, 3, 1, 0)
    watermarkAccent.BorderSizePixel = 0
    watermarkAccent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    watermarkAccent.ZIndex = 22
    local watermarkAccentGradient = Instance.new("UIGradient")
    watermarkAccentGradient.Rotation = 90
    bindAccentGradient(watermarkAccentGradient)
    watermarkAccentGradient.Parent = watermarkAccent

    local watermarkLabel = Instance.new("TextLabel")
    watermarkLabel.Name = "WatermarkText"
    watermarkLabel.Parent = watermarkRoot
    watermarkLabel.Position = UDim2.fromOffset(13, 1)
    watermarkLabel.Size = UDim2.new(1, -21, 1, -2)
    watermarkLabel.BackgroundTransparency = 1
    watermarkLabel.Text = ""
    watermarkLabel.TextColor3 = Color3.fromRGB(215, 217, 228)
    watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
    watermarkLabel.TextYAlignment = Enum.TextYAlignment.Center
    watermarkLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    watermarkLabel.TextStrokeTransparency = 0.35
    watermarkLabel.Font = Enum.Font.Code
    watermarkLabel.TextSize = 13
    watermarkLabel.RichText = true
    watermarkLabel.TextWrapped = false
    watermarkLabel.ZIndex = 23
    local hudKeybindLabel = Instance.new("TextLabel")
    hudKeybindLabel.Name = "OmniKeybindList"
    hudKeybindLabel.Parent = HudGui
    hudKeybindLabel.Position = UDim2.fromOffset(12, 60)
    hudKeybindLabel.Size = UDim2.fromOffset(230, 0)
    hudKeybindLabel.AutomaticSize = Enum.AutomaticSize.Y
    hudKeybindLabel.TextYAlignment = Enum.TextYAlignment.Top
    hudKeybindLabel.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
    hudKeybindLabel.BackgroundTransparency = 0.1
    hudKeybindLabel.Active = true
    hudKeybindLabel.BorderSizePixel = 0
    hudKeybindLabel.Text = "KEYBINDS  |  RightShift: Menu"
    hudKeybindLabel.TextColor3 = Color3.fromRGB(210, 215, 230)
    hudKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    hudKeybindLabel.Font = Enum.Font.Code
    hudKeybindLabel.TextSize = 10
    hudKeybindLabel.Visible = true
    hudKeybindLabel.ZIndex = 20
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 6)
    keybindCorner.Parent = hudKeybindLabel
    local keybindPadding = Instance.new("UIPadding")
    keybindPadding.PaddingLeft = UDim.new(0, 9)
    keybindPadding.PaddingRight = UDim.new(0, 8)
    keybindPadding.PaddingTop = UDim.new(0, 5)
    keybindPadding.PaddingBottom = UDim.new(0, 5)
    keybindPadding.Parent = hudKeybindLabel
    local keybindStroke = Instance.new("UIStroke")
    keybindStroke.Parent = hudKeybindLabel
    bindAccent(keybindStroke)
    keybindStroke.Thickness = 1
    local function makeHUDDraggable(guiObject)
        local dragging = false
        local dragStart
        local startPosition
        table.insert(managedConnections, guiObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPosition = guiObject.Position
            end
        end))
        table.insert(managedConnections, UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end))
        table.insert(managedConnections, UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end
    makeHUDDraggable(watermarkRoot)
    makeHUDDraggable(hudKeybindLabel)
    local hudElapsed = 0
     table.insert(managedConnections, RunService.RenderStepped:Connect(function(deltaTime)
        hudElapsed += deltaTime
        if hudElapsed < watermarkRefreshRate then return end
        hudElapsed = 0
        local pieces = {}
        local accentR = math.floor(math.clamp(uiAccentColor.R, 0, 1) * 255 + 0.5)
        local accentG = math.floor(math.clamp(uiAccentColor.G, 0, 1) * 255 + 0.5)
        local accentB = math.floor(math.clamp(uiAccentColor.B, 0, 1) * 255 + 0.5)
        local accentHex = string.format("#%02X%02X%02X", accentR, accentG, accentB)
        if watermarkOptions.Title then
            table.insert(pieces, string.format('<font color="%s">\u{25C6} OMNI</font>', accentHex))
        end
        if watermarkOptions.FPS then
            local fps = math.min(240, math.floor(1 / math.max(deltaTime, 1 / 240)))
            local fpsColor = fps >= 120 and "#7BFFA9" or (fps >= 60 and "#FFD479" or "#FF6B72")
            table.insert(pieces, string.format('<font color="#7C7C8C">FPS</font> <font color="%s">%d</font>', fpsColor, fps))
        end
        if watermarkOptions.Ping then
            local ping = 0
            pcall(function() ping = math.floor(Player:GetNetworkPing() * 1000 + 0.5) end)
            local pingColor = ping <= 70 and "#7BFFA9" or (ping <= 140 and "#FFD479" or "#FF6B72")
            table.insert(pieces, string.format('<font color="#7C7C8C">PING</font> <font color="%s">%dms</font>', pingColor, ping))
        end
        table.insert(pieces, string.format('<font color="#8A8A9A">%s</font>', os.date("%H:%M:%S")))
        watermarkLabel.Text = table.concat(pieces, '  <font color="#3C3C4A">\u{2022}</font>  ')
        watermarkBackgroundGradient.Offset = Vector2.new(math.sin(os.clock() * 0.9) * 0.18, 0)
        watermarkAccentGradient.Offset = Vector2.new(0, math.sin(os.clock() * 1.6) * 0.35)
        local watermarkWidth = math.clamp(watermarkLabel.TextBounds.X + 28, 200, 900)
        watermarkRoot.Size = UDim2.fromOffset(watermarkWidth, 26)
        watermarkRoot.Visible = watermarkEnabled
    end))


    local starAuraEnabled = false
    local starAuraConnection
    local starAuraStars = {}
    local STAR_AURA_COUNT = 100
    local STAR_AURA_POINTS = { {0.50, 0.04}, {0.96, 0.82}, {0.04, 0.82}, {0.50, 0.96}, {0.04, 0.18}, {0.96, 0.18} }
    local STAR_AURA_EDGES = { {1, 2}, {2, 3}, {3, 1}, {4, 5}, {5, 6}, {6, 4} }

    local function clearStarAura()
        if starAuraConnection then
            starAuraConnection:Disconnect()
            starAuraConnection = nil
        end
        for i = 1, #starAuraStars do
            local star = starAuraStars[i]
            star.gui:Destroy()
            star.anchor:Destroy()
        end
        table.clear(starAuraStars)
    end

    local function setStarAuraEnabled(enabled)
        starAuraEnabled = enabled
        clearStarAura()
        if not enabled then return end

        local playerGui = Player:WaitForChild("PlayerGui")
        for index = 1, STAR_AURA_COUNT do
            local anchor = Instance.new("Part")
            anchor.Name = "PlayerAuraAnchor"
            anchor.Anchored = true
            anchor.CanCollide = false
            anchor.CanTouch = false
            anchor.CanQuery = false
            anchor.Transparency = 1
            anchor.Size = Vector3.new(0.05, 0.05, 0.05)
            anchor.Parent = workspace

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "PlayerAuraStar"
            billboard.Adornee = anchor
            local starSize = Random:NextInteger(12, 18)
            billboard.Size = UDim2.fromOffset(starSize, starSize)
            billboard.AlwaysOnTop = false
            billboard.LightInfluence = 0
            billboard.Parent = playerGui

            local lines = {}
            for i = 1, #STAR_AURA_EDGES do
                local edge = STAR_AURA_EDGES[i]
                local p1, p2 = STAR_AURA_POINTS[edge[1]], STAR_AURA_POINTS[edge[2]]
                local dx, dy = p2[1] - p1[1], p2[2] - p1[2]
                local line = Instance.new("Frame")
                line.Name = "StarLine"
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Position = UDim2.fromScale((p1[1] + p2[1]) / 2, (p1[2] + p2[2]) / 2)
                line.Size = UDim2.new(math.sqrt(dx * dx + dy * dy), 0, 0, 1.25)
                line.Rotation = math.deg(math.atan2(dy, dx))
                line.BackgroundColor3 = Color3.fromRGB(225, 230, 238)
                line.BackgroundTransparency = 0.15
                line.BorderSizePixel = 0
                line.Parent = billboard
                table.insert(lines, line)
            end

            table.insert(starAuraStars, {
                anchor = anchor,
                gui = billboard,
                lines = lines,
                position = nil,
                velocity = Vector3.zero,
                age = 0,
                lifetime = Random:NextNumber(1.1, 2.4),
            })
        end

        local lastCharacter
        starAuraConnection = RunService.RenderStepped:Connect(function(deltaTime)
            local character = Player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if character ~= lastCharacter then
                lastCharacter = character
                for i = 1, #starAuraStars do
                    local star = starAuraStars[i]
                    star.position = nil
                end
            end

            for i = 1, #starAuraStars do
                local star = starAuraStars[i]
                if root then
                    if not star.position or star.age >= star.lifetime then

                        star.position = root.Position + Vector3.new(Random:NextNumber(-0.45, 0.45), Random:NextNumber(0.1, 1.8), Random:NextNumber(-0.45, 0.45))
                        star.velocity = Vector3.new(Random:NextNumber(-0.55, 0.55), Random:NextNumber(0.18, 0.8), Random:NextNumber(-0.55, 0.55))
                        star.age = 0
                        star.lifetime = Random:NextNumber(1.1, 2.4)
                    else
                        star.age += deltaTime
                        star.position += star.velocity * deltaTime
                    end
                    star.anchor.Position = star.position
                    local progress = math.clamp(star.age / star.lifetime, 0, 1)
                    local opacity = math.sin(progress * math.pi)
                    local transparency = opacity < 0.06 and 1 or math.clamp(1 - opacity, 0.15, 0.98)
                    for i = 1, #star.lines do
                        local line = star.lines[i]
                        line.BackgroundTransparency = transparency
                    end
                else
                    star.position = nil
                    for i = 1, #star.lines do
                        local line = star.lines[i]
                        line.BackgroundTransparency = 1
                    end
                end
            end
        end)
    end

    local function unloadUI()
        if uiUnloaded then return end
        uiUnloaded = true
        if snowConnection then
            snowConnection:Disconnect()
            snowConnection = nil
        end
        for i = 1, #managedConnections do
            local connection = managedConnections[i]
            connection:Disconnect()
        end
        table.clear(managedConnections)
        for i = 1, #tabConnections do
            local connection = tabConnections[i]
            connection:Disconnect()
        end
        table.clear(tabConnections)
        local aimHook = _G.__OmniAimHook
        if type(aimHook) == "table" then
            if aimHook.state then aimHook.state.active = false end
            if type(aimHook.restore) == "function" then
                pcall(aimHook.restore)
            elseif aimHook.meta then
                pcall(function()
                    local unlock = setreadonly or make_writeable
                    if type(unlock) == "function" then unlock(aimHook.meta, false) end
                    aimHook.meta.__index = aimHook.oldIndex
                    if type(unlock) == "function" then unlock(aimHook.meta, true) end
                end)
            end
            _G.__OmniAimHook = nil
        end
        uiClickSound:Destroy()
    animationBlur:Destroy()
        HudGui:Destroy()
        if espGui then espGui:Destroy() end
        setStarAuraEnabled(false)
        menuMusic:Stop()
        menuMusic:Destroy()
        ScreenGui:Destroy()
    end

    local tabButtons = {}
    local function setActiveTab(tabName)
        for name, button in next, tabButtons do
            local on = name == tabName
            button.BackgroundColor3 = on and Color3.fromRGB(18, 18, 30) or Color3.fromRGB(15, 15, 25)
            button.TextColor3 = on and uiAccentColor or Color3.fromRGB(200, 200, 215)
            local stroke = button:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = on and 0 or 0.55 end
        end
    end

    local function makeSubTabs(container, names, topOffset)
        topOffset = topOffset or 36
        local bar = Instance.new("Frame")
        bar.Name = "SubTabBar"
        bar.Parent = container
        bar.Position = UDim2.fromOffset(10, topOffset)
        bar.Size = UDim2.new(1, -20, 0, 24)
        bar.BackgroundTransparency = 1
        bar.ZIndex = 10

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 4)
        layout.Parent = bar

        local pages, buttons = {}, {}

        local function select(name)
            for pageName, page in next, pages do
                page.Visible = pageName == name
            end
            for buttonName, button in next, buttons do
                local on = buttonName == name
                button.BackgroundColor3 = on and Color3.fromRGB(18, 18, 30) or Color3.fromRGB(18, 18, 30)
                button.TextColor3 = on and uiAccentColor or Color3.fromRGB(225, 225, 235)
            end
        end

        for index = 1, #names do
            local name = names[index]
            local button = Instance.new("TextButton")
            button.Name = name:gsub("%s+", "") .. "SubTab"
            button.Parent = bar
            button.LayoutOrder = index
            button.Size = UDim2.new(1 / #names, -3, 1, 0)
            button.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            button.BorderSizePixel = 0
            button.Text = name
            button.TextColor3 = Color3.fromRGB(225, 225, 235)
            button.Font = Enum.Font.Code
            button.TextSize = 11
            button.ZIndex = 11
            buttons[name] = button

            local page = Instance.new("ScrollingFrame")
            page.Name = name:gsub("%s+", "") .. "Page"
            page.Parent = container
            page.Position = UDim2.fromOffset(6, topOffset + 28)
            page.Size = UDim2.new(1, -12, 1, -(topOffset + 34))
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.ScrollBarThickness = 3
            page.CanvasSize = UDim2.fromOffset(0, 0)
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.Visible = false
            page.ZIndex = 4

            local pageLayout = Instance.new("UIListLayout")
            pageLayout.Parent = page
            pageLayout.Padding = UDim.new(0, 4)
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

            pages[name] = page
            button.Activated:Connect(function() select(name) end)
        end

        select(names[1])
        return pages, select
    end

    local MELEE_SKINS = {
        "None", "Karambit", "ButterflyKnife", "IceAxe", "PlasmaNinjato",
        "Greatsword", "Longsword", "Cutlass", "IceDagger", "M9Fade", "M9XR7",
        "AnarchyTomahawk", "FlipKnifeShark", "Kukri", "Scythe", "GoldenDV2",
    }
    local RANGED_PART_TOKENS = {
        "receiver", "barrel", "mag", "slide", "stock", "sight", "muzzle", "handguard",
        "m4", "ak", "makarov", "mosin", "shotgun", "front", "picatinny", "bolt",
    }
    local skinState = {
        meleeSkin = "None",
        weaponItem = nil,
        weaponSkin = nil,
    }
    local originalMeleeRefs = {}
    local knownMeleeSkins = {}
    for index = 1, #MELEE_SKINS do
        local skinName = MELEE_SKINS[index]
        if skinName ~= "None" then knownMeleeSkins[skinName] = true end
    end

    local function gameDataFolder()
        local playersFolder = ReplicatedStorage:FindFirstChild("Players")
        return playersFolder and playersFolder:FindFirstChild(Player.Name)
    end

    local function applyNativeMeleeSkin(skinName)
        local playerFolder = gameDataFolder()
        local inventory = playerFolder and playerFolder:FindFirstChild("Inventory")
        if not inventory then return end
        local itemsList = ReplicatedStorage:FindFirstChild("ItemsList")
        local targetItem = nil
        if skinName and skinName ~= "None" and itemsList then
            targetItem = itemsList:FindFirstChild(skinName)
        end
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("ObjectValue") then
                if originalMeleeRefs[item.Name] == nil then
                    originalMeleeRefs[item.Name] = item.Value
                end
                local originalRef = originalMeleeRefs[item.Name]
                local originalName = originalRef and originalRef.Name or ""
                local properties = originalRef and originalRef:FindFirstChild("ItemProperties")
                local slotType = properties and properties:FindFirstChild("SlotType") and properties.SlotType.Value or ""
                local lowerName = string.lower(originalName)
                local isMelee = slotType == "Melee"
                    or string.find(lowerName, "knife", 1, true)
                    or string.find(lowerName, "cleaver", 1, true)
                    or string.find(lowerName, "axe", 1, true)
                    or string.find(lowerName, "crowbar", 1, true)
                    or string.find(lowerName, "karambit", 1, true)
                    or originalName == "DV2"
                if isMelee then
                    if targetItem then
                        pcall(function() item.Value = targetItem end)
                    elseif originalRef then
                        pcall(function() item.Value = originalRef end)
                    end
                end
            end
        end
    end

    local function isHoldingMelee()
        local playerFolder = gameDataFolder()
        local status = playerFolder and playerFolder:FindFirstChild("Status")
        local gameplay = status and status:FindFirstChild("GameplayVariables")
        local equippedSlot = gameplay and gameplay:FindFirstChild("EquippedSlot")
        if equippedSlot and equippedSlot.Value then
            local slotName = string.lower(tostring(equippedSlot.Value))
            if string.find(slotName, "back", 1, true) or string.find(slotName, "hip", 1, true)
                or string.find(slotName, "hotbar", 1, true) or string.find(slotName, "primary", 1, true)
                or string.find(slotName, "secondary", 1, true) or string.find(slotName, "equipment", 1, true) then
                return false
            end
            if string.find(slotName, "melee", 1, true) then return true end
        end
        local equippedTool = gameplay and gameplay:FindFirstChild("EquippedTool") and gameplay.EquippedTool.Value
        if equippedTool then
            local itemsList = ReplicatedStorage:FindFirstChild("ItemsList")
            local itemRef = itemsList and itemsList:FindFirstChild(equippedTool.Name)
            local properties = itemRef and itemRef:FindFirstChild("ItemProperties")
            local itemType = properties and (properties:GetAttribute("ItemType") or "") or ""
            local itemSlot = properties and (properties:GetAttribute("Slot") or "") or ""
            itemType, itemSlot = string.lower(tostring(itemType)), string.lower(tostring(itemSlot))
            if string.find(itemType, "ranged", 1, true) or string.find(itemSlot, "back", 1, true)
                or string.find(itemSlot, "hip", 1, true) or string.find(itemSlot, "primary", 1, true)
                or string.find(itemSlot, "secondary", 1, true) or string.find(itemSlot, "hotbar", 1, true) then
                return false
            end
            if string.find(itemType, "melee", 1, true) or string.find(itemSlot, "melee", 1, true) then return true end
        end
        local camera = workspace.CurrentCamera
        local viewmodel = camera and (camera:FindFirstChild("ViewModel") or camera:FindFirstChildOfClass("Model"))
        local item = viewmodel and viewmodel:FindFirstChild("Item")
        if not item then return false end
        for _, descendant in ipairs(item:GetDescendants()) do
            local partName = string.lower(descendant.Name)
            for tokenIndex = 1, #RANGED_PART_TOKENS do
                if string.find(partName, RANGED_PART_TOKENS[tokenIndex], 1, true) then
                    return false
                end
            end
        end
        return false
    end

    local function viewmodelItem()
        local camera = workspace.CurrentCamera
        local viewmodel = camera and (camera:FindFirstChild("ViewModel") or camera:FindFirstChildOfClass("Model"))
        return viewmodel and viewmodel:FindFirstChild("Item")
    end

    local meleeHiddenParts = setmetatable({}, { __mode = "k" })

    local function restoreMeleeParts(item)
        if not item then return end
        for part, transparency in pairs(meleeHiddenParts) do
            if part.Parent then
                pcall(function() part.Transparency = transparency end)
            end
            meleeHiddenParts[part] = nil
        end
    end

    local function clearMeleeSkinVisual(keepName)
        local item = viewmodelItem()
        if not item then return end
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("Model") and child:GetAttribute("OmniMeleeSkin") and child.Name ~= keepName then
                child:Destroy()
            end
        end
        restoreMeleeParts(item)
    end

    local function hasRangedParts(item)
        if not item then return false end
        local stack = { item }
        while #stack > 0 do
            local node = table.remove(stack)
            for _, child in ipairs(node:GetChildren()) do
                local isOurModel = child:IsA("Model") and child:GetAttribute("OmniMeleeSkin") ~= nil
                if not isOurModel then
                    if child:IsA("BasePart") then
                        local partName = string.lower(child.Name)
                        for tokenIndex = 1, #RANGED_PART_TOKENS do
                            if string.find(partName, RANGED_PART_TOKENS[tokenIndex], 1, true) then
                                return true
                            end
                        end
                    end
                    stack[#stack + 1] = child
                end
            end
        end
        return false
    end

    local lastMeleeUpdate = 0
    table.insert(managedConnections, RunService.RenderStepped:Connect(function()
        local now = os.clock()
        if now - lastMeleeUpdate < 0.2 then return end
        lastMeleeUpdate = now

        local item = viewmodelItem()
        local itemRoot = item and item:FindFirstChild("ItemRoot")
        local skinName = skinState.meleeSkin

        if not isHoldingMelee() or not skinName or skinName == "None" then
            clearMeleeSkinVisual()
            return
        end

        if not (item and itemRoot and itemRoot:IsA("BasePart")) then return end
        if hasRangedParts(item) then
            clearMeleeSkinVisual()
            return
        end

        local skinContainer = item:FindFirstChild(skinName)
        if not skinContainer then
            local modelsFolder = ReplicatedStorage:FindFirstChild("ItemsListModels")
            local template = modelsFolder and modelsFolder:FindFirstChild(skinName)
            if template then
                local clone = template:Clone()
                clone.Name = skinName
                clone:SetAttribute("OmniMeleeSkin", true)
                local cloneRoot = clone:FindFirstChild("ItemRoot")
                if cloneRoot and cloneRoot:IsA("BasePart") then
                    pcall(function() clone:PivotTo(itemRoot.CFrame) end)
                    local weld = Instance.new("WeldConstraint")
                    weld.Name = "SkinToVMWeld"
                    weld.Part0 = cloneRoot
                    weld.Part1 = itemRoot
                    weld.Parent = cloneRoot
                end
                clone.Parent = item
                skinContainer = clone
            end
        end

        if not skinContainer then
            restoreMeleeParts(item)
            return
        end

        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("Model") and child:GetAttribute("OmniMeleeSkin") and child ~= skinContainer then
                child:Destroy()
            end
        end

        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= skinName then
                if meleeHiddenParts[child] == nil then
                    meleeHiddenParts[child] = child.Transparency
                end
                child.Transparency = 1
            end
        end

        for _, descendant in ipairs(skinContainer:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Transparency = descendant.Name == "ItemRoot" and 1 or 0
            end
        end
    end))

    local function skinsFolder()
        return ReplicatedStorage:FindFirstChild("Skins")
    end

    local function skinItemNames()
        local folder = skinsFolder()
        local out = {}
        if folder then
            for _, child in ipairs(folder:GetChildren()) do out[#out + 1] = child.Name end
        end
        table.sort(out)
        return out
    end

    local function skinNamesFor(itemName)
        local folder = skinsFolder()
        local itemFolder = folder and folder:FindFirstChild(itemName)
        local out = {}
        if itemFolder then
            for _, child in ipairs(itemFolder:GetChildren()) do out[#out + 1] = child.Name end
        end
        table.sort(out)
        if #out == 0 then out = { "Default" } end
        return out
    end

    local iconCache = {}

    local function imageFrom(value)
        if type(value) == "number" then return "rbxassetid://" .. tostring(math.floor(value)) end
        if type(value) ~= "string" or value == "" then return nil end
        if string.find(value, "://", 1, true) then return value end
        local id = tonumber(value)
        if id then return "rbxassetid://" .. tostring(math.floor(id)) end
        return nil
    end

    local function iconFrom(container)
        if not container then return nil end
        local properties = container:FindFirstChild("ItemProperties")
        local image = properties and imageFrom(properties:GetAttribute("ItemIcon") or properties:GetAttribute("Icon"))
        if image then return image end
        if properties then
            local icon = properties:FindFirstChild("ItemIcon") or properties:FindFirstChild("Icon") or properties:FindFirstChild("Image")
            if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) and icon.Image ~= "" then
                return icon.Image
            end
            if icon and (icon:IsA("StringValue") or icon:IsA("NumberValue")) then
                image = imageFrom(icon.Value)
                if image then return image end
            end
        end
        image = imageFrom(container:GetAttribute("ItemIcon") or container:GetAttribute("Icon"))
        if image then return image end
        local function fromChild(child)
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                if child.Image ~= "" then return child.Image end
            elseif child:IsA("StringValue") or child:IsA("NumberValue") then
                local childName = child.Name
                if childName == "ItemIcon" or childName == "Icon" or childName == "Image" then
                    return imageFrom(child.Value)
                end
            end
            return nil
        end
        for _, child in ipairs(container:GetChildren()) do
            image = fromChild(child)
            if image then return image end
        end
        for _, descendant in ipairs(container:GetDescendants()) do
            image = fromChild(descendant)
            if image then return image end
        end
        return nil
    end

    local iconOf = iconFrom

    local function itemIcon(name)
        if iconCache[name] then return iconCache[name] end
        local function remember(image)
            if image and image ~= "" then iconCache[name] = image end
            return image or ""
        end
        local list = ReplicatedStorage:FindFirstChild("ItemsList")
        local models = ReplicatedStorage:FindFirstChild("ItemsListModels")
        local image = list and iconOf(list:FindFirstChild(name))
        if image then return remember(image) end
        local model = models and models:FindFirstChild(name)
        if model then
            image = iconFrom(model)
            if image then return remember(image) end
            local vm = model:FindFirstChild("Viewmodel") or model:FindFirstChild("ViewModel")
            image = vm and iconFrom(vm)
            if image then return remember(image) end
        end
        local folder = skinsFolder()
        local itemFolder = folder and folder:FindFirstChild(name)
        if itemFolder then
            for _, skin in ipairs(itemFolder:GetChildren()) do
                image = iconFrom(skin)
                if image then return remember(image) end
            end
        end
        local base = string.gsub(string.gsub(tostring(name), "_unlocked$", ""), "_T%d+$", "")
        if base == "" then return "" end
        if base ~= name then
            image = list and iconOf(list:FindFirstChild(base))
            if image then return remember(image) end
            model = models and models:FindFirstChild(base)
            image = model and iconFrom(model)
            if image then return remember(image) end
        end
        if list then
            for _, entry in ipairs(list:GetChildren()) do
                if entry.Name == base or string.find(entry.Name, base, 1, true) or string.find(base, entry.Name, 1, true) then
                    image = iconOf(entry)
                    if image then return remember(image) end
                end
            end
        end
        if models then
            for _, candidate in ipairs(models:GetChildren()) do
                local candidateName = candidate.Name
                if candidateName == base or string.find(candidateName, base, 1, true) or string.find(base, candidateName, 1, true) then
                    image = iconFrom(candidate)
                    if image then return remember(image) end
                end
            end
        end
        return ""
    end

    local function skinIcon(itemName, skinName)
        local folder = skinsFolder()
        local itemFolder = folder and folder:FindFirstChild(itemName)
        local skin = itemFolder and itemFolder:FindFirstChild(skinName)
        return iconFrom(skin) or itemIcon(itemName)
    end

    local function meleeModel(name)
        local models = ReplicatedStorage:FindFirstChild("ItemsListModels")
        local model = models and models:FindFirstChild(name)
        if model and model:IsA("Model") then return model end
        local list = ReplicatedStorage:FindFirstChild("ItemsList")
        local item = list and list:FindFirstChild(name)
        if item then
            if item:IsA("Model") then return item end
            local nested = item:FindFirstChild("Model", true)
            if nested and nested:IsA("Model") then return nested end
        end
        return nil
    end

    local function dressModel(model, itemName, skinName)
        local folder = skinsFolder()
        if not model or not folder then return end
        local itemFolder = folder:FindFirstChild(itemName)
        local skin = itemFolder and itemFolder:FindFirstChild(skinName)
        if not skin then return end
        local textures = skin:FindFirstChild("Textures")
        local materials = skin:FindFirstChild("Materials")
        if not textures and not materials then return end
        local parts = {}
        for _, child in ipairs(model:GetChildren()) do
            parts[#parts + 1] = child
            for _, nested in ipairs(child:GetChildren()) do parts[#parts + 1] = nested end
        end
        for _, part in ipairs(parts) do
            local key = part:GetAttribute("Skinnable")
            local texture = key and textures and textures:FindFirstChild(key)
            if texture then
                pcall(function()
                    for _, old in ipairs(part:GetChildren()) do
                        if old:IsA(texture.ClassName) then old:Destroy() end
                    end
                    local copy = texture:Clone()
                    copy.Name = "SurfaceAppearance"
                    copy.Parent = part
                    local transparency = copy:GetAttribute("Transparency")
                    if transparency and part:IsA("BasePart") and part.Transparency ~= 1 then
                        part.Transparency = transparency
                    end
                end)
            end
            local materialEntry = key and materials and materials:FindFirstChild(key)
            if materialEntry and part:IsA("BasePart") then
                pcall(function()
                    for _, old in ipairs(part:GetChildren()) do
                        if old:IsA("SurfaceAppearance") then old:Destroy() end
                    end
                    local color = materialEntry:GetAttribute("Color")
                    local transparency = materialEntry:GetAttribute("Transparency")
                    local materialName = materialEntry:GetAttribute("Name")
                    if color then part.Color = color end
                    if transparency then part.Transparency = transparency end
                    if materialName and Enum.Material[materialName] then part.Material = Enum.Material[materialName] end
                end)
            end
        end
    end

    local function refKey(objectValue)
        if typeof(objectValue) ~= "Instance" or not objectValue:IsA("ObjectValue") then return nil end
        local ref = objectValue.Value
        if not ref then return nil end
        local properties = ref:FindFirstChild("ItemProperties")
        local special = properties and properties:GetAttribute("SpecialSkinItem")
        if type(special) == "string" and special ~= "" then return special end
        return ref.Name
    end

    local function ownedSkinRefs(itemName)
        local out, seen = {}, {}
        local playerFolder = gameDataFolder()
        if not playerFolder then return out end
        local valid = { [itemName] = true }
        local folder = skinsFolder()
        local itemFolder = folder and folder:FindFirstChild(itemName)
        if itemFolder then
            for _, skin in ipairs(itemFolder:GetChildren()) do
                local modelSkin = skin:GetAttribute("ModelSkin")
                if type(modelSkin) == "string" and modelSkin ~= "" then valid[modelSkin] = true end
            end
        end
        local function scan(root)
            if not root then return end
            for _, child in ipairs(root:GetChildren()) do
                if not seen[child] and child:IsA("ObjectValue") and (valid[child.Name] or valid[refKey(child) or ""]) then
                    seen[child] = true
                    out[#out + 1] = child
                end
                local nested = child:FindFirstChild("Inventory")
                if nested then scan(nested) end
            end
        end
        scan(playerFolder:FindFirstChild("Inventory"))
        scan(playerFolder:FindFirstChild("Hotbar"))
        return out
    end

    local function stampSkinRef(objectValue, itemName, skinName)
        local list = ReplicatedStorage:FindFirstChild("ItemsList")
        local folder = skinsFolder()
        local itemFolder = folder and folder:FindFirstChild(itemName)
        local skin = itemFolder and itemFolder:FindFirstChild(skinName)
        local modelSkin = skin and skin:GetAttribute("ModelSkin")
        local target = (type(modelSkin) == "string" and modelSkin ~= "" and modelSkin) or nil
        if not target and list and list:FindFirstChild(itemName) then target = itemName end
        if objectValue:GetAttribute("Skin") == skinName and (not target or objectValue.Name == target) then
            return false
        end
        if target and objectValue.Name ~= target then
            objectValue.Name = target
            local ref = list and list:FindFirstChild(target)
            if ref then objectValue.Value = ref end
        end
        objectValue:SetAttribute("Skin", skinName)
        return true
    end

    local function applyWeaponSkin(itemName, skinName)
        local applied = 0
        local refs = ownedSkinRefs(itemName)
        for index = 1, #refs do
            if stampSkinRef(refs[index], itemName, skinName) then applied += 1 end
        end
        local camera = workspace.CurrentCamera
        local viewmodel = camera and camera:FindFirstChildOfClass("Model")
        if viewmodel then dressModel(viewmodel, itemName, skinName) end
        local character = Player.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then dressModel(tool, itemName, skinName) end
        return applied
    end

    local inventoryViewer = {
        enabled = true,
        mode = "Image",
        key = Enum.KeyCode.None,
        capturing = false,
        refreshControls = nil,
    }

    local inventoryViewerRoot = Instance.new("Frame")
    inventoryViewerRoot.Name = "OmniInventoryViewer"
    inventoryViewerRoot.Parent = HudGui
    inventoryViewerRoot.AnchorPoint = Vector2.new(1, 0)
    inventoryViewerRoot.Position = UDim2.new(1, -18, 0, 148)
    inventoryViewerRoot.Size = UDim2.fromOffset(252, 334)
    inventoryViewerRoot.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    inventoryViewerRoot.BackgroundTransparency = 0.04
    inventoryViewerRoot.BorderSizePixel = 0
    inventoryViewerRoot.Visible = inventoryViewer.enabled
    inventoryViewerRoot.ZIndex = 15

    local inventoryViewerCorner = Instance.new("UICorner")
    inventoryViewerCorner.CornerRadius = UDim.new(0, 8)
    inventoryViewerCorner.Parent = inventoryViewerRoot

    local inventoryViewerGradient = Instance.new("UIGradient")
    inventoryViewerGradient.Rotation = 90
    inventoryViewerGradient.Color = ColorSequence.new(Color3.fromRGB(20, 20, 32), Color3.fromRGB(7, 7, 13))
    inventoryViewerGradient.Parent = inventoryViewerRoot

    local inventoryViewerStroke = Instance.new("UIStroke")
    inventoryViewerStroke.Parent = inventoryViewerRoot
    bindAccent(inventoryViewerStroke)
    inventoryViewerStroke.Thickness = 1
    inventoryViewerStroke.Transparency = 0.35

    local inventoryViewerHeader = Instance.new("Frame")
    inventoryViewerHeader.Name = "InventoryViewerHeader"
    inventoryViewerHeader.Parent = inventoryViewerRoot
    inventoryViewerHeader.Size = UDim2.new(1, 0, 0, 34)
    inventoryViewerHeader.BackgroundColor3 = Color3.fromRGB(13, 13, 22)
    inventoryViewerHeader.BackgroundTransparency = 0.1
    inventoryViewerHeader.BorderSizePixel = 0
    inventoryViewerHeader.ZIndex = 16
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = inventoryViewerHeader

    local inventoryHeaderAccentBar = Instance.new("Frame")
    inventoryHeaderAccentBar.Parent = inventoryViewerHeader
    inventoryHeaderAccentBar.Position = UDim2.fromOffset(10, 10)
    inventoryHeaderAccentBar.Size = UDim2.fromOffset(2, 14)
    inventoryHeaderAccentBar.BorderSizePixel = 0
    inventoryHeaderAccentBar.ZIndex = 17
    local headerAccentGradient = Instance.new("UIGradient")
    headerAccentGradient.Rotation = 90
    bindAccentGradient(headerAccentGradient)
    headerAccentGradient.Parent = inventoryHeaderAccentBar

    local inventoryHeaderLine = Instance.new("Frame")
    inventoryHeaderLine.Parent = inventoryViewerHeader
    inventoryHeaderLine.AnchorPoint = Vector2.new(0, 1)
    inventoryHeaderLine.Position = UDim2.new(0, 8, 1, -1)
    inventoryHeaderLine.Size = UDim2.new(1, -16, 0, 1)
    inventoryHeaderLine.BorderSizePixel = 0
    inventoryHeaderLine.BackgroundTransparency = 0.4
    inventoryHeaderLine.ZIndex = 17
    local headerLineGradient = Instance.new("UIGradient")
    headerLineGradient.Color = ColorSequence.new(uiAccentColor, Color3.fromRGB(70, 70, 90))
    bindAccentGradient(headerLineGradient)
    headerLineGradient.Parent = inventoryHeaderLine

    local inventoryViewerTitle = Instance.new("TextLabel")
    inventoryViewerTitle.Parent = inventoryViewerHeader
    inventoryViewerTitle.Position = UDim2.fromOffset(18, 7)
    inventoryViewerTitle.Size = UDim2.new(1, -84, 0, 20)
    inventoryViewerTitle.BackgroundTransparency = 1
    inventoryViewerTitle.Text = "INVENTORY"
    inventoryViewerTitle.TextColor3 = Color3.fromRGB(240, 240, 250)
    inventoryViewerTitle.TextXAlignment = Enum.TextXAlignment.Left
    inventoryViewerTitle.Font = Enum.Font.Code
    inventoryViewerTitle.TextSize = 12
    inventoryViewerTitle.ZIndex = 17

    local inventoryCountBadge = Instance.new("Frame")
    inventoryCountBadge.Parent = inventoryViewerHeader
    inventoryCountBadge.AnchorPoint = Vector2.new(1, 0.5)
    inventoryCountBadge.Position = UDim2.new(1, -10, 0.5, 0)
    inventoryCountBadge.Size = UDim2.fromOffset(32, 17)
    inventoryCountBadge.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
    inventoryCountBadge.BorderSizePixel = 0
    inventoryCountBadge.ZIndex = 17
    local countBadgeCorner = Instance.new("UICorner")
    countBadgeCorner.CornerRadius = UDim.new(0, 4)
    countBadgeCorner.Parent = inventoryCountBadge
    local countBadgeStroke = Instance.new("UIStroke")
    countBadgeStroke.Parent = inventoryCountBadge
    countBadgeStroke.Color = Color3.fromRGB(70, 70, 90)
    countBadgeStroke.Thickness = 1

    local inventoryViewerCount = Instance.new("TextLabel")
    inventoryViewerCount.Parent = inventoryCountBadge
    inventoryViewerCount.Size = UDim2.fromScale(1, 1)
    inventoryViewerCount.BackgroundTransparency = 1
    inventoryViewerCount.Text = "0"
    inventoryViewerCount.TextColor3 = Color3.fromRGB(230, 230, 242)
    inventoryViewerCount.TextXAlignment = Enum.TextXAlignment.Center
    inventoryViewerCount.Font = Enum.Font.Code
    inventoryViewerCount.TextSize = 10
    inventoryViewerCount.ZIndex = 18

    local inventoryImageHolder = Instance.new("ScrollingFrame")
    inventoryImageHolder.Parent = inventoryViewerRoot
    inventoryImageHolder.Position = UDim2.fromOffset(4, 40)
    inventoryImageHolder.Size = UDim2.new(1, -8, 1, -46)
    inventoryImageHolder.BackgroundTransparency = 1
    inventoryImageHolder.BorderSizePixel = 0
    inventoryImageHolder.ScrollBarThickness = 3
    inventoryImageHolder.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    inventoryImageHolder.CanvasSize = UDim2.fromOffset(0, 0)
    inventoryImageHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inventoryImageHolder.ClipsDescendants = true
    inventoryImageHolder.ZIndex = 16

    local inventoryImageGrid = Instance.new("UIGridLayout")
    inventoryImageGrid.Parent = inventoryImageHolder
    inventoryImageGrid.CellSize = UDim2.fromOffset(54, 64)
    inventoryImageGrid.CellPadding = UDim2.fromOffset(5, 6)
    inventoryImageGrid.SortOrder = Enum.SortOrder.LayoutOrder

    local inventoryImagePadding = Instance.new("UIPadding")
    inventoryImagePadding.Parent = inventoryImageHolder
    inventoryImagePadding.PaddingLeft = UDim.new(0, 5)
    inventoryImagePadding.PaddingTop = UDim.new(0, 6)
    inventoryImagePadding.PaddingRight = UDim.new(0, 2)

    local inventoryTextHolder = Instance.new("ScrollingFrame")
    inventoryTextHolder.Parent = inventoryViewerRoot
    inventoryTextHolder.Position = UDim2.fromOffset(4, 40)
    inventoryTextHolder.Size = UDim2.new(1, -8, 1, -46)
    inventoryTextHolder.BackgroundTransparency = 1
    inventoryTextHolder.BorderSizePixel = 0
    inventoryTextHolder.ScrollBarThickness = 3
    inventoryTextHolder.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    inventoryTextHolder.CanvasSize = UDim2.fromOffset(0, 0)
    inventoryTextHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inventoryTextHolder.Visible = false
    inventoryTextHolder.ZIndex = 16

    local inventoryTextLayout = Instance.new("UIListLayout")
    inventoryTextLayout.Parent = inventoryTextHolder
    inventoryTextLayout.Padding = UDim.new(0, 4)
    inventoryTextLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local inventoryTextPadding = Instance.new("UIPadding")
    inventoryTextPadding.Parent = inventoryTextHolder
    inventoryTextPadding.PaddingLeft = UDim.new(0, 5)
    inventoryTextPadding.PaddingTop = UDim.new(0, 6)
    inventoryTextPadding.PaddingRight = UDim.new(0, 2)

    local function inventoryKeyName()
        if inventoryViewer.key == Enum.KeyCode.None then return "None" end
        return inventoryViewer.key.Name
    end

    local uiRefreshers = {}
    local keybindEntries = {}
    local keybindById = {}
    local keybindCapture = nil
    local keybindRowRefreshers = {}

    local function refreshAllRows()
        for index = 1, #uiRefreshers do pcall(uiRefreshers[index]) end
    end

    local function refreshKeybindRows()
        for _, refresh in pairs(keybindRowRefreshers) do pcall(refresh) end
    end

    local function refreshInventoryKeybindLabel()
        local lines = { "KEYBINDS" }
        for index = 1, #keybindEntries do
            local entry = keybindEntries[index]
            if entry.key ~= "None" then
                table.insert(lines, entry.label .. ": " .. entry.key)
            end
        end
        if inventoryViewer.key ~= Enum.KeyCode.None then
            table.insert(lines, inventoryKeyName() .. ": Inventory")
        end
        table.insert(lines, "RightShift: Menu")
        hudKeybindLabel.RichText = false
        hudKeybindLabel.TextWrapped = true
        hudKeybindLabel.Text = table.concat(lines, "\n")
    end

    local function KeybindAdd(id, label, getValue, setValue)
        local entry = {
            id = id, label = label, key = "None", mode = "Toggle", held = false,
            get = getValue, set = setValue,
        }
        keybindEntries[#keybindEntries + 1] = entry
        keybindById[id] = entry
        return entry
    end

    local function KeybindSet(id, keyName)
        local entry = keybindById[id]
        if not entry then return end
        entry.key = tostring(keyName or "None")
        entry.held = false
        refreshKeybindRows()
        refreshInventoryKeybindLabel()
    end

    local function KeybindGet(id)
        local entry = keybindById[id]
        return entry and entry.key or "None"
    end

    local function collectInventoryEntries()
        local entries = {}
        local byName = {}
        local itemsList = ReplicatedStorage:FindFirstChild("ItemsList")
        local function push(name, amount)
            if type(name) ~= "string" or name == "" then return end
            amount = math.max(1, math.floor(tonumber(amount) or 1))
            local existing = byName[name]
            if existing then
                existing.count += amount
            else
                local entry = { name = name, count = amount }
                byName[name] = entry
                entries[#entries + 1] = entry
            end
        end
        local function pushItem(item)
            local name = item.Name
            if item:IsA("ObjectValue") and item.Value then
                name = item.Value.Name
            else
                local attributeName = item:GetAttribute("ItemName")
                if type(attributeName) == "string" and attributeName ~= "" then name = attributeName end
            end
            if itemsList and not itemsList:FindFirstChild(name) then return end
            push(name, item:GetAttribute("Amount"))
        end
        local function scan(root, depth)
            if not root or depth > 4 then return end
            for _, child in ipairs(root:GetChildren()) do
                local nested = child:FindFirstChild("Inventory")
                local known = itemsList and itemsList:FindFirstChild(child.Name)
                if nested and not known then
                    scan(nested, depth + 1)
                elseif child:IsA("ObjectValue") or child:IsA("Folder") or child:IsA("Model") or child:IsA("Configuration") then
                    pushItem(child)
                    local attachments = child:FindFirstChild("Attachments")
                    if attachments then scan(attachments, depth + 1) end
                else
                    pushItem(child)
                end
            end
        end
        local data = gameDataFolder()
        if data then
            scan(data:FindFirstChild("Inventory"), 0)
            if #entries == 0 then
                scan(data:FindFirstChild("Hotbar"), 0)
            end
        end
        table.sort(entries, function(a, b) return a.name < b.name end)
        return entries
    end

    local inventoryLastSignature = nil

    local function clearInventoryHolder(holder)
        for _, child in ipairs(holder:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextLabel") or child:IsA("Frame") then
                child:Destroy()
            end
        end
    end

    local function clearInventoryEmptyState()
        local empty = inventoryViewerRoot:FindFirstChild("InventoryEmptyState")
        if empty then empty:Destroy() end
    end

    local function renderInventoryViewer(force)
        if not inventoryViewer.enabled and not force then return end
        local entries = collectInventoryEntries()
        local signatureParts = { inventoryViewer.mode }
        for index = 1, #entries do
            signatureParts[#signatureParts + 1] = entries[index].name .. ":" .. entries[index].count
        end
        local signature = table.concat(signatureParts, ",")
        if not force and signature == inventoryLastSignature then
            return
        end
        inventoryLastSignature = signature

        inventoryViewerCount.Text = tostring(#entries)
        inventoryImageHolder.Visible = inventoryViewer.mode == "Image"
        inventoryTextHolder.Visible = inventoryViewer.mode ~= "Image"
        clearInventoryHolder(inventoryImageHolder)
        clearInventoryHolder(inventoryTextHolder)
        clearInventoryEmptyState()

        if #entries == 0 then
            local empty = Instance.new("TextLabel")
            empty.Name = "InventoryEmptyState"
            empty.Parent = inventoryViewerRoot
            empty.Position = UDim2.fromOffset(4, 40)
            empty.Size = UDim2.new(1, -8, 1, -46)
            empty.BackgroundTransparency = 1
            empty.Text = "No items found"
            empty.TextColor3 = Color3.fromRGB(120, 120, 140)
            empty.Font = Enum.Font.Code
            empty.TextSize = 11
            empty.ZIndex = 17
            return
        end

        if inventoryViewer.mode == "Image" then
            for index = 1, #entries do
                local entry = entries[index]
                local tile = Instance.new("ImageButton")
                tile.Name = entry.name
                tile.Parent = inventoryImageHolder
                tile.LayoutOrder = index
                tile.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                tile.BorderSizePixel = 0
                tile.Image = itemIcon(entry.name)
                tile.ImageColor3 = Color3.new(1, 1, 1)
                tile.ScaleType = Enum.ScaleType.Fit
                tile.ZIndex = 17
                local tileCorner = Instance.new("UICorner")
                tileCorner.CornerRadius = UDim.new(0, 5)
                tileCorner.Parent = tile
                local tileGradient = Instance.new("UIGradient")
                tileGradient.Rotation = 90
                tileGradient.Color = ColorSequence.new(Color3.fromRGB(27, 27, 42), Color3.fromRGB(16, 16, 26))
                tileGradient.Parent = tile
                local tileStroke = Instance.new("UIStroke")
                tileStroke.Parent = tile
                tileStroke.Color = Color3.fromRGB(58, 58, 76)
                tileStroke.Thickness = 1
                local caption = Instance.new("TextLabel")
                caption.Parent = tile
                caption.AnchorPoint = Vector2.new(0, 1)
                caption.Position = UDim2.new(0, 0, 1, 0)
                caption.Size = UDim2.new(1, 0, 0, 15)
                caption.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
                caption.BackgroundTransparency = 0.18
                caption.BorderSizePixel = 0
                caption.Text = entry.name
                caption.TextColor3 = Color3.fromRGB(225, 225, 235)
                caption.TextStrokeTransparency = 0.6
                caption.TextTruncate = Enum.TextTruncate.AtEnd
                caption.Font = Enum.Font.Code
                caption.TextSize = 9
                caption.ZIndex = 18
                local captionCorner = Instance.new("UICorner")
                captionCorner.CornerRadius = UDim.new(0, 4)
                captionCorner.Parent = caption
                if tile.Image == "" then
                    local placeholder = Instance.new("TextLabel")
                    placeholder.Parent = tile
                    placeholder.Size = UDim2.new(1, 0, 1, -15)
                    placeholder.BackgroundTransparency = 1
                    placeholder.Text = string.upper(string.sub(entry.name, 1, 2))
                    placeholder.TextColor3 = Color3.fromRGB(115, 115, 138)
                    placeholder.Font = Enum.Font.Code
                    placeholder.TextSize = 14
                    placeholder.ZIndex = 18
                end
                if entry.count > 1 then
                    local amountBack = Instance.new("Frame")
                    amountBack.Parent = tile
                    amountBack.AnchorPoint = Vector2.new(1, 0)
                    amountBack.Position = UDim2.new(1, -3, 0, 3)
                    amountBack.Size = UDim2.fromOffset(26, 14)
                    amountBack.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
                    amountBack.BackgroundTransparency = 0.12
                    amountBack.BorderSizePixel = 0
                    amountBack.ZIndex = 18
                    local amountCorner = Instance.new("UICorner")
                    amountCorner.CornerRadius = UDim.new(0, 4)
                    amountCorner.Parent = amountBack
                    local amount = Instance.new("TextLabel")
                    amount.Parent = amountBack
                    amount.Size = UDim2.fromScale(1, 1)
                    amount.BackgroundTransparency = 1
                    amount.Text = "x" .. tostring(entry.count)
                    amount.TextColor3 = Color3.fromRGB(255, 255, 255)
                    amount.TextXAlignment = Enum.TextXAlignment.Center
                    amount.Font = Enum.Font.Code
                    amount.TextSize = 9
                    amount.ZIndex = 19
                end
                tile.MouseEnter:Connect(function()
                    tileStroke.Color = uiAccentColor
                    tileStroke.Transparency = 0.2
                end)
                tile.MouseLeave:Connect(function()
                    tileStroke.Color = Color3.fromRGB(58, 58, 76)
                    tileStroke.Transparency = 0
                end)
            end
        else
            for index = 1, #entries do
                local entry = entries[index]
                local row = Instance.new("Frame")
                row.Parent = inventoryTextHolder
                row.LayoutOrder = index
                row.Size = UDim2.new(1, -4, 0, 20)
                row.BackgroundColor3 = Color3.fromRGB(17, 17, 27)
                row.BackgroundTransparency = 0.12
                row.BorderSizePixel = 0
                row.ZIndex = 17
                local rowCorner = Instance.new("UICorner")
                rowCorner.CornerRadius = UDim.new(0, 4)
                rowCorner.Parent = row
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = row
                nameLabel.Position = UDim2.fromOffset(7, 0)
                nameLabel.Size = UDim2.new(1, -46, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = entry.name
                nameLabel.TextColor3 = Color3.fromRGB(222, 224, 236)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Font = Enum.Font.Code
                nameLabel.TextSize = 11
                nameLabel.ZIndex = 18
                local countLabel = Instance.new("TextLabel")
                countLabel.Parent = row
                countLabel.AnchorPoint = Vector2.new(1, 0.5)
                countLabel.Position = UDim2.new(1, -7, 0.5, 0)
                countLabel.Size = UDim2.fromOffset(34, 16)
                countLabel.BackgroundTransparency = 1
                countLabel.Text = entry.count > 1 and ("x" .. tostring(entry.count)) or ""
                countLabel.TextColor3 = uiAccentColor
                countLabel.TextXAlignment = Enum.TextXAlignment.Right
                countLabel.Font = Enum.Font.Code
                countLabel.TextSize = 10
                countLabel.ZIndex = 18
            end
        end
    end

    local function setInventoryViewerEnabled(value)
        inventoryViewer.enabled = value and true or false
        inventoryViewerRoot.Visible = inventoryViewer.enabled
        if inventoryViewer.enabled then
            renderInventoryViewer(true)
        end
        if inventoryViewer.refreshControls then
            pcall(inventoryViewer.refreshControls)
        end
    end

    table.insert(managedConnections, UIS.InputBegan:Connect(function(input, gameProcessed)
        if uiUnloaded then return end
        if inventoryViewer.capturing then
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.RightShift then return end
            inventoryViewer.capturing = false
            if input.KeyCode == Enum.KeyCode.Escape then
            elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                inventoryViewer.key = Enum.KeyCode.None
            else
                inventoryViewer.key = input.KeyCode
            end
            refreshInventoryKeybindLabel()
            if inventoryViewer.refreshControls then
                pcall(inventoryViewer.refreshControls)
            end
            return
        end
        if gameProcessed then return end
        if inventoryViewer.key ~= Enum.KeyCode.None and input.KeyCode == inventoryViewer.key then
            setInventoryViewerEnabled(not inventoryViewer.enabled)
        end
    end))

    table.insert(managedConnections, UIS.InputBegan:Connect(function(input, gameProcessed)
        if uiUnloaded then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if keybindCapture then
            if input.KeyCode == Enum.KeyCode.RightShift then return end
            local id = keybindCapture
            keybindCapture = nil
            if input.KeyCode == Enum.KeyCode.Escape then
                refreshKeybindRows()
            elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                KeybindSet(id, "None")
            else
                KeybindSet(id, input.KeyCode.Name)
            end
            return
        end
        if gameProcessed then return end
        for index = 1, #keybindEntries do
            local entry = keybindEntries[index]
            if entry.key ~= "None" and input.KeyCode.Name == entry.key then
                if entry.mode == "Hold" then
                    entry.held = true
                    pcall(entry.set, true)
                else
                    local ok, value = pcall(entry.get)
                    pcall(entry.set, not (ok and value))
                end
                refreshAllRows()
            end
        end
    end))

    table.insert(managedConnections, UIS.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for index = 1, #keybindEntries do
            local entry = keybindEntries[index]
            if entry.mode == "Hold" and entry.held and entry.key ~= "None" and input.KeyCode.Name == entry.key then
                entry.held = false
                pcall(entry.set, false)
                refreshAllRows()
            end
        end
    end))

    task.spawn(function()
        while HudGui.Parent do
            if inventoryViewer.enabled then
                pcall(renderInventoryViewer, false)
            end
            task.wait(1)
        end
    end)

    refreshInventoryKeybindLabel()
    if inventoryViewer.enabled then
        renderInventoryViewer(true)
    end

    local PlayersService = game:GetService("Players")
    local espState = {
        enabled = false,
        box = true,
        names = true,
        health = true,
        distance = true,
        visibility = true,
        tracer = false,
        chams = true,
        teamCheck = false,
        walls = true,
        maxDistance = 0,
        infinite = true,
        cornerBox = false,
        boxFill = false,
        skeleton = false,
        headDot = true,
    }
    local espColors = {
        box = Color3.fromRGB(20, 20, 25),
        boxFill = Color3.fromRGB(30, 30, 35),
        name = Color3.fromRGB(255, 255, 255),
        health = Color3.fromRGB(255, 255, 255),
        distance = Color3.fromRGB(255, 255, 255),
        tracer = Color3.fromRGB(0, 255, 0),
        chams = Color3.fromRGB(0, 255, 0),
        skeleton = Color3.fromRGB(0, 150, 0),
        headDot = Color3.fromRGB(0, 255, 0),
    }
    chamsState = {
        material = "Neon",
        materialOn = false,
        fillTransparency = 0.78,
        outline = false,
        outlineColor = Color3.fromRGB(255, 255, 255),
        outlineTransparency = 0.35,
        rainbow = false,
        pulse = false,
        strobe = false,
        saturation = 1,
        intensity = 0.5,
    }
    chamsOriginals = setmetatable({}, { __mode = "k" })
    espHealthStyle = {
        thickness = 2,
        glow = 5,
        version = 0,
    }
    espHealthColors = {
        top = Color3.fromRGB(0, 255, 0),
        bottom = Color3.fromRGB(0, 100, 0),
        version = 0,
    }
    local function espColor(key)
        return {
            get = function() return espColors[key] end,            set = function(color) espColors[key] = color end,
        }
    end
    local function applyHealthBarColors()
        local sequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, espHealthColors.top),
            ColorSequenceKeypoint.new(1, espHealthColors.bottom),
        })
        for _, entry in pairs(espEntries) do
            if entry.healthFillGradient then
                entry.healthFillGradient.Color = sequence
                entry.healthGlowGradient.Color = sequence
            end
        end
    end
    local aimState = {
        silentAim = false,
        instaHit = false,
        fov = 200,
        target = nil,
        targetPart = nil,
        lastScan = 0,
        lmbHeld = false,
        firing = false,
        lastShot = 0,
        eye = nil,
        manipOrigin = nil,
        internal = false,
        fle = nil,
        fleChecked = false,
    }

    gunModState = {
        removeMuzzle = false, removeSprintAnimation = false, rapidKnife = false, rapidKnifeRate = 1,
        noRecoil = false, noBob = false, noSpread = false, noDrop = false, noDrag = false,
        instantAim = false, instantEquip = false, instantReload = false, autoPackMags = false, autoReload = false,
        autoReloadAt = 0, autoRefill = false, unlockFiremodes = false, oneTap = false,
        rapidFire = false, rapidFireDelay = 0.05, forceAuto = false, multibullet = false, multibulletCount = 3,
        ignoreWater = false, fireUnderwater = false, removeWeight = false, doubleTap = false,
        instantMosin = false, noBolt = false, removeSandboxing = false, removeRechamber = false,
        meleeReach = false, meleeReachDist = 10, instantGrenade = false, removeAimRestrictions = false,
        sprintShoot = false, instantLean = false, noSway = false, noObstruct = false,
    }
    gunModAmmoOriginals = setmetatable({}, {__mode = "k"})
    gunModSpringOriginals = setmetatable({}, {__mode = "k"})
    gunModWeaponOriginals = setmetatable({}, {__mode = "k"})
    gunModFireUnderwaterOriginal = nil
    gunModFireUnderwaterModule = nil
    gunModMuzzleOriginals = setmetatable({}, { __mode = "k" })
    gunModAnimationHumanoids = setmetatable({}, { __mode = "k" })

    function gunModWatchHumanoid(humanoid)
        if not humanoid or not humanoid:IsA("Humanoid") or gunModAnimationHumanoids[humanoid] then return end
        local ok, connection = pcall(function()
            return humanoid.AnimationPlayed:Connect(function(track)
                local animation = track and track.Animation
                local animationName = animation and string.lower(animation.Name or "") or ""
                if gunModState.rapidKnife and (animationName == "use" or animationName == "usealt" or animationName == "stab") then
                    pcall(function() track:AdjustSpeed(gunModState.rapidKnifeRate) end)
                end
                if gunModState.instantEquip and string.find(animationName, "equip", 1, true) then
                    pcall(function()
                        track:AdjustSpeed(15)
                        track.TimePosition = math.max(0, track.Length - 0.01)
                    end)
                end
                if gunModState.removeSprintAnimation and string.find(animationName, "sprint", 1, true) then
                    pcall(function() track:Stop(0) end)
                end
            end)
        end)
        if ok and connection then
            gunModAnimationHumanoids[humanoid] = connection
            table.insert(managedConnections, connection)
        end
    end

    function gunModInstantEquipModel(child)
        if not gunModState.instantEquip then return end
        if not child:IsA("Model") then return end
        if child.Name == Player.Name then return end
        task.spawn(function()
            local iterations = 0
            while child.Parent and iterations < 500 do
                iterations += 1
                local humanoid = child:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Animator then
                    for _, track in ipairs(humanoid.Animator:GetPlayingAnimationTracks()) do
                        local animation = track.Animation
                        if animation and animation.Name == "Equip" then
                            pcall(function()
                                track:AdjustSpeed(15)
                                track.TimePosition = math.max(0, track.Length - 0.01)
                            end)
                            return
                        end
                    end
                end
                task.wait(0.001)
            end
        end)
    end

    function gunModWatchCamera(camera)
        if not camera then return end
        for _, child in ipairs(camera:GetChildren()) do
            if child:IsA("Model") and child.Name == "ViewModel" then
                gunModWatchHumanoid(child:FindFirstChildOfClass("Humanoid"))
            end
        end
        local connection = camera.ChildAdded:Connect(function(child)
            if child:IsA("Model") and child.Name == "ViewModel" then
                gunModWatchHumanoid(child:FindFirstChildOfClass("Humanoid") or child:WaitForChild("Humanoid", 5))
            end
            if child:IsA("Model") and VMChams then VMChams.Watch(child) end
            gunModInstantEquipModel(child)
        end)
        table.insert(managedConnections, connection)
    end

    gunModWatchCamera(workspace.CurrentCamera)

    VMChams = (function()
        local module = {
            armEnabled = false,
            gunEnabled = false,
            armColor = Color3.new(1, 1, 1),
            gunColor = Color3.new(1, 1, 1),
            armMaterial = "SmoothPlastic",
            gunMaterial = "SmoothPlastic",
            model = nil,
        }

        local function material(name)
            local ok, value = pcall(function() return Enum.Material[name] end)
            if ok and value then return value end
            return Enum.Material.SmoothPlastic
        end

        function module.Apply()
            local vm = module.model
            if not vm or not vm.Parent then return end
            if not (module.gunEnabled or module.armEnabled) then return end
            local gunMaterial = material(module.gunMaterial)
            local armMaterial = material(module.armMaterial)
            local item = vm:FindFirstChild("Item")
            if item and module.gunEnabled then
                for _, part in ipairs(item:GetDescendants()) do
                    if (part:IsA("MeshPart") or part:IsA("BasePart")) and part.Transparency < 1
                        and part.Name ~= "Muzzle" and part.Name ~= "SightMark" and part.Name ~= "AimPart" then
                        pcall(function()
                            part.Material = gunMaterial
                            part.Color = module.gunColor
                            local appearance = part:FindFirstChildOfClass("SurfaceAppearance")
                            if appearance then appearance:Destroy() end
                        end)
                    end
                end
            end
            if module.armEnabled then
                for _, vmItem in ipairs(vm:GetChildren()) do
                    if vmItem:IsA("MeshPart") and (vmItem.Name:find("Hand") or vmItem.Name:find("Arm")) then
                        pcall(function()
                            vmItem.Material = armMaterial
                            vmItem.Color = module.armColor
                        end)
                    elseif vmItem:IsA("Model") and (vmItem:FindFirstChild("LL") or vmItem:FindFirstChild("LH")) then
                        for _, part in ipairs(vmItem:GetChildren()) do
                            if part:IsA("BasePart") then
                                pcall(function()
                                    part.Material = armMaterial
                                    part.Color = module.armColor
                                    local appearance = part:FindFirstChildOfClass("SurfaceAppearance")
                                    if appearance then appearance:Destroy() end
                                end)
                            end
                        end
                    end
                end
            end
        end

        function module.Watch(model)
            if not model then return end
            module.model = model
            task.defer(function()
                if module.model == model then module.Apply() end
            end)
        end

        function module.Refresh()
            module.Apply()
        end

        return module
    end)()

    do
        local camera = workspace.CurrentCamera
        local existing = camera and camera:FindFirstChildOfClass("Model")
        if existing then VMChams.Watch(existing) end
    end

    function gunModApplyAmmo()
        local folder = ReplicatedStorage:FindFirstChild("AmmoTypes")
        if not folder then return end
        for _, ammo in ipairs(folder:GetChildren()) do
            if not gunModAmmoOriginals[ammo] then
                gunModAmmoOriginals[ammo] = {
                    drop = ammo:GetAttribute("ProjectileDrop"),
                    drag = ammo:GetAttribute("Drag"),
                }
            end
            local original = gunModAmmoOriginals[ammo]
            pcall(function()
                ammo:SetAttribute("ProjectileDrop", gunModState.noDrop and 0 or original.drop)
                ammo:SetAttribute("Drag", gunModState.noDrag and 0 or original.drag)
            end)
        end
    end
    mwPortAmmoFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")
    if mwPortAmmoFolder then
        table.insert(managedConnections, mwPortAmmoFolder.ChildAdded:Connect(function()
            task.defer(gunModApplyAmmo)
        end))
    end

    function gunModSetUnderwater(enabled)
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local library = modules and modules:FindFirstChild("FunctionLibraryExtension")
        if not library then return end
        local ok, mod = pcall(require, library)
        if not ok or type(mod) ~= "table" or type(mod.IsCharacterUnderWater) ~= "function" then return end
        if gunModFireUnderwaterModule ~= mod then
            gunModFireUnderwaterModule = mod
            gunModFireUnderwaterOriginal = mod.IsCharacterUnderWater
        end
        if enabled then
            mod.IsCharacterUnderWater = function() return false end
        elseif gunModFireUnderwaterOriginal then
            mod.IsCharacterUnderWater = gunModFireUnderwaterOriginal
        end
    end

    function gunModScanInternals()
        if type(getgc) ~= "function" or type(hookfunction) ~= "function" then return end
        local ok, objects = pcall(getgc, true)
        if not ok or type(objects) ~= "table" then return end
        for _, object in ipairs(objects) do
            if type(object) == "table" then
                local shove, update = rawget(object, "shove"), rawget(object, "update")
                if type(shove) == "function" and type(update) == "function" and not gunModWeaponOriginals[object] then
                    gunModWeaponOriginals[object] = true
                    local oldShove, oldUpdate
                    pcall(function()
                        oldShove = hookfunction(shove, function(...)
                            if gunModState.noRecoil then return end
                            return oldShove(...)
                        end)
                    end)
                    pcall(function()
                        oldUpdate = hookfunction(update, function(...)
                            if gunModState.noBob then return Vector3.zero end
                            return oldUpdate(...)
                        end)
                    end)
                end
                local springCreate = rawget(object, "create")
                if type(springCreate) == "function" and not gunModWeaponOriginals[springCreate] then
                    local sourceName = ""
                    pcall(function() sourceName = debug.getinfo(springCreate).short_src or "" end)
                    if string.find(sourceName, "SpringV2", 1, true) then
                        gunModWeaponOriginals[springCreate] = true
                        local originalCreate
                        pcall(function()
                            originalCreate = hookfunction(springCreate, function(...)
                                local result = originalCreate(...)
                                if type(result) == "table" then
                                    local oldShove, oldUpdate = result.shove, result.update
                                    if type(oldShove) == "function" then
                                        result.shove = function(...)
                                            if gunModState.noRecoil then return end
                                            return oldShove(...)
                                        end
                                    end
                                    if type(oldUpdate) == "function" then
                                        result.update = function(...)
                                            if gunModState.noBob then return Vector3.zero end
                                            return oldUpdate(...)
                                        end
                                    end
                                end
                                return result
                            end)
                        end)
                    end
                end
                local updateClient = rawget(object, "updateClient")
                if type(updateClient) == "function" and not gunModWeaponOriginals[updateClient] then
                    gunModWeaponOriginals[updateClient] = true
                    local original
                    pcall(function()
                        original = hookfunction(updateClient, function(...)
                            local args = table.pack(...)
                            local settings = args[1]
                            if type(settings) == "table" then
                                if gunModState.instantAim then
                                    settings.AimInSpeed, settings.AimOutSpeed = 0, 0
                                end
                                if gunModState.forceAuto then settings.FireMode = "Auto" end
                                if gunModState.unlockFiremodes then settings.FireModes = {"Auto", "Semi"} end
                                if gunModState.rapidFire then settings.FireRate = gunModState.rapidFireDelay end
                                if gunModState.noBolt and type(settings.CycleTiming) == "table" then
                                    settings.CycleTiming[1], settings.CycleTiming[2] = 0, 0
                                end
                            end
                            return original(table.unpack(args, 1, args.n))
                        end)
                    end)
                end
            end
        end
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local fps = modules and modules:FindFirstChild("FPS")
        local bulletScript = fps and fps:FindFirstChild("Bullet")
        if bulletScript and type(require) == "function" then
            local ok, bullet = pcall(require, bulletScript)
            if ok and type(bullet) == "table" and type(bullet.CreateBullet) == "function" and not gunModWeaponOriginals[bullet] then
                local original = bullet.CreateBullet
                gunModWeaponOriginals[bullet] = true
                bullet.CreateBullet = function(...)
                    local args = table.pack(...)
                    local hasAimPart = false
                    for i = 1, args.n do
                        if typeof(args[i]) == "Instance" and args[i].Name == "AimPart" then
                            hasAimPart = true
                            break
                        end
                    end
                    local result = table.pack(original(table.unpack(args, 1, args.n)))
                    if hasAimPart and (gunModState.multibullet or gunModState.doubleTap or gunModState.oneTap) then
                        local count = gunModState.oneTap and 10 or (gunModState.doubleTap and 2 or math.clamp(math.floor(gunModState.multibulletCount), 1, 12))
                        for _ = 2, count do pcall(original, table.unpack(args, 1, args.n)) end
                    end
                    return table.unpack(result, 1, result.n)
                end
            end
        end
    end
    task.spawn(function()
        while not uiUnloaded do
            gunModScanInternals()
            task.wait(2)
        end
    end)
    task.spawn(function()
        local springTable
        while not uiUnloaded and not springTable do
            if type(getgc) == "function" then
                local ok, gc = pcall(getgc, true)
                if ok and type(gc) == "table" then
                    for _, item in ipairs(gc) do
                        if type(item) == "table" then
                            local springs = rawget(item, "springs")
                            local sway = type(springs) == "table" and rawget(springs, "sway") or nil
                            if type(sway) == "table" and typeof(rawget(sway, "Position")) == "Vector3" then
                                springTable = springs
                                break
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
        if not springTable then return end
        local originals = {}
        for _, name in ipairs({"leanAlpha", "sway", "wallTouchTilt"}) do
            local spring = rawget(springTable, name)
            if type(spring) == "table" then
                originals[name] = {rawget(spring, "Force"), rawget(spring, "Speed"), rawget(spring, "Position")}
            end
        end
        while not uiUnloaded do
            local rules = {
                {"leanAlpha", gunModState.instantLean, originals.leanAlpha and originals.leanAlpha[1], 50},
                {"sway", gunModState.noSway, 0, 0},
                {"wallTouchTilt", gunModState.noObstruct, 0, 0},
            }
            for _, rule in ipairs(rules) do
                local spring, saved = rawget(springTable, rule[1]), originals[rule[1]]
                if type(spring) == "table" and saved then
                    pcall(function()
                        if rule[2] then
                            rawset(spring, "Force", rule[3])
                            rawset(spring, "Speed", rule[4])
                            if rule[1] == "sway" then rawset(spring, "Position", Vector3.zero) end
                        else
                            rawset(spring, "Force", saved[1])
                            rawset(spring, "Speed", saved[2])
                            rawset(spring, "Position", saved[3])
                        end
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
    gunModSprintWas = setmetatable({}, {__mode = "k"})
    gunModSprintShots = setmetatable({}, {__mode = "k"})
    gunModRechamberOriginals = setmetatable({}, {__mode = "k"})
    task.spawn(function()
        while not uiUnloaded do
            if type(getgc) == "function" then
                local ok, gc = pcall(getgc, true)
                if ok and type(gc) == "table" then
                    for _, weapon in ipairs(gc) do
                        if type(weapon) == "table" then
                            local looksLikeWeapon = rawget(weapon, "settings") ~= nil
                                or rawget(weapon, "RecoilPatternPos") ~= nil
                                or rawget(weapon, "useDebounce") ~= nil
                                or rawget(weapon, "TouchWallPosY") ~= nil
                            if looksLikeWeapon then
                                pcall(function()
                                    if gunModState.sprintShoot then
                                        local previous = gunModSprintShots[weapon]
                                        local recoilPosition = rawget(weapon, "RecoilPatternPos")
                                        if gunModSprintWas[weapon] and rawget(weapon, "sprinting") == false
                                            and type(recoilPosition) == "number" and type(previous) == "number"
                                            and recoilPosition > previous then
                                            local gameplaySettings = rawget(weapon, "GameplaySettings")
                                            local toggleSprint = typeof(gameplaySettings) == "Instance"
                                                and gameplaySettings:GetAttribute("ToggleSprint") == true
                                            if rawget(weapon, "SprintButtonHeld") == true or toggleSprint then
                                                rawset(weapon, "sprinting", true)
                                                local playerRef = rawget(weapon, "rs_Player")
                                                local status = typeof(playerRef) == "Instance" and playerRef:FindFirstChild("Status")
                                                local variables = status and status:FindFirstChild("GameplayVariables")
                                                local sprintValue = variables and variables:FindFirstChild("Sprinting")
                                                if sprintValue then pcall(function() sprintValue:SetAttribute("Value", true) end) end
                                            end
                                        end
                                        gunModSprintShots[weapon] = recoilPosition
                                        gunModSprintWas[weapon] = rawget(weapon, "sprinting") == true
                                    else
                                        gunModSprintWas[weapon], gunModSprintShots[weapon] = nil, nil
                                    end
                                    local settings = rawget(weapon, "settings")
                                    if type(settings) == "table" then
                                        local cycle = rawget(settings, "CycleTiming")
                                        if type(cycle) == "table" then
                                            if gunModState.noBolt then
                                                if not gunModWeaponOriginals[cycle] then gunModWeaponOriginals[cycle] = {cycle[1], cycle[2]} end
                                                cycle[1], cycle[2] = 0, 0
                                            elseif type(gunModWeaponOriginals[cycle]) == "table" then
                                                cycle[1], cycle[2] = gunModWeaponOriginals[cycle][1], gunModWeaponOriginals[cycle][2]
                                                gunModWeaponOriginals[cycle] = nil
                                            end
                                        end
                                        local moduleName = rawget(settings, "useModuleName")
                                        local throwDelay = rawget(settings, "GrenadeThrowDelay")
                                        if (moduleName == "GrenadeDefault" or moduleName == "FlareDefault") and type(throwDelay) == "number" then
                                            if gunModState.instantGrenade then
                                                if gunModWeaponOriginals[settings] == nil then gunModWeaponOriginals[settings] = throwDelay end
                                                rawset(settings, "GrenadeThrowDelay", 0)
                                            elseif type(gunModWeaponOriginals[settings]) == "number" then
                                                rawset(settings, "GrenadeThrowDelay", gunModWeaponOriginals[settings])
                                                gunModWeaponOriginals[settings] = nil
                                            end
                                        end
                                    end
                                    local touchWallY = rawget(weapon, "TouchWallPosY")
                                    if touchWallY and (gunModState.noObstruct or gunModState.removeSandboxing) then
                                        if not gunModWeaponOriginals[weapon] then
                                            gunModWeaponOriginals[weapon] = {touchWallY, rawget(weapon, "TouchWallPosZ"), rawget(weapon, "TouchWallRotX"), rawget(weapon, "TouchWallRotY")}
                                        end
                                        rawset(weapon, "TouchWallPosY", 0)
                                        rawset(weapon, "TouchWallPosZ", 0)
                                        rawset(weapon, "TouchWallRotX", 0)
                                        rawset(weapon, "TouchWallRotY", 0)
                                    elseif type(gunModWeaponOriginals[weapon]) == "table" and touchWallY then
                                        local saved = gunModWeaponOriginals[weapon]
                                        rawset(weapon, "TouchWallPosY", saved[1])
                                        rawset(weapon, "TouchWallPosZ", saved[2])
                                        rawset(weapon, "TouchWallRotX", saved[3])
                                        rawset(weapon, "TouchWallRotY", saved[4])
                                        gunModWeaponOriginals[weapon] = nil
                                    end
                                    local debounce = rawget(weapon, "useDebounce")
                                    if debounce ~= nil then
                                        if gunModState.removeRechamber then
                                            if gunModRechamberOriginals[weapon] == nil then gunModRechamberOriginals[weapon] = debounce end
                                            rawset(weapon, "useDebounce", false)
                                        elseif gunModRechamberOriginals[weapon] ~= nil then
                                            rawset(weapon, "useDebounce", gunModRechamberOriginals[weapon])
                                            gunModRechamberOriginals[weapon] = nil
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.25)
        end
    end)
    if mwPortAmmoFolder then task.defer(gunModApplyAmmo) end
    gunModMosinOriginals = setmetatable({}, {__mode = "k"})
    function gunModSetMosin(enabled)
        local folder = ReplicatedStorage:FindFirstChild("AmmoTypes")
        if not folder then return end
        for _, ammo in ipairs(folder:GetChildren()) do
            if enabled then
                if gunModMosinOriginals[ammo] == nil then gunModMosinOriginals[ammo] = ammo:GetAttribute("RecoilStrength") or false end
                ammo:SetAttribute("RecoilStrength", 1)
            elseif gunModMosinOriginals[ammo] ~= nil then
                ammo:SetAttribute("RecoilStrength", gunModMosinOriginals[ammo] ~= false and gunModMosinOriginals[ammo] or nil)
                gunModMosinOriginals[ammo] = nil
            end
        end
    end
    gunModPackRemote, gunModPackLast = nil, 0
    table.insert(managedConnections, RunService.Heartbeat:Connect(function()
        if not gunModState.autoPackMags or os.clock() - gunModPackLast < 0.5 then return end
        gunModPackLast = os.clock()
        if not (gunModPackRemote and gunModPackRemote.Parent) then
            gunModPackRemote = nil
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                for _, remote in ipairs(remotes:GetDescendants()) do
                    if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                        local name = string.lower(remote.Name)
                        if string.find(name, "pack", 1, true) and (string.find(name, "mag", 1, true) or string.find(name, "ammo", 1, true)) then
                            gunModPackRemote = remote
                            break
                        end
                    end
                end
            end
        end
        if gunModPackRemote then
            pcall(function()
                if gunModPackRemote:IsA("RemoteEvent") then gunModPackRemote:FireServer() else gunModPackRemote:InvokeServer() end
            end)
        end
    end))
    function gunModInventory()
        local playersFolder = ReplicatedStorage:FindFirstChild("Players")
        local localData = playersFolder and playersFolder:FindFirstChild(Player.Name)
        return localData and localData:FindFirstChild("Inventory")
    end
    function gunModCurrentWeapon()
        local playersFolder = ReplicatedStorage:FindFirstChild("Players")
        local localData = playersFolder and playersFolder:FindFirstChild(Player.Name)
        local status = localData and localData:FindFirstChild("Status")
        local variables = status and status:FindFirstChild("GameplayVariables")
        local equipped = variables and variables:FindFirstChild("EquippedTool")
        local inventory = gunModInventory()
        return equipped and equipped.Value ~= "" and inventory and inventory:FindFirstChild(equipped.Value), inventory
    end
    gunModReloadRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Reload")
    gunModInventoryMove = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("InventoryMove")
    gunModReloadHooks = setmetatable({}, {__mode = "k"})
    function gunModBestMagazine(weaponData)
        local properties = weaponData and weaponData.itemProperties
        local compatible = properties and properties.CompatibleMagazines
        local inventory = gunModInventory()
        if not compatible or not inventory then return nil end
        local best, bestCount
        for _, container in ipairs(inventory:GetChildren()) do
            local storage = container:FindFirstChild("Inventory")
            if storage then
                for _, magazine in ipairs(storage:GetChildren()) do
                    local count = magazine:GetAttribute("LoadedAmmo") or 0
                    if compatible:GetAttribute(magazine.Name) and (not bestCount or count > bestCount) then
                        best, bestCount = magazine, count
                    end
                end
            end
        end
        return best
    end
    function gunModFindAmmo(weaponData, requested)
        local needed = (weaponData.MaxAmmo or 0) - (weaponData.Bullets or 0)
        local amount = requested and (requested:GetAttribute("Amount") or 0) or 0
        if needed <= 0 or (requested and amount > 0) then return requested, math.min(needed, amount) end
        local properties = weaponData.itemProperties
        local compatible = properties and properties.CompatibleAmmo
        local preferred = properties and properties:GetAttribute("PreferredAmmo")
        local inventory = gunModInventory()
        if not compatible or not inventory then return nil, 0 end
        local best, bestCount
        for _, container in ipairs(inventory:GetChildren()) do
            local storage = container:FindFirstChild("Inventory")
            if storage then
                for _, item in ipairs(storage:GetChildren()) do
                    local count = item:GetAttribute("Amount") or 0
                    if compatible:GetAttribute(item.Name) and (not preferred or preferred == item.Name) then
                        if not bestCount or count > bestCount then best, bestCount = item, count end
                    end
                end
            end
        end
        return best, math.min(needed, bestCount or 0)
    end
    task.spawn(function()
        while not uiUnloaded do
            if gunModState.instantReload and type(getgc) == "function" and type(debug) == "table" then
                local ok, gc = pcall(getgc, true)
                if ok and type(gc) == "table" then
                    for _, reloadTable in ipairs(gc) do
                        if type(reloadTable) == "table" and type(rawget(reloadTable, "magazine")) == "function"
                            and type(rawget(reloadTable, "loadByHand")) == "function" and not gunModReloadHooks[reloadTable] then
                            gunModReloadHooks[reloadTable] = true
                            local oldMagazine, oldHand = reloadTable.magazine, reloadTable.loadByHand
                            reloadTable.magazine = function(weaponData, magazine)
                                if not gunModState.instantReload then return oldMagazine(weaponData, magazine) end
                                local selected = magazine or gunModBestMagazine(weaponData)
                                if not selected or weaponData.useDebounce then return end
                                if weaponData.Scope or (weaponData.sight and weaponData.sight:GetAttribute("NoReloadAim")) then
                                    pcall(function() weaponData:aim(false) end)
                                end
                                for _, tracks in ipairs({weaponData.clientAnimationTracks, weaponData.serverAnimationTracks}) do
                                    if type(tracks) == "table" then
                                        for _, name in ipairs({"Inspect", "Use", "Reload", "ReloadEnter", "ReloadLoop", "ReloadChamber", "BoltOpen"}) do
                                            if tracks[name] then pcall(tracks[name].Stop, tracks[name], 0) end
                                        end
                                    end
                                end
                                if gunModReloadRemote then
                                    local mode = weaponData.Bullets == 0 and 2 or 1
                                    task.spawn(function() pcall(function() gunModReloadRemote:InvokeServer(nil, mode, selected) end) end)
                                end
                                weaponData.reloading = false
                                weaponData.useDebounce = false
                                weaponData.RecoilPatternPos = 0
                            end
                            reloadTable.loadByHand = function(weaponData, ammo)
                                if not gunModState.instantReload then return oldHand(weaponData, ammo) end
                                if weaponData.useDebounce then return end
                                local selected, count = gunModFindAmmo(weaponData, ammo)
                                if not selected or count <= 0 or not gunModReloadRemote then return end
                                for _, name in ipairs({"Inspect", "Reload", "ReloadEnter", "ReloadLoop"}) do
                                    local track = weaponData.clientAnimationTracks and weaponData.clientAnimationTracks[name]
                                    if track then pcall(track.Stop, track, 0) end
                                end
                                task.spawn(function()
                                    for _ = 1, count do pcall(function() gunModReloadRemote:InvokeServer(nil, 1, selected) end) end
                                end)
                                weaponData.reloading = false
                                weaponData.useDebounce = false
                                weaponData.cancellingReload = false
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
    gunModReloadBusy = false
    gunModRefillLast = 0
    table.insert(managedConnections, RunService.Heartbeat:Connect(function()
        if gunModState.autoReload and not gunModReloadBusy and gunModReloadRemote then
            local weapon, inventory = gunModCurrentWeapon()
            local attachments = weapon and weapon:FindFirstChild("Attachments")
            local currentMagazine
            if attachments then
                for _, item in ipairs(attachments:GetChildren()) do
                    if item:GetAttribute("LoadedAmmo") ~= nil and (item:GetAttribute("Slot") == "Magazine" or not currentMagazine) then
                        currentMagazine = item
                        if item:GetAttribute("Slot") == "Magazine" then break end
                    end
                end
            end
            local ammoLeft = currentMagazine and currentMagazine:GetAttribute("LoadedAmmo")
            if type(ammoLeft) == "number" and ammoLeft <= gunModState.autoReloadAt then
                local compatible = weapon and (weapon:FindFirstChild("CompatibleMagazines") or (weapon:FindFirstChild("ItemProperties") and weapon.ItemProperties:FindFirstChild("CompatibleMagazines")))
                local best, bestCount
                if inventory then
                    for _, container in ipairs(inventory:GetChildren()) do
                        local storage = container:FindFirstChild("Inventory")
                        if storage then
                            for _, magazine in ipairs(storage:GetChildren()) do
                                local count = magazine:GetAttribute("LoadedAmmo")
                                if type(count) == "number" and count > 0 and (not compatible or compatible:GetAttribute(magazine.Name) ~= nil) then
                                    if not bestCount or count > bestCount then best, bestCount = magazine, count end
                                end
                            end
                        end
                    end
                end
                if best then
                    gunModReloadBusy = true
                    task.spawn(function()
                        pcall(function() gunModReloadRemote:InvokeServer(nil, 1, best) end)
                        task.wait(0.35)
                        gunModReloadBusy = false
                    end)
                end
            end
        end
        if gunModState.autoRefill and os.clock() - gunModRefillLast >= 0.5 and gunModInventoryMove then
            gunModRefillLast = os.clock()
            local weapon, inventory = gunModCurrentWeapon()
            local attachments = weapon and weapon:FindFirstChild("Attachments")
            if attachments and inventory then
                local magazine
                for _, item in ipairs(attachments:GetChildren()) do
                    if item:GetAttribute("LoadedAmmo") ~= nil then magazine = item; if item:GetAttribute("Slot") == "Magazine" then break end end
                end
                local loaded = magazine and magazine:GetAttribute("LoadedAmmo")
                local maximum = magazine and magazine:GetAttribute("MaxLoadedAmmo")
                if magazine and type(loaded) == "number" and loaded < (maximum or 30) then
                    local itemsList = ReplicatedStorage:FindFirstChild("ItemsList")
                    local itemData = itemsList and itemsList:FindFirstChild(magazine.Name)
                    local compatibleAmmo = itemData and itemData:FindFirstChild("ItemProperties")
                        and itemData.ItemProperties:FindFirstChild("CompatibleAmmo")
                    local found
                    if compatibleAmmo then
                        for _, container in ipairs(inventory:GetChildren()) do
                            local storage = container:FindFirstChild("Inventory")
                            if storage then
                                for _, ammo in ipairs(storage:GetChildren()) do
                                    if (ammo:GetAttribute("Amount") or 0) > 0 and compatibleAmmo:GetAttribute(ammo.Name) then
                                        found = ammo
                                        break
                                    end
                                end
                            end
                            if found then break end
                        end
                    end
                    if found then
                        pcall(function()
                            gunModInventoryMove:FireServer(found:GetAttribute("Slot"), magazine:GetAttribute("Slot"), found.Parent, magazine.Parent, nil)
                        end)
                    end
                end
            end
        end
    end))
    if mwPortAmmoFolder then
        table.insert(managedConnections, mwPortAmmoFolder.ChildAdded:Connect(function()
            task.defer(function()
                gunModApplyAmmo()
                if gunModState.instantMosin then gunModSetMosin(true) end
            end)
        end))
    end
    ScreenGui.Destroying:Connect(function()
        for key in pairs(gunModState) do
            if type(gunModState[key]) == "boolean" then gunModState[key] = false end
        end
        pcall(gunModSetUnderwater, false)
        for ammo, saved in pairs(gunModAmmoOriginals) do
            if ammo and ammo.Parent then
                pcall(function()
                    ammo:SetAttribute("ProjectileDrop", saved.drop)
                    ammo:SetAttribute("Drag", saved.drag)
                end)
            end
        end
        for ammo, saved in pairs(gunModMosinOriginals) do
            if ammo and ammo.Parent then
                pcall(function() ammo:SetAttribute("RecoilStrength", saved ~= false and saved or nil) end)
            end
        end
        for object, saved in pairs(gunModMuzzleOriginals) do
            if object and object.Parent and saved ~= nil then pcall(function() object.Enabled = saved end) end
        end
        for weapon, saved in pairs(gunModRechamberOriginals) do
            if weapon then pcall(function() weapon.useDebounce = saved end) end
        end
        for object, saved in pairs(gunModWeaponOriginals) do
            if type(saved) == "table" and object then
                pcall(function()
                    if #saved == 2 and object[1] ~= nil then object[1], object[2] = saved[1], saved[2]
                    elseif #saved == 4 and object.TouchWallPosY ~= nil then
                        object.TouchWallPosY, object.TouchWallPosZ, object.TouchWallRotX, object.TouchWallRotY = saved[1], saved[2], saved[3], saved[4]
                    elseif type(saved) == "number" and object.GrenadeThrowDelay ~= nil then
                        object.GrenadeThrowDelay = saved
                    end
                end)
            end
        end
    end)

    mwPortCurrentCharacter = Player.Character
    if mwPortCurrentCharacter then
        gunModWatchHumanoid(mwPortCurrentCharacter:FindFirstChildOfClass("Humanoid"))
    end
    table.insert(managedConnections, Player.CharacterAdded:Connect(function(character)
        gunModWatchHumanoid(character:WaitForChild("Humanoid", 5))
    end))
    table.insert(managedConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        gunModWatchCamera(workspace.CurrentCamera)
    end))

    gunModScanElapsed = 0
    table.insert(managedConnections, RunService.Heartbeat:Connect(function(deltaTime)
        gunModScanElapsed = gunModScanElapsed + deltaTime
        if gunModScanElapsed < 0.2 then return end
        gunModScanElapsed = 0
        local camera = workspace.CurrentCamera
        local viewModel = camera and camera:FindFirstChild("ViewModel")
        if viewModel then
            for _, object in ipairs(viewModel:GetDescendants()) do
                if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                    local effectName = string.lower(object.Name or "")
                    if string.find(effectName, "muzzle", 1, true) or string.find(effectName, "flash", 1, true) then
                        if gunModMuzzleOriginals[object] == nil then
                            gunModMuzzleOriginals[object] = object.Enabled
                        end
                        if gunModState.removeMuzzle then
                            object.Enabled = false
                        elseif gunModMuzzleOriginals[object] ~= nil then
                            object.Enabled = gunModMuzzleOriginals[object]
                            gunModMuzzleOriginals[object] = nil
                        end
                    end
                end
            end
        end
    end))

    local function characterAlive(character)
        if not character then return false end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        return humanoid ~= nil and humanoid.Health > 0
    end

    local function onSameTeam(otherPlayer)
        if otherPlayer == Player then return true end
        if not espState.teamCheck then return false end
        if not Player.Team or not otherPlayer.Team then return false end
        return Player.Team == otherPlayer.Team
    end

    espGui = Instance.new("ScreenGui")
    espGui.Name = "OmniESP"
    espGui.ResetOnSpawn = false
    espGui.IgnoreGuiInset = true
    espGui.DisplayOrder = 9990
    espGui.Enabled = true
    espGui.Parent = Player:WaitForChild("PlayerGui")

    local espLayer = Instance.new("Frame")
    espLayer.Name = "ESPLayer"
    espLayer.Parent = espGui
    espLayer.Size = UDim2.fromScale(1, 1)
    espLayer.BackgroundTransparency = 1
    espLayer.BorderSizePixel = 0
    espLayer.Visible = espState.enabled

    local visualPortState = {
        corpses = false, ai = false, bosses = false, extractions = false, droppedItems = false,
        corpseDistance = true, aiDistance = true, bossDistance = true, snaplines = false,
        radar = false, radarRange = 250,
    }
    local visualPortEntries = setmetatable({}, {__mode = "k"})
    local bossNames = {Anton=true, Dozer=true, Whisper=true, ScavKing=true, Grif=true, BTR80=true, MI24V=true}
    local function visualPortPart(model)
        if not model then return nil end
        if model:IsA("BasePart") then return model end
        return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Head") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    end
    local function visualPortDestroy(model)
        local entry = visualPortEntries[model]
        if not entry then return end
        if entry.gui then pcall(function() entry.gui:Destroy() end) end
        if entry.highlight then pcall(function() entry.highlight:Destroy() end) end
        visualPortEntries[model] = nil
    end
    local function visualPortCreate(model, kind)
        if not model or visualPortEntries[model] then return end
        local part = visualPortPart(model)
        if not part then return end
        local color = kind == "AI" and Color3.fromRGB(255, 185, 90)
            or kind == "Boss" and Color3.fromRGB(255, 90, 110)
            or kind == "Corpse" and Color3.fromRGB(80, 255, 140)
            or kind == "Exit" and Color3.fromRGB(80, 255, 180)
            or Color3.fromRGB(255, 170, 70)
        local gui = Instance.new("BillboardGui")
        gui.Name = "Omni" .. kind .. "Overlay"
        gui.Adornee = part
        gui.Size = UDim2.fromOffset(180, 28)
        gui.StudsOffset = Vector3.new(0, 2.5, 0)
        gui.AlwaysOnTop = true
        gui.Enabled = false
        gui.Parent = espGui
        local label = Instance.new("TextLabel")
        label.Parent = gui
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextColor3 = color
        label.TextStrokeTransparency = 0.15
        label.Text = kind .. ": " .. model.Name
        local highlight
        if kind == "AI" or kind == "Boss" or kind == "Dropped" then
            highlight = Instance.new("Highlight")
            highlight.Name = "Omni" .. kind .. "Highlight"
            highlight.Adornee = model
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.82
            highlight.OutlineTransparency = 0.1
            highlight.Enabled = false
            highlight.Parent = espGui
        end
        visualPortEntries[model] = {kind=kind, part=part, gui=gui, label=label, highlight=highlight, color=color}
    end
    local function visualPortScan()
        local dropped = workspace:FindFirstChild("DroppedItems")
        if dropped then
            for _, model in ipairs(dropped:GetChildren()) do
                if model:IsA("Model") then
                    if model:FindFirstChildOfClass("Humanoid") then
                        if visualPortState.corpses then visualPortCreate(model, "Corpse") end
                    elseif visualPortState.droppedItems then
                        visualPortCreate(model, "Dropped")
                    end
                end
            end
        end
        local zones = workspace:FindFirstChild("AiZones")
        if zones then
            for _, zone in ipairs(zones:GetChildren()) do
                for _, model in ipairs(zone:GetChildren()) do
                    if model:IsA("Model") then
                        if visualPortState.bosses and bossNames[model.Name] then
                            visualPortCreate(model, "Boss")
                        elseif visualPortState.ai and model:FindFirstChildOfClass("Humanoid") then
                            visualPortCreate(model, "AI")
                        end
                    end
                end
            end
        end
        local noCollision = workspace:FindFirstChild("NoCollision")
        local exits = noCollision and noCollision:FindFirstChild("ExitLocations")
        if exits and visualPortState.extractions then
            for _, item in ipairs(exits:GetChildren()) do
                if item:IsA("Model") or item:IsA("BasePart") then visualPortCreate(item, "Exit") end
            end
        end
        for model, entry in pairs(visualPortEntries) do
            local active = (entry.kind == "Corpse" and visualPortState.corpses)
                or (entry.kind == "AI" and visualPortState.ai)
                or (entry.kind == "Boss" and visualPortState.bosses)
                or (entry.kind == "Exit" and visualPortState.extractions)
                or (entry.kind == "Dropped" and visualPortState.droppedItems)
            if not model.Parent or not active then visualPortDestroy(model) end
        end
    end
    _G.__OmniVisualPort = { state = visualPortState, scan = function() return visualPortScan() end }

    visualPortScanElapsed = 0
    table.insert(managedConnections, RunService.Heartbeat:Connect(function(dt)
        visualPortScanElapsed += dt
        if visualPortScanElapsed >= 1 then
            visualPortScanElapsed = 0
            _G.__OmniVisualPort.scan()
        end
        local camera = workspace.CurrentCamera
        local character = Player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        for model, entry in pairs(visualPortEntries) do
            local enabled = entry.kind == "Corpse" and _G.__OmniVisualPort.state.corpses
                or entry.kind == "AI" and _G.__OmniVisualPort.state.ai
                or entry.kind == "Boss" and _G.__OmniVisualPort.state.bosses
                or entry.kind == "Exit" and _G.__OmniVisualPort.state.extractions
                or entry.kind == "Dropped" and _G.__OmniVisualPort.state.droppedItems
            local part = entry.part
            if not model.Parent or not part or not part.Parent then
                visualPortDestroy(model)
            else
                local distance = root and math.floor((root.Position - part.Position).Magnitude / 4) or nil
                local kindName = entry.kind
                entry.label.Text = kindName .. ": " .. model.Name .. (distance and (" [" .. distance .. "m]") or "")
                entry.gui.Enabled = enabled and camera ~= nil
                if entry.highlight then entry.highlight.Enabled = enabled end
            end
        end
    end))

    radarFrame = Instance.new("Frame")
    radarFrame.Name = "OmniRadar"
    radarFrame.Parent = espGui
    radarFrame.AnchorPoint = Vector2.new(1, 0)
    radarFrame.Position = UDim2.new(1, -22, 0, 86)
    radarFrame.Size = UDim2.fromOffset(156, 156)
    radarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    radarFrame.BackgroundTransparency = 0.2
    radarFrame.BorderSizePixel = 0
    radarFrame.Visible = false
    radarCorner = Instance.new("UICorner")
    radarCorner.CornerRadius = UDim.new(1, 0)
    radarCorner.Parent = radarFrame
    radarStroke = Instance.new("UIStroke")
    radarStroke.Color = uiAccentColor
    radarStroke.Transparency = 0.25
    radarStroke.Parent = radarFrame
    radarCenter = Instance.new("Frame")
    radarCenter.Parent = radarFrame
    radarCenter.AnchorPoint = Vector2.new(0.5, 0.5)
    radarCenter.Position = UDim2.fromScale(0.5, 0.5)
    radarCenter.Size = UDim2.fromOffset(5, 5)
    radarCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    radarCenter.BorderSizePixel = 0
    radarDots = {}
    function radarDotFor(player)
        if radarDots[player] then return radarDots[player] end
        local dot = Instance.new("Frame")
        dot.Name = "RadarDot"
        dot.Parent = radarFrame
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
        dot.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        radarDots[player] = dot
        return dot
    end
    table.insert(managedConnections, RunService.RenderStepped:Connect(function()
        radarFrame.Visible = _G.__OmniVisualPort.state.radar
        if not _G.__OmniVisualPort.state.radar then
            for _, dot in pairs(radarDots) do dot.Visible = false end
            return
        end
        local character = Player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local camera = workspace.CurrentCamera
        local yaw = camera and math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z) or 0
        local seen = {}
        for _, other in ipairs(game:GetService("Players"):GetPlayers()) do
            if other ~= Player then
                local otherRoot = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
                if otherRoot then
                    local delta = otherRoot.Position - root.Position
                    local localX = delta.X * math.cos(yaw) - delta.Z * math.sin(yaw)
                    local localZ = delta.X * math.sin(yaw) + delta.Z * math.cos(yaw)
                    local range = _G.__OmniVisualPort.state.radarRange
                    local dot = radarDotFor(other)
                    dot.Position = UDim2.new(0.5, math.clamp(localX / range * 68, -68, 68), 0.5, math.clamp(localZ / range * 68, -68, 68))
                    dot.Visible = delta.Magnitude <= range
                    seen[other] = true
                end
            end
        end
        for player, dot in pairs(radarDots) do
            if not seen[player] then dot.Visible = false end
            if player.Parent == nil then dot:Destroy(); radarDots[player] = nil end
        end
    end))

    local aimFovRing = Instance.new("Frame")
    aimFovRing.Name = "AimFOV"
    aimFovRing.Parent = espGui
    aimFovRing.AnchorPoint = Vector2.new(0.5, 0.5)
    aimFovRing.BackgroundTransparency = 1
    aimFovRing.BorderSizePixel = 0
    aimFovRing.Visible = false
    aimFovRing.ZIndex = 2
    local aimFovStroke = Instance.new("UIStroke")
    aimFovStroke.Parent = aimFovRing
    aimFovStroke.Thickness = 1
    aimFovStroke.Transparency = 0.55
    aimFovStroke.Color = uiAccentColor
    local aimFovCorner = Instance.new("UICorner")
    aimFovCorner.CornerRadius = UDim.new(1, 0)
    aimFovCorner.Parent = aimFovRing

    local espEntries = {}

    local skeletonBones = {
        { "Head", "UpperTorso" },
        { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" },
        { "LeftUpperArm", "LeftLowerArm" },
        { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" },
        { "RightUpperArm", "RightLowerArm" },
        { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" },
        { "LeftUpperLeg", "LeftLowerLeg" },
        { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" },
        { "RightUpperLeg", "RightLowerLeg" },
        { "RightLowerLeg", "RightFoot" },
    }

    local skeletonAliases = {
        UpperTorso = { "UpperTorso", "Torso" },
        LowerTorso = { "LowerTorso", "Torso" },
        LeftUpperArm = { "LeftUpperArm", "Left Arm" },
        RightUpperArm = { "RightUpperArm", "Right Arm" },
        LeftLowerArm = { "LeftLowerArm", "Left Arm" },
        RightLowerArm = { "RightLowerArm", "Right Arm" },
        LeftHand = { "LeftHand", "Left Arm" },
        RightHand = { "RightHand", "Right Arm" },
        LeftUpperLeg = { "LeftUpperLeg", "Left Leg" },
        RightUpperLeg = { "RightUpperLeg", "Right Leg" },
        LeftLowerLeg = { "LeftLowerLeg", "Left Leg" },
        RightLowerLeg = { "RightLowerLeg", "Right Leg" },
        LeftFoot = { "LeftFoot", "Left Leg" },
        RightFoot = { "RightFoot", "Right Leg" },
    }

    local function skeletonPart(character, name)
        local candidates = skeletonAliases[name] or { name }
        for _, partName in ipairs(candidates) do
            local part = character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then return part end
        end
        return nil
    end

    local function makeLineFrame(parent, name)
        local line = Instance.new("Frame")
        line.Name = name
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = espColors.skeleton
        line.BackgroundTransparency = 0.2
        line.BorderSizePixel = 0
        line.Visible = false
        line.ZIndex = 4
        line.Parent = parent
        return line
    end

    local function positionLine(line, fromPoint, toPoint)
        local dx = toPoint.X - fromPoint.X
        local dy = toPoint.Y - fromPoint.Y
        local length = math.sqrt(dx * dx + dy * dy)
        if length < 1 then
            line.Visible = false
            return
        end
        line.Position = UDim2.fromOffset((fromPoint.X + toPoint.X) * 0.5, (fromPoint.Y + toPoint.Y) * 0.5)
        line.Size = UDim2.fromOffset(length, 1)
        line.Rotation = math.deg(math.atan2(dy, dx))
    end

    local function positionSegment(segment, x, y, width, height)
        segment.Position = UDim2.fromOffset(x, y)
        segment.Size = UDim2.fromOffset(width, height)
    end

    local function makeEspEntry(otherPlayer)
        local box = Instance.new("Frame")
        box.Name = "ESP_" .. otherPlayer.Name
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.ZIndex = 4
        box.Parent = espLayer

        local stroke = Instance.new("UIStroke")
        stroke.Color = espColors.box
        stroke.Thickness = 1
        stroke.Transparency = 0.05
        stroke.Parent = box

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 2)
        corner.Parent = box

        local fill = Instance.new("Frame")
        fill.Name = "ESPBoxFill"
        fill.Size = UDim2.fromScale(1, 1)
        fill.BackgroundColor3 = espColors.boxFill
        fill.BackgroundTransparency = 0.86
        fill.BorderSizePixel = 0
        fill.Visible = false
        fill.ZIndex = 4
        fill.Parent = box

        local cornerLines = {}
        for index = 1, 8 do
            local line = Instance.new("Frame")
            line.Name = "ESPCorner" .. tostring(index)
            line.BackgroundColor3 = espColors.box
            line.BorderSizePixel = 0
            line.Visible = false
            line.ZIndex = 5
            line.Parent = box
            cornerLines[index] = line
        end

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "ESPName"
        nameLabel.AnchorPoint = Vector2.new(0.5, 1)
        nameLabel.Position = UDim2.new(0.5, 0, 0, -2)
        nameLabel.Size = UDim2.new(1, 140, 0, 14)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = otherPlayer.Name
        nameLabel.TextColor3 = espColors.name
        nameLabel.TextStrokeTransparency = 0.35
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextSize = 11
        nameLabel.ZIndex = 6
        nameLabel.Parent = box

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "ESPDistance"
        distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
        distanceLabel.Position = UDim2.new(0.5, 0, 1, 2)
        distanceLabel.Size = UDim2.new(1, 90, 0, 12)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = ""
        distanceLabel.TextColor3 = espColors.distance
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.Font = Enum.Font.Code
        distanceLabel.TextSize = 9
        distanceLabel.ZIndex = 6
        distanceLabel.Parent = box

        local visibilityLabel = Instance.new("TextLabel")
        visibilityLabel.Name = "VisibilityLabel"
        visibilityLabel.AnchorPoint = Vector2.new(0.5, 0)
        visibilityLabel.Position = UDim2.new(0.5, 0, 1, 16)
        visibilityLabel.Size = UDim2.new(1, 0, 0, 14)
        visibilityLabel.BackgroundTransparency = 1
        visibilityLabel.Font = Enum.Font.Code
        visibilityLabel.TextSize = 9
        visibilityLabel.ZIndex = 6
        visibilityLabel.Parent = box

        local healthBack = Instance.new("Frame")
        healthBack.Name = "ESPHealthBack"
        healthBack.AnchorPoint = Vector2.new(1, 0)
        healthBack.Position = UDim2.new(0, -5, 0, 0)
        healthBack.Size = UDim2.fromOffset(2, 1)
        healthBack.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        healthBack.BackgroundTransparency = 0.5
        healthBack.BorderSizePixel = 0
        healthBack.ZIndex = 5
        healthBack.Parent = box

        local healthBackGradient = Instance.new("UIGradient")
        healthBackGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, espHealthColors.top),
            ColorSequenceKeypoint.new(1, espHealthColors.bottom),
        })
        healthBackGradient.Rotation = 90
        healthBackGradient.Parent = healthBack

        local healthFill = Instance.new("Frame")
        healthFill.Name = "ESPHealthFill"
        healthFill.AnchorPoint = Vector2.new(0, 1)
        healthFill.Position = UDim2.new(0, 0, 1, 0)
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        local healthGradient = Instance.new("UIGradient")
        healthGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, espHealthColors.top),
            ColorSequenceKeypoint.new(1, espHealthColors.bottom),
        })
        healthGradient.Rotation = 90
        healthGradient.Parent = healthFill
        local healthCorner = Instance.new("UICorner")
        healthCorner.CornerRadius = UDim.new(0, 1)
        healthCorner.Parent = healthFill
        healthFill.BackgroundColor3 = espColors.health
        healthFill.BorderSizePixel = 0
        healthFill.ZIndex = 6
        healthFill.Parent = healthBack

        local tracer = Instance.new("Frame")
        tracer.Name = "ESPTracer"
        tracer.AnchorPoint = Vector2.new(0.5, 0.5)
        tracer.BackgroundColor3 = espColors.tracer
        tracer.BackgroundTransparency = 0.25
        tracer.BorderSizePixel = 0
        tracer.Visible = false
        tracer.ZIndex = 3
        tracer.Parent = espLayer

        local headDot = Instance.new("Frame")
        headDot.Name = "ESPHeadDot"
        headDot.AnchorPoint = Vector2.new(0.5, 0.5)
        headDot.Size = UDim2.fromOffset(4, 4)
        headDot.BackgroundColor3 = espColors.headDot
        headDot.BorderSizePixel = 0
        headDot.Visible = false
        headDot.ZIndex = 5
        headDot.Parent = espLayer
        local headDotCorner = Instance.new("UICorner")
        headDotCorner.CornerRadius = UDim.new(1, 0)
        headDotCorner.Parent = headDot

        local bones = {}
        for index = 1, #skeletonBones do
            bones[index] = makeLineFrame(espLayer, "ESPBone" .. tostring(index))
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPChams_" .. otherPlayer.Name
        highlight.Enabled = false
        highlight.FillColor = espColors.chams
        highlight.OutlineColor = chamsState.outlineColor
        highlight.FillTransparency = chamsState.fillTransparency
        highlight.OutlineTransparency = chamsState.outline and chamsState.outlineTransparency or 1
        highlight.Parent = espGui

        local entry = {
            box = box,
            stroke = stroke,
            nameLabel = nameLabel,
            distanceLabel = distanceLabel,
            healthBack = healthBack,
            healthFill = healthFill,
            healthBackGradient = healthBackGradient,
            tracer = tracer,
            highlight = highlight,
            fill = fill,
            cornerLines = cornerLines,
            headDot = headDot,
            bones = bones,
            visible = true,
            visibleAt = 0,
            visibilityLabel = visibilityLabel,
        }
        espEntries[otherPlayer] = entry
        return entry
    end

    local visibilityParams = RaycastParams.new()
    visibilityParams.FilterType = Enum.RaycastFilterType.Exclude
    visibilityParams.IgnoreWater = true

    local function internalRaycast(origin, direction, params)
        aimState.internal = true
        local result = workspace:Raycast(origin, direction, params)
        aimState.internal = false
        return result
    end

    local function isTargetVisible(character, aimPoint)
        local camera = workspace.CurrentCamera
        if not camera then return true end
        local filter = {}
        if Player.Character then filter[#filter + 1] = Player.Character end
        if character then filter[#filter + 1] = character end
        visibilityParams.FilterDescendantsInstances = filter
        local origin = camera.CFrame.Position
        local result = internalRaycast(origin, aimPoint - origin, visibilityParams)
        return result == nil
    end

    local function hideEspEntry(entry)
        entry.box.Visible = false
        entry.tracer.Visible = false
        entry.headDot.Visible = false
        entry.fill.Visible = false
        entry.highlight.Enabled = false
        for index = 1, #entry.cornerLines do entry.cornerLines[index].Visible = false end
        for index = 1, #entry.bones do entry.bones[index].Visible = false end
    end

    local function uacPosition(playerName)
        local playersFolder = ReplicatedStorage:FindFirstChild("Players")
        local data = playersFolder and playersFolder:FindFirstChild(playerName)
        local status = data and data:FindFirstChild("Status")
        local uac = status and status:FindFirstChild("UAC")
        local position = uac and uac:GetAttribute("LastVerifiedPos")
        if typeof(position) == "Vector3" then
            return position
        end
        return nil
    end

    local espLastPositions = {}

    local function renderESP()
        if not espState.enabled then
            for _, entry in next, espEntries do hideEspEntry(entry) end
            return
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local now = os.clock()
        for _, otherPlayer in ipairs(PlayersService:GetPlayers()) do
            local entry = espEntries[otherPlayer] or makeEspEntry(otherPlayer)
            local character = otherPlayer.Character
            local alive = characterAlive(character)
            local head = alive and character:FindFirstChild("Head")
            local rootPart = alive and character:FindFirstChild("HumanoidRootPart")
            local farPosition = nil
            if alive and head and rootPart then
                espLastPositions[otherPlayer] = rootPart.Position
            elseif espState.infinite then
                farPosition = uacPosition(otherPlayer.Name) or espLastPositions[otherPlayer]
            end
            if otherPlayer == Player or onSameTeam(otherPlayer) or not (farPosition or (alive and head and rootPart)) then
                hideEspEntry(entry)
            else
                local headPos, rootPos
                if alive and head and rootPart then
                    headPos = head.Position
                    rootPos = rootPart.Position
                else
                    headPos = farPosition + Vector3.new(0, 3, 0)
                    rootPos = farPosition
                end
                local topScreen, topOn = camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.75, 0))
                local bottomScreen, bottomOn = camera:WorldToViewportPoint(rootPos - Vector3.new(0, 2.6, 0))
                if not topOn or not bottomOn or topScreen.Z <= 0 or bottomScreen.Z <= 0 then
                    hideEspEntry(entry)
                else
                    local height = math.abs(bottomScreen.Y - topScreen.Y)
                    local width = math.max(16, height * 0.48)
                    local distance = (camera.CFrame.Position - rootPos).Magnitude
                    local meters = math.floor(distance * 0.28 + 0.5)
                    local boxTop = math.min(topScreen.Y, bottomScreen.Y)
                    if espState.infinite and height < 8 then
                        height = 8
                        width = math.max(10, width)
                        boxTop = (topScreen.Y + bottomScreen.Y) * 0.5 - height * 0.5
                    end
                    if (not farPosition and height < 8) or (not farPosition and espState.maxDistance > 0 and meters > espState.maxDistance) then
                        hideEspEntry(entry)
                    else
                        local visible = true
                        if not farPosition then
                            if now - entry.visibleAt > 0.15 then
                                entry.visibleAt = now
                                entry.visible = isTargetVisible(character, headPos)
                            end
                            visible = entry.visible
                        else
                            visible = true
                        end
                        if not espState.walls and not visible then
                            hideEspEntry(entry)
                        else
                            local x = (topScreen.X + bottomScreen.X) * 0.5 - width * 0.5
                            local y = boxTop
                                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                                local health = humanoid and math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1) or 0

                                local boxWidth = math.max(1, math.floor(width))
                                local boxHeight = math.max(1, math.floor(height))
                                local drawBox = espState.box
                                local drawCorners = drawBox and espState.cornerBox

                                entry.box.Visible = true
                                entry.box.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
                                entry.box.Size = UDim2.fromOffset(boxWidth, boxHeight)
                                entry.stroke.Color = espColors.box
                                entry.stroke.Transparency = drawBox and not drawCorners and 0.05 or 1

                                entry.fill.Visible = drawBox and espState.boxFill
                                entry.fill.BackgroundColor3 = espColors.boxFill

                                local cornerLength = math.clamp(math.floor(math.min(boxWidth, boxHeight) * 0.24), 5, 16)
                                for index = 1, 8 do
                                    local segment = entry.cornerLines[index]
                                    segment.Visible = drawCorners
                                    segment.BackgroundColor3 = espColors.box
                                end
                                if drawCorners then
                                    local lines = entry.cornerLines
                                    positionSegment(lines[1], 0, 0, cornerLength, 1)
                                    positionSegment(lines[2], 0, 0, 1, cornerLength)
                                    positionSegment(lines[3], boxWidth - cornerLength, 0, cornerLength, 1)
                                    positionSegment(lines[4], boxWidth - 1, 0, 1, cornerLength)
                                    positionSegment(lines[5], 0, boxHeight - 1, cornerLength, 1)
                                    positionSegment(lines[6], 0, boxHeight - cornerLength, 1, cornerLength)
                                    positionSegment(lines[7], boxWidth - cornerLength, boxHeight - 1, cornerLength, 1)
                                    positionSegment(lines[8], boxWidth - 1, boxHeight - cornerLength, 1, cornerLength)
                                end

                                local headScreen, headOnScreen = camera:WorldToViewportPoint(headPos)
                                entry.headDot.Visible = espState.headDot and headOnScreen and headScreen.Z > 0
                                if entry.headDot.Visible then
                                    entry.headDot.Position = UDim2.fromOffset(math.floor(headScreen.X), math.floor(headScreen.Y))
                                    entry.headDot.BackgroundColor3 = espColors.headDot
                                end

                                if espState.skeleton and character then
                                    if entry.skeletonCharacter ~= character or now - (entry.skeletonAt or 0) > 2 then
                                        entry.skeletonCharacter = character
                                        entry.skeletonAt = now
                                        entry.skeletonParts = {}
                                        for index, bone in ipairs(skeletonBones) do
                                            entry.skeletonParts[index] = {
                                                skeletonPart(character, bone[1]),
                                                skeletonPart(character, bone[2]),
                                            }
                                        end
                                    end
                                    for index, line in ipairs(entry.bones) do
                                        local pair = entry.skeletonParts and entry.skeletonParts[index]
                                        local partA = pair and pair[1]
                                        local partB = pair and pair[2]
                                        if partA and partB and partA.Parent and partB.Parent then
                                            local pointA, onA = camera:WorldToViewportPoint(partA.Position)
                                            local pointB, onB = camera:WorldToViewportPoint(partB.Position)
                                            if onA and onB and pointA.Z > 0 and pointB.Z > 0 then
                                                line.Visible = true
                                                line.BackgroundColor3 = espColors.skeleton
                                                positionLine(line, Vector2.new(pointA.X, pointA.Y), Vector2.new(pointB.X, pointB.Y))
                                            else
                                                line.Visible = false
                                            end
                                        else
                                            line.Visible = false
                                        end
                                    end
                                else
                                    for index = 1, #entry.bones do entry.bones[index].Visible = false end
                                end

                                entry.nameLabel.Visible = espState.names
                                entry.nameLabel.Text = otherPlayer.Name
                                entry.nameLabel.TextColor3 = espColors.name

                                entry.distanceLabel.Visible = espState.distance
                                entry.distanceLabel.Text = tostring(meters) .. "m"
                                entry.distanceLabel.TextColor3 = espColors.distance
                                
                                entry.visibilityLabel.Visible = espState.visibility
                                entry.visibilityLabel.Text = entry.visible and "visible" or "hidden"
                                entry.visibilityLabel.TextColor3 = entry.visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
                                entry.visibilityLabel.Position = UDim2.new(0.5, 0, 0, boxHeight + 8)
                                entry.visibilityLabel.Size = UDim2.new(1, 0, 0, 18)
                                entry.visibilityLabel.BackgroundTransparency = 1
                                entry.visibilityLabel.Font = Enum.Font.GothamBold
                                entry.visibilityLabel.TextSize = 12
                                entry.visibilityLabel.ZIndex = 6


                                if not entry.healthBack then
                                    entry.healthBack = Instance.new("Frame")
                                    entry.healthBack.Name = "ESPHealthBack"
                                    entry.healthBack.AnchorPoint = Vector2.new(1, 0)
                                    entry.healthBack.Position = UDim2.new(0, -5, 0, 0)
                                    entry.healthBack.Size = UDim2.fromOffset(2, math.max(6, math.floor(height)))
                                    entry.healthBack.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                                    entry.healthBack.BackgroundTransparency = 0.5
                                    entry.healthBack.BorderSizePixel = 0
                                    entry.healthBack.ZIndex = 5
                                    entry.healthBack.Parent = entry.box
                                end
                                if not entry.healthFill then
                                    entry.healthFill = Instance.new("Frame")
                                    entry.healthFill.Name = "ESPHealthFill"
                                    entry.healthFill.AnchorPoint = Vector2.new(0, 1)
                                    entry.healthFill.Position = UDim2.new(0, 0, 1, 0)
                                    entry.healthFill.Size = UDim2.new(1, 0, 1, 0)
                                    entry.healthFill.BackgroundColor3 = espColors.health
                                    entry.healthFill.BorderSizePixel = 0
                                    entry.healthFill.ZIndex = 6
                                    entry.healthFill.Parent = entry.healthBack
                                elseif entry.healthFill.Parent ~= entry.healthBack then
                                    entry.healthFill.Parent = entry.healthBack
                                end
                                entry.healthBack.Visible = espState.health and humanoid ~= nil
                                entry.healthFill.Visible = espState.health and humanoid ~= nil
                                if espState.health and humanoid then
                                    entry.healthBack.Size = UDim2.fromOffset(2, math.max(6, math.floor(height)))
                                    entry.healthFill.Size = UDim2.new(1, 0, health, 0)
                                end

                                entry.tracer.Visible = espState.tracer
                                if espState.tracer then
                                    local startX, startY = viewport.X * 0.5, viewport.Y
                                    local endX, endY = x + width * 0.5, y + height
                                    local dx, dy = endX - startX, endY - startY
                                    local length = math.sqrt(dx * dx + dy * dy)
                                    entry.tracer.BackgroundColor3 = espColors.tracer
                                    entry.tracer.Position = UDim2.fromOffset(startX + dx * 0.5, startY + dy * 0.5)
                                    entry.tracer.Size = UDim2.fromOffset(length, 1)
                                    entry.tracer.Rotation = math.deg(math.atan2(dy, dx))
                                end

                                entry.highlight.Enabled = espState.chams and character ~= nil
                                if entry.highlight.Enabled then
                                    entry.highlight.Adornee = character
                                    if not (chamsState.rainbow or chamsState.pulse or chamsState.strobe) then
                                        entry.highlight.FillColor = espColors.chams
                                        entry.highlight.FillTransparency = math.clamp(chamsState.fillTransparency + (chamsState.intensity - 0.5) * 2, 0, 0.99)
                                    end
                                    entry.highlight.OutlineColor = chamsState.outline and chamsState.outlineColor or espColors.chams
                                    entry.highlight.OutlineTransparency = chamsState.outline and chamsState.outlineTransparency or 1
                                    entry.highlight.DepthMode = espState.walls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                                end
                            end
                        end
                    end
                end
            end
        end

    table.insert(managedConnections, PlayersService.PlayerRemoving:Connect(function(otherPlayer)
        espLastPositions[otherPlayer] = nil
        local entry = espEntries[otherPlayer]
        if entry then
            entry.box:Destroy()
            entry.tracer:Destroy()
            entry.headDot:Destroy()
            for index = 1, #entry.bones do entry.bones[index]:Destroy() end
            entry.highlight:Destroy()
            espEntries[otherPlayer] = nil
        end
    end))

    do
        local chamsClock = 0
        local chamsHue = 0
        table.insert(managedConnections, RunService.RenderStepped:Connect(function(deltaTime)
            if not espState.chams then return end
            chamsClock += deltaTime or 0
            chamsHue = (chamsHue + (deltaTime or 0) * 0.3) % 1
            local rainbowColor = Color3.fromHSV(chamsHue, math.clamp(chamsState.saturation, 0, 1), 1)
            local fillColor = chamsState.rainbow and rainbowColor or espColors.chams
            local intensityOffset = (math.clamp(chamsState.intensity, 0, 1) - 0.5) * 2
            local baseTransparency = chamsState.pulse
                and (0.55 + 0.35 * math.sin(chamsClock * 4))
                or chamsState.fillTransparency
            local fillTransparency = math.clamp(baseTransparency + intensityOffset, 0, 0.99)
            if chamsState.strobe then
                fillTransparency = (math.floor(chamsClock * 12) % 2 == 0) and 0 or 0.99
            end
            for _, entry in pairs(espEntries) do
                local highlight = entry.highlight
                if highlight and highlight.Enabled then
                    highlight.FillColor = fillColor
                    highlight.FillTransparency = fillTransparency
                    if chamsState.outline then
                        highlight.OutlineColor = chamsState.rainbow and rainbowColor or chamsState.outlineColor
                        highlight.OutlineTransparency = chamsState.outlineTransparency
                    end
                end
            end
        end))

        task.spawn(function()
            while true do
                task.wait(1)
                if espState.chams and chamsState.materialOn then
                    local ok, material = pcall(function() return Enum.Material[chamsState.material] end)
                    if not ok then material = Enum.Material.Neon end
                    for _, entry in pairs(espEntries) do
                        local character = entry.highlight and entry.highlight.Adornee
                        if character and character.Parent then
                            for _, part in ipairs(character:GetDescendants()) do
                                if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "HumanoidRootPart" then
                                    if not chamsOriginals[part] then
                                        chamsOriginals[part] = { material = part.Material, color = part.Color }
                                    end
                                    pcall(function()
                                        part.Material = material
                                        part.Color = espColors.chams
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    function chamsRestoreMaterials()
        for part, original in pairs(chamsOriginals) do
            if part.Parent then
                pcall(function()
                    part.Material = original.material
                    part.Color = original.color
                end)
            end
        end
        table.clear(chamsOriginals)
    end

    local aimParts = { "Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart" }

    local function resolveAimPart(character)
        if not character then return nil end
        for _, name in ipairs(aimParts) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then return part end
        end
        return character:FindFirstChildWhichIsA("BasePart")
    end

    local function isDowned(character)
        return character and character:GetAttribute("SD") ~= nil
    end

    local function aimEye()
        local character = Player.Character
        if not character then return nil end
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not root then return head and head.Position or nil end

        if not aimState.fleChecked then
            aimState.fleChecked = true
            local ok, module = pcall(function()
                local modules = ReplicatedStorage:FindFirstChild("Modules")
                local library = modules and modules:FindFirstChild("FunctionLibraryExtension")
                return library and require(library)
            end)
            aimState.fle = ok and type(module) == "table" and module or false
        end

        if aimState.fle and type(aimState.fle.GetEstimatedCameraPosition) == "function" then
            local ok, position = pcall(aimState.fle.GetEstimatedCameraPosition, aimState.fle, Player)
            if ok and typeof(position) == "Vector3" then return position end
        end

        local crouching = character:GetAttribute("Crouch")
        local eye = root.Position + Vector3.new(0, crouching and 0.6 or 1.6, 0)
        local leaning = character:GetAttribute("Leaning")
        if type(leaning) == "number" and leaning ~= 0 then
            local side = eye - root.CFrame.RightVector * leaning * 1.18
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.IgnoreWater = true
            pcall(function() params.CollisionGroup = "WeaponRay" end)
            local filter = { character }
            local noCollision = workspace:FindFirstChild("NoCollision")
            local droppedItems = workspace:FindFirstChild("DroppedItems")
            if noCollision then filter[#filter + 1] = noCollision end
            if droppedItems then filter[#filter + 1] = droppedItems end
            params.FilterDescendantsInstances = filter
            local hit = internalRaycast(eye, side - eye, params)
            if hit then return (eye + hit.Position) * 0.8 end
            return side
        end

        return eye
    end

    local function scanAimTarget()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local mouseLocation = UIS:GetMouseLocation()
        local centerX, centerY = mouseLocation.X, mouseLocation.Y
        local bestTarget, bestPart, bestDistance = nil, nil, aimState.fov
        for _, otherPlayer in ipairs(PlayersService:GetPlayers()) do
            local character = otherPlayer.Character
            if otherPlayer ~= Player and not onSameTeam(otherPlayer) and characterAlive(character) and not isDowned(character) then
                local aimPart = resolveAimPart(character)
                if aimPart then
                    local screen, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen and screen.Z > 0 then
                        local dx, dy = screen.X - centerX, screen.Y - centerY
                        local screenDistance = math.sqrt(dx * dx + dy * dy)
                        if screenDistance <= bestDistance then
                            local rootPart = character:FindFirstChild("HumanoidRootPart") or aimPart
                            local meters = (camera.CFrame.Position - rootPart.Position).Magnitude * 0.28
                            if espState.maxDistance == 0 or meters <= espState.maxDistance then
                                bestDistance = screenDistance
                                bestTarget = aimPart.Position
                                bestPart = aimPart
                            end
                        end
                    end
                end
            end
        end
        aimState.target = bestTarget
        aimState.targetPart = bestPart
        aimState.eye = aimEye()
    end

    LegitAim = {
        enabled = false,
        aimPart = "Head",
        fov = 140,
        smoothness = 10,
        prediction = 0.12,
        wallCheck = true,
        teamCheck = true,
        sticky = false,
        lastScan = 0,
        target = nil,
        targetPart = nil,
    }

    table.insert(managedConnections, RunService.RenderStepped:Connect(function(deltaTime)
        local aim = LegitAim
        local camera = workspace.CurrentCamera
        if not camera then return end
        if not aim.enabled then
            aim.target = nil
            aim.targetPart = nil
            return
        end
        if UIS:GetFocusedTextBox() then return end
        if ScreenGui.Enabled and Main.Visible then return end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if not aim.sticky then
                aim.target = nil
                aim.targetPart = nil
            end
            return
        end

        local viewport = camera.ViewportSize
        local centerX, centerY = viewport.X * 0.5, viewport.Y * 0.5
        local function partFor(character)
            if aim.aimPart == "Nearest" then
                local best, bestDistance = nil, math.huge
                local candidates = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }
                for index = 1, #candidates do
                    local part = character:FindFirstChild(candidates[index])
                    if part and part:IsA("BasePart") then
                        local screen, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen and screen.Z > 0 then
                            local dx, dy = screen.X - centerX, screen.Y - centerY
                            local distance = math.sqrt(dx * dx + dy * dy)
                            if distance < bestDistance then
                                best = part
                                bestDistance = distance
                            end
                        end
                    end
                end
                return best
            end
            local part = character:FindFirstChild(aim.aimPart)
                or character:FindFirstChild("Head")
                or character:FindFirstChild("HumanoidRootPart")
            return part
        end

        local now = os.clock()
        if aim.sticky and aim.targetPart and aim.targetPart.Parent then
            aim.target = aim.targetPart.Position
        elseif now - aim.lastScan >= 0.05 then
            aim.lastScan = now
            local bestPart, bestDistance = nil, aim.fov
            for _, otherPlayer in ipairs(PlayersService:GetPlayers()) do
                local character = otherPlayer.Character
                local teamBlocked = aim.teamCheck and onSameTeam(otherPlayer)
                if otherPlayer ~= Player and not teamBlocked and characterAlive(character) and not isDowned(character) then
                    local part = partFor(character)
                    if part then
                        local screen, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen and screen.Z > 0 then
                            local dx, dy = screen.X - centerX, screen.Y - centerY
                            local distance = math.sqrt(dx * dx + dy * dy)
                            if distance <= bestDistance then
                                if not aim.wallCheck or isTargetVisible(character, part.Position) then
                                    bestDistance = distance
                                    bestPart = part
                                end
                            end
                        end
                    end
                end
            end
            if bestPart then
                aim.targetPart = bestPart
                aim.target = bestPart.Position
            elseif not aim.sticky then
                aim.targetPart = nil
                aim.target = nil
            end
        end

        local targetPart = aim.targetPart
        if not targetPart or not targetPart.Parent then return end
        local velocity = targetPart.AssemblyLinearVelocity or Vector3.zero
        local targetPosition = targetPart.Position + velocity * aim.prediction
        local desired = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        local alpha = math.clamp((deltaTime or 0) * math.max(aim.smoothness, 1), 0, 1)
        camera.CFrame = camera.CFrame:Lerp(desired, alpha)
    end))

    local aimHookReady = false
    local function ensureAimHook()
        if aimHookReady then return end
        if type(hookmetamethod) ~= "function" or type(checkcaller) ~= "function" or type(getnamecallmethod) ~= "function" then
            return
        end

        local previous = _G.__OmniAimHook
        if type(previous) == "table" then
            if previous.state then previous.state.active = false end
            if type(previous.restore) == "function" then pcall(previous.restore) end
        end

        local closure = type(newcclosure) == "function" and newcclosure or function(func) return func end
        local oldNamecall
        local hookState = { active = true }
        local installed = pcall(function()
            oldNamecall = hookmetamethod(game, "__namecall", closure(function(self, ...)
                if not hookState.active or uiUnloaded or aimState.internal or checkcaller() then
                    return oldNamecall(self, ...)
                end

                local method = getnamecallmethod()
                if method == "GetAttribute" then
                    local attribute = ...
                    if gunModState.noSpread and attribute == "AccuracyDeviation" then return 0 end
                    if gunModState.removeWeight and (attribute == "MovementModifer" or attribute == "GearWeight") then return 0 end
                    if gunModState.removeAimRestrictions and attribute == "BlockADS" then return false end
                    if gunModState.removeSprintAnimation and attribute == "Sprinting" then return false end
                elseif method == "Raycast" and self == workspace and gunModState.ignoreWater then
                    local args = table.pack(...)
                    local params = args[3]
                    if typeof(params) == "RaycastParams" then
                        pcall(function() params.IgnoreWater = true end)
                    end
                end
                if gunModState.meleeReach and (method == "Raycast" or method == "Spherecast" or method == "Blockcast")
                    and self == workspace and type(debug) == "table" and type(debug.traceback) == "function" then
                    local trace = debug.traceback()
                    if string.find(trace, "Melee", 1, true) then
                        local args = table.pack(...)
                        local directionIndex = method == "Raycast" and 2 or 3
                        local direction = args[directionIndex]
                        if typeof(direction) == "Vector3" and direction.Magnitude > 0.001 then
                            args[directionIndex] = direction + direction.Unit * gunModState.meleeReachDist
                            return oldNamecall(self, table.unpack(args, 1, args.n))
                        end
                    end
                end
                if (not aimState.silentAim or not aimState.firing) then
                    return oldNamecall(self, ...)
                end

                local targetPart = aimState.targetPart
                if not (targetPart and targetPart.Parent) then
                    return oldNamecall(self, ...)
                end

                if method == "Raycast" and self == workspace then
                    local origin, _, params = ...
                    if typeof(params) == "RaycastParams" and params.CollisionGroup == "WeaponRay" and typeof(origin) == "Vector3" then
                        local delta = targetPart.Position - origin
                        if delta.Magnitude >= 0.001 then
                            return {
                                Instance = targetPart,
                                Position = targetPart.Position,
                                Normal = delta.Unit * -1,
                                Material = targetPart.Material,
                                Distance = delta.Magnitude,
                            }
                        end
                    end
                    return oldNamecall(self, ...)
                end

                if method == "InvokeServer" and typeof(self) == "Instance" and self.Name == "FireProjectile" then
                    local args = table.pack(...)
                    if args.n >= 3 and typeof(args[1]) == "Vector3" then
                        local origin = aimState.manipOrigin or aimState.eye
                            or (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position)
                        if origin then
                            local delta = targetPart.Position - origin
                            if delta.Magnitude >= 0.001 then
                                args[1] = delta.Unit
                                args[3] = tick() - delta.Magnitude / 1000
                                if type(setnamecallmethod) == "function" then pcall(setnamecallmethod, method) end
                                return oldNamecall(self, table.unpack(args, 1, args.n))
                            end
                        end
                    end
                    return oldNamecall(self, ...)
                end

                return oldNamecall(self, ...)
            end))
        end)

        if installed and oldNamecall then
            _G.__OmniAimHook = {
                state = hookState,
                restore = function()
                    hookState.active = false
                    pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end)
                end,
            }
            aimHookReady = true
        else
            aimHookReady = false
        end
    end

    table.insert(managedConnections, UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            aimState.lmbHeld = true
            aimState.firing = true
        end
    end))
    table.insert(managedConnections, UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            aimState.lmbHeld = false
            aimState.firing = false
        end
    end))

    table.insert(managedConnections, RunService.RenderStepped:Connect(function()
        if uiUnloaded then return end
        local now = os.clock()

        if aimState.silentAim or gunModState.noSpread or gunModState.removeWeight
            or gunModState.removeAimRestrictions or gunModState.ignoreWater or gunModState.meleeReach
            or gunModState.removeSprintAnimation then
            ensureAimHook()
        end

        if aimState.silentAim then
            ensureAimHook()
            if now - aimState.lastScan >= 0.05 then
                aimState.lastScan = now
                scanAimTarget()
            end
            local mouseLocation = UIS:GetMouseLocation()
            aimFovRing.Visible = true
            aimFovRing.Size = UDim2.fromOffset(aimState.fov * 2, aimState.fov * 2)
            aimFovRing.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
            aimFovStroke.Color = uiAccentColor
        else
            aimFovRing.Visible = false
            aimState.target = nil
            aimState.targetPart = nil
            aimState.eye = nil
        end

        local mouseDown = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        aimState.lmbHeld = mouseDown
        aimState.firing = mouseDown
        if aimState.instaHit and mouseDown and not UIS:GetFocusedTextBox() and not (ScreenGui.Enabled and Main.Visible) then
            local character = Player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local tool = character and character:FindFirstChildWhichIsA("Tool")
            if tool and humanoid and humanoid.Health > 0 and now - aimState.lastShot >= 0.02 then
                aimState.lastShot = now
                pcall(function() tool:Activate() end)
            end
        end
        if aimState.triggerbot and aim.targetPart and aim.targetPart.Parent and mouseDown and not UIS:GetFocusedTextBox() then
            local character = aim.targetPart.Parent
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local tool = character and character:FindFirstChildWhichIsA("Tool")
            if tool and humanoid and humanoid.Health > 0 then
                aimState.lastShot = now
                pcall(function() tool:Activate() end)
            end
        end

        renderESP()
    end))

    local OMNI_WORLD = (function()
    local worldFx = {
        fullBright = false, noFog = false, removeGrass = false, potato = false,
        timeOn = false, timeVal = 12,
        ambientOn = false,
        ambientA = Color3.new(1, 1, 1), ambientB = Color3.new(1, 1, 1),
        noLeaves = false, noFoliage = false, noTrees = false, noClouds = false,
        skyOn = false, skyPreset = 1, skyRotX = 0, skyRotZ = 0,
        fogOn = false, fogStart = 0, fogEnd = 1000, fogColor = Color3.fromRGB(170, 185, 205),
        atmoOn = false, atmoDensity = 20, atmoHaze = 0, atmoGlare = 0, atmoOffset = 0,
        atmoColor = Color3.fromRGB(200, 210, 230), atmoDecay = Color3.fromRGB(100, 110, 130),
        cloudOn = false, cloudCover = 50, cloudDensity = 50, cloudColor = Color3.new(1, 1, 1),
        bloomOn = false, bloomIntensity = 0.5, bloomSize = 24, bloomThreshold = 1,
        gradeOn = false, gradeTint = Color3.new(1, 1, 1),
        gradeSat = 0, gradeContrast = 0, gradeBrightness = 0,
        terrainOn = false, terrainMat = 1, terrainColor = Color3.fromRGB(115, 115, 115),
    }
    local WORLD_SKY_PRESETS = {
        { name = "Purple Nebula", ids = { "159454299", "159454296", "159454293", "159454286", "159454300", "159454288" } },
        { name = "Vaporwave", ids = { "600832720", "600833821", "600835177", "600833341", "600834603", "600835727" } },
        { name = "Deep Space", ids = { "265805434", "265805423", "265805445", "265805466", "265805481", "265805502" } },
        { name = "Night Sky", ids = { "12064107", "12064152", "12064121", "12064131", "12064115", "12064143" } },
        { name = "Sunset", ids = { "924373456", "924373468", "924373479", "924373497", "924373508", "924373523" } },
        { name = "Blood Moon", ids = { "401664839", "401664861", "401664883", "401664901", "401664916", "401664936" } },
        { name = "Purple Planet", ids = { "16262356578", "16262358026", "16262360469", "16262362003", "16262363873", "16262366016" } },
    }
    local WORLD_TERRAIN_MATERIALS = {
        "Grass", "Ground", "Sand", "Rock", "Slate", "Snow", "Mud", "Basalt", "CrackedLava",
        "Glacier", "Ice", "LeafyGrass", "Limestone", "Pavement", "Salt", "Sandstone", "Silt", "WoodPlanks",
    }
    local worldDefaults = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
    local worldBloom = Instance.new("BloomEffect")
    worldBloom.Name = "OmniWorldBloom"
    worldBloom.Enabled = false
    worldBloom.Parent = Lighting
    local worldGrade = Instance.new("ColorCorrectionEffect")
    worldGrade.Name = "OmniWorldGrade"
    worldGrade.Enabled = false
    worldGrade.Parent = Lighting
    local worldBrightCC = Instance.new("ColorCorrectionEffect")
    worldBrightCC.Name = "OmniWorldBright"
    worldBrightCC.Brightness = 0.06
    worldBrightCC.Contrast = 0.05
    worldBrightCC.Enabled = false
    worldBrightCC.Parent = Lighting

    local worldSky, worldHiddenSkies, worldOldLatitude = nil, {}, nil
    local worldAtmo, worldAtmoDefaults, worldAtmoCreated = nil, nil, false
    local worldCloudsFx, worldCloudDefaults, worldCloudCreated = nil, nil, false
    local worldHiddenClouds = {}
    local worldTerrainActive = nil
    local worldTerrainColors = {}
    local worldWaterDefaults = nil
    local worldLightApplied = false
    local worldClockApplied = false
    local worldFogApplied = false
    local worldFoliageBusy = false

    local function worldApplyClock()
        local want = worldFx.timeOn or worldFx.fullBright
        if not want and not worldClockApplied then return end
        if want then
            Lighting.ClockTime = worldFx.timeOn and worldFx.timeVal or 12
        else
            Lighting.ClockTime = worldDefaults.ClockTime
        end
        worldClockApplied = want
    end

    local function worldApplyLighting()
        local want = worldFx.fullBright or worldFx.ambientOn
        if not want and not worldLightApplied then return end
        local L = Lighting
        if worldFx.fullBright then
            L.Brightness = 3
            L.GlobalShadows = false
            L.Ambient = Color3.new(1, 1, 1)
            L.OutdoorAmbient = Color3.new(1, 1, 1)
        elseif worldFx.ambientOn then
            L.Ambient = worldFx.ambientA
            L.OutdoorAmbient = worldFx.ambientB
        else
            L.Brightness = worldDefaults.Brightness
            L.GlobalShadows = worldDefaults.GlobalShadows
            L.Ambient = worldDefaults.Ambient
            L.OutdoorAmbient = worldDefaults.OutdoorAmbient
        end
        worldBrightCC.Enabled = worldFx.fullBright
        worldLightApplied = want
    end

    local function worldApplyFog()
        local L = Lighting
        local want = worldFx.fogOn or worldFx.noFog or worldFx.fullBright
        if not want and not worldFogApplied then return end
        if worldFx.fogOn then
            L.FogStart = worldFx.fogStart
            L.FogEnd = math.max(worldFx.fogEnd, worldFx.fogStart + 1)
            L.FogColor = worldFx.fogColor
        elseif want then
            L.FogStart = 0
            L.FogEnd = 100000
        else
            L.FogStart = worldDefaults.FogStart
            L.FogEnd = worldDefaults.FogEnd
            L.FogColor = worldDefaults.FogColor
        end
        worldFogApplied = want
    end

    local function worldApplySky()
        if not worldFx.skyOn then
            if worldSky then worldSky:Destroy(); worldSky = nil end
            for sky in pairs(worldHiddenSkies) do
                if sky and sky.Parent == nil then sky.Parent = Lighting end
                worldHiddenSkies[sky] = nil
            end
            if worldOldLatitude ~= nil then
                Lighting.GeographicLatitude = worldOldLatitude
                worldOldLatitude = nil
            end
            return
        end
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") and child ~= worldSky then
                worldHiddenSkies[child] = true
                child.Parent = nil
            end
        end
        if not worldSky or worldSky.Parent ~= Lighting then
            worldSky = Instance.new("Sky")
            worldSky.Name = "OmniWorldSky"
            worldSky.Parent = Lighting
        end
        local preset = WORLD_SKY_PRESETS[worldFx.skyPreset] or WORLD_SKY_PRESETS[1]
        local ids = preset.ids
        local rotation = math.floor((worldFx.skyRotZ % 360 + 45) / 90) % 4
        local bk, ft, lf, rt = ids[1], ids[3], ids[4], ids[5]
        if rotation == 1 then
            bk, ft, lf, rt = lf, rt, ft, bk
        elseif rotation == 2 then
            bk, ft, lf, rt = ft, bk, rt, lf
        elseif rotation == 3 then
            bk, ft, lf, rt = rt, lf, bk, ft
        end
        local function asset(id) return "rbxassetid://" .. id end
        worldSky.SkyboxBk = asset(bk)
        worldSky.SkyboxFt = asset(ft)
        worldSky.SkyboxLf = asset(lf)
        worldSky.SkyboxRt = asset(rt)
        worldSky.SkyboxDn = asset(ids[2])
        worldSky.SkyboxUp = asset(ids[6])
        if worldOldLatitude == nil then worldOldLatitude = Lighting.GeographicLatitude end
        Lighting.GeographicLatitude = math.clamp(worldFx.skyRotX, -90, 90)
    end

    local function worldFindAtmosphere(createIfMissing)
        local atmo = Lighting:FindFirstChild("OmniWorldAtmosphere") or Lighting:FindFirstChildOfClass("Atmosphere")
        if not atmo and createIfMissing then
            atmo = Instance.new("Atmosphere")
            atmo.Name = "OmniWorldAtmosphere"
            atmo.Parent = Lighting
            worldAtmoCreated = true
        end
        return atmo
    end

    local function worldApplyAtmosphere()
        if worldFx.atmoOn then
            local atmo = worldFindAtmosphere(true)
            if not atmo then return end
            if not worldAtmoDefaults then
                worldAtmoDefaults = {
                    Density = atmo.Density, Offset = atmo.Offset, Color = atmo.Color,
                    Decay = atmo.Decay, Glare = atmo.Glare, Haze = atmo.Haze,
                }
            end
            worldAtmo = atmo
            atmo.Density = math.clamp(worldFx.atmoDensity / 100, 0, 1)
            atmo.Haze = math.clamp(worldFx.atmoHaze, 0, 10)
            atmo.Glare = math.clamp(worldFx.atmoGlare, 0, 10)
            atmo.Offset = math.clamp(worldFx.atmoOffset / 100, -1, 1)
            atmo.Color = worldFx.atmoColor
            atmo.Decay = worldFx.atmoDecay
        elseif worldAtmo then
            local atmo = worldAtmo
            if worldAtmoCreated then
                pcall(function() atmo:Destroy() end)
            elseif worldAtmoDefaults and atmo.Parent then
                pcall(function()
                    atmo.Density = worldAtmoDefaults.Density
                    atmo.Offset = worldAtmoDefaults.Offset
                    atmo.Color = worldAtmoDefaults.Color
                    atmo.Decay = worldAtmoDefaults.Decay
                    atmo.Glare = worldAtmoDefaults.Glare
                    atmo.Haze = worldAtmoDefaults.Haze
                end)
            end
            worldAtmo = nil
            worldAtmoDefaults = nil
            worldAtmoCreated = false
        end
    end

    local function worldFindClouds(createIfMissing)
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        local clouds = terrain and (terrain:FindFirstChild("OmniWorldClouds") or terrain:FindFirstChildOfClass("Clouds"))
        if not clouds then clouds = Lighting:FindFirstChildOfClass("Clouds") end
        if not clouds and createIfMissing and terrain then
            clouds = Instance.new("Clouds")
            clouds.Name = "OmniWorldClouds"
            clouds.Parent = terrain
            worldCloudCreated = true
        end
        return clouds
    end

    local function worldApplyCloudSettings()
        if worldFx.cloudOn then
            local clouds = worldFindClouds(true)
            if not clouds then return end
            if not worldCloudDefaults then
                worldCloudDefaults = { Cover = clouds.Cover, Density = clouds.Density, Color = clouds.Color, Enabled = clouds.Enabled }
            end
            worldCloudsFx = clouds
            clouds.Enabled = true
            clouds.Cover = math.clamp(worldFx.cloudCover / 100, 0, 1)
            clouds.Density = math.clamp(worldFx.cloudDensity / 100, 0, 1)
            clouds.Color = worldFx.cloudColor
        elseif worldCloudsFx then
            local clouds = worldCloudsFx
            if worldCloudCreated then
                pcall(function() clouds:Destroy() end)
            elseif worldCloudDefaults and clouds.Parent then
                pcall(function()
                    clouds.Cover = worldCloudDefaults.Cover
                    clouds.Density = worldCloudDefaults.Density
                    clouds.Color = worldCloudDefaults.Color
                    clouds.Enabled = worldCloudDefaults.Enabled
                end)
            end
            worldCloudsFx = nil
            worldCloudDefaults = nil
            worldCloudCreated = false
        end
    end

    local function worldApplyCloudVisibility()
        if worldFx.noClouds then
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            for _, parent in ipairs({ terrain, Lighting }) do
                local clouds = parent and parent:FindFirstChildOfClass("Clouds")
                if clouds then
                    worldHiddenClouds[clouds] = true
                    clouds.Enabled = false
                end
            end
            return
        end
        for clouds in pairs(worldHiddenClouds) do
            if clouds.Parent then clouds.Enabled = true end
            worldHiddenClouds[clouds] = nil
        end
    end

    local function worldApplyTerrainColor()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if not terrain then return end
        local materialName = WORLD_TERRAIN_MATERIALS[worldFx.terrainMat] or "Grass"
        local material = Enum.Material[materialName]
        if not material then return end
        if worldTerrainActive and worldTerrainActive ~= materialName then
            local previous = Enum.Material[worldTerrainActive]
            local color = worldTerrainColors[worldTerrainActive]
            if previous and color then
                pcall(function() terrain:SetMaterialColor(previous, color) end)
            end
            worldTerrainActive = nil
        end
        if not worldTerrainColors[materialName] then
            local ok, color = pcall(function() return terrain:GetMaterialColor(material) end)
            worldTerrainColors[materialName] = ok and color or Color3.new(1, 1, 1)
        end
        pcall(function()
            if worldFx.terrainOn then
                terrain:SetMaterialColor(material, worldFx.terrainColor)
                worldTerrainActive = materialName
            else
                terrain:SetMaterialColor(material, worldTerrainColors[materialName])
                worldTerrainActive = nil
            end
        end)
    end

    local function worldApplyTerrainDecor()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if not terrain then return end
        if not worldWaterDefaults then
            worldWaterDefaults = {
                WaveSize = terrain.WaterWaveSize, WaveSpeed = terrain.WaterWaveSpeed,
                Reflectance = terrain.WaterReflectance, Transparency = terrain.WaterTransparency,
            }
        end
        local hideDecor = worldFx.removeGrass or worldFx.potato
        pcall(function()
            if type(sethiddenproperty) == "function" then
                sethiddenproperty(terrain, "Decoration", not hideDecor)
            else
                terrain.Decoration = not hideDecor
            end
        end)
        if not pcall(function() return terrain.Decoration end) then
            pcall(function() terrain.Decoration = not hideDecor end)
        end
        local potato = worldFx.potato
        pcall(function()
            terrain.WaterWaveSize = potato and 0 or worldWaterDefaults.WaveSize
            terrain.WaterWaveSpeed = potato and 0 or worldWaterDefaults.WaveSpeed
            terrain.WaterReflectance = potato and 0 or worldWaterDefaults.Reflectance
            terrain.WaterTransparency = potato and 0 or worldWaterDefaults.Transparency
        end)
    end

    local function worldApplyFoliage()
        if worldFoliageBusy then return end
        local zones = workspace:FindFirstChild("SpawnerZones")
        local folder = zones and zones:FindFirstChild("Foliage")
        if not folder then return end
        if not (worldFx.noLeaves or worldFx.noFoliage or worldFx.noTrees) then return end
        worldFoliageBusy = true
        task.spawn(function()
            local stack = { folder }
            local count = 0
            while #stack > 0 do
                local node = table.remove(stack)
                for _, child in ipairs(node:GetChildren()) do
                    if child:IsA("BasePart") then
                        local isLeaf = child:FindFirstChildOfClass("SurfaceAppearance") ~= nil
                        if isLeaf then
                            if worldFx.noLeaves then child.Transparency = 1 end
                        elseif child:IsA("MeshPart") then
                            local isTree = child.Color == Color3.fromRGB(108, 88, 75)
                            local hide = (isTree and worldFx.noTrees) or ((not isTree) and worldFx.noFoliage)
                            if hide then child.Transparency = 1 end
                        end
                    end
                    stack[#stack + 1] = child
                    count += 1
                    if count % 400 == 0 then task.wait() end
                end
            end
            worldFoliageBusy = false
        end)
    end

    local function worldApplyAll()
        worldApplyClock()
        worldApplyLighting()
        worldApplyFog()
        worldApplySky()
        worldApplyAtmosphere()
        worldApplyCloudSettings()
        worldApplyCloudVisibility()
        worldApplyTerrainColor()
        worldApplyTerrainDecor()
        worldApplyFoliage()
        worldBloom.Enabled = worldFx.bloomOn
        if worldFx.bloomOn then
            worldBloom.Intensity = math.clamp(worldFx.bloomIntensity, 0, 5)
            worldBloom.Size = math.clamp(worldFx.bloomSize, 0, 56)
            worldBloom.Threshold = math.clamp(worldFx.bloomThreshold, 0, 2)
        end
        worldGrade.Enabled = worldFx.gradeOn
        if worldFx.gradeOn then
            worldGrade.TintColor = worldFx.gradeTint
            worldGrade.Saturation = math.clamp(worldFx.gradeSat / 100, -1, 1.5)
            worldGrade.Contrast = math.clamp(worldFx.gradeContrast / 100, -1, 1)
            worldGrade.Brightness = math.clamp(worldFx.gradeBrightness / 100, -1, 1)
        end
    end

    local worldLastTick = 0
    table.insert(managedConnections, RunService.RenderStepped:Connect(function()
        local now = os.clock()
        if worldFx.timeOn or worldFx.fullBright then worldApplyClock() end
        if worldFx.ambientOn or worldFx.fullBright then worldApplyLighting() end
        if now - worldLastTick < 0.5 then return end
        worldLastTick = now
        worldApplyFog()
        worldApplyAtmosphere()
        worldApplyCloudSettings()
        worldApplyCloudVisibility()
        worldApplyTerrainColor()
    end))

    local movementState = {
        flyEnabled = false, flySpeed = 10, flyVSpeed = 10,
        speedEnabled = false, speedValue = 20,
        fovEnabled = false, fovValue = 70,
    }
    local flyParts, flyPartIndex = {}, {}
    local flyCharacter, flyAddedConn, flyRemovedConn = nil, nil, nil
    local walkSpeedApplied = false
    local defaultFov = nil
    local fovApplied = false

    local function flyAddPart(part)
        if part and part:IsA("BasePart") and not flyPartIndex[part] then
            local index = #flyParts + 1
            flyParts[index] = part
            flyPartIndex[part] = index
        end
    end

    local function flyRemovePart(part)
        local index = flyPartIndex[part]
        if not index then return end
        local lastIndex = #flyParts
        local lastPart = flyParts[lastIndex]
        flyParts[index] = lastPart
        flyParts[lastIndex] = nil
        flyPartIndex[part] = nil
        if lastPart and lastPart ~= part then flyPartIndex[lastPart] = index end
    end

    local function flyBindCharacter(character)
        if flyAddedConn then flyAddedConn:Disconnect(); flyAddedConn = nil end
        if flyRemovedConn then flyRemovedConn:Disconnect(); flyRemovedConn = nil end
        table.clear(flyParts)
        table.clear(flyPartIndex)
        flyCharacter = character
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do flyAddPart(part) end
        flyAddedConn = character.DescendantAdded:Connect(flyAddPart)
        flyRemovedConn = character.DescendantRemoving:Connect(flyRemovePart)
    end

    table.insert(managedConnections, RunService.RenderStepped:Connect(function(deltaTime)
        local character = Player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if movementState.speedEnabled then
                local target = math.clamp(movementState.speedValue, 16, 22)
                if humanoid.WalkSpeed ~= target then humanoid.WalkSpeed = target end
                walkSpeedApplied = true
            elseif walkSpeedApplied then
                walkSpeedApplied = false
                pcall(function() humanoid.WalkSpeed = 16 end)
            end
        end
        local camera = workspace.CurrentCamera
        if camera then
            if not defaultFov then defaultFov = camera.FieldOfView end
            if movementState.fovEnabled then
                if camera.FieldOfView ~= movementState.fovValue then
                    camera.FieldOfView = movementState.fovValue
                end
                fovApplied = true
            elseif fovApplied then
                fovApplied = false
                pcall(function() camera.FieldOfView = defaultFov end)
            end
        end
        if not movementState.flyEnabled then
            if flyCharacter then flyBindCharacter(nil) end
            return
        end
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not (character and root and camera) then return end
        if root.Anchored then root.Anchored = false end
        if flyCharacter ~= character then flyBindCharacter(character) end
        local look = camera.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.001 then flat = flat.Unit else flat = Vector3.new(0, 0, -1) end
        local direction = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + flat end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - flat end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + Vector3.new(-flat.Z, 0, flat.X) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction + Vector3.new(flat.Z, 0, -flat.X) end
        if direction.Magnitude > 0.001 then direction = direction.Unit end
        local vertical = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical += 1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vertical -= 1 end
        local step = math.clamp(deltaTime or 0, 0, 0.05)
        root.CFrame = root.CFrame
            + direction * step * movementState.flySpeed
            + Vector3.new(0, vertical * step * movementState.flyVSpeed, 0)
        for index = 1, #flyParts do
            local part = flyParts[index]
            if part.Parent and part.AssemblyLinearVelocity.Magnitude > 0 then
                part.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end))

    return {
        state = worldFx,
        apply = worldApplyAll,
        terrainMaterials = WORLD_TERRAIN_MATERIALS,
        movement = movementState,
    }
    end)()

    KeybindAdd("fly", "Flyhack", function() return OMNI_WORLD.movement.flyEnabled end, function(value)
        OMNI_WORLD.movement.flyEnabled = value and true or false
    end)
    KeybindAdd("speed", "Speed Hack", function() return OMNI_WORLD.movement.speedEnabled end, function(value)
        OMNI_WORLD.movement.speedEnabled = value and true or false
    end)
    KeybindAdd("silentaim", "Silent Aim", function() return aimState.silentAim end, function(value)
        aimState.silentAim = value and true or false
        if not aimState.silentAim then
            aimState.target = nil
            aimState.targetPart = nil
        end
    end)
    KeybindAdd("instahit", "Insta Hit", function() return aimState.instaHit end, function(value)
        aimState.instaHit = value and true or false
    end)
    KeybindAdd("esp", "ESP", function() return espState.enabled end, function(value)
        espState.enabled = value and true or false
        espLayer.Visible = espState.enabled
    end)
    KeybindAdd("radar", "Radar", function() return _G.__OmniVisualPort.state.radar end, function(value)
        _G.__OmniVisualPort.state.radar = value and true or false
        _G.__OmniVisualPort.scan()
    end)
    KeybindAdd("fullbright", "Full Bright", function() return OMNI_WORLD.state.fullBright end, function(value)
        OMNI_WORLD.state.fullBright = value and true or false
        OMNI_WORLD.apply()
    end)
    KeybindAdd("fov", "FOV Changer", function() return OMNI_WORLD.movement.fovEnabled end, function(value)
        OMNI_WORLD.movement.fovEnabled = value and true or false
    end)
    KeybindAdd("legitaim", "Aimbot", function() return LegitAim.enabled end, function(value)
        LegitAim.enabled = value and true or false
        if not LegitAim.enabled then
            LegitAim.target = nil
            LegitAim.targetPart = nil
        end
    end)

    ACBypass = (function()
        local module = {
            enabled = true,
            pending = setmetatable({}, { __mode = "k" }),
            killed = setmetatable({}, { __mode = "k" }),
        }
        local workerStarted = false

        local function isJunkPart(part)
            if part.ClassName ~= "Part" or part.Name ~= "Part" then return false end
            if not part.Anchored or part.Material ~= Enum.Material.Neon then return false end
            if math.abs(part.Transparency - 0.75) > 0.01 then return false end
            local size = part.Size
            if size.X > 0.2 or size.Y > 0.2 or size.Z > 0.2 then return false end
            return #part:GetChildren() == 0
        end

        local function scrub(part)
            local ok, junk = pcall(isJunkPart, part)
            if ok and junk then
                pcall(function() part:Destroy() end)
                return true
            end
            return false
        end

        function module.Kill()
            if not module.enabled then return end
            if not (getconnections and debug and debug.getupvalues) then return end
            pcall(function()
                for _, connection in ipairs(getconnections(game:GetService("LogService").MessageOut)) do
                    local fn = connection.Function
                    if type(fn) == "function" and not module.killed[fn] then
                        local upOk, upvalues = pcall(debug.getupvalues, fn)
                        if upOk and type(upvalues) == "table" then
                            local marker = upvalues[1]
                            if type(marker) == "table" and rawget(marker, 1) == "[ESP]" and rawget(marker, 2) == "[AIMBOT]" then
                                module.killed[fn] = true
                                if not pcall(function() connection:Disconnect() end) then
                                    pcall(function() connection.Enabled = false end)
                                    pcall(function() connection:Disable() end)
                                end
                            end
                        end
                    end
                end
            end)
        end

        function module.Start()
            if workerStarted then return end
            workerStarted = true
            table.insert(managedConnections, workspace.ChildAdded:Connect(function(part)
                if module.enabled and part.ClassName == "Part" then
                    module.pending[part] = true
                end
            end))
            task.spawn(function()
                for _, part in ipairs(workspace:GetChildren()) do
                    if part.ClassName == "Part" then module.pending[part] = true end
                end
                local sweepAt = os.clock() + 10
                while true do
                    if module.enabled then
                        local processed = 0
                        for part in pairs(module.pending) do
                            module.pending[part] = nil
                            scrub(part)
                            processed += 1
                            if processed >= 120 then break end
                        end
                        if os.clock() >= sweepAt then
                            sweepAt = os.clock() + 10
                            for _, part in ipairs(workspace:GetChildren()) do
                                if part.ClassName == "Part" then scrub(part) end
                            end
                            pcall(module.Kill)
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end

        function module.Arm()
            if not module.enabled then return end
            pcall(module.Kill)
        end

        function module.SetEnabled(value)
            module.enabled = value and true or false
            if module.enabled then
                task.spawn(function()
                    pcall(module.Kill)
                end)
            end
        end

        return module
    end)()

    ACBypass.Start()
    task.spawn(function()
        local deadline = os.clock() + 10
        while not Player.Character and os.clock() < deadline do task.wait(0.2) end
        ACBypass.Arm()
    end)
    table.insert(managedConnections, Player.CharacterAdded:Connect(function()
        task.wait(0.5)
        ACBypass.Arm()
    end))

    local SaveManager = (function()
    local SaveManager = {}
    SaveManager.Folder = "Omni"
    SaveManager.AutoLoadPath = "Omni/autoload.txt"
    SaveManager.Current = ""

    local function saveSafeName(value)
        local cleaned = tostring(value or ""):gsub("%.json$", ""):gsub("[^%w%-%_ ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        return cleaned:sub(1, 48)
    end
    SaveManager.SafeName = saveSafeName

    local function saveEncodeValue(value)
        if typeof(value) == "Color3" then
            return { __color = { value.R, value.G, value.B } }
        end
        return value
    end

    local function saveDecodeValue(value)
        if type(value) == "table" and type(value.__color) == "table" then
            local color = value.__color
            if type(color[1]) == "number" and type(color[2]) == "number" and type(color[3]) == "number" then
                return Color3.new(math.clamp(color[1], 0, 1), math.clamp(color[2], 0, 1), math.clamp(color[3], 0, 1))
            end
        end
        return value
    end

    local function saveEncodeState(source)
        local out = {}
        if type(source) ~= "table" then return out end
        for key, value in pairs(source) do
            if type(key) == "string" then out[key] = saveEncodeValue(value) end
        end
        return out
    end

    local function saveApplyState(target, data)
        if type(target) ~= "table" or type(data) ~= "table" then return end
        for key, value in pairs(data) do
            if type(key) == "string" and target[key] ~= nil then
                local decoded = saveDecodeValue(value)
                if type(decoded) == type(target[key]) then target[key] = decoded end
            end
        end
    end

    local function saveKeybindSnapshot()
        local out = {}
        for index = 1, #keybindEntries do
            local entry = keybindEntries[index]
            if entry.key ~= "None" then out[entry.id] = entry.key end
        end
        return out
    end

    local function saveKeybindApply(data)
        if type(data) ~= "table" then return end
        for id, keyName in pairs(data) do
            if type(id) == "string" and type(keyName) == "string" then
                KeybindSet(id, keyName)
            end
        end
    end

    function SaveManager.Snapshot()
        local palette = {}
        local paletteKeys = {}
        for name, color in next, currentThemePalette do
            if typeof(color) == "Color3" then table.insert(paletteKeys, name) end
        end
        table.sort(paletteKeys)
        for index = 1, #paletteKeys do
            local name = paletteKeys[index]
            local color = currentThemePalette[name]
            palette[name] = { color.R, color.G, color.B }
        end
        local savedClickSounds = {}
        for index = 1, #customClickSounds do
            local sound = customClickSounds[index]
            savedClickSounds[index] = { name = sound.name, id = sound.id }
        end
        return {
            version = 2,
            selectedTheme = selectedTheme,
            effectsEnabled = effectsEnabled,
            menuMusicEnabled = menuMusicEnabled,
            menuMusicOnlyWithUI = menuMusicOnlyWithUI,
            selectedSongIndex = selectedSongIndex,
            musicVolume = menuMusic.Volume,
            clickSoundId = UI_CLICK_SOUND_ID,
            clickSoundsEnabled = uiClickSoundsEnabled,
            customClickSounds = savedClickSounds,
            watermarkEnabled = watermarkEnabled,
            watermarkOptions = table.clone(watermarkOptions),
            watermarkRefreshRate = watermarkRefreshRate,
            inventoryViewerEnabled = inventoryViewer.enabled,
            inventoryViewerMode = inventoryViewer.mode,
            inventoryViewerKey = inventoryKeyName(),
            keybindListEnabled = hudKeybindEnabled,
            palette = palette,
            esp = saveEncodeState(espState),
            espColors = saveEncodeState(espColors),
            aim = saveEncodeState(aimState),
            gunMods = saveEncodeState(gunModState),
            visualPort = saveEncodeState(_G.__OmniVisualPort.state),
            world = saveEncodeState(OMNI_WORLD.state),
            movement = saveEncodeState(OMNI_WORLD.movement),
            chams = saveEncodeState(chamsState),
            legitAim = {
                enabled = LegitAim.enabled,
                aimPart = LegitAim.aimPart,
                fov = LegitAim.fov,
                smoothness = LegitAim.smoothness,
                prediction = LegitAim.prediction,
                wallCheck = LegitAim.wallCheck,
                teamCheck = LegitAim.teamCheck,
                sticky = LegitAim.sticky,
            },
            vmChams = {
                armEnabled = VMChams.armEnabled,
                gunEnabled = VMChams.gunEnabled,
                armMaterial = VMChams.armMaterial,
                gunMaterial = VMChams.gunMaterial,
                armColor = saveEncodeValue(VMChams.armColor),
                gunColor = saveEncodeValue(VMChams.gunColor),
            },
            keybinds = saveKeybindSnapshot(),
        }
    end

    function SaveManager.Apply(data)
        if type(data) ~= "table" then return false, "Invalid config data" end
        if type(data.selectedTheme) == "string" then selectedTheme = data.selectedTheme end
        if type(data.effectsEnabled) == "boolean" then effectsEnabled = data.effectsEnabled end
        if type(data.menuMusicEnabled) == "boolean" then menuMusicEnabled = data.menuMusicEnabled end
        if type(data.menuMusicOnlyWithUI) == "boolean" then menuMusicOnlyWithUI = data.menuMusicOnlyWithUI end
        if type(data.selectedSongIndex) == "number" and MENU_SONGS[data.selectedSongIndex] then
            selectedSongIndex = data.selectedSongIndex
            menuMusic:Pause()
            menuMusic.SoundId = MENU_SONGS[selectedSongIndex].id
            menuMusic.TimePosition = 0
        end
        if type(data.musicVolume) == "number" then menuMusic.Volume = math.clamp(data.musicVolume, 0, 1) end
        if type(data.clickSoundId) == "string" and data.clickSoundId:match("^rbxassetid://%d+$") then
            UI_CLICK_SOUND_ID = data.clickSoundId
        end
        if type(data.clickSoundsEnabled) == "boolean" then
            uiClickSoundsEnabled = data.clickSoundsEnabled
            local clickSoundsBox = ScreenGui:FindFirstChild("UIClickSoundsCheckbox", true)
            if clickSoundsBox then clickSoundsBox.BackgroundColor3 = uiClickSoundsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36) end
        end
        table.clear(customClickSounds)
        if type(data.customClickSounds) == "table" then
            for index = 1, #data.customClickSounds do
                local sound = data.customClickSounds[index]
                if type(sound) == "table" and type(sound.id) == "string" and sound.id:match("^%d+$") then
                    local soundName = type(sound.name) == "string" and sound.name or ("Custom " .. sound.id)
                    table.insert(customClickSounds, { name = soundName, id = sound.id })
                end
            end
        end
        if refreshClickSoundMenu then refreshClickSoundMenu() end
        if type(data.watermarkEnabled) == "boolean" then watermarkEnabled = data.watermarkEnabled end
        if type(data.watermarkOptions) == "table" then
            local watermarkOptionsList = { "Title", "FPS", "Ping" }
            for index = 1, #watermarkOptionsList do
                local optionName = watermarkOptionsList[index]
                if type(data.watermarkOptions[optionName]) == "boolean" then watermarkOptions[optionName] = data.watermarkOptions[optionName] end
            end
        end
        if type(data.watermarkRefreshRate) == "number" then watermarkRefreshRate = math.clamp(data.watermarkRefreshRate, 0.1, 1) end
        if data.inventoryViewerMode == "Image" or data.inventoryViewerMode == "Text" then
            inventoryViewer.mode = data.inventoryViewerMode
            inventoryLastSignature = nil
        end
        if type(data.inventoryViewerKey) == "string" then
            local keyOK, keyCode = pcall(function() return Enum.KeyCode[data.inventoryViewerKey] end)
            if keyOK and keyCode then inventoryViewer.key = keyCode end
        end
        if type(data.inventoryViewerEnabled) == "boolean" then
            setInventoryViewerEnabled(data.inventoryViewerEnabled)
        elseif inventoryViewer.refreshControls then
            pcall(inventoryViewer.refreshControls)
        end
        if type(data.palette) == "table" and applyLoadedPalette then
            local colors = {}
            for name, rgb in next, data.palette do
                if type(name) == "string" and type(rgb) == "table" and type(rgb[1]) == "number" and type(rgb[2]) == "number" and type(rgb[3]) == "number" then
                    colors[name] = Color3.new(math.clamp(rgb[1], 0, 1), math.clamp(rgb[2], 0, 1), math.clamp(rgb[3], 0, 1))
                end
            end
            applyLoadedPalette(colors)
        end
        saveApplyState(espState, data.esp)
        saveApplyState(espColors, data.espColors)
        saveApplyState(aimState, data.aim)
        saveApplyState(gunModState, data.gunMods)
        saveApplyState(_G.__OmniVisualPort.state, data.visualPort)
        saveApplyState(OMNI_WORLD.state, data.world)
        saveApplyState(OMNI_WORLD.movement, data.movement)
        saveApplyState(chamsState, data.chams)
        saveApplyState(LegitAim, data.legitAim)
        if not LegitAim.enabled then
            LegitAim.target = nil
            LegitAim.targetPart = nil
        end
        if type(data.vmChams) == "table" then
            local vm = data.vmChams
            if type(vm.armEnabled) == "boolean" then VMChams.armEnabled = vm.armEnabled end
            if type(vm.gunEnabled) == "boolean" then VMChams.gunEnabled = vm.gunEnabled end
            if type(vm.armMaterial) == "string" then VMChams.armMaterial = vm.armMaterial end
            if type(vm.gunMaterial) == "string" then VMChams.gunMaterial = vm.gunMaterial end
            local armColor = saveDecodeValue(vm.armColor)
            if typeof(armColor) == "Color3" then VMChams.armColor = armColor end
            local gunColor = saveDecodeValue(vm.gunColor)
            if typeof(gunColor) == "Color3" then VMChams.gunColor = gunColor end
            VMChams.Refresh()
        end
        if not espState.chams then
            pcall(chamsRestoreMaterials)
        end
        if type(data.keybindListEnabled) == "boolean" then hudKeybindEnabled = data.keybindListEnabled end
        saveKeybindApply(data.keybinds)
        espLayer.Visible = espState.enabled
        pcall(function() _G.__OmniVisualPort.scan() end)
        pcall(OMNI_WORLD.apply)
        refreshAllRows()
        refreshKeybindRows()
        refreshInventoryKeybindLabel()
        applyTheme()
        updateMenuMusic()
        watermarkRoot.Visible = watermarkEnabled
        hudKeybindLabel.Visible = hudKeybindEnabled
        local effectsBox = ScreenGui:FindFirstChild("EffectsCheckbox", true)
        if effectsBox then effectsBox.BackgroundColor3 = effectsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36) end
        local musicBox = ScreenGui:FindFirstChild("MenuMusicCheckbox", true)
        if musicBox then musicBox.BackgroundColor3 = menuMusicEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36) end
        local modeBox = ScreenGui:FindFirstChild("MusicOnlyWithUICheckbox", true)
        if modeBox then modeBox.BackgroundColor3 = menuMusicOnlyWithUI and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36) end
        local volumeControl = ScreenGui:FindFirstChild("MusicVolumeDropdown", true)
        if volumeControl then volumeControl.Text = tostring(math.floor(menuMusic.Volume * 100 + 0.5)) .. "%" end
        local songStatus = ScreenGui:FindFirstChild("CurrentMenuSong", true)
        if songStatus and MENU_SONGS[selectedSongIndex] then songStatus.Text = "Now Playing  -  " .. MENU_SONGS[selectedSongIndex].name end
        return true
    end

    function SaveManager.EnsureFolder()
        if type(makefolder) ~= "function" then return false, "Workspace file APIs unavailable" end
        if type(isfolder) == "function" then
            local ok, exists = pcall(isfolder, SaveManager.Folder)
            if ok and exists then return true end
        end
        local ok = pcall(makefolder, SaveManager.Folder)
        if ok then return true end
        if type(isfolder) == "function" then
            local checkOK, exists = pcall(isfolder, SaveManager.Folder)
            if checkOK and exists then return true end
        end
        return false, "Could not create workspace/" .. SaveManager.Folder
    end

    function SaveManager.Path(name)
        return SaveManager.Folder .. "/" .. name .. ".json"
    end

    function SaveManager.List()
        local names = {}
        if type(listfiles) ~= "function" then return names end
        local ok, files = pcall(listfiles, SaveManager.Folder)
        if not ok or type(files) ~= "table" then return names end
        for index = 1, #files do
            local name = tostring(files[index]):match("([^/\\]+)%.json$")
            if name then names[#names + 1] = name end
        end
        table.sort(names)
        return names
    end

    function SaveManager.Save(name)
        name = saveSafeName(name)
        if name == "" then return false, "Enter a config name first" end
        local ready, reason = SaveManager.EnsureFolder()
        if not ready then return false, reason end
        if type(writefile) ~= "function" then return false, "Workspace file APIs unavailable" end
        local ok, encoded = pcall(function() return HttpService:JSONEncode(SaveManager.Snapshot()) end)
        if not ok then return false, "Could not encode config" end
        local written = pcall(writefile, SaveManager.Path(name), encoded)
        if not written then return false, "Could not write workspace config" end
        SaveManager.Current = name
        return true, "Saved: " .. name
    end

    function SaveManager.Load(name)
        name = saveSafeName(name)
        if name == "" then return false, "Enter a config name first" end
        if type(readfile) ~= "function" then return false, "Workspace file APIs unavailable" end
        local ok, raw = pcall(readfile, SaveManager.Path(name))
        if not ok or type(raw) ~= "string" then return false, "Config not found" end
        local decodeOK, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not decodeOK then return false, "Config file is invalid" end
        local applyOK, reason = SaveManager.Apply(data)
        if not applyOK then return false, reason or "Could not apply config" end
        SaveManager.Current = name
        return true, "Loaded: " .. name
    end

    function SaveManager.Delete(name)
        name = saveSafeName(name)
        if name == "" then return false, "Select a config first" end
        if type(delfile) ~= "function" then return false, "Workspace delete API unavailable" end
        local ok = pcall(delfile, SaveManager.Path(name))
        if not ok then return false, "Could not delete config" end
        if SaveManager.Current == name then SaveManager.Current = "" end
        return true, "Deleted: " .. name
    end

    function SaveManager.SetAutoload(name)
        name = saveSafeName(name)
        if name == "" then return false, "Select a config first" end
        local ready, reason = SaveManager.EnsureFolder()
        if not ready then return false, reason end
        if type(writefile) ~= "function" then return false, "Workspace file APIs unavailable" end
        local ok = pcall(writefile, SaveManager.AutoLoadPath, name)
        if not ok then return false, "Could not set auto load" end
        return true, "Auto load: " .. name
    end

    function SaveManager.ClearAutoload()
        if type(delfile) ~= "function" then return false, "Workspace delete API unavailable" end
        local ok = pcall(delfile, SaveManager.AutoLoadPath)
        if not ok then return false, "No auto load setting found" end
        return true, "Auto load removed"
    end

    function SaveManager.GetAutoload()
        if type(readfile) ~= "function" then return nil end
        local ok, name = pcall(readfile, SaveManager.AutoLoadPath)
        if not ok or type(name) ~= "string" then return nil end
        name = saveSafeName(name)
        if name == "" then return nil end
        return name
    end

    function SaveManager.LoadAutoload()
        local name = SaveManager.GetAutoload()
        if not name then return false, "No auto load config" end
        return SaveManager.Load(name)
    end
    return SaveManager
    end)()

    local function makeActionRow(parent, labelText, layoutOrder, absoluteY, buttonWidth)
        local row = Instance.new("Frame")
        row.Name = labelText:gsub("[^%w]", "") .. "Row"
        row.Parent = parent
        row.BackgroundTransparency = 1
        row.ZIndex = 6
        if absoluteY then
            row.Position = UDim2.new(0, 10, 0, absoluteY)
            row.Size = UDim2.new(1, -20, 0, 24)
        else
            row.LayoutOrder = layoutOrder or 1
            row.Size = UDim2.new(1, -16, 0, 24)
        end

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.Size = UDim2.new(1, -((buttonWidth or 44) + 10), 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(190, 190, 205)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.ZIndex = 6

        local button = Instance.new("TextButton")
        button.Name = "ValueButton"
        button.Parent = row
        button.AnchorPoint = Vector2.new(1, 0.5)
        button.Position = UDim2.new(1, 0, 0.5, 0)
        button.Size = UDim2.fromOffset(buttonWidth or 44, 18)
        button.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
        button.BorderSizePixel = 0
        button.Text = ""
        button.TextColor3 = Color3.fromRGB(140, 140, 155)
        button.Font = Enum.Font.Code
        button.TextSize = 10
        button.ZIndex = 7
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Parent = button
        buttonStroke.Color = Color3.fromRGB(60, 60, 72)
        buttonStroke.Thickness = 1
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 3)
        buttonCorner.Parent = button
        button.MouseEnter:Connect(function() buttonStroke.Transparency = 0.2 end)
        button.MouseLeave:Connect(function() buttonStroke.Transparency = 0 end)
        return row, button
    end

    local colorPopup = nil
    local function closeColorPicker()
        if not colorPopup then return end
        local popup = colorPopup
        colorPopup = nil
        popup:Destroy()
    end

    local function openColorPicker(anchor, getColor, setColor)
        closeColorPicker()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local popupWidth, popupHeight = 196, 188

        local root = Instance.new("Frame")
        root.Name = "OmniColorPickerRoot"
        root.Parent = ScreenGui
        root.Size = UDim2.fromScale(1, 1)
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.ZIndex = 190
        colorPopup = root

        local backdrop = Instance.new("TextButton")
        backdrop.Parent = root
        backdrop.Size = UDim2.fromScale(1, 1)
        backdrop.BackgroundTransparency = 1
        backdrop.Text = ""
        backdrop.ZIndex = 190
        backdrop.Activated:Connect(closeColorPicker)

        local popup = Instance.new("Frame")
        popup.Name = "OmniColorPicker"
        popup.Parent = root
        popup.Size = UDim2.fromOffset(popupWidth, popupHeight)
        popup.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        popup.BorderSizePixel = 0
        popup.ZIndex = 200
        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, 6)
        popupCorner.Parent = popup
        local popupStroke = Instance.new("UIStroke")
        popupStroke.Parent = popup
        bindAccent(popupStroke)
        popupStroke.Thickness = 1
        local popupGradient = Instance.new("UIGradient")
        popupGradient.Rotation = 90
        popupGradient.Color = ColorSequence.new(Color3.fromRGB(20, 20, 30), Color3.fromRGB(8, 8, 14))
        popupGradient.Parent = popup

        local pickerX = anchor.AbsolutePosition.X
        local pickerY = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + 6
        pickerX = math.clamp(pickerX, 8, math.max(8, viewport.X - popupWidth - 8))
        pickerY = math.clamp(pickerY, 8, math.max(8, viewport.Y - popupHeight - 8))
        popup.Position = UDim2.fromOffset(pickerX, pickerY)

        local popupBlocker = Instance.new("TextButton")
        popupBlocker.Parent = popup
        popupBlocker.Size = UDim2.fromScale(1, 1)
        popupBlocker.BackgroundTransparency = 1
        popupBlocker.BorderSizePixel = 0
        popupBlocker.Text = ""
        popupBlocker.ZIndex = 200

        local header = Instance.new("TextLabel")
        header.Parent = popup
        header.Position = UDim2.fromOffset(10, 5)
        header.Size = UDim2.new(1, -34, 0, 16)
        header.BackgroundTransparency = 1
        header.Text = "COLOR"
        header.TextColor3 = Color3.fromRGB(235, 235, 245)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Font = Enum.Font.Code
        header.TextSize = 10
        header.ZIndex = 201

        local closeButton = Instance.new("TextButton")
        closeButton.Parent = popup
        closeButton.AnchorPoint = Vector2.new(1, 0)
        closeButton.Position = UDim2.new(1, -6, 0, 4)
        closeButton.Size = UDim2.fromOffset(18, 18)
        closeButton.BackgroundTransparency = 1
        closeButton.BorderSizePixel = 0
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(170, 170, 190)
        closeButton.Font = Enum.Font.Code
        closeButton.TextSize = 10
        closeButton.ZIndex = 201
        closeButton.Activated:Connect(closeColorPicker)

        local hue, saturation, value = getColor():ToHSV()
        local svField = Instance.new("Frame")
        svField.Parent = popup
        svField.Position = UDim2.fromOffset(10, 28)
        svField.Size = UDim2.fromOffset(142, 112)
        svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svField.BorderSizePixel = 0
        svField.ZIndex = 201
        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 3)
        svCorner.Parent = svField

        local whiteLayer = Instance.new("Frame")
        whiteLayer.Parent = svField
        whiteLayer.Size = UDim2.fromScale(1, 1)
        whiteLayer.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteLayer.BorderSizePixel = 0
        whiteLayer.ZIndex = 202
        local whiteGradient = Instance.new("UIGradient")
        whiteGradient.Parent = whiteLayer
        whiteGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

        local blackLayer = Instance.new("Frame")
        blackLayer.Parent = svField
        blackLayer.Size = UDim2.fromScale(1, 1)
        blackLayer.BackgroundColor3 = Color3.new(0, 0, 0)
        blackLayer.BorderSizePixel = 0
        blackLayer.ZIndex = 203
        local blackGradient = Instance.new("UIGradient")
        blackGradient.Parent = blackLayer
        blackGradient.Rotation = 90
        blackGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

        local svInput = Instance.new("TextButton")
        svInput.Parent = svField
        svInput.Size = UDim2.fromScale(1, 1)
        svInput.BackgroundTransparency = 1
        svInput.BorderSizePixel = 0
        svInput.Text = ""
        svInput.ZIndex = 204

        local svCursor = Instance.new("Frame")
        svCursor.Parent = svField
        svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        svCursor.Size = UDim2.fromOffset(10, 10)
        svCursor.BackgroundTransparency = 1
        svCursor.BorderSizePixel = 0
        svCursor.ZIndex = 205
        local cursorCorner = Instance.new("UICorner")
        cursorCorner.CornerRadius = UDim.new(1, 0)
        cursorCorner.Parent = svCursor
        local cursorStroke = Instance.new("UIStroke")
        cursorStroke.Parent = svCursor
        cursorStroke.Color = Color3.fromRGB(255, 255, 255)
        cursorStroke.Thickness = 1

        local hueBar = Instance.new("Frame")
        hueBar.Parent = popup
        hueBar.Position = UDim2.fromOffset(158, 28)
        hueBar.Size = UDim2.fromOffset(24, 112)
        hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
        hueBar.BorderSizePixel = 0
        hueBar.ZIndex = 201
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(0, 3)
        hueCorner.Parent = hueBar
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Parent = hueBar
        hueGradient.Rotation = 90
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        })

        local hueInput = Instance.new("TextButton")
        hueInput.Parent = hueBar
        hueInput.Size = UDim2.fromScale(1, 1)
        hueInput.BackgroundTransparency = 1
        hueInput.BorderSizePixel = 0
        hueInput.Text = ""
        hueInput.ZIndex = 204

        local hueMark = Instance.new("Frame")
        hueMark.Parent = hueBar
        hueMark.Size = UDim2.new(1, 0, 0, 3)
        hueMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueMark.BorderSizePixel = 0
        hueMark.ZIndex = 205
        local hueMarkStroke = Instance.new("UIStroke")
        hueMarkStroke.Parent = hueMark
        hueMarkStroke.Color = Color3.fromRGB(15, 15, 20)
        hueMarkStroke.Thickness = 1

        local currentSwatch = Instance.new("Frame")
        currentSwatch.Parent = popup
        currentSwatch.Position = UDim2.fromOffset(10, 150)
        currentSwatch.Size = UDim2.fromOffset(18, 18)
        currentSwatch.BorderSizePixel = 0
        currentSwatch.ZIndex = 201
        local currentCorner = Instance.new("UICorner")
        currentCorner.CornerRadius = UDim.new(0, 3)
        currentCorner.Parent = currentSwatch
        local currentStroke = Instance.new("UIStroke")
        currentStroke.Parent = currentSwatch
        currentStroke.Color = Color3.fromRGB(255, 255, 255)
        currentStroke.Thickness = 1
        currentStroke.Transparency = 0.5

        local hexLabel = Instance.new("TextLabel")
        hexLabel.Parent = popup
        hexLabel.Position = UDim2.fromOffset(34, 150)
        hexLabel.Size = UDim2.new(1, -44, 0, 18)
        hexLabel.BackgroundTransparency = 1
        hexLabel.Text = ""
        hexLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
        hexLabel.TextXAlignment = Enum.TextXAlignment.Left
        hexLabel.Font = Enum.Font.Code
        hexLabel.TextSize = 10
        hexLabel.ZIndex = 201

        local hint = Instance.new("TextLabel")
        hint.Parent = popup
        hint.Position = UDim2.fromOffset(10, 168)
        hint.Size = UDim2.new(1, -20, 0, 12)
        hint.BackgroundTransparency = 1
        hint.Text = "drag to pick  |  click outside to close"
        hint.TextColor3 = Color3.fromRGB(115, 115, 135)
        hint.TextXAlignment = Enum.TextXAlignment.Left
        hint.Font = Enum.Font.Code
        hint.TextSize = 8
        hint.ZIndex = 201

        local dragMode = nil
        local popupConnections = {}
        local function applyColor()
            local color = Color3.fromHSV(hue, saturation, value)
            setColor(color)
            svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            svCursor.Position = UDim2.fromScale(saturation, 1 - value)
            hueMark.Position = UDim2.new(0, 0, hue, -1)
            currentSwatch.BackgroundColor3 = color
            local r = math.floor(math.clamp(color.R, 0, 1) * 255 + 0.5)
            local g = math.floor(math.clamp(color.G, 0, 1) * 255 + 0.5)
            local b = math.floor(math.clamp(color.B, 0, 1) * 255 + 0.5)
            hexLabel.Text = string.format("#%02X%02X%02X", r, g, b)
        end
        local function updateFromPointer(position)
            if dragMode == "SV" then
                local origin, size = svField.AbsolutePosition, svField.AbsoluteSize
                saturation = math.clamp((position.X - origin.X) / math.max(size.X, 1), 0, 1)
                value = 1 - math.clamp((position.Y - origin.Y) / math.max(size.Y, 1), 0, 1)
            elseif dragMode == "Hue" then
                local origin, size = hueBar.AbsolutePosition, hueBar.AbsoluteSize
                hue = math.clamp((position.Y - origin.Y) / math.max(size.Y, 1), 0, 1)
            end
            applyColor()
        end
        svInput.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragMode = "SV"
                updateFromPointer(input.Position)
            end
        end)
        hueInput.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragMode = "Hue"
                updateFromPointer(input.Position)
            end
        end)
        popupConnections[#popupConnections + 1] = UIS.InputChanged:Connect(function(input)
            if dragMode and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromPointer(input.Position)
            end
        end)
        popupConnections[#popupConnections + 1] = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragMode = nil
            end
        end)
        root.Destroying:Connect(function()
            for index = 1, #popupConnections do
                popupConnections[index]:Disconnect()
            end
        end)
        applyColor()
    end

    local function makeColorSwatch(parent, getColor, setColor)
        local swatch = Instance.new("TextButton")
        swatch.Name = "ColorSwatch"
        swatch.Parent = parent
        swatch.AnchorPoint = Vector2.new(1, 0.5)
        swatch.Position = UDim2.new(1, -28, 0.5, 0)
        swatch.Size = UDim2.fromOffset(16, 16)
        swatch.BackgroundColor3 = getColor()
        swatch.BorderSizePixel = 0
        swatch.Text = ""
        swatch.ZIndex = 8
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = swatch
        local stroke = Instance.new("UIStroke")
        stroke.Parent = swatch
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.45
        local function refresh()
            swatch.BackgroundColor3 = getColor()
        end
        swatch.Activated:Connect(function()
            openColorPicker(swatch, getColor, function(color)
                setColor(color)
                refresh()
            end)
        end)
        swatch.MouseEnter:Connect(function() stroke.Transparency = 0.1 end)
        swatch.MouseLeave:Connect(function() stroke.Transparency = 0.45 end)
        refresh()
        return swatch, refresh
    end

    local function makeToggleRow(parent, labelText, getValue, setValue, layoutOrder, absoluteY, colorConfig, bindId)
        local row = Instance.new("Frame")
        row.Name = labelText:gsub("[^%w]", "") .. "Row"
        row.Parent = parent
        row.BackgroundTransparency = 1
        row.ZIndex = 6
        if absoluteY then
            row.Position = UDim2.new(0, 10, 0, absoluteY)
            row.Size = UDim2.new(1, -20, 0, 26)
        else
            row.LayoutOrder = layoutOrder or 1
            row.Size = UDim2.new(1, -16, 0, 26)
        end

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.Size = UDim2.new(1, (colorConfig and -60 or -32) - (bindId and 82 or 0), 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(200, 200, 215)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.ZIndex = 6

        local check = Instance.new("TextButton")
        check.Name = "ToggleCheckbox"
        check.Parent = row
        check.AnchorPoint = Vector2.new(1, 0.5)
        check.Position = UDim2.new(1, bindId and -82 or 0, 0.5, 0)
        check.Size = UDim2.fromOffset(18, 18)
        check.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        check.BorderSizePixel = 0
        check.Text = ""
        check.ZIndex = 8
        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 2)
        checkCorner.Parent = check
        local checkStroke = Instance.new("UIStroke")
        checkStroke.Parent = check
        checkStroke.Color = Color3.fromRGB(78, 78, 92)
        checkStroke.Thickness = 1

        local function refresh()
            local on = getValue() and true or false
            check.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
            checkStroke.Color = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(78, 78, 92)
        end
        check.Activated:Connect(function()
            setValue(not (getValue() and true or false))
            refresh()
        end)
        check.MouseEnter:Connect(function() checkStroke.Transparency = 0.15 end)
        check.MouseLeave:Connect(function() checkStroke.Transparency = 0 end)
        if bindId then
            local bindButton = Instance.new("TextButton")
            bindButton.Name = "BindButton"
            bindButton.Parent = row
            bindButton.AnchorPoint = Vector2.new(1, 0.5)
            bindButton.Position = UDim2.new(1, 0, 0.5, 0)
            bindButton.Size = UDim2.fromOffset(74, 20)
            bindButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            bindButton.BorderSizePixel = 0
            bindButton.Text = "None"
            bindButton.TextColor3 = Color3.fromRGB(225, 225, 235)
            bindButton.Font = Enum.Font.Code
            bindButton.TextSize = 10
            bindButton.ZIndex = 8
            local bindCorner = Instance.new("UICorner")
            bindCorner.CornerRadius = UDim.new(0, 3)
            bindCorner.Parent = bindButton
            local bindStroke = Instance.new("UIStroke")
            bindStroke.Parent = bindButton
            bindStroke.Color = Color3.fromRGB(60, 60, 72)
            bindStroke.Thickness = 1
            local function refreshBind()
                local entry = keybindById[bindId]
                if keybindCapture == bindId then
                    bindButton.Text = "..."
                else
                    bindButton.Text = entry and entry.key or "None"
                end
            end
            bindButton.Activated:Connect(function()
                keybindCapture = bindId
                refreshBind()
            end)
            bindButton.MouseButton2Click:Connect(function()
                keybindCapture = nil
                KeybindSet(bindId, "None")
            end)
            refreshBind()
            keybindRowRefreshers[bindId] = refreshBind
        end
        if colorConfig then
            makeColorSwatch(row, colorConfig.get, colorConfig.set)
        end
        refresh()
        uiRefreshers[#uiRefreshers + 1] = refresh
        return row, refresh
    end

    local function makeSliderRow(parent, labelText, minValue, maxValue, step, getValue, setValue, layoutOrder, absoluteY)
        step = step or 1
        local row = Instance.new("Frame")
        row.Name = labelText:gsub("[^%w]", "") .. "SliderRow"
        row.Parent = parent
        row.BackgroundTransparency = 1
        row.ZIndex = 6
        if absoluteY then
            row.Position = UDim2.new(0, 10, 0, absoluteY)
            row.Size = UDim2.new(1, -20, 0, 30)
        else
            row.LayoutOrder = layoutOrder or 1
            row.Size = UDim2.new(1, -16, 0, 30)
        end

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.Size = UDim2.new(0, 96, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(200, 200, 215)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.ZIndex = 6

        local track = Instance.new("Frame")
        track.Name = "SliderTrack"
        track.Parent = row
        track.Position = UDim2.fromOffset(100, 0)
        track.Size = UDim2.new(1, -150, 1, 0)
        track.BackgroundTransparency = 1
        track.BorderSizePixel = 0
        track.ZIndex = 7

        local line = Instance.new("Frame")
        line.Parent = track
        line.AnchorPoint = Vector2.new(0, 0.5)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.Size = UDim2.new(1, 0, 0, 3)
        line.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        line.BorderSizePixel = 0
        line.ZIndex = 7
        local lineCorner = Instance.new("UICorner")
        lineCorner.CornerRadius = UDim.new(1, 0)
        lineCorner.Parent = line

        local fill = Instance.new("Frame")
        fill.Parent = track
        fill.AnchorPoint = Vector2.new(0, 0.5)
        fill.Position = UDim2.new(0, 0, 0.5, 0)
        fill.Size = UDim2.new(0, 0, 0, 3)
        fill.BorderSizePixel = 0
        fill.ZIndex = 8
        local fillGradient = Instance.new("UIGradient")
        fillGradient.Parent = fill
        fillGradient.Color = ColorSequence.new(uiAccentColor, Color3.fromRGB(223, 57, 137))
        bindAccentGradient(fillGradient)
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local knob = Instance.new("Frame")
        knob.Parent = track
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.Size = UDim2.fromOffset(11, 11)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 9
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Parent = row
        valueLabel.AnchorPoint = Vector2.new(1, 0.5)
        valueLabel.Position = UDim2.new(1, 0, 0.5, 0)
        valueLabel.Size = UDim2.fromOffset(44, 18)
        valueLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
        valueLabel.BorderSizePixel = 0
        valueLabel.Text = ""
        valueLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
        valueLabel.Font = Enum.Font.Code
        valueLabel.TextSize = 10
        valueLabel.ZIndex = 8
        local valueCorner = Instance.new("UICorner")
        valueCorner.CornerRadius = UDim.new(0, 3)
        valueCorner.Parent = valueLabel
        local valueStroke = Instance.new("UIStroke")
        valueStroke.Parent = valueLabel
        valueStroke.Color = Color3.fromRGB(60, 60, 72)
        valueStroke.Thickness = 1

        local dragging = false
        local function refresh()
            local value = math.clamp(getValue(), minValue, maxValue)
            local alpha = (value - minValue) / math.max(maxValue - minValue, 1)
            fill.Size = UDim2.new(alpha, 0, 0, 3)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            valueLabel.Text = step < 1 and string.format("%.2f", value) or tostring(math.floor(value + 0.5))
        end
        local function updateFromPointer(position)
            local size = track.AbsoluteSize.X
            if size <= 0 then return end
            local alpha = math.clamp((position.X - track.AbsolutePosition.X) / size, 0, 1)
            local raw = minValue + (maxValue - minValue) * alpha
            local stepped = math.floor(raw / step + 0.5) * step
            setValue(math.clamp(stepped, minValue, maxValue))
            refresh()
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromPointer(input.Position)
            end
        end)
        table.insert(tabConnections, UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromPointer(input.Position)
            end
        end))
        table.insert(tabConnections, UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        refresh()
        uiRefreshers[#uiRefreshers + 1] = refresh
        return row, refresh
    end

    local function makeBindRow(parent, labelText, layoutOrder, absoluteY)
        local row = Instance.new("Frame")
        row.Name = labelText:gsub("[^%w]", "") .. "BindRow"
        row.Parent = parent
        row.BackgroundTransparency = 1
        row.ZIndex = 6
        if absoluteY then
            row.Position = UDim2.new(0, 10, 0, absoluteY)
            row.Size = UDim2.new(1, -20, 0, 26)
        else
            row.LayoutOrder = layoutOrder or 1
            row.Size = UDim2.new(1, -16, 0, 26)
        end

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.Size = UDim2.new(1, -86, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(200, 200, 215)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.ZIndex = 6

        local button = Instance.new("TextButton")
        button.Name = "BindButton"
        button.Parent = row
        button.AnchorPoint = Vector2.new(1, 0.5)
        button.Position = UDim2.new(1, 0, 0.5, 0)
        button.Size = UDim2.fromOffset(78, 20)
        button.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
        button.BorderSizePixel = 0
        button.Text = "NONE"
        button.TextColor3 = Color3.fromRGB(225, 225, 235)
        button.Font = Enum.Font.Code
        button.TextSize = 10
        button.ZIndex = 8
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = button
        local stroke = Instance.new("UIStroke")
        stroke.Parent = button
        stroke.Color = Color3.fromRGB(60, 60, 72)
        stroke.Thickness = 1
        return row, button
    end

    local function showTab(tabName)
        closeColorPicker()
        setActiveTab(tabName)
        for i = 1, #tabConnections do
            local connection = tabConnections[i]
            connection:Disconnect()
        end
        table.clear(tabConnections)
        table.clear(uiRefreshers)
        table.clear(keybindRowRefreshers)
			for _, child in Content:GetChildren() do
				child:Destroy()
			end

			local innerTabs = tabDefinitions[tabName]
			if not innerTabs then
				return
			end

			for index = 1, #innerTabs do
			    local innerName = innerTabs[index]
				local section = Instance.new("Frame")
				section.Name = innerName .. "Section"
				section.Parent = Content
				section.Position = UDim2.new((index - 1) * 0.5, index > 1 and 4 or 0, 0, 0)
				section.Size = UDim2.new(#innerTabs == 1 and 1 or 0.5, #innerTabs == 1 and 0 or -4, 1, 0)
                if tabName == "Visuals" or tabName == "Combat" then
                    section.Position = UDim2.fromOffset(0, 0)
                    section.Size = UDim2.new(1, 0, 1, 0)
                end
              if innerName == "Player Visuals" then
                  section.Position = UDim2.new(0, 0, 0, 0)
                  section.Size = UDim2.new(0.5, -4, 1, 0)
                  section.Visible = false
              end
              if innerName == "Skin Changer" then
                  section.Position = UDim2.new(0, 0, 0, 0)
                  section.Size = UDim2.new(1, 0, 1, 0)
                  section.Visible = false
              end
				section.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
				section.BorderSizePixel = 0

				local sectionStroke = Instance.new("UIStroke")
				sectionStroke.Parent = section
				bindAccent(sectionStroke)
				sectionStroke.Thickness = 1

				local title = Instance.new("TextLabel")
				title.Name = "Title"
				title.Parent = section
				title.Size = UDim2.new(1, 0, 0, 30)
				title.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
				title.BorderSizePixel = 0
				title.Text = innerName
				title.TextColor3 = Color3.fromRGB(255, 255, 255)
				title.Font = Enum.Font.Code
				title.TextSize = 14

            if innerName == "ESP" then
                local pages, selectInnerTab = makeSubTabs(section, { "ESP", "Inventory", "Loot", "World" }, 36)
                for _, visualPage in pairs(pages) do
                    visualPage.Size = UDim2.new(1, -12, 1, -70)
                    visualPage.ScrollBarThickness = 4
                    visualPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
                end
                pages["ESP"].Name = "ESPPage"

                makeToggleRow(pages["ESP"], "ESP", function() return espState.enabled end, function(value)
                    espState.enabled = value
                    espLayer.Visible = value
                end, 1, nil, nil, "esp")
                makeToggleRow(pages["ESP"], "Box", function() return espState.box end, function(value) espState.box = value end, 2, nil, espColor("box"))
                makeToggleRow(pages["ESP"], "Name", function() return espState.names end, function(value) espState.names = value end, 3, nil, espColor("name"))
                makeToggleRow(pages["ESP"], "Health", function() return espState.health end, function(value) espState.health = value end, 4, nil, {
                    get = function() return espHealthColors.top end,
                    set = function(color) 
                        espHealthColors.top = color
                        espHealthColors.version += 1
                        applyHealthBarColors()
                    end,
                })
                makeToggleRow(pages["ESP"], "Health Low Color", function() return espHealthColors.bottom end, function(value) 
                    espHealthColors.bottom = value
                    espHealthColors.version += 1
                    applyHealthBarColors()
                end, 20, nil, {
                    get = function() return espHealthColors.bottom end,
                    set = function(color) 
                        espHealthColors.bottom = color
                        espHealthColors.version += 1
                        applyHealthBarColors()
                    end,
                })
                makeToggleRow(pages["ESP"], "Distance", function() return espState.distance end, function(value) espState.distance = value end, 5, nil, espColor("distance"))
                makeToggleRow(pages["ESP"], "Tracer", function() return espState.tracer end, function(value) espState.tracer = value end, 6, nil, espColor("tracer"))
                makeToggleRow(pages["ESP"], "Chams", function() return espState.chams end, function(value)
                    espState.chams = value
                    if not value then chamsRestoreMaterials() end
                end, 7, nil, espColor("chams"))
                makeToggleRow(pages["ESP"], "Skeleton", function() return espState.skeleton end, function(value) espState.skeleton = value end, 8, nil, espColor("skeleton"))
                makeToggleRow(pages["ESP"], "Head Dot", function() return espState.headDot end, function(value) espState.headDot = value end, 9, nil, espColor("headDot"))
                makeToggleRow(pages["ESP"], "Box Fill", function() return espState.boxFill end, function(value) espState.boxFill = value end, 10, nil, espColor("boxFill"))
                makeToggleRow(pages["ESP"], "Corner Box", function() return espState.cornerBox end, function(value) espState.cornerBox = value end, 11)
                makeToggleRow(pages["ESP"], "Team Check", function() return espState.teamCheck end, function(value) espState.teamCheck = value end, 12)
                makeToggleRow(pages["ESP"], "Walls", function() return espState.walls end, function(value) espState.walls = value end, 13)
                makeToggleRow(pages["ESP"], "Visibility", function() return espState.visibility end, function(value) espState.visibility = value end, 14)

                local _, maxDistanceButton = makeActionRow(pages["ESP"], "Max Distance", 14, nil, 64)
                local distanceOptions = { 300, 600, 1000, 2000, 5000, 0 }
                local function refreshMaxDistance()
                    maxDistanceButton.Text = espState.maxDistance == 0 and "OFF" or (tostring(espState.maxDistance) .. "m")
                end
                maxDistanceButton.Activated:Connect(function()
                    local found = 1
                    for index = 1, #distanceOptions do
                        if distanceOptions[index] == espState.maxDistance then
                            found = index
                            break
                        end
                    end
                    found = found % #distanceOptions + 1
                    espState.maxDistance = distanceOptions[found]
                    refreshMaxDistance()
                end)
                refreshMaxDistance()

                makeToggleRow(pages["ESP"], "Infinite Distance", function() return espState.infinite end, function(value) espState.infinite = value end, 15)

                local _, chamsMaterialButton = makeActionRow(pages["ESP"], "Chams Material", 16, nil, 110)
                local chamsMaterials = { "Neon", "ForceField", "Glass", "SmoothPlastic" }
                local function refreshChamsMaterial()
                    chamsMaterialButton.Text = chamsState.material
                end
                chamsMaterialButton.Activated:Connect(function()
                    local found = 1
                    for index = 1, #chamsMaterials do
                        if chamsMaterials[index] == chamsState.material then
                            found = index
                            break
                        end
                    end
                    chamsState.material = chamsMaterials[found % #chamsMaterials + 1]
                    chamsRestoreMaterials()
                    refreshChamsMaterial()
                end)
                refreshChamsMaterial()
                makeSliderRow(pages["ESP"], "Chams Fill", 0, 1, 0.01,
                    function() return chamsState.fillTransparency end,
                    function(value) chamsState.fillTransparency = value end, 18)
                makeToggleRow(pages["ESP"], "Chams Outline", function() return chamsState.outline end,
                    function(value) chamsState.outline = value end, 19)
                makeSliderRow(pages["ESP"], "Outline Alpha", 0, 1, 0.01,
                    function() return chamsState.outlineTransparency end,
                    function(value) chamsState.outlineTransparency = value end, 20)
                makeToggleRow(pages["ESP"], "Rainbow Chams", function() return chamsState.rainbow end,
                    function(value) chamsState.rainbow = value end, 21)
                makeToggleRow(pages["ESP"], "Pulse Chams", function() return chamsState.pulse end,
                    function(value) chamsState.pulse = value end, 22)
                makeToggleRow(pages["ESP"], "Strobe Chams", function() return chamsState.strobe end,
                    function(value) chamsState.strobe = value end, 23)
                makeSliderRow(pages["ESP"], "Chams Intensity", 0, 1, 0.01,
                    function() return chamsState.intensity end,
                    function(value) chamsState.intensity = value end, 24)
                makeSliderRow(pages["ESP"], "Chams Saturation", 0, 1, 0.01,
                    function() return chamsState.saturation end,
                    function(value) chamsState.saturation = value end, 25)
                makeToggleRow(pages["ESP"], "Material Chams", function() return chamsState.materialOn end,
                    function(value)
                        chamsState.materialOn = value
                        if not value then chamsRestoreMaterials() end
                    end, 17)

                makeToggleRow(pages["ESP"], "Arm Chams", function() return VMChams.armEnabled end,
                    function(value)
                        VMChams.armEnabled = value
                        VMChams.Refresh()
                    end, 26, nil, {
                        get = function() return VMChams.armColor end,
                        set = function(color)
                            VMChams.armColor = color
                            VMChams.Refresh()
                        end,
                    })
                local _, armMaterialButton = makeActionRow(pages["ESP"], "Arm Material", 27, nil, 110)
                local materialOptions = { "SmoothPlastic", "Neon", "ForceField", "Glass" }
                local function cycleVMChamsMaterial(button, key)
                    local current = 1
                    for index = 1, #materialOptions do
                        if materialOptions[index] == VMChams[key] then
                            current = index
                            break
                        end
                    end
                    VMChams[key] = materialOptions[current % #materialOptions + 1]
                    button.Text = VMChams[key]
                    VMChams.Refresh()
                end
                armMaterialButton.Activated:Connect(function()
                    cycleVMChamsMaterial(armMaterialButton, "armMaterial")
                end)
                armMaterialButton.Text = VMChams.armMaterial

                makeToggleRow(pages["ESP"], "Gun Chams", function() return VMChams.gunEnabled end,
                    function(value)
                        VMChams.gunEnabled = value
                        VMChams.Refresh()
                    end, 28, nil, {
                        get = function() return VMChams.gunColor end,
                        set = function(color)
                            VMChams.gunColor = color
                            VMChams.Refresh()
                        end,
                    })
                local _, gunMaterialButton = makeActionRow(pages["ESP"], "Gun Material", 29, nil, 110)
                gunMaterialButton.Activated:Connect(function()
                    cycleVMChamsMaterial(gunMaterialButton, "gunMaterial")
                end)
                gunMaterialButton.Text = VMChams.gunMaterial

                local inventoryPage = pages["Inventory"]
                local inventoryPageLayout = inventoryPage:FindFirstChildOfClass("UIListLayout")
                if inventoryPageLayout then
                    inventoryPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                end

                local toggleRow, refreshInventoryToggle = makeToggleRow(inventoryPage, "Inventory Viewer", function()
                    return inventoryViewer.enabled
                end, function(value)
                    setInventoryViewerEnabled(value)
                end, 1)

                toggleRow.Name = "InventoryViewerToggleRow"

                local modeRow = Instance.new("Frame")
                modeRow.Name = "InventoryViewerModeRow"
                modeRow.Parent = inventoryPage
                modeRow.LayoutOrder = 2
                modeRow.Size = UDim2.new(1, -16, 0, 26)
                modeRow.BackgroundTransparency = 1
                modeRow.ZIndex = 6
                local modeLabel = Instance.new("TextLabel")
                modeLabel.Parent = modeRow
                modeLabel.Size = UDim2.new(1, -140, 1, 0)
                modeLabel.BackgroundTransparency = 1
                modeLabel.Text = "Display Mode"
                modeLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
                modeLabel.TextXAlignment = Enum.TextXAlignment.Left
                modeLabel.Font = Enum.Font.Code
                modeLabel.TextSize = 11
                modeLabel.ZIndex = 6
                local imageModeButton = Instance.new("TextButton")
                imageModeButton.Name = "InventoryViewerImageMode"
                imageModeButton.Parent = modeRow
                imageModeButton.Position = UDim2.new(1, -132, 0, 3)
                imageModeButton.Size = UDim2.fromOffset(64, 20)
                imageModeButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                imageModeButton.BorderSizePixel = 0
                imageModeButton.Text = "Image"
                imageModeButton.Font = Enum.Font.Code
                imageModeButton.TextSize = 10
                imageModeButton.ZIndex = 7
                local imageModeCorner = Instance.new("UICorner")
                imageModeCorner.CornerRadius = UDim.new(0, 3)
                imageModeCorner.Parent = imageModeButton
                local imageModeStroke = Instance.new("UIStroke")
                imageModeStroke.Parent = imageModeButton
                imageModeStroke.Color = Color3.fromRGB(60, 60, 72)
                imageModeStroke.Thickness = 1
                local textModeButton = Instance.new("TextButton")
                textModeButton.Name = "InventoryViewerTextMode"
                textModeButton.Parent = modeRow
                textModeButton.Position = UDim2.new(1, -66, 0, 3)
                textModeButton.Size = UDim2.fromOffset(64, 20)
                textModeButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                textModeButton.BorderSizePixel = 0
                textModeButton.Text = "Text"
                textModeButton.Font = Enum.Font.Code
                textModeButton.TextSize = 10
                textModeButton.ZIndex = 7
                local textModeCorner = Instance.new("UICorner")
                textModeCorner.CornerRadius = UDim.new(0, 3)
                textModeCorner.Parent = textModeButton
                local textModeStroke = Instance.new("UIStroke")
                textModeStroke.Parent = textModeButton
                textModeStroke.Color = Color3.fromRGB(60, 60, 72)
                textModeStroke.Thickness = 1
                imageModeButton.Activated:Connect(function()
                    inventoryViewer.mode = "Image"
                    inventoryLastSignature = nil
                    if inventoryViewer.enabled then renderInventoryViewer(true) end
                    if inventoryViewer.refreshControls then pcall(inventoryViewer.refreshControls) end
                end)
                textModeButton.Activated:Connect(function()
                    inventoryViewer.mode = "Text"
                    inventoryLastSignature = nil
                    if inventoryViewer.enabled then renderInventoryViewer(true) end
                    if inventoryViewer.refreshControls then pcall(inventoryViewer.refreshControls) end
                end)

                local keybindRow, keybindButton = makeBindRow(inventoryPage, "Toggle Bind", 3)
                keybindRow.Name = "InventoryViewerKeybindRow"
                local keybindButtonStroke = keybindButton:FindFirstChildOfClass("UIStroke")
                keybindButton.Activated:Connect(function()
                    inventoryViewer.capturing = true
                    if inventoryViewer.refreshControls then pcall(inventoryViewer.refreshControls) end
                end)
                keybindButton.MouseButton2Click:Connect(function()
                    inventoryViewer.key = Enum.KeyCode.None
                    refreshInventoryKeybindLabel()
                    if inventoryViewer.refreshControls then pcall(inventoryViewer.refreshControls) end
                end)

                local function refreshInventoryControls()
                    refreshInventoryToggle()
                    local imageOn = inventoryViewer.mode == "Image"
                    imageModeButton.BackgroundColor3 = imageOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(18, 18, 30)
                    imageModeButton.TextColor3 = imageOn and Color3.fromRGB(10, 10, 18) or Color3.fromRGB(200, 200, 215)
                    imageModeStroke.Color = imageOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 72)
                    textModeButton.BackgroundColor3 = (not imageOn) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(18, 18, 30)
                    textModeButton.TextColor3 = (not imageOn) and Color3.fromRGB(10, 10, 18) or Color3.fromRGB(200, 200, 215)
                    textModeStroke.Color = (not imageOn) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 72)
                    keybindButton.Text = inventoryViewer.capturing and "..." or inventoryKeyName()
                    keybindButton.TextColor3 = inventoryViewer.capturing and uiAccentColor or Color3.fromRGB(225, 225, 235)
                    keybindButton.BackgroundColor3 = inventoryViewer.capturing and Color3.fromRGB(34, 27, 48) or Color3.fromRGB(18, 18, 30)
                    if keybindButtonStroke then
                        keybindButtonStroke.Color = inventoryViewer.capturing and uiAccentColor or Color3.fromRGB(60, 60, 72)
                    end
                end

                inventoryViewer.refreshControls = refreshInventoryControls
                refreshInventoryControls()

                inventoryPage.Destroying:Connect(function()
                    inventoryViewer.capturing = false
                    if inventoryViewer.refreshControls == refreshInventoryControls then
                        inventoryViewer.refreshControls = nil
                    end
                end)

                local worldPage = pages["World"]
                local worldOrder = 1
                local function worldToggle(label, key, bindId)
                    makeToggleRow(worldPage, label, function() return _G.__OmniVisualPort.state[key] end,
                        function(value)
                            _G.__OmniVisualPort.state[key] = value
                            if key == "snaplines" then espState.tracer = value end
                            _G.__OmniVisualPort.scan()
                        end, worldOrder, nil, nil, bindId)
                    worldOrder += 1
                end
                worldToggle("Corpse ESP", "corpses")
                worldToggle("AI ESP", "ai")
                worldToggle("Boss Tracker", "bosses")
                worldToggle("Extraction ESP", "extractions")
                worldToggle("Dropped Item ESP", "droppedItems")
                worldToggle("Snaplines", "snaplines")
                worldToggle("Radar", "radar", "radar")
                makeSliderRow(worldPage, "Radar Range", 50, 500, 10,
                    function() return _G.__OmniVisualPort.state.radarRange end,
                    function(value) _G.__OmniVisualPort.state.radarRange = value end, worldOrder)
                worldOrder += 1

                local function worldHeader(text)
                    local header = Instance.new("TextLabel")
                    header.Name = "WorldHeader"
                    header.Parent = worldPage
                    header.LayoutOrder = worldOrder
                    header.Size = UDim2.new(1, -16, 0, 20)
                    header.BackgroundTransparency = 1
                    header.Text = text
                    header.TextColor3 = Color3.fromRGB(150, 150, 170)
                    header.TextXAlignment = Enum.TextXAlignment.Left
                    header.Font = Enum.Font.Code
                    header.TextSize = 11
                    header.ZIndex = 6
                    worldOrder += 1
                end

                local function worldFxToggle(label, key, afterApply, bindId)
                    makeToggleRow(worldPage, label, function() return OMNI_WORLD.state[key] end, function(value)
                        OMNI_WORLD.state[key] = value
                        if afterApply then afterApply() else OMNI_WORLD.apply() end
                    end, worldOrder, nil, nil, bindId)
                    worldOrder += 1
                end

                local function worldFxSlider(label, minValue, maxValue, step, key, afterApply)
                    makeSliderRow(worldPage, label, minValue, maxValue, step,
                        function() return OMNI_WORLD.state[key] end,
                        function(value)
                            OMNI_WORLD.state[key] = value
                            if afterApply then afterApply() else OMNI_WORLD.apply() end
                        end, worldOrder)
                    worldOrder += 1
                end

                local function worldFxColor(label, key)
                    local row = Instance.new("Frame")
                    row.Name = label:gsub("[^%w]", "") .. "ColorRow"
                    row.Parent = worldPage
                    row.LayoutOrder = worldOrder
                    row.Size = UDim2.new(1, -16, 0, 26)
                    row.BackgroundTransparency = 1
                    row.ZIndex = 6
                    local text = Instance.new("TextLabel")
                    text.Parent = row
                    text.Size = UDim2.new(1, -32, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = label
                    text.TextColor3 = Color3.fromRGB(200, 200, 215)
                    text.TextXAlignment = Enum.TextXAlignment.Left
                    text.Font = Enum.Font.Code
                    text.TextSize = 11
                    text.ZIndex = 6
                    makeColorSwatch(row, function() return OMNI_WORLD.state[key] end, function(color)
                        OMNI_WORLD.state[key] = color
                        OMNI_WORLD.apply()
                    end)
                    worldOrder += 1
                end

                local function worldFxCycle(label, values, key)
                    local row, button = makeActionRow(worldPage, label, worldOrder, nil, 120)
                    worldOrder += 1
                    local function refresh()
                        button.Text = values[OMNI_WORLD.state[key]] or tostring(OMNI_WORLD.state[key])
                    end
                    button.Activated:Connect(function()
                        OMNI_WORLD.state[key] = (OMNI_WORLD.state[key] % #values) + 1
                        refresh()
                        OMNI_WORLD.apply()
                    end)
                    refresh()
                    return row
                end

                worldHeader("Lighting")
                worldFxToggle("Full Bright", "fullBright", nil, "fullbright")
                worldFxToggle("No Fog", "noFog")
                worldFxToggle("Ambient Changer", "ambientOn")
                worldFxColor("Ambient Color", "ambientA")
                worldFxColor("Outdoor Ambient", "ambientB")
                worldFxToggle("Time Changer", "timeOn")
                worldFxSlider("Time", 0, 24, 1, "timeVal")

                worldHeader("Fog")
                worldFxToggle("Custom Fog", "fogOn")
                worldFxSlider("Fog Start", 0, 2000, 1, "fogStart")
                worldFxSlider("Fog End", 50, 10000, 10, "fogEnd")
                worldFxColor("Fog Color", "fogColor")

                worldHeader("Sky")
                worldFxToggle("Custom Skybox", "skyOn")
                worldFxCycle("Skybox", { "Purple Nebula", "Vaporwave", "Deep Space", "Night Sky", "Sunset", "Blood Moon", "Purple Planet" }, "skyPreset")
                worldFxSlider("Sky Rotation X", -90, 90, 1, "skyRotX")
                worldFxSlider("Sky Rotation Z", 0, 360, 1, "skyRotZ")
                worldFxToggle("No Clouds", "noClouds")

                worldHeader("Atmosphere")
                worldFxToggle("Atmosphere Controls", "atmoOn")
                worldFxSlider("Atmosphere Density", 0, 100, 1, "atmoDensity")
                worldFxSlider("Atmosphere Haze", 0, 10, 1, "atmoHaze")
                worldFxSlider("Atmosphere Glare", 0, 10, 1, "atmoGlare")
                worldFxSlider("Atmosphere Offset", -100, 100, 1, "atmoOffset")
                worldFxColor("Atmosphere Color", "atmoColor")
                worldFxColor("Atmosphere Decay", "atmoDecay")

                worldHeader("Clouds")
                worldFxToggle("Custom Cloud Settings", "cloudOn")
                worldFxSlider("Cloud Cover", 0, 100, 1, "cloudCover")
                worldFxSlider("Cloud Density", 0, 100, 1, "cloudDensity")
                worldFxColor("Cloud Color", "cloudColor")

                worldHeader("Post Processing")
                worldFxToggle("Bloom", "bloomOn")
                worldFxSlider("Bloom Intensity", 0, 5, 1, "bloomIntensity")
                worldFxSlider("Bloom Size", 0, 56, 1, "bloomSize")
                worldFxSlider("Bloom Threshold", 0, 2, 1, "bloomThreshold")
                worldFxToggle("Color Grading", "gradeOn")
                worldFxColor("Color Grade Tint", "gradeTint")
                worldFxSlider("Saturation", -100, 150, 1, "gradeSat")
                worldFxSlider("Contrast", -100, 100, 1, "gradeContrast")
                worldFxSlider("Brightness", -100, 100, 1, "gradeBrightness")

                worldHeader("Terrain")
                worldFxToggle("Terrain Material Color", "terrainOn")
                worldFxCycle("Terrain Material", OMNI_WORLD.terrainMaterials, "terrainMat")
                worldFxColor("Terrain Color", "terrainColor")
                worldFxToggle("Remove Grass", "removeGrass")
                worldFxToggle("Extreme Potato Mode", "potato")

                worldHeader("Foliage")
                worldFxToggle("No Leaves", "noLeaves")
                worldFxToggle("No Foliage", "noFoliage")
                worldFxToggle("No Trees", "noTrees")
            end

            if innerName == "Player" then
                makeToggleRow(section, "Flyhack", function() return OMNI_WORLD.movement.flyEnabled end, function(value)
                    OMNI_WORLD.movement.flyEnabled = value
                    if not value then
                        local character = Player.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end) end
                    end
                end, nil, 40, nil, "fly")
                makeSliderRow(section, "Fly Speed", 1, 50, 1, function() return OMNI_WORLD.movement.flySpeed end, function(value)
                    OMNI_WORLD.movement.flySpeed = value
                end, nil, 74)
                makeSliderRow(section, "Vertical Speed", 1, 50, 1, function() return OMNI_WORLD.movement.flyVSpeed end, function(value)
                    OMNI_WORLD.movement.flyVSpeed = value
                end, nil, 112)
                makeToggleRow(section, "Speed Hack", function() return OMNI_WORLD.movement.speedEnabled end, function(value)
                    OMNI_WORLD.movement.speedEnabled = value
                end, nil, 150, nil, "speed")
                makeSliderRow(section, "Speed", 16, 22, 1, function() return OMNI_WORLD.movement.speedValue end, function(value)
                    OMNI_WORLD.movement.speedValue = value
                end, nil, 184)
                makeToggleRow(section, "FOV Changer", function() return OMNI_WORLD.movement.fovEnabled end, function(value)
                    OMNI_WORLD.movement.fovEnabled = value
                end, nil, 222, nil, "fov")
                makeSliderRow(section, "Camera FOV", 30, 120, 1, function() return OMNI_WORLD.movement.fovValue end, function(value)
                    OMNI_WORLD.movement.fovValue = value
                end, nil, 256)
            end

            if innerName == "Combat" then
                local pages = makeSubTabs(section, { "Legit", "Rage", "Gun Mods" }, 36)
                local legitPage = pages["Legit"]

                makeToggleRow(legitPage, "Enable Aimbot", function() return LegitAim.enabled end, function(value)
                    LegitAim.enabled = value
                    if not value then
                        LegitAim.target = nil
                        LegitAim.targetPart = nil
                    end
                end, 1, nil, nil, "legitaim")

                local _, aimPartButton = makeActionRow(legitPage, "Aim Part", 2, nil, 110)
                local aimPartOptions = { "Head", "Torso", "Nearest" }
                local function refreshAimPart()
                    aimPartButton.Text = LegitAim.aimPart
                end
                aimPartButton.Activated:Connect(function()
                    local current = 1
                    for index = 1, #aimPartOptions do
                        if aimPartOptions[index] == LegitAim.aimPart then
                            current = index
                            break
                        end
                    end
                    LegitAim.aimPart = aimPartOptions[current % #aimPartOptions + 1]
                    refreshAimPart()
                end)
                refreshAimPart()

                makeSliderRow(legitPage, "Aim FOV", 20, 600, 5,
                    function() return LegitAim.fov end,
                    function(value) LegitAim.fov = value end, 3)
                makeSliderRow(legitPage, "Smoothness", 1, 30, 1,
                    function() return LegitAim.smoothness end,
                    function(value) LegitAim.smoothness = value end, 4)
                makeSliderRow(legitPage, "Prediction", 0, 0.4, 0.01,
                    function() return LegitAim.prediction end,
                    function(value) LegitAim.prediction = value end, 5)
                makeToggleRow(legitPage, "Team Check", function() return LegitAim.teamCheck end,
                    function(value) LegitAim.teamCheck = value end, 6)
                makeToggleRow(legitPage, "Wall Check", function() return LegitAim.wallCheck end,
                    function(value) LegitAim.wallCheck = value end, 7)
                makeToggleRow(legitPage, "Sticky Target", function() return LegitAim.sticky end,
                    function(value) LegitAim.sticky = value end, 8)

                local ragePage = pages["Rage"]
                makeToggleRow(ragePage, "Silent Aim", function()
                    return aimState.silentAim
                end, function(value)
                    aimState.silentAim = value
                    if not value then
                        aimState.target = nil
                        aimState.targetPart = nil
                    end
                end, 1, nil, nil, "silentaim")
                makeSliderRow(ragePage, "Silent FOV", 50, 600, 10, function()
                    return aimState.fov
                end, function(value)
                    aimState.fov = value
                end, 2)
                makeToggleRow(ragePage, "Insta Hit", function()
                    return aimState.instaHit
                end, function(value)
                    aimState.instaHit = value
                end, 3, nil, nil, "instahit")
                makeToggleRow(ragePage, "Triggerbot", function()
                    return aimState.triggerbot
                end, function(value)
                    aimState.triggerbot = value
                end, 4, nil, nil, "triggerbot")
                makeToggleRow(ragePage, "No Fall", function()
                    return aimState.noFall
                end, function(value)
                    aimState.noFall = value
                    local character = Player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        if value then
                            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Landing) end)
                        else
                            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end)
                        end
                    end
                end, 5, nil, nil, "nofall")

                local gunModsPage = pages["Gun Mods"]
                local order = 0
                local function toggle(label, key)
                    order += 1
                    makeToggleRow(gunModsPage, label, function() return gunModState[key] end, function(v)
                        gunModState[key] = v
                        if key == "noDrop" or key == "noDrag" then gunModApplyAmmo() end
                        if key == "fireUnderwater" then gunModSetUnderwater(v) end
                        if key == "instantMosin" then gunModSetMosin(v) end
                    end, order)
                end
                local function slider(label, key, min, max, step)
                    order += 1
                    makeSliderRow(gunModsPage, label, min, max, step, function() return gunModState[key] end,
                        function(v) gunModState[key] = v end, order)
                end
                toggle("No Recoil", "noRecoil")
                toggle("No Bob", "noBob")
                toggle("No Spread", "noSpread")
                toggle("No Bullet Drop", "noDrop")
                toggle("No Drag", "noDrag")
                toggle("Instant ADS", "instantAim")
                toggle("Instant Equip", "instantEquip")
                toggle("Rapid Fire", "rapidFire")
                slider("Fire Rate (s)", "rapidFireDelay", 0.01, 0.5, 0.01)
                toggle("Force Auto", "forceAuto")
                toggle("Multibullet", "multibullet")
                slider("Bullet Count", "multibulletCount", 1, 12, 1)
                toggle("Ignore Water", "ignoreWater")
                toggle("Fire Underwater", "fireUnderwater")
                toggle("Remove Gear Weight", "removeWeight")
                toggle("Remove Aim Restrictions", "removeAimRestrictions")
                toggle("No Bolt", "noBolt")
                toggle("Remove Sandboxing", "removeSandboxing")
                toggle("Remove Rechamber Delay", "removeRechamber")
                toggle("Instant Grenade", "instantGrenade")
                toggle("Sprint While Shooting", "sprintShoot")
                toggle("Instant Lean", "instantLean")
                toggle("No Sway", "noSway")
                toggle("Remove Obstructions", "noObstruct")
                toggle("Remove Muzzle Effects", "removeMuzzle")
                toggle("Remove Sprint Animation", "removeSprintAnimation")
                toggle("Rapid Knife", "rapidKnife")
                slider("Knife Swing Rate", "rapidKnifeRate", 1, 10, 1)
                toggle("Instant Reload", "instantReload")
                toggle("Auto Pack Mags", "autoPackMags")
                toggle("Auto Reload", "autoReload")
                order += 1
                makeSliderRow(gunModsPage, "Reload At", 0, 30, 1,
                    function() return gunModState.autoReloadAt end,
                    function(value) gunModState.autoReloadAt = value end, order)
                toggle("Auto Refill Mags", "autoRefill")
                toggle("Unlock Fire Modes", "unlockfiremodes")
                toggle("One Tap (10 bullets)", "oneTap")
                toggle("Double Tap", "doubleTap")
                toggle("Instant Mosin", "instantMosin")
                toggle("Melee Reach", "meleeReach")
                slider("Melee Reach Distance", "meleeReachDist", 1, 30, 1)
            end


            if innerName == "Features" then
                local featuresCard = Instance.new("Frame")
                featuresCard.Name = "FeaturesCard"
                featuresCard.Parent = section
                featuresCard.Size = UDim2.fromScale(1, 1)
                featuresCard.BackgroundTransparency = 1
                featuresCard.ZIndex = 4

                local playerVisualsButton = Instance.new("TextButton")
                playerVisualsButton.Name = "OpenPlayerVisualsSubTab"
                playerVisualsButton.Parent = featuresCard
                playerVisualsButton.Position = UDim2.new(0, 12, 0, 42)
                playerVisualsButton.Size = UDim2.new(0.5, -18, 0, 24)
                playerVisualsButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                playerVisualsButton.BorderSizePixel = 0
                playerVisualsButton.Text = "Player Visuals ›"
                playerVisualsButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                playerVisualsButton.Font = Enum.Font.Code
                playerVisualsButton.TextSize = 10
                playerVisualsButton.TextTruncate = Enum.TextTruncate.AtEnd
                playerVisualsButton.ZIndex = 10
                playerVisualsButton.Activated:Connect(function()
                    local playerVisualsSection = Content:FindFirstChild("Player VisualsSection")
                    if not playerVisualsSection then return end
                    local featuresSection = Content:FindFirstChild("FeaturesSection")
                    if not featuresSection then return end
                    local skinSection = Content:FindFirstChild("Skin ChangerSection")
                    if skinSection then skinSection.Visible = false end
                    featuresSection.Visible = false
                    playerVisualsSection.Visible = true
                end)

                local skinChangerButton = Instance.new("TextButton")
                skinChangerButton.Name = "OpenSkinChangerSubTab"
                skinChangerButton.Parent = featuresCard
                skinChangerButton.Position = UDim2.new(0.5, 6, 0, 42)
                skinChangerButton.Size = UDim2.new(0.5, -18, 0, 24)
                skinChangerButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                skinChangerButton.BorderSizePixel = 0
                skinChangerButton.Text = "Skin Changer ›"
                skinChangerButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                skinChangerButton.Font = Enum.Font.Code
                skinChangerButton.TextSize = 10
                skinChangerButton.TextTruncate = Enum.TextTruncate.AtEnd
                skinChangerButton.ZIndex = 10
                skinChangerButton.Activated:Connect(function()
                    local skinSection = Content:FindFirstChild("Skin ChangerSection")
                    if not skinSection then return end
                    local featuresSection = Content:FindFirstChild("FeaturesSection")
                    if not featuresSection then return end
                    local playerVisualsSection = Content:FindFirstChild("Player VisualsSection")
                    if playerVisualsSection then playerVisualsSection.Visible = false end
                    featuresSection.Visible = false
                    skinSection.Visible = true
                end)

                local uacRow = Instance.new("Frame")
                uacRow.Name = "UacReportsRow"
                uacRow.Parent = featuresCard
                uacRow.Position = UDim2.new(0, 12, 0, 72)
                uacRow.Size = UDim2.new(1, -24, 0, 24)
                uacRow.BackgroundTransparency = 1
                uacRow.ZIndex = 10
                local uacLabel = Instance.new("TextLabel")
                uacLabel.Parent = uacRow
                uacLabel.Size = UDim2.new(1, -30, 1, 0)
                uacLabel.BackgroundTransparency = 1
                uacLabel.Text = "UAC Reports"
                uacLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                uacLabel.TextXAlignment = Enum.TextXAlignment.Left
                uacLabel.Font = Enum.Font.Code
                uacLabel.TextSize = 11
                uacLabel.ZIndex = 10
                local uacToggle = Instance.new("TextButton")
                uacToggle.Name = "UacReportsToggle"
                uacToggle.Parent = uacRow
                uacToggle.Position = UDim2.new(1, -18, 0, 3)
                uacToggle.Size = UDim2.fromOffset(18, 18)
                uacToggle.BackgroundColor3 = reportState.alerts and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                uacToggle.BorderSizePixel = 0
                uacToggle.Text = ""
                uacToggle.ZIndex = 11
                local uacToggleStroke = Instance.new("UIStroke")
                uacToggleStroke.Parent = uacToggle
                uacToggleStroke.Color = Color3.fromRGB(255, 255, 255)
                uacToggleStroke.Thickness = 1
                uacToggle.Activated:Connect(function()
                    reportState.alerts = not reportState.alerts
                    uacToggle.BackgroundColor3 = reportState.alerts and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                end)
                makeToggleRow(featuresCard, "AC Bypass", function()
                    return ACBypass.enabled
                end, function(value)
                    ACBypass.SetEnabled(value)
                end, nil, 104)
            end

            if innerName == "Player Visuals" then
                local backButton = Instance.new("TextButton")
                backButton.Name = "PlayerVisualsBackTab"
                backButton.Parent = section
                backButton.Position = UDim2.fromOffset(12, 34)
                backButton.Size = UDim2.fromOffset(86, 22)
                backButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                backButton.BorderSizePixel = 0
                backButton.Text = "‹ Features"
                backButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                backButton.Font = Enum.Font.Code
                backButton.TextSize = 11
                backButton.ZIndex = 10
                backButton.Activated:Connect(function()
                    section.Visible = false
                    local featuresSection = Content:FindFirstChild("FeaturesSection")
                    if featuresSection then featuresSection.Visible = true end
                end)

                local auraRow = Instance.new("Frame")
                auraRow.Name = "PlayerAuraRow"
                auraRow.Parent = section
                auraRow.Position = UDim2.fromOffset(12, 66)
                auraRow.Size = UDim2.new(1, -24, 0, 24)
                auraRow.BackgroundTransparency = 1
                auraRow.ZIndex = 4
                local auraLabel = Instance.new("TextLabel")
                auraLabel.Parent = auraRow
                auraLabel.Size = UDim2.new(1, -152, 1, 0)
                auraLabel.BackgroundTransparency = 1
                auraLabel.Text = "Player Aura"
                auraLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                auraLabel.TextXAlignment = Enum.TextXAlignment.Left
                auraLabel.Font = Enum.Font.Code
                auraLabel.TextSize = 12
                auraLabel.ZIndex = 5
                local auraDropdown = Instance.new("TextButton")
                auraDropdown.Name = "PlayerAuraDropdown"
                auraDropdown.Parent = auraRow
                auraDropdown.Position = UDim2.new(1, -142, 0, 2)
                auraDropdown.Size = UDim2.fromOffset(112, 20)
                auraDropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                auraDropdown.BorderSizePixel = 0
                auraDropdown.Text = "Star of David  ▾"
                auraDropdown.TextColor3 = Color3.fromRGB(235, 235, 245)
                auraDropdown.Font = Enum.Font.Code
                auraDropdown.TextSize = 10
                auraDropdown.ZIndex = 10
                local auraBox = Instance.new("TextButton")
                auraBox.Name = "PlayerAuraToggle"
                auraBox.Parent = auraRow
                auraBox.Position = UDim2.new(1, -20, 0, 3)
                auraBox.Size = UDim2.fromOffset(18, 18)
                auraBox.BackgroundColor3 = starAuraEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                auraBox.BorderSizePixel = 0
                auraBox.Text = ""
                auraBox.ZIndex = 10
                local auraStroke = Instance.new("UIStroke")
                auraStroke.Parent = auraBox
                auraStroke.Color = Color3.fromRGB(255, 255, 255)
                auraStroke.Thickness = 1
                auraBox.Activated:Connect(function()
                    setStarAuraEnabled(not starAuraEnabled)
                    auraBox.BackgroundColor3 = starAuraEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                end)
                local auraChoices = Instance.new("Frame")
                auraChoices.Name = "PlayerAuraChoices"
                auraChoices.Parent = section
                auraChoices.Position = UDim2.fromOffset(12, 94)
                auraChoices.Size = UDim2.new(1, -24, 0, 28)
                auraChoices.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                auraChoices.BorderSizePixel = 0
                auraChoices.Visible = false
                auraChoices.ZIndex = 30
                local auraOption = Instance.new("TextButton")
                auraOption.Parent = auraChoices
                auraOption.Size = UDim2.new(1, 0, 1, 0)
                auraOption.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                auraOption.BorderSizePixel = 0
                auraOption.Text = "Star of David"
                auraOption.TextColor3 = Color3.fromRGB(235, 235, 245)
                auraOption.TextXAlignment = Enum.TextXAlignment.Left
                auraOption.Font = Enum.Font.Code
                auraOption.TextSize = 11
                auraOption.ZIndex = 31
                auraOption.Activated:Connect(function()
                    auraDropdown.Text = "Star of David  ▾"
                    auraChoices.Visible = false
                end)
                auraDropdown.Activated:Connect(function()
                    auraChoices.Visible = not auraChoices.Visible
                    auraDropdown.Text = "Star of David" .. (auraChoices.Visible and "  ▴" or "  ▾")
                end)
            end

            if innerName == "Skin Changer" then
                local backButton = Instance.new("TextButton")
                backButton.Name = "SkinChangerBackTab"
                backButton.Parent = section
                backButton.Position = UDim2.fromOffset(12, 34)
                backButton.Size = UDim2.fromOffset(86, 22)
                backButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                backButton.BorderSizePixel = 0
                backButton.Text = "‹ Features"
                backButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                backButton.Font = Enum.Font.Code
                backButton.TextSize = 11
                backButton.ZIndex = 10
                backButton.Activated:Connect(function()
                    section.Visible = false
                    local featuresSection = Content:FindFirstChild("FeaturesSection")
                    if featuresSection then featuresSection.Visible = true end
                end)

                local pages = makeSubTabs(section, { "Melee", "Weapons" }, 62)

                local function makeHeader(parent, text, order)
                    local label = Instance.new("TextLabel")
                    label.Parent = parent
                    label.LayoutOrder = order
                    label.Size = UDim2.new(1, -8, 0, 18)
                    label.BackgroundTransparency = 1
                    label.Text = text
                    label.TextColor3 = Color3.fromRGB(160, 160, 175)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Code
                    label.TextSize = 10
                    label.ZIndex = 5
                    return label
                end

                local function makeStatus(parent, order)
                    local label = Instance.new("TextLabel")
                    label.Parent = parent
                    label.LayoutOrder = order
                    label.Size = UDim2.new(1, -8, 0, 20)
                    label.BackgroundTransparency = 1
                    label.Text = ""
                    label.TextColor3 = Color3.fromRGB(170, 170, 190)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.TextTruncate = Enum.TextTruncate.AtEnd
                    label.Font = Enum.Font.Code
                    label.TextSize = 10
                    label.ZIndex = 5
                    return label
                end

                local function makeGrid(parent, order, height)
                    local frame = Instance.new("ScrollingFrame")
                    frame.Parent = parent
                    frame.LayoutOrder = order
                    frame.Size = UDim2.new(1, -8, 0, height)
                    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                    frame.BorderSizePixel = 0
                    frame.ScrollBarThickness = 3
                    frame.CanvasSize = UDim2.fromOffset(0, 0)
                    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    frame.ZIndex = 5
                    local grid = Instance.new("UIGridLayout")
                    grid.Parent = frame
                    grid.CellSize = UDim2.fromOffset(54, 54)
                    grid.CellPadding = UDim2.fromOffset(4, 4)
                    grid.SortOrder = Enum.SortOrder.LayoutOrder
                    local padding = Instance.new("UIPadding")
                    padding.Parent = frame
                    padding.PaddingLeft = UDim.new(0, 6)
                    padding.PaddingTop = UDim.new(0, 4)
                    padding.PaddingBottom = UDim.new(0, 4)
                    return frame
                end

                local function mountModelPreview(parent, template)
                    if not template or not template:IsA("Model") then return false end
                    local viewport = Instance.new("ViewportFrame")
                    viewport.Parent = parent
                    viewport.Size = UDim2.new(1, 0, 1, -14)
                    viewport.BackgroundTransparency = 1
                    viewport.Ambient = Color3.fromRGB(225, 225, 235)
                    viewport.LightColor = Color3.fromRGB(255, 255, 255)
                    viewport.ZIndex = 6
                    local ok = pcall(function()
                        local clone = template:Clone()
                        for _, descendant in ipairs(clone:GetDescendants()) do
                            if descendant:IsA("Script") or descendant:IsA("LocalScript") then
                                descendant:Destroy()
                            end
                        end
                        clone:PivotTo(CFrame.new(0, 0, 0))
                        clone.Parent = viewport
                        local center, size = clone:GetBoundingBox()
                        local distance = math.max(size.Magnitude, 1) * 1.4
                        local camera = Instance.new("Camera")
                        camera.FieldOfView = 40
                        camera.Parent = viewport
                        camera.CFrame = CFrame.lookAt(
                            center.Position + Vector3.new(distance * 0.35, distance * 0.4, distance),
                            center.Position
                        )
                        viewport.CurrentCamera = camera
                    end)
                    if not ok then
                        viewport:Destroy()
                        return false
                    end
                    return true
                end

                local function makeCell(parent, index, image, caption, placeholderText, modelTemplate)
                    local cell = Instance.new("ImageButton")
                    cell.Name = caption
                    cell.Parent = parent
                    cell.LayoutOrder = index
                    cell.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                    cell.BorderSizePixel = 0
                    cell.Image = image or ""
                    if (image == nil or image == "") and not mountModelPreview(cell, modelTemplate) then
                        local placeholder = Instance.new("TextLabel")
                        placeholder.Parent = cell
                        placeholder.Size = UDim2.new(1, 0, 1, -14)
                        placeholder.BackgroundTransparency = 1
                        placeholder.Text = placeholderText or string.upper(string.sub(caption, 1, 2))
                        placeholder.TextColor3 = Color3.fromRGB(110, 110, 130)
                        placeholder.Font = Enum.Font.Code
                        placeholder.TextSize = 14
                        placeholder.ZIndex = 7
                    end
                    cell.ScaleType = Enum.ScaleType.Fit
                    cell.ZIndex = 6
                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(70, 70, 70)
                    stroke.Thickness = 1
                    stroke.Parent = cell
                    local label = Instance.new("TextLabel")
                    label.Parent = cell
                    label.AnchorPoint = Vector2.new(0, 1)
                    label.Position = UDim2.new(0, 0, 1, 0)
                    label.Size = UDim2.new(1, 0, 0, 14)
                    label.BackgroundTransparency = 1
                    label.Text = caption
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextStrokeTransparency = 0.5
                    label.TextTruncate = Enum.TextTruncate.AtEnd
                    label.Font = Enum.Font.Code
                    label.TextSize = 9
                    label.ZIndex = 7
                    return cell, stroke
                end

                local meleePage = pages["Melee"]
                local meleeStatus = makeStatus(meleePage, 6)

                makeHeader(meleePage, "Melee skin", 2)
                local meleeList = makeGrid(meleePage, 3, 170)

                local meleeButtons = {}

                local function highlightMelee()
                    for name, entry in pairs(meleeButtons) do
                        entry[2].Color = name == skinState.meleeSkin and uiAccentColor or Color3.fromRGB(70, 70, 70)
                    end
                end

                local function buildMeleeList()
                    for index = 1, #MELEE_SKINS do
                        local name = MELEE_SKINS[index]
                        local cell, stroke = makeCell(
                            meleeList, index, itemIcon(name), name,
                            name == "None" and "X" or nil, meleeModel(name)
                        )
                        meleeButtons[name] = { cell, stroke }
                        cell.Activated:Connect(function()
                            skinState.meleeSkin = name
                            if name == "None" then clearMeleeSkinVisual() end
                            applyNativeMeleeSkin(name)
                            meleeStatus.Text = name == "None" and "Melee skin cleared" or ("Melee skin: " .. name)
                            highlightMelee()
                        end)
                    end
                    highlightMelee()
                end
                buildMeleeList()

                local weaponsPage = pages["Weapons"]
                local weaponStatus = makeStatus(weaponsPage, 7)
                local selectedWeapon = skinState.weaponItem
                local selectedSkin = skinState.weaponSkin

                local filterBox = Instance.new("TextBox")
                filterBox.Parent = weaponsPage
                filterBox.LayoutOrder = 1
                filterBox.Size = UDim2.new(1, -8, 0, 24)
                filterBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                filterBox.BorderSizePixel = 0
                filterBox.PlaceholderText = "Search weapons..."
                filterBox.Text = ""
                filterBox.TextColor3 = Color3.fromRGB(235, 235, 245)
                filterBox.PlaceholderColor3 = Color3.fromRGB(135, 135, 150)
                filterBox.Font = Enum.Font.Code
                filterBox.TextSize = 11
                filterBox.ClearTextOnFocus = false
                filterBox.ZIndex = 5

                makeHeader(weaponsPage, "Weapon", 2)
                local weaponList = makeGrid(weaponsPage, 3, 150)
                makeHeader(weaponsPage, "Skin", 4)
                local weaponSkinList = makeGrid(weaponsPage, 5, 220)

                local weaponButtons = {}
                local skinButtons = {}

                local function highlightSkins()
                    for name, entry in pairs(skinButtons) do
                        entry[2].Color = name == selectedSkin and uiAccentColor or Color3.fromRGB(70, 70, 70)
                    end
                end

                local function highlightWeapons()
                    for name, entry in pairs(weaponButtons) do
                        entry[2].Color = name == selectedWeapon and uiAccentColor or Color3.fromRGB(70, 70, 70)
                    end
                end

                local function refreshWeaponSkinList()
                    for _, child in ipairs(weaponSkinList:GetChildren()) do
                        if child:IsA("ImageButton") then child:Destroy() end
                    end
                    table.clear(skinButtons)
                    if not selectedWeapon then return end
                    local names = skinNamesFor(selectedWeapon)
                    if not selectedSkin or not table.find(names, selectedSkin) then
                        selectedSkin = table.find(names, "Default") and "Default" or names[1]
                        skinState.weaponSkin = selectedSkin
                    end
                    for index = 1, #names do
                        local name = names[index]
                        local cell, stroke = makeCell(weaponSkinList, index, skinIcon(selectedWeapon, name), name)
                        skinButtons[name] = { cell, stroke }
                        cell.Activated:Connect(function()
                            selectedSkin = name
                            skinState.weaponSkin = name
                            highlightSkins()
                            local applied = applyWeaponSkin(selectedWeapon, name)
                            weaponStatus.Text = string.format("Applied %s · %d item(s)", name, applied)
                        end)
                    end
                    highlightSkins()
                end

                local function refreshWeaponList()
                    for _, child in ipairs(weaponList:GetChildren()) do
                        if child:IsA("ImageButton") then child:Destroy() end
                    end
                    table.clear(weaponButtons)
                    local filter = string.lower(filterBox.Text)
                    local names = skinItemNames()
                    local visible = 0
                    local firstVisible = nil
                    for index = 1, #names do
                        local name = names[index]
                        if filter == "" or string.find(string.lower(name), filter, 1, true) then
                            visible += 1
                            if not firstVisible then firstVisible = name end
                            local cell, stroke = makeCell(weaponList, visible, itemIcon(name), name)
                            weaponButtons[name] = { cell, stroke }
                            cell.Activated:Connect(function()
                                selectedWeapon = name
                                skinState.weaponItem = name
                                highlightWeapons()
                                refreshWeaponSkinList()
                                weaponStatus.Text = "Selected: " .. name
                            end)
                        end
                    end
                    if not selectedWeapon or not weaponButtons[selectedWeapon] then
                        selectedWeapon = firstVisible
                        skinState.weaponItem = selectedWeapon
                    end
                    highlightWeapons()
                    if visible == 0 then
                        weaponStatus.Text = "No weapons found in ReplicatedStorage.Skins"
                    else
                        refreshWeaponSkinList()
                    end
                end

                filterBox:GetPropertyChangedSignal("Text"):Connect(refreshWeaponList)

                refreshWeaponList()
            end

            if innerName == "Save Manager" then
                local currentConfigName = ""

                local configList = Instance.new("ScrollingFrame")
                configList.Name = "WorkspaceConfigList"
                configList.Parent = section
                configList.Position = UDim2.fromOffset(12, 74)
                configList.Size = UDim2.new(1, -24, 0, 130)
                configList.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
                configList.BorderSizePixel = 0
                configList.ScrollBarThickness = 3
                configList.CanvasSize = UDim2.fromOffset(0, 0)
                configList.ZIndex = 4
                local configLayout = Instance.new("UIListLayout")
                configLayout.Parent = configList
                configLayout.Padding = UDim.new(0, 2)
                configLayout.SortOrder = Enum.SortOrder.Name

                local configNameLabel = Instance.new("TextLabel")
                configNameLabel.Parent = section
                configNameLabel.Position = UDim2.fromOffset(12, 210)
                configNameLabel.Size = UDim2.new(1, -24, 0, 16)
                configNameLabel.BackgroundTransparency = 1
                configNameLabel.Text = "Config Name:"
                configNameLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
                configNameLabel.Font = Enum.Font.Code
                configNameLabel.TextSize = 11
                configNameLabel.ZIndex = 5

                local configNameBox = Instance.new("TextBox")
                configNameBox.Name = "ConfigNameInput"
                configNameBox.Parent = section
                configNameBox.Position = UDim2.fromOffset(12, 228)
                configNameBox.Size = UDim2.new(1, -24, 0, 24)
                configNameBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                configNameBox.BorderSizePixel = 0
                configNameBox.PlaceholderText = "Type config name here..."
                configNameBox.Text = ""
                configNameBox.TextColor3 = Color3.fromRGB(235, 235, 245)
                configNameBox.PlaceholderColor3 = Color3.fromRGB(135, 135, 150)
                configNameBox.Font = Enum.Font.Code
                configNameBox.TextSize = 11
                configNameBox.ClearTextOnFocus = false
                configNameBox.ZIndex = 5

                local currentConfigLabel = Instance.new("TextLabel")
                currentConfigLabel.Name = "CurrentConfigStatus"
                currentConfigLabel.Parent = section
                currentConfigLabel.Position = UDim2.fromOffset(12, 314)
                currentConfigLabel.Size = UDim2.new(1, -24, 0, 28)
                currentConfigLabel.BackgroundTransparency = 1
                currentConfigLabel.Text = "Current Config: None"
                currentConfigLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                currentConfigLabel.TextXAlignment = Enum.TextXAlignment.Left
                currentConfigLabel.TextWrapped = true
                currentConfigLabel.Font = Enum.Font.Code
                currentConfigLabel.TextSize = 10
                currentConfigLabel.ZIndex = 5

                local function setConfigStatus(message)
                    currentConfigLabel.Text = message
                end
                local safeConfigName = SaveManager.SafeName
                local function refreshConfigList()
                    local configChildren = configList:GetChildren()
                    for i = 1, #configChildren do
                        local child = configChildren[i]
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    local names = SaveManager.List()
                    for i = 1, #names do
                        local name = names[i]
                        local entry = Instance.new("TextButton")
                        entry.Name = "Config_" .. name
                        entry.Parent = configList
                        entry.Size = UDim2.new(1, -4, 0, 24)
                        entry.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                        entry.BorderSizePixel = 0
                        entry.Text = name
                        entry.TextColor3 = Color3.fromRGB(235, 235, 245)
                        entry.TextXAlignment = Enum.TextXAlignment.Left
                        entry.Font = Enum.Font.Code
                        entry.TextSize = 11
                        entry.ZIndex = 5
                        entry.Activated:Connect(function()
                            configNameBox.Text = name
                            currentConfigName = name
                            setConfigStatus("Selected: " .. name)
                        end)
                    end
                    configList.CanvasSize = UDim2.fromOffset(0, #names * 26)
                    if #names == 0 then setConfigStatus("No saved configs") end
                end


                local configButtons = Instance.new("Frame")
                configButtons.Name = "ConfigActionButtons"
                configButtons.Parent = section
                configButtons.Position = UDim2.fromOffset(12, 258)
                configButtons.Size = UDim2.new(1, -24, 0, 26)
                configButtons.BackgroundTransparency = 1
                local configActions = { "Save", "Load", "Delete", "Refresh" }
                for actionIndex = 1, #configActions do
                    local actionName = configActions[actionIndex]
                    local actionButton = Instance.new("TextButton")
                    actionButton.Parent = configButtons
                    actionButton.Position = UDim2.new((actionIndex - 1) * 0.25, 0, 0, 0)
                    actionButton.Size = UDim2.new(0.25, -3, 1, 0)
                    actionButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                    actionButton.BorderSizePixel = 0
                    actionButton.Text = actionName
                    actionButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                    actionButton.Font = Enum.Font.Code
                    actionButton.TextSize = 10
                    actionButton.ZIndex = 5
                    actionButton.Activated:Connect(function()
                        local name = safeConfigName(configNameBox.Text)
                        if actionName == "Refresh" then
                            refreshConfigList()
                        elseif actionName == "Save" then
                            local ok, message = SaveManager.Save(name)
                            currentConfigName = SaveManager.Current
                            setConfigStatus(message)
                            if ok then refreshConfigList() end
                        elseif actionName == "Load" then
                            local ok, message = SaveManager.Load(name)
                            if ok then currentConfigName = name end
                            setConfigStatus(message)
                        elseif actionName == "Delete" then
                            local ok, message = SaveManager.Delete(name)
                            currentConfigName = SaveManager.Current
                            setConfigStatus(message)
                            if ok then refreshConfigList() end
                        end
                    end)
                end

                local autoloadButton = Instance.new("TextButton")
                autoloadButton.Parent = section
                autoloadButton.Position = UDim2.fromOffset(12, 288)
                autoloadButton.Size = UDim2.new(0.5, -6, 0, 24)
                autoloadButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                autoloadButton.BorderSizePixel = 0
                autoloadButton.Text = "Set As Auto Load"
                autoloadButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                autoloadButton.Font = Enum.Font.Code
                autoloadButton.TextSize = 9
                autoloadButton.ZIndex = 5
                autoloadButton.Activated:Connect(function()
                    local name = safeConfigName(configNameBox.Text)
                    local ok, message = SaveManager.SetAutoload(name)
                    setConfigStatus(message)
                end)

                local removeAutoloadButton = Instance.new("TextButton")
                removeAutoloadButton.Parent = section
                removeAutoloadButton.Position = UDim2.new(0.5, 0, 0, 288)
                removeAutoloadButton.Size = UDim2.new(0.5, -6, 0, 24)
                removeAutoloadButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                removeAutoloadButton.BorderSizePixel = 0
                removeAutoloadButton.Text = "Remove Auto Load"
                removeAutoloadButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                removeAutoloadButton.Font = Enum.Font.Code
                removeAutoloadButton.TextSize = 9
                removeAutoloadButton.ZIndex = 5
                removeAutoloadButton.Activated:Connect(function()
                    local ok, message = SaveManager.ClearAutoload()
                    setConfigStatus(message)
                end)

                local unloadButton = Instance.new("TextButton")
                unloadButton.Name = "UnloadUIButton"
                unloadButton.Parent = section
                unloadButton.Position = UDim2.fromOffset(12, 358)
                unloadButton.Size = UDim2.new(1, -24, 0, 30)
                unloadButton.BackgroundColor3 = Color3.fromRGB(42, 12, 20)
                unloadButton.BorderSizePixel = 0
                unloadButton.Text = "Unload UI"
                unloadButton.TextColor3 = Color3.fromRGB(255, 220, 225)
                unloadButton.Font = Enum.Font.Code
                unloadButton.TextSize = 13
                unloadButton.ZIndex = 4
                local unloadStroke = Instance.new("UIStroke")
                unloadStroke.Parent = unloadButton
                unloadStroke.Color = Color3.fromRGB(190, 45, 65)
                unloadStroke.Thickness = 1
                unloadButton.Activated:Connect(unloadUI)

                local configsPageButton = Instance.new("TextButton")
                configsPageButton.Name = "ConfigsPageButton"
                configsPageButton.Parent = section
                configsPageButton.Position = UDim2.new(0, 12, 0, 34)
                configsPageButton.Size = UDim2.new(0.5, -15, 0, 23)
                configsPageButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                configsPageButton.BorderSizePixel = 0
                configsPageButton.Text = "Save Manager"
                configsPageButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                configsPageButton.Font = Enum.Font.Code
                configsPageButton.TextSize = 11
                configsPageButton.ZIndex = 10
                local settingsPageButton = Instance.new("TextButton")
                settingsPageButton.Name = "SettingsPageButton"
                settingsPageButton.Parent = section
                settingsPageButton.Position = UDim2.new(0.5, 3, 0, 34)
                settingsPageButton.Size = UDim2.new(0.5, -15, 0, 23)
                settingsPageButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                settingsPageButton.BorderSizePixel = 0
                settingsPageButton.Text = "Settings"
                settingsPageButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                settingsPageButton.Font = Enum.Font.Code
                settingsPageButton.TextSize = 11
                settingsPageButton.ZIndex = 10
                local settingsPage = Instance.new("Frame")
                settingsPage.Name = "ConfigsSettingsPage"
                settingsPage.Parent = section
                settingsPage.Position = UDim2.fromOffset(12, 68)
                settingsPage.Size = UDim2.new(1, -24, 1, -80)
                settingsPage.BackgroundTransparency = 1
                settingsPage.Visible = false

                local hideNameRow = Instance.new("Frame")
                hideNameRow.Name = "HideChatNameRow"
                hideNameRow.Parent = settingsPage
                hideNameRow.Size = UDim2.new(1, 0, 0, 24)
                hideNameRow.BackgroundTransparency = 1
                hideNameRow.ZIndex = 10
                local hideNameLabel = Instance.new("TextLabel")
                hideNameLabel.Parent = hideNameRow
                hideNameLabel.Size = UDim2.new(1, -30, 1, 0)
                hideNameLabel.BackgroundTransparency = 1
                hideNameLabel.Text = "Hide name in chat"
                hideNameLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                hideNameLabel.TextXAlignment = Enum.TextXAlignment.Left
                hideNameLabel.Font = Enum.Font.Code
                hideNameLabel.TextSize = 12
                hideNameLabel.ZIndex = 10
                local hideNameBox = Instance.new("TextButton")
                hideNameBox.Parent = hideNameRow
                hideNameBox.Position = UDim2.new(1, -18, 0, 3)
                hideNameBox.Size = UDim2.fromOffset(18, 18)
                hideNameBox.BorderSizePixel = 0
                hideNameBox.Text = ""
                hideNameBox.ZIndex = 11
                local hideNameStroke = Instance.new("UIStroke")
                hideNameStroke.Parent = hideNameBox
                hideNameStroke.Color = Color3.fromRGB(255, 255, 255)
                hideNameStroke.Thickness = 1
                local function paintHideName()
                    hideNameBox.BackgroundColor3 = hideChatName and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                end
                hideNameBox.Activated:Connect(function()
                    hideChatName = not hideChatName
                    paintHideName()
                end)
                paintHideName()

                local configControls = { configList, configNameLabel, configNameBox, currentConfigLabel, configButtons, autoloadButton, removeAutoloadButton, unloadButton }
                local function showConfigPage(showSettings)
                    settingsPage.Visible = showSettings
                    for controlIndex = 1, #configControls do
                        configControls[controlIndex].Visible = not showSettings
                    end
                end
                configsPageButton.Activated:Connect(function() showConfigPage(false) end)
                settingsPageButton.Activated:Connect(function() showConfigPage(true) end)

                local folderReady, folderReason = SaveManager.EnsureFolder()
                refreshConfigList()
                if not folderReady then setConfigStatus(folderReason or "Workspace file APIs unavailable") end
                task.defer(function()
                    local autoName = SaveManager.GetAutoload()
                    if autoName then
                        configNameBox.Text = autoName
                        local ok, message = SaveManager.Load(autoName)
                        setConfigStatus(message)
                    end
                end)
            end

            if innerName == "Theme" then
                local themePage = Instance.new("Frame")
                themePage.Name = "ThemePage"
                themePage.Parent = section
                themePage.Position = UDim2.fromOffset(0, 58)
                themePage.Size = UDim2.new(1, 0, 1, -58)
                themePage.BackgroundTransparency = 1
                local themeHeading = Instance.new("TextLabel")
                themeHeading.Name = "ThemeHeading"
                themeHeading.Parent = themePage
                themeHeading.Position = UDim2.fromOffset(12, 6)
                themeHeading.Size = UDim2.new(1, -24, 0, 24)
                themeHeading.BackgroundTransparency = 1
                themeHeading.Text = "Theme"
                themeHeading.TextColor3 = Color3.fromRGB(220, 225, 240)
                themeHeading.TextXAlignment = Enum.TextXAlignment.Left
                themeHeading.Font = Enum.Font.Code
                themeHeading.TextSize = 13
                themeHeading.ZIndex = 10

                local soundPage = Instance.new("Frame")
                soundPage.Name = "SoundPage"
                soundPage.Parent = section
                soundPage.Position = UDim2.fromOffset(0, 58)
                soundPage.Size = UDim2.new(1, 0, 1, -58)
                soundPage.BackgroundTransparency = 1
                soundPage.Visible = false
                local soundsHeading = Instance.new("TextLabel")
                soundsHeading.Name = "SoundsHeading"
                soundsHeading.Parent = soundPage
                soundsHeading.Position = UDim2.fromOffset(12, 6)
                soundsHeading.Size = UDim2.new(1, -24, 0, 24)
                soundsHeading.BackgroundTransparency = 1
                soundsHeading.Text = "Sounds"
                soundsHeading.TextColor3 = Color3.fromRGB(220, 225, 240)
                soundsHeading.TextXAlignment = Enum.TextXAlignment.Left
                soundsHeading.Font = Enum.Font.Code
                soundsHeading.TextSize = 13
                soundsHeading.ZIndex = 10

                local themePageButton = Instance.new("TextButton")
                themePageButton.Name = "ThemePageButton"
                themePageButton.Parent = section
                themePageButton.Position = UDim2.new(0, 12, 0, 33)
                themePageButton.Size = UDim2.new(0.5, -15, 0, 23)
                themePageButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                themePageButton.BorderSizePixel = 0
                themePageButton.Text = "Theme"
                themePageButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                themePageButton.Font = Enum.Font.Code
                themePageButton.TextSize = 11
                themePageButton.ZIndex = 10

                local soundsPageButton = Instance.new("TextButton")
                soundsPageButton.Name = "SoundsPageButton"
                soundsPageButton.Parent = section
                soundsPageButton.Position = UDim2.new(0.5, 3, 0, 33)
                soundsPageButton.Size = UDim2.new(0.5, -15, 0, 23)
                soundsPageButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                soundsPageButton.BorderSizePixel = 0
                soundsPageButton.Text = "Sounds"
                soundsPageButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                soundsPageButton.Font = Enum.Font.Code
                soundsPageButton.TextSize = 11
                soundsPageButton.ZIndex = 10

                local function showSettingsPage(showSounds)
                    themePage.Visible = not showSounds
                    soundPage.Visible = showSounds
                    title.Text = "Theme"
                end
                themePageButton.Activated:Connect(function() showSettingsPage(false) end)
                soundsPageButton.Activated:Connect(function() showSettingsPage(true) end)

                local choices = { "Snow", "Rain", "Lightning", "Fire", "Star of David" }
                local row = Instance.new("Frame")
                row.Parent = themePage
                row.Position = UDim2.fromOffset(12, 42)
                row.Size = UDim2.new(1, -24, 0, 24)
                row.BackgroundTransparency = 1
                row.ZIndex = 4
                local box = Instance.new("TextButton")
                box.Name = "EffectsCheckbox"
                box.Parent = row
                box.Size = UDim2.fromOffset(18, 18)
                box.Position = UDim2.new(1, -40, 0, 3)
                box.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                box.BackgroundTransparency = 0
                box.BorderSizePixel = 0
                box.Text = ""
                box.ZIndex = 10
                local outline = Instance.new("UIStroke")
                outline.Parent = box
                outline.Color = Color3.fromRGB(255, 255, 255)
                outline.Thickness = 1
                local label = Instance.new("TextLabel")
                label.Parent = row
                label.Position = UDim2.fromOffset(0, 0)
                label.Size = UDim2.new(1, -128, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "UI Animations"
                label.TextColor3 = Color3.fromRGB(190, 190, 190)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Font = Enum.Font.Code
                label.TextSize = 12
                label.ZIndex = 10
                local animationNameLabel = Instance.new("TextLabel")
                animationNameLabel.Name = "SelectedAnimationName"
                animationNameLabel.Parent = row
                animationNameLabel.Position = UDim2.new(1, -104, 0, 0)
                animationNameLabel.Size = UDim2.fromOffset(58, 24)
                animationNameLabel.BackgroundTransparency = 1
                animationNameLabel.Text = effectsEnabled and selectedTheme or "Off"
                animationNameLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                animationNameLabel.TextXAlignment = Enum.TextXAlignment.Right
                animationNameLabel.Font = Enum.Font.Code
                animationNameLabel.TextSize = 10
                animationNameLabel.ZIndex = 10
                local arrow, list
                local function refreshMark() box.BackgroundColor3 = effectsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36); box.BackgroundTransparency = 0; arrow.Visible = effectsEnabled; animationNameLabel.Text = effectsEnabled and selectedTheme or "Off"; if not effectsEnabled then list.Visible = false end end
                box.Activated:Connect(function() effectsEnabled = not effectsEnabled; refreshMark(); applyTheme() end)
                arrow = Instance.new("TextButton")
                arrow.Name = "ThemeDropdownArrow"
                arrow.Parent = row
                arrow.Position = UDim2.new(1, -20, 0, 2)
                arrow.Size = UDim2.fromOffset(18, 20)
                arrow.BackgroundTransparency = 1
                arrow.BorderSizePixel = 0
                arrow.Text = ""
                arrow.Visible = effectsEnabled
                arrow.ZIndex = 10
                local arrowLeft = Instance.new("Frame")
                arrowLeft.Parent = arrow
                arrowLeft.AnchorPoint = Vector2.new(0.5, 0.5)
                arrowLeft.Position = UDim2.fromScale(0.34, 0.68)
                arrowLeft.Size = UDim2.fromOffset(7, 1.5)
                arrowLeft.Rotation = 45
                arrowLeft.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                arrowLeft.BorderSizePixel = 0
                arrowLeft.ZIndex = 10
                local arrowRight = Instance.new("Frame")
                arrowRight.Parent = arrow
                arrowRight.AnchorPoint = Vector2.new(0.5, 0.5)
                arrowRight.Position = UDim2.fromScale(0.66, 0.68)
                arrowRight.Size = UDim2.fromOffset(7, 1.5)
                arrowRight.Rotation = -45
                arrowRight.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                arrowRight.BorderSizePixel = 0
                arrowRight.ZIndex = 10
                local arrowStem = Instance.new("Frame")
                arrowStem.Parent = arrow
                arrowStem.AnchorPoint = Vector2.new(0.5, 0.5)
                arrowStem.Position = UDim2.fromScale(0.5, 0.38)
                arrowStem.Size = UDim2.fromOffset(1.5, 7)
                arrowStem.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                arrowStem.BorderSizePixel = 0
                arrowStem.ZIndex = 10
                list = Instance.new("Frame")
                list.Name = "ThemeChoices"
                list.Parent = themePage
                list.Position = UDim2.fromOffset(12, 100)
                list.Size = UDim2.new(1, -24, 0, #choices * 40)
                list.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                list.BorderSizePixel = 0
                list.Visible = false
                list.ZIndex = 30
                refreshMark()
                arrow.Activated:Connect(function() list.Visible = not list.Visible; arrowLeft.Rotation = list.Visible and -45 or 45; arrowRight.Rotation = list.Visible and 45 or -45 end)
                for choiceIndex = 1, #choices do
                    local choice = choices[choiceIndex]
                    local option = Instance.new("TextButton")
                    option.Parent = list
                    option.Position = UDim2.fromOffset(0, (choiceIndex - 1) * 40)
                    option.Size = UDim2.new(1, 0, 0, 40)
                    option.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                    option.BorderSizePixel = 0
                    option.Text = ""
                    option.ZIndex = 31
                    local name = Instance.new("TextLabel")
                    name.Parent = option
                    name.Position = UDim2.fromOffset(6, 1)
                    name.Size = UDim2.new(1, -10, 0, 17)
                    name.BackgroundTransparency = 1
                    name.Text = choice
                    name.TextColor3 = Color3.fromRGB(235, 235, 255)
                    name.TextXAlignment = Enum.TextXAlignment.Left
                    name.Font = Enum.Font.Code
                    name.TextSize = 11
                    name.ZIndex = 32
                    option.Activated:Connect(function() selectedTheme = choice; animationNameLabel.Text = choice; list.Visible = false; arrowLeft.Rotation = 45; arrowRight.Rotation = -45; applyTheme() end)
                end

                local picker = Instance.new("Frame")
                picker.Name = "UIColorPicker"
                picker.Parent = themePage
                picker.Position = UDim2.fromOffset(12, 146)
                picker.Size = UDim2.new(1, -24, 0, 178)
                picker.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
                picker.BorderSizePixel = 0
                picker.Visible = false
                picker.ZIndex = 40
                local pickerStroke = Instance.new("UIStroke")
                pickerStroke.Parent = picker
                bindAccent(pickerStroke)
                pickerStroke.Thickness = 1

                local hue, saturation, value = uiAccentColor:ToHSV()
                local svField = Instance.new("Frame")
                svField.Name = "SaturationValue"
                svField.Parent = picker
                svField.Position = UDim2.fromOffset(8, 8)
                svField.Size = UDim2.new(1, -46, 1, -16)
                svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                svField.BorderSizePixel = 0
                svField.ZIndex = 41
                local whiteLayer = Instance.new("Frame")
                whiteLayer.Parent = svField
                whiteLayer.Size = UDim2.fromScale(1, 1)
                whiteLayer.BackgroundColor3 = Color3.new(1, 1, 1)
                whiteLayer.BorderSizePixel = 0
                whiteLayer.ZIndex = 42
                local whiteGradient = Instance.new("UIGradient")
                whiteGradient.Parent = whiteLayer
                whiteGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
                local blackLayer = Instance.new("Frame")
                blackLayer.Parent = svField
                blackLayer.Size = UDim2.fromScale(1, 1)
                blackLayer.BackgroundColor3 = Color3.new(0, 0, 0)
                blackLayer.BorderSizePixel = 0
                blackLayer.ZIndex = 43
                local blackGradient = Instance.new("UIGradient")
                blackGradient.Parent = blackLayer
                blackGradient.Rotation = 90
                blackGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
                local svInput = Instance.new("TextButton")
                svInput.Parent = svField
                svInput.Size = UDim2.fromScale(1, 1)
                svInput.BackgroundTransparency = 1
                svInput.BorderSizePixel = 0
                svInput.Text = ""
                svInput.ZIndex = 44
                local svCursor = Instance.new("Frame")
                svCursor.Parent = svField
                svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                svCursor.Size = UDim2.fromOffset(10, 10)
                svCursor.BackgroundTransparency = 1
                svCursor.BorderSizePixel = 0
                svCursor.ZIndex = 45
                local cursorRound = Instance.new("UICorner")
                cursorRound.CornerRadius = UDim.new(1, 0)
                cursorRound.Parent = svCursor
                local cursorStroke = Instance.new("UIStroke")
                cursorStroke.Parent = svCursor
                cursorStroke.Color = Color3.fromRGB(255, 255, 255)
                cursorStroke.Thickness = 1

                local hueBar = Instance.new("Frame")
                hueBar.Name = "HueBar"
                hueBar.Parent = picker
                hueBar.Position = UDim2.new(1, -30, 0, 8)
                hueBar.Size = UDim2.new(0, 22, 1, -16)
                hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
                hueBar.BorderSizePixel = 0
                hueBar.ZIndex = 41
                local hueGradient = Instance.new("UIGradient")
                hueGradient.Parent = hueBar
                hueGradient.Rotation = 90
                hueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                })
                local hueInput = Instance.new("TextButton")
                hueInput.Parent = hueBar
                hueInput.Size = UDim2.fromScale(1, 1)
                hueInput.BackgroundTransparency = 1
                hueInput.BorderSizePixel = 0
                hueInput.Text = ""
                hueInput.ZIndex = 44
                local hueMark = Instance.new("Frame")
                hueMark.Parent = hueBar
                hueMark.Size = UDim2.new(1, 0, 0, 3)
                hueMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueMark.BorderSizePixel = 0
                hueMark.ZIndex = 45
                local hueMarkStroke = Instance.new("UIStroke")
                hueMarkStroke.Parent = hueMark
                hueMarkStroke.Color = Color3.fromRGB(15, 15, 20)
                hueMarkStroke.Thickness = 1

                local activeColorKey = "Outline"
                local activeColorButton = nil
                local applyPaletteColor
                local function updateColor()
                    local color = Color3.fromHSV(hue, saturation, value)
                    if activeColorButton then activeColorButton.BackgroundColor3 = color end
                    if applyPaletteColor then
                        applyPaletteColor(activeColorKey, color)
                    else
                        setUIAccent(color)
                    end
                    svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    svCursor.Position = UDim2.fromScale(saturation, 1 - value)
                    hueMark.Position = UDim2.new(0, 0, hue, -1)
                end
                local dragMode
                local function updateFromPointer(position)
                    if not picker.Visible then return end
                    if dragMode == "SV" then
                        local origin, size = svField.AbsolutePosition, svField.AbsoluteSize
                        saturation = math.clamp((position.X - origin.X) / size.X, 0, 1)
                        value = 1 - math.clamp((position.Y - origin.Y) / size.Y, 0, 1)
                    elseif dragMode == "Hue" then
                        local origin, size = hueBar.AbsolutePosition, hueBar.AbsoluteSize
                        hue = math.clamp((position.Y - origin.Y) / size.Y, 0, 1)
                    end
                    updateColor()
                end
                svInput.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragMode = "SV"
                        updateFromPointer(input.Position)
                    end
                end)
                hueInput.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragMode = "Hue"
                        updateFromPointer(input.Position)
                    end
                end)
                table.insert(tabConnections, UIS.InputChanged:Connect(function(input)
                    if dragMode and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromPointer(input.Position)
                    end
                end))
                table.insert(tabConnections, UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragMode = nil end
                end))
                updateColor()

             
                local themePaletteValues = {
                    ["Outline"] = uiAccentColor,
                    ["Text Misc"] = Color3.fromRGB(190, 190, 205),
                    ["Menu Background"] = Main.BackgroundColor3,
                    ["Tab Button Unselected"] = Color3.fromRGB(15, 15, 25),
                    ["Inline"] = uiAccentColor,
                    ["High Contrast"] = Color3.fromRGB(235, 235, 245),
                    ["Low Contrast"] = Color3.fromRGB(75, 75, 90),
                    ["Page Background"] = Color3.fromRGB(8, 8, 16),
                    ["Section Background"] = Color3.fromRGB(10, 10, 20),
                    ["Accent"] = uiAccentColor,
                }
                local themePaletteDefaults = table.clone(themePaletteValues)
                for colorName, colorValue in next, currentThemePalette do
                    if typeof(colorValue) == "Color3" and themePaletteValues[colorName] ~= nil then themePaletteValues[colorName] = colorValue end
                end
                currentThemePalette = themePaletteValues
                local paletteSwatches = {}
                applyPaletteColor = function(name, color)
                    themePaletteValues[name] = color
                    if paletteSwatches[name] then paletteSwatches[name].BackgroundColor3 = color end
                    if name == "Outline" or name == "Accent" or name == "Inline" then
                        setUIAccent(color)
                    elseif name == "Menu Background" then
                        Main.BackgroundColor3 = color
                    elseif name == "Page Background" then
                        Content.BackgroundColor3 = color
                        Content.BackgroundTransparency = 0
                    elseif name == "Section Background" then
                        local contentChildren = Content:GetChildren()
                        for i = 1, #contentChildren do
                            local item = contentChildren[i]
                            if item:IsA("Frame") and item.Name:find("Section") then item.BackgroundColor3 = color end
                        end
                    elseif name == "Tab Button Unselected" then
                        local tabChildren = TabHolder:GetChildren()
                        for i = 1, #tabChildren do
                            local item = tabChildren[i]
                            if item:IsA("TextButton") then item.BackgroundColor3 = color end
                        end
                    elseif name == "Text Misc" then
                        local themeControls = themePage:GetDescendants()
                        for i = 1, #themeControls do
                            local item = themeControls[i]
                            if item:IsA("TextLabel") or item:IsA("TextButton") then item.TextColor3 = color end
                        end
                    elseif name == "High Contrast" or name == "Low Contrast" then
                        local transparency = name == "High Contrast" and 0.35 or 0.8
                        local screenControls = ScreenGui:GetDescendants()
                        for i = 1, #screenControls do
                            local item = screenControls[i]
                            if item:IsA("TextLabel") or item:IsA("TextButton") then
                                item.TextStrokeColor3 = color
                                item.TextStrokeTransparency = transparency
                            end
                        end
                    end
                end
                applyLoadedPalette = function(values)
                    for colorName, colorValue in next, values do
                        if themePaletteValues[colorName] and typeof(colorValue) == "Color3" then
                            applyPaletteColor(colorName, colorValue)
                        end
                    end
                end

                local paletteScroll = Instance.new("ScrollingFrame")
                paletteScroll.Name = "ThemePaletteSettings"
                paletteScroll.Parent = themePage
                paletteScroll.Position = UDim2.fromOffset(12, 78)
                paletteScroll.Size = UDim2.new(1, -24, 1, -78)
                paletteScroll.BackgroundTransparency = 1
                paletteScroll.BorderSizePixel = 0
                paletteScroll.ScrollBarThickness = 3
                paletteScroll.CanvasSize = UDim2.fromOffset(0, 500)
                paletteScroll.ZIndex = 4

                local hudRowY = 0
                local function makeHudRow(rowName, labelText, controlText, checked, callback)
                    local hudRow = Instance.new("Frame")
                    hudRow.Parent = paletteScroll
                    hudRow.Position = UDim2.fromOffset(0, hudRowY)
                    hudRow.Size = UDim2.new(1, -4, 0, 22)
                    hudRow.BackgroundTransparency = 1
                    hudRow.ZIndex = 4
                    local hudLabel = Instance.new("TextLabel")
                    hudLabel.Parent = hudRow
                    hudLabel.Size = UDim2.new(1, -92, 1, 0)
                    hudLabel.BackgroundTransparency = 1
                    hudLabel.Text = labelText
                    hudLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                    hudLabel.TextXAlignment = Enum.TextXAlignment.Left
                    hudLabel.Font = Enum.Font.Code
                    hudLabel.TextSize = 11
                    hudLabel.ZIndex = 5
                    local control = Instance.new("TextButton")
                    control.Parent = hudRow
                    control.Position = UDim2.new(1, -90, 0, 1)
                    control.Size = UDim2.fromOffset(88, 20)
                    control.BackgroundColor3 = checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(18, 18, 30)
                    control.BorderSizePixel = 0
                    control.Text = controlText
                    control.TextColor3 = checked and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(235, 235, 245)
                    control.Font = Enum.Font.Code
                    control.TextSize = 10
                    control.ZIndex = 5
                    control.Activated:Connect(function() callback(control) end)
                    hudRowY += 24
                    return control
                end

                local function makeHudCheckboxRow(rowName, labelText, getValue, onToggle)
                    local hudRow = Instance.new("Frame")
                    hudRow.Name = rowName .. "Row"
                    hudRow.Parent = paletteScroll
                    hudRow.Position = UDim2.fromOffset(0, hudRowY)
                    hudRow.Size = UDim2.new(1, -4, 0, 22)
                    hudRow.BackgroundTransparency = 1
                    hudRow.ZIndex = 4
                    local hudLabel = Instance.new("TextLabel")
                    hudLabel.Parent = hudRow
                    hudLabel.Size = UDim2.new(1, -30, 1, 0)
                    hudLabel.BackgroundTransparency = 1
                    hudLabel.Text = labelText
                    hudLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                    hudLabel.TextXAlignment = Enum.TextXAlignment.Left
                    hudLabel.Font = Enum.Font.Code
                    hudLabel.TextSize = 11
                    hudLabel.ZIndex = 5
                    local check = Instance.new("TextButton")
                    check.Name = rowName .. "Checkbox"
                    check.Parent = hudRow
                    check.AnchorPoint = Vector2.new(1, 0.5)
                    check.Position = UDim2.new(1, 0, 0.5, 0)
                    check.Size = UDim2.fromOffset(18, 18)
                    check.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                    check.BorderSizePixel = 0
                    check.Text = ""
                    check.ZIndex = 6
                    local checkCorner = Instance.new("UICorner")
                    checkCorner.CornerRadius = UDim.new(0, 2)
                    checkCorner.Parent = check
                    local checkStroke = Instance.new("UIStroke")
                    checkStroke.Parent = check
                    checkStroke.Color = Color3.fromRGB(78, 78, 92)
                    checkStroke.Thickness = 1
                    local function refresh()
                        local on = getValue() and true or false
                        check.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                        checkStroke.Color = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(78, 78, 92)
                    end
                    check.Activated:Connect(function()
                        onToggle()
                        refresh()
                    end)
                    refresh()
                    hudRowY += 24
                    return check, refresh
                end

                makeHudCheckboxRow("Watermark", "Watermark", function() return watermarkEnabled end, function()
                    watermarkEnabled = not watermarkEnabled
                    watermarkRoot.Visible = watermarkEnabled
                end)
                makeHudCheckboxRow("WatermarkTitle", "Show Title", function() return watermarkOptions.Title end, function()
                    watermarkOptions.Title = not watermarkOptions.Title
                end)
                makeHudCheckboxRow("WatermarkFPS", "Show FPS", function() return watermarkOptions.FPS end, function()
                    watermarkOptions.FPS = not watermarkOptions.FPS
                end)
                makeHudCheckboxRow("WatermarkPing", "Show Ping", function() return watermarkOptions.Ping end, function()
                    watermarkOptions.Ping = not watermarkOptions.Ping
                end)

                local refreshRates = { 0.1, 0.2, 0.5, 1 }
                local refreshIndex = 1
                makeHudRow("RefreshRate", "Refresh Rate", "0.1s", false, function(control)
                    refreshIndex = refreshIndex % #refreshRates + 1
                    watermarkRefreshRate = refreshRates[refreshIndex]
                    control.Text = tostring(watermarkRefreshRate) .. "s"
                end)
                makeHudCheckboxRow("KeybindList", "Keybind List", function() return hudKeybindEnabled end, function()
                    hudKeybindEnabled = not hudKeybindEnabled
                    hudKeybindLabel.Visible = hudKeybindEnabled
                end)


                local themeHeader = Instance.new("TextLabel")
                themeHeader.Parent = paletteScroll
                themeHeader.Position = UDim2.fromOffset(0, hudRowY + 8)
                themeHeader.Size = UDim2.new(1, -4, 0, 18)
                themeHeader.BackgroundTransparency = 1
                themeHeader.Text = "THEMING"
                themeHeader.TextColor3 = Color3.fromRGB(235, 235, 245)
                themeHeader.TextXAlignment = Enum.TextXAlignment.Left
                themeHeader.Font = Enum.Font.Code
                themeHeader.TextSize = 10
                themeHeader.ZIndex = 5

                local paletteNames = { "Outline", "Text Misc", "Menu Background", "Tab Button Unselected", "Inline", "High Contrast", "Low Contrast", "Page Background", "Section Background", "Accent" }
                for paletteIndex = 1, #paletteNames do
                    local paletteName = paletteNames[paletteIndex]
                    local paletteRow = Instance.new("Frame")
                    paletteRow.Name = "Palette_" .. string.gsub(paletteName, " ", "")
                    paletteRow.Parent = paletteScroll
                    paletteRow.Position = UDim2.fromOffset(0, hudRowY + 28 + (paletteIndex - 1) * 24)
                    paletteRow.Size = UDim2.new(1, -4, 0, 22)
                    paletteRow.BackgroundTransparency = 1
                    paletteRow.ZIndex = 4

                    local paletteLabel = Instance.new("TextLabel")
                    paletteLabel.Parent = paletteRow
                    paletteLabel.Size = UDim2.new(1, -38, 1, 0)
                    paletteLabel.BackgroundTransparency = 1
                    paletteLabel.Text = paletteName
                    paletteLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                    paletteLabel.TextXAlignment = Enum.TextXAlignment.Left
                    paletteLabel.Font = Enum.Font.Code
                    paletteLabel.TextSize = 11
                    paletteLabel.ZIndex = 5

                    local paletteSwatch = Instance.new("TextButton")
                    paletteSwatch.Name = "ColorSwatch"
                    paletteSwatch.Parent = paletteRow
                    paletteSwatch.Position = UDim2.new(1, -24, 0, 2)
                    paletteSwatch.Size = UDim2.fromOffset(18, 18)
                    paletteSwatch.BackgroundColor3 = themePaletteValues[paletteName]
                    paletteSwatch.BorderSizePixel = 0
                    paletteSwatch.Text = ""
                    paletteSwatch.ZIndex = 5
                    paletteSwatches[paletteName] = paletteSwatch
                    paletteSwatch.Activated:Connect(function()
                        if picker.Visible and activeColorKey == paletteName then
                            picker.Visible = false
                            return
                        end
                        activeColorKey = paletteName
                        activeColorButton = paletteSwatch
                        hue, saturation, value = themePaletteValues[paletteName]:ToHSV()
                        local pickerY = paletteRow.AbsolutePosition.Y - themePage.AbsolutePosition.Y + paletteRow.AbsoluteSize.Y + 4
                        pickerY = math.clamp(pickerY, 4, math.max(4, themePage.AbsoluteSize.Y - 182))
                        picker.Position = UDim2.fromOffset(12, pickerY)
                        picker.Visible = true
                        updateColor()
                    end)
                end

                local presetButton = Instance.new("TextButton")
                presetButton.Name = "ThemePresetDropdown"
                presetButton.Parent = paletteScroll
                presetButton.Position = UDim2.fromOffset(0, hudRowY + 278)
                presetButton.Size = UDim2.new(1, -4, 0, 24)
                presetButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                presetButton.BorderSizePixel = 0
                presetButton.Text = "Themes  ▾"
                presetButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                presetButton.Font = Enum.Font.Code
                presetButton.TextSize = 11
                presetButton.ZIndex = 5

                local presetList = Instance.new("ScrollingFrame")
                presetList.Name = "ThemePresets"
                presetList.Parent = themePage
                presetList.Position = UDim2.fromOffset(12, 78 + hudRowY + 278)
                presetList.Size = UDim2.new(1, -24, 0, 4 * 24)
                presetList.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                presetList.BorderSizePixel = 0
                presetList.ScrollBarThickness = 3
                presetList.CanvasSize = UDim2.fromOffset(0, 0)
                presetList.Visible = false
                presetList.ZIndex = 30
                local builtInPresetNames = { "Omni", "Midnight", "Rain", "Ember" }
                local presetPalettes = {
                    Omni = themePaletteDefaults,
                    Midnight = { Outline = Color3.fromRGB(100, 130, 200), Accent = Color3.fromRGB(100, 130, 200), ["Menu Background"] = Color3.fromRGB(7, 10, 20), ["Page Background"] = Color3.fromRGB(9, 13, 24), ["Section Background"] = Color3.fromRGB(12, 16, 29) },
                    Rain = { Outline = Color3.fromRGB(75, 160, 220), Accent = Color3.fromRGB(75, 160, 220), ["Menu Background"] = Color3.fromRGB(5, 12, 20), ["Page Background"] = Color3.fromRGB(8, 16, 25), ["Section Background"] = Color3.fromRGB(12, 24, 34) },
                    Ember = { Outline = Color3.fromRGB(225, 85, 35), Accent = Color3.fromRGB(225, 85, 35), ["Menu Background"] = Color3.fromRGB(18, 7, 6), ["Page Background"] = Color3.fromRGB(20, 9, 8), ["Section Background"] = Color3.fromRGB(29, 13, 10) },
                }
                local THEME_FOLDER = "Omni/Themes"
                local themeNameBox = Instance.new("TextBox")
                themeNameBox.Name = "CustomThemeName"
                themeNameBox.Parent = paletteScroll
                themeNameBox.Position = UDim2.fromOffset(0, hudRowY + 308)
                themeNameBox.Size = UDim2.new(1, -4, 0, 24)
                themeNameBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                themeNameBox.BorderSizePixel = 0
                themeNameBox.PlaceholderText = "Theme name..."
                themeNameBox.Text = ""
                themeNameBox.TextColor3 = Color3.fromRGB(235, 235, 245)
                themeNameBox.PlaceholderColor3 = Color3.fromRGB(135, 135, 150)
                themeNameBox.Font = Enum.Font.Code
                themeNameBox.TextSize = 11
                themeNameBox.ClearTextOnFocus = false
                themeNameBox.ZIndex = 5

                local customThemeStatus = Instance.new("TextLabel")
                customThemeStatus.Name = "CustomThemeStatus"
                customThemeStatus.Parent = paletteScroll
                customThemeStatus.Position = UDim2.fromOffset(0, hudRowY + 336)
                customThemeStatus.Size = UDim2.new(1, -4, 0, 16)
                customThemeStatus.BackgroundTransparency = 1
                customThemeStatus.Text = "Themes save in workspace/Omni/Themes"
                customThemeStatus.TextColor3 = Color3.fromRGB(160, 160, 175)
                customThemeStatus.TextXAlignment = Enum.TextXAlignment.Left
                customThemeStatus.Font = Enum.Font.Code
                customThemeStatus.TextSize = 9
                customThemeStatus.ZIndex = 5
                paletteScroll.CanvasSize = UDim2.fromOffset(0, hudRowY + 360)

                local function cleanThemeName(value)
                    return tostring(value or ""):gsub("%.json$", ""):gsub("[^%w%-%_ ]", ""):gsub("^%s+", ""):gsub("%s+$", ""):sub(1, 48)
                end
                local function themeFilePath(name)
                    return THEME_FOLDER .. "/" .. name .. ".json"
                end
                local function ensureThemeFolder()
                    if type(makefolder) ~= "function" then return false end
                    if type(isfolder) == "function" then
                        local ok, exists = pcall(isfolder, THEME_FOLDER)
                        if ok and exists then return true end
                    end
                    if type(isfolder) == "function" then
                        local ok, exists = pcall(isfolder, "Omni")
                        if (not ok or not exists) and not pcall(makefolder, "Omni") then return false end
                    end
                    local made = pcall(makefolder, THEME_FOLDER)
                    if made then return true end
                    if type(isfolder) == "function" then
                        local ok, exists = pcall(isfolder, THEME_FOLDER)
                        return ok and exists
                    end
                    return false
                end
                local function encodeThemePalette()
                    local palette = {}
                    local paletteKeys = {}
                    for name, color in next, themePaletteValues do
                        if typeof(color) == "Color3" then table.insert(paletteKeys, name) end
                    end
                    table.sort(paletteKeys)
                    for keyIndex = 1, #paletteKeys do
                        local name = paletteKeys[keyIndex]
                        local color = themePaletteValues[name]
                        palette[name] = { color.R, color.G, color.B }
                    end
                    return {
                        version = 1,
                        palette = palette,
                        animation = {
                            theme = selectedTheme,
                            enabled = effectsEnabled or selectedTheme ~= "Snow",
                        },
                        animationTheme = selectedTheme,
                        animationsEnabled = effectsEnabled or selectedTheme ~= "Snow",
                    }
                end
                local function decodeThemePalette(data)
                    if type(data) ~= "table" or type(data.palette) ~= "table" then return nil end
                    local colors = {}
                    for name, rgb in next, data.palette do
                        if type(name) == "string" and type(rgb) == "table" and type(rgb[1]) == "number" and type(rgb[2]) == "number" and type(rgb[3]) == "number" and themePaletteValues[name] ~= nil then
                            colors[name] = Color3.new(math.clamp(rgb[1], 0, 1), math.clamp(rgb[2], 0, 1), math.clamp(rgb[3], 0, 1))
                        end
                    end
                    return colors
                end
                local function loadCustomTheme(name)
                    if type(readfile) ~= "function" then return false, "Workspace file APIs unavailable" end
                    local ok, raw = pcall(readfile, themeFilePath(name))
                    if not ok or type(raw) ~= "string" then return false, "Saved theme not found" end
                    local decodedOK, data = pcall(function() return HttpService:JSONDecode(raw) end)
                    if not decodedOK then return false, "Theme file is invalid" end
                    local colors = decodeThemePalette(data)
                    if not colors then return false, "Theme file is invalid" end
                    applyLoadedPalette(colors)
                  
                    local savedAnimation = type(data.animation) == "table" and data.animation or nil
                    local savedAnimationName = savedAnimation and savedAnimation.theme or data.animationTheme
                    local savedAnimationEnabled = savedAnimation and savedAnimation.enabled
                    if savedAnimationEnabled == nil then savedAnimationEnabled = data.animationsEnabled end
                    selectedTheme = "Snow"
                    for i = 1, #choices do
                        local availableAnimation = choices[i]
                        if availableAnimation == savedAnimationName then selectedTheme = availableAnimation; break end
                    end
                    effectsEnabled = type(savedAnimationEnabled) == "boolean" and savedAnimationEnabled or false
                    applyTheme()
                    local effectsBox = ScreenGui:FindFirstChild("EffectsCheckbox", true)
                    if effectsBox then effectsBox.BackgroundColor3 = effectsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36) end
                    local animationLabel = ScreenGui:FindFirstChild("SelectedAnimationName", true)
                    if animationLabel then animationLabel.Text = effectsEnabled and selectedTheme or "Off" end
                    local effectsArrow = ScreenGui:FindFirstChild("ThemeDropdownArrow", true)
                    if effectsArrow then effectsArrow.Visible = effectsEnabled end
                    local effectsList = ScreenGui:FindFirstChild("ThemeChoices", true)
                    if effectsList and not effectsEnabled then effectsList.Visible = false end
                    presetButton.Text = "Themes  ·  " .. name .. "  ▾"
                    local animationStatus = effectsEnabled and (selectedTheme .. " ON") or (selectedTheme .. " OFF")
                    customThemeStatus.Text = "Loaded: " .. name .. " · Animation: " .. animationStatus
                    return true
                end
                local function refreshThemeList()
                    local presetChildren = presetList:GetChildren()
                    for i = 1, #presetChildren do
                        local child = presetChildren[i]
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    local names = table.clone(builtInPresetNames)
                    local seen = {}
                    for i = 1, #names do
                        local name = names[i]
                        seen[name:lower()] = true
                    end
                    if type(listfiles) == "function" then
                        local ok, files = pcall(listfiles, THEME_FOLDER)
                        if ok and type(files) == "table" then
                            for i = 1, #files do
                                local filePath = files[i]
                                local name = tostring(filePath):match("([^/\\]+)%.json$")
                                if name and not seen[name:lower()] then table.insert(names, name); seen[name:lower()] = true end
                            end
                        end
                    end
                    table.sort(names, function(a, b)
                        local aBuiltIn, bBuiltIn = presetPalettes[a] ~= nil, presetPalettes[b] ~= nil
                        if aBuiltIn ~= bBuiltIn then return aBuiltIn end
                        return a:lower() < b:lower()
                    end)
                    presetList.CanvasSize = UDim2.fromOffset(0, #names * 24)
                    presetList.Size = UDim2.new(1, -24, 0, math.min(#names * 24, 6 * 24))
                    for presetIndex = 1, #names do
                        local presetName = names[presetIndex]
                        local presetOption = Instance.new("TextButton")
                        presetOption.Parent = presetList
                        presetOption.Position = UDim2.fromOffset(0, (presetIndex - 1) * 24)
                        presetOption.Size = UDim2.new(1, -4, 0, 24)
                        presetOption.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                        presetOption.BorderSizePixel = 0
                        presetOption.Text = presetName
                        presetOption.TextColor3 = Color3.fromRGB(235, 235, 245)
                        presetOption.Font = Enum.Font.Code
                        presetOption.TextSize = 11
                        presetOption.ZIndex = 31
                        presetOption.Activated:Connect(function()
                            if presetPalettes[presetName] then
                       
                                selectedTheme = "Snow"
                                effectsEnabled = false
                                applyTheme()
                                local effectsBox = ScreenGui:FindFirstChild("EffectsCheckbox", true)
                                if effectsBox then effectsBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36) end
                                local effectsArrow = ScreenGui:FindFirstChild("ThemeDropdownArrow", true)
                                if effectsArrow then effectsArrow.Visible = false end
                                local effectsList = ScreenGui:FindFirstChild("ThemeChoices", true)
                                if effectsList then effectsList.Visible = false end
                                for colorName, colorValue in next, presetPalettes[presetName] do applyPaletteColor(colorName, colorValue) end
                                presetButton.Text = "Themes  ·  " .. presetName .. "  ▾"
                                customThemeStatus.Text = "Selected theme: " .. presetName
                                presetList.Visible = false
                            else
                                local ok, reason = loadCustomTheme(presetName)
                                if not ok then customThemeStatus.Text = reason end
                                presetList.Visible = false
                            end
                        end)
                    end
                end
                presetButton.Activated:Connect(function() presetList.Visible = not presetList.Visible end)

                local themeActions = { "Save Theme", "Delete", "Refresh" }
                local themeActionsRow = Instance.new("Frame")
                themeActionsRow.Name = "CustomThemeActions"
                themeActionsRow.Parent = paletteScroll
                themeActionsRow.Position = UDim2.fromOffset(0, 450)
                themeActionsRow.Size = UDim2.new(1, -4, 0, 24)
                themeActionsRow.BackgroundTransparency = 1
                for actionIndex = 1, #themeActions do
                    local actionName = themeActions[actionIndex]
                    local actionButton = Instance.new("TextButton")
                    actionButton.Parent = themeActionsRow
                    actionButton.Position = UDim2.new((actionIndex - 1) / 3, 0, 0, 0)
                    actionButton.Size = UDim2.new(1 / 3, -3, 1, 0)
                    actionButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                    actionButton.BorderSizePixel = 0
                    actionButton.Text = actionName
                    actionButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                    actionButton.Font = Enum.Font.Code
                    actionButton.TextSize = 9
                    actionButton.ZIndex = 6
                    actionButton.Activated:Connect(function()
                        local name = cleanThemeName(themeNameBox.Text)
                        if actionName == "Refresh" then
                            local ready = ensureThemeFolder()
                            refreshThemeList()
                            customThemeStatus.Text = ready and "Saved themes refreshed" or "Workspace file APIs unavailable"
                        elseif name == "" then
                            customThemeStatus.Text = "Enter a theme name first"
                        elseif presetPalettes[name] then
                            customThemeStatus.Text = "That name is reserved for a built-in theme"
                        elseif actionName == "Save Theme" then
                            local ready = ensureThemeFolder()
                            if not ready or type(writefile) ~= "function" then customThemeStatus.Text = "Workspace file APIs unavailable"; return end
                            local encodedOK, raw = pcall(function() return HttpService:JSONEncode(encodeThemePalette()) end)
                            if not encodedOK then customThemeStatus.Text = "Could not encode theme"; return end
                            local writeOK = pcall(writefile, themeFilePath(name), raw)
                            if writeOK then
                                presetButton.Text = "Themes  ·  " .. name .. "  ▾"
                                local savedAnimationEnabled = effectsEnabled or selectedTheme ~= "Snow"
                                local animationStatus = savedAnimationEnabled and (selectedTheme .. " ON") or (selectedTheme .. " OFF")
                                customThemeStatus.Text = "Saved: " .. name .. " · Animation: " .. animationStatus
                                refreshThemeList()
                            else
                                customThemeStatus.Text = "Could not save theme"
                            end
                        elseif actionName == "Delete" then
                            if type(delfile) ~= "function" then customThemeStatus.Text = "Workspace delete API unavailable"; return end
                            local deleteOK = pcall(delfile, themeFilePath(name))
                            customThemeStatus.Text = deleteOK and ("Deleted theme: " .. name) or "Saved theme not found"
                            refreshThemeList()
                        end
                    end)
                end
                local themeFolderReady = ensureThemeFolder()
                refreshThemeList()
                if not themeFolderReady then customThemeStatus.Text = "Workspace file APIs unavailable" end

                local menuMusicRow = Instance.new("Frame")
                menuMusicRow.Name = "MenuMusicRow"
                menuMusicRow.Parent = soundPage
                menuMusicRow.Position = UDim2.fromOffset(12, 42)
                menuMusicRow.Size = UDim2.new(1, -24, 0, 24)
                menuMusicRow.BackgroundTransparency = 1
                menuMusicRow.ZIndex = 9

                local menuMusicLabel = Instance.new("TextLabel")
                menuMusicLabel.Parent = menuMusicRow
                menuMusicLabel.Size = UDim2.new(1, -64, 1, 0)
                menuMusicLabel.BackgroundTransparency = 1
                menuMusicLabel.Text = "Menu Music"
                menuMusicLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                menuMusicLabel.TextXAlignment = Enum.TextXAlignment.Left
                menuMusicLabel.Font = Enum.Font.Code
                menuMusicLabel.TextSize = 12
                menuMusicLabel.ZIndex = 10

                local menuMusicBox = Instance.new("TextButton")
                menuMusicBox.Name = "MenuMusicCheckbox"
                menuMusicBox.Parent = menuMusicRow
                menuMusicBox.Size = UDim2.fromOffset(18, 18)
                menuMusicBox.Position = UDim2.new(1, -40, 0, 3)
                menuMusicBox.BackgroundColor3 = menuMusicEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                menuMusicBox.BackgroundTransparency = 0
                menuMusicBox.BorderSizePixel = 0
                menuMusicBox.Text = ""
                menuMusicBox.ZIndex = 10
                local menuMusicBoxStroke = Instance.new("UIStroke")
                menuMusicBoxStroke.Parent = menuMusicBox
                menuMusicBoxStroke.Color = Color3.fromRGB(255, 255, 255)
                menuMusicBoxStroke.Thickness = 1.5

                local menuSongArrow = Instance.new("TextButton")
                menuSongArrow.Name = "MenuSongDropdownArrow"
                menuSongArrow.Parent = menuMusicRow
                menuSongArrow.Position = UDim2.new(1, -20, 0, 2)
                menuSongArrow.Size = UDim2.fromOffset(18, 20)
                menuSongArrow.BackgroundTransparency = 1
                menuSongArrow.BorderSizePixel = 0
                menuSongArrow.Text = ""
                menuSongArrow.ZIndex = 10
                local songArrowLeft = Instance.new("Frame")
                songArrowLeft.Parent = menuSongArrow
                songArrowLeft.AnchorPoint = Vector2.new(0.5, 0.5)
                songArrowLeft.Position = UDim2.fromScale(0.34, 0.62)
                songArrowLeft.Size = UDim2.fromOffset(7, 1.5)
                songArrowLeft.Rotation = 45
                songArrowLeft.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                songArrowLeft.BorderSizePixel = 0
                songArrowLeft.ZIndex = 10
                local songArrowRight = Instance.new("Frame")
                songArrowRight.Parent = menuSongArrow
                songArrowRight.AnchorPoint = Vector2.new(0.5, 0.5)
                songArrowRight.Position = UDim2.fromScale(0.66, 0.62)
                songArrowRight.Size = UDim2.fromOffset(7, 1.5)
                songArrowRight.Rotation = -45
                songArrowRight.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                songArrowRight.BorderSizePixel = 0
                songArrowRight.ZIndex = 10

                local songStatus = Instance.new("TextLabel")
                songStatus.Name = "CurrentMenuSong"
                songStatus.Parent = soundPage
                songStatus.Position = UDim2.fromOffset(12, 98)
                songStatus.Size = UDim2.new(1, -24, 0, 22)
                songStatus.BackgroundTransparency = 1
                songStatus.Text = "Now Playing  •  " .. MENU_SONGS[selectedSongIndex].name
                songStatus.TextColor3 = Color3.fromRGB(190, 190, 205)
                songStatus.TextXAlignment = Enum.TextXAlignment.Left
                songStatus.Font = Enum.Font.Code
                songStatus.TextSize = 12
                songStatus.ZIndex = 10

                local songList = Instance.new("Frame")
                songList.Name = "MenuSongChoices"
                songList.Parent = soundPage
                songList.Position = UDim2.fromOffset(12, 124)
                songList.Size = UDim2.new(1, -24, 0, #MENU_SONGS * 30)
                songList.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                songList.BorderSizePixel = 0
                songList.Visible = false
                songList.ZIndex = 30
                local songLayout = Instance.new("UIListLayout")
                songLayout.Parent = songList
                songLayout.SortOrder = Enum.SortOrder.LayoutOrder
                for songIndex = 1, #MENU_SONGS do
                    local song = MENU_SONGS[songIndex]
                    local songOption = Instance.new("TextButton")
                    songOption.Name = "SongOption" .. songIndex
                    songOption.Parent = songList
                    songOption.LayoutOrder = songIndex
                    songOption.Size = UDim2.new(1, 0, 0, 30)
                    songOption.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                    songOption.BorderSizePixel = 0
                    songOption.Text = song.name
                    songOption.TextColor3 = Color3.fromRGB(235, 235, 245)
                    songOption.TextXAlignment = Enum.TextXAlignment.Left
                    songOption.Font = Enum.Font.Code
                    songOption.TextSize = 12
                    songOption.ZIndex = 31
                    songOption.Activated:Connect(function()
                        selectedSongIndex = songIndex
                        menuMusic:Pause()
                        menuMusic.TimePosition = 0
                        menuMusic.SoundId = song.id
                        songStatus.Text = "Now Playing  •  " .. song.name
                        songList.Visible = false
                        songArrowLeft.Rotation = 45
                        songArrowRight.Rotation = -45
                        menuMusicPausedByToggle = false
                        updateMenuMusic()
                    end)
                end
                local function toggleSongList()
                    songList.Visible = not songList.Visible
                    songArrowLeft.Rotation = songList.Visible and -45 or 45
                    songArrowRight.Rotation = songList.Visible and 45 or -45
                end
                menuSongArrow.Activated:Connect(toggleSongList)
                menuMusicBox.Activated:Connect(function()
                    menuMusicEnabled = not menuMusicEnabled
                    menuMusicBox.BackgroundColor3 = menuMusicEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                    if not menuMusicEnabled then
                        menuMusic:Pause()
                        menuMusicPausedByToggle = true
                    end
                    updateMenuMusic()
                end)

                local clickSoundsRow = Instance.new("Frame")
                clickSoundsRow.Name = "UIClickSoundsRow"
                clickSoundsRow.Parent = soundPage
                clickSoundsRow.Position = UDim2.fromOffset(12, 126)
                clickSoundsRow.Size = UDim2.new(1, -24, 0, 24)
                clickSoundsRow.BackgroundTransparency = 1
                clickSoundsRow.ZIndex = 9
                local clickSoundsLabel = Instance.new("TextLabel")
                clickSoundsLabel.Parent = clickSoundsRow
                clickSoundsLabel.Size = UDim2.new(1, -30, 1, 0)
                clickSoundsLabel.BackgroundTransparency = 1
                clickSoundsLabel.Text = "Click Sounds"
                clickSoundsLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                clickSoundsLabel.TextXAlignment = Enum.TextXAlignment.Left
                clickSoundsLabel.Font = Enum.Font.Code
                clickSoundsLabel.TextSize = 12
                clickSoundsLabel.ZIndex = 10
                local clickSoundsBox = Instance.new("TextButton")
                clickSoundsBox.Name = "UIClickSoundsCheckbox"
                clickSoundsBox.Parent = clickSoundsRow
                clickSoundsBox.Size = UDim2.fromOffset(18, 18)
                clickSoundsBox.Position = UDim2.new(1, -18, 0, 3)
                clickSoundsBox.BackgroundColor3 = uiClickSoundsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                clickSoundsBox.BorderSizePixel = 0
                clickSoundsBox.Text = ""
                clickSoundsBox.ZIndex = 10
                local clickSoundsStroke = Instance.new("UIStroke")
                clickSoundsStroke.Parent = clickSoundsBox
                clickSoundsStroke.Color = Color3.fromRGB(255, 255, 255)
                clickSoundsStroke.Thickness = 1.5
                clickSoundsBox.Activated:Connect(function()
                    uiClickSoundsEnabled = not uiClickSoundsEnabled
                    clickSoundsBox.BackgroundColor3 = uiClickSoundsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                    if uiClickSoundsEnabled then playUIClickSound() end
                end)

                local musicModeRow = Instance.new("Frame")
                musicModeRow.Name = "MusicPlaybackModeRow"
                musicModeRow.Parent = soundPage
                musicModeRow.Position = UDim2.fromOffset(12, 72)
                musicModeRow.Size = UDim2.new(1, -24, 0, 24)
                musicModeRow.BackgroundTransparency = 1
                musicModeRow.ZIndex = 9
                local musicModeLabel = Instance.new("TextLabel")
                musicModeLabel.Parent = musicModeRow
                musicModeLabel.Size = UDim2.new(1, -30, 1, 0)
                musicModeLabel.BackgroundTransparency = 1
                musicModeLabel.Text = "Only Play With UI Open"
                musicModeLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                musicModeLabel.TextXAlignment = Enum.TextXAlignment.Left
                musicModeLabel.Font = Enum.Font.Code
                musicModeLabel.TextSize = 12
                musicModeLabel.ZIndex = 10
                local musicModeBox = Instance.new("TextButton")
                musicModeBox.Name = "MusicOnlyWithUICheckbox"
                musicModeBox.Parent = musicModeRow
                musicModeBox.Size = UDim2.fromOffset(18, 18)
                musicModeBox.Position = UDim2.new(1, -18, 0, 3)
                musicModeBox.BackgroundColor3 = menuMusicOnlyWithUI and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                musicModeBox.BackgroundTransparency = 0
                musicModeBox.BorderSizePixel = 0
                musicModeBox.Text = ""
                musicModeBox.ZIndex = 10
                local musicModeStroke = Instance.new("UIStroke")
                musicModeStroke.Parent = musicModeBox
                musicModeStroke.Color = Color3.fromRGB(255, 255, 255)
                musicModeStroke.Thickness = 1.5
                musicModeBox.Activated:Connect(function()
                    menuMusicOnlyWithUI = not menuMusicOnlyWithUI
                    musicModeBox.BackgroundColor3 = menuMusicOnlyWithUI and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 36)
                    updateMenuMusic()
                end)

                local volumeRowY = 154
                local volumeRow = Instance.new("Frame")
                volumeRow.Name = "MusicVolumeRow"
                volumeRow.Parent = soundPage
                volumeRow.Position = UDim2.fromOffset(12, volumeRowY)
                volumeRow.Size = UDim2.new(1, -24, 0, 24)
                volumeRow.BackgroundTransparency = 1
                volumeRow.ZIndex = 9

                local volumeLabel = Instance.new("TextLabel")
                volumeLabel.Parent = volumeRow
                volumeLabel.Size = UDim2.new(1, -64, 1, 0)
                volumeLabel.BackgroundTransparency = 1
                volumeLabel.Text = "Song Volume"
                volumeLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
                volumeLabel.Font = Enum.Font.Code
                volumeLabel.TextSize = 12
                volumeLabel.ZIndex = 10

                local volumeButton = Instance.new("TextButton")
                volumeButton.Name = "MusicVolumeDropdown"
                volumeButton.Parent = volumeRow
                volumeButton.Position = UDim2.new(1, -62, 0, 2)
                volumeButton.Size = UDim2.fromOffset(40, 20)
                volumeButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                volumeButton.BorderSizePixel = 0
                volumeButton.Text = "40%"
                volumeButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                volumeButton.Font = Enum.Font.Code
                volumeButton.TextSize = 11
                volumeButton.ZIndex = 10
                local volumeButtonStroke = Instance.new("UIStroke")
                volumeButtonStroke.Parent = volumeButton
                volumeButtonStroke.Color = uiAccentColor
                volumeButtonStroke.Thickness = 1
                table.insert(accentStrokes, volumeButtonStroke)

                local volumeArrow = Instance.new("TextButton")
                volumeArrow.Name = "MusicVolumeArrow"
                volumeArrow.Parent = volumeRow
                volumeArrow.Position = UDim2.new(1, -20, 0, 2)
                volumeArrow.Size = UDim2.fromOffset(18, 20)
                volumeArrow.BackgroundTransparency = 1
                volumeArrow.BorderSizePixel = 0
                volumeArrow.Text = ""
                volumeArrow.ZIndex = 10
                local volumeArrowLeft = Instance.new("Frame")
                volumeArrowLeft.Parent = volumeArrow
                volumeArrowLeft.AnchorPoint = Vector2.new(0.5, 0.5)
                volumeArrowLeft.Position = UDim2.fromScale(0.34, 0.62)
                volumeArrowLeft.Size = UDim2.fromOffset(7, 1.5)
                volumeArrowLeft.Rotation = 45
                volumeArrowLeft.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                volumeArrowLeft.BorderSizePixel = 0
                volumeArrowLeft.ZIndex = 10
                local volumeArrowRight = Instance.new("Frame")
                volumeArrowRight.Parent = volumeArrow
                volumeArrowRight.AnchorPoint = Vector2.new(0.5, 0.5)
                volumeArrowRight.Position = UDim2.fromScale(0.66, 0.62)
                volumeArrowRight.Size = UDim2.fromOffset(7, 1.5)
                volumeArrowRight.Rotation = -45
                volumeArrowRight.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
                volumeArrowRight.BorderSizePixel = 0
                volumeArrowRight.ZIndex = 10
                local volumeList = Instance.new("Frame")
                volumeList.Name = "MusicVolumeChoices"
                volumeList.Parent = soundPage
                volumeList.Position = UDim2.fromOffset(12, volumeRowY + 28)
                volumeList.Size = UDim2.new(1, -24, 0, 6 * 30)
                volumeList.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                volumeList.BorderSizePixel = 0
                volumeList.Visible = false
                volumeList.ZIndex = 30
                local volumeLayout = Instance.new("UIListLayout")
                volumeLayout.Parent = volumeList
                volumeLayout.SortOrder = Enum.SortOrder.LayoutOrder
                local volumeChoices = { {"0%", 0}, {"20%", 0.2}, {"40%", 0.4}, {"60%", 0.6}, {"80%", 0.8}, {"100%", 1} }
                for volumeIndex = 1, #volumeChoices do
                    local volumeChoice = volumeChoices[volumeIndex]
                    local volumeOption = Instance.new("TextButton")
                    volumeOption.Name = "Volume" .. volumeChoice[1]
                    volumeOption.Parent = volumeList
                    volumeOption.LayoutOrder = volumeIndex
                    volumeOption.Size = UDim2.new(1, 0, 0, 30)
                    volumeOption.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                    volumeOption.BorderSizePixel = 0
                    volumeOption.Text = volumeChoice[1]
                    volumeOption.TextColor3 = Color3.fromRGB(235, 235, 245)
                    volumeOption.Font = Enum.Font.Code
                    volumeOption.TextSize = 12
                    volumeOption.ZIndex = 31
                    volumeOption.Activated:Connect(function()
                        menuMusic.Volume = volumeChoice[2]
                        volumeButton.Text = volumeChoice[1]
                        volumeList.Visible = false
                        volumeArrowLeft.Rotation = 45
                        volumeArrowRight.Rotation = -45
                    end)
                end
                local function toggleVolumeList()
                    volumeList.Visible = not volumeList.Visible
                    volumeArrowLeft.Rotation = volumeList.Visible and -45 or 45
                    volumeArrowRight.Rotation = volumeList.Visible and 45 or -45
                end
                volumeButton.Activated:Connect(toggleVolumeList)
                volumeArrow.Activated:Connect(toggleVolumeList)

                local clickSoundRow = Instance.new("Frame")
                clickSoundRow.Name = "ClickSoundRow"
                clickSoundRow.Parent = soundPage
                clickSoundRow.Position = UDim2.fromOffset(12, 194)
                clickSoundRow.Size = UDim2.new(1, -24, 0, 24)
                clickSoundRow.BackgroundTransparency = 1
                clickSoundRow.ZIndex = 9
                local clickSoundLabel = Instance.new("TextLabel")
                clickSoundLabel.Parent = clickSoundRow
                clickSoundLabel.Size = UDim2.new(1, -116, 1, 0)
                clickSoundLabel.BackgroundTransparency = 1
                clickSoundLabel.Text = "Click Sound"
                clickSoundLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                clickSoundLabel.TextXAlignment = Enum.TextXAlignment.Left
                clickSoundLabel.Font = Enum.Font.Code
                clickSoundLabel.TextSize = 12
                clickSoundLabel.ZIndex = 10
                local clickSoundButton = Instance.new("TextButton")
                clickSoundButton.Name = "ClickSoundDropdown"
                clickSoundButton.Parent = clickSoundRow
                clickSoundButton.Position = UDim2.new(1, -104, 0, 2)
                clickSoundButton.Size = UDim2.fromOffset(84, 20)
                clickSoundButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                clickSoundButton.BorderSizePixel = 0
                clickSoundButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                clickSoundButton.Font = Enum.Font.Code
                clickSoundButton.TextSize = 9
                clickSoundButton.ZIndex = 10
                local clickSoundArrow = Instance.new("TextButton")
                clickSoundArrow.Name = "ClickSoundDropdownArrow"
                clickSoundArrow.Parent = clickSoundRow
                clickSoundArrow.Position = UDim2.new(1, -20, 0, 2)
                clickSoundArrow.Size = UDim2.fromOffset(18, 20)
                clickSoundArrow.BackgroundTransparency = 1
                clickSoundArrow.BorderSizePixel = 0
                clickSoundArrow.Text = "⌄"
                clickSoundArrow.TextColor3 = Color3.fromRGB(220, 225, 240)
                clickSoundArrow.Font = Enum.Font.Code
                clickSoundArrow.TextSize = 16
                clickSoundArrow.ZIndex = 10
                local clickSoundList = Instance.new("ScrollingFrame")
                clickSoundList.Name = "ClickSoundChoices"
                clickSoundList.Parent = soundPage
                clickSoundList.Position = UDim2.fromOffset(12, 222)
                clickSoundList.Size = UDim2.new(1, -24, 0, 156)
                clickSoundList.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
                clickSoundList.BorderSizePixel = 0
                clickSoundList.ScrollBarThickness = 3
                clickSoundList.CanvasSize = UDim2.fromOffset(0, 0)
                clickSoundList.Visible = false
                clickSoundList.ZIndex = 30
                local clickSoundLayout = Instance.new("UIListLayout")
                clickSoundLayout.Parent = clickSoundList
                clickSoundLayout.SortOrder = Enum.SortOrder.LayoutOrder
                clickSoundLayout.Padding = UDim.new(0, 1)
                local clickSoundInputRow = Instance.new("Frame")
                clickSoundInputRow.Name = "AddClickSoundRow"
                clickSoundInputRow.Parent = soundPage
                clickSoundInputRow.Position = UDim2.fromOffset(12, 230)
                clickSoundInputRow.Size = UDim2.new(1, -24, 0, 24)
                clickSoundInputRow.BackgroundTransparency = 1
                clickSoundInputRow.ZIndex = 9
                local clickSoundInputLabel = Instance.new("TextLabel")
                clickSoundInputLabel.Parent = clickSoundInputRow
                clickSoundInputLabel.Size = UDim2.new(1, -116, 1, 0)
                clickSoundInputLabel.BackgroundTransparency = 1
                clickSoundInputLabel.Text = "Add Asset ID"
                clickSoundInputLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
                clickSoundInputLabel.TextXAlignment = Enum.TextXAlignment.Left
                clickSoundInputLabel.Font = Enum.Font.Code
                clickSoundInputLabel.TextSize = 11
                clickSoundInputLabel.ZIndex = 10
                local clickSoundInput = Instance.new("TextBox")
                clickSoundInput.Name = "ClickSoundIdInput"
                clickSoundInput.Parent = clickSoundInputRow
                clickSoundInput.Position = UDim2.new(1, -104, 0, 2)
                clickSoundInput.Size = UDim2.fromOffset(68, 20)
                clickSoundInput.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                clickSoundInput.BorderSizePixel = 0
                clickSoundInput.Text = ""
                clickSoundInput.PlaceholderText = "Asset ID"
                clickSoundInput.TextColor3 = Color3.fromRGB(235, 235, 245)
                clickSoundInput.Font = Enum.Font.Code
                clickSoundInput.TextSize = 9
                clickSoundInput.ClearTextOnFocus = false
                clickSoundInput.ZIndex = 10
                local addClickSoundButton = Instance.new("TextButton")
                addClickSoundButton.Name = "AddClickSound"
                addClickSoundButton.Parent = clickSoundInputRow
                addClickSoundButton.Position = UDim2.new(1, -32, 0, 2)
                addClickSoundButton.Size = UDim2.fromOffset(32, 20)
                addClickSoundButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
                addClickSoundButton.BorderSizePixel = 0
                addClickSoundButton.Text = "Add"
                addClickSoundButton.TextColor3 = Color3.fromRGB(235, 235, 245)
                addClickSoundButton.Font = Enum.Font.Code
                addClickSoundButton.TextSize = 9
                addClickSoundButton.ZIndex = 10
                local function getClickSoundName()
                    for presetIndex = 1, #CLICK_SOUND_PRESETS do
                        local sound = CLICK_SOUND_PRESETS[presetIndex]
                        if UI_CLICK_SOUND_ID == "rbxassetid://" .. sound.id then return sound.name end
                    end
                    for customIndex = 1, #customClickSounds do
                        local sound = customClickSounds[customIndex]
                        if UI_CLICK_SOUND_ID == "rbxassetid://" .. sound.id then return sound.name end
                    end
                    return "Custom"
                end
                refreshClickSoundMenu = function()
                    local children = clickSoundList:GetChildren()
                    for childIndex = 1, #children do
                        local child = children[childIndex]
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    local optionCount = #CLICK_SOUND_PRESETS + #customClickSounds
                    clickSoundList.CanvasSize = UDim2.fromOffset(0, optionCount * 25)
                    for presetIndex = 1, #CLICK_SOUND_PRESETS do
                        local sound = CLICK_SOUND_PRESETS[presetIndex]
                        local option = Instance.new("TextButton")
                        option.Name = "ClickSoundPreset" .. presetIndex
                        option.Parent = clickSoundList
                        option.LayoutOrder = presetIndex
                        option.Size = UDim2.new(1, 0, 0, 24)
                        option.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                        option.BorderSizePixel = 0
                        option.Text = sound.name
                        option.TextColor3 = Color3.fromRGB(235, 235, 245)
                        option.Font = Enum.Font.Code
                        option.TextSize = 10
                        option.ZIndex = 31
                        option.Activated:Connect(function()
                            UI_CLICK_SOUND_ID = "rbxassetid://" .. sound.id
                            clickSoundButton.Text = sound.name
                            clickSoundList.Visible = false
                        end)
                    end
                    for customIndex = 1, #customClickSounds do
                        local sound = customClickSounds[customIndex]
                        local option = Instance.new("TextButton")
                        option.Name = "ClickSoundCustom" .. customIndex
                        option.Parent = clickSoundList
                        option.LayoutOrder = #CLICK_SOUND_PRESETS + customIndex
                        option.Size = UDim2.new(1, 0, 0, 24)
                        option.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
                        option.BorderSizePixel = 0
                        option.Text = sound.name
                        option.TextColor3 = Color3.fromRGB(235, 235, 245)
                        option.Font = Enum.Font.Code
                        option.TextSize = 10
                        option.ZIndex = 31
                        option.Activated:Connect(function()
                            UI_CLICK_SOUND_ID = "rbxassetid://" .. sound.id
                            clickSoundButton.Text = sound.name
                            clickSoundList.Visible = false
                        end)
                    end
                    clickSoundButton.Text = getClickSoundName()
                end
                local function addClickSound()
                    local assetId = clickSoundInput.Text:match("^%s*(%d+)%s*$")
                    if not assetId then return end
                    local found = false
                    for presetIndex = 1, #CLICK_SOUND_PRESETS do
                        local sound = CLICK_SOUND_PRESETS[presetIndex]
                        if sound.id == assetId then
                            UI_CLICK_SOUND_ID = "rbxassetid://" .. sound.id
                            found = true
                            break
                        end
                    end
                    for customIndex = 1, #customClickSounds do
                        local sound = customClickSounds[customIndex]
                        if sound.id == assetId then
                            UI_CLICK_SOUND_ID = "rbxassetid://" .. sound.id
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(customClickSounds, { name = "Custom " .. assetId, id = assetId })
                        UI_CLICK_SOUND_ID = "rbxassetid://" .. assetId
                    end
                    clickSoundInput.Text = ""
                    refreshClickSoundMenu()
                end
                local function toggleClickSoundList()
                    clickSoundList.Visible = not clickSoundList.Visible
                end
                addClickSoundButton.Activated:Connect(addClickSound)
                clickSoundInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed then addClickSound() end
                end)
                clickSoundButton.Activated:Connect(toggleClickSoundList)
                clickSoundArrow.Activated:Connect(toggleClickSoundList)
                refreshClickSoundMenu()


            end
			end
    end

    local tabOrder = { Combat = 1, Visuals = 2, Player = 3, Misc = 4, Settings = 5 }


    local function CreateTab(tabName)
			local button = Instance.new("TextButton")
			button.Name = tabName .. "Tab"
			button.LayoutOrder = tabOrder[tabName] or 999
			button.Parent = TabHolder
			button.ZIndex = 10
			button.Size = UDim2.fromOffset(105, 30)
			button.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
			button.BorderSizePixel = 0
			button.Text = tabName
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Font = Enum.Font.Code
			button.TextSize = 14
			tabButtons[tabName] = button

			local buttonStroke = Instance.new("UIStroke")
			buttonStroke.Parent = button
			bindAccent(buttonStroke)
			buttonStroke.Thickness = 1

			button.Activated:Connect(function()
				showTab(tabName)
			end)
    end

    _G.__OmniBindUIClickSound = function(instance)
        if instance:IsA("GuiButton") and not instance:GetAttribute("OmniClickSoundBound") then
            instance:SetAttribute("OmniClickSoundBound", true)
            instance.Activated:Connect(function()
                playUIClickSound()
            end)
        end
    end
    table.insert(managedConnections, ScreenGui.DescendantAdded:Connect(function(instance)
        _G.__OmniBindUIClickSound(instance)
    end))
    task.defer(function()
        for _, instance in ipairs(ScreenGui:GetDescendants()) do
            _G.__OmniBindUIClickSound(instance)
        end
    end)

    CreateTab("Combat")
    CreateTab("Visuals")
    CreateTab("Player")
    CreateTab("Misc")
    CreateTab("Settings")

    showTab("Settings") 
    showTab("Combat")

    local function startSnow()
        if snowConnection then snowConnection:Disconnect() end
        applyTheme()
        snowConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if not effectsEnabled then return end
            if selectedTheme == "Lightning" and not lightningFlash.Visible and Random:NextNumber() < 0.004 then
                makeLightningBolt()
                lightningFlash.Visible = true
                lightningFlash.BackgroundTransparency = 0.52
                task.delay(0.045, function()
                    if lightningFlash.Parent then lightningFlash.BackgroundTransparency = 0.82 end
                end)
                task.delay(0.13, function()
                    lightningFlash.Visible = false
                    if lightningBolt then lightningBolt:Destroy(); lightningBolt = nil end
                end)
            end
            local activeItems = selectedTheme == "Snow" and snowflakes
                or (selectedTheme == "Rain" and rainDrops)
                or (selectedTheme == "Lightning" and lightningRainDrops)
                or (selectedTheme == "Fire" and fireFlames)
                or starFlakes
            for i = 1, #activeItems do
                local item = activeItems[i]
                local position = item.frame.Position
                local direction = item.rise and -1 or 1
                local y = position.Y.Scale + item.speed * deltaTime * direction
                local drift = item.drift or -0.08
                local x = position.X.Scale + drift * deltaTime
                if item.rise and y < -0.1 then y = 1.08; x = Random:NextNumber() elseif not item.rise and y > 1.05 then y = -0.05; x = Random:NextNumber() end
                if x < -0.05 then x = 1.05 elseif x > 1.05 then x = -0.05 end
                item.frame.Position = UDim2.fromScale(x, y)
                if item.flicker then
                    local pulse = 0.84 + 0.16 * math.sin(os.clock() * 12 + item.phase)
                    local heightFade = math.clamp((0.62 - y) / 0.62, 0, 1)
                    item.frame.Size = UDim2.fromOffset(item.baseWidth * pulse, item.baseHeight * (0.9 + 0.1 * pulse))
                    item.frame.Rotation = math.sin(os.clock() * 5 + item.phase) * 10
                    item.frame.ImageTransparency = 0.05 + 0.76 * heightFade + 0.08 * (1 - pulse)
                    item.core.ImageTransparency = 0.28 + 0.65 * heightFade + 0.06 * (1 - pulse)
                elseif item.ember then
                    item.frame.BackgroundTransparency = 0.12 + 0.5 * math.abs(math.sin(os.clock() * 6 + x * 20))
                end
            end
        end)
    end

    _G.__OmniSetMenuOpen = function(isOpen)
        menuOpen = isOpen
        ScreenGui.Enabled = isOpen
        updateMenuMusic()
        if isOpen then
            refreshUIScale()
            clampToViewport(Main)
            startSnow()
        else
            if menuMusicOnlyWithUI and menuMusic.IsPlaying then
                menuMusic:Pause()
                menuMusicPausedByToggle = true
            end
            if snowConnection then
                snowConnection:Disconnect()
                snowConnection = nil
            end
            SnowLayer.Visible = false
            animationBlur.Enabled = false
        end
    end

    applyTheme()
    startSnow()
    updateMenuMusic()
    playUIClickSound(1)
    table.insert(managedConnections, UIS.InputBegan:Connect(function(input, gameProcessed)
        if uiUnloaded or gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            _G.__OmniSetMenuOpen(not menuOpen)
        end
    end))

    _G.__OmniDragState = { dragging = false }

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _G.__OmniDragState.dragging = true
            _G.__OmniDragState.dragStart = input.Position
            _G.__OmniDragState.startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    _G.__OmniDragState.dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            _G.__OmniDragState.dragInput = input
        end
    end)

    table.insert(managedConnections, UIS.InputChanged:Connect(function(input)
        if input == _G.__OmniDragState.dragInput and _G.__OmniDragState.dragging then
            local delta = input.Position - _G.__OmniDragState.dragStart
            Main.Position = UDim2.new(
                _G.__OmniDragState.startPos.X.Scale,
                _G.__OmniDragState.startPos.X.Offset + delta.X,
                _G.__OmniDragState.startPos.Y.Scale,
                _G.__OmniDragState.startPos.Y.Offset + delta.Y
            )
            clampToViewport(Main)
        end
    end))
    
