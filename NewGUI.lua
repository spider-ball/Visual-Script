--==============================================================
-- ROUND MENU (GUI) - minimal: panels, outline, separators only
--==============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- BLOCK 1. SETTINGS
--==============================================================

local MENU_SIZE     = 1
local MENU_OFFSET_X = 0
local MENU_OFFSET_Y = 0
local BASE_SCALE    = 1.05

local Z_OTHER   = 1
local Z_OUTLINE = 100

local COLOR_MAIN_PANEL = Color3.fromRGB(255, 255, 255)
local COLOR_SIDE_PANEL = Color3.fromRGB(100, 100, 100)
local COLOR_LINES      = Color3.fromRGB(0, 0, 0)
local COLOR_OUTLINE    = Color3.fromRGB(0, 0, 0)

local LINE_THICKNESS    = 2
local OUTLINE_THICKNESS = 2

-- Sections (top panel buttons)
local COLOR_SECTION_ACTIVE = Color3.fromRGB(170, 170, 170)
local COLOR_TEXT           = Color3.fromRGB(0, 0, 0)

local SECTIONS_AREA_X     = 0.109   -- start of the buttons row, relative to the top panel
local SECTIONS_AREA_WIDTH = 0.81   -- width of the buttons row (the rest on the right is free space for Move)

local SECTION_ICON_SIZE = 0.9   -- icon height, as a fraction of the button height

-- SECTIONS: one entry per section button (left to right).
--   Name   = text under the icon
--   IconId = rbxassetid number of the icon (change the number for each section)
--   Tabs   = (optional) list of { Title = "...", IconId = 123 } for this section's tabs.
--            Without it the section gets TABS_PER_SECTION default tabs.
local SECTIONS = {
	{ Name = "Section 1",  IconId = 108716693326627 },
	{ Name = "Section 2",  IconId = 108716693326627 },
	{ Name = "Section 3",  IconId = 108716693326627 },
	{ Name = "Section 4",  IconId = 108716693326627 },
	{ Name = "Section 5",  IconId = 108716693326627 },
	{ Name = "Section 6",  IconId = 108716693326627 },
	{ Name = "Section 7",  IconId = 108716693326627 },
	{ Name = "Section 8",  IconId = 108716693326627 },
	{ Name = "Section 9",  IconId = 108716693326627 },
	{ Name = "Section 10", IconId = 108716693326627 },
}

-- Tabs (two columns inside every section: 1 left, 2 right, 3 left, 4 right)
local TAB_ARROW_ID        = 89884279192043    -- rbxassetid number of the open/close icon
local DEFAULT_TAB_ICON_ID = 108716693326627   -- rbxassetid number of the tab icon (default)
local TABS_PER_SECTION    = 4                 -- number of default tabs in a section

local COLOR_TAB_HEADER = COLOR_SIDE_PANEL
local COLOR_TAB_BODY   = Color3.fromRGB(115, 115, 115)

local TAB_HEADER_HEIGHT = 0.13    -- relative to the column height
local TAB_HEADER_WIDTH  = 0.94    -- relative to the tab body width (header is centered above the body)
local TAB_TOGGLE_WIDTH  = 0.15    -- open/close button width, relative to the header width
local TAB_ICON_X        = 0.008   -- tab icon distance from the left edge of the header (bigger = more to the right)
local TAB_BODY_HEIGHT   = 0.29    -- relative to the column height
local TAB_GAP           = 0.03    -- space between two tabs, relative to the column height
local TAB_ICON_SIZE     = 1       -- tab icon height, as a fraction of the tab header height
local TAB_ARROW_SIZE    = 1.5     -- open/close icon height, as a fraction of the tab header height
local TAB_TITLE_SIZE    = 1     -- tab title height, as a fraction of the tab header height

local TAB_ARROW_ROTATION_OPEN   = 0     -- arrow rotation when the tab is open
local TAB_ARROW_ROTATION_CLOSED = 180   -- arrow rotation when the tab is closed

