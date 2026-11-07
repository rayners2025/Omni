

local UIS            = game:GetService("UserInputService")
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting       = game:GetService("Lighting")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local SoundService   = game:GetService("SoundService")
local CoreGui        = game:GetService("CoreGui")
local Player         = Players.LocalPlayer
local Random         = Random.new()

local gg = (getgenv and getgenv()) or _G

do
    local g = (getgenv and getgenv()) or _G
    local function pick(...)
        for i = 1, select("#", ...) do
            local v = select(i, ...)
            if type(v) == "function" then return v end
        end
    end

    local execName = ""
    pcall(function()
        local n = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or ""
        execName = string.lower(tostring(n or ""))
    end)
    g.__OmniExecutor = execName
    local isPotassium = execName:find("potassium", 1, true) ~= nil
    g.__OmniIsPotassium = isPotassium

    if type(request) ~= "function" then
        local r = pick(http_request, g.request, g.http_request, syn and syn.request, http and http.request, fluxus and fluxus.request)
        if r then getfenv(0).request = r end
    end

    if type(gethui) ~= "function" then
        local h = pick(g.gethui, function()
            local ok, res = pcall(function() return game:GetService("CoreGui") end)
            return ok and res or nil
        end)
        if h then getfenv(0).gethui = h end
    end

    if type(newcclosure) == "function" then
        local ok, test = pcall(function()
            local f = newcclosure(function() return 123 end)
            return type(f) == "function" and f() == 123
        end)
        if not ok or not test then
            getfenv(0).newcclosure = function(f) return f end
        end
    else
        getfenv(0).newcclosure = function(f) return f end
    end

    g.__OmniCanHookFn = type(hookfunction) == "function"
    g.__OmniCanHookMeta = type(hookmetamethod) == "function"
    g.__OmniCanGetGC = type(getgc) == "function"

    g.__OmniProtectGui = pick(g.protect_gui, g.protectgui, syn and syn.protect_gui)

    if isPotassium then

        g.__OmniSoftHooks = true
    end
end

if gg.__OMNI_LOADED then
    local prevUnload = gg.__OmniUnload
    if type(prevUnload) == "function" then
        pcall(prevUnload)
    else
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Omni Project delta", Text = "Already loaded.", Duration = 4
            })
        end)
        return
    end
end
gg.__OMNI_LOADED = true

local REPO = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"

local function fetchModule(url)
    local req = request or http_request or (syn and syn.request)
    if type(req) == "function" then
        local ok, r = pcall(req, { Url = url, Method = "GET" })
        if ok and type(r) == "table" and r.StatusCode == 200 and type(r.Body) == "string" then
            return r.Body
        end
    end
    return game:HttpGet(url)
end

