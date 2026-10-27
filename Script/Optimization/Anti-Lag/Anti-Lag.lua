-- ==========================================
-- OPT v15
-- ==========================================
local Players    = game:GetService("Players")
local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local UIS        = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PG = Player:WaitForChild("PlayerGui", 10)
if not PG then return end

-- Убираем дубль при повторном запуске
local old = PG:FindFirstChild("OptGui")
if old then old:Destroy() end

-- ==========================================
-- НАСТРОЙКИ
-- ==========================================
local KEEP_OWN_LIGHTS = false -- true = не трогать свет на своём персонаже (фонарик)
local KEEP_OWN_NEON = false   -- true = не трогать неон на своём персонаже и машине
local TARGET_FOG = 180
local TARGET_BRIGHTNESS = 1
local YIELD_EVERY = 500

local EFFECT_CLASSES = { ParticleEmitter=true, Beam=true, Trail=true, Smoke=true, Fire=true, Sparkles=true, Highlight=true }
local LIGHT_CLASSES  = { PointLight=true, SpotLight=true, SurfaceLight=true }
-- Эффекты ударов/падений (ColorCorrection и новые эффекты в камере) не трогаем
local POST_FX = { BloomEffect=true, BlurEffect=true, DepthOfFieldEffect=true, SunRaysEffect=true }

local function weak() return setmetatable({}, { __mode = "k" }) end

local enabled = false
local restore = { effects = weak(), lights = weak(), postFx = weak(), neon = weak(), lighting = nil, quality = nil }
local conns = {}
local lightHooks = weak()
local cleanToken = 0

-- ==========================================
-- КНОПКА
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "OptGui", false, true
gui.DisplayOrder = 999
gui.Parent = PG

local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(50, 24)
btn.Position = UDim2.new(1, -70, 0, 60)
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn.BackgroundTransparency = 0.6
btn.TextColor3 = Color3.fromRGB(255, 80, 80)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.Text = "OFF"
btn.BorderSizePixel = 0
btn.AutoButtonColor = false
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(255, 80, 80)
stroke.Thickness = 1.5
stroke.Transparency = 0.5

-- ==========================================
-- ЗАЩИТА (только ТВОЙ персонаж и твоя машина)
-- ==========================================
local function isProtected(obj)
    local char = Player.Character
    if not char then return false end
    if obj:IsDescendantOf(char) then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if seat then
        if obj:IsDescendantOf(seat) then return true end
        local vehicle = seat:FindFirstAncestorOfClass("Model")
        if vehicle and obj:IsDescendantOf(vehicle) then return true end
    end
    return false
end

-- ==========================================
-- СВЕТ, ЭФФЕКТЫ, НЕОН
-- ==========================================
local function killLight(obj)
    if KEEP_OWN_LIGHTS and isProtected(obj) then return end
    if restore.lights[obj] == nil then restore.lights[obj] = obj.Enabled end
    obj.Enabled = false

    if not lightHooks[obj] then
        lightHooks[obj] = obj:GetPropertyChangedSignal("Enabled"):Connect(function()
            if enabled and obj.Enabled then
                restore.lights[obj] = true
                obj.Enabled = false
            end
        end)
    end
end

local function killEffect(obj)
    if isProtected(obj) then return end
    if restore.effects[obj] == nil then restore.effects[obj] = obj.Enabled end
    obj.Enabled = false
end

local function killNeon(obj)
    if KEEP_OWN_NEON and isProtected(obj) then return end
    if restore.neon[obj] == nil then restore.neon[obj] = obj.Material end
    obj.Material = Enum.Material.SmoothPlastic
end

local function handle(obj)
    local cls = obj.ClassName
    if LIGHT_CLASSES[cls] then
        killLight(obj)
    elseif EFFECT_CLASSES[cls] then
        killEffect(obj)
    elseif obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
        killNeon(obj)
    end
end

local function cleanOnce(token)
    local list = Workspace:GetDescendants()
    for i, obj in ipairs(list) do
        if not enabled or token ~= cleanToken then return end
        pcall(handle, obj)
        if i % YIELD_EVERY == 0 then task.wait() end
    end
    for _, obj in ipairs(Lighting:GetChildren()) do
        if POST_FX[obj.ClassName] then
            pcall(function()
                if restore.postFx[obj] == nil then restore.postFx[obj] = obj.Enabled end
                obj.Enabled = false
            end)
        end
    end
end