-- Logo (top-left corner of the top panel)
local LOGO_ID   = 117390305692041   -- rbxassetid number of the logo (change to your own)
local LOGO_SIZE = 1.15              -- logo height, as a fraction of the top panel height

--==============================================================
-- BLOCK 2. BUILD GUI
--==============================================================

local old = playerGui:FindFirstChild("RoundedRectGui")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoundedRectGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

----------------------------------------------------------------
-- Utilities
----------------------------------------------------------------
local function makeGroup(name, zIndex)
	local g = Instance.new("Frame")
	g.Name = name
	g.AnchorPoint = Vector2.new(0.5, 0.5)
	g.Position = UDim2.new(0.5, 0, 0.5, 0)
	g.Size = UDim2.new(1, 0, 1, 0)
	g.BackgroundTransparency = 1
	g.BorderSizePixel = 0
	g.ZIndex = zIndex
	g.Parent = screenGui
	return g
end

local function makePart(name, parent, size, pos, color, cornerScale)
	local p = Instance.new("Frame")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.BackgroundColor3 = color
	p.BorderSizePixel = 0
	p.ZIndex = Z_OTHER
	p.Parent = parent

	if cornerScale then
		local c = Instance.new("UICorner")
		c.CornerRadius = cornerScale
		c.Parent = p
	end
	return p
end

local function makeLine(name, parent, isHorizontal, length, position)
	local line = Instance.new("Frame")
	line.Name = name
	if isHorizontal then
		line.Size = UDim2.new(length, 0, 0, LINE_THICKNESS)
	else
		line.Size = UDim2.new(0, LINE_THICKNESS, length, 0)
	end
	line.Position = position
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = COLOR_LINES
	line.BorderSizePixel = 0
	line.ZIndex = Z_OUTLINE
	line.Parent = parent
	return line
end

----------------------------------------------------------------
-- Main panel
----------------------------------------------------------------
local mainGroup = makeGroup("MainGroup", Z_OTHER)

makePart("GrayRect", mainGroup, UDim2.new(0.65, 0, 0.75, 0), UDim2.new(0.55, 0, 0.555, 0), COLOR_MAIN_PANEL, UDim.new(0.11, 0))

local PART_SIZE = UDim2.new(0.03, 0, 0.1, 0)
makePart("MainPart1", mainGroup, PART_SIZE, UDim2.new(0.239, 1, 0.23, 0), COLOR_MAIN_PANEL)
makePart("MainPart2", mainGroup, PART_SIZE, UDim2.new(0.240, 0, 0.88, 0), COLOR_MAIN_PANEL)
makePart("MainPart3", mainGroup, PART_SIZE, UDim2.new(0.86, 0, 0.23, 0), COLOR_MAIN_PANEL)

----------------------------------------------------------------
-- Section pages with tabs (inside the main panel)
----------------------------------------------------------------
local pagesArea = Instance.new("Frame")
pagesArea.Name = "PagesArea"
pagesArea.AnchorPoint = Vector2.new(0.5, 0.5)
pagesArea.Position = UDim2.new(0.55, 0, 0.555, 0)   -- same place as GrayRect
pagesArea.Size = UDim2.new(0.65, 0, 0.75, 0)
pagesArea.BackgroundTransparency = 1
pagesArea.BorderSizePixel = 0
pagesArea.ZIndex = Z_OTHER + 1
pagesArea.Parent = mainGroup

local pages = {}

local function addCornerAndStroke(frame, cornerScale)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(cornerScale, 0)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLOR_OUTLINE
	stroke.Thickness = OUTLINE_THICKNESS
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame
end

local function makeColumn(page, name, x)
	local column = Instance.new("Frame")
	column.Name = name
	column.Position = UDim2.new(x, 0, 0.03, 0)
	column.Size = UDim2.new(0.46, 0, 0.94, 0)
	column.BackgroundTransparency = 1
	column.BorderSizePixel = 0
	column.ZIndex = Z_OTHER
	column.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 2)   -- header and body touch each other, the gap between tabs is TabSpacer
	layout.Parent = column

	return column
end