local function loadModule(url)
    local src = fetchModule(url)
    assert(type(src) == "string" and #src > 0, "failed to fetch: " .. url)
    if url:match("Library%.lua$") then

        local patched, n = src:gsub(
            "ContainerLabel%.Visible = true;",
            "ContainerLabel.Visible = KeyPicker.Value ~= 'None';",
            1
        )
        if n == 1 then src = patched end
    end
    local chunk, err = loadstring(src, url)
    assert(type(chunk) == "function", tostring(err))
    return chunk()
end

local Library     = loadModule(REPO .. "Library.lua")
local ThemeManager = loadModule(REPO .. "addons/ThemeManager.lua")
local SaveManager  = loadModule(REPO .. "addons/SaveManager.lua")

local Toggles = gg.Toggles
local Options  = gg.Options

local function T(k) local t = Toggles[k]; return t and t.Value end
local function O(k, default)
    local o = Options[k]
    if o then return o.Value end
    return default
end

local managedConns = {}
local shuttingDown = false
local function conn(signal, cb)
    if shuttingDown then return {Disconnect=function()end} end
    local c = signal:Connect(cb)
    managedConns[#managedConns+1] = c
    return c
end

local function runOmni()

local espState = {
    enabled=false, box=true, names=true, health=true, distance=true,
    visibility=true, tracer=false, chams=true, teamCheck=false, walls=true,
    maxDistance=0, infinite=true, cornerBox=false, boxFill=false,
    skeleton=false, headDot=true, weapon=false, ai=false, refreshRate=60,
    boxType="Dynamic", boxSizeX=3.6, boxSizeY=5, boxPadding=1.1,
}
local espColors = {
    box=Color3.fromRGB(20,20,25), boxFill=Color3.fromRGB(30,30,35),
    name=Color3.fromRGB(255,255,255), weapon=Color3.fromRGB(235,235,235), health=Color3.fromRGB(255,255,255),
    distance=Color3.fromRGB(255,255,255), tracer=Color3.fromRGB(0,255,0),
    chams=Color3.fromRGB(0,255,0), skeleton=Color3.fromRGB(0,150,0),
    headDot=Color3.fromRGB(0,255,0),
    visibilityVisible=Color3.fromRGB(120,255,150), visibilityHidden=Color3.fromRGB(255,90,90),
}
local thirdPersonState = {enabled=false, distance=10, lockBody=true, fade=true, fadeSpeed=14, fadeTransparency=0.85}
local itemFinderState = {enabled=false, query="", maxResults=12}
local shotTracerState = {
    enabled=false, style="Tracer 1", texture="Pulse",
    color=Color3.fromRGB(255,50,50), color2=Color3.fromRGB(255,200,50),
    thickness=0.25, lifetime=0.5, textureSpeed=0,
    transparency1=0, transparency2=1,
    segments=10, curve1=0, curve2=0, randomizeCurve=false,
}
local State = {}
do
    local name = "Unknown"
    pcall(function()
        local fn = (type(identifyexecutor) == "function" and identifyexecutor)
            or (type(getexecutorname) == "function" and getexecutorname)
        if fn then
            local ok, v = pcall(fn)
            if ok and type(v) == "string" and v ~= "" then name = v end
        end
    end)
    State.executorName = name
end
State.shotTracerObjects = {}
State.shotTracerHook = nil
local installBulletHook
local streamSyncState = {enabled=false, range=12000, lastRequested={}}
local screenRemovalState = {enabled=false, elements={}, pendingRestore=false, maskConn=nil}
local undergroundState = {enabled=false, held=false, depth=15, timeout=1, method="Classic", using=false}
local thirdPersonOriginal = {min=Player.CameraMinZoomDistance, max=Player.CameraMaxZoomDistance, mode=Player.CameraMode}
local thirdPersonWasOn, thirdPersonFade = false, 0
local thirdPersonFadeParts, thirdPersonFadeCharacter, thirdPersonFadeRefresh = {}, nil, 0
local itemFinderGui, itemFinderFrame, itemFinderText
local thirdPersonPartOriginals = setmetatable({}, {__mode="k"})
local espHealthColors = {
    top=Color3.fromRGB(0,255,0), bottom=Color3.fromRGB(0,100,0),
}
local chamsState = {
    material="Neon", materialOn=false, fillTransparency=0.78,
    outline=false, outlineColor=Color3.fromRGB(255,255,255),
    outlineTransparency=0.35, rainbow=false, pulse=false, strobe=false,
    saturation=1, intensity=0.5,
}
local chamsOriginals = setmetatable({}, {__mode="k"})

local aimState = {
    silentAim=false, instaHit=false, magicBullet=false, magicAuto=false, syncMagic=false, triggerbot=false,
    manipulatedDirection=nil,
    triggerFovSource="Silent Aim FOV", triggerDelay=50, triggerChance=100,
    triggerTargetAI=true, triggerTarget=nil, triggerReadyAt=0,
    triggerHeld=false, triggerPressAt=0,
    fov=200, target=nil, targetPart=nil, targetName=nil, showTargetName=true, lastScan=0,
    aimPriority="Head First", blacklist=nil, blacklistEnabled=true,
    lmbHeld=false, firing=false, lastShot=0,
    eye=nil, manipOrigin=nil, internal=false, fle=nil, fleChecked=false,
    targetHeli=false,
    targetAI=true,

    hitchance=100,
    wallbang=true,
    emulated_tick=5,
    fired_projectiles={},
    fovColor=Color3.fromRGB(0,220,110),
    tracerEnabled=true,
    tracerColor=Color3.fromRGB(0,220,110),
    tracerThickness=1,
    tracerOrigin="Bottom",
    tracerOpacity=1,
    tracerOutline=false,
    tracerOutlineColor=Color3.fromRGB(0,0,0),
}

local MELEE_SKINS_GLOBAL = {
    "None","Karambit","ButterflyKnife","IceAxe","PlasmaNinjato",
    "Greatsword","Longsword","Cutlass","IceDagger","M9Fade","M9XR7",
    "AnarchyTomahawk","FlipKnifeShark","Kukri","Scythe","GoldenDV2",
}

local detectState = {
    mod=false, cheater=false,
    modAlerted={}, cheaterAlerted={},
    modList={},
}
local soundState = {
    hitEnabled=false, hitId="rbxassetid://6545967532", hitVol=1,
    gunEnabled=false, gunId="rbxassetid://3060494212", gunVol=1,
}
local HITSOUND_IDS = {
    ["never lose"]="rbxassetid://6545967532",
    ["rust"]="rbxassetid://5043539486",
    ["cs go"]="rbxassetid://7254985723",
    ["bameware"]="rbxassetid://6607339542",
    ["skeet"]="rbxassetid://4817809188",
    ["osu"]="rbxassetid://7149255551",
    ["minecraft bow"]="rbxassetid://3442683707",
    ["oof"]="rbxassetid://3060494212",
    ["moan"]="rbxassetid://7606020137",
}
local GUNSOUND_IDS = {
    ["minecraft bow"]="rbxassetid://3442683707",
    ["oof"]="rbxassetid://3060494212",
    ["fart"]="rbxassetid://3068648094",
    ["hee hee"]="rbxassetid://3048623108",
    ["this is sparta"]="rbxassetid://130781067",
    ["godzilla"]="rbxassetid://130783046",
    ["roger that"]="rbxassetid://135308704",
}
local HITSOUND_DETECT = {
    ["rbxassetid://4585382589"]=true,
    ["rbxassetid://4585351098"]=true,
    ["rbxassetid://4585382046"]=true,
    ["rbxassetid://4585364605"]=true,
}
local MOAN_ID = "rbxassetid://7606020137"

local LegitAim = {
    enabled=false, aimPart="Head", fov=140, smoothness=10,
    prediction=0.12, wallCheck=true, teamCheck=true, sticky=false,
    lastScan=0, target=nil, targetPart=nil,
}

local gunModState = {
    removeMuzzle=false, removeSprintAnimation=false,
    noRecoil=false, noBob=false, noSpread=false, noDrop=false, noDrag=false,
    instantAim=false, instantEquip=false,
    unlockFiremodes=false, rapidFire=false, rapidFireDelay=0.05,
    forceAuto=false, multibullet=false, multibulletCount=3,
    ignoreWater=false, removeWeight=false,
    noBolt=false, removeSandboxing=false, removeRechamber=false,
    meleeReach=false, meleeReachDist=10,
    removeAimRestrictions=false, sprintShoot=false, instantLean=false,
    noSway=false, noObstruct=false,
}

local worldFx = {
    fullBright=false, noFog=false, removeGrass=false, potato=false,
    timeOn=false, timeVal=12,
    ambientOn=false, ambientA=Color3.new(1,1,1), ambientB=Color3.new(1,1,1),
    noLeaves=false, noFoliage=false, noTrees=false, noClouds=false,
    skyOn=false, skyPreset=1, skyRotX=0, skyRotZ=0,
    fogOn=false, fogStart=0, fogEnd=1000, fogColor=Color3.fromRGB(170,185,205),
    atmoOn=false, atmoDensity=20, atmoHaze=0, atmoGlare=0, atmoOffset=0,
    atmoColor=Color3.fromRGB(200,210,230), atmoDecay=Color3.fromRGB(100,110,130),
    cloudOn=false, cloudCover=50, cloudDensity=50, cloudColor=Color3.new(1,1,1),
    bloomOn=false, bloomIntensity=0.5, bloomSize=24, bloomThreshold=1,
    gradeOn=false, gradeTint=Color3.new(1,1,1), gradeSat=0, gradeContrast=0, gradeBrightness=0,
    terrainOn=false, terrainMat=1, terrainColor=Color3.fromRGB(115,115,115),
}

local WORLD_SKY_PRESETS = {
    {name="Purple Nebula",ids={"159454299","159454296","159454293","159454286","159454300","159454288"}},
    {name="Vaporwave",   ids={"600832720","600833821","600835177","600833341","600834603","600835727"}},
    {name="Deep Space",  ids={"265805434","265805423","265805445","265805466","265805481","265805502"}},
    {name="Night Sky",   ids={"12064107","12064152","12064121","12064131","12064115","12064143"}},
    {name="Sunset",      ids={"924373456","924373468","924373479","924373497","924373508","924373523"}},
    {name="Blood Moon",  ids={"401664839","401664861","401664883","401664901","401664916","401664936"}},
}
local WORLD_TERRAIN_MATERIALS = {
    "Grass","Ground","Sand","Rock","Slate","Snow","Mud","Basalt","CrackedLava",
    "Glacier","Ice","LeafyGrass","Limestone","Pavement","Salt","Sandstone","Silt","WoodPlanks",
}

local movementState = {
    flyEnabled=false, flySpeed=10, flyVSpeed=10,
    speedEnabled=false, speedValue=20,
    noFallEnabled=false,
    explodeMinesMode="All",
    extendReach=false,
    peekBlink=false,
    waterMode="Off",
    fovEnabled=false, fovValue=70,
    zoomEnabled=false, zoomFov=40, zoomKey="None",
    _zoomActive=false, _defaultFov=nil,
}

local ACBypassEnabled = true
local reportState = { count=0, known=false, alerts=false }
local skinState = { meleeSkin="None", weaponItem=nil, weaponSkin=nil }
local hideChatName = false

local espGui = Instance.new("ScreenGui")
espGui.Name = "OmniESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 9990
espGui.Parent = Player:WaitForChild("PlayerGui")

local espLayer = Instance.new("Frame")
espLayer.Name = "ESPLayer"
espLayer.Parent = espGui
espLayer.Size = UDim2.fromScale(1,1)
espLayer.BackgroundTransparency = 1
espLayer.BorderSizePixel = 0
espLayer.Visible = false

local aimFovRing = Instance.new("Frame")
aimFovRing.Name = "AimFOV"
aimFovRing.Parent = espGui
aimFovRing.AnchorPoint = Vector2.new(0.5,0.5)
aimFovRing.BackgroundTransparency = 1
aimFovRing.BorderSizePixel = 0
aimFovRing.Visible = false
local aimFovStroke = Instance.new("UIStroke")
aimFovStroke.Parent = aimFovRing
aimFovStroke.Thickness = 1
aimFovStroke.Color = Color3.fromRGB(0,220,110)
local aimFovCorner = Instance.new("UICorner")
aimFovCorner.CornerRadius = UDim.new(1,0)
aimFovCorner.Parent = aimFovRing

local aimTracerOutline = Instance.new("Frame")
aimTracerOutline.Name = "AimTracerOutline"
aimTracerOutline.Parent = espGui
aimTracerOutline.AnchorPoint = Vector2.new(0.5,0.5)
aimTracerOutline.BorderSizePixel = 0
aimTracerOutline.ZIndex = 2
aimTracerOutline.Visible = false
local aimTracerLine = Instance.new("Frame")
aimTracerLine.Name = "AimTracer"
aimTracerLine.Parent = espGui
aimTracerLine.AnchorPoint = Vector2.new(0.5,0.5)
aimTracerLine.BorderSizePixel = 0
aimTracerLine.ZIndex = 3
aimTracerLine.Visible = false

local function hideAimTracer()
    aimTracerLine.Visible = false
    aimTracerOutline.Visible = false
end

local function updateAimTracer()
    local cam = workspace.CurrentCamera
    local part = aimState.targetPart
    if not aimState.tracerEnabled or not cam or not part or not part.Parent then
        hideAimTracer()
        return
    end
    local vp = cam.ViewportSize
    local c = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local screen, on = cam:WorldToViewportPoint(part.Position)
    local z = screen.Z
    local to = Vector2.new(screen.X, screen.Y)
    if not on or z <= 0 then
        local d = to - c
        if z <= 0 then d = -d end
        if d.Magnitude <= 0.001 then
            hideAimTracer()
            return
        end
        local u = d.Unit
        local k = math.min((vp.X * 0.5 - 20) / math.max(math.abs(u.X), 0.001),
                           (vp.Y * 0.5 - 20) / math.max(math.abs(u.Y), 0.001))
        to = c + u * k
    end
    local origin = aimState.tracerOrigin or "Bottom"
    local from
    if origin == "Mouse" then
        local m = Player:GetMouse()
        from = Vector2.new(m.X, m.Y)
    elseif origin == "Crosshair" then
        from = c
    else
        from = Vector2.new(vp.X * 0.5, vp.Y)
    end
    local dx, dy = to.X - from.X, to.Y - from.Y
    local len = math.sqrt(dx*dx + dy*dy)
    if len < 1 then
        hideAimTracer()
        return
    end
    local th = math.clamp(tonumber(aimState.tracerThickness) or 1, 0.5, 8)
    local op = math.clamp(tonumber(aimState.tracerOpacity) or 1, 0.1, 1)
    local pos = UDim2.fromOffset((from.X + to.X) * 0.5, (from.Y + to.Y) * 0.5)
    local rot = math.deg(math.atan2(dy, dx))
    aimTracerLine.Position = pos
    aimTracerLine.Size = UDim2.fromOffset(len, th)
    aimTracerLine.Rotation = rot
    aimTracerLine.BackgroundColor3 = aimState.tracerColor
    aimTracerLine.BackgroundTransparency = 1 - op
    aimTracerLine.Visible = true
    aimTracerOutline.Position = pos
    aimTracerOutline.Size = UDim2.fromOffset(len, th + 2)
    aimTracerOutline.Rotation = rot
    aimTracerOutline.BackgroundColor3 = aimState.tracerOutlineColor
    aimTracerOutline.BackgroundTransparency = 1 - op
    aimTracerOutline.Visible = aimState.tracerOutline
end

local aimNameGui, aimNameLabel
local function ensureAimNameGui()
    if aimNameGui then return aimNameGui end
    local g = Instance.new("BillboardGui")
    g.Name = "OmniAimTargetName"
    g.Size = UDim2.fromOffset(220, 26)
    g.StudsOffset = Vector3.new(0, 1.1, 0)
    g.AlwaysOnTop = true
    g.MaxDistance = 1500
    g.LightInfluence = 0
    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 15
    l.TextColor3 = Color3.fromRGB(0, 220, 110)
    l.TextStrokeTransparency = 0.35
    l.Text = ""
    l.Parent = g
    aimNameGui, aimNameLabel = g, l
    return g
end

local function hideAimTargetLine()
    if aimNameGui then aimNameGui.Enabled = false end
end

local function updateAimTargetLine()
    local target = aimState.targetPart
    if not aimState.showTargetName or not target or not target.Parent then
        hideAimTargetLine()
        return
    end
    local g = ensureAimNameGui()
    aimNameLabel.Text = aimState.targetName or target.Name
    aimNameLabel.TextColor3 = aimState.tracerColor
    if g.Parent ~= target then g.Parent = target end
    g.Enabled = true
end

local espEntries = {}

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "OmniHUD"
HudGui.ResetOnSpawn = false
HudGui.IgnoreGuiInset = true
HudGui.DisplayOrder = 10001
HudGui.Parent = Player:WaitForChild("PlayerGui")

local watermarkEnabled = true
local watermarkFrames = 0
local watermarkTick = os.clock()
local watermarkFps = 0
local watermarkGui, watermarkFrame, watermarkLabel
local watermarkDrag = {active=false, start=nil, origin=nil}

local watermarkOutline, watermarkAccent, watermarkBg
local function themeColor3(key, fallback)
    local c = Library and Library[key]
    if typeof(c) == "Color3" then return c end
    return fallback
end
local function colorToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end
local function applyWatermarkTheme()
    if not watermarkGui or not watermarkGui.Parent then return themeColor3("AccentColor", Color3.fromRGB(0, 220, 110)), themeColor3("FontColor", Color3.fromRGB(220,220,220)) end
    local accent = themeColor3("AccentColor", Color3.fromRGB(0, 220, 110))
    local main = themeColor3("MainColor", Color3.fromRGB(30, 30, 30))
    local bg = themeColor3("BackgroundColor", Color3.fromRGB(20, 20, 20))
    local outlineC = themeColor3("OutlineColor", Color3.fromRGB(50, 50, 50))
    local fontC = themeColor3("FontColor", Color3.fromRGB(220, 220, 220))
    if watermarkOutline then
        watermarkOutline.BackgroundColor3 = outlineC
        local g = watermarkOutline:FindFirstChildOfClass("UIGradient")
        if g then
            g.Color = ColorSequence.new(accent, Color3.new(
                math.clamp(accent.R * 0.55, 0, 1),
                math.clamp(accent.G * 0.55, 0, 1),
                math.clamp(accent.B * 0.55, 0, 1)
            ))
        end
    end
    if watermarkAccent then
        watermarkAccent.BackgroundColor3 = accent
        local g = watermarkAccent:FindFirstChildOfClass("UIGradient")
        if g then
            g.Color = ColorSequence.new(accent, Color3.new(
                math.clamp(accent.R * 0.65, 0, 1),
                math.clamp(accent.G * 0.65, 0, 1),
                math.clamp(accent.B * 0.65, 0, 1)
            ))
        end
    end
    if watermarkBg then
        watermarkBg.BackgroundColor3 = main
        local g = watermarkBg:FindFirstChildOfClass("UIGradient")
        if g then
            g.Color = ColorSequence.new(main, bg)
        end
    end
    if watermarkLabel then
        watermarkLabel.TextColor3 = fontC
        if Library and Library.Font then
            pcall(function() watermarkLabel.FontFace = Library.Font end)
            pcall(function() watermarkLabel.Font = Enum.Font.Code end)
        end
    end
    return accent, fontC
end

local function ensureMedalwareWatermark()
    if watermarkGui and watermarkGui.Parent then
        watermarkGui.Enabled = true
        if watermarkFrame then watermarkFrame.Visible = true end
        applyWatermarkTheme()
        return
    end
    local host = (gethui and gethui()) or CoreGui
    local old = host:FindFirstChild("OmniWatermark") or host:FindFirstChild("MedalwareWatermark")
    if old then old:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "OmniWatermark"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10050
    gui.Parent = host
    local frame = Instance.new("Frame")
    frame.Name = "WatermarkRoot"
    frame.AnchorPoint = Vector2.new(1,0)
    frame.Position = UDim2.new(1,-14,0,10)
    frame.Size = UDim2.fromOffset(280,24)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    local outline = Instance.new("Frame")
    outline.Name = "WatermarkOutline"
    outline.Size = UDim2.fromScale(1,1)
    outline.BorderSizePixel = 0
    outline.BackgroundColor3 = Color3.fromRGB(50,50,50)
    outline.Active = true
    outline.ZIndex = 1
    outline.Parent = frame
    local outlineGradient = Instance.new("UIGradient")
    outlineGradient.Rotation = 45
    outlineGradient.Parent = outline
    local background = Instance.new("Frame")
    background.Name = "WatermarkBackground"
    background.Position = UDim2.fromOffset(1,1)
    background.Size = UDim2.new(1,-2,1,-2)
    background.BorderSizePixel = 0
    background.BackgroundColor3 = Color3.fromRGB(30,30,30)
    background.Active = true
    background.ZIndex = 2
    background.Parent = frame
    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Rotation = 90
    backgroundGradient.Parent = background
    local accentLine = Instance.new("Frame")
    accentLine.Name = "WatermarkAccent"
    accentLine.Position = UDim2.fromOffset(0,0)
    accentLine.Size = UDim2.new(1,0,0,2)
    accentLine.BorderSizePixel = 0
    accentLine.BackgroundColor3 = Color3.fromRGB(0,220,110)
    accentLine.Active = true
    accentLine.ZIndex = 3
    accentLine.Parent = background
    local accentGradient = Instance.new("UIGradient")
    accentGradient.Rotation = 0
    accentGradient.Parent = accentLine
    local label = Instance.new("TextLabel")
    label.Name = "WatermarkText"
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(8,2)
    label.Size = UDim2.new(1,-16,1,-2)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0
    label.RichText = true
    label.TextWrapped = false
    label.Active = true
    label.ZIndex = 4
    label.Text = '<font color="#FFFFFF">Omni Project delta</font> <font color="#D2D2D2">(' .. tostring(State.executorName or "Unknown") .. ')</font> <font color="#D2D2D2">|</font> FPS: 0 <font color="#D2D2D2">|</font> Ping: 0ms'
    label.Parent = frame
    watermarkOutline = outline
    watermarkAccent = accentLine
    watermarkBg = background
    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        watermarkDrag.active = true
        watermarkDrag.start = input.Position
        watermarkDrag.origin = frame.Position
    end
    for _, obj in ipairs({frame, outline, background, label}) do
        conn(obj.InputBegan, beginDrag)
    end
    conn(UIS.InputChanged, function(input)
        if not watermarkDrag.active then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - watermarkDrag.start
            local o = watermarkDrag.origin
            frame.Position = UDim2.new(o.X.Scale, o.X.Offset + delta.X, o.Y.Scale, o.Y.Offset + delta.Y)
        end
    end)
    conn(UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            watermarkDrag.active = false
        end
    end)
    watermarkGui = gui
    watermarkFrame = frame
    watermarkLabel = label
end

local function updateMedalwareWatermark(fps)
    if not watermarkEnabled then
        if watermarkGui then watermarkGui.Enabled = false end
        return
    end
    ensureMedalwareWatermark()
    if not (watermarkGui and watermarkFrame and watermarkLabel) then return end
    watermarkGui.Enabled = true
    watermarkFrame.Visible = true
    local ping = 0
    pcall(function()
        ping = math.floor(Player:GetNetworkPing() * 1000 + 0.5)
    end)
    local date = os.date("%Y-%m-%d")
    local clock = os.date("%H:%M:%S")
    local accent, fontC = applyWatermarkTheme()
    local accentHex = colorToHex(accent)
    local muted = colorToHex(Color3.fromRGB(180,180,180))
    local exec = tostring(State.executorName or "Unknown"):gsub("[&<>]", { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;" })
    local text = string.format(
        '<font color="%s">Omni Project delta</font> <font color="%s">(%s)</font> <font color="%s">|</font> FPS: %s <font color="%s">|</font> Ping: %dms <font color="%s">|</font> %s %s',
        accentHex, muted, exec, muted, tostring(fps or 0), muted, ping, muted, date, clock
    )
    if watermarkLabel.Text ~= text then watermarkLabel.Text = text end
    local width = math.clamp(watermarkLabel.TextBounds.X + 22, 220, 900)
    local target = UDim2.fromOffset(width, 24)
    if watermarkFrame.Size ~= target then watermarkFrame.Size = target end
end

conn(RunService.RenderStepped, function()
    watermarkFrames = watermarkFrames + 1
    local now = os.clock()
    if now - watermarkTick >= 0.5 then
        watermarkFps = math.floor(watermarkFrames / (now - watermarkTick) + 0.5)
        watermarkFrames = 0
        watermarkTick = now
        pcall(updateMedalwareWatermark, watermarkFps)
    end
end)

local reportDing = Instance.new("Sound")
reportDing.SoundId = "rbxasset://sounds/electronicpingshort.wav"
reportDing.Volume = 0.55; reportDing.PlaybackSpeed = 1.1
reportDing.Parent = SoundService

local reportPopup = Instance.new("Frame")
reportPopup.AnchorPoint = Vector2.new(0.5,0)
reportPopup.Position = UDim2.new(0.5,0,0,46)
reportPopup.Size = UDim2.fromOffset(340,56)
reportPopup.BackgroundColor3 = Color3.fromRGB(30,30,30)
reportPopup.BackgroundTransparency = 0.05
reportPopup.BorderSizePixel = 0
reportPopup.Visible = false; reportPopup.ZIndex = 20
reportPopup.Parent = HudGui
Instance.new("UICorner",reportPopup).CornerRadius = UDim.new(0,8)
local rpStroke = Instance.new("UIStroke",reportPopup)
rpStroke.Color = Color3.fromRGB(255,64,72); rpStroke.Thickness = 1.5

local rpTitle = Instance.new("TextLabel",reportPopup)
rpTitle.Position = UDim2.fromOffset(0,7); rpTitle.Size = UDim2.new(1,0,0,18)
rpTitle.BackgroundTransparency = 1; rpTitle.Text = "YOU HAVE BEEN REPORTED"
rpTitle.TextColor3 = Color3.fromRGB(255,96,104); rpTitle.Font = Enum.Font.GothamBold
rpTitle.TextSize = 13; rpTitle.ZIndex = 21

local rpBody = Instance.new("TextLabel",reportPopup)
rpBody.Position = UDim2.fromOffset(0,27); rpBody.Size = UDim2.new(1,0,0,20)
rpBody.BackgroundTransparency = 1; rpBody.Font = Enum.Font.Code
rpBody.TextColor3 = Color3.fromRGB(238,238,246); rpBody.TextSize = 12; rpBody.ZIndex = 21

local reportCounterLabel = Instance.new("TextLabel",HudGui)
reportCounterLabel.Position = UDim2.new(0,16,1,-46)
reportCounterLabel.Size = UDim2.fromOffset(150,28)
reportCounterLabel.BackgroundColor3 = Color3.fromRGB(22,8,12)
reportCounterLabel.BackgroundTransparency = 0.1; reportCounterLabel.BorderSizePixel = 0
reportCounterLabel.Text = "REPORTS: 0"; reportCounterLabel.TextColor3 = Color3.fromRGB(255,80,90)
reportCounterLabel.Font = Enum.Font.Code; reportCounterLabel.TextSize = 12
reportCounterLabel.Visible = false; reportCounterLabel.ZIndex = 20
Instance.new("UICorner",reportCounterLabel).CornerRadius = UDim.new(0,6)

local reportPopupToken = 0
local function showReportPopup(delta, total)
    reportPopupToken = reportPopupToken+1
    local token = reportPopupToken
    rpBody.Text = string.format("+%d report%s | %d total",delta,delta==1 and "" or "s",total)
    reportPopup.Visible = true
    reportPopup.BackgroundTransparency = 0.05; rpStroke.Transparency = 0
    rpTitle.TextTransparency = 0; rpBody.TextTransparency = 0
    task.delay(4.2, function()
        if token ~= reportPopupToken then return end
        pcall(function()
            TweenService:Create(reportPopup,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
            TweenService:Create(rpStroke,TweenInfo.new(0.4),{Transparency=1}):Play()
            TweenService:Create(rpTitle,TweenInfo.new(0.4),{TextTransparency=1}):Play()
            TweenService:Create(rpBody,TweenInfo.new(0.4),{TextTransparency=1}):Play()
        end)
        task.delay(0.45, function() if token==reportPopupToken then reportPopup.Visible=false end end)
    end)
end

local function readReportCount()
    local count = 0
    pcall(function()
        local pf = ReplicatedStorage:FindFirstChild("Players")
        local md = pf and pf:FindFirstChild(Player.Name)
        local st = md and md:FindFirstChild("Status")
        local uac = st and st:FindFirstChild("UAC")
        local rep = uac and uac:FindFirstChild("Reports")
        if not rep then return end
        local total = rep:GetAttribute("Count")
        if type(total)=="number" then count=total
        else
            for _,v in pairs(rep:GetAttributes()) do
                if type(v)=="number" then count=count+v end
            end
        end
    end)
    return math.max(0,math.floor(count))
end

task.spawn(function()
    local known = false
    while HudGui.Parent do
        local current = readReportCount()
        if known and current>reportState.count and reportState.alerts then
            showReportPopup(current-reportState.count,current)
            pcall(function() reportDing.TimePosition=0; reportDing:Play() end)
        end
        reportState.count = current
        reportState.known = true; known = true
        reportCounterLabel.Visible = reportState.alerts
        if reportState.alerts then
            reportCounterLabel.Text = "REPORTS: "..tostring(current)
        end
        task.wait(0.5)
    end
end)

local chatOriginalText = setmetatable({},{__mode="k"})
local function scrubChatWindow()
    local names = {Player.Name}
    if Player.DisplayName~=Player.Name then names[2]=Player.DisplayName end
    local playerGui = Player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local function scan(inst, depth)
        if depth>8 then return end
        for _,child in ipairs(inst:GetChildren()) do
            if child.Name=="ChatWindow" then
                for _,line in ipairs(child:GetChildren()) do
                    local msg = line:IsA("TextLabel") and line:FindFirstChild("Message")
                    if msg and msg:IsA("TextLabel") then
                        local orig = chatOriginalText[msg]
                        if hideChatName then
                            if not orig then chatOriginalText[msg]=msg.Text; orig=msg.Text end
                            local replaced = orig
                            for _,n in ipairs(names) do
                                replaced = replaced:gsub(n:gsub("%p","%%%0"),"Hidden")
                            end
                            if replaced~=msg.Text then msg.Text=replaced end
                        elseif orig then
                            msg.Text=orig; chatOriginalText[msg]=nil
                        end
                    end
                end
            elseif child:IsA("GuiObject") or child:IsA("ScreenGui") or child:IsA("Folder") then
                scan(child,depth+1)
            end
        end
    end
    scan(playerGui,0)
end
task.spawn(function()
    while HudGui.Parent do pcall(scrubChatWindow); task.wait(0.5) end
end)

local VMChams = (function()
    local m = {
        armEnabled=false, gunEnabled=false,
        armColor=Color3.fromRGB(255,255,255), gunColor=Color3.fromRGB(255,255,255),
        armMaterial="SmoothPlastic", gunMaterial="SmoothPlastic",
        armTransparency=0, gunTransparency=0,
        model=nil,
    }
    local originals = setmetatable({}, {__mode="k"})
    local function mat(name)
        local ok,v = pcall(function() return Enum.Material[name] end)
        return ok and v or Enum.Material.SmoothPlastic
    end
    local function paint(part, color, material, transparency)
        if originals[part] == nil then
            originals[part] = {color=part.Color, material=part.Material, transparency=part.Transparency}
        end
        pcall(function()
            part.Color = color
            part.Material = mat(material)
            part.Transparency = transparency or 0
            local sa = part:FindFirstChildOfClass("SurfaceAppearance")
            if sa then sa:Destroy() end
        end)
    end
    local function revert(part)
        local o = originals[part]
        if not o then return end
        pcall(function()
            part.Color = o.color
            part.Material = o.material
            part.Transparency = o.transparency
        end)
        originals[part] = nil
    end
    function m.Apply()
        local vm = m.model
        if not vm or not vm.Parent then return end
        local item = vm:FindFirstChild("Item")
        local touched = setmetatable({}, {__mode="k"})
        if item and m.gunEnabled then
            for _, p in ipairs(item:GetDescendants()) do
                if (p:IsA("MeshPart") or p:IsA("BasePart"))
                    and p.Name ~= "Muzzle" and p.Name ~= "SightMark" and p.Name ~= "AimPart" then
                    touched[p] = true
                    paint(p, m.gunColor, m.gunMaterial, m.gunTransparency)
                end
            end
        end
        if m.armEnabled then
            for _, p in ipairs(vm:GetDescendants()) do
                if (p:IsA("MeshPart") or p:IsA("BasePart")) and not (item and p:IsDescendantOf(item)) then
                    local n = string.lower(p.Name)
                    if string.find(n, "hand", 1, true) or string.find(n, "arm", 1, true)
                        or string.find(n, "glove", 1, true) then
                        touched[p] = true
                        paint(p, m.armColor, m.armMaterial, m.armTransparency)
                    end
                end
            end
        end
        for part in pairs(originals) do
            if not part.Parent then
                originals[part] = nil
            elseif not touched[part] then
                revert(part)
            end
        end
    end
    function m.Watch(model)
        m.model = model
        task.defer(function() if m.model == model then m.Apply() end end)
    end
    function m.Refresh() m.Apply() end
    function m.Reset()
        for part in pairs(originals) do revert(part) end
        m.model = nil
    end
    return m
end)()

do
    local cam = workspace.CurrentCamera
    local ex = cam and (cam:FindFirstChild("ViewModel") or cam:FindFirstChildOfClass("Model"))
    if ex then VMChams.Watch(ex) end
    if cam then
        conn(cam.ChildAdded, function(child)
            if child:IsA("Model") then VMChams.Watch(child) end
        end)
    end
end

local viewmodelState = {
    x=0, y=0, z=0, offsetEnabled=false,
    noArms=false, unlockSkins=false, removeClothing=false,
    highlight=false,
    fillColor=Color3.fromRGB(255,98,127), fillTransparency=0,
    outlineColor=Color3.fromRGB(255,98,127), outlineTransparency=0,
    fillMult=1, outlineMult=1,
}
local vmJointOriginals = setmetatable({}, {__mode="k"})
local vmArmOriginals = setmetatable({}, {__mode="k"})
local vmClothingOriginals = setmetatable({}, {__mode="k"})
local vmHighlight = nil
local unlockSkinHookOriginal = nil
local unlockSkinLibrary = nil
pcall(function()
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local module = modules and modules:FindFirstChild("FunctionLibraryExtension")
    if module then
        local lib = require(module)
        if type(lib.IsItemAccessibleToPlayer) == "function" then
            unlockSkinLibrary = lib
            unlockSkinHookOriginal = lib.IsItemAccessibleToPlayer
            lib.IsItemAccessibleToPlayer = function(...)
                if viewmodelState.unlockSkins then return true end
                return unlockSkinHookOriginal(...)
            end
        end
    end
end)

local function ensureVmHighlight(vm)
    if vmHighlight and vmHighlight.Parent then return vmHighlight end
    local existing = vm:FindFirstChild("OmniVMHighlight")
    if existing and existing:IsA("Highlight") then
        vmHighlight = existing
        return existing
    end
    local h = Instance.new("Highlight")
    h.Name = "OmniVMHighlight"
    h.Adornee = vm
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = vm
    vmHighlight = h
    return h
end

local function partIsClothing(part, vm)
    local cur = part
    while cur and cur ~= vm do
        local it = cur:GetAttribute("ItemType")
        if it == "Shirt" or it == "Gloves" then return true end
        local n = string.lower(cur.Name or "")
        if n == "shirt" or n == "gloves" then return true end
        cur = cur.Parent
    end
    return false
end

local function applyViewmodelOptions()
    local cam = workspace.CurrentCamera
    local vm = cam and (cam:FindFirstChild("ViewModel") or cam:FindFirstChildOfClass("Model"))
    if not vm then return end

    local root = vm:FindFirstChild("HumanoidRootPart")
    if root then
        local offset = Vector3.zero
        if viewmodelState.offsetEnabled then
            offset = Vector3.new(viewmodelState.x/10, viewmodelState.y/10, viewmodelState.z/10)
        end
        for _, joint in ipairs(root:GetChildren()) do
            if joint:IsA("Motor6D") then
                if not vmJointOriginals[joint] then vmJointOriginals[joint] = joint.C0 end
                local target = vmJointOriginals[joint] + offset
                if joint.C0 ~= target then joint.C0 = target end
            end
        end
    end

    for _, part in ipairs(vm:GetDescendants()) do
        if part:IsA("BasePart") then
            local n = string.lower(part.Name)
            if string.find(n, "hand", 1, true) or string.find(n, "arm", 1, true) then
                if vmArmOriginals[part] == nil then
                    vmArmOriginals[part] = part.LocalTransparencyModifier
                end
                local target = viewmodelState.noArms and 1 or vmArmOriginals[part]
                if part.LocalTransparencyModifier ~= target then
                    part.LocalTransparencyModifier = target
                end
            end
            if viewmodelState.removeClothing and partIsClothing(part, vm) then
                if vmClothingOriginals[part] == nil then
                    vmClothingOriginals[part] = part.LocalTransparencyModifier
                end
                if part.LocalTransparencyModifier ~= 1 then
                    part.LocalTransparencyModifier = 1
                end
            elseif vmClothingOriginals[part] ~= nil then
                part.LocalTransparencyModifier = vmClothingOriginals[part]
                vmClothingOriginals[part] = nil
            end
        end
    end

    if viewmodelState.highlight then
        local h = ensureVmHighlight(vm)
        h.FillColor = viewmodelState.fillColor
        h.FillTransparency = math.clamp(viewmodelState.fillTransparency * viewmodelState.fillMult, 0, 1)
        h.OutlineColor = viewmodelState.outlineColor
        h.OutlineTransparency = math.clamp(viewmodelState.outlineTransparency * viewmodelState.outlineMult, 0, 1)
    elseif vmHighlight then
        pcall(function() vmHighlight:Destroy() end)
        vmHighlight = nil
    end
end
conn(RunService.RenderStepped, function() pcall(applyViewmodelOptions) end)
conn(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    local cam = workspace.CurrentCamera
    if cam then
        conn(cam.ChildAdded, function(child)
            if child:IsA("Model") then
                task.defer(applyViewmodelOptions)
                VMChams.Watch(child)
            end
        end)
    end
end)

local extEspState = {
    corpses=false, ai=false, bosses=false, extractions=false,
    droppedItems=false, radar=false, radarRange=200,
}
local extEspEntries = {}

local radarFrame = Instance.new("Frame")
radarFrame.Name = "OmniRadar"
radarFrame.Parent = espGui
radarFrame.AnchorPoint = Vector2.new(1,0)
radarFrame.Position = UDim2.new(1,-22,0,86)
radarFrame.Size = UDim2.fromOffset(156,156)
radarFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
radarFrame.BackgroundTransparency = 0.2
radarFrame.BorderSizePixel = 0; radarFrame.Visible = false
Instance.new("UICorner",radarFrame).CornerRadius = UDim.new(1,0)
local radarStroke = Instance.new("UIStroke",radarFrame)
radarStroke.Color = Color3.fromRGB(0,220,110); radarStroke.Transparency = 0.25
local radarCenter = Instance.new("Frame",radarFrame)
radarCenter.AnchorPoint = Vector2.new(0.5,0.5)
radarCenter.Position = UDim2.fromScale(0.5,0.5)
radarCenter.Size = UDim2.fromOffset(5,5)
radarCenter.BackgroundColor3 = Color3.fromRGB(255,255,255)
radarCenter.BorderSizePixel = 0
local radarDots = {}

local function radarDotFor(plr)
    if radarDots[plr] then return radarDots[plr] end
    local dot = Instance.new("Frame",radarFrame)
    dot.AnchorPoint = Vector2.new(0.5,0.5); dot.Size = UDim2.fromOffset(6,6)
    dot.BackgroundColor3 = Color3.fromRGB(255,90,90); dot.BorderSizePixel = 0
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
    radarDots[plr] = dot; return dot
end

conn(RunService.RenderStepped, function()
    radarFrame.Visible = extEspState.radar
    if not extEspState.radar then
        for _,d in pairs(radarDots) do d.Visible=false end; return
    end
    local ch = Player.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local cam = workspace.CurrentCamera
    local yaw = cam and math.atan2(cam.CFrame.LookVector.X,cam.CFrame.LookVector.Z) or 0
    local seen = {}
    for _,other in ipairs(Players:GetPlayers()) do
        if other~=Player then
            local or2 = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
            if or2 then
                local delta = or2.Position - root.Position
                local lx = delta.X*math.cos(yaw)-delta.Z*math.sin(yaw)
                local lz = delta.X*math.sin(yaw)+delta.Z*math.cos(yaw)
                local range = extEspState.radarRange
                local dot = radarDotFor(other)
                dot.Position = UDim2.new(0.5,math.clamp(lx/range*68,-68,68),0.5,math.clamp(lz/range*68,-68,68))
                dot.Visible = delta.Magnitude<=range; seen[other]=true
            end
        end
    end
    for plr,dot in pairs(radarDots) do
        if not seen[plr] then dot.Visible=false end
        if plr.Parent==nil then dot:Destroy(); radarDots[plr]=nil end
    end
end)

local function extEspScan()
    local function makeLabel(model, kind, part)
        local existing = extEspEntries[model]
        if existing then return end
        local gui = Instance.new("BillboardGui")
        gui.AlwaysOnTop = true; gui.Size = UDim2.fromOffset(120,20)
        gui.StudsOffset = Vector3.new(0,2.5,0); gui.Parent = part
        local lbl = Instance.new("TextLabel",gui)
        lbl.Size = UDim2.fromScale(1,1); lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(0,220,110); lbl.Font = Enum.Font.Code
        lbl.TextSize = 11; lbl.TextStrokeTransparency = 0.3
        lbl.Text = kind..": "..model.Name
        local hl = Instance.new("Highlight",gui)
        hl.FillColor = Color3.fromRGB(0,220,110); hl.FillTransparency = 0.7
        hl.OutlineTransparency = 1; hl.Adornee = model
        extEspEntries[model] = {gui=gui,label=lbl,highlight=hl,kind=kind,part=part}
    end

    if extEspState.corpses then
        local dead = workspace:FindFirstChild("DeadPlayers") or workspace:FindFirstChild("Corpses")
        if dead then
            for _,m in ipairs(dead:GetChildren()) do
                if m:IsA("Model") then
                    local p = m:FindFirstChildOfClass("BasePart")
                    if p then makeLabel(m,"Corpse",p) end
                end
            end
        end
    end

    if extEspState.ai then
        local aiZ = workspace:FindFirstChild("AiZones")
        if aiZ then
            for _,zone in ipairs(aiZ:GetChildren()) do
                for _,npc in ipairs(zone:GetChildren()) do
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    local root = npc:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health>0 and root then makeLabel(npc,"AI",root) end
                end
            end
        end
    end

    for model,entry in pairs(extEspEntries) do
        local active = (entry.kind=="Corpse" and extEspState.corpses)
            or (entry.kind=="AI" and extEspState.ai)
        if not model.Parent or not active then
            pcall(function() entry.gui:Destroy() end)
            extEspEntries[model] = nil
        end
    end
end

gg.__OmniExtESP = { state=extEspState, scan=extEspScan }

local vpElapsed = 0
conn(RunService.Heartbeat, function(dt)
    local vs = extEspState
    if vs.corpses or vs.ai then
        vpElapsed = vpElapsed+dt
        if vpElapsed>=1 then vpElapsed=0; pcall(extEspScan) end
    end
end)

local InventoryChecker = (function()
    local invCfg = {
        inv_enabled=false, inv_mode="Text", inv_filter_mode="Off", inv_filter_minval=10000,
        inv_filter_items={}, inv_show_kdr=false, inv_show_value=false, inv_show_reports=false,
        inv_show_team=false, inv_show_hours=false, inv_bodies_enabled=false, ai_inv_enabled=false,
        inv_text_size=12, inv_line_h=15, inv_aim_radius=160, inv_update_rate=10, inv_bg_transparency=0,
        inv_width=370, inv_height=470,
    }
local inv_gui=nil
local inv_root=nil
local inv_text_scroll=nil
local inv_image_scroll=nil
local inv_text_layout=nil
local inv_image_layout=nil
local inv_target_label=nil
local inv_stats_label=nil
local inv_value_label=nil
State.inv_last_target =nil
State.inv_last_kind =nil
State.inv_last_refresh =0
State.inv_last_target_scan =0
local inv_last_pos=UDim2.fromOffset(math.max(0,(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1280)-(invCfg.inv_width or 370)-20),20)
State.inv_pos_save =nil
State.inv_theme =nil
State.inv_item_entries ={}
local function inv_get_icon(name)
    local items=ReplicatedStorage:FindFirstChild("ItemsList")
    local item=items and items:FindFirstChild(name)
    local props=item and item:FindFirstChild("ItemProperties")
    local icon=props and props:FindFirstChild("ItemIcon")
    if icon and icon:IsA("ImageLabel") then return icon.Image end
    if icon and icon:IsA("StringValue") then return icon.Value end
    return ""
end
local function inv_item_info(item)
    local defs=ReplicatedStorage:FindFirstChild("ItemsList")
    local def=defs and defs:FindFirstChild(item.Name)
    local props=def and def:FindFirstChild("ItemProperties")
    local itemType=tostring((props and props:GetAttribute("ItemType")) or item:GetAttribute("ItemType") or "")
    local slot=tostring((props and props:GetAttribute("Slot")) or item:GetAttribute("Slot") or "")
    local price=tonumber((props and props:GetAttribute("Price")) or item:GetAttribute("Price")) or 0
    local amount=tonumber(item:GetAttribute("Amount")) or 1
    return {name=item.Name, type=itemType, slot=slot, price=price, amount=math.max(1,amount), icon=inv_get_icon(item.Name), instance=item}
end
local function inv_filter_pass(info)
    local mode=invCfg.inv_filter_mode or "Off"
    if mode=="Off" then return true end
    local typ=(info.type.." "..info.slot):lower()
    local name=info.name:lower()
    if mode=="Gear Only" then
        for _,key in ipairs({"weapon","armor","attach","ammo","container","clothing","medicine","med","helmet","vest","rig","backpack"}) do
            if typ:find(key,1,true) or name:find(key,1,true) then return true end
        end
        return false
    elseif mode=="Valuables" then
        return info.price >= (invCfg.inv_filter_minval or 0)
    elseif mode=="Custom" then
        local selected=invCfg.inv_filter_items or {}
        return selected[info.name]==true
    end
    return true
end
local function inv_get_target_data(target, kind)
    local playerName
    local model
    if kind=="player" then
        playerName=target.Name
        model=target.Character
    else
        model=target
        playerName=target and target.Name
    end
    local playerDataRoot=ReplicatedStorage:FindFirstChild("Players")
    local playerData=playerName and playerDataRoot and playerDataRoot:FindFirstChild(playerName)
    local inventory=(playerData and playerData:FindFirstChild("Inventory")) or (model and model:FindFirstChild("Inventory"))
    local hotbar=(playerData and playerData:FindFirstChild("Hotbar")) or (model and model:FindFirstChild("Hotbar"))
    return inventory, hotbar, playerData, model
end
local function inv_collect_entries(target, kind)
    local inventory,hotbar,playerData,model=inv_get_target_data(target,kind)
    local entries={}
    local value=0
    local seen=setmetatable({}, {__mode="k"})
    local function add_item(item,group,depth)
        if not item or seen[item] or depth>4 then return end
        seen[item]=true
        local info=inv_item_info(item)
        local childrenInv=item:FindFirstChild("Inventory")
        local attachments=item:FindFirstChild("Attachments")
        local defs=ReplicatedStorage:FindFirstChild("ItemsList")
        local known=defs and defs:FindFirstChild(item.Name)
        if known and inv_filter_pass(info) then
            entries[#entries+1]={group=group,info=info}
            value=value+(info.price*info.amount)
        end
        if attachments then
            for _,att in ipairs(attachments:GetChildren()) do add_item(att,"ATTACHMENTS",depth+1) end
        end
        if childrenInv then
            for _,child in ipairs(childrenInv:GetChildren()) do add_item(child,"LOOT",depth+1) end
        end
        if not known and not childrenInv and not attachments then
            local nested=item:FindFirstChildOfClass("Folder")
            if nested and nested.Name=="Inventory" then
                for _,child in ipairs(nested:GetChildren()) do add_item(child,"LOOT",depth+1) end
            end
        end
    end
    if hotbar then
        for _,item in ipairs(hotbar:GetChildren()) do add_item(item,"HOTBAR",0) end
    end
    if inventory then
        for _,slot in ipairs(inventory:GetChildren()) do
            if slot:FindFirstChild("Inventory") and not (ReplicatedStorage:FindFirstChild("ItemsList") and ReplicatedStorage.ItemsList:FindFirstChild(slot.Name)) then
                for _,item in ipairs(slot.Inventory:GetChildren()) do add_item(item,"LOOT",0) end
            else
                add_item(slot,"GEAR",0)
            end
        end
    end
    return entries,value,playerData,model
end
local function inv_clear_scroller(scroll,layout)
    if not scroll then return end
    for _,child in ipairs(scroll:GetChildren()) do
        if child~=layout and not child:IsA("UIPadding") then child:Destroy() end
    end
end
local function inv_build_gui()
    local existing=CoreGui:FindFirstChild("PD_InvScreen")
    if existing then existing:Destroy() end
    local screen=Instance.new("ScreenGui")
    screen.Name="PD_InvScreen"; screen.ResetOnSpawn=false; screen.IgnoreGuiInset=true
    screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; screen.Enabled=false; screen.Parent=CoreGui
    local rootFrame=Instance.new("Frame",screen)
    rootFrame.Name="InventoryViewerRoot"; rootFrame.Size=UDim2.fromOffset(invCfg.inv_width or 370,invCfg.inv_height or 470); rootFrame.Position=inv_last_pos
    rootFrame.BackgroundColor3=Color3.fromRGB(12,12,16); rootFrame.BackgroundTransparency=math.clamp((invCfg.inv_bg_transparency or 15)/100,0,0.95)
    rootFrame.BorderSizePixel=0; rootFrame.Active=true; rootFrame.ClipsDescendants=true
    local rootCorner=Instance.new("UICorner",rootFrame); rootCorner.CornerRadius=UDim.new(0,7)
    local outline=Instance.new("UIStroke",rootFrame); outline.Color=Color3.fromRGB(58,58,72); outline.Thickness=1
    local header=Instance.new("Frame",rootFrame); header.Name="Header"; header.Size=UDim2.new(1,0,0,28); header.BackgroundColor3=Color3.fromRGB(20,20,27); header.BorderSizePixel=0; header.Active=true
    local accent=Instance.new("Frame",header); accent.Size=UDim2.fromOffset(3,15); accent.Position=UDim2.fromOffset(8,6); accent.BackgroundColor3=Library.AccentColor; accent.BorderSizePixel=0
    local title=Instance.new("TextLabel",header); title.BackgroundTransparency=1; title.Position=UDim2.fromOffset(17,0); title.Size=UDim2.new(1,-25,1,0); title.Text="INVENTORY VIEWER"; title.Font=Enum.Font.GothamSemibold; title.TextSize=11; title.TextColor3=Color3.fromRGB(235,235,245); title.TextXAlignment=Enum.TextXAlignment.Left
    inv_target_label=Instance.new("TextLabel",rootFrame); inv_target_label.BackgroundTransparency=1; inv_target_label.Position=UDim2.fromOffset(10,32); inv_target_label.Size=UDim2.new(1,-20,0,17); inv_target_label.Font=Enum.Font.GothamSemibold; inv_target_label.TextSize=11; inv_target_label.TextColor3=Color3.fromRGB(235,235,245); inv_target_label.TextXAlignment=Enum.TextXAlignment.Left; inv_target_label.Text="Waiting for target..."
    inv_stats_label=Instance.new("TextLabel",rootFrame); inv_stats_label.BackgroundTransparency=1; inv_stats_label.Position=UDim2.fromOffset(10,50); inv_stats_label.Size=UDim2.new(1,-20,0,26); inv_stats_label.Font=Enum.Font.Gotham; inv_stats_label.TextSize=10; inv_stats_label.TextColor3=Color3.fromRGB(155,155,170); inv_stats_label.TextXAlignment=Enum.TextXAlignment.Left; inv_stats_label.TextYAlignment=Enum.TextYAlignment.Top; inv_stats_label.TextWrapped=true; inv_stats_label.Text=""
    inv_value_label=Instance.new("TextLabel",rootFrame); inv_value_label.BackgroundTransparency=1; inv_value_label.Position=UDim2.fromOffset(10,77); inv_value_label.Size=UDim2.new(1,-20,0,15); inv_value_label.Font=Enum.Font.GothamSemibold; inv_value_label.TextSize=10; inv_value_label.TextColor3=Color3.fromRGB(120,220,155); inv_value_label.TextXAlignment=Enum.TextXAlignment.Left; inv_value_label.Text=""
    local divider=Instance.new("Frame",rootFrame); divider.Position=UDim2.fromOffset(8,96); divider.Size=UDim2.new(1,-16,0,1); divider.BackgroundColor3=Color3.fromRGB(50,50,60); divider.BorderSizePixel=0
    local textScroll=Instance.new("ScrollingFrame",rootFrame); textScroll.Name="TextList"; textScroll.Position=UDim2.fromOffset(8,102); textScroll.Size=UDim2.new(1,-16,1,-110); textScroll.BackgroundTransparency=1; textScroll.BorderSizePixel=0; textScroll.ScrollBarThickness=4; textScroll.CanvasSize=UDim2.new(); textScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local listLayout=Instance.new("UIListLayout",textScroll); listLayout.Name="InventoryRowsLayout"; listLayout.SortOrder=Enum.SortOrder.LayoutOrder; listLayout.Padding=UDim.new(0,2)
    local listPadding=Instance.new("UIPadding",textScroll); listPadding.PaddingLeft=UDim.new(0,2); listPadding.PaddingRight=UDim.new(0,2); listPadding.PaddingTop=UDim.new(0,3); listPadding.PaddingBottom=UDim.new(0,3)
    local imageScroll=Instance.new("ScrollingFrame",rootFrame); imageScroll.Name="ImageGrid"; imageScroll.Position=textScroll.Position; imageScroll.Size=textScroll.Size; imageScroll.BackgroundTransparency=1; imageScroll.BorderSizePixel=0; imageScroll.ScrollBarThickness=4; imageScroll.CanvasSize=UDim2.new(); imageScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; imageScroll.Visible=false
    local grid=Instance.new("UIGridLayout",imageScroll); grid.Name="InventoryGridLayout"; grid.CellSize=UDim2.fromOffset(64,72); grid.CellPadding=UDim2.fromOffset(4,4); grid.SortOrder=Enum.SortOrder.LayoutOrder
    local gp=Instance.new("UIPadding",imageScroll); gp.PaddingLeft=UDim.new(0,3); gp.PaddingRight=UDim.new(0,3); gp.PaddingTop=UDim.new(0,3); gp.PaddingBottom=UDim.new(0,3)
    local dragging=false; local dragStart=Vector2.zero; local frameStart=Vector2.zero
    conn(header.InputBegan, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=Vector2.new(input.Position.X,input.Position.Y); frameStart=Vector2.new(rootFrame.Position.X.Offset,rootFrame.Position.Y.Offset)
        end
    end)
    conn(header.InputEnded, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false; inv_last_pos=rootFrame.Position; if State.inv_pos_save then State.inv_pos_save() end end
    end)
    conn(UIS.InputChanged, function(input)
        if not dragging or not screen.Parent then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
        local pos=frameStart+delta
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        pos=Vector2.new(math.clamp(pos.X,0,math.max(0,viewport.X-(invCfg.inv_width or 370))),math.clamp(pos.Y,0,math.max(0,viewport.Y-(invCfg.inv_height or 470))))
        rootFrame.Position=UDim2.fromOffset(pos.X,pos.Y); inv_last_pos=rootFrame.Position
    end)
    local grip=Instance.new("TextButton",rootFrame)
    grip.Name="ResizeGrip"; grip.AnchorPoint=Vector2.new(1,1); grip.Position=UDim2.new(1,-3,1,-3); grip.Size=UDim2.fromOffset(16,16)
    grip.BackgroundColor3=Color3.fromRGB(34,34,42); grip.BorderSizePixel=0; grip.Text=""; grip.AutoButtonColor=false; grip.ZIndex=20
    local gripCorner=Instance.new("UICorner",grip); gripCorner.CornerRadius=UDim.new(0,3)
    for i=1,3 do
        local dot=Instance.new("Frame",grip); dot.BackgroundColor3=Color3.fromRGB(150,150,162); dot.BorderSizePixel=0
        dot.Size=UDim2.fromOffset(3,3); dot.Position=UDim2.new(1,-5-(i-1)*4,1,-5-(i-1)*4); dot.ZIndex=21
    end
    local resizing=false; local resizeStart=Vector2.zero; local sizeStart=Vector2.zero
    conn(grip.InputBegan, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            resizing=true; resizeStart=Vector2.new(input.Position.X,input.Position.Y)
            sizeStart=Vector2.new(invCfg.inv_width or 370,invCfg.inv_height or 470)
        end
    end)
    conn(UIS.InputChanged, function(input)
        if not resizing or not screen.Parent then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local delta=Vector2.new(input.Position.X,input.Position.Y)-resizeStart
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local maxW=math.max(260,viewport.X-(rootFrame.Position.X.Offset or 0)-6)
        local maxH=math.max(200,viewport.Y-(rootFrame.Position.Y.Offset or 0)-6)
        invCfg.inv_width=math.clamp(sizeStart.X+delta.X,260,maxW)
        invCfg.inv_height=math.clamp(sizeStart.Y+delta.Y,200,maxH)
        rootFrame.Size=UDim2.fromOffset(invCfg.inv_width,invCfg.inv_height)
    end)
    conn(grip.InputEnded, function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        if resizing then
            resizing=false
            invCfg.inv_width=math.floor(rootFrame.Size.X.Offset+0.5)
            invCfg.inv_height=math.floor(rootFrame.Size.Y.Offset+0.5)
            rootFrame.Size=UDim2.fromOffset(invCfg.inv_width,invCfg.inv_height)
            if State.inv_size_changed then pcall(State.inv_size_changed,invCfg.inv_width,invCfg.inv_height) end
        end
    end)
    do
        local L=Library
        rootFrame.BackgroundColor3=Color3.fromRGB(22,22,22); rootFrame.BackgroundTransparency=0
        rootCorner.CornerRadius=UDim.new(0,0)
        outline.Color=Color3.fromRGB(50,50,50); outline.Thickness=1
        header.BackgroundTransparency=1
        accent.Size=UDim2.new(1,0,0,1); accent.Position=UDim2.fromOffset(0,0); accent.BackgroundColor3=L.AccentColor; accent.ZIndex=11; accent:SetAttribute("MWHdr","bar")
        local fade=Instance.new("Frame",rootFrame); fade.Name="Fade"; fade:SetAttribute("MWHdr","fade"); fade.BackgroundColor3=Color3.new(1,1,1); fade.BorderSizePixel=0; fade.Size=UDim2.new(1,0,0,20); fade.Position=UDim2.fromOffset(0,1); fade.ZIndex=1; fade.Active=false
        local fg=Instance.new("UIGradient",fade); fg.Rotation=90
        fg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(math.max(0,L.AccentColor.R-0.12),math.max(0,L.AccentColor.G-0.12),math.max(0,L.AccentColor.B-0.12))),ColorSequenceKeypoint.new(1,Color3.fromRGB(22,22,22))}
        fg.Offset=Vector2.new(0,-0.55)
        divider.BackgroundColor3=Color3.fromRGB(50,50,50)
        title:SetAttribute("MWHdr","title"); title.Text="Inventory"; title.Font=L.Font; title.TextSize=14; title.TextColor3=L.AccentColor; title.TextStrokeTransparency=0; title.Position=UDim2.fromOffset(6,3); title.Size=UDim2.new(1,-10,0,14)
        inv_target_label.Font=L.Font; inv_target_label.TextSize=14; inv_target_label.TextColor3=L.FontColor; inv_target_label.TextStrokeTransparency=0
        inv_stats_label.Font=L.Font; inv_stats_label.TextSize=12; inv_stats_label.TextColor3=Color3.fromRGB(150,150,150); inv_stats_label.TextStrokeTransparency=0.5
        inv_value_label.Font=L.Font; inv_value_label.TextSize=12; inv_value_label.TextColor3=L.AccentColor; inv_value_label.TextStrokeTransparency=0
        textScroll.ScrollBarImageColor3=L.AccentColor; imageScroll.ScrollBarImageColor3=L.AccentColor
        State.inv_theme={AccentColor=L.AccentColor,FontColor=L.FontColor,MainColor=Color3.fromRGB(30,30,30),OutlineColor=L.OutlineColor,Font=L.Font}
    end
    inv_gui=screen; inv_root=rootFrame; inv_text_scroll=textScroll; inv_image_scroll=imageScroll; inv_text_layout=listLayout; inv_image_layout=grid
end
local function inv_stat_line(playerData, displayName)
    local out={}
    local status=playerData and playerData:FindFirstChild("Status")
    local journey=status and status:FindFirstChild("Journey")
    local stats=journey and journey:FindFirstChild("Statistics")
    if invCfg.inv_show_kdr and stats then
        local kdr=stats:GetAttribute("KDR") or stats:GetAttribute("KD")
        local kills=tonumber(stats:GetAttribute("Kills") or stats:GetAttribute("Eliminations"))
        local deaths=tonumber(stats:GetAttribute("Deaths"))
        if kdr~=nil then table.insert(out,"K/D "..tostring(kdr)) elseif kills and deaths then table.insert(out,"K/D "..string.format("%.2f",kills/math.max(1,deaths))) end
    end
    if invCfg.inv_show_hours and stats then
        local played=stats:GetAttribute("TimePlayed")
        if type(played)=="number" then table.insert(out,string.format("%.1fh",played/3600)) end
    end
    if invCfg.inv_show_reports and status then
        local uac=status:FindFirstChild("UAC"); local reports=uac and uac:FindFirstChild("Reports")
        local reportCount=reports and (reports:GetAttribute("1") or reports:GetAttribute("Count"))
        if reportCount~=nil then table.insert(out,tostring(reportCount).." reports") end
    end
    if invCfg.inv_show_team and displayName then
        local clans=ReplicatedStorage:FindFirstChild("Clans"); local team
        if clans then for _,clan in ipairs(clans:GetChildren()) do if clan:FindFirstChild(displayName) then team=clan.Name; break end end end
        table.insert(out,"Team: "..(team or "none"))
    end
    return table.concat(out,"   |   ")
end
local function inv_render(target,kind)
    local entries,totalValue,playerData,model=inv_collect_entries(target,kind)
    State.inv_item_entries=entries
    local name=target and target.Name or "Unknown"
    if inv_target_label then inv_target_label.Text=(kind=="body" and "[BODY] " or kind=="ai" and "[AI] " or "")..name end
    if inv_stats_label then inv_stats_label.Text=inv_stat_line(playerData,name) end
    if inv_value_label then inv_value_label.Text=invCfg.inv_show_value and ("Estimated value: "..tostring(math.floor(totalValue)).." RUB   |   "..tostring(#entries).." items") or (tostring(#entries).." items") end
    if not inv_gui then return end
    local useText=(invCfg.inv_mode or "Text")=="Text"
    inv_text_scroll.Visible=useText; inv_image_scroll.Visible=not useText
    inv_text_scroll.ScrollBarImageColor3=(State.inv_theme and State.inv_theme.AccentColor or Library.AccentColor)
    inv_image_scroll.ScrollBarImageColor3=(State.inv_theme and State.inv_theme.AccentColor or Library.AccentColor)
    inv_clear_scroller(inv_text_scroll,inv_text_layout); inv_clear_scroller(inv_image_scroll,inv_image_layout)
    local parentScroll=useText and inv_text_scroll or inv_image_scroll
    local order=0; local lastGroup=nil
    for _,entry in ipairs(entries) do
        order+=1
        local info=entry.info
        if useText then
            if entry.group~=lastGroup then
                lastGroup=entry.group
                local heading=Instance.new("TextLabel",parentScroll); heading.Name="InventoryGroup"; heading.BackgroundTransparency=1; heading.Size=UDim2.new(1,-4,0,18); heading.Font=(State.inv_theme and State.inv_theme.Font or Enum.Font.GothamBold); heading.TextSize=12; heading.TextColor3=(State.inv_theme and State.inv_theme.AccentColor or Library.AccentColor); heading.TextXAlignment=Enum.TextXAlignment.Left; heading.Text=entry.group; heading.LayoutOrder=order; order+=1
            end
            local row=Instance.new("TextLabel",parentScroll); row.Name="ItemRow"; row.BackgroundColor3=(State.inv_theme and State.inv_theme.MainColor or Color3.fromRGB(22,22,29)); row.BackgroundTransparency=0; row.BorderSizePixel=0; row.Size=UDim2.new(1,-4,0,math.clamp(invCfg.inv_line_h or 15,12,24)); row.Font=(State.inv_theme and State.inv_theme.Font or Enum.Font.Gotham); row.TextSize=math.clamp(invCfg.inv_text_size or 12,10,18); row.TextColor3=(State.inv_theme and State.inv_theme.FontColor or Color3.fromRGB(225,225,235)); row.TextStrokeTransparency=0.5; row.TextXAlignment=Enum.TextXAlignment.Left; row.TextTruncate=Enum.TextTruncate.AtEnd; row.Text="  "..info.name..(info.amount>1 and ("  x"..tostring(info.amount)) or "")..(invCfg.inv_show_value and ("   •   "..tostring(math.floor(info.price*info.amount)).." RUB") or ""); row.LayoutOrder=order
        else
            local cell=Instance.new("Frame",parentScroll); cell.Name="ItemCell"; cell.BackgroundColor3=(State.inv_theme and State.inv_theme.MainColor or Color3.fromRGB(22,22,29)); cell.BorderSizePixel=0; cell.LayoutOrder=order
            local corner=Instance.new("UICorner",cell); corner.CornerRadius=UDim.new(0,0); local cst=Instance.new("UIStroke",cell); cst.Color=Color3.fromRGB(50,50,50); cst.Thickness=1
            local icon=Instance.new("ImageLabel",cell); icon.BackgroundTransparency=1; icon.Position=UDim2.fromOffset(5,3); icon.Size=UDim2.fromOffset(54,48); icon.ScaleType=Enum.ScaleType.Fit; icon.Image=info.icon or ""
            if icon.Image=="" then
                local fallback=Instance.new("TextLabel",cell); fallback.BackgroundTransparency=1; fallback.Position=UDim2.fromOffset(2,4); fallback.Size=UDim2.new(1,-4,0,43); fallback.Font=Enum.Font.Code; fallback.TextSize=9; fallback.TextWrapped=true; fallback.TextColor3=Color3.fromRGB(185,185,200); fallback.Text=info.name
            end
            local label=Instance.new("TextLabel",cell); label.BackgroundTransparency=1; label.Position=UDim2.new(0,2,1,-19); label.Size=UDim2.new(1,-4,0,16); label.Font=Enum.Font.Code; label.TextSize=8; label.TextColor3=Color3.fromRGB(225,225,235); label.TextTruncate=Enum.TextTruncate.AtEnd; label.Text=info.name..(info.amount>1 and (" x"..tostring(info.amount)) or "")
            if info.amount>1 then
                local badge=Instance.new("TextLabel",cell); badge.BackgroundColor3=(State.inv_theme and State.inv_theme.AccentColor or Library.AccentColor); badge.BorderSizePixel=0; badge.Position=UDim2.fromOffset(42,2); badge.Size=UDim2.fromOffset(20,13); badge.Font=Enum.Font.Code; badge.TextSize=8; badge.TextColor3=Color3.new(1,1,1); badge.Text="x"..tostring(info.amount)
            end
        end
    end
    inv_text_scroll.CanvasSize=UDim2.fromOffset(0,inv_text_layout.AbsoluteContentSize.Y+8)
    inv_image_scroll.CanvasSize=UDim2.fromOffset(0,inv_image_layout.AbsoluteContentSize.Y+8)
end
local function inv_get_closest()
    local mouse=UIS:GetMouseLocation()
    local best,bestKind,bestDist=nil,nil,math.huge
    local maxRadius=invCfg.inv_aim_radius or 160
    local function consider(target,kind,part)
        if not part or not part:IsA("BasePart") then return end
        local screen,on=workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        if not on or screen.Z<=0 then return end
        local dist=(Vector2.new(screen.X,screen.Y)-mouse).Magnitude
        if dist<=maxRadius and dist<bestDist then best,bestKind,bestDist=target,kind,dist end
    end
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=Player and player.Character then
            local character=player.Character; local hum=character:FindFirstChildOfClass("Humanoid"); local rootPart=character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health>0 then consider(player,"player",rootPart) end
        end
    end
    if invCfg.inv_bodies_enabled then
        local dropped=workspace:FindFirstChild("DroppedItems")
        if dropped then for _,body in ipairs(dropped:GetChildren()) do
            if body:IsA("Model") and body:FindFirstChildOfClass("Humanoid") and (body:FindFirstChild("Head") or body:FindFirstChildWhichIsA("BasePart")) then
                consider(body,"body",body:FindFirstChild("Head") or body:FindFirstChildWhichIsA("BasePart"))
            end
        end end
    end
    if invCfg.ai_inv_enabled then
        local zones=workspace:FindFirstChild("AiZones")
        if zones then
            for _,zone in ipairs(zones:GetChildren()) do
                for _,obj in ipairs(zone:GetChildren()) do
                    if obj:IsA("Model") and obj.Parent then
                        local hum=obj:FindFirstChildOfClass("Humanoid")
                        local part=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart")
                        if hum and hum.Health>0 and (obj:FindFirstChild("Inventory") or (ReplicatedStorage:FindFirstChild("Players") and ReplicatedStorage.Players:FindFirstChild(obj.Name))) then
                            consider(obj,"ai",part)
                        end
                    end
                end
            end
        end
    end
    return best,bestKind
end
local function inv_populate(target,kind)
    if not target then return end
    if not inv_gui then inv_build_gui() end
    inv_render(target,kind or "player")
end
local function inv_update_frame()
    if not invCfg.inv_enabled then
        if inv_gui then inv_gui.Enabled=false end
        State.inv_last_target=nil; State.inv_last_kind=nil
        return
    end
    local now=os.clock()
    local rate=math.clamp(invCfg.inv_update_rate or 10,5,10)
    if now-State.inv_last_target_scan < 1/rate then return end
    State.inv_last_target_scan=now
    local target,kind=inv_get_closest()
    if not target then
        if inv_gui then inv_gui.Enabled=false end
        State.inv_last_target=nil; State.inv_last_kind=nil
        return
    end
    if not inv_gui then inv_build_gui() end
    inv_gui.Enabled=true
    if target~=State.inv_last_target or kind~=State.inv_last_kind or now-State.inv_last_refresh>=math.max(0.5,1/rate) then
        State.inv_last_target=target; State.inv_last_kind=kind; State.inv_last_refresh=now
        inv_populate(target,kind)
    end
end
    local api={}
    function api.setEnabled(v) invCfg.inv_enabled=(v==true); if not v and inv_gui then inv_gui.Enabled=false end end
    function api.getEnabled() return invCfg.inv_enabled end
    function api.applySize()
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local w=math.clamp(math.floor(tonumber(invCfg.inv_width) or 370),260,math.max(260,viewport.X-20))
        local h=math.clamp(math.floor(tonumber(invCfg.inv_height) or 470),200,math.max(200,viewport.Y-20))
        invCfg.inv_width=w; invCfg.inv_height=h
        if inv_root then inv_root.Size=UDim2.fromOffset(w,h) end
    end
    function api.setOption(k,v)
        invCfg[k]=v; State.inv_last_target=nil
        if k=="inv_width" or k=="inv_height" then pcall(api.applySize) end
    end
    function api.getOption(k) return invCfg[k] end
    function api.update() if invCfg.inv_enabled then inv_update_frame() elseif inv_gui and inv_gui.Enabled then inv_gui.Enabled=false; State.inv_last_target=nil; State.inv_last_kind=nil end end
    function api.destroy() invCfg.inv_enabled=false; if inv_gui then pcall(function() inv_gui:Destroy() end); inv_gui=nil; inv_root=nil end end
    return api
end)()
gg.__OmniInventoryChecker = InventoryChecker
conn(RunService.RenderStepped, function() pcall(InventoryChecker.update) end)

local skeletonBones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local skeletonAliases = {
    UpperTorso={"UpperTorso","Torso"}, LowerTorso={"LowerTorso","Torso"},
    LeftUpperArm={"LeftUpperArm","Left Arm"}, RightUpperArm={"RightUpperArm","Right Arm"},
    LeftLowerArm={"LeftLowerArm","Left Arm"}, RightLowerArm={"RightLowerArm","Right Arm"},
    LeftHand={"LeftHand","Left Arm"}, RightHand={"RightHand","Right Arm"},
    LeftUpperLeg={"LeftUpperLeg","Left Leg"}, RightUpperLeg={"RightUpperLeg","Right Leg"},
    LeftLowerLeg={"LeftLowerLeg","Left Leg"}, RightLowerLeg={"RightLowerLeg","Right Leg"},
    LeftFoot={"LeftFoot","Left Leg"}, RightFoot={"RightFoot","Right Leg"},
}

local function skeletonPart(character, name)
    for _, n in ipairs(skeletonAliases[name] or {name}) do
        local p = character:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
end

local function makeLineFrame(parent)
    local l = Instance.new("Frame")
    l.AnchorPoint = Vector2.new(0.5,0.5)
    l.BackgroundColor3 = espColors.skeleton
    l.BackgroundTransparency = 0.2
    l.BorderSizePixel = 0
    l.Visible = false
    l.ZIndex = 4
    l.Parent = parent
    return l
end

local function positionLine(line, a, b)
    local dx,dy = b.X-a.X, b.Y-a.Y
    local len = math.sqrt(dx*dx+dy*dy)
    if len < 1 then line.Visible=false; return end
    line.Position = UDim2.fromOffset((a.X+b.X)*0.5,(a.Y+b.Y)*0.5)
    line.Size = UDim2.fromOffset(len,1)
    line.Rotation = math.deg(math.atan2(dy,dx))
end

local function characterAlive(ch)
    if not ch then return false end
    local h = ch:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function isDowned(ch)
    if not ch then return false end
    if ch:GetAttribute("SD") ~= nil then return true end

    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return true end
    if ch:GetAttribute("Downed") == true or ch:GetAttribute("Knocked") == true then return true end
    return false
end

local function onSameTeam(other)
    if other == Player then return true end
    if not espState.teamCheck then return false end
    if not Player.Team or not other.Team then return false end
    return Player.Team == other.Team
end

local visParams = RaycastParams.new()
visParams.FilterType = Enum.RaycastFilterType.Exclude
visParams.IgnoreWater = true

local function internalRaycast(o, d, p)
    aimState.internal = true
    local ok, r = pcall(workspace.Raycast, workspace, o, d, p)
    aimState.internal = false
    if not ok then return nil end
    return r
end

local function isVisible(ch, pt)
    local cam = workspace.CurrentCamera
    if not cam then return true end
    local filter = {}
    if Player.Character then filter[1] = Player.Character end
    if ch then filter[#filter+1] = ch end
    visParams.FilterDescendantsInstances = filter
    return internalRaycast(cam.CFrame.Position, pt-cam.CFrame.Position, visParams) == nil
end

local function makeEspEntry(plr)
    local box = Instance.new("Frame")
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

    Instance.new("UICorner", box).CornerRadius = UDim.new(0,2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1,1)
    fill.BackgroundColor3 = espColors.boxFill
    fill.BackgroundTransparency = 0.86
    fill.BorderSizePixel = 0
    fill.Visible = false
    fill.ZIndex = 4
    fill.Parent = box

    local cornerLines = {}
    for i = 1,8 do
        local l = Instance.new("Frame")
        l.BackgroundColor3 = espColors.box
        l.BorderSizePixel = 0
        l.Visible = false
        l.ZIndex = 5
        l.Parent = box
        cornerLines[i] = l
    end

    local nameLabel = Instance.new("TextLabel")
    nameLabel.AnchorPoint = Vector2.new(0.5,1)
    nameLabel.Position = UDim2.new(0.5,0,0,-2)
    nameLabel.Size = UDim2.new(1,140,0,14)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = espColors.name
    nameLabel.TextStrokeTransparency = 0.35
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 11
    nameLabel.ZIndex = 6
    nameLabel.Parent = box

    local distLabel = Instance.new("TextLabel")
    distLabel.AnchorPoint = Vector2.new(0.5,0)
    distLabel.Position = UDim2.new(0.5,0,1,2)
    distLabel.Size = UDim2.new(1,90,0,12)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = espColors.distance
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Font = Enum.Font.Code
    distLabel.TextSize = 9
    distLabel.ZIndex = 6
    distLabel.Parent = box

    local weaponLabel = Instance.new("TextLabel")
    weaponLabel.AnchorPoint = Vector2.new(0.5,0)
    weaponLabel.Position = UDim2.new(0.5,0,1,14)
    weaponLabel.Size = UDim2.new(1,110,0,12)
    weaponLabel.BackgroundTransparency = 1
    weaponLabel.TextColor3 = espColors.weapon
    weaponLabel.TextStrokeTransparency = 0.5
    weaponLabel.Font = Enum.Font.Code
    weaponLabel.TextSize = 9
    weaponLabel.TextTruncate = Enum.TextTruncate.AtEnd
    weaponLabel.ZIndex = 6
    weaponLabel.Parent = box

    local visLabel = Instance.new("TextLabel")
    visLabel.AnchorPoint = Vector2.new(0.5,0)
    visLabel.BackgroundTransparency = 1
    visLabel.Font = Enum.Font.GothamBold
    visLabel.TextSize = 12
    visLabel.ZIndex = 6
    visLabel.Parent = box

    local hBack = Instance.new("Frame")
    hBack.AnchorPoint = Vector2.new(1,0)
    hBack.Position = UDim2.new(0,-5,0,0)
    hBack.Size = UDim2.fromOffset(2,1)
    hBack.BackgroundColor3 = Color3.fromRGB(30,30,35)
    hBack.BackgroundTransparency = 0.5
    hBack.BorderSizePixel = 0
    hBack.ZIndex = 5
    hBack.Parent = box

    local hFill = Instance.new("Frame")
    hFill.AnchorPoint = Vector2.new(0,1)
    hFill.Position = UDim2.new(0,0,1,0)
    hFill.Size = UDim2.new(1,0,1,0)
    hFill.BackgroundColor3 = espColors.health
    hFill.BorderSizePixel = 0
    hFill.ZIndex = 6
    hFill.Parent = hBack
    local hGrad = Instance.new("UIGradient")
    hGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,espHealthColors.top),
        ColorSequenceKeypoint.new(1,espHealthColors.bottom),
    })
    hGrad.Rotation = 90
    hGrad.Parent = hFill

    local tracer = Instance.new("Frame")
    tracer.AnchorPoint = Vector2.new(0.5,0.5)
    tracer.BackgroundColor3 = espColors.tracer
    tracer.BackgroundTransparency = 0.25
    tracer.BorderSizePixel = 0
    tracer.Visible = false
    tracer.ZIndex = 3
    tracer.Parent = espLayer

    local headDot = Instance.new("Frame")
    headDot.AnchorPoint = Vector2.new(0.5,0.5)
    headDot.Size = UDim2.fromOffset(4,4)
    headDot.BackgroundColor3 = espColors.headDot
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.ZIndex = 5
    headDot.Parent = espLayer
    Instance.new("UICorner", headDot).CornerRadius = UDim.new(1,0)

    local bones = {}
    for i = 1,#skeletonBones do
        bones[i] = makeLineFrame(espLayer)
    end

    local highlight = Instance.new("Highlight")
    highlight.Enabled = false
    highlight.FillColor = espColors.chams
    highlight.FillTransparency = chamsState.fillTransparency
    highlight.OutlineTransparency = 1
    highlight.Parent = espGui

    local entry = {
        box=box, stroke=stroke, nameLabel=nameLabel, distLabel=distLabel, weaponLabel=weaponLabel,
        visLabel=visLabel, hBack=hBack, hFill=hFill, hGrad=hGrad,
        tracer=tracer, highlight=highlight, fill=fill,
        cornerLines=cornerLines, headDot=headDot, bones=bones,
        visible=true, visibleAt=0,
    }
    espEntries[plr] = entry
    return entry
end

local function hideEntry(e)
    if not e then return end
    if e._hidden then return end
    e._hidden = true
    e.box.Visible = false
    e.fill.Visible = false
    e.tracer.Visible = false
    e.headDot.Visible = false
    e.nameLabel.Visible = false
    e.distLabel.Visible = false
    e.visLabel.Visible = false
    if e.weaponLabel then e.weaponLabel.Visible = false end
    e.hBack.Visible = false
    e.hFill.Visible = false
    e.highlight.Enabled = false
    e.highlight.Adornee = nil
    for i = 1,#e.cornerLines do e.cornerLines[i].Visible = false end
    for i = 1,#e.bones do e.bones[i].Visible = false end
end

State.espLastPos = {}
State.espBoxCache = {}

State.espBoxNames = {
    Head=true, HeadTopHitBox=true, FaceHitBox=true,
    UpperTorso=true, Torso=true, LowerTorso=true, HumanoidRootPart=true,
    LeftUpperArm=true, RightUpperArm=true, LeftLowerArm=true, RightLowerArm=true,
    LeftHand=true, RightHand=true,
    LeftUpperLeg=true, RightUpperLeg=true, LeftLowerLeg=true, RightLowerLeg=true,
    LeftFoot=true, RightFoot=true,
    ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true,
}

State.espBoxParts = function(model)
    local cached = State.espBoxCache[model]
    local count = #model:GetChildren()
    if cached and cached.count == count then return cached.list end
    local list = {}
    for _, p in ipairs(model:GetChildren()) do
        if p:IsA("BasePart") and State.espBoxNames[p.Name] then
            list[#list + 1] = p
        end
    end
    State.espBoxCache[model] = { count = count, list = list }
    return list
end

State.espProjectBox = function(model, cam)
    local parts = State.espBoxParts(model)
    if #parts == 0 then return nil end
    local pad = tonumber(espState.boxPadding) or 1.1
    local minX, minY, maxX, maxY
    local any = false
    for i = 1, #parts do
        local p = parts[i]
        if p.Parent then
            local cf, size = p.CFrame, p.Size
            local hx = size.X * 0.5 * pad
            local hy = size.Y * 0.5 * pad
            local hz = size.Z * 0.5 * pad
            for xi = -1, 1, 2 do
                for yi = -1, 1, 2 do
                    for zi = -1, 1, 2 do
                        local sp, on = cam:WorldToViewportPoint(cf * Vector3.new(hx * xi, hy * yi, hz * zi))
                        if on and sp.Z > 0 then
                            any = true
                            if not minX or sp.X < minX then minX = sp.X end
                            if not maxX or sp.X > maxX then maxX = sp.X end
                            if not minY or sp.Y < minY then minY = sp.Y end
                            if not maxY or sp.Y > maxY then maxY = sp.Y end
                        end
                    end
                end
            end
        end
    end
    if not any then return nil end
    local w = maxX - minX
    local h = maxY - minY
    if w ~= w or h ~= h then return nil end
    return minX, minY, math.max(1, w), math.max(4, h)
end

State.espBoundingBox = function(model, basePos, cam)
    if (espState.boxType or "Dynamic") == "Dynamic" and model then
        local l, t, w, h = State.espProjectBox(model, cam)
        if l then return l, t, w, h end
    end
    local bh = tonumber(espState.boxSizeY) or 5
    local bw = tonumber(espState.boxSizeX) or 3.6
    local half = Vector3.new(0, bh * 0.5, 0)
    local top, topOn = cam:WorldToViewportPoint(basePos + half)
    if not (topOn and top.Z > 0) then return nil end
    local bot, botOn = cam:WorldToViewportPoint(basePos - half)
    if not (botOn and bot.Z > 0) then return nil end
    local h = math.max(4, math.abs(top.Y - bot.Y) * 1.2)
    local w = math.max(1, h * bw / bh)
    local l = (top.X + bot.X) * 0.5 - w * 0.5
    local t = (top.Y + bot.Y) * 0.5 + 2 - h * 0.5
    if l ~= l or t ~= t then return nil end
    return l, t, w, h
end

local function getESPWeapon(plr, character)
    local tool = character and character:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    local pf = ReplicatedStorage:FindFirstChild("Players")
    local pd = pf and pf:FindFirstChild(plr.Name)
    local status = pd and pd:FindFirstChild("Status")
    local vars = status and status:FindFirstChild("GameplayVariables")
    local equipped = vars and vars:FindFirstChild("EquippedTool")
    local value
    if equipped and equipped:IsA("ValueBase") then
        value = equipped.Value
    end
    if typeof(value)=="Instance" then return value.Name end
    if type(value)=="string" and value~="" then return value end
    return ""
end

local function renderAIESP(cam,vp,now)
    local seen={}
    if espState.ai then
        local zones=workspace:FindFirstChild("AiZones")
        if zones then
            for _,zone in ipairs(zones:GetChildren()) do
                for _,model in ipairs(zone:GetChildren()) do
                    if model:IsA("Model") then
                        local hum=model:FindFirstChildOfClass("Humanoid")
                        local head=model:FindFirstChild("Head")
                        local root=model:FindFirstChild("HumanoidRootPart") or head or model:FindFirstChildWhichIsA("BasePart")
                        if hum and hum.Health>0 and head and root and not isDowned(model) then
                            local entry=espEntries[model] or makeEspEntry(model)
                            seen[model]=true
                            local boxL,boxT,boxW,boxH=State.espBoundingBox(model,root.Position,cam)
                            if boxL then
                                local h=boxH; local w=boxW
                                local x=boxL; local y=boxT
                                local meters=math.floor((cam.CFrame.Position-root.Position).Magnitude*0.28+0.5)
                                if espState.maxDistance<=0 or meters<=espState.maxDistance then
                                    local bw,bh=math.max(1,math.floor(w)),math.max(1,math.floor(h))
                                    entry._hidden=false
                                    entry.box.Visible=true
                                    entry.box.Position=UDim2.fromOffset(math.floor(x),math.floor(y)); entry.box.Size=UDim2.fromOffset(bw,bh)
                                    entry.stroke.Color=espColors.box; entry.stroke.Transparency=(espState.box and not espState.cornerBox) and 0.05 or 1
                                    entry.fill.Visible=espState.box and espState.boxFill; entry.fill.BackgroundColor3=espColors.boxFill
                                    entry.nameLabel.Visible=espState.names; entry.nameLabel.Text="[AI] "..model.Name; entry.nameLabel.TextColor3=espColors.name
                                    entry.distLabel.Visible=espState.distance; entry.distLabel.Text=tostring(meters).."m"; entry.distLabel.TextColor3=espColors.distance
                                    entry.weaponLabel.Visible=false
                                    local aiVisible=isVisible(model,head.Position)
                                    entry.visLabel.Visible=espState.visibility
                                    entry.visLabel.Text=aiVisible and "VISIBLE" or "HIDDEN"
                                    entry.visLabel.TextColor3=aiVisible and espColors.visibilityVisible or espColors.visibilityHidden
                                    entry.visLabel.Position=UDim2.new(0.5,0,0,bh+8)
                                    local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                                    entry.hBack.Visible=espState.health; entry.hFill.Visible=espState.health
                                    entry.hBack.Size=UDim2.fromOffset(2,bh); entry.hFill.Size=UDim2.new(1,0,hp,0)
                                    entry.hGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,espHealthColors.top),ColorSequenceKeypoint.new(1,espHealthColors.bottom)})
                                    entry.tracer.Visible=espState.tracer
                                    if espState.tracer then
                                        local sx,sy=vp.X*0.5,vp.Y; local ex,ey=x+w*0.5,y+h; local dx,dy=ex-sx,ey-sy
                                        entry.tracer.BackgroundColor3=espColors.tracer; entry.tracer.Position=UDim2.fromOffset(sx+dx*0.5,sy+dy*0.5)
                                        entry.tracer.Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),1); entry.tracer.Rotation=math.deg(math.atan2(dy,dx))
                                    end
                                    entry.highlight.Enabled=espState.chams
                                    if entry.highlight.Enabled then
                                        entry.highlight.Adornee=model; entry.highlight.FillColor=espColors.chams
                                        entry.highlight.FillTransparency=chamsState.fillTransparency
                                        entry.highlight.OutlineTransparency=chamsState.outline and chamsState.outlineTransparency or 1
                                        entry.highlight.DepthMode=espState.walls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                                    end
                                    if espState.skeleton then
                                        for i,bone in ipairs(skeletonBones) do
                                            local pa=skeletonPart(model,bone[1]); local pb=skeletonPart(model,bone[2]); local line=entry.bones[i]
                                            if pa and pb then
                                                local a2,aOn=cam:WorldToViewportPoint(pa.Position); local b2,bOn=cam:WorldToViewportPoint(pb.Position)
                                                if aOn and bOn and a2.Z>0 and b2.Z>0 then line.Visible=true; line.BackgroundColor3=espColors.skeleton; positionLine(line,Vector2.new(a2.X,a2.Y),Vector2.new(b2.X,b2.Y)) else line.Visible=false end
                                            else line.Visible=false end
                                        end
                                    else for i=1,#entry.bones do entry.bones[i].Visible=false end end
                                else hideEntry(entry) end
                            else hideEntry(entry) end
                        end
                    end
                end
            end
        end
    end
    for entity,entry in pairs(espEntries) do
        if typeof(entity)=="Instance" and entity:IsA("Model") and not seen[entity] then
            State.espBoxCache[entity] = nil
            hideEntry(entry)
        end
    end