-- ==========================================
-- LIGHTING: удержание значений
-- ==========================================
local function applyLighting()
    pcall(function()
        if Lighting.FogEnd ~= TARGET_FOG then Lighting.FogEnd = TARGET_FOG end
        if Lighting.Brightness ~= TARGET_BRIGHTNESS then Lighting.Brightness = TARGET_BRIGHTNESS end
        if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
    end)
end

local function holdProperty(prop, target)
    table.insert(conns, Lighting:GetPropertyChangedSignal(prop):Connect(function()
        if enabled and Lighting[prop] ~= target then
            if restore.lighting then restore.lighting[prop] = Lighting[prop] end
            Lighting[prop] = target
        end
    end))
end

-- ==========================================
-- ВКЛ / ВЫКЛ
-- ==========================================
local function enable()
    if enabled then return end
    enabled = true
    cleanToken += 1

    restore.lighting = {
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
    }
    pcall(function()
        restore.quality = UserSettings():GetService("UserGameSettings").SavedQualityLevel
    end)

    applyLighting()
    pcall(function()
        UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)

    local token = cleanToken
    task.spawn(cleanOnce, token)

    table.insert(conns, Workspace.DescendantAdded:Connect(function(obj)
        if enabled then pcall(handle, obj) end
    end))
    holdProperty("FogEnd", TARGET_FOG)
    holdProperty("Brightness", TARGET_BRIGHTNESS)
    holdProperty("GlobalShadows", false)

    -- после респавна (авария) очищаем заново
    table.insert(conns, Player.CharacterAdded:Connect(function()
        if not enabled then return end
        task.wait(1)
        cleanToken += 1
        task.spawn(cleanOnce, cleanToken)
        applyLighting()
    end))

    btn.Text = "ON"
    btn.TextColor3 = Color3.fromRGB(80, 255, 120)
    stroke.Color = Color3.fromRGB(80, 255, 120)
end

local function disable()
    if not enabled then return end
    enabled = false
    cleanToken += 1

    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    conns = {}

    for _, c in pairs(lightHooks) do pcall(function() c:Disconnect() end) end
    lightHooks = weak()

    for obj, v in pairs(restore.effects) do
        if obj.Parent then pcall(function() obj.Enabled = v end) end
    end
    for obj, v in pairs(restore.lights) do
        if obj.Parent then pcall(function() obj.Enabled = v end) end
    end
    for obj, v in pairs(restore.postFx) do
        if obj.Parent then pcall(function() obj.Enabled = v end) end
    end
    for obj, v in pairs(restore.neon) do
        if obj.Parent then pcall(function() obj.Material = v end) end
    end
    restore.effects, restore.lights, restore.postFx, restore.neon = weak(), weak(), weak(), weak()

    if restore.lighting then
        for k, v in pairs(restore.lighting) do
            pcall(function() Lighting[k] = v end)
        end
        restore.lighting = nil
    end

    if restore.quality ~= nil then
        pcall(function()
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = restore.quality
        end)
        restore.quality = nil
    end

    btn.Text = "OPT"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    stroke.Color = Color3.fromRGB(255, 80, 80)
end

-- ==========================================
-- ПЕРЕТАСКИВАНИЕ / КЛИК (ПК + тач)
-- ==========================================
local DRAG_THRESHOLD = 10
local activeInput, startInput, startPos, dragging = nil, Vector2.zero, btn.Position, false

local function clampOnScreen()
    local ap, sz, vp = btn.AbsolutePosition, btn.AbsoluteSize, gui.AbsoluteSize
    local fixX = math.clamp(ap.X, 0, math.max(0, vp.X - sz.X)) - ap.X
    local fixY = math.clamp(ap.Y, 0, math.max(0, vp.Y - sz.Y)) - ap.Y
    if fixX ~= 0 or fixY ~= 0 then
        local p = btn.Position
        btn.Position = UDim2.new(p.X.Scale, p.X.Offset + fixX, p.Y.Scale, p.Y.Offset + fixY)
    end
end

btn.InputBegan:Connect(function(input)
    if activeInput then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        activeInput = input
        dragging = false
        startInput = Vector2.new(input.Position.X, input.Position.Y)
        startPos = btn.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not activeInput then return end
    local isMove = input == activeInput
        or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement)
    if not isMove then return end

    local delta = Vector2.new(input.Position.X, input.Position.Y) - startInput
    if not dragging and delta.Magnitude > DRAG_THRESHOLD then
        dragging = true
    end
    if dragging then
        btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        clampOnScreen()
    end
end)

UIS.InputEnded:Connect(function(input)
    if activeInput and input == activeInput then
        if not dragging then
            if enabled then disable() else enable() end
        end
        activeInput, dragging = nil, false
    end
end)

print("[OPT v15] Готово.")