-- A tab = header (icon, title, open/close button) + body. Closing hides the body,
-- the tabs below move up by themselves (UIListLayout skips invisible objects).
local function makeTab(column, order, data)
	local base = order * 3

	local header = Instance.new("Frame")
	header.Name = "TabHeader"
	header.LayoutOrder = base + 1
	header.Size = UDim2.new(TAB_HEADER_WIDTH, 0, TAB_HEADER_HEIGHT, OUTLINE_THICKNESS)   -- + outline: the bottom of the header is covered by the body outline
	header.BackgroundColor3 = COLOR_TAB_HEADER
	header.BorderSizePixel = 0
	header.ZIndex = Z_OTHER
	header.Parent = column
	addCornerAndStroke(header, 0.3)

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Position = UDim2.new(TAB_ICON_X, 0, 0.5, 0)
	icon.Size = UDim2.new(0.5, 0, TAB_ICON_SIZE, 0)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.Image = "rbxassetid://" .. (data.IconId or DEFAULT_TAB_ICON_ID)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.ZIndex = Z_OTHER
	icon.Parent = header

	local iconRatio = Instance.new("UIAspectRatioConstraint")
	iconRatio.AspectRatio = 1
	iconRatio.Parent = icon

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0, 0.5)
	title.Position = UDim2.new(0.15, 0, 0.5, 0)
	title.Size = UDim2.new(0.55, 0, TAB_TITLE_SIZE, 0)
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.Text = data.Title or "Tab"
	title.TextColor3 = COLOR_TEXT
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = Z_OTHER
	title.Parent = header

	local toggle = Instance.new("TextButton")
	toggle.Name = "Toggle"
	toggle.AnchorPoint = Vector2.new(1, 0.5)
	toggle.Position = UDim2.new(1, 0, 0.5, 0)
	toggle.Size = UDim2.new(TAB_TOGGLE_WIDTH, 0, 1, 0)
	toggle.BackgroundTransparency = 1
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.ZIndex = Z_OTHER
	toggle.Parent = header

	local toggleLine = Instance.new("Frame")
	toggleLine.Name = "Divider"
	toggleLine.AnchorPoint = Vector2.new(0.5, 0.5)
	toggleLine.Position = UDim2.new(0, 0, 0.5, 0)
	toggleLine.Size = UDim2.new(0, LINE_THICKNESS, 1, 0)
	toggleLine.BackgroundColor3 = COLOR_LINES
	toggleLine.BorderSizePixel = 0
	toggleLine.ZIndex = Z_OTHER
	toggleLine.Parent = toggle

	local arrow = Instance.new("ImageLabel")
	arrow.Name = "Arrow"
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)
	arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
	arrow.Size = UDim2.new(5, 0, TAB_ARROW_SIZE, 0)
	arrow.BackgroundTransparency = 1
	arrow.BorderSizePixel = 0
	arrow.Image = "rbxassetid://" .. TAB_ARROW_ID
	arrow.ScaleType = Enum.ScaleType.Fit
	arrow.Rotation = TAB_ARROW_ROTATION_OPEN
	arrow.ZIndex = Z_OTHER
	arrow.Parent = toggle

	local arrowRatio = Instance.new("UIAspectRatioConstraint")
	arrowRatio.AspectRatio = 1
	arrowRatio.Parent = arrow

	local body = Instance.new("Frame")
	body.Name = "TabBody"
	body.LayoutOrder = base + 2
	body.Size = UDim2.new(1, 0, TAB_BODY_HEIGHT, 0)
	body.BackgroundColor3 = COLOR_TAB_BODY
	body.BorderSizePixel = 0
	body.ZIndex = Z_OTHER + 1   -- above the header: its top outline covers the header bottom outline (one line instead of two)
	body.Parent = column
	addCornerAndStroke(body, 0.1)

	-- Empty spacer: the distance between this tab and the next one
	local spacer = Instance.new("Frame")
	spacer.Name = "TabSpacer"
	spacer.LayoutOrder = base + 3
	spacer.Size = UDim2.new(1, 0, TAB_GAP, 0)
	spacer.BackgroundTransparency = 1
	spacer.BorderSizePixel = 0
	spacer.ZIndex = Z_OTHER
	spacer.Parent = column

	local isOpen = true
	toggle.Activated:Connect(function()
		isOpen = not isOpen
		body.Visible = isOpen
		TweenService:Create(arrow, TweenInfo.new(0.15), {
			Rotation = isOpen and TAB_ARROW_ROTATION_OPEN or TAB_ARROW_ROTATION_CLOSED,
		}):Play()
	end)