end

local function renderESP()
    if not espState.enabled then
        for _, e in next, espEntries do hideEntry(e) end
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local now = os.clock()

    for _, plr in ipairs(Players:GetPlayers()) do
        local entry = espEntries[plr] or makeEspEntry(plr)
        local ch = plr.Character
        local alive = characterAlive(ch) and not isDowned(ch)

        if not alive then
            State.espLastPos[plr] = nil
            if ch then State.espBoxCache[ch] = nil end
            hideEntry(entry)
            continue
        end

        local head = ch:FindFirstChild("Head")
        local root = ch:FindFirstChild("HumanoidRootPart")
            or ch:FindFirstChild("UpperTorso")
            or ch:FindFirstChild("Torso")

        local headPos = head and head.Position
        local rootPos = root and root.Position
        local usingCached = false

        if headPos and rootPos then
            State.espLastPos[plr] = rootPos
        elseif espState.infinite then
            local last = State.espLastPos[plr]
            if last then
                headPos = last + Vector3.new(0, 3, 0)
                rootPos = last
                usingCached = true
            end
        end

        if plr == Player or onSameTeam(plr) or not (headPos and rootPos) then
            hideEntry(entry)
        else

            local boxL, boxT, boxW, boxH = State.espBoundingBox(ch, rootPos, cam)

            if not boxL then
                hideEntry(entry)
            else
                local dist = (cam.CFrame.Position - rootPos).Magnitude
                local meters = math.floor(dist*0.28+0.5)

                if not (boxW >= 0 and boxW < 1e6 and boxH >= 0 and boxH < 1e6
                    and boxL == boxL and boxT == boxT and boxT > -1e6 and boxT < 1e6) then
                    hideEntry(entry)
                    continue
                end

                if not usingCached and espState.maxDistance > 0 and meters > espState.maxDistance then hideEntry(entry); continue end

                if not usingCached and now - entry.visibleAt > 0.15 then
                    entry.visibleAt = now
                    entry.visible = isVisible(ch, headPos)
                end

                if not espState.walls and not entry.visible then hideEntry(entry); continue end

                local h = math.min(boxH, vp.Y * 0.9)
                local w = math.min(boxW, vp.X * 0.6)
                local x = boxL + (boxW - w) * 0.5
                local boxTop = boxT + (boxH - h) * 0.5
                local humanoid = ch and ch:FindFirstChildOfClass("Humanoid")
                local hp = humanoid and math.clamp(humanoid.Health/math.max(humanoid.MaxHealth,1),0,1) or 0
                local bw = math.max(1,math.floor(w))
                local bh = math.max(1,math.floor(h))
                local bx = math.floor(x)
                local by = math.floor(boxTop)

                entry._hidden = false

                entry.box.Visible = true
                entry.box.Position = UDim2.fromOffset(bx, by)
                entry.box.Size = UDim2.fromOffset(bw, bh)
                entry.stroke.Color = espColors.box
                entry.stroke.Transparency = (espState.box and not espState.cornerBox) and 0.05 or 1

                entry.fill.Visible = espState.box and espState.boxFill
                entry.fill.BackgroundColor3 = espColors.boxFill

                local cLen = math.clamp(math.floor(math.min(bw,bh)*0.24),5,16)
                local function seg(i, px,py,sw,sh)
                    local l = entry.cornerLines[i]
                    l.Visible = espState.cornerBox
                    l.BackgroundColor3 = espColors.box
                    l.Position = UDim2.fromOffset(px,py)
                    l.Size = UDim2.fromOffset(sw,sh)
                end
                if espState.cornerBox then
                    seg(1,0,0,cLen,1); seg(2,0,0,1,cLen)
                    seg(3,bw-cLen,0,cLen,1); seg(4,bw-1,0,1,cLen)
                    seg(5,0,bh-1,cLen,1); seg(6,0,bh-cLen,1,cLen)
                    seg(7,bw-cLen,bh-1,cLen,1); seg(8,bw-1,bh-cLen,1,cLen)
                else
                    for i=1,8 do entry.cornerLines[i].Visible=false end
                end

                local hS, hOn = cam:WorldToViewportPoint(headPos)
                entry.headDot.Visible = espState.headDot and hOn and hS.Z>0
                if entry.headDot.Visible then
                    entry.headDot.Position = UDim2.fromOffset(math.floor(hS.X), math.floor(hS.Y))
                    entry.headDot.BackgroundColor3 = espColors.headDot
                end

                entry.nameLabel.Visible = espState.names
                entry.nameLabel.Text = plr.Name
                entry.nameLabel.TextColor3 = espColors.name
                entry.nameLabel.Position = UDim2.new(0.5, 0, 0, -16)
                entry.nameLabel.Size = UDim2.new(1, 0, 0, 14)

                entry.distLabel.Visible = espState.distance
                entry.distLabel.Text = tostring(meters).."m"
                entry.distLabel.TextColor3 = espColors.distance
                entry.distLabel.Position = UDim2.new(0.5, 0, 0, espState.names and -28 or -16)
                entry.distLabel.Size = UDim2.new(1, 0, 0, 12)

                local weaponName = getESPWeapon(plr,ch)
                entry.weaponLabel.Visible = espState.weapon and weaponName~=""
                entry.weaponLabel.Text = weaponName
                entry.weaponLabel.TextColor3 = espColors.weapon
                entry.weaponLabel.Position = UDim2.new(0.5,0,1,espState.distance and 14 or 2)

                entry.visLabel.Visible = espState.visibility
                entry.visLabel.Text = entry.visible and "VISIBLE" or "HIDDEN"
                entry.visLabel.TextColor3 = entry.visible and espColors.visibilityVisible or espColors.visibilityHidden
                entry.visLabel.Position = UDim2.new(0.5,0,0,bh+8)
                entry.visLabel.Size = UDim2.new(1,0,0,18)

                entry.hBack.Visible = espState.health and humanoid~=nil
                entry.hFill.Visible = espState.health and humanoid~=nil
                if espState.health and humanoid then
                    entry.hBack.Size = UDim2.fromOffset(2, math.max(6, math.floor(h)))
                    entry.hFill.Size = UDim2.new(1,0, hp, 0)
                    entry.hGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, espHealthColors.top),
                        ColorSequenceKeypoint.new(1, espHealthColors.bottom),
                    })
                end

                entry.tracer.Visible = espState.tracer
                if espState.tracer then
                    local sx, sy = vp.X*0.5, vp.Y
                    local ex, ey = x+w*0.5, boxTop+h
                    local dx, dy = ex-sx, ey-sy
                    local len = math.sqrt(dx*dx+dy*dy)
                    entry.tracer.BackgroundColor3 = espColors.tracer
                    entry.tracer.Position = UDim2.fromOffset(sx+dx*0.5, sy+dy*0.5)
                    entry.tracer.Size = UDim2.fromOffset(len,1)
                    entry.tracer.Rotation = math.deg(math.atan2(dy,dx))
                end

                entry.highlight.Enabled = espState.chams and ch~=nil
                if entry.highlight.Enabled then
                    entry.highlight.Adornee = ch
                    entry.highlight.FillColor = espColors.chams
                    entry.highlight.FillTransparency = chamsState.fillTransparency
                    entry.highlight.OutlineColor = chamsState.outline and chamsState.outlineColor or espColors.chams
                    entry.highlight.OutlineTransparency = chamsState.outline and chamsState.outlineTransparency or 1
                    entry.highlight.DepthMode = espState.walls
                        and Enum.HighlightDepthMode.AlwaysOnTop
                        or Enum.HighlightDepthMode.Occluded
                end

                if espState.skeleton and ch then
                    for i, bone in ipairs(skeletonBones) do
                        local pa = skeletonPart(ch, bone[1])
                        local pb = skeletonPart(ch, bone[2])
                        local line = entry.bones[i]
                        if pa and pb and pa.Parent and pb.Parent then
                            local a2, aOn = cam:WorldToViewportPoint(pa.Position)
                            local b2, bOn = cam:WorldToViewportPoint(pb.Position)
                            if aOn and bOn and a2.Z>0 and b2.Z>0 then
                                line.Visible = true
                                line.BackgroundColor3 = espColors.skeleton
                                positionLine(line, Vector2.new(a2.X,a2.Y), Vector2.new(b2.X,b2.Y))
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                else
                    for i=1,#entry.bones do entry.bones[i].Visible=false end
                end
            end
        end
    end
    renderAIESP(cam,vp,now)
