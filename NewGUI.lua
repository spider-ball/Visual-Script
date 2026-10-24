--==============================================================
-- ROUND MENU (GUI) - minimal: panels, outline, separators only
--==============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local SCRIPT_START = os.clock()   -- used for the script uptime in the side panel

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

local SECTION_ICON_SIZE  = 0.9    -- icon height, as a fraction of the button height
local SECTION_LABEL_SIZE = 0.20   -- text height, as a fraction of the button height

-- SECTIONS: one entry per section button (left to right).
--   Name   = text under the icon
--   IconId = rbxassetid number of the icon (change the number for each section)
--   Tabs   = this section's tabs (1 left, 2 right, 3 left, 4 right, ...)
--     Title  = tab name
--     IconId = rbxassetid number of the tab icon
--   More than 4 tabs are fine: the page becomes scrollable.
local SECTIONS = {
	{ Name = "Section 1", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 2", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 3", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 4", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 5", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 6", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 7", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 8", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 9", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
	{ Name = "Section 10", IconId = 108716693326627, Tabs = {
		{ Title = "Tab 1", IconId = 108716693326627 },
		{ Title = "Tab 2", IconId = 108716693326627 },
		{ Title = "Tab 3", IconId = 108716693326627 },
		{ Title = "Tab 4", IconId = 108716693326627 },
	} },
}

-- Tabs (two columns inside every section: 1 left, 2 right, 3 left, 4 right)
local TAB_ARROW_ID        = 89884279192043    -- rbxassetid number of the open/close icon
local DEFAULT_TAB_ICON_ID = 108716693326627   -- tab icon used when a tab has no IconId

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

-- Scroll (the tabs of a section page scroll down when they do not fit)
local PAGE_SCROLL_HEIGHT   = 0.95   -- height of the scroll window, relative to the page (keeps tabs inside the rounded corners)
local SCROLL_BAR_THICKNESS = 0      -- scroll bar width in pixels (0 = hidden, scrolling still works)
local TAB_COLUMN_TOP       = 0.03   -- space above the tabs, relative to the page height
local TAB_COLUMN_HEIGHT    = 0.94   -- the "column height" that the tab sizes above are relative to

-- Logo (top-left corner of the top panel)
local LOGO_ID   = 117390305692041   -- rbxassetid number of the logo (change to your own)
local LOGO_SIZE = 1.15              -- logo height, as a fraction of the top panel height

-- Side panel (left): player card, search, stats. All heights are relative to the side panel height.
local SIDE_CONTENT_WIDTH = 0.84    -- width of the card texts / search box / stats, relative to the side panel width
local SIDE_TOP_GAP       = 0.015   -- space above the white player card panel
local SIDE_ITEM_GAP      = 0.012   -- space between two items
local SIDE_AVATAR_SIZE   = 0.17    -- avatar height (the avatar is round)
local SIDE_NAME_HEIGHT   = 0.045   -- display name height
local SIDE_INFO_HEIGHT   = 0.035   -- @username and ID line height
local SIDE_SEARCH_HEIGHT = 0.07    -- search box height
local SIDE_STATS_HEIGHT  = 0.2     -- height of the 4 stats rows together
local SIDE_STATS_BOTTOM  = 0.97    -- bottom edge of the stats panel (bigger = lower; keep it inside the rounded corner)
local STATS_UPDATE_INTERVAL = 0.5  -- seconds between stats updates
local COLOR_SEARCH_BOX      = Color3.fromRGB(255, 255, 255)   -- white search box
local COLOR_STATS_PANEL     = Color3.fromRGB(255, 255, 255)   -- white panel under the stats
local COLOR_CARD_PANEL      = Color3.fromRGB(255, 255, 255)   -- white panel under the player card
local SIDE_CARD_PADDING     = 0.012   -- space inside the card panel (top and bottom), relative to the side panel height
local SIDE_SEARCH_GAP       = 0.02    -- space between the search box and the stats panel under it
local SIDE_CARD_TEXT_WIDTH  = 0.74    -- width of the name / @username / ID texts inside the card panel
local STATS_TEXT_AREA       = 0.9                              -- stats text size inside the panel (fraction of the panel)
local STATS_TEXT_SIZE       = 14      -- text size of all 4 stats rows (the same for every row; the longest row limits how big it can be)

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

makePart("GrayRect", mainGroup, UDim2.new(0.65, 0, 0.75, 0), UDim2.new(0.55, 0, 0.555, 0), COLOR_MAIN_PANEL, UDim.new(0.096, 0))

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
local pageStates = {}

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
	column.Position = UDim2.new(x, 0, TAB_COLUMN_TOP, 0)
	column.Size = UDim2.new(0.46, 0, TAB_COLUMN_HEIGHT, 0)
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
local function makeTab(column, order, data, columnIndex, onChanged)
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

	local tab = {
		open = true,
		matched = true,   -- false = hidden by the search
		columnIndex = columnIndex,
		title = data.Title or "Tab",
		header = header,
		body = body,
		spacer = spacer,
	}
	toggle.Activated:Connect(function()
		tab.open = not tab.open
		body.Visible = tab.open
		TweenService:Create(arrow, TweenInfo.new(0.15), {
			Rotation = tab.open and TAB_ARROW_ROTATION_OPEN or TAB_ARROW_ROTATION_CLOSED,
		}):Play()
		onChanged()
	end)

	return tab
end

-- Canvas of a page: grows when the tabs do not fit, shrinks when tabs are closed.
-- Column size and position are divided by the canvas size, so the tabs keep the same size on screen.
local function refreshCanvas(pageState)
	local heights = { 0, 0 }   -- [1] = left column, [2] = right column
	for _, tab in ipairs(pageState.tabs) do
		if tab.matched then
			local h = TAB_HEADER_HEIGHT + TAB_GAP
			if tab.open then
				h = h + TAB_BODY_HEIGHT
			end
			heights[tab.columnIndex] = heights[tab.columnIndex] + h
		end
	end

	local content = (TAB_COLUMN_TOP * 2 + math.max(heights[1], heights[2]) * TAB_COLUMN_HEIGHT) / PAGE_SCROLL_HEIGHT
	local canvas = math.max(1, content)
	pageState.scroll.CanvasSize = UDim2.new(0, 0, canvas, 0)

	for _, column in ipairs(pageState.columns) do
		column.Position = UDim2.new(column.Position.X.Scale, 0, TAB_COLUMN_TOP / PAGE_SCROLL_HEIGHT / canvas, 0)
		column.Size = UDim2.new(0.46, 0, TAB_COLUMN_HEIGHT / PAGE_SCROLL_HEIGHT / canvas, 0)
	end
end

-- Places the visible (matching) tabs 1 left, 2 right, 3 left, 4 right and hides the others.
local function arrangeTabs(pageState)
	local shown = 0
	for _, tab in ipairs(pageState.tabs) do
		tab.header.Visible = tab.matched
		tab.spacer.Visible = tab.matched
		tab.body.Visible = tab.matched and tab.open
		if tab.matched then
			shown = shown + 1
			local base = math.floor((shown - 1) / 2) * 3
			tab.columnIndex = (shown % 2 == 1) and 1 or 2
			local column = pageState.columns[tab.columnIndex]
			tab.header.Parent = column
			tab.body.Parent = column
			tab.spacer.Parent = column
			tab.header.LayoutOrder = base + 1
			tab.body.LayoutOrder = base + 2
			tab.spacer.LayoutOrder = base + 3
		end
	end
	refreshCanvas(pageState)
end

for i, data in ipairs(SECTIONS) do
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page" .. i
	page.Size = UDim2.new(1, 0, PAGE_SCROLL_HEIGHT, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.ScrollBarThickness = SCROLL_BAR_THICKNESS
	page.ScrollBarImageColor3 = COLOR_LINES
	page.CanvasSize = UDim2.new(0, 0, 1, 0)
	page.Visible = (i == 1)
	page.ZIndex = Z_OTHER
	page.Parent = pagesArea

	local pageState = {
		scroll  = page,
		columns = { makeColumn(page, "LeftColumn", 0.02), makeColumn(page, "RightColumn", 0.52) },
		tabs    = {},
	}
	local function refresh()
		refreshCanvas(pageState)
	end

	-- Tabs go 1 left, 2 right, 3 left, 4 right
	for k, tabData in ipairs(data.Tabs or {}) do
		local columnIndex = (k % 2 == 1) and 1 or 2
		local tab = makeTab(pageState.columns[columnIndex], math.floor((k - 1) / 2), tabData, columnIndex, refresh)
		table.insert(pageState.tabs, tab)
	end
	arrangeTabs(pageState)

	pages[i] = page
	pageStates[i] = pageState
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
	label.Size = UDim2.new(1, 0, SECTION_LABEL_SIZE, 0)
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
-- Side panel content: player card, search, stats
----------------------------------------------------------------
local localPlayer = Players.LocalPlayer

local sideArea = Instance.new("Frame")
sideArea.Name = "SideArea"
sideArea.AnchorPoint = Vector2.new(0.5, 0)
sideArea.Position = UDim2.new(0.185, 0, 0.185, 0)   -- inside the side panel, under the top panel
sideArea.Size = UDim2.new(0.074, 0, 0.735, 0)
sideArea.BackgroundTransparency = 1
sideArea.BorderSizePixel = 0
sideArea.ZIndex = Z_OTHER + 1   -- above SidePart1-3
sideArea.Parent = sideTopGroup

-- Items are placed one under another (top to bottom)
local sideY = SIDE_TOP_GAP + SIDE_CARD_PADDING

local function placeSideItem(item, height, width)
	item.AnchorPoint = Vector2.new(0.5, 0)
	item.Position = UDim2.new(0.5, 0, sideY, 0)
	item.Size = UDim2.new(width or SIDE_CONTENT_WIDTH, 0, height, 0)
	item.Parent = sideArea
	sideY = sideY + height + SIDE_ITEM_GAP
end

local function makeSideLabel(name, text, textTransparency, alignment)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = COLOR_TEXT
	label.TextTransparency = textTransparency
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = alignment
	label.ZIndex = Z_OTHER
	return label
end

local function makeSideLine(name, anchorY, y)
	local line = Instance.new("Frame")
	line.Name = name
	line.AnchorPoint = Vector2.new(0.5, anchorY)
	line.Position = UDim2.new(0.5, 0, y, 0)
	line.Size = UDim2.new(SIDE_CONTENT_WIDTH, 0, 0, LINE_THICKNESS)
	line.BackgroundColor3 = COLOR_LINES
	line.BorderSizePixel = 0
	line.ZIndex = Z_OTHER
	line.Parent = sideArea
	return line
end

-- White panel behind the player card; its height is set after the card items are placed
local cardPanel = Instance.new("Frame")
cardPanel.Name = "CardPanel"
cardPanel.AnchorPoint = Vector2.new(0.5, 0)
cardPanel.Position = UDim2.new(0.5, 0, SIDE_TOP_GAP, 0)
cardPanel.BackgroundColor3 = COLOR_CARD_PANEL
cardPanel.BorderSizePixel = 0
cardPanel.ZIndex = Z_OTHER - 1   -- under the avatar and texts (they are siblings)
cardPanel.Parent = sideArea
addCornerAndStroke(cardPanel, 0.1)

-- Player card: avatar, display name, @username, user id
local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.BackgroundColor3 = COLOR_TAB_BODY
avatar.BorderSizePixel = 0
avatar.ScaleType = Enum.ScaleType.Crop
avatar.ZIndex = Z_OTHER
placeSideItem(avatar, SIDE_AVATAR_SIZE)
addCornerAndStroke(avatar, 0.5)

local avatarRatio = Instance.new("UIAspectRatioConstraint")
avatarRatio.AspectRatio = 1
avatarRatio.Parent = avatar

task.spawn(function()
	local ok, image = pcall(function()
		return Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	if ok and image then
		avatar.Image = image
	end
end)

placeSideItem(makeSideLabel("DisplayName", localPlayer.DisplayName, 0, Enum.TextXAlignment.Center), SIDE_NAME_HEIGHT, SIDE_CARD_TEXT_WIDTH)
makeSideLine("CardLine", 0.5, sideY - SIDE_ITEM_GAP / 2)   -- separator under the display name (full width of the card panel)
placeSideItem(makeSideLabel("Username", "@" .. localPlayer.Name, 0, Enum.TextXAlignment.Center), SIDE_INFO_HEIGHT, SIDE_CARD_TEXT_WIDTH)
placeSideItem(makeSideLabel("UserId", "ID: " .. localPlayer.UserId, 0, Enum.TextXAlignment.Center), SIDE_INFO_HEIGHT, SIDE_CARD_TEXT_WIDTH)

local cardBottom = sideY - SIDE_ITEM_GAP + SIDE_CARD_PADDING   -- bottom edge of the card panel
cardPanel.Size = UDim2.new(SIDE_CONTENT_WIDTH, 0, cardBottom - SIDE_TOP_GAP, 0)

-- Search box (filters the tabs of all sections while you type)
local searchBox = Instance.new("Frame")
searchBox.Name = "Search"
searchBox.BackgroundColor3 = COLOR_SEARCH_BOX
searchBox.BorderSizePixel = 0
searchBox.ZIndex = Z_OTHER
searchBox.AnchorPoint = Vector2.new(0.5, 1)
searchBox.Position = UDim2.new(0.5, 0, SIDE_STATS_BOTTOM - SIDE_STATS_HEIGHT - SIDE_SEARCH_GAP, 0)   -- right above the stats panel
searchBox.Size = UDim2.new(SIDE_CONTENT_WIDTH, 0, SIDE_SEARCH_HEIGHT, 0)
searchBox.Parent = sideArea
addCornerAndStroke(searchBox, 0.3)

local searchInput = Instance.new("TextBox")
searchInput.Name = "Input"
searchInput.AnchorPoint = Vector2.new(0, 0.5)
searchInput.Position = UDim2.new(0.07, 0, 0.5, 0)
searchInput.Size = UDim2.new(0.68, 0, 0.6, 0)
searchInput.BackgroundTransparency = 1
searchInput.BorderSizePixel = 0
searchInput.Text = ""
searchInput.PlaceholderText = "Search..."
searchInput.PlaceholderColor3 = COLOR_TEXT
searchInput.TextColor3 = COLOR_TEXT
searchInput.Font = Enum.Font.GothamBold
searchInput.TextScaled = true
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ClearTextOnFocus = true
searchInput.ZIndex = Z_OTHER
searchInput.Parent = searchBox

local searchInputSize = Instance.new("UITextSizeConstraint")
searchInputSize.MinTextSize = 10
searchInputSize.MaxTextSize = 18
searchInputSize.Parent = searchInput

local searchClear = Instance.new("TextButton")
searchClear.Name = "Clear"
searchClear.AnchorPoint = Vector2.new(1, 0.5)
searchClear.Position = UDim2.new(0.97, 0, 0.5, 0)
searchClear.Size = UDim2.new(0.2, 0, 0.55, 0)
searchClear.BackgroundTransparency = 1
searchClear.BorderSizePixel = 0
searchClear.Text = "X"
searchClear.TextColor3 = COLOR_TEXT
searchClear.Font = Enum.Font.GothamBold
searchClear.TextScaled = true
searchClear.AutoButtonColor = false
searchClear.Visible = false
searchClear.ZIndex = Z_OTHER
searchClear.Parent = searchBox

-- Shown in the main panel when nothing matches
local noResults = Instance.new("TextLabel")
noResults.Name = "NoResults"
noResults.AnchorPoint = Vector2.new(0.5, 0.5)
noResults.Position = UDim2.new(0.5, 0, 0.45, 0)
noResults.Size = UDim2.new(0.5, 0, 0.08, 0)
noResults.BackgroundTransparency = 1
noResults.BorderSizePixel = 0
noResults.Text = "No results"
noResults.TextColor3 = COLOR_TEXT
noResults.TextTransparency = 0.3
noResults.Font = Enum.Font.GothamBold
noResults.TextScaled = true
noResults.Visible = false
noResults.ZIndex = Z_OTHER
noResults.Parent = pagesArea

-- Search by tab title or section name (not case sensitive).
-- Sections without matches are dimmed; if the open section has no matches, the first section with matches opens.
local function applySearch(rawText)
	local query = string.lower(string.match(rawText, "^%s*(.-)%s*$"))
	local searching = (query ~= "")

	local firstMatch = nil
	local activeHasMatch = false

	for i, state in ipairs(pageStates) do
		local sectionMatches = searching and (string.find(string.lower(SECTIONS[i].Name), query, 1, true) ~= nil)
		local count = 0
		for _, tab in ipairs(state.tabs) do
			tab.matched = (not searching) or sectionMatches
				or (string.find(string.lower(tab.title), query, 1, true) ~= nil)
			if tab.matched then
				count = count + 1
			end
		end
		arrangeTabs(state)
		state.scroll.CanvasPosition = Vector2.new(0, 0)

		local dimmed = searching and count == 0
		local btn = sectionButtons[i]
		local icon = btn:FindFirstChild("Icon")
		local label = btn:FindFirstChild("Label")
		if icon then
			icon.ImageTransparency = dimmed and 0.6 or 0
		end
		if label then
			label.TextTransparency = dimmed and 0.6 or 0
		end

		if count > 0 then
			firstMatch = firstMatch or i
			if i == activeSection then
				activeHasMatch = true
			end
		end
	end

	if searching and firstMatch and not activeHasMatch then
		setActiveSection(firstMatch)
	end
	noResults.Visible = searching and firstMatch == nil
	searchClear.Visible = (rawText ~= "")
end

searchInput:GetPropertyChangedSignal("Text"):Connect(function()
	applySearch(searchInput.Text)
end)

searchClear.Activated:Connect(function()
	searchInput.Text = ""
end)

-- Stats (bottom): FPS, ping, script uptime, players on the server
local statsPanel = Instance.new("Frame")
statsPanel.Name = "StatsPanel"
statsPanel.AnchorPoint = Vector2.new(0.5, 1)
statsPanel.Position = UDim2.new(0.5, 0, SIDE_STATS_BOTTOM, 0)
statsPanel.Size = UDim2.new(SIDE_CONTENT_WIDTH, 0, SIDE_STATS_HEIGHT, 0)
statsPanel.BackgroundColor3 = COLOR_STATS_PANEL
statsPanel.BorderSizePixel = 0
statsPanel.ZIndex = Z_OTHER
statsPanel.Parent = sideArea
addCornerAndStroke(statsPanel, 0.1)

local statsFrame = Instance.new("Frame")
statsFrame.Name = "Stats"
statsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
statsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
statsFrame.Size = UDim2.new(STATS_TEXT_AREA, 0, STATS_TEXT_AREA, 0)
statsFrame.BackgroundTransparency = 1
statsFrame.BorderSizePixel = 0
statsFrame.ZIndex = Z_OTHER
statsFrame.Parent = statsPanel

-- Separator between Ping and Uptime (full width of the stats panel, exactly in the middle of the 4 rows)
makeLine("StatsLine", statsPanel, true, 1, UDim2.new(0.5, 0, 0.5, 0))

local statsLayout = Instance.new("UIListLayout")
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Parent = statsFrame

local function makeStatRow(order, text)
	local row = makeSideLabel("Stat" .. order, text, 0, Enum.TextXAlignment.Left)
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 1 / 4, 0)
	row.Parent = statsFrame

	local rowSize = Instance.new("UITextSizeConstraint")
	rowSize.MaxTextSize = STATS_TEXT_SIZE
	rowSize.Parent = row
	return row
end

local fpsLabel     = makeStatRow(1, "FPS: --")
local pingLabel    = makeStatRow(2, "Ping: --")
local uptimeLabel  = makeStatRow(3, "Uptime: 00:00")
local playersLabel = makeStatRow(4, "Players: --")

local function formatTime(seconds)
	seconds = math.floor(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%d:%02d:%02d", h, m, s)
	end
	return string.format("%02d:%02d", m, s)
end

local statFrames, statElapsed = 0, 0
local statsConnection = RunService.RenderStepped:Connect(function(dt)
	statFrames = statFrames + 1
	statElapsed = statElapsed + dt
	if statElapsed < STATS_UPDATE_INTERVAL then
		return
	end

	fpsLabel.Text = "FPS: " .. math.floor(statFrames / statElapsed + 0.5)
	statFrames, statElapsed = 0, 0

	local ok, ping = pcall(function()
		return localPlayer:GetNetworkPing()
	end)
	pingLabel.Text = ok and ("Ping: " .. math.floor(ping * 1000 + 0.5) .. " ms") or "Ping: --"

	uptimeLabel.Text = "Uptime: " .. formatTime(os.clock() - SCRIPT_START)
	playersLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
end)

-- Stop the stats loop when the menu is destroyed (for example when the script is run again)
screenGui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		statsConnection:Disconnect()
	end
end)

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
