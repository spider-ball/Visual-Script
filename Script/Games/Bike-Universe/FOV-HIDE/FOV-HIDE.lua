if game.PlaceId ~= 98628861455414 then return end

local RS, TS = game:GetService("RunService"), game:GetService("TweenService")
local PG = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Player = game:GetService("Players").LocalPlayer

-- FOV
local BIKE_FOV, WALK_FOV, SPEED = 120, 90, 6
local cur, target, seatConn = WALK_FOV, WALK_FOV

local function bind(char)
	if seatConn then seatConn:Disconnect() end
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end
	local function upd()
		target = hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") and BIKE_FOV or WALK_FOV
	end
	upd()
	seatConn = hum:GetPropertyChangedSignal("SeatPart"):Connect(upd)
end

if Player.Character then task.spawn(bind, Player.Character) end
Player.CharacterAdded:Connect(bind)

RS:BindToRenderStep("CustomFOV", Enum.RenderPriority.Last.Value, function(dt)
	cur += (target - cur) * (1 - math.exp(-SPEED * dt))
	workspace.CurrentCamera.FieldOfView = cur
end)

-- UI fade
local INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MAP = {
	GuiObject = {"BackgroundTransparency"},
	ImageLabel = {"ImageTransparency"}, ImageButton = {"ImageTransparency"},
	TextLabel = {"TextTransparency", "TextStrokeTransparency"},
	TextButton = {"TextTransparency", "TextStrokeTransparency"},
	TextBox = {"TextTransparency", "TextStrokeTransparency"},
	UIStroke = {"Transparency"},
}

local function path(p)
	local c = PG
	for part in p:gmatch("[^%.]+") do
		c = c and c:FindFirstChild(part)
	end
	return c
end

local cache, tokens = {}, {}

local function build(obj)
	local list = {}
	for _, i in ipairs({obj, table.unpack(obj:GetDescendants())}) do
		local shown, hidden = {}, {}
		for class, props in MAP do
			if i:IsA(class) then
				for _, p in props do shown[p], hidden[p] = i[p], 1 end
			end
		end
		if next(shown) then list[#list + 1] = {i, shown, hidden} end
	end
	cache[obj] = list
	return list
end

local function fade(obj, show)
	if not obj then return end
	local token = {}
	tokens[obj] = token
	local isGui = obj:IsA("ScreenGui")
	local prop = isGui and "Enabled" or "Visible"
	if show then obj[prop] = true end
	for _, v in cache[obj] or build(obj) do
		if v[1].Parent then TS:Create(v[1], INFO, show and v[2] or v[3]):Play() end
	end
	if not show then
		task.delay(INFO.Time, function()
			if tokens[obj] == token then obj[prop] = false end
		end)
	end
end

local hidden, origPhone = false

local function toggle()
	hidden = not hidden
	local show = not hidden
	local spawn, phone = path("MobileControlsTop.Top.Util.Spawn"), path("MobileControlsTop.Top.Util.Phone")

	fade(PG:FindFirstChild("RobuxShopButton"), show)
	fade(PG:FindFirstChild("PumpkinHUD"), show)
	fade(path("MobileControlsTop.Top.Util.Build"), show)
	fade(path("MobileControlsTop.Top.Util.Bikes"), show)
	fade(spawn, show)

	if phone then
		origPhone = origPhone or phone.Position
		local pos = hidden and spawn and spawn.Position or origPhone
		TS:Create(phone, INFO, {Position = pos}):Play()
	end
end

-- Кнопка
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "MyToggleGui", false, true

local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(50, 15)
btn.Position = UDim2.fromScale(0.5, 1)
btn.AnchorPoint = Vector2.new(0.5, 1)
btn.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
btn.BackgroundTransparency = 0.7
btn.BorderSizePixel = 0
btn.Text = ""
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

btn.MouseButton1Click:Connect(toggle)
gui.Parent = PG