end

conn(Players.PlayerRemoving, function(plr)
    State.espLastPos[plr] = nil
    local e = espEntries[plr]
    if not e then return end
    e.box:Destroy(); e.tracer:Destroy(); e.headDot:Destroy()
    for i=1,#e.bones do e.bones[i]:Destroy() end
    e.highlight:Destroy()
    espEntries[plr] = nil
end)

local chamsClock, chamsHue = 0, 0
conn(RunService.RenderStepped, function(dt)
    if not espState.chams then return end
    chamsClock = chamsClock + dt
    chamsHue = (chamsHue + dt*0.3) % 1
    local rainbow = Color3.fromHSV(chamsHue, chamsState.saturation, 1)
    local fillColor = chamsState.rainbow and rainbow or espColors.chams
    local base = chamsState.pulse and (0.55+0.35*math.sin(chamsClock*4)) or chamsState.fillTransparency
    local ft = math.clamp(base + (chamsState.intensity-0.5)*2, 0, 0.99)
    if chamsState.strobe then ft = (math.floor(chamsClock*12)%2==0) and 0 or 0.99 end
    for _, e in pairs(espEntries) do
        if e.highlight and e.highlight.Enabled then
            e.highlight.FillColor = fillColor
            e.highlight.FillTransparency = ft
        end
    end
end)

local function chamsRestoreMaterials()
    for part, orig in pairs(chamsOriginals) do
        if part.Parent then
            pcall(function() part.Material = orig.material; part.Color = orig.color end)
        end
    end
    table.clear(chamsOriginals)
end

local aimParts = {"Head","HeadTopHitBox","FaceHitBox","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}

State.aimOrders = {
    ["Head First"] = {"Head","HeadTopHitBox","FaceHitBox","UpperTorso","Torso","LowerTorso","HumanoidRootPart"},
    ["Torso First"] = {"UpperTorso","Torso","LowerTorso","HumanoidRootPart","Head","HeadTopHitBox","FaceHitBox"},
}

local function resolveAimPart(ch)
    if not ch then return nil end
    local mode = aimState.aimPriority or "Head First"
    local cam = workspace.CurrentCamera
    if mode == "Nearest Part" and cam then
        local origin = cam.CFrame.Position
        local best, bestD
        for _, n in ipairs(aimParts) do
            local p = ch:FindFirstChild(n)
            if p and p:IsA("BasePart") then
                local d = (p.Position - origin).Magnitude
                if not bestD or d < bestD then bestD, best = d, p end
            end
        end
        if best then return best end
    else
        local order = (State.aimOrders and State.aimOrders[mode]) or (State.aimOrders and State.aimOrders["Head First"])
        if order then
            for _, n in ipairs(order) do
                local p = ch:FindFirstChild(n)
                if p and p:IsA("BasePart") then return p end
            end
        end
    end
    return ch:FindFirstChildWhichIsA("BasePart")
end

local function aimEye()
    local ch = Player.Character
    if not ch then return nil end
    local root = ch:FindFirstChild("HumanoidRootPart")
    if not root then
        local head = ch:FindFirstChild("Head")
        return head and head.Position
    end
    if not aimState.fleChecked then
        aimState.fleChecked = true
        local ok, mod = pcall(function()
            local m = ReplicatedStorage:FindFirstChild("Modules")
            local lib = m and m:FindFirstChild("FunctionLibraryExtension")
            return lib and require(lib)
        end)
        aimState.fle = ok and type(mod)=="table" and mod or false
    end
    if aimState.fle and type(aimState.fle.GetEstimatedCameraPosition)=="function" then
        local ok, pos = pcall(aimState.fle.GetEstimatedCameraPosition, aimState.fle, Player)
        if ok and typeof(pos)=="Vector3" then return pos end
    end
    local crouch = ch:GetAttribute("Crouch")
    return root.Position + Vector3.new(0, crouch and 0.6 or 1.6, 0)
end

local function scanAimTarget()
    local cam = workspace.CurrentCamera
    if not cam then return end

    local vp = cam.ViewportSize
    local cx, cy = vp.X * 0.5, vp.Y * 0.5
    local best, bestPart, bestName, bestDist = nil, nil, nil, aimState.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        local ch = plr.Character
        if plr~=Player and not onSameTeam(plr) and characterAlive(ch) and not isDowned(ch) and not (aimState.blacklistEnabled and aimState.blacklist and aimState.blacklist[string.lower(plr.Name)]) then
            local part = resolveAimPart(ch)
            if part then
                local s, on = cam:WorldToViewportPoint(part.Position)
                if on and s.Z>0 then
                    local d = math.sqrt((s.X-cx)^2+(s.Y-cy)^2)
                    if d <= bestDist then
                        bestDist = d; best = part.Position; bestPart = part; bestName = plr.Name
                    end
                end
            end
        end
    end

    local zones = workspace:FindFirstChild("AiZones")
    if zones then
        for _, z in ipairs(zones:GetChildren()) do
            for _, m in ipairs(z:GetChildren()) do
                local part
                if m.Name == "MI24V" or m.Name == "BTR80" then
                    if aimState.targetHeli then
                        part = m:FindFirstChild("CollisionPilot") or m:FindFirstChild("CollisionBox") or m.PrimaryPart
                    end
                elseif aimState.targetAI ~= false and not (aimState.blacklistEnabled and aimState.blacklist and aimState.blacklist[string.lower(m.Name)]) then
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    if (hum and hum.Health > 0) or m:FindFirstChild("HumanoidRootPart") then
                        if not isDowned(m) then
                            part = m:FindFirstChild(aimState.aimPart or "Head")
                                or m:FindFirstChild("Head")
                                or m:FindFirstChild("HumanoidRootPart")
                                or m:FindFirstChildWhichIsA("BasePart")
                        end
                    end
                end
                if part and part:IsA("BasePart") then
                    local s, on = cam:WorldToViewportPoint(part.Position)
                    if on and s.Z>0 then
                        local d = math.sqrt((s.X-cx)^2+(s.Y-cy)^2)
                        if d <= bestDist then
                            bestDist = d
                            best = part.Position
                            bestPart = part
                            bestName = m.Name
                        end
                    end
                end
            end
        end
    end
    aimState.target = best
    aimState.targetPart = bestPart
    aimState.targetName = bestName
    aimState.eye = aimEye()
end

State.aimHookReady = false
local function ensureAimHook(force)
    if State.aimHookReady and not force then return end
    if type(hookmetamethod)~="function" or type(getnamecallmethod)~="function" then return end
    local prev = gg.__OmniAimHook
    if type(prev)=="table" and type(prev.restore)=="function" then pcall(prev.restore) end
    gg.__OmniAimHook = nil
    State.aimHookReady = false
    local closure = type(newcclosure)=="function" and newcclosure or function(f) return f end
    local checkcaller_fn = type(checkcaller)=="function" and checkcaller or function() return false end
    local hookState = {active=true, hits=0}
    local oldNC

    local rawMT, mtWasReadOnly
    pcall(function()
        if type(getrawmetatable)=="function" and type(setreadonly)=="function" then
            rawMT = getrawmetatable(game)
            mtWasReadOnly = isreadonly and isreadonly(rawMT)
            setreadonly(rawMT, false)
        end
    end)
    local hooked = closure(function(self, ...)
            hookState.hits = hookState.hits + 1
            if not oldNC then return end
            if not hookState.active or shuttingDown or aimState.internal then
                return oldNC(self, ...)
            end
            local method = getnamecallmethod()
            local fromCaller = checkcaller_fn()
            if method == "GetAttribute" then
                if fromCaller then return oldNC(self, ...) end
                local attr = ...
                if gunModState.noSpread and attr=="AccuracyDeviation" then return 0 end
                if gunModState.removeWeight and (attr=="MovementModifer" or attr=="GearWeight") then return 0 end
                if gunModState.removeAimRestrictions and attr=="BlockADS" then return false end
                if gunModState.noSway and (attr=="Sway" or attr=="AimSway" or attr=="WeaponSway") then return 0 end
                if gunModState.noObstruct and (attr=="WallTouchTilt" or attr=="Obstruction") then return 0 end
                if gunModState.instantLean and attr=="LeanAlpha" then return 0 end
                if gunModState.removeSandboxing and (attr=="Sandboxing" or attr=="IsSandbox") then return false end
                if gunModState.sprintShoot and (attr=="CanShootWhileSprint" or attr=="SprintShoot") then return true end
                if gunModState.ignoreWater and attr=="IgnoreWater" then return true end
                if gunModState.removeMuzzle and attr=="MuzzleEffect" then return false end
                if gunModState.removeSprintAnimation and attr=="Value" and self.Name=="Sprinting" then return false end
            end

            if gunModState.ignoreWater and self==workspace and (method=="Raycast" or method=="Spherecast" or method=="Blockcast") then
                local args = table.pack(...)
                local params = args[3]
                if typeof(params)=="RaycastParams" then
                    pcall(function() params.IgnoreWater = true end)
                end
            end

            if gunModState.meleeReach and (method=="Raycast" or method=="Spherecast" or method=="Blockcast") and self==workspace then
                local tb = debug.traceback()
                if type(tb)=="string" and tb:find("Melee", 1, true) then
                    local args = table.pack(...)
                    if method=="Raycast" and typeof(args[2])=="Vector3" and args[2].Magnitude>0 then
                        local d = args[2]
                        args[2] = d + d.Unit * (gunModState.meleeReachDist or 10)
                        return oldNC(self, table.unpack(args,1,args.n))
                    elseif method=="Spherecast" and typeof(args[2])=="Vector3" and args[2].Magnitude>0 then
                        local d = args[2]
                        args[2] = d + d.Unit * (gunModState.meleeReachDist or 10)
                        return oldNC(self, table.unpack(args,1,args.n))
                    elseif method=="Blockcast" and typeof(args[2])=="Vector3" and args[2].Magnitude>0 then
                        local d = args[2]
                        args[2] = d + d.Unit * (gunModState.meleeReachDist or 10)
                        return oldNC(self, table.unpack(args,1,args.n))
                    end
                end
            end

            if method=="FireServer" and typeof(self)=="Instance" and self.Name=="ProjectileInflict" then
                local tb = type(debug)=="table" and type(debug.traceback)=="function" and debug.traceback() or nil
                if type(tb)=="string" and tb:find("CharacterController",1,true) then
                    return coroutine.yield()
                end
                if aimState.instaHit then
                    local args = table.pack(...)
                    local proj = aimState.fired_projectiles[args[3]] or aimState.fired_projectiles[args[2]]
                    if proj then
                        aimState.fired_projectiles[args[3]] = nil
                        aimState.fired_projectiles[args[2]] = nil
                        args[4] = proj[2] + (aimState.emulated_tick or 5)
                        return oldNC(self, table.unpack(args,1,math.max(args.n,4)))
                    end
                    return oldNC(self, ...)
                end
            end

            if method == "InvokeServer" and typeof(self) == "Instance" and self.Name == "FireProjectile" then
                local args = table.pack(...)
                if args[2] ~= nil then
                    local cache = aimState.fired_projectiles
                    local n = 0
                    for _ in pairs(cache) do n = n + 1 end
                    if n >= 64 then table.clear(cache) end
                    cache[args[2]] = { args[2], args[3], args[1] }
                end
                return oldNC(self, table.unpack(args, 1, args.n))
            end

            if method == "Raycast" and (aimState.silentAim or aimState.magicBullet) then
                local k = table.pack(...)
                if typeof(k[1]) ~= "Vector3" or typeof(k[2]) ~= "Vector3" then
                    return oldNC(self, ...)
                end
                local isWorld = self == workspace
                local tb = type(debug)=="table" and type(debug.traceback)=="function" and debug.traceback() or nil
                local fromBullet = type(tb) == "string" and tb:find("Bullet", 1, true) ~= nil
                if not fromBullet and not isWorld then
                    return oldNC(self, ...)
                end
                local hitbox = aimState.targetPart
                if not (hitbox and hitbox.Parent) then
                    local nowR = os.clock()
                    if nowR - (State.aimFallbackAt or 0) >= 0.05 then
                        State.aimFallbackAt = nowR
                        pcall(scanAimTarget)
                    end
                    hitbox = aimState.targetPart
                end
                if not (hitbox and hitbox.Parent) then
                    return oldNC(self, ...)
                end
                local r = hitbox.Position
                hookState.redirects = (hookState.redirects or 0) + 1
                if not hookState.announced then
                    hookState.announced = true
                    pcall(function() task.defer(function()
                        local sg = game:GetService("StarterGui")
                        if sg and sg.SetCore then
                            sg:SetCore("SendNotification", { Title = "Omni", Text = "Silent aim redirecting", Duration = 3 })
                        end
                    end) end)
                end
                if aimState.wallbang then
                    return {
                        Instance = hitbox,
                        Position = r,
                        Distance = (r - k[1]).Magnitude,
                        Normal = Vector3.new(1, 0, 0),
                        Material = hitbox.Material,
                    }
                end
                k[2] = r - k[1]
                return oldNC(self, table.unpack(k, 1, k.n))
            end

            return oldNC(self,...)
    end)
    local function captureOriginal()
        local cur
        pcall(function()
            local m = rawMT or (type(getrawmetatable)=="function" and getrawmetatable(game))
            if m then cur = m.__namecall end
        end)
        if type(cur)=="function" and cur ~= hooked then return cur end
        return nil
    end

    oldNC = captureOriginal()
    local installed = false
    local prevFn
    local ok = pcall(function()
        prevFn = hookmetamethod(game, "__namecall", hooked)
    end)
    if ok then
        if type(prevFn)=="function" and prevFn ~= hooked then
            oldNC = prevFn
            installed = true
        elseif oldNC then
            installed = true
        end
    end
    if not installed then
        local cur = captureOriginal()
        if cur then
            oldNC = cur
            pcall(function()
                local m = rawMT or getrawmetatable(game)
                setreadonly(m, false)
                m.__namecall = hooked
                setreadonly(m, true)
            end)
            installed = true
        end
    end
    if rawMT ~= nil then
        pcall(function() setreadonly(rawMT, mtWasReadOnly ~= false) end)
    end
    if not installed and oldNC then
        pcall(function() hookmetamethod(game, "__namecall", oldNC) end)
    end
    if installed and oldNC and oldNC ~= hooked then
        gg.__OmniAimHook = {
            state = hookState,
            hits = function() return hookState.hits end,
            redirects = function() return hookState.redirects or 0 end,
            restore = function()
                hookState.active = false
                pcall(function() hookmetamethod(game, "__namecall", oldNC) end)
            end,
        }
        State.aimHookReady = true
    end
end

task.spawn(function()
    for _ = 1, 50 do
        if shuttingDown then return end
        ensureAimHook()
        if State.aimHookReady then return end
        task.wait(0.2)
    end
end)

conn(RunService.RenderStepped, function(dt)
    local aim = LegitAim
    local cam = workspace.CurrentCamera
    if not cam then return end
    if not aim.enabled then aim.target=nil; aim.targetPart=nil; return end
    if UIS:GetFocusedTextBox() then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        if not aim.sticky then aim.target=nil; aim.targetPart=nil end
        return
    end
    local vp = cam.ViewportSize
    local cx, cy = vp.X*0.5, vp.Y*0.5
    local now = os.clock()
    if aim.sticky and aim.targetPart and aim.targetPart.Parent then
        aim.target = aim.targetPart.Position
    elseif now - aim.lastScan >= 0.05 then
        aim.lastScan = now
        local best, bestD = nil, aim.fov
        for _, plr in ipairs(Players:GetPlayers()) do
            local ch = plr.Character
            if plr~=Player and not onSameTeam(plr) and characterAlive(ch) and not isDowned(ch) and not (aimState.blacklistEnabled and aimState.blacklist and aimState.blacklist[string.lower(plr.Name)]) then
                local p = ch:FindFirstChild(aim.aimPart) or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
                if p then
                    local s, on = cam:WorldToViewportPoint(p.Position)
                    if on and s.Z>0 then
                        local d = math.sqrt((s.X-cx)^2+(s.Y-cy)^2)
                        if d<=bestD and (not aim.wallCheck or isVisible(ch, p.Position)) then
                            bestD=d; best=p
                        end
                    end
                end
            end
        end
        if aimState.targetAI ~= false then
            local zones = workspace:FindFirstChild("AiZones")
            if zones then
                for _, z in ipairs(zones:GetChildren()) do
                    for _, m in ipairs(z:GetChildren()) do
                        if m.Name=="MI24V" or m.Name=="BTR80" then continue end
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 and not isDowned(m) then
                            local p = m:FindFirstChild(aim.aimPart) or m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                            if p and p:IsA("BasePart") then
                                local s, on = cam:WorldToViewportPoint(p.Position)
                                if on and s.Z>0 then
                                    local d = math.sqrt((s.X-cx)^2+(s.Y-cy)^2)
                                    if d<=bestD and (not aim.wallCheck or isVisible(m, p.Position)) then
                                        bestD=d; best=p
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        aim.targetPart = best
        aim.target = best and best.Position
    end
    local tp = aim.targetPart
    if not tp or not tp.Parent then return end
    local vel = tp.AssemblyLinearVelocity or Vector3.zero
    local desired = CFrame.lookAt(cam.CFrame.Position, tp.Position + vel*aim.prediction)
    cam.CFrame = cam.CFrame:Lerp(desired, math.clamp(dt*math.max(aim.smoothness,1),0,1))
end)

State.espElapsed = 0
conn(UIS.InputBegan, function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        aimState.lmbHeld=true; aimState.firing=true
    end
end)
conn(UIS.InputEnded, function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        aimState.lmbHeld=false; aimState.firing=false
    end
end)

conn(RunService.RenderStepped, function(dt)
    if shuttingDown then return end
    local now = os.clock()

    if aimState.silentAim or aimState.instaHit or aimState.magicBullet
        or gunModState.noSpread or gunModState.removeWeight or gunModState.removeAimRestrictions
        or gunModState.meleeReach or gunModState.ignoreWater or gunModState.noSway or gunModState.noObstruct
        or gunModState.instantLean or gunModState.removeSandboxing or gunModState.sprintShoot
        or gunModState.removeMuzzle or gunModState.removeSprintAnimation or gunModState.unlockFiremodes then
        ensureAimHook()
    end

    if (aimState.silentAim or aimState.magicBullet or aimState.instaHit) and type(installBulletHook) == "function" then
        if now - (State.bulletCheckAt or 0) >= 1 then
            State.bulletCheckAt = now
            pcall(installBulletHook)
        end
    end

    if aimState.silentAim or aimState.magicBullet then
        if now - aimState.lastScan >= 0 then
            aimState.lastScan = now
            local okScan, errScan = pcall(scanAimTarget)
            if not okScan and not State.aimScanWarned then
                State.aimScanWarned = true
                warn("[Omni] aim scan error: " .. tostring(errScan))
            end
        end
        if aimState.silentAim or aimState.magicBullet then
            local cam = workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(1920,1080)
            aimFovRing.Visible = true
            aimFovRing.Size = UDim2.fromOffset(aimState.fov*2, aimState.fov*2)
            aimFovRing.Position = UDim2.fromOffset(vp.X*0.5, vp.Y*0.5)
            aimFovStroke.Color = aimState.fovColor
            pcall(updateAimTracer)
            pcall(updateAimTargetLine)
        else
            aimFovRing.Visible = false
            hideAimTracer()
            hideAimTargetLine()
        end
    else
        aimFovRing.Visible = false
        hideAimTracer()
        hideAimTargetLine()
        aimState.target=nil; aimState.targetPart=nil; aimState.targetName=nil; aimState.eye=nil
    end

    aimState.lmbHeld = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    aimState.firing = aimState.lmbHeld

    if (aimState.silentAim or aimState.magicBullet or aimState.instaHit) and aimState.firing and State.aimHookReady then
        if now - (State.aimHookCheckAt or 0) >= 2.5 then
            State.aimHookCheckAt = now
            local h = gg.__OmniAimHook
            local hits = type(h) == "table" and type(h.hits) == "function" and h.hits() or 0
            if hits == (State.aimHookCheckHits or 0) then
                ensureAimHook(true)
            end
            State.aimHookCheckHits = hits
        end
    end

    if aimState.triggerbot then
        local cam = workspace.CurrentCamera
        local trigPart = nil
        if cam then
            local ml = UIS:GetMouseLocation()
            local fov = aimState.fov
            local best = fov
            for _, plr in ipairs(Players:GetPlayers()) do
                local ch = plr.Character
                if plr~=Player and not onSameTeam(plr) and characterAlive(ch) and not isDowned(ch) and not (aimState.blacklistEnabled and aimState.blacklist and aimState.blacklist[string.lower(plr.Name)]) then
                    local p = resolveAimPart(ch)
                    if p then
                        local s,on = cam:WorldToViewportPoint(p.Position)
                        if on and s.Z>0 then
                            local d = math.sqrt((s.X-ml.X)^2+(s.Y-ml.Y)^2)
                            if d<=best and isVisible(ch,p.Position) then best=d; trigPart=p end
                        end
                    end
                end
            end
        end
        if trigPart and trigPart.Parent then
            if aimState.triggerTarget~=trigPart then
                aimState.triggerTarget=trigPart
                aimState.triggerReadyAt=now+(math.max(0,aimState.triggerDelay)/1000)
            end
            if now>=aimState.triggerReadyAt and not aimState.triggerHeld then
                if math.random(1,100)<=math.clamp(aimState.triggerChance,1,100) then
                    local press = (getgenv and getgenv() or _G).mouse1press or mouse1press
                    if type(press)=="function" then
                        pcall(press); aimState.triggerHeld=true; aimState.triggerPressAt=now
                    end
                end
                aimState.triggerReadyAt=now+(math.max(0,aimState.triggerDelay)/1000)
            end
        else
            aimState.triggerTarget=nil
            if aimState.triggerHeld and now-aimState.triggerPressAt>=0.1 then
                local rel = (getgenv and getgenv() or _G).mouse1release or mouse1release
                if type(rel)=="function" then pcall(rel) end
                aimState.triggerHeld=false
            end
        end
    elseif aimState.triggerHeld then
        local rel = (getgenv and getgenv() or _G).mouse1release or mouse1release
        if type(rel)=="function" then pcall(rel) end
        aimState.triggerHeld=false; aimState.triggerTarget=nil
    end

    State.espElapsed = State.espElapsed + dt
    if State.espElapsed >= 1/math.clamp(espState.refreshRate,30,240) then
        State.espElapsed = 0
        local ok, err = pcall(renderESP)
        if not ok and not State.espWarned then
            State.espWarned = true
            warn("[Omni] ESP render error: "..tostring(err))
        end
    end
end)

local flyParts, flyPartIdx, flyChar = {}, {}, nil
local flyAddConn, flyRemConn

local function flyAddPart(p)
    if p and p:IsA("BasePart") and not flyPartIdx[p] then
        local i = #flyParts+1; flyParts[i]=p; flyPartIdx[p]=i
    end
end
local function flyRemPart(p)
    local i = flyPartIdx[p]; if not i then return end
    local last = flyParts[#flyParts]; flyParts[i]=last; flyParts[#flyParts]=nil
    flyPartIdx[p]=nil; if last and last~=p then flyPartIdx[last]=i end
end
local function flyBind(ch)
    if flyAddConn then flyAddConn:Disconnect() end
    if flyRemConn then flyRemConn:Disconnect() end
    table.clear(flyParts); table.clear(flyPartIdx); flyChar=ch
    if not ch then return end
    for _,p in ipairs(ch:GetDescendants()) do flyAddPart(p) end
    flyAddConn = ch.DescendantAdded:Connect(flyAddPart)
    flyRemConn = ch.DescendantRemoving:Connect(flyRemPart)
end

local defaultFov, fovApplied, walkApplied = nil, false, false

local waterPlatform = nil
local waterLastUpdate = 0
local mosesTerr = workspace:FindFirstChildOfClass("Terrain")
local mosesSaved = {}
local mosesWarned = false

local function clearWaterPlatform()
    if waterPlatform then
        pcall(function() waterPlatform:Destroy() end)
        waterPlatform = nil
    end
end

local function mosesRestore(rec)
    pcall(function()
        local mats,occ = mosesTerr:ReadVoxels(rec.reg,4)
        for _,c in ipairs(rec.cells) do
            local mx = mats[c[1]]
            if mx and mx[c[2]] and mx[c[2]][c[3]] == Enum.Material.Air then
                mx[c[2]][c[3]] = Enum.Material.Water
                occ[c[1]][c[2]][c[3]] = c[4]
            end
        end
        mosesTerr:WriteVoxels(rec.reg,4,mats,occ)
    end)
end

local function mosesGiveBack(all,pos)
    for k,rec in pairs(mosesSaved) do
        if all or not pos or (rec.c-pos).Magnitude > 60 then
            mosesSaved[k] = nil
            mosesRestore(rec)
        end
    end
end

local function restoreMoses()
    if next(mosesSaved) and mosesTerr then mosesGiveBack(true) end
end

local function updateWalkOnWater(root)
    if not root or not root.Parent then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Player.Character, waterPlatform}
    local waterY = nil
    for _, offset in ipairs({6, 30, 80}) do
        local result = workspace:Raycast(root.Position + Vector3.new(0, offset, 0), Vector3.new(0, -200, 0), params)
        if result then
            local hit = result.Instance
            if hit and (hit.Material == Enum.Material.Water or string.find(string.lower(hit.Name or ""), "water", 1, true) or string.find(string.lower(hit.Name or ""), "ocean", 1, true)) then
                waterY = result.Position.Y
                break
            end
        end
    end
    if not waterY then
        clearWaterPlatform()
        return
    end
    if root.Position.Y > waterY + 14 then
        clearWaterPlatform()
        return
    end
    if not waterPlatform then
        local p = Instance.new("Part")
        p.Name = "OmniWaterPlatform"
        p.Anchored = true
        p.CanCollide = true
        p.CanQuery = false
        p.CanTouch = false
        p.Transparency = 1
        p.CastShadow = false
        p.Size = Vector3.new(14, 0.5, 14)
        p.Parent = workspace
        waterPlatform = p
    end
    waterPlatform.CFrame = CFrame.new(root.Position.X, waterY + 0.15, root.Position.Z)
    waterPlatform.Parent = workspace
end

task.spawn(function()
    while not shuttingDown do
        local ch = Player.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if movementState.waterMode == "Moses" then
            mosesTerr = mosesTerr or workspace:FindFirstChildOfClass("Terrain")
            if mosesTerr and r then
                local ok,err = pcall(function()
                    local p = r.Position
                    mosesGiveBack(false,p)
                    local reg = Region3.new(p-Vector3.new(24,24,24),p+Vector3.new(24,24,24)):ExpandToGrid(4)
                    local mats,occ = mosesTerr:ReadVoxels(reg,4)
                    local sz = mats.Size
                    local cells
                    for x=1,sz.X do
                        for y=1,sz.Y do
                            for z=1,sz.Z do
                                if mats[x][y][z] == Enum.Material.Water then
                                    cells = cells or {}
                                    cells[#cells+1] = {x,y,z,occ[x][y][z]}
                                    mats[x][y][z] = Enum.Material.Air
                                    occ[x][y][z] = 0
                                end
                            end
                        end
                    end
                    if cells then
                        mosesTerr:WriteVoxels(reg,4,mats,occ)
                        mosesSaved[tostring(reg.CFrame.Position)..tostring(os.clock())] = {reg=reg,cells=cells,c=reg.CFrame.Position}
                    end
                end)
                if not ok and not mosesWarned then
                    mosesWarned = true
                    pcall(function() Library:Notify("Moses error: "..tostring(err),8) end)
                end
            end
        elseif next(mosesSaved) and mosesTerr then
            mosesGiveBack(true)
        end
        task.wait(0.3)
    end
end)

conn(RunService.RenderStepped, function(dt)
    local ch = Player.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        if movementState.speedEnabled then
            local t = math.clamp(movementState.speedValue,16,22)
            if hum.WalkSpeed~=t then hum.WalkSpeed=t end
            walkApplied=true
        elseif walkApplied then
            walkApplied=false; pcall(function() hum.WalkSpeed=16 end)
        end
    end

    if movementState.noFallEnabled and hum and hum.Health > 0 then
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root and hum:GetState() == Enum.HumanoidStateType.Freefall and root.AssemblyLinearVelocity.Y < -12.5 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landed) end)
        end
    end

    local cam = workspace.CurrentCamera
    if cam then
        if not defaultFov then defaultFov=cam.FieldOfView; movementState._defaultFov=defaultFov end
        local zoomHeld = movementState._zoomActive
        if not zoomHeld and Options and Options.ZoomKey and type(Options.ZoomKey.GetState)=="function" then
            local okz, st = pcall(function() return Options.ZoomKey:GetState() end)
            zoomHeld = okz and st
        end
        if movementState.zoomEnabled and zoomHeld then
            if cam.FieldOfView~=movementState.zoomFov then cam.FieldOfView=movementState.zoomFov end
            fovApplied=true
        elseif movementState.fovEnabled then
            if cam.FieldOfView~=movementState.fovValue then cam.FieldOfView=movementState.fovValue end
            fovApplied=true
        elseif fovApplied then
            fovApplied=false; pcall(function() cam.FieldOfView=defaultFov end)
        end
    end

    local now = os.clock()
    if movementState.waterMode ~= "Off" and now - waterLastUpdate >= 0.1 then
        waterLastUpdate = now
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root then
            if movementState.waterMode == "Walk on Water" then
                restoreMoses()
                updateWalkOnWater(root)
            elseif movementState.waterMode == "Moses" then
                clearWaterPlatform()
            end
        end
    elseif movementState.waterMode == "Off" then
        clearWaterPlatform()
        restoreMoses()
    end

    if not movementState.flyEnabled then
        if flyChar then flyBind(nil) end
        return
    end
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not (ch and root and cam) then return end
    if root.Anchored then root.Anchored=false end
    if flyChar~=ch then flyBind(ch) end
    local lv = cam.CFrame.LookVector
    local flat = Vector3.new(lv.X,0,lv.Z)
    if flat.Magnitude>0.001 then flat=flat.Unit else flat=Vector3.new(0,0,-1) end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+flat end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-flat end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+Vector3.new(-flat.Z,0,flat.X) end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir+Vector3.new(flat.Z,0,-flat.X) end
    if dir.Magnitude>0.001 then dir=dir.Unit end
    local vert = 0
    if UIS:IsKeyDown(Enum.KeyCode.Space) then vert=1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vert=vert-1 end
    local step = math.clamp(dt,0,0.05)
    root.CFrame = root.CFrame + dir*step*movementState.flySpeed + Vector3.new(0,vert*step*movementState.flyVSpeed,0)
    for i=1,#flyParts do
        local p=flyParts[i]
        if p.Parent and p.AssemblyLinearVelocity.Magnitude>0 then p.AssemblyLinearVelocity=Vector3.zero end
    end
end)