end

local function makeDefaultTabs()
	local tabs = {}
	for k = 1, TABS_PER_SECTION do
		tabs[k] = { Title = "Tab " .. k, IconId = DEFAULT_TAB_ICON_ID }
	end
	return tabs
end

for i, data in ipairs(SECTIONS) do
	local page = Instance.new("Frame")
	page.Name = "Page" .. i
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = (i == 1)
	page.ZIndex = Z_OTHER
	page.Parent = pagesArea

	local leftColumn  = makeColumn(page, "LeftColumn",  0.02)
	local rightColumn = makeColumn(page, "RightColumn", 0.52)

	-- Tabs go 1 left, 2 right, 3 left, 4 right
	for k, tabData in ipairs(data.Tabs or makeDefaultTabs()) do
		local column = (k % 2 == 1) and leftColumn or rightColumn
		makeTab(column, math.floor((k - 1) / 2), tabData)
	end

	pages[i] = page
end

----------------------------------------------------------------
-- Left side panel + top panel
----------------------------------------------------------------
local sideTopGroup = makeGroup("SideTopGroup", Z_OTHER)

makePart("InnerRect", sideTopGroup, UDim2.new(0.08, 0, 0.9, 0), UDim2.new(0.185, 0, 0.48, 0), COLOR_SIDE_PANEL, UDim.new(0.38, 0))
local topBar = makePart("BlackRect", sideTopGroup, UDim2.new(0.73, 0, 0.15, 0), UDim2.new(0.51, 0, 0.105, 0), COLOR_SIDE_PANEL, UDim.new(0.5, 0))
topBar.ZIndex = Z_OTHER + 1   -- top panel (and everything inside it) above SidePart1-3

makePart("SidePart1", sideTopGroup, UDim2.new(0.03, 0, 0.1, 0),   UDim2.new(0.21, 0, 0.88, 0),   COLOR_SIDE_PANEL)
makePart("SidePart2", sideTopGroup, UDim2.new(0.04, 0, 0.065, 0), UDim2.new(0.165, 0, 0.147, 0), COLOR_SIDE_PANEL)
makePart("SidePart3", sideTopGroup, UDim2.new(0.03, 0, 0.08, 0),  UDim2.new(0.86, 0, 0.14, 0),   COLOR_SIDE_PANEL)

----------------------------------------------------------------
-- Section buttons (top panel)
----------------------------------------------------------------
local sectionsArea = Instance.new("Frame")
sectionsArea.Name = "SectionsArea"
sectionsArea.AnchorPoint = Vector2.new(0, 0.5)
sectionsArea.Position = UDim2.new(SECTIONS_AREA_X, 0, 0.5, 0)
sectionsArea.Size = UDim2.new(SECTIONS_AREA_WIDTH, 0, 1, 0)
sectionsArea.BackgroundTransparency = 1
sectionsArea.BorderSizePixel = 0
sectionsArea.ZIndex = Z_OTHER
sectionsArea.Parent = topBar

local sectionsLayout = Instance.new("UIListLayout")
sectionsLayout.FillDirection = Enum.FillDirection.Horizontal
sectionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
sectionsLayout.Parent = sectionsArea

local sectionButtons = {}
local activeSection = 1

local function setActiveSection(index)
	activeSection = index
	for i, btn in ipairs(sectionButtons) do
		btn.BackgroundTransparency = (i == index) and 0 or 1
	end
	for i, page in ipairs(pages) do
		page.Visible = (i == index)
	end
end

