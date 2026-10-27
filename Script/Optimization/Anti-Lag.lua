-- ==========================================
-- OPT v10
-- ==========================================
local Players   = game:GetService("Players")
local Lighting  = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UIS       = game:GetService("UserInputService")

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
local TARGET_FOG = 180
local TARGET_BRIGHTNESS = 0.5
local YIELD_EVERY = 500

local EFFECT_CLASSES = { ParticleEmitter=true, Beam=true, Trail=true, Smoke=true, Fire=true, Sparkles=true, Highlight=true }
local LIGHT_CLASSES  = { PointLight=true, SpotLight=true, SurfaceLight=true }
local POST_FX = { BloomEffect=true, BlurEffect=true, DepthOfFieldEffect=true, SunRaysEffect=true }

local function weak() return setmetatable({}, { __mode = "k" }) end

local enabled = false
local restore = { effects = weak(), lights = weak(), postFx = weak(), lighting = nil, quality = nil }
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
-- СВЕТ И ЭФФЕКТЫ
-- ==========================================
local function killLight(obj)
    if KEEP_OWN_LIGHTS and isProtected(obj) then return end
    if restore.lights[obj] == nil then restore.lights[obj] = obj.Enabled end
    obj.Enabled = false

    if not lightHooks[obj] then
        lightHooks[obj] = obj:GetPropertyChangedSignal("Enabled"):Connect(function()
            if enabled and obj.Enabled then
                restore.lights[obj] = true -- игра хотела включить: запомним
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

local function handle(obj)
    local cls = obj.ClassName
    if LIGHT_CLASSES[cls] then
        killLight(obj)
    elseif EFFECT_CLASSES[cls] then
        killEffect(obj)
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
local function holdProperty(prop, target)
    table.insert(conns, Lighting:GetPropertyChangedSignal(prop):Connect(function()
        if enabled and Lighting[prop] ~= target then
            if restore.lighting then restore.lighting[prop] = Lighting[prop] end -- значение игры
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

    Lighting.FogEnd = TARGET_FOG
    Lighting.Brightness = TARGET_BRIGHTNESS
    Lighting.GlobalShadows = false
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
    restore.effects, restore.lights, restore.postFx = weak(), weak(), weak()

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
local activeInput, dragStart, startAbs, dragDistance = nil, nil, nil, 0

local function clampToScreen(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return pos end
    local vp, size = cam.ViewportSize, btn.AbsoluteSize
    return Vector2.new(
        math.clamp(pos.X, 0, math.max(0, vp.X - size.X)),
        math.clamp(pos.Y, 0, math.max(0, vp.Y - size.Y))
    )
end

btn.InputBegan:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        activeInput = input
        dragStart = input.Position
        startAbs = btn.AbsolutePosition
        dragDistance = 0
    end
end)

UIS.InputChanged:Connect(function(input)
    if not activeInput then return end
    local isMove = input == activeInput or input.UserInputType == Enum.UserInputType.MouseMovement
    if not isMove then return end

    local delta = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(dragStart.X, dragStart.Y)
    dragDistance = math.max(dragDistance, math.abs(delta.X) + math.abs(delta.Y))
    if dragDistance > DRAG_THRESHOLD then
        local p = clampToScreen(startAbs + delta)
        btn.Position = UDim2.fromOffset(p.X, p.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if activeInput and input == activeInput then
        if dragDistance <= DRAG_THRESHOLD then
            if enabled then disable() else enable() end
        end
        activeInput = nil
    end
end)

print("[OPT v10] Готово.")