local function getMineFolder()
    local az = workspace:FindFirstChild("AiZones")
    return az and az:FindFirstChild("OutpostLandmines")
end

local function explodeLandmines(mode)
    local folder = getMineFolder()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local kids = folder and folder:GetChildren() or {}
    if #kids == 0 or not root then
        pcall(function() Library:Notify("Couldn't find any landmines", 3) end)
        return
    end
    if type(firetouchinterest) ~= "function" then
        pcall(function() Library:Notify("Executor has no firetouchinterest", 3) end)
        return
    end
    local n = 0
    for _, m in ipairs(kids) do
        local t = m:FindFirstChild("Trigger")
        if t and t:IsA("BasePart") then
            pcall(function()
                firetouchinterest(root, t, 0)
                task.wait()
                firetouchinterest(root, t, 1)
            end)
            n = n + 1
            if mode == "One" then break end
        end
    end
    pcall(function() Library:Notify("Exploded "..n.." landmine"..(n==1 and "" or "s"), 3) end)
end

local reachOriginal = nil
local function setExtendReach(enabled)
    local ok, settings = pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local gs = modules and modules:FindFirstChild("GameSettings")
        return gs and require(gs)
    end)
    if not ok or type(settings) ~= "table" or type(settings.InteractionDistance) ~= "number" then
        pcall(function() Library:Notify("Extend Reach: GameSettings unreachable", 4) end)
        return
    end
    if enabled then
        if reachOriginal == nil then reachOriginal = settings.InteractionDistance end
        settings.InteractionDistance = 15
    else
        if reachOriginal ~= nil then
            settings.InteractionDistance = reachOriginal
            reachOriginal = nil
        end
    end
end

conn(Player.CharacterAdded, function()
    task.wait(2)
    if movementState.extendReach then pcall(setExtendReach, true) end
end)

local pbPos = nil
local pbBusy = false
conn(RunService.Heartbeat, function()
    if movementState.flyEnabled or not movementState.peekBlink then
        if not movementState.peekBlink then pbPos = nil end
        return
    end
    local ch = Player.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root or pbBusy then return end
    if not pbPos then pbPos = root.CFrame end
    pbBusy = true
    local cf, vel = root.CFrame, root.AssemblyLinearVelocity
    root.Anchored = true
    RunService.RenderStepped:Wait()
    if root.Parent then
        root.Anchored = false
        root.CFrame = cf
        root.AssemblyLinearVelocity = vel
    end
    pbBusy = false
end)

local worldDefaults = {
    Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
    FogStart=Lighting.FogStart, FogEnd=Lighting.FogEnd, FogColor=Lighting.FogColor,
    GlobalShadows=Lighting.GlobalShadows,
    Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
}
local worldBloom = Instance.new("BloomEffect",Lighting); worldBloom.Name="OmniWorldBloom"; worldBloom.Enabled=false
local worldGrade = Instance.new("ColorCorrectionEffect",Lighting); worldGrade.Name="OmniWorldGrade"; worldGrade.Enabled=false
State.worldBrightCC = Instance.new("ColorCorrectionEffect",Lighting)
State.worldBrightCC.Name="OmniWorldBright"; State.worldBrightCC.Brightness=0.06; State.worldBrightCC.Contrast=0.05; State.worldBrightCC.Enabled=false

local worldSky, worldHiddenSkies, worldOldLat = nil, {}, nil
local worldAtmo, worldAtmoDefaults, worldAtmoCreated = nil, nil, false
local worldCloudsFx, worldCloudDefaults, worldCloudCreated = nil, nil, false
State.worldHiddenClouds = {}
local worldTerrainActive, worldTerrainColors = nil, {}
State.worldWaterDefaults = nil
State.worldPotatoMaterials = setmetatable({},{__mode="k"})
State.worldFoliageOriginals = setmetatable({},{__mode="k"})
local worldGrassApplied = false
local worldLightApplied, worldClockApplied, worldFogApplied = false, false, false

local function applyLighting()
    local want = worldFx.fullBright or worldFx.ambientOn
    if not want and not worldLightApplied then return end
    if worldFx.fullBright then
        Lighting.Brightness=3; Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1)
    elseif worldFx.ambientOn then
        Lighting.Ambient=worldFx.ambientA; Lighting.OutdoorAmbient=worldFx.ambientB
    else
        Lighting.Brightness=worldDefaults.Brightness; Lighting.GlobalShadows=worldDefaults.GlobalShadows
        Lighting.Ambient=worldDefaults.Ambient; Lighting.OutdoorAmbient=worldDefaults.OutdoorAmbient
    end
    State.worldBrightCC.Enabled = worldFx.fullBright
    worldLightApplied = want
end

local function worldApplyClock()
    local want = worldFx.timeOn or worldFx.fullBright
    if not want and not worldClockApplied then return end
    Lighting.ClockTime = want and (worldFx.timeOn and worldFx.timeVal or 12) or worldDefaults.ClockTime
    worldClockApplied = want
end

local function worldApplyFog()
    local want = worldFx.fogOn or worldFx.noFog or worldFx.fullBright
    if not want and not worldFogApplied then return end
    if worldFx.fogOn then
        Lighting.FogStart=worldFx.fogStart
        Lighting.FogEnd=math.max(worldFx.fogEnd,worldFx.fogStart+1)
        Lighting.FogColor=worldFx.fogColor
    elseif want then
        Lighting.FogStart=0; Lighting.FogEnd=100000
    else
        Lighting.FogStart=worldDefaults.FogStart; Lighting.FogEnd=worldDefaults.FogEnd; Lighting.FogColor=worldDefaults.FogColor
    end
    worldFogApplied = want
end

local function worldApplySky()
    if not worldFx.skyOn then
        if worldSky then worldSky:Destroy(); worldSky=nil end
        for sky in pairs(worldHiddenSkies) do if sky and sky.Parent==nil then sky.Parent=Lighting end; worldHiddenSkies[sky]=nil end
        if worldOldLat~=nil then Lighting.GeographicLatitude=worldOldLat; worldOldLat=nil end
        return
    end
    for _,child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child~=worldSky then worldHiddenSkies[child]=true; child.Parent=nil end
    end
    if not worldSky or worldSky.Parent~=Lighting then
        worldSky=Instance.new("Sky"); worldSky.Name="OmniWorldSky"; worldSky.Parent=Lighting
    end
    local preset = WORLD_SKY_PRESETS[worldFx.skyPreset] or WORLD_SKY_PRESETS[1]
    local ids = preset.ids
    local function asset(id) return "rbxassetid://"..id end
    worldSky.SkyboxBk=asset(ids[1]); worldSky.SkyboxFt=asset(ids[3])
    worldSky.SkyboxLf=asset(ids[4]); worldSky.SkyboxRt=asset(ids[5])
    worldSky.SkyboxDn=asset(ids[2]); worldSky.SkyboxUp=asset(ids[6])
    if worldOldLat==nil then worldOldLat=Lighting.GeographicLatitude end
    Lighting.GeographicLatitude=math.clamp(worldFx.skyRotX,-90,90)
end

local function worldApplyAtmosphere()
    if worldFx.atmoOn then
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if not atmo then atmo=Instance.new("Atmosphere",Lighting); atmo.Name="OmniWorldAtmo"; worldAtmoCreated=true end
        if not worldAtmoDefaults then
            worldAtmoDefaults={Density=atmo.Density,Offset=atmo.Offset,Color=atmo.Color,Decay=atmo.Decay,Glare=atmo.Glare,Haze=atmo.Haze}
        end
        worldAtmo=atmo
        atmo.Density=math.clamp(worldFx.atmoDensity/100,0,1); atmo.Haze=math.clamp(worldFx.atmoHaze,0,10)
        atmo.Glare=math.clamp(worldFx.atmoGlare,0,10); atmo.Offset=math.clamp(worldFx.atmoOffset/100,-1,1)
        atmo.Color=worldFx.atmoColor; atmo.Decay=worldFx.atmoDecay
    elseif worldAtmo then
        if worldAtmoCreated then pcall(function() worldAtmo:Destroy() end)
        elseif worldAtmoDefaults and worldAtmo.Parent then
            pcall(function()
                worldAtmo.Density=worldAtmoDefaults.Density; worldAtmo.Offset=worldAtmoDefaults.Offset
                worldAtmo.Color=worldAtmoDefaults.Color; worldAtmo.Decay=worldAtmoDefaults.Decay
                worldAtmo.Glare=worldAtmoDefaults.Glare; worldAtmo.Haze=worldAtmoDefaults.Haze
            end)
        end
        worldAtmo=nil; worldAtmoDefaults=nil; worldAtmoCreated=false
    end
end

local function worldApplyPotatoMaterials()
    if worldFx.potato then
        local n = 0
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                if State.worldPotatoMaterials[d]==nil then State.worldPotatoMaterials[d]=d.Material end
                if d.Material~=Enum.Material.SmoothPlastic then pcall(function() d.Material=Enum.Material.SmoothPlastic end) end
                n = n + 1
                if n % 400 == 0 then task.wait() end
            end
        end
    else
        for part,orig in pairs(State.worldPotatoMaterials) do
            if part and part.Parent then pcall(function() part.Material=orig end) end
            State.worldPotatoMaterials[part]=nil
        end
    end
end

local function worldApplyGrass()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end
    local on = not worldFx.removeGrass
    if not worldFx.removeGrass and not worldGrassApplied then return end
    if type(sethiddenproperty) == "function" then
        local ok = pcall(sethiddenproperty, terrain, "Decoration", on)
        if ok then worldGrassApplied = not on; return end
    end
    if pcall(function() terrain.Decoration = on end) then
        worldGrassApplied = not on
    end
end

local function worldFoliageFolder()
    local zones = workspace:FindFirstChild("SpawnerZones")
    return zones and zones:FindFirstChild("Foliage")
end

local TREE_COLOR = Color3.fromRGB(108,88,75)

local function worldApplyFoliagePart(part)
    if not part or not part:IsA("BasePart") then return end
    local hide = false
    if part:IsA("MeshPart") then
        local tree = part.Color == TREE_COLOR
        hide = (tree and worldFx.noTrees) or ((not tree) and worldFx.noFoliage)
    end
    if not hide and worldFx.noLeaves and part:FindFirstChildOfClass("SurfaceAppearance") then
        hide = true
    end
    if hide then
        if State.worldFoliageOriginals[part] == nil then
            State.worldFoliageOriginals[part] = part.Transparency
        end
        if part.Transparency ~= 1 then part.Transparency = 1 end
    else
        local orig = State.worldFoliageOriginals[part]
        if orig ~= nil then
            if part.Parent then pcall(function() part.Transparency = orig end) end
            State.worldFoliageOriginals[part] = nil
        end
    end
end

local worldFoliageWatched, worldFoliageConn, worldFoliageKey = nil, nil, nil
local function worldBindFoliage(folder)
    if worldFoliageWatched == folder then return end
    if worldFoliageConn then pcall(function() worldFoliageConn:Disconnect() end); worldFoliageConn = nil end
    worldFoliageWatched = folder
    if folder then
        worldFoliageConn = conn(folder.DescendantAdded, function(d)
            if d:IsA("BasePart") then
                worldApplyFoliagePart(d)
            elseif d:IsA("SurfaceAppearance") and d.Parent and d.Parent:IsA("BasePart") then
                worldApplyFoliagePart(d.Parent)
            end
        end)
    end
end

local function worldApplyFoliage()
    local key = (worldFx.noFoliage and 1 or 0) + (worldFx.noTrees and 2 or 0) + (worldFx.noLeaves and 4 or 0)
    local folder = worldFoliageFolder()

    if folder == worldFoliageWatched and worldFoliageKey == key
        and (key ~= 0 or next(State.worldFoliageOriginals) == nil) then
        return
    end
    worldBindFoliage(folder)
    worldFoliageKey = key
    if not folder then
        if key == 0 then
            for part, orig in pairs(State.worldFoliageOriginals) do
                if part and part.Parent then pcall(function() part.Transparency = orig end) end
                State.worldFoliageOriginals[part] = nil
            end
        end
        return
    end
    task.spawn(function()
        local n = 0
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("BasePart") then worldApplyFoliagePart(d) end
            n = n + 1
            if n % 250 == 0 then task.wait() end
        end
    end)
end

local function worldApplyClouds()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    local containers = { terrain, Lighting }
    if worldFx.noClouds then
        for _, c in ipairs(containers) do
            if c then
                local clouds = c:FindFirstChildOfClass("Clouds")
                if clouds and clouds.Enabled then
                    State.worldHiddenClouds[clouds] = true
                    pcall(function() clouds.Enabled = false end)
                end
            end
        end
    else
        for clouds in pairs(State.worldHiddenClouds) do
            if clouds and clouds.Parent then pcall(function() clouds.Enabled = true end) end
            State.worldHiddenClouds[clouds] = nil
        end
    end
end

conn(workspace.DescendantAdded, function(d)
    if d.Name == "Foliage" and d:IsA("Folder") then
        task.defer(function()
            if not d.Parent then return end
            if worldFx.noFoliage or worldFx.noTrees or worldFx.noLeaves then
                pcall(worldApplyFoliage)
            end
        end)
    end
end)

conn(workspace.DescendantAdded, function(d)
    if worldFx.potato and d:IsA("BasePart") then
        if State.worldPotatoMaterials[d]==nil then State.worldPotatoMaterials[d]=d.Material end
        pcall(function() d.Material=Enum.Material.SmoothPlastic end)
    end
end)

local function worldApplyAll()
    worldApplyClock(); applyLighting(); worldApplyFog()
    worldApplySky(); worldApplyAtmosphere(); worldApplyPotatoMaterials()
    worldApplyGrass(); worldApplyFoliage(); worldApplyClouds()
    worldBloom.Enabled = worldFx.bloomOn
    if worldFx.bloomOn then
        worldBloom.Intensity=math.clamp(worldFx.bloomIntensity,0,5)
        worldBloom.Size=math.clamp(worldFx.bloomSize,0,56)
        worldBloom.Threshold=math.clamp(worldFx.bloomThreshold,0,2)
    end
    worldGrade.Enabled = worldFx.gradeOn
    if worldFx.gradeOn then
        worldGrade.TintColor=worldFx.gradeTint
        worldGrade.Saturation=math.clamp(worldFx.gradeSat/100,-1,1.5)
        worldGrade.Contrast=math.clamp(worldFx.gradeContrast/100,-1,1)
        worldGrade.Brightness=math.clamp(worldFx.gradeBrightness/100,-1,1)
    end
end

State.worldLastTick = 0
conn(RunService.RenderStepped, function()
    local now = os.clock()
    if worldFx.timeOn or worldFx.fullBright then worldApplyClock() end
    if worldFx.ambientOn or worldFx.fullBright then applyLighting() end
    if now-State.worldLastTick<0.5 then return end
    State.worldLastTick=now
    worldApplyFog(); worldApplyAtmosphere()
end)

State.gunModAmmoOriginals = setmetatable({}, {__mode="k"})
State.gunModWeaponOriginals = setmetatable({}, {__mode="k"})
State.gunModMuzzleOriginals = setmetatable({}, {__mode="k"})
State.gunModRechamberOriginals = setmetatable({}, {__mode="k"})

local function gunModApplyAmmo()
    local folder = ReplicatedStorage:FindFirstChild("AmmoTypes")
    if not folder then return end
    for _, ammo in ipairs(folder:GetChildren()) do
        if not State.gunModAmmoOriginals[ammo] then
            State.gunModAmmoOriginals[ammo] = {
                drop=ammo:GetAttribute("ProjectileDrop"),
                drag=ammo:GetAttribute("Drag"),
            }
        end
        local orig = State.gunModAmmoOriginals[ammo]
        pcall(function()
            ammo:SetAttribute("ProjectileDrop", gunModState.noDrop and 0 or orig.drop)
            ammo:SetAttribute("Drag", gunModState.noDrag and 0 or orig.drag)
        end)
    end
end

task.spawn(function()
    local hookedShove = setmetatable({}, {__mode="k"})
    local hookedUpdate = setmetatable({}, {__mode="k"})
    while not shuttingDown do

        pcall(gunModApplyAmmo)

        local needGC = gunModState.noRecoil or gunModState.noBob or gunModState.noBolt
            or gunModState.instantEquip or gunModState.rapidFire or gunModState.forceAuto
            or gunModState.removeRechamber or gunModState.noSpread or gunModState.instantAim
            or gunModState.unlockFiremodes or gunModState.removeSprintAnimation
        if needGC and type(getgc)=="function" and type(hookfunction)=="function" then
            local gc
            local ok, res = pcall(getgc, true)
            if ok and type(res)=="table" then
                gc = res
            else
                ok, res = pcall(getgc)
                if ok and type(res)=="table" then gc = res end
            end
            if type(gc)=="table" then
                for _, obj in ipairs(gc) do
                    if type(obj)=="table" then
                        local shove = rawget(obj,"shove")
                        local update = rawget(obj,"update")

                        local isSpringTable = rawget(obj,"position") ~= nil
                            or rawget(obj,"velocity") ~= nil
                            or rawget(obj,"stiffness") ~= nil
                            or rawget(obj,"damping") ~= nil
                        if not gg.__OmniSoftHooks and not isSpringTable
                            and type(shove)=="function" and type(update)=="function" then
                            if not hookedShove[shove] then
                                local old
                                local okh = pcall(function()
                                    old = hookfunction(shove, function(...)
                                        if gunModState.noRecoil then return end
                                        if not old then return end
                                        return old(...)
                                    end)
                                end)
                                if okh and old then hookedShove[shove]=true end
                            end
                            if not hookedUpdate[update] then
                                local old
                                local okh = pcall(function()
                                    old = hookfunction(update, function(...)
                                        if not old then return end
                                        if gunModState.noBob then

                                            pcall(old, ...)
                                            return Vector3.zero
                                        end
                                        return old(...)
                                    end)
                                end)
                                if okh and old then hookedUpdate[update]=true end
                            end
                        end

                        local updateClient = rawget(obj, "updateClient")
                        if type(updateClient)=="function" and not hookedUpdate[updateClient]
                            and (rawget(obj,"shove") or rawget(obj,"FireMode") or rawget(obj,"AimInSpeed") or rawget(obj,"settings")) then
                            local old
                            local okh = pcall(function()
                                old = hookfunction(updateClient, function(...)
                                    if not old then return end
                                    local n = select("#", ...)
                                    local a1 = ...
                                    if type(a1)=="table" then
                                        if gunModState.instantAim then
                                            a1.AimInSpeed = 0
                                            a1.AimOutSpeed = 0
                                        end
                                        if gunModState.forceAuto then
                                            a1.FireMode = "Auto"
                                        end
                                        if gunModState.rapidFire then
                                            a1.FireRate = gunModState.rapidFireDelay or 0.05
                                        end
                                        if gunModState.unlockFiremodes and rawget(a1, "FireModes") then
                                            a1.FireModes = { "Auto", "Semi" }
                                        end
                                    end
                                    return old(...)
                                end)
                            end)
                            if okh and old then hookedUpdate[updateClient]=true end
                        end
                        local settings = rawget(obj,"settings")
                        if type(settings)=="table" then
                            local cycle = rawget(settings,"CycleTiming")
                            if type(cycle)=="table" then
                                if gunModState.noBolt then
                                    if not State.gunModWeaponOriginals[cycle] then
                                        State.gunModWeaponOriginals[cycle]={cycle[1],cycle[2]}
                                    end
                                    cycle[1]=0; cycle[2]=0
                                elseif type(State.gunModWeaponOriginals[cycle])=="table" then
                                    cycle[1]=State.gunModWeaponOriginals[cycle][1]
                                    cycle[2]=State.gunModWeaponOriginals[cycle][2]
                                    State.gunModWeaponOriginals[cycle]=nil
                                end
                            end
                        end
                        local debounce = rawget(obj,"useDebounce")
                        if debounce~=nil then
                            if gunModState.removeRechamber then
                                if State.gunModRechamberOriginals[obj]==nil then
                                    State.gunModRechamberOriginals[obj]=debounce
                                end
                                rawset(obj,"useDebounce",false)
                            elseif State.gunModRechamberOriginals[obj]~=nil then
                                rawset(obj,"useDebounce",State.gunModRechamberOriginals[obj])
                                State.gunModRechamberOriginals[obj]=nil
                            end
                        end
                    end
                end
            end
        end
        task.wait(needGC and 0.75 or 2)
    end
end)