for i, data in ipairs(SECTIONS) do
	local btn = Instance.new("TextButton")
	btn.Name = "Section" .. i
	btn.LayoutOrder = i
	btn.Size = UDim2.new(1 / #SECTIONS, 0, 1, 0)
	btn.BackgroundColor3 = COLOR_SECTION_ACTIVE
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = Z_OTHER
	btn.Parent = sectionsArea

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.Position = UDim2.new(0.5, 0, -0.04, 0)
	icon.Size = UDim2.new(1, 0, SECTION_ICON_SIZE, 0)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.Image = "rbxassetid://" .. data.IconId
	icon.ScaleType = Enum.ScaleType.Fit
	icon.ZIndex = Z_OTHER
	icon.Parent = btn

	local iconRatio = Instance.new("UIAspectRatioConstraint")
	iconRatio.AspectRatio = 1
	iconRatio.Parent = icon

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 0.98, 0)
	label.Size = UDim2.new(1, 0, 0.17, 0)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Text = data.Name
	label.TextColor3 = COLOR_TEXT
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.ZIndex = Z_OTHER
	label.Parent = btn

	-- Separator on the right edge of every button (including the last one)
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.AnchorPoint = Vector2.new(0.5, 0.5)
	divider.Position = UDim2.new(1, 0, 0.5, 0)
	divider.Size = UDim2.new(0, LINE_THICKNESS, 1, 0)
	divider.BackgroundColor3 = COLOR_LINES
	divider.BorderSizePixel = 0
	divider.ZIndex = Z_OTHER
	divider.Parent = btn

	btn.Activated:Connect(function()
		setActiveSection(i)
	end)

	sectionButtons[i] = btn
end

setActiveSection(1)

----------------------------------------------------------------
-- Logo (top panel, left of the section buttons)
----------------------------------------------------------------
local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.Position = UDim2.new(SECTIONS_AREA_X / 2, 0, 0.5, 0)
logo.Size = UDim2.new(SECTIONS_AREA_X, 0, LOGO_SIZE, 0)
logo.BackgroundTransparency = 1
logo.BorderSizePixel = 0
logo.Image = "rbxassetid://" .. LOGO_ID
logo.ScaleType = Enum.ScaleType.Fit
logo.ZIndex = Z_OTHER
logo.Parent = topBar

local logoRatio = Instance.new("UIAspectRatioConstraint")
logoRatio.AspectRatio = 1
logoRatio.Parent = logo

----------------------------------------------------------------
-- Outline of the whole menu + separators
----------------------------------------------------------------
local outlineGroup = makeGroup("OutlineGroup", Z_OUTLINE)

local outline = Instance.new("Frame")
outline.Name = "OutlineRect"
outline.Size = UDim2.new(0.728, 0, 0.9, 0)
outline.Position = UDim2.new(0.51, 0, 0.48, 0)
outline.AnchorPoint = Vector2.new(0.5, 0.5)
outline.BackgroundTransparency = 1
outline.BorderSizePixel = 0
outline.ZIndex = Z_OUTLINE
outline.Parent = outlineGroup

local outlineCorner = Instance.new("UICorner")
outlineCorner.CornerRadius = UDim.new(0.08, 0)
outlineCorner.Parent = outline

local outlineStroke = Instance.new("UIStroke")
outlineStroke.Color = COLOR_OUTLINE
outlineStroke.Thickness = OUTLINE_THICKNESS
outlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
outlineStroke.Parent = outline

-- Top panel / main panel separator
makeLine("Line1", outlineGroup, true,  0.729, UDim2.new(0.51, 0, 0.18, 0))
-- Side panel / main panel separator
makeLine("Line2", outlineGroup, false, 0.91,  UDim2.new(0.224, 0, 0.48, 0))

----------------------------------------------------------------
-- Apply menu size / position
----------------------------------------------------------------
for _, group in ipairs({ mainGroup, sideTopGroup, outlineGroup }) do
	group.Size = UDim2.new(BASE_SCALE * MENU_SIZE, 0, BASE_SCALE * MENU_SIZE, 0)
	group.Position = UDim2.new(0.5 + MENU_OFFSET_X, 0, 0.5 - MENU_OFFSET_Y, 0)
end