do
    local watched = setmetatable({}, {__mode="k"})

    local function fastEquipTrack(track)
        if not gunModState.instantEquip or not track then return end
        local anim = track.Animation
        local name = string.lower((anim and anim.Name) or "")
        if not string.find(name, "equip", 1, true) then return end
        pcall(function()
            track:AdjustSpeed(20)
            if track.Length and track.Length > 0 then
                track.TimePosition = math.max(track.Length - 0.01, 0)
            end
        end)
    end

    local function watchAnimator(animator)
        if not animator or watched[animator] then return end
        watched[animator] = true
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            fastEquipTrack(track)
        end
        local c = conn(animator.AnimationPlayed, fastEquipTrack)
        conn(animator.Destroying, function()
            if c then c:Disconnect() end
            watched[animator] = nil
        end)
    end

    State.ieE = 0
    conn(RunService.Heartbeat, function(dt)
        if not gunModState.instantEquip then return end
        State.ieE = State.ieE + dt
        if State.ieE < 0.25 then return end
        State.ieE = 0
        local cam = workspace.CurrentCamera
        if cam then
            for _, d in ipairs(cam:GetDescendants()) do
                if d:IsA("Animator") then watchAnimator(d) end
            end
        end
        local ch = Player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local an = hum and hum:FindFirstChildOfClass("Animator")
        if an then watchAnimator(an) end
    end)
end

State.gunScanE = 0
conn(RunService.Heartbeat, function(dt)
    State.gunScanE = State.gunScanE + dt
    if State.gunScanE < 0.2 then return end
    State.gunScanE = 0
    local cam = workspace.CurrentCamera
    local vm = cam and cam:FindFirstChild("ViewModel")
    if not vm then return end
    for _, obj in ipairs(vm:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            local n = string.lower(obj.Name or "")
            if string.find(n,"muzzle",1,true) or string.find(n,"flash",1,true) then
                if State.gunModMuzzleOriginals[obj]==nil then State.gunModMuzzleOriginals[obj]=obj.Enabled end
                if gunModState.removeMuzzle then
                    obj.Enabled = false
                else
                    obj.Enabled = State.gunModMuzzleOriginals[obj]
                end
            end
        end
    end
end)

State.acPending = setmetatable({}, {__mode="k"})
State.acKilled = setmetatable({}, {__mode="k"})

local function acScrub(part)
    if part.ClassName~="Part" or part.Name~="Part" then return false end
    if not part.Anchored or part.Material~=Enum.Material.Neon then return false end
    if math.abs(part.Transparency-0.75)>0.01 then return false end
    if part.Size.X>0.2 or part.Size.Y>0.2 or part.Size.Z>0.2 then return false end
    if #part:GetChildren()>0 then return false end
    pcall(function() part:Destroy() end); return true
end

local function acKill()
    if not (getconnections and debug and debug.getupvalues) then return end
    pcall(function()
        for _, c in ipairs(getconnections(game:GetService("LogService").MessageOut)) do
            local fn = c.Function
            if type(fn)=="function" and not State.acKilled[fn] then
                local ok, uv = pcall(debug.getupvalues, fn)
                if ok and type(uv)=="table" then
                    local m = uv[1]
                    if type(m)=="table" and rawget(m,1)=="[ESP]" and rawget(m,2)=="[AIMBOT]" then
                        State.acKilled[fn]=true
                        pcall(function() c:Disconnect() end)
                    end
                end
            end
        end
    end)
end

conn(workspace.ChildAdded, function(p)
    if ACBypassEnabled and p.ClassName=="Part" then State.acPending[p]=true end
end)

task.spawn(function()
    for _, p in ipairs(workspace:GetChildren()) do
        if p.ClassName=="Part" then State.acPending[p]=true end
    end
    local sweep = os.clock()+10
    while not shuttingDown do
        if ACBypassEnabled then
            local n=0
            for p in pairs(State.acPending) do
                State.acPending[p]=nil; acScrub(p); n=n+1
                if n>=120 then break end
            end
            if os.clock()>=sweep then
                sweep=os.clock()+10
                for _, p in ipairs(workspace:GetChildren()) do acScrub(p) end
                pcall(acKill)
            end
        end
        task.wait(0.2)
    end
end)

State.shotTracerTextures = {
    ["Solid"]="", ["Pulse"]="rbxassetid://446111271",
    ["Spark"]="rbxasset://textures/particles/sparkles_main.dds",
    ["Smoke"]="rbxasset://textures/particles/smoke_main.dds",
    ["Fire"]="rbxasset://textures/particles/fire_main.dds",
    ["Slash"]="rbxasset://textures/particles/slash_main.dds",
}
local function drawShotTracer(origin, direction)
    if not shotTracerState.enabled then return end
    if typeof(origin)~="Vector3" or typeof(direction)~="Vector3" then return end
    if direction.Magnitude<0.001 then return end

    local s = shotTracerState
    local life = math.clamp(tonumber(s.lifetime) or 0.5, 0.05, 3)
    local distance = math.clamp(direction.Magnitude, 10, 2000)
    local finish = origin + direction.Unit * distance
    local container = workspace:FindFirstChild("NoCollision") or workspace

    local a = Instance.new("Part")
    a.Name = "OmniTracerA"
    a.Anchored = true
    a.Size = Vector3.new(0.01, 0.01, 0.01)
    a.CFrame = CFrame.new(origin)
    a.CanCollide = false
    a.CanTouch = false
    a.CanQuery = false
    a.Transparency = 1
    a.Parent = container

    local b = Instance.new("Part")
    b.Name = "OmniTracerB"
    b.Anchored = true
    b.Size = Vector3.new(0.01, 0.01, 0.01)
    b.CFrame = CFrame.new(finish)
    b.CanCollide = false
    b.CanTouch = false
    b.CanQuery = false
    b.Transparency = 1
    b.Parent = container

    local at0 = Instance.new("Attachment")
    at0.Parent = a
    local at1 = Instance.new("Attachment")
    at1.Parent = b

    local c1, c2 = s.color, s.color2
    if s.style == "Rainbow" then
        local h = (os.clock() * 0.25) % 1
        c1 = Color3.fromHSV(h, 1, 1)
        c2 = Color3.fromHSV((h + 0.25) % 1, 1, 1)
    elseif s.style == "Dark Beam" then
        c1 = c1:Lerp(Color3.new(0,0,0), 0.45)
        c2 = c2:Lerp(Color3.new(0,0,0), 0.45)
    end

    local curve1, curve2 = tonumber(s.curve1) or 0, tonumber(s.curve2) or 0
    if s.randomizeCurve then
        if math.random(0,1) == 0 then curve1 = -curve1 end
        if math.random(0,1) == 0 then curve2 = -curve2 end
    end
    if s.style == "Curved" or s.style == "Bent" or s.style == "Lightning"
        or s.style == "Zigzag" or s.style == "Spiral" then
        local auto = math.min(distance * 0.06, 12)
        curve1 = auto * (s.style == "Bent" and -1 or 1)
        curve2 = -curve1
    end

    local width = tonumber(s.thickness) or 0.25
    local w0, w1 = width, width
    if s.style == "Tracer 1" then
        w1 = width * 0.65
    elseif s.style == "Tracer 2" then
        w0 = width * 0.65
    elseif s.style == "Pulse Beam" then
        w0, w1 = width * 1.8, width * 0.8
    elseif s.style == "Core Beam" then
        w0, w1 = width * 0.55, width * 0.35
    end

    local beam = Instance.new("Beam")
    beam.Name = "OmniTracer"
    beam.Attachment0 = at0
    beam.Attachment1 = at1
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Width0 = w0
    beam.Width1 = w1
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, math.clamp(tonumber(s.transparency1) or 0, 0, 1)),
        NumberSequenceKeypoint.new(1, math.clamp(tonumber(s.transparency2) or 1, 0, 1)),
    })
    beam.Texture = State.shotTracerTextures[s.texture] or ""
    beam.TextureSpeed = tonumber(s.textureSpeed) or 0
    beam.TextureLength = distance
    beam.TextureMode = Enum.TextureMode.Stretch
    beam.Segments = math.clamp(tonumber(s.segments) or 10, 1, 30)
    beam.CurveSize0 = curve1
    beam.CurveSize1 = curve2
    beam.Parent = a

    State.shotTracerObjects[#State.shotTracerObjects+1] = a
    State.shotTracerObjects[#State.shotTracerObjects+1] = b

    task.delay(life, function()
        if not a.Parent then return end
        local started = os.clock()
        local fadeConn
        fadeConn = RunService.RenderStepped:Connect(function()
            if not a.Parent then
                if fadeConn then fadeConn:Disconnect() end
                return
            end
            local alpha = math.clamp((os.clock() - started) / 0.12, 0, 1)
            beam.Transparency = NumberSequence.new(math.clamp(alpha + (tonumber(s.transparency1) or 0), 0, 1))
            if alpha >= 1 then
                if fadeConn then fadeConn:Disconnect() end
                pcall(function() a:Destroy() end)
                pcall(function() b:Destroy() end)
            end
        end)
    end)
end

installBulletHook = function()
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local fps = modules and modules:FindFirstChild("FPS")
    local bulletModule = fps and fps:FindFirstChild("Bullet")
    if not bulletModule then return end
    if State.shotTracerHook and State.bulletHookFn then
        local okA, api = pcall(require, bulletModule)
        if okA and api and api.CreateBullet == State.bulletHookFn then return end
        State.shotTracerHook = nil
    end
    local ok, bullet = pcall(require, bulletModule)
    if not ok or type(bullet) ~= "table" or type(bullet.CreateBullet) ~= "function" then return end

    local realOriginal = bullet.CreateBullet
    if State.bulletHookFn and realOriginal == State.bulletHookFn then
        realOriginal = State.bulletOriginal
    end
    if type(realOriginal) ~= "function" then return end
    State.bulletOriginal = realOriginal
    local oldBullet = realOriginal

    local function createBulletHook(...)
        local s29 = { ... }

        local hitbox = aimState.targetPart
        if hitbox and not hitbox.Parent then hitbox = nil end

        local silentOn = aimState.silentAim or aimState.magicBullet
        if hitbox and silentOn then
            local hc = tonumber(aimState.hitchance) or 100
            if hc >= 100 or math.random(1, 100) <= hc then
                local cam = workspace.CurrentCamera
                if cam then
                    s29[8] = {
                        ClassName = "Part",
                        CFrame = CFrame.new(cam.CFrame.p, hitbox.Position),
                    }
                end
            end
        end

        if shotTracerState.enabled and hitbox then
            local cam = workspace.CurrentCamera
            if cam then
                local origin = cam.CFrame.p
                local dir = hitbox.Position - origin
                if dir.Magnitude > 0.001 then
                    pcall(drawShotTracer, origin, dir.Unit * 1000)
                end
            end
        end

        if gunModState.multibullet then
            local n = math.clamp(math.floor(gunModState.multibulletCount or 3), 1, 12)
            for _ = 2, n do
                pcall(oldBullet, unpack(s29))
            end
        end

        return oldBullet(unpack(s29))
    end

    bullet.CreateBullet = createBulletHook
    State.bulletHookFn = createBulletHook

    State.shotTracerHook = {
        restore = function()
            pcall(function() bullet.CreateBullet = oldBullet end)
            State.bulletHookFn = nil
        end,
    }
    pcall(function()
        if Library and Library.Notify then
            Library:Notify("Bullet hook installed", 3)
        end
    end)
end

task.spawn(function()
    for _=1,120 do
        if shuttingDown then return end
        installBulletHook()
        if State.shotTracerHook then return end
        task.wait(1)
    end
end)

local function refreshModList()
    local list = {}
    pcall(function()
        local pf = ReplicatedStorage:FindFirstChild("Players")
        if not pf then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == Player then continue end
            local data = pf:FindFirstChild(plr.Name)
            local st = data and data:FindFirstChild("Status")
            local gv = st and st:FindFirstChild("GameplayVariables")
            local prem = gv and gv:GetAttribute("PremiumLevel")
            if type(prem) == "number" and prem >= 4 then
                list[#list+1] = plr.Name .. " (P" .. tostring(prem) .. ")"
            end
        end
    end)
    detectState.modList = list
    return list
end

task.spawn(function()
    while not shuttingDown do
        task.wait(3)
        pcall(function()
            local pf = ReplicatedStorage:FindFirstChild("Players")
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == Player then continue end
                if detectState.cheater and not detectState.cheaterAlerted[plr.Name] and pf then
                    local data = pf:FindFirstChild(plr.Name)
                    local st = data and data:FindFirstChild("Status")
                    local j = st and st:FindFirstChild("Journey")
                    local w = j and j:FindFirstChild("WipeStatistics")
                    if w then
                        local d = w:GetAttribute("Deaths") or 1
                        if d == 0 then d = 1 end
                        local k = w:GetAttribute("Kills") or 0
                        local kdr = math.floor(k / d * 10) / 10
                        if k >= 15 and kdr >= 5 then
                            detectState.cheaterAlerted[plr.Name] = true
                            pcall(function() Library:Notify("Suspected cheater: "..plr.Name.." KDR:"..kdr, 8) end)
                        end
                    end
                end
                if detectState.mod and not detectState.modAlerted[plr.Name] and pf then
                    local data = pf:FindFirstChild(plr.Name)
                    local st = data and data:FindFirstChild("Status")
                    local gv = st and st:FindFirstChild("GameplayVariables")
                    local prem = gv and gv:GetAttribute("PremiumLevel")
                    if type(prem) == "number" and prem >= 4 then
                        detectState.modAlerted[plr.Name] = true
                        pcall(function() Library:Notify("Mod detected: "..plr.Name, 8) end)
                    end
                end
            end
            if detectState.mod then refreshModList() end
        end)
    end
end)

local function applyCustomHitsound(sound)
    if not sound:IsA("Sound") or not soundState.hitEnabled then return end
    if not HITSOUND_DETECT[sound.SoundId] then return end
    sound.SoundId = soundState.hitId
    sound.Volume = soundState.hitVol
    if soundState.hitId == MOAN_ID then
        sound.TimePosition = 2
        task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
    end
end
local function applyCustomGunsound(inst)
    if not (inst:IsA("Sound") and soundState.gunEnabled) then return end
    local n = inst.Name
    if n ~= "FireSound" and n ~= "FireFarSound" and n ~= "FireSoundSupressed" then return end
    local cam = workspace.CurrentCamera
    if not (inst:IsDescendantOf(cam) or (Player.Character and inst:IsDescendantOf(Player.Character))) then return end
    inst.SoundId = soundState.gunId
    inst.Volume = soundState.gunVol
end
task.spawn(function()
    local pg = Player:WaitForChild("PlayerGui", 15)
    if not pg then return end
    local function hookMain(gui)
        conn(gui.ChildAdded, applyCustomHitsound)
        for _, c in ipairs(gui:GetChildren()) do applyCustomHitsound(c) end
    end
    conn(pg.ChildAdded, function(child)
        if child.Name == "MainGui" then hookMain(child) end
    end)
    local existing = pg:FindFirstChild("MainGui")
    if existing then hookMain(existing) end
end)
local cam0 = workspace.CurrentCamera
if cam0 then
    conn(cam0.DescendantAdded, applyCustomGunsound)
    for _, d in ipairs(cam0:GetDescendants()) do applyCustomGunsound(d) end
end
conn(Player.CharacterAdded, function(char)
    conn(char.DescendantAdded, applyCustomGunsound)
    for _, d in ipairs(char:GetDescendants()) do applyCustomGunsound(d) end
end)
if Player.Character then
    conn(Player.Character.DescendantAdded, applyCustomGunsound)
end

local function playTestSound(id, vol)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = vol or 1
    if id == MOAN_ID then s.TimePosition = 2 end
    s.Parent = SoundService
    s:Play()
    if id == MOAN_ID then task.delay(0.9, function() if s.Parent then s:Stop() end end) end
    game:GetService("Debris"):AddItem(s, 5)
end

do
local function playerStatusFolder(plr)
    local root = ReplicatedStorage:FindFirstChild("Players")
    local folder = root and root:FindFirstChild(plr.Name)
    return folder and folder:FindFirstChild("Status")
end

local function streamSyncTick()
    if not streamSyncState.enabled then return end
    local ch = Player.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local origin = hrp.Position
    local now = os.clock()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            local status = playerStatusFolder(plr)
            local uac = status and status:FindFirstChild("UAC")
            local verified = uac and uac:GetAttribute("LastVerifiedPos")
            local anchor = typeof(verified) == "Vector3" and verified or (root and root.Position)
            if anchor then
                local dist = (anchor - origin).Magnitude
                local stale = streamSyncState.lastRequested[plr] or 0
                if dist <= (streamSyncState.range or 12000) and now - stale > 1.5 then
                    streamSyncState.lastRequested[plr] = now
                    if not root then
                        pcall(function() Player:RequestStreamAroundAsync(anchor, 0.5) end)
                    elseif dist > 300 then
                        pcall(function() Player:RequestStreamAroundAsync(anchor, 0.5) end)
                    end
                end
            end
        end
    end
end

State.streamSyncE = 0
conn(RunService.Heartbeat, function(dt)
    State.streamSyncE = (State.streamSyncE or 0) + dt
    if State.streamSyncE < 0.5 then return end
    State.streamSyncE = 0
    pcall(streamSyncTick)
end)
end

do
local spoofState = {
    enabled=true,
    version="2456807", userid="find me", location="little saint james", job="omni.gg",
    hideData=false, hideClientFps=false, hideServerFps=false,
}
State.serverSpoof = spoofState

local function spoofFind(root, name)
    if not root then return nil end
    return root:FindFirstChild(name, true)
end

local function spoofSetVisible(inst, vis)
    if inst then pcall(function() inst.Visible = vis end) end
end

local function escapePattern(v)
    return (tostring(v or ""):gsub("%%", "%%%%"))
end

local function serverSpoofTick()
    local s = spoofState
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    local holder = spoofFind(pg, "ServerInfo")
    local frame = holder and spoofFind(holder, "Frame")
    if not frame then return end
    local live = spoofFind(frame, "serverInfo")
    if not live then return end
    local clone = frame:FindFirstChild("_serverInfo")
    if not clone then
        clone = live:Clone()
        clone.Name = "_serverInfo"
        clone.Parent = frame
    end

    if not s.enabled then
        live.Visible = true
        clone.Visible = false
        clone.Text = live.Text
        spoofSetVisible(frame:FindFirstChild("DataLabel"), true)
        spoofSetVisible(frame:FindFirstChild("clientFPS"), true)
        spoofSetVisible(frame:FindFirstChild("serverFPS"), true)
        return
    end

    live.Visible = false
    clone.Visible = true
    local txt = live.Text
    if s.version ~= "" then
        txt = txt:gsub("^[^|]+%s*|", escapePattern(s.version) .. " |")
    end
    if s.userid ~= "" then
        txt = txt:gsub("|%s*#%d+", "| " .. escapePattern(s.userid))
    end
    if s.location ~= "" then
        txt = txt:gsub("Server Location:%s*[^|]+", "Server Location: " .. escapePattern(s.location) .. " ")
    end
    if s.job ~= "" then
        txt = txt:gsub("|%s*[^|]+%s*$", "| " .. escapePattern(s.job))
    end
    clone.Text = txt
    spoofSetVisible(frame:FindFirstChild("DataLabel"), not s.hideData)
    spoofSetVisible(frame:FindFirstChild("clientFPS"), not s.hideClientFps)
    spoofSetVisible(frame:FindFirstChild("serverFPS"), not s.hideServerFps)
end

State.serverSpoofTick = serverSpoofTick

local acc = 0
conn(RunService.Heartbeat, function(dt)
    acc = acc + dt
    if acc < 0.5 then return end
    acc = 0
    pcall(serverSpoofTick)
end)
end

local function applyScreenRemovals()
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    local s = screenRemovalState
    local function on(name) return s.enabled and s.elements[name] end
    local function srChain(root, ...)
        local cur = root
        for _, name in ipairs({...}) do
            if not cur then return nil end
            cur = cur:FindFirstChild(name)
        end
        return cur
    end

    local mainFrame = srChain(pg, "NoInsetGui", "MainFrame") or srChain(pg, "MainGui", "MainFrame")
    local screenFx = mainFrame and mainFrame:FindFirstChild("ScreenEffects")

    if screenFx then
        local hideVisor = on("Visor")
        for _, name in ipairs({"HelmetMask", "Visor", "Mask"}) do
            local obj = screenFx:FindFirstChild(name)
            if obj and obj:IsA("GuiObject") then obj.Visible = not hideVisor end
        end
        local parallax = srChain(screenFx, "Parallax", "Parallax")
        if parallax and parallax:IsA("GuiObject") then parallax.Visible = not on("Parallax") end
        local flash = srChain(screenFx, "Flashbang", "ImageLabel")
        if flash and flash:IsA("GuiObject") then flash.Visible = not on("Flashbang") end
    end

    local blur = Lighting:FindFirstChild("InventoryBlur")
    if blur then blur.Enabled = not on("Inventory Blur") end

    local backpack = srChain(pg, "MainGui", "MainFrame", "BackpackFrame")
    if backpack then
        for _, frame in ipairs(backpack:GetChildren()) do
            if frame:IsA("Frame") then
                frame.BackgroundTransparency = on("Inventory Background") and 1 or 0.05
                local decor = frame:FindFirstChild("Decor")
                if decor then decor.Visible = not on("Inventory Decoration") end
            end
        end
    end

    local mask = screenFx and screenFx:FindFirstChild("Mask")
    local gasMask = mask and srChain(mask, "GP5", "GasMask")
    if gasMask then
        if on("Gas Mask") then
            if gasMask.IsPlaying then pcall(function() gasMask:Stop() end) end
            if not s.maskConn then
                s.maskConn = gasMask:GetPropertyChangedSignal("Playing"):Connect(function()
                    if gasMask.IsPlaying and s.enabled and s.elements["Gas Mask"] then
                        pcall(function() gasMask:Stop() end)
                    end
                end)
            end
        elseif s.maskConn then
            s.maskConn:Disconnect()
            s.maskConn = nil
        end
    end
end

State.srE = 0
conn(RunService.Heartbeat, function(dt)
    if not (screenRemovalState.enabled or screenRemovalState.pendingRestore) then return end
    State.srE = (State.srE or 0) + dt
    if State.srE < 0.25 then return end
    State.srE = 0
    pcall(applyScreenRemovals)
    if not screenRemovalState.enabled then screenRemovalState.pendingRestore = false end
end)

local function undergroundResolve()
    local s = undergroundState
    if not (s.enabled or s.held) or s.using then return end
    local ch = Player.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not (ch and hum and root) or hum.Health <= 0 then return end
    if movementState.flyEnabled or movementState.peekBlink then return end
    local base = root.CFrame
    local depth = math.max(1, tonumber(s.depth) or 15)
    local method = s.method or "Classic"
    local deadline = os.clock() + math.max(0.1, tonumber(s.timeout) or 1)
    local flip = false
    s.using = true
    if State.ugConn then State.ugConn:Disconnect() end
    State.ugConn = RunService.RenderStepped:Connect(function()
        local c = Player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not (s.enabled or s.held) or not (c and r and h) or h.Health <= 0 or os.clock() >= deadline then
            if State.ugConn then State.ugConn:Disconnect(); State.ugConn = nil end
            s.using = false
            if c and r and r.Parent then
                pcall(function()
                    if method == "CFrame" then r.CFrame = base else c:PivotTo(base) end
                    r.AssemblyLinearVelocity = Vector3.zero
                end)
            end
            return
        end
        flip = not flip
        pcall(function()
            if flip then
                local drop = CFrame.new(0, -(depth + 10), 0)
                if method == "CFrame" then r.CFrame = base * drop else c:PivotTo(base * drop) end
            elseif method == "CFrame" then
                r.CFrame = base
            else
                c:PivotTo(base)
            end
            if h then h:ChangeState(Enum.HumanoidStateType.Running) end
        end)
    end)
end
conn(RunService.Heartbeat, function()
    if undergroundState.enabled or undergroundState.held then pcall(undergroundResolve) end
end)

local function doRejoin()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end)
end

local function unload()
    shuttingDown = true
    for _, c in ipairs(managedConns) do pcall(function() c:Disconnect() end) end
    table.clear(managedConns)
    pcall(function() VMChams.Reset() end)
    if State.shotTracerHook and State.shotTracerHook.restore then pcall(State.shotTracerHook.restore) end
    State.shotTracerHook=nil
    for _,obj in ipairs(State.shotTracerObjects) do pcall(function() obj:Destroy() end) end
    table.clear(State.shotTracerObjects)
    local hook = gg.__OmniAimHook
    if type(hook)=="table" and type(hook.restore)=="function" then pcall(hook.restore) end
    gg.__OmniAimHook = nil
    pcall(function() espGui:Destroy() end)
    pcall(function() HudGui:Destroy() end)
    pcall(chamsRestoreMaterials)
    clearWaterPlatform()
    restoreMoses()

    worldFx.fullBright=false; worldFx.noFog=false; worldFx.ambientOn=false
    worldFx.skyOn=false; worldFx.atmoOn=false; worldFx.bloomOn=false; worldFx.gradeOn=false
    worldFx.potato=false
    worldFx.removeGrass=false; worldFx.noLeaves=false; worldFx.noFoliage=false
    worldFx.noTrees=false; worldFx.noClouds=false
    pcall(worldApplyAll)
    pcall(function() worldBloom:Destroy() end)
    pcall(function() worldGrade:Destroy() end)
    pcall(function() State.worldBrightCC:Destroy() end)

    pcall(function() InventoryChecker.destroy() end)
    pcall(function()
        Player.CameraMaxZoomDistance=thirdPersonOriginal.max
        Player.CameraMinZoomDistance=thirdPersonOriginal.min
        Player.CameraMode=thirdPersonOriginal.mode
        if itemFinderGui then itemFinderGui:Destroy(); itemFinderGui=nil end
        for part,original in pairs(thirdPersonPartOriginals) do if part.Parent then part.LocalTransparencyModifier=original end end
        table.clear(thirdPersonPartOriginals)
    end)
    for joint,base in pairs(vmJointOriginals) do pcall(function() if joint.Parent then joint.C0=base end end) end
    for part,base in pairs(vmArmOriginals) do pcall(function() if part.Parent then part.LocalTransparencyModifier=base end end) end
    if unlockSkinLibrary and unlockSkinHookOriginal then pcall(function() unlockSkinLibrary.IsItemAccessibleToPlayer=unlockSkinHookOriginal end) end
    gg.__OmniExtESP = nil
    gg.__OmniInventoryChecker = nil
    gg.__OmniUnload = nil
    gg.__OMNI_LOADED = nil
end

gg.__OmniUnload = function()
    pcall(unload)
    pcall(function()
        if Library and type(Library.Unload) == "function" then Library:Unload() end
    end)
end

local function buildUI()
local Window = Library:CreateWindow({
    Title = "Omni Project delta (" .. tostring(State.executorName or "Unknown") .. ")",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Combat   = Window:AddTab("Combat"),
    Visuals  = Window:AddTab("Visuals"),
    Player   = Window:AddTab("Player"),
    World    = Window:AddTab("World"),
    Misc     = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

do
    local tab = Tabs.Combat
    do

    local legitGroup = tab:AddLeftGroupbox("Legit Aimbot")
    legitGroup:AddToggle("LegitAimEnabled", {
        Text = "Enable Aimbot",
        Default = false,
        Callback = function(v)
            LegitAim.enabled = v
            if not v then LegitAim.target=nil; LegitAim.targetPart=nil end
        end,
    }):AddKeyPicker("LegitAimKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Aimbot"})

    legitGroup:AddDropdown("LegitAimPart", {
        Text = "Aim Part",
        Values = {"Head","UpperTorso","Nearest"},
        Default = 1,
        Callback = function(v) LegitAim.aimPart = v end,
    })
    legitGroup:AddSlider("LegitFOV", {
        Text="Aim FOV", Min=20, Max=600, Default=140, Rounding=0,
        Callback=function(v) LegitAim.fov=v end,
    })
    legitGroup:AddSlider("LegitSmooth", {
        Text="Smoothness", Min=1, Max=30, Default=10, Rounding=0,
        Callback=function(v) LegitAim.smoothness=v end,
    })
    legitGroup:AddSlider("LegitPrediction", {
        Text="Prediction", Min=0, Max=0.4, Default=0.12, Rounding=2,
        Callback=function(v) LegitAim.prediction=v end,
    })
    legitGroup:AddToggle("LegitTeamCheck", {
        Text="Team Check", Default=false,
        Callback=function(v) LegitAim.teamCheck=v end,
    })
    legitGroup:AddToggle("LegitWallCheck", {
        Text="Wall Check", Default=true,
        Callback=function(v) LegitAim.wallCheck=v end,
    })
    legitGroup:AddToggle("LegitSticky", {
        Text="Sticky Target", Default=false,
        Callback=function(v) LegitAim.sticky=v end,
    })

    local function setMagicToggle(value)
        local opt = (Options and Options.MagicBullet) or (Toggles and Toggles.MagicBullet)
        if not opt then return false end
        aimState.syncMagic = true
        local okSet = pcall(function()
            if type(opt.SetValue) == "function" then
                opt:SetValue(value)
            else
                opt.Value = value
            end
        end)
        aimState.syncMagic = false
        return okSet
    end

    local rageGroup = tab:AddRightGroupbox("Rage")
    rageGroup:AddToggle("SilentAim", {
        Text="Silent Aim", Default=false,
        Callback=function(v)
            aimState.silentAim=v
            if v then
                if not aimState.magicBullet then aimState.magicAuto=true end
                aimState.magicBullet=true
                if not setMagicToggle(true) then
                    aimState.magicBullet=true
                end
            else
                if aimState.magicAuto then
                    aimState.magicAuto=false
                    aimState.magicBullet=false
                    setMagicToggle(false)
                end
                if not aimState.magicBullet then
                    aimState.target=nil; aimState.targetPart=nil; aimState.eye=nil
                end
            end
        end,
    }):AddKeyPicker("SilentAimKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Silent Aim"})

    rageGroup:AddSlider("SilentFOV", {
        Text="Silent FOV", Min=50, Max=600, Default=200, Rounding=0,
        Callback=function(v) aimState.fov=v end,
    })
    rageGroup:AddLabel("FOV Ring Color"):AddColorPicker("SilentFovColor",{Default=aimState.fovColor,Title="FOV Ring",Callback=function(v) aimState.fovColor=v end})
    rageGroup:AddToggle("SilentTracer", {
        Text="Target Line", Default=true,
        Callback=function(v) aimState.tracerEnabled=v end,
    })
    rageGroup:AddDropdown("SilentTracerOrigin", {
        Text="Target Line Origin", Values={"Mouse","Crosshair","Bottom"}, Default=3,
        Callback=function(v) aimState.tracerOrigin=v end,
    })
    rageGroup:AddToggle("SilentTargetName", {
        Text="Target Name", Default=true,
        Callback=function(v) aimState.showTargetName=v end,
    })
    rageGroup:AddLabel("Target Line Color"):AddColorPicker("SilentTracerColor",{Default=aimState.tracerColor,Title="Target Line",Callback=function(v) aimState.tracerColor=v end})
    rageGroup:AddLabel("Target Line Outline Color"):AddColorPicker("SilentTracerOutlineColor",{Default=aimState.tracerOutlineColor,Title="Line Outline",Callback=function(v) aimState.tracerOutlineColor=v end})
    rageGroup:AddSlider("SilentTracerThickness",{Text="Target Line Thickness",Min=0.5,Max=8,Default=1,Rounding=1,Callback=function(v) aimState.tracerThickness=v end})
    rageGroup:AddSlider("SilentTracerOpacity",{Text="Target Line Opacity",Min=0.1,Max=1,Default=1,Rounding=2,Callback=function(v) aimState.tracerOpacity=v end})
    rageGroup:AddToggle("SilentTracerOutline", {
        Text="Target Line Outline", Default=false,
        Callback=function(v) aimState.tracerOutline=v end,
    })
    rageGroup:AddToggle("MagicBullet", {
        Text="Magic Bullet", Default=false,
        Callback=function(v)
            aimState.magicBullet=v
            if not aimState.syncMagic then aimState.magicAuto=false end

            if not v and not aimState.silentAim then
                aimState.target=nil; aimState.targetPart=nil; aimState.eye=nil
            end
        end,
    }):AddKeyPicker("MagicBulletKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Magic Bullet"})

    rageGroup:AddToggle("InstaHit", {
        Text="Instant Hit", Default=false,
        Callback=function(v) aimState.instaHit=v end,
    }):AddKeyPicker("InstaHitKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Instant Hit"})

    rageGroup:AddToggle("AimWallbang", {
        Text="Silent Wallbang", Default=true,
        Callback=function(v) aimState.wallbang=v end,
    })
    rageGroup:AddSlider("AimHitchance", {
        Text="Silent Hitchance", Min=1, Max=100, Default=100, Rounding=0,
        Callback=function(v) aimState.hitchance=v end,
    })
    rageGroup:AddSlider("AimEmulatedTick", {
        Text="Instant Emulated Tick", Min=1, Max=20, Default=5, Rounding=0,
        Callback=function(v) aimState.emulated_tick=v end,
    })

    rageGroup:AddToggle("Triggerbot", {
        Text="Triggerbot", Default=false,
        Callback=function(v)
            aimState.triggerbot=v
            if not v then aimState.triggerTarget=nil; aimState.triggerReadyAt=0 end
        end,
    }):AddKeyPicker("TriggerKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Triggerbot"})

    rageGroup:AddSlider("TriggerDelay", {
        Text="Trigger Delay (ms)", Min=0, Max=500, Default=50, Rounding=0,
        Callback=function(v) aimState.triggerDelay=v end,
    })
    rageGroup:AddSlider("TriggerChance", {
        Text="Trigger Chance %", Min=1, Max=100, Default=100, Rounding=0,
        Callback=function(v) aimState.triggerChance=v end,
    })
    rageGroup:AddToggle("TargetAI", {
        Text="Target AI", Default=true,
        Callback=function(v) aimState.targetAI=v end,
    })
    rageGroup:AddToggle("TargetHeli", {
        Text="Target Heli/APC", Default=false,
        Callback=function(v) aimState.targetHeli=v end,
    })
    rageGroup:AddDropdown("AimPriority", {
        Text="Aim Priority",
        Values={"Head First","Torso First","Nearest Part"},
        Default=1,
        Callback=function(v) aimState.aimPriority=v end,
    })
    rageGroup:AddToggle("BlacklistEnabled", {
        Text="Use Target Blacklist", Default=true,
        Callback=function(v) aimState.blacklistEnabled=v end,
    })
    rageGroup:AddInput("TargetBlacklist", {
        Text="Blacklisted Names", Default="", Placeholder="name1, name2, name3",
        Callback=function(v)
            local set = {}
            for name in tostring(v or ""):gmatch("[^,]+") do
                local n = name:match("^%s*(.-)%s*$")
                if n ~= "" then set[string.lower(n)] = true end
            end
            aimState.blacklist = set
        end,
    })
    rageGroup:AddToggle("UndergroundResolver", {
        Text="Underground Resolver", Default=false,
        Callback=function(v) undergroundState.enabled=v end,
    }):AddKeyPicker("UndergroundKey", {Default="None", SyncToggleState=false, Mode="Hold", Text="Underground",
        Callback=function(v) undergroundState.held=v end})
    rageGroup:AddSlider("UndergroundDepth", {
        Text="Depth", Min=1, Max=60, Default=15, Rounding=0,
        Callback=function(v) undergroundState.depth=v end,
    })
    rageGroup:AddSlider("UndergroundTimeout", {
        Text="Timeout (s)", Min=0.1, Max=3, Default=1, Rounding=1,
        Callback=function(v) undergroundState.timeout=v end,
    })
    rageGroup:AddDropdown("UndergroundMethod", {
        Text="Method", Values={"Classic","CFrame"}, Default=1,
        Callback=function(v) undergroundState.method=v end,
    })
    rageGroup:AddToggle("CustomHitSound", {
        Text="Custom Hit Sound", Default=false,
        Callback=function(v) soundState.hitEnabled=v end,
    })
    local hsNames = {}
    for k in pairs(HITSOUND_IDS) do hsNames[#hsNames+1]=k end
    table.sort(hsNames)
    rageGroup:AddDropdown("HitSoundPick", {
        Text="Hit Sound", Values=hsNames, Default=1,
        Callback=function(v) soundState.hitId = HITSOUND_IDS[v] or soundState.hitId end,
    })
    rageGroup:AddSlider("HitSoundVol", {
        Text="Hit Volume", Min=1, Max=300, Default=100, Rounding=0,
        Callback=function(v) soundState.hitVol=v/100 end,
    })
    rageGroup:AddButton("Test Hit Sound", function()
        playTestSound(soundState.hitId, soundState.hitVol)
    end)
    rageGroup:AddToggle("CustomGunSound", {
        Text="Custom Gun Sound", Default=false,
        Callback=function(v) soundState.gunEnabled=v end,
    })
    local gsNames = {}
    for k in pairs(GUNSOUND_IDS) do gsNames[#gsNames+1]=k end
    table.sort(gsNames)
    rageGroup:AddDropdown("GunSoundPick", {
        Text="Gun Sound", Values=gsNames, Default=2,
        Callback=function(v) soundState.gunId = GUNSOUND_IDS[v] or soundState.gunId end,
    })
    rageGroup:AddSlider("GunSoundVol", {
        Text="Gun Volume", Min=1, Max=300, Default=100, Rounding=0,
        Callback=function(v) soundState.gunVol=v/100 end,
    })
    rageGroup:AddButton("Test Gun Sound", function()
        playTestSound(soundState.gunId, soundState.gunVol)
    end)

    local gmLeft = tab:AddLeftGroupbox("Gun Mods")

    local function gmt(group, text, key)
        group:AddToggle("GM_"..key, {
            Text=text, Default=false,
            Callback=function(v)
                gunModState[key]=v
                if key=="noDrop" or key=="noDrag" then task.defer(gunModApplyAmmo) end
            end,
        })
    end
    local function gms(group, text, key, min, max, step, default)
        group:AddSlider("GMS_"..key, {
            Text=text, Min=min, Max=max, Default=default or min, Rounding=step<1 and 2 or 0,
            Callback=function(v) gunModState[key]=v end,
        })
    end

    gmt(gmLeft,"No Recoil","noRecoil")
    gmt(gmLeft,"No Bob","noBob")
    gmt(gmLeft,"No Spread","noSpread")
    gmt(gmLeft,"No Bullet Drop","noDrop")
    gmt(gmLeft,"No Drag","noDrag")
    gmt(gmLeft,"Instant ADS","instantAim")
    gmt(gmLeft,"Instant Equip","instantEquip")
    gmt(gmLeft,"Rapid Fire","rapidFire")
    gms(gmLeft,"Fire Rate (s)","rapidFireDelay",0.01,0.5,0.01,0.05)
    gmt(gmLeft,"Force Auto","forceAuto")
    gmt(gmLeft,"Multibullet","multibullet")
    gms(gmLeft,"Bullet Count","multibulletCount",1,12,1,3)
    gmt(gmLeft,"Ignore Water","ignoreWater")
    gmt(gmLeft,"Remove Gear Weight","removeWeight")

    gmt(gmLeft,"Remove Aim Restrictions","removeAimRestrictions")
    gmt(gmLeft,"No Bolt","noBolt")
    gmt(gmLeft,"Remove Sandboxing","removeSandboxing")
    gmt(gmLeft,"Remove Rechamber Delay","removeRechamber")
    gmt(gmLeft,"Sprint While Shooting","sprintShoot")
    gmt(gmLeft,"Instant Lean","instantLean")
    gmt(gmLeft,"No Sway","noSway")
    gmt(gmLeft,"Remove Obstructions","noObstruct")
    gmt(gmLeft,"Remove Muzzle Effects","removeMuzzle")
    gmt(gmLeft,"Remove Sprint Animation","removeSprintAnimation")
    gmt(gmLeft,"Unlock Firemodes","unlockFiremodes")
    gmt(gmLeft,"Extend Melee Reach","meleeReach")
    gms(gmLeft,"Reach Extra Studs","meleeReachDist",1,30,1,10)
end

    local tab = Tabs.Visuals
    do

    local espGroup = tab:AddLeftGroupbox("ESP")
    espGroup:AddToggle("ESPEnabled", {
        Text="ESP", Default=false,
        Callback=function(v) espState.enabled=v; espLayer.Visible=v end,
    }):AddKeyPicker("ESPKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="ESP"})

    espGroup:AddToggle("ESPBox",        {Text="Box",          Default=true,  Callback=function(v) espState.box=v end})
    espGroup:AddToggle("ESPNames",      {Text="Names",        Default=true,  Callback=function(v) espState.names=v end})
    espGroup:AddToggle("ESPHealth",     {Text="Health",       Default=true,  Callback=function(v) espState.health=v end})
    espGroup:AddToggle("ESPDistance",   {Text="Distance",     Default=true,  Callback=function(v) espState.distance=v end})
    espGroup:AddToggle("ESPWeapon",     {Text="Weapon",       Default=false, Callback=function(v) espState.weapon=v end})
    espGroup:AddToggle("ESPAI",         {Text="AI ESP",        Default=false, Callback=function(v) espState.ai=v end})
    espGroup:AddToggle("ESPVisibility", {Text="Visibility Status", Default=true, Callback=function(v) espState.visibility=v end})
    espGroup:AddLabel("Visible Status Color"):AddColorPicker("ESPVisibleStatusColor",{Default=espColors.visibilityVisible,Title="Visible",Callback=function(v) espColors.visibilityVisible=v end})
    espGroup:AddLabel("Hidden Status Color"):AddColorPicker("ESPHiddenStatusColor",{Default=espColors.visibilityHidden,Title="Hidden",Callback=function(v) espColors.visibilityHidden=v end})
    espGroup:AddToggle("ESPTracer",     {Text="Tracer",       Default=false, Callback=function(v) espState.tracer=v end})
    espGroup:AddToggle("ESPSkeleton",   {Text="Skeleton",     Default=false, Callback=function(v) espState.skeleton=v end})
    espGroup:AddToggle("ESPHeadDot",    {Text="Head Dot",     Default=true,  Callback=function(v) espState.headDot=v end})
    espGroup:AddToggle("ESPBoxFill",    {Text="Box Fill",     Default=false, Callback=function(v) espState.boxFill=v end})
    espGroup:AddToggle("ESPCornerBox",  {Text="Corner Box",   Default=false, Callback=function(v) espState.cornerBox=v end})
    espGroup:AddToggle("ESPTeamCheck",  {Text="Team Check",   Default=false, Callback=function(v) espState.teamCheck=v end})
    espGroup:AddToggle("ESPWalls",      {Text="Through Walls",Default=true,  Callback=function(v) espState.walls=v end})
    espGroup:AddToggle("ESPInfinite",   {Text="Infinite",     Default=true,  Callback=function(v) espState.infinite=v end})
    espGroup:AddSlider("ESPMaxDist",    {Text="Max Distance", Min=0,  Max=5000, Default=0, Rounding=0, Callback=function(v) espState.maxDistance=v end})
    espGroup:AddSlider("ESPRefresh",    {Text="Refresh Hz",   Min=30, Max=240, Default=60, Rounding=0, Callback=function(v) espState.refreshRate=v end})
    espGroup:AddDropdown("ESPBoxType",  {Text="Box Style",    Values={"Dynamic","Static"}, Default=1, Callback=function(v) espState.boxType=v end})
    espGroup:AddSlider("ESPBoxWidth",   {Text="Box Width",    Min=1, Max=10, Default=3.6, Rounding=1, Callback=function(v) espState.boxSizeX=v end})
    espGroup:AddSlider("ESPBoxHeight",  {Text="Box Height",   Min=2, Max=12, Default=5, Rounding=1, Callback=function(v) espState.boxSizeY=v end})
    espGroup:AddSlider("ESPBoxPadding", {Text="Box Padding",  Min=0.8, Max=2, Default=1.1, Rounding=2, Callback=function(v) espState.boxPadding=v end})

    espGroup:AddLabel("Box Color"):AddColorPicker("ESPBoxColor",    {Default=espColors.box,      Title="Box Color",      Callback=function(v) espColors.box=v end})
    espGroup:AddLabel("Name Color"):AddColorPicker("ESPNameColor",  {Default=espColors.name,     Title="Name Color",     Callback=function(v) espColors.name=v end})
    espGroup:AddLabel("Weapon Color"):AddColorPicker("ESPWeaponColor",{Default=espColors.weapon,Title="Weapon Color",Callback=function(v) espColors.weapon=v end})
    espGroup:AddLabel("Health Top"):AddColorPicker("ESPHealthTop",  {Default=espHealthColors.top,Title="Health Top",     Callback=function(v) espHealthColors.top=v end})
    espGroup:AddLabel("Health Bot"):AddColorPicker("ESPHealthBot",  {Default=espHealthColors.bottom,Title="Health Bot",  Callback=function(v) espHealthColors.bottom=v end})
    espGroup:AddLabel("Tracer"):AddColorPicker("ESPTracerColor",    {Default=espColors.tracer,   Title="Tracer Color",   Callback=function(v) espColors.tracer=v end})
    espGroup:AddLabel("Head Dot"):AddColorPicker("ESPDotColor",     {Default=espColors.headDot,  Title="Head Dot Color", Callback=function(v) espColors.headDot=v end})
    espGroup:AddLabel("Skeleton"):AddColorPicker("ESPSkelColor",    {Default=espColors.skeleton, Title="Skeleton Color", Callback=function(v) espColors.skeleton=v end})
    espGroup:AddToggle("StreamSync",{Text="Stream Sync",Default=false,
        Callback=function(v) streamSyncState.enabled=v; if v then table.clear(streamSyncState.lastRequested) end end})
    espGroup:AddSlider("StreamSyncRange",{Text="Range (studs)",Min=1000,Max=20000,Default=12000,Rounding=0,
        Callback=function(v) streamSyncState.range=v end})
    local shotGroup = tab:AddRightGroupbox("Shot Tracers")
    shotGroup:AddToggle("ShotTracersEnabled",{Text="Bullet Tracers",Default=false,Callback=function(v) shotTracerState.enabled=v end})
    shotGroup:AddDropdown("ShotTracerStyle",{Text="Style",Values={"Tracer 1","Tracer 2","Curved","Pulse Beam","Core Beam","Lightning","Zigzag","Spiral","Bent","Dark Beam","Rainbow"},Default=1,Callback=function(v) shotTracerState.style=v end})
    shotGroup:AddDropdown("ShotTracerTexture",{Text="Texture",Values={"Solid","Pulse","Spark","Smoke","Fire","Slash"},Default=2,Callback=function(v) shotTracerState.texture=v end})
    shotGroup:AddSlider("ShotTracerTextureSpeed",{Text="Texture Scroll Speed",Min=0,Max=8,Default=0,Rounding=1,Callback=function(v) shotTracerState.textureSpeed=v end})
    shotGroup:AddLabel("Tracer Color"):AddColorPicker("ShotTracerColor",{Default=shotTracerState.color,Title="Tracer Color",Callback=function(v) shotTracerState.color=v end})
    shotGroup:AddLabel("Tracer Color 2"):AddColorPicker("ShotTracerColor2",{Default=shotTracerState.color2,Title="Tracer Color 2",Callback=function(v) shotTracerState.color2=v end})
    shotGroup:AddSlider("ShotTracerThickness",{Text="Thickness",Min=5,Max=100,Default=25,Rounding=0,Callback=function(v) shotTracerState.thickness=v/100 end})
    shotGroup:AddSlider("ShotTracerLifetime",{Text="Lifetime (s x100)",Min=10,Max=300,Default=50,Rounding=0,Callback=function(v) shotTracerState.lifetime=v/100 end})
    shotGroup:AddSlider("ShotTracerAlpha1",{Text="Start Transparency",Min=0,Max=1,Default=0,Rounding=2,Callback=function(v) shotTracerState.transparency1=v end})
    shotGroup:AddSlider("ShotTracerAlpha2",{Text="End Transparency",Min=0,Max=1,Default=1,Rounding=2,Callback=function(v) shotTracerState.transparency2=v end})
    shotGroup:AddSlider("ShotTracerSegments",{Text="Segments",Min=1,Max=30,Default=10,Rounding=0,Callback=function(v) shotTracerState.segments=v end})
    shotGroup:AddSlider("ShotTracerCurve1",{Text="Curve Start",Min=-20,Max=20,Default=0,Rounding=1,Callback=function(v) shotTracerState.curve1=v end})
    shotGroup:AddSlider("ShotTracerCurve2",{Text="Curve End",Min=-20,Max=20,Default=0,Rounding=1,Callback=function(v) shotTracerState.curve2=v end})
    shotGroup:AddToggle("ShotTracerRandomCurve",{Text="Randomize Curve",Default=false,Callback=function(v) shotTracerState.randomizeCurve=v end})


    end
    do
    local weaponSkinGroup=tab:AddRightGroupbox("Weapon Skin Swapper")
    local function skinRoot() return ReplicatedStorage:FindFirstChild("Skins") end
    local function itemRoot() return ReplicatedStorage:FindFirstChild("ItemsList") end
    local function skinItemNames()
        local out={}; local f=skinRoot()
        if f then for _,v in ipairs(f:GetChildren()) do out[#out+1]=v.Name end end
        table.sort(out); if #out==0 then out={"None"} end; return out
    end
    local selectedSkinItem,selectedSkinName=nil,nil
    local weaponSkinChoices={}
    local function skinNamesFor(item)
        local out={}; local f=skinRoot(); local folder=f and f:FindFirstChild(item)
        if folder then for _,v in ipairs(folder:GetChildren()) do out[#out+1]=v.Name end end
        table.sort(out); if #out==0 then out={"Default"} end; return out
    end
    local function dressWeaponModel(model,itemName,skinName)
        local f=skinRoot(); local item=f and f:FindFirstChild(itemName); local skin=item and item:FindFirstChild(skinName)
        if not (model and skin) then return end
        local textures,materials=skin:FindFirstChild("Textures"),skin:FindFirstChild("Materials")
        if not textures and not materials then return end
        for _,part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local key=part:GetAttribute("Skinnable")
                local tex=key and textures and textures:FindFirstChild(key)
                local mat=key and materials and materials:FindFirstChild(key)
                if tex then pcall(function()
                    for _,old in ipairs(part:GetChildren()) do if old:IsA(tex.ClassName) then old:Destroy() end end
                    local copy=tex:Clone(); copy.Name="SurfaceAppearance"; copy.Parent=part
                    local tr=copy:GetAttribute("Transparency"); if tr and part.Transparency~=1 then part.Transparency=tr end
                end) end
                if mat then pcall(function()
                    for _,old in ipairs(part:GetChildren()) do if old:IsA("SurfaceAppearance") then old:Destroy() end end
                    local col,tr,mn=mat:GetAttribute("Color"),mat:GetAttribute("Transparency"),mat:GetAttribute("Name")
                    if col then part.Color=col end; if tr then part.Transparency=tr end
                    if mn and Enum.Material[mn] then part.Material=Enum.Material[mn] end
                end) end
            end
        end
    end
    local function applyWeaponSkin(itemName,skinName)
        local count=0; local pf=ReplicatedStorage:FindFirstChild("Players")
        local pd=pf and pf:FindFirstChild(Player.Name); local list=itemRoot()
        local valid={[itemName]=true}; local f=skinRoot(); local sf=f and f:FindFirstChild(itemName)
        if sf then for _,sk in ipairs(sf:GetChildren()) do local ms=sk:GetAttribute("ModelSkin"); if type(ms)=="string" and ms~="" then valid[ms]=true end end end
        local seen=setmetatable({}, {__mode="k"})
        local function scan(folder)
            if not folder then return end
            for _,obj in ipairs(folder:GetChildren()) do
                if obj:IsA("ObjectValue") and not seen[obj] then
                    local ref=obj.Value; local props=ref and ref:FindFirstChild("ItemProperties")
                    local special=props and props:GetAttribute("SpecialSkinItem")
                    if valid[obj.Name] or valid[(type(special)=="string" and special~="") and special or (ref and ref.Name or "")] then
                        seen[obj]=true
                        local skin=sf and sf:FindFirstChild(skinName); local modelName=skin and skin:GetAttribute("ModelSkin")
                        local target=(type(modelName)=="string" and modelName~="") and modelName or itemName
                        local refTarget=list and list:FindFirstChild(target)
                        if refTarget then obj.Name=target; obj.Value=refTarget end
                        obj:SetAttribute("Skin",skinName); count+=1
                    end
                end
                local inner=obj:FindFirstChild("Inventory"); if inner then scan(inner) end
            end
        end
        if pd then scan(pd:FindFirstChild("Inventory")); scan(pd:FindFirstChild("Hotbar")) end
        local cam=workspace.CurrentCamera; local vm=cam and (cam:FindFirstChild("ViewModel") or cam:FindFirstChildOfClass("Model"))
        if vm then dressWeaponModel(vm,itemName,skinName); local it=vm:FindFirstChild("Item"); if it then dressWeaponModel(it,itemName,skinName) end end
        local ch=Player.Character; local tool=ch and ch:FindFirstChildOfClass("Tool"); if tool then dressWeaponModel(tool,itemName,skinName) end
        return count
    end
    local itemValues=skinItemNames()
    weaponSkinGroup:AddDropdown("WeaponSkinItem",{Text="Weapon",Values=itemValues,Default=1,Callback=function(v)
        selectedSkinItem=v
        local values=skinNamesFor(v); selectedSkinName=values[1]
        pcall(function() local opt=Options.WeaponSkinName; if opt then if opt.SetValues then opt:SetValues(values) else opt.Values=values end end end)
        pcall(function() local opt=Options.WeaponSkinName; if opt and opt.SetValue then opt:SetValue(selectedSkinName) end end)
    end})
    local initialItem=itemValues[1]
    local initialSkins=skinNamesFor(initialItem)
    selectedSkinItem=initialItem; selectedSkinName=initialSkins[1]
    weaponSkinGroup:AddDropdown("WeaponSkinName",{Text="Skin",Values=initialSkins,Default=1,Callback=function(v) selectedSkinName=v end})
    weaponSkinGroup:AddButton("Apply Weapon Skin",function()
        if not selectedSkinItem or selectedSkinItem=="None" or not selectedSkinName then pcall(function() Library:Notify("Select a weapon and skin first",3) end); return end
        weaponSkinChoices[selectedSkinItem]=selectedSkinName
        local n=applyWeaponSkin(selectedSkinItem,selectedSkinName)
        pcall(function() Library:Notify("Applied "..selectedSkinName.." to "..tostring(n).." inventory item(s)",3) end)
    end)
    weaponSkinGroup:AddButton("Clear Selected Skin",function()
        if not selectedSkinItem then return end
        weaponSkinChoices[selectedSkinItem]=nil
        applyWeaponSkin(selectedSkinItem,"Default")
    end)
    local lastSkinRefresh=0
    conn(RunService.Heartbeat,function()
        local now=os.clock(); if now-lastSkinRefresh<2 then return end; lastSkinRefresh=now
        for itemName,skinName in pairs(weaponSkinChoices) do pcall(applyWeaponSkin,itemName,skinName) end
    end)

    do
    local extEspGroup = tab:AddRightGroupbox("Ext ESP")
    extEspGroup:AddToggle("VPCorpses",{Text="Corpse ESP",Default=false,
        Callback=function(v) extEspState.corpses=v; pcall(extEspScan) end})
    extEspGroup:AddToggle("VPAI",{Text="AI ESP",Default=false,
        Callback=function(v) extEspState.ai=v; pcall(extEspScan) end})
    extEspGroup:AddToggle("VPRadar",{Text="Radar",Default=false,
        Callback=function(v) extEspState.radar=v end})
    extEspGroup:AddSlider("VPRadarRange",{Text="Radar Range",Min=50,Max=600,Default=200,Rounding=0,
        Callback=function(v) extEspState.radarRange=v end})

    local chamsGroup = tab:AddRightGroupbox("Chams")
    chamsGroup:AddToggle("ChamsEnabled", {
        Text="Chams", Default=false,
        Callback=function(v) espState.chams=v; if not v then chamsRestoreMaterials() end end,
    })
    chamsGroup:AddLabel("Chams Color"):AddColorPicker("ChamsColor", {
        Default=espColors.chams, Title="Chams Color",
        Callback=function(v) espColors.chams=v end,
    })
    chamsGroup:AddSlider("ChamsFill",    {Text="Fill Alpha", Min=0, Max=1, Default=0.78, Rounding=2, Callback=function(v) chamsState.fillTransparency=v end})
    chamsGroup:AddToggle("ChamsOutline", {Text="Outline",    Default=false, Callback=function(v) chamsState.outline=v end})
    chamsGroup:AddSlider("ChamsOutlineA",{Text="Outline Alpha",Min=0,Max=1,Default=0.35,Rounding=2,Callback=function(v) chamsState.outlineTransparency=v end})
    chamsGroup:AddLabel("Outline Color"):AddColorPicker("ChamsOutlineColor",{Default=chamsState.outlineColor,Title="Outline Color",Callback=function(v) chamsState.outlineColor=v end})
    chamsGroup:AddToggle("ChamsRainbow", {Text="Rainbow",    Default=false, Callback=function(v) chamsState.rainbow=v end})
    chamsGroup:AddToggle("ChamsPulse",   {Text="Pulse",      Default=false, Callback=function(v) chamsState.pulse=v end})
    chamsGroup:AddToggle("ChamsStrobe",  {Text="Strobe",     Default=false, Callback=function(v) chamsState.strobe=v end})
    chamsGroup:AddSlider("ChamsIntensity",{Text="Intensity", Min=0,Max=1,Default=0.5,Rounding=2,Callback=function(v) chamsState.intensity=v end})
    chamsGroup:AddSlider("ChamsSat",     {Text="Saturation", Min=0,Max=1,Default=1,  Rounding=2,Callback=function(v) chamsState.saturation=v end})
    chamsGroup:AddDropdown("ChamsMaterial",{
        Text="Material", Values={"Neon","ForceField","Glass","SmoothPlastic"}, Default=1,
        Callback=function(v) chamsState.material=v end,
    })
end

    end
    local tab = Tabs.Player
    do
    local moveGroup = tab:AddLeftGroupbox("Movement")

    moveGroup:AddToggle("FlyEnabled", {
        Text="Flyhack", Default=false,
        Callback=function(v) movementState.flyEnabled=v end,
    }):AddKeyPicker("FlyKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Flyhack"})

    moveGroup:AddSlider("FlySpeed",  {Text="Fly Speed",  Min=1,Max=50,Default=10,Rounding=0,Callback=function(v) movementState.flySpeed=v end})
    moveGroup:AddSlider("FlyVSpeed", {Text="Vert Speed", Min=1,Max=50,Default=10,Rounding=0,Callback=function(v) movementState.flyVSpeed=v end})

    moveGroup:AddToggle("SpeedEnabled", {
        Text="Speed Hack", Default=false,
        Callback=function(v) movementState.speedEnabled=v end,
    }):AddKeyPicker("SpeedKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Speed Hack"})

    moveGroup:AddSlider("SpeedValue", {Text="Speed",Min=16,Max=22,Default=20,Rounding=0,Callback=function(v) movementState.speedValue=v end})
    moveGroup:AddToggle("NoFallEnabled", {Text="No Fall", Default=false, Callback=function(v) movementState.noFallEnabled=v end})
    moveGroup:AddDropdown("MineMode", {
        Text = "Detonation mode",
        Values = {"All","One"},
        Default = 1,
        Callback = function(v) movementState.explodeMinesMode = v end,
    })
    moveGroup:AddButton("Explode Landmines", function()
        explodeLandmines(movementState.explodeMinesMode or "All")
    end)
    moveGroup:AddToggle("ExtendReach", {
        Text = "Extend Reach",
        Default = false,
        Callback = function(v)
            movementState.extendReach = v
            pcall(setExtendReach, v)
        end,
    })
    moveGroup:AddToggle("PeekBlink", {
        Text = "Peek Blink",
        Default = false,
        Callback = function(v)
            movementState.peekBlink = v
            if not v then pbPos = nil end
        end,
    }):AddKeyPicker("PBKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="Peek Blink"})
    moveGroup:AddDropdown("WaterMode", {Text="Water Mode", Values={"Off","Walk on Water","Moses"}, Default=1, Callback=function(v) movementState.waterMode=v end})

    local camGroup = tab:AddRightGroupbox("Camera")
    camGroup:AddToggle("FOVChanger", {
        Text="FOV Changer", Default=false,
        Callback=function(v) movementState.fovEnabled=v end,
    }):AddKeyPicker("FOVKey", {Default="None", SyncToggleState=true, Mode="Toggle", Text="FOV Changer"})

    camGroup:AddSlider("FOVValue", {Text="Camera FOV",Min=30,Max=120,Default=70,Rounding=0,Callback=function(v) movementState.fovValue=v end})

    camGroup:AddToggle("ZoomEnabled", {
        Text="Zoom", Default=false,
        Callback=function(v)
            movementState.zoomEnabled=v
            if not v then movementState._zoomActive=false end
        end,
    }):AddKeyPicker("ZoomKey", {
        Default="None",
        Mode="Hold",
        Text="Zoom",
        SyncToggleState=false,
        Callback=function(v)

            if movementState.zoomEnabled then
                movementState._zoomActive = v and true or false
            end
        end,
    })
    camGroup:AddSlider("ZoomFOV", {Text="Zoom FOV",Min=10,Max=80,Default=40,Rounding=0,Callback=function(v) movementState.zoomFov=v end})

    local thirdGroup = tab:AddRightGroupbox("Third Person")
    thirdGroup:AddToggle("ThirdPersonEnabled",{Text="Third Person",Default=false,Callback=function(v) thirdPersonState.enabled=v end})
        :AddKeyPicker("ThirdPersonKey",{Default="None",SyncToggleState=true,Mode="Toggle",Text="Third Person"})
    thirdGroup:AddSlider("ThirdPersonDistance",{Text="Camera Distance",Min=1,Max=50,Default=10,Rounding=1,Callback=function(v) thirdPersonState.distance=v end})
    thirdGroup:AddToggle("ThirdPersonLockBody",{Text="Lock Body To Camera",Default=true,Callback=function(v) thirdPersonState.lockBody=v end})
    thirdGroup:AddToggle("ThirdPersonFade",{Text="Zoom Fade",Default=true,Callback=function(v) thirdPersonState.fade=v end})
    thirdGroup:AddSlider("ThirdPersonFadeSpeed",{Text="Fade Speed",Min=2,Max=30,Default=14,Rounding=1,Callback=function(v) thirdPersonState.fadeSpeed=v end})
    thirdGroup:AddSlider("ThirdPersonFadeAmount",{Text="Fade Transparency",Min=0.1,Max=1,Default=0.85,Rounding=2,Callback=function(v) thirdPersonState.fadeTransparency=v end})

    local vmGroup = tab:AddLeftGroupbox("Viewmodel")
    vmGroup:AddToggle("VMArms",{Text="Arm Chams",Default=false,
        Callback=function(v) VMChams.armEnabled=v; VMChams.Refresh() end})
    vmGroup:AddLabel("Arm Color"):AddColorPicker("VMArmColor",{Default=VMChams.armColor,Title="Arm Color",
        Callback=function(v) VMChams.armColor=v; VMChams.Refresh() end})
    vmGroup:AddDropdown("VMArmMat",{Text="Arm Material",Values={"SmoothPlastic","Neon","ForceField","Glass"},Default=1,
        Callback=function(v) VMChams.armMaterial=v; VMChams.Refresh() end})
    vmGroup:AddSlider("VMArmAlpha",{Text="Arm Transparency",Min=0,Max=1,Default=0,Rounding=2,
        Callback=function(v) VMChams.armTransparency=v; VMChams.Refresh() end})
    vmGroup:AddToggle("VMGun",{Text="Gun Chams",Default=false,
        Callback=function(v) VMChams.gunEnabled=v; VMChams.Refresh() end})
    vmGroup:AddLabel("Gun Color"):AddColorPicker("VMGunColor",{Default=VMChams.gunColor,Title="Gun Color",
        Callback=function(v) VMChams.gunColor=v; VMChams.Refresh() end})
    vmGroup:AddDropdown("VMGunMat",{Text="Gun Material",Values={"SmoothPlastic","Neon","ForceField","Glass"},Default=1,
        Callback=function(v) VMChams.gunMaterial=v; VMChams.Refresh() end})
    vmGroup:AddSlider("VMGunAlpha",{Text="Gun Transparency",Min=0,Max=1,Default=0,Rounding=2,
        Callback=function(v) VMChams.gunTransparency=v; VMChams.Refresh() end})    vmGroup:AddToggle("VMOffsetEnabled",{Text="Enable Offsets",Default=false,
        Callback=function(v) viewmodelState.offsetEnabled=v end})
    vmGroup:AddSlider("VMOffsetX",{Text="Offset X",Min=-50,Max=50,Default=0,Rounding=0,Callback=function(v) viewmodelState.x=v end})
    vmGroup:AddSlider("VMOffsetY",{Text="Offset Y",Min=-50,Max=50,Default=0,Rounding=0,Callback=function(v) viewmodelState.y=v end})
    vmGroup:AddSlider("VMOffsetZ",{Text="Offset Z",Min=-50,Max=50,Default=0,Rounding=0,Callback=function(v) viewmodelState.z=v end})    vmGroup:AddToggle("VMHighlight",{Text="Highlight",Default=false,
        Callback=function(v) viewmodelState.highlight=v end})
    vmGroup:AddLabel("Fill Color"):AddColorPicker("VMFillColor",{Default=viewmodelState.fillColor,Title="Fill",
        Callback=function(v) viewmodelState.fillColor=v end})
    vmGroup:AddSlider("VMFillAlpha",{Text="Fill Transparency",Min=0,Max=1,Default=0,Rounding=2,
        Callback=function(v) viewmodelState.fillTransparency=v end})
    vmGroup:AddLabel("Outline Color"):AddColorPicker("VMOutlineColor",{Default=viewmodelState.outlineColor,Title="Outline",
        Callback=function(v) viewmodelState.outlineColor=v end})
    vmGroup:AddSlider("VMOutlineAlpha",{Text="Outline Transparency",Min=0,Max=1,Default=0,Rounding=2,
        Callback=function(v) viewmodelState.outlineTransparency=v end})
    vmGroup:AddSlider("VMFillMult",{Text="Fill Multiplier",Min=0,Max=2,Default=1,Rounding=2,
        Callback=function(v) viewmodelState.fillMult=v end})
    vmGroup:AddSlider("VMOutlineMult",{Text="Outline Multiplier",Min=0,Max=2,Default=1,Rounding=2,
        Callback=function(v) viewmodelState.outlineMult=v end})    vmGroup:AddToggle("VMNoArms",{Text="Hide Arms",Default=false,Callback=function(v) viewmodelState.noArms=v end})
    vmGroup:AddToggle("VMRemoveClothing",{Text="Remove Clothing",Default=false,Callback=function(v) viewmodelState.removeClothing=v end})
    vmGroup:AddToggle("VMUnlockSkins",{Text="Unlock All Skins (local)",Default=false,Callback=function(v) viewmodelState.unlockSkins=v end})
end

local function restoreThirdPerson()
    Player.CameraMaxZoomDistance=thirdPersonOriginal.max
    Player.CameraMinZoomDistance=thirdPersonOriginal.min
    Player.CameraMode=thirdPersonOriginal.mode
    thirdPersonWasOn=false
end

local function updateThirdPerson(dt)
    local enabled=thirdPersonState.enabled
    local char=Player.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local cam=workspace.CurrentCamera
    if enabled and cam and hum then
        thirdPersonWasOn=true
        Player.CameraMode=Enum.CameraMode.Classic
        Player.CameraMinZoomDistance=thirdPersonState.distance
        Player.CameraMaxZoomDistance=thirdPersonState.distance
        if cam.CameraType~=Enum.CameraType.Custom then cam.CameraType=Enum.CameraType.Custom end
        if cam.CameraSubject~=hum then cam.CameraSubject=hum end
        if thirdPersonState.lockBody and not Library.Unloaded and not (Library.Window and Library.Window.Holder and Library.Window.Holder.Visible) then
            local root=char:FindFirstChild("HumanoidRootPart")
            if root then
                local look=cam.CFrame.LookVector
                root.CFrame=CFrame.new(root.Position,root.Position+Vector3.new(look.X,0,look.Z))
            end
        end
    elseif thirdPersonWasOn then
        restoreThirdPerson()
    end

    local want=0
    if enabled and thirdPersonState.fade and char and cam then
        local aiming=UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if aiming then want=thirdPersonState.fadeTransparency end
    end
    local alpha=math.clamp((dt or 1/60)*thirdPersonState.fadeSpeed,0,1)
    thirdPersonFade=thirdPersonFade+(want-thirdPersonFade)*alpha
    if char and (thirdPersonFade>0.001 or #thirdPersonFadeParts>0) then
        local now=os.clock()
        if thirdPersonFadeCharacter~=char or now-thirdPersonFadeRefresh>1 then
            thirdPersonFadeCharacter=char; thirdPersonFadeRefresh=now; table.clear(thirdPersonFadeParts)
            for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then thirdPersonFadeParts[#thirdPersonFadeParts+1]=part end end
        end
        for _,part in ipairs(thirdPersonFadeParts) do
            if part.Parent then
                if thirdPersonPartOriginals[part]==nil then thirdPersonPartOriginals[part]=part.LocalTransparencyModifier end
                part.LocalTransparencyModifier=thirdPersonFade>0.001 and thirdPersonFade or (thirdPersonPartOriginals[part] or 0)
            end
        end
    end
end

local function ensureItemFinderGui()
    if itemFinderGui and itemFinderGui.Parent then return end
    itemFinderGui=Instance.new("ScreenGui")
    itemFinderGui.Name="OmniItemFinder"; itemFinderGui.ResetOnSpawn=false; itemFinderGui.IgnoreGuiInset=true; itemFinderGui.DisplayOrder=90; itemFinderGui.Parent=CoreGui
    itemFinderFrame=Instance.new("Frame"); itemFinderFrame.Name="Panel"; itemFinderFrame.Position=UDim2.fromOffset(22,250); itemFinderFrame.Size=UDim2.fromOffset(245,190); itemFinderFrame.BackgroundColor3=Color3.fromRGB(18,18,22); itemFinderFrame.BackgroundTransparency=0.08; itemFinderFrame.BorderSizePixel=0; itemFinderFrame.Visible=false; itemFinderFrame.Parent=itemFinderGui
    local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,5); corner.Parent=itemFinderFrame
    local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(65,65,75); stroke.Thickness=1; stroke.Parent=itemFinderFrame
    local title=Instance.new("TextLabel"); title.BackgroundTransparency=1; title.Position=UDim2.fromOffset(10,6); title.Size=UDim2.new(1,-20,0,22); title.Font=Enum.Font.GothamBold; title.TextSize=13; title.TextXAlignment=Enum.TextXAlignment.Left; title.TextColor3=Library.AccentColor; title.Text="ITEM FINDER"; title.Parent=itemFinderFrame
    itemFinderText=Instance.new("TextLabel"); itemFinderText.BackgroundTransparency=1; itemFinderText.Position=UDim2.fromOffset(10,32); itemFinderText.Size=UDim2.new(1,-20,1,-40); itemFinderText.Font=Enum.Font.Code; itemFinderText.TextSize=12; itemFinderText.TextXAlignment=Enum.TextXAlignment.Left; itemFinderText.TextYAlignment=Enum.TextYAlignment.Top; itemFinderText.TextWrapped=false; itemFinderText.TextColor3=Color3.fromRGB(225,225,230); itemFinderText.Text="Enter an item name"; itemFinderText.Parent=itemFinderFrame
end

local itemFinderLastScan, itemFinderResults=0,{}
local function scanForItems()
    local query=itemFinderState.query:lower():gsub("^%s+",""):gsub("%s+$","")
    local results={}
    if query=="" then return results end
    local playerFolder=ReplicatedStorage:FindFirstChild("Players")
    if playerFolder then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=Player then
                local data=playerFolder:FindFirstChild(plr.Name)
                local inv=data and data:FindFirstChild("Inventory")
                if inv then
                    for _,item in ipairs(inv:GetChildren()) do
                        if item.Name:lower():find(query,1,true) then results[#results+1]=plr.Name.."  •  "..item.Name end
                        local attachments=item:FindFirstChild("Attachments")
                        if attachments then for _,att in ipairs(attachments:GetChildren()) do
                            if att.Name:lower():find(query,1,true) then results[#results+1]=plr.Name.."  •  "..att.Name end
                        end end
                    end
                end
            end
            if #results>=itemFinderState.maxResults then break end
        end
    end
    return results
end

local function updateItemFinder()
    if not itemFinderState.enabled then
        if itemFinderFrame then itemFinderFrame.Visible=false end
        return
    end
    ensureItemFinderGui()
    itemFinderFrame.Visible=true
    if os.clock()-itemFinderLastScan>=1 then
        itemFinderLastScan=os.clock(); itemFinderResults=scanForItems()
    end
    local query=itemFinderState.query
    if query=="" then itemFinderText.Text="Type an item name in the Item Finder controls."
    elseif #itemFinderResults==0 then itemFinderText.Text="No matching items found."
    else itemFinderText.Text=table.concat(itemFinderResults,"\n") end
end

conn(RunService.RenderStepped,function(dt)
    pcall(updateThirdPerson,dt)
    pcall(updateItemFinder)
end)

    local tab = Tabs.World
    do

    local lightGroup = tab:AddLeftGroupbox("Lighting")
    lightGroup:AddToggle("FullBright",{Text="Full Bright",Default=false,
        Callback=function(v) worldFx.fullBright=v; worldApplyAll() end,
    }):AddKeyPicker("FullBrightKey",{Default="None", SyncToggleState=true, Mode="Toggle",Text="Full Bright"})
    lightGroup:AddToggle("NoFog",{Text="No Fog",Default=false,
        Callback=function(v) worldFx.noFog=v; worldApplyAll() end})
    lightGroup:AddToggle("AmbientOn",{Text="Custom Ambient",Default=false,
        Callback=function(v) worldFx.ambientOn=v; worldApplyAll() end})
    lightGroup:AddLabel("Ambient A"):AddColorPicker("AmbientA",{Default=Color3.new(1,1,1),Title="Ambient A",
        Callback=function(v) worldFx.ambientA=v; if worldFx.ambientOn then worldApplyAll() end end})
    lightGroup:AddLabel("Ambient B"):AddColorPicker("AmbientB",{Default=Color3.new(1,1,1),Title="Ambient B",
        Callback=function(v) worldFx.ambientB=v; if worldFx.ambientOn then worldApplyAll() end end})
    lightGroup:AddToggle("TimeOn",{Text="Custom Time",Default=false,
        Callback=function(v) worldFx.timeOn=v; worldApplyAll() end})
    lightGroup:AddSlider("TimeVal",{Text="Time of Day",Min=0,Max=24,Default=12,Rounding=1,
        Callback=function(v) worldFx.timeVal=v; if worldFx.timeOn then worldApplyAll() end end})

    local skyGroup = tab:AddRightGroupbox("Sky")
    skyGroup:AddToggle("SkyOn",{Text="Custom Sky",Default=false,
        Callback=function(v) worldFx.skyOn=v; worldApplyAll() end})
    local skyNames = {}; for _,p in ipairs(WORLD_SKY_PRESETS) do skyNames[#skyNames+1]=p.name end
    skyGroup:AddDropdown("SkyPreset",{Text="Preset",Values=skyNames,Default=1,
        Callback=function(v)
            for i,p in ipairs(WORLD_SKY_PRESETS) do if p.name==v then worldFx.skyPreset=i; break end end
            if worldFx.skyOn then worldApplyAll() end
        end})

    local fxGroup = tab:AddLeftGroupbox("Post FX")
    fxGroup:AddToggle("BloomOn",{Text="Bloom",Default=false,
        Callback=function(v) worldFx.bloomOn=v; worldApplyAll() end})
    fxGroup:AddSlider("BloomIntensity",{Text="Bloom Intensity",Min=0,Max=5,Default=0.5,Rounding=2,
        Callback=function(v) worldFx.bloomIntensity=v; if worldFx.bloomOn then worldApplyAll() end end})
    fxGroup:AddSlider("BloomSize",{Text="Bloom Size",Min=0,Max=56,Default=24,Rounding=0,
        Callback=function(v) worldFx.bloomSize=v; if worldFx.bloomOn then worldApplyAll() end end})
    fxGroup:AddToggle("GradeOn",{Text="Color Grade",Default=false,
        Callback=function(v) worldFx.gradeOn=v; worldApplyAll() end})
    fxGroup:AddSlider("GradeSat",{Text="Saturation",Min=-100,Max=150,Default=0,Rounding=0,
        Callback=function(v) worldFx.gradeSat=v; if worldFx.gradeOn then worldApplyAll() end end})
    fxGroup:AddSlider("GradeContrast",{Text="Contrast",Min=-100,Max=100,Default=0,Rounding=0,
        Callback=function(v) worldFx.gradeContrast=v; if worldFx.gradeOn then worldApplyAll() end end})
    fxGroup:AddSlider("GradeBrightness",{Text="Brightness",Min=-100,Max=100,Default=0,Rounding=0,
        Callback=function(v) worldFx.gradeBrightness=v; if worldFx.gradeOn then worldApplyAll() end end})

    local terrainGroup = tab:AddRightGroupbox("Terrain")
    terrainGroup:AddToggle("RemoveGrass",{Text="No Grass",Default=false,
        Callback=function(v) worldFx.removeGrass=v; worldApplyAll() end})
    terrainGroup:AddToggle("PotatoMode",{Text="Potato Mode",Default=false,
        Callback=function(v) worldFx.potato=v; worldApplyAll() end})
    terrainGroup:AddToggle("NoLeaves",{Text="No Leaves",Default=false,
        Callback=function(v) worldFx.noLeaves=v; worldApplyFoliage() end})
    terrainGroup:AddToggle("NoFoliage",{Text="No Foliage",Default=false,
        Callback=function(v) worldFx.noFoliage=v; worldApplyFoliage() end})
    terrainGroup:AddToggle("NoTrees",{Text="No Trees",Default=false,
        Callback=function(v) worldFx.noTrees=v; worldApplyFoliage() end})
    terrainGroup:AddToggle("NoClouds",{Text="No Clouds",Default=false,
        Callback=function(v) worldFx.noClouds=v; worldApplyClouds() end})
end

    local tab = Tabs.Misc
    do
    local featGroup = tab:AddLeftGroupbox("Features")

    featGroup:AddToggle("ACBypass",{Text="AC Bypass",Default=true,
        Callback=function(v) ACBypassEnabled=v; if v then pcall(acKill) end end})
    featGroup:AddToggle("ModDetector",{Text="Mod Detector",Default=false,
        Callback=function(v)
            detectState.mod=v
            if v then pcall(function() Library:Notify("Mod Detector enabled",3) end) end
        end})
    featGroup:AddToggle("CheaterDetector",{Text="Cheater Detector",Default=false,
        Callback=function(v)
            detectState.cheater=v
            if v then pcall(function() Library:Notify("Cheater Detector enabled",3) end) end
        end})
    featGroup:AddButton("Show Moderator List", function()
        local list = refreshModList()
        if #list == 0 then
            pcall(function() Library:Notify("No moderators found in server",4) end)
        else
            pcall(function() Library:Notify("Mods: "..table.concat(list, ", "), 8) end)
        end
    end)
    featGroup:AddButton("Rejoin", function()
        doRejoin()
    end)
    featGroup:AddToggle("UACReports",{Text="UAC Report Alerts",Default=false,
        Callback=function(v) reportState.alerts=v end})
    featGroup:AddToggle("HideNameChat",{Text="Hide Name in Chat",Default=false,
        Callback=function(v) hideChatName=v end})
    featGroup:AddToggle("WatermarkEnabled",{Text="OMNI Watermark",Default=true,
        Callback=function(v)
            watermarkEnabled=v
            pcall(updateMedalwareWatermark, watermarkFps)
        end})    featGroup:AddToggle("ScreenRemovals",{Text="Enable Removals",Default=false,
        Callback=function(v) screenRemovalState.enabled=v; screenRemovalState.pendingRestore=true end})
    featGroup:AddDropdown("RemoveElements",{
        Text="Removals",
        Values={"Flashbang","Gas Mask","Parallax","Visor","Inventory Background","Inventory Blur","Inventory Decoration"},
        Default={"Visor"},
        Multi=true,
        Callback=function(v)
            local picked={}
            for name,on in pairs(v) do if on then picked[name]=true end end
            screenRemovalState.elements=picked
            screenRemovalState.pendingRestore=true
        end})

    local spoofGroup = tab:AddRightGroupbox("Server Info Spoofer")
    spoofGroup:AddToggle("ServerSpoof",{Text="Spoof Server Info",Default=true,
        Callback=function(v)
            State.serverSpoof.enabled=v
            if type(State.serverSpoofTick)=="function" then pcall(State.serverSpoofTick) end
        end})
    spoofGroup:AddInput("ServerSpoofVersion",{Text="Version",Default="2456807",Placeholder="e.g. 1.0",
        Callback=function(v) State.serverSpoof.version=tostring(v or "") end})
    spoofGroup:AddInput("ServerSpoofUserID",{Text="User ID",Default="find me",Placeholder="e.g. #1989",
        Callback=function(v) State.serverSpoof.userid=tostring(v or "") end})
    spoofGroup:AddInput("ServerSpoofLocation",{Text="Location",Default="little saint james",Placeholder="e.g. BT",
        Callback=function(v) State.serverSpoof.location=tostring(v or "") end})
    spoofGroup:AddInput("ServerSpoofJob",{Text="Job / Link",Default="omni.gg",Placeholder="job id or link",
        Callback=function(v) State.serverSpoof.job=tostring(v or "") end})
    spoofGroup:AddToggle("ServerSpoofHideData",{Text="Hide Network Data",Default=false,
        Callback=function(v) State.serverSpoof.hideData=v end})
    spoofGroup:AddToggle("ServerSpoofHideClientFps",{Text="Hide Client FPS",Default=false,
        Callback=function(v) State.serverSpoof.hideClientFps=v end})
    spoofGroup:AddToggle("ServerSpoofHideServerFps",{Text="Hide Server FPS",Default=false,
        Callback=function(v) State.serverSpoof.hideServerFps=v end})

    local finderGroup = tab:AddRightGroupbox("Item Finder")
    finderGroup:AddToggle("ItemFinderEnabled",{Text="Enable Item Finder",Default=false,Callback=function(v) itemFinderState.enabled=v end})
    finderGroup:AddInput("ItemFinderQuery",{Text="Item Name",Default="",Placeholder="Search item name",Callback=function(v) itemFinderState.query=tostring(v or "") end})
    finderGroup:AddSlider("ItemFinderMaxResults",{Text="Max Results",Min=1,Max=30,Default=12,Rounding=0,Callback=function(v) itemFinderState.maxResults=v end})

    local invGroup = tab:AddLeftGroupbox("Inventory Viewer")
    invGroup:AddToggle("InvCheckerEnabled",{Text="Inventory Viewer",Default=false,
        Callback=function(v) InventoryChecker.setEnabled(v) end
    }):AddKeyPicker("InvCheckerKeybind",{Default="None",SyncToggleState=true,Mode="Toggle",Text="Inventory Viewer"})
    invGroup:AddDropdown("InvViewerMode",{Text="Display Mode",Values={"Text","Image"},Default=1,
        Callback=function(v) InventoryChecker.setOption("inv_mode",v) end})
    invGroup:AddDropdown("InvFilterMode",{Text="Filter Mode",Values={"Off","Gear Only","Valuables","Custom"},Default=1,
        Callback=function(v) InventoryChecker.setOption("inv_filter_mode",v) end})
    invGroup:AddSlider("InvFilterMinValue",{Text="Minimum Value",Min=0,Max=500000,Default=10000,Rounding=0,
        Callback=function(v) InventoryChecker.setOption("inv_filter_minval",v) end})
    local function invItemNames()
        local names={}; local items=ReplicatedStorage:FindFirstChild("ItemsList")
        if items then for _,item in ipairs(items:GetChildren()) do names[#names+1]=item.Name end end
        table.sort(names); return names
    end
    invGroup:AddDropdown("InvFilterItems",{Text="Custom Item Filter",Values=invItemNames(),Default={},Multi=true,
        Callback=function(v) local selected={}; for name,on in pairs(v) do if on then selected[name]=true end end; InventoryChecker.setOption("inv_filter_items",selected) end})
    invGroup:AddLabel("Displayed Info")
    invGroup:AddToggle("InvShowKDR",{Text="Show K/D",Default=false,Callback=function(v) InventoryChecker.setOption("inv_show_kdr",v) end})
    invGroup:AddToggle("InvValue",{Text="Show Estimated Value",Default=false,Callback=function(v) InventoryChecker.setOption("inv_show_value",v) end})
    invGroup:AddToggle("InvShowReports",{Text="Show Reports",Default=false,Callback=function(v) InventoryChecker.setOption("inv_show_reports",v) end})
    invGroup:AddToggle("InvShowTeam",{Text="Show Team",Default=false,Callback=function(v) InventoryChecker.setOption("inv_show_team",v) end})
    invGroup:AddToggle("InvShowHours",{Text="Show Hours Played",Default=false,Callback=function(v) InventoryChecker.setOption("inv_show_hours",v) end})
    invGroup:AddLabel("Scan Targets")
    invGroup:AddToggle("InvBodies",{Text="Dead Body Inventory",Default=false,Callback=function(v) InventoryChecker.setOption("inv_bodies_enabled",v) end})
    invGroup:AddToggle("InvAI",{Text="AI Inventory",Default=false,Callback=function(v) InventoryChecker.setOption("ai_inv_enabled",v) end})
    invGroup:AddLabel("Layout")
    invGroup:AddSlider("InvTextSize",{Text="Text Size",Min=10,Max=18,Default=12,Rounding=0,Callback=function(v) InventoryChecker.setOption("inv_text_size",v) end})
    invGroup:AddSlider("InvLineHeight",{Text="Line Height",Min=12,Max=24,Default=15,Rounding=0,Callback=function(v) InventoryChecker.setOption("inv_line_h",v) end})
    invGroup:AddSlider("InvAimRadius",{Text="Aim Radius",Min=30,Max=400,Default=160,Rounding=0,Callback=function(v) InventoryChecker.setOption("inv_aim_radius",v) end})
    local invWidthOpt=invGroup:AddSlider("InvViewerWidth",{Text="Window Width",Min=260,Max=900,Default=370,Rounding=0,Callback=function(v) InventoryChecker.setOption("inv_width",v) end})
    local invHeightOpt=invGroup:AddSlider("InvViewerHeight",{Text="Window Height",Min=200,Max=1000,Default=470,Rounding=0,Callback=function(v) InventoryChecker.setOption("inv_height",v) end})
    State.inv_size_opts={w=invWidthOpt,h=invHeightOpt}
    State.inv_size_changed=function(w,h)
        local opts=State.inv_size_opts
        if not opts then return end
        if math.abs((opts.w.Value or 0)-w)>0.5 then opts.w:SetValue(w) end
        if math.abs((opts.h.Value or 0)-h)>0.5 then opts.h:SetValue(h) end
    end

    end
    do
    local skinGroup = tab:AddRightGroupbox("Melee Skin")
    skinGroup:AddDropdown("MeleeSkin", {
        Text="Melee Skin",
        Values=MELEE_SKINS_GLOBAL,
        Default=1,
        Callback=function(v)
            skinState.meleeSkin = v
            if v=="None" then return end

            local playersFolder = ReplicatedStorage:FindFirstChild("Players")
            local inv = playersFolder and playersFolder:FindFirstChild(Player.Name) and playersFolder[Player.Name]:FindFirstChild("Inventory")
            local list = ReplicatedStorage:FindFirstChild("ItemsList")
            local target = list and list:FindFirstChild(v)
            if not inv then return end
            for _, item in ipairs(inv:GetChildren()) do
                if item:IsA("ObjectValue") then
                    local ref = item.Value
                    local props = ref and ref:FindFirstChild("ItemProperties")
                    local slot = props and props:FindFirstChild("SlotType") and props.SlotType.Value or ""
                    local n = string.lower(ref and ref.Name or "")
                    local isMelee = slot=="Melee" or n:find("knife") or n:find("axe") or n:find("karambit") or ref.Name=="DV2"
                    if isMelee and target then
                        pcall(function() item.Value=target end)
                    end
                end
            end
        end,
    })
end

    local tab = Tabs.Settings
    do

    local menuGroup = tab:AddLeftGroupbox("Menu")
    menuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind",
    })
    Library.ToggleKeybind = Options.MenuKeybind

    if Library.KeybindFrame then
        Library.KeybindFrame.Visible = true
    end

    do
        local function clearPickingKeybind()
            local picking = Library.PickingKeybind or Library.CurrentlyPicking or Library.ActiveKeybind
            if not picking then

                for _, opt in pairs(Options) do
                    if type(opt) == "table" and opt.Type == "KeyPicker" and opt.Toggled then
                        picking = opt
                        break
                    end
                end
            end
            if not picking then return false end
            if picking.SetValue then
                pcall(function() picking:SetValue("None") end)
            else
                picking.Value = "None"
            end
            picking.Toggled = false
            pcall(function()
                if picking.Display then picking:Display() end
                if picking.Update then picking:Update() end
            end)
            Library.PickingKeybind = nil
            Library.CurrentlyPicking = nil
            Library.ActiveKeybind = nil
            return true
        end
        conn(UIS.InputBegan, function(input, gp)
            if gp then return end
            if input.KeyCode ~= Enum.KeyCode.Delete and input.KeyCode ~= Enum.KeyCode.Backspace then return end
            if clearPickingKeybind() then

            end
        end)
    end

        end
SaveManager:SetLibrary(Library)
    ThemeManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    ThemeManager:SetFolder("Omni/Themes")
    SaveManager:SetFolder("Omni/Configs")
    SaveManager:BuildConfigSection(tab)

    if type(ThemeManager.BuildThemeSection) == "function" then
        ThemeManager:BuildThemeSection(tab)
    elseif type(ThemeManager.ApplyToTab) == "function" then
        ThemeManager:ApplyToTab(tab)
    else

        local tg = tab:AddLeftGroupbox("Theme")
        tg:AddLabel("Theme manager not available on this lib version")
    end

    local unloadGroup = tab:AddRightGroupbox("Unload")
    unloadGroup:AddButton("Unload Omni", function()
        unload()
        Library:Unload()
    end)
end

task.delay(1, function()
    if not shuttingDown then
        pcall(function() SaveManager:LoadAutoloadConfig() end)
    end
end)

pcall(function()
    local name = (gg and gg.__OmniExecutor) or ""
    if name ~= "" then
        Library:Notify("Omni ready ("..name..")", 4)
    else
        Library:Notify("Omni ready", 4)
    end
end)

Library:OnUnload(function()
    unload()
end)
end

buildUI()
end

local ok, err = pcall(runOmni)
if not ok then
    gg.__OMNI_LOADED = nil
    gg.__OmniUnload = nil
    pcall(function() warn("[Omni] load error: " .. tostring(err)) end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Omni", Text = "Load error: " .. tostring(err), Duration = 8
        })
    end)
end
