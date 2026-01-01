local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ALLOWED_IDS = {
	7326395533,
	9460094811,
	4333331142,
}

local function isAllowed(userId)
	for _, id in ipairs(ALLOWED_IDS) do
		if id == userId then
			return true
		end
	end
	return false
end
if not isAllowed(LocalPlayer.UserId) then
	return
end

--==========================
-- SCRIPT
--==========================

local CheckUsingScreen = Instance.new("ScreenGui")
CheckUsingScreen.Name = "CheckUsingScreen"
CheckUsingScreen.ResetOnSpawn = false
CheckUsingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CheckUsingScreen.DisplayOrder = 99999
CheckUsingScreen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.new(0.368627, 0, 0.25098)
Main.BorderSizePixel = 0
Main.BorderColor3 = Color3.new(0, 0, 0)
Main.Visible = false
Main.ZIndex = 99999
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Parent = CheckUsingScreen

local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
UIAspectRatioConstraint.AspectRatio = 0.75
UIAspectRatioConstraint.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.BackgroundColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.BorderSizePixel = 0
Title.BorderColor3 = Color3.new(0, 0, 0)
Title.TextTransparency = 0
Title.Text = "Check HAPPYscript"
Title.TextColor3 = Color3.new(1, 0, 0.917647)
Title.TextSize = 14
Title.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Title.TextScaled = true
Title.TextWrapped = true
Title.Parent = Main

local UIGradient = Instance.new("UIGradient")
UIGradient.Name = "UIGradient"
UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.717647, 0, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))})
UIGradient.Rotation = -45
UIGradient.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "UIStroke"
UIStroke.Color = Color3.new(0.435294, 0, 0.686275)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = Main

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Position = UDim2.new(0, 0, 0.2, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 0.8, 0)
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.BorderColor3 = Color3.new(0, 0, 0)
ScrollingFrame.Transparency = 1
ScrollingFrame.Active = true
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 3, 0)
ScrollingFrame.ScrollBarImageColor3 = Color3.new(0.588235, 0, 1)
ScrollingFrame.ScrollBarThickness = 7
ScrollingFrame.Parent = Main

local Player0 = Instance.new("Frame")
Player0.Name = "Player0"
Player0.Position = UDim2.new(0, 0, 0.01, 0)
Player0.Size = UDim2.new(1, 0, 0.05, 0)
Player0.BackgroundColor3 = Color3.new(0, 0, 0)
Player0.BackgroundTransparency = 0.5
Player0.BorderSizePixel = 0
Player0.BorderColor3 = Color3.new(0, 0, 0)
Player0.Visible = false
Player0.Transparency = 0.5
Player0.Parent = ScrollingFrame

local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(1, 0, 1, 0)
Logo.BackgroundColor3 = Color3.new(1, 1, 1)
Logo.BackgroundTransparency = 1
Logo.BorderSizePixel = 0
Logo.BorderColor3 = Color3.new(0, 0, 0)
Logo.Transparency = 1
Logo.Parent = Player0

local UIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"

UIAspectRatioConstraint2.Parent = Logo

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Name = "UIStroke"
UIStroke2.Color = Color3.new(1, 0, 1)
UIStroke2.Thickness = 2
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke2.Parent = Logo

local Name = Instance.new("TextLabel")
Name.Name = "Name"
Name.Position = UDim2.new(0.2, 0, 0, 0)
Name.Size = UDim2.new(0.8, 0, 1, 0)
Name.BackgroundColor3 = Color3.new(1, 1, 1)
Name.BackgroundTransparency = 1
Name.BorderSizePixel = 0
Name.BorderColor3 = Color3.new(0, 0, 0)
Name.TextTransparency = 0
Name.TextColor3 = Color3.new(1, 1, 1)
Name.TextSize = 14
Name.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Name.TextScaled = true
Name.TextWrapped = true
Name.TextXAlignment = Enum.TextXAlignment.Left
Name.Parent = Player0

local UIDragDetector = Instance.new("UIDragDetector")
UIDragDetector.Name = "UIDragDetector"

UIDragDetector.Parent = Main

local Frame = Instance.new("Frame")
Frame.Name = "Frame"
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Size = UDim2.new(0.51, 0, 0.51, 0)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)
Frame.BorderSizePixel = 0
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.Visible = false
Frame.ZIndex = 100000
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = CheckUsingScreen

local UIAspectRatioConstraint3 = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint3.Name = "UIAspectRatioConstraint"
UIAspectRatioConstraint3.AspectRatio = 0.75
UIAspectRatioConstraint3.Parent = Frame

local UIGradient2 = Instance.new("UIGradient")
UIGradient2.Name = "UIGradient"
UIGradient2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.5, 0, 0), NumberSequenceKeypoint.new(0.501247, 1, 0), NumberSequenceKeypoint.new(1, 1, 0)})
UIGradient2.Rotation = -45
UIGradient2.Offset = Vector2.new(0, -1)
UIGradient2.Parent = Frame

local Button = Instance.new("TextButton")
Button.Name = "Button"
Button.Position = UDim2.new(0.5, 0, 0.3, 0)
Button.Size = UDim2.new(0, 50, 0, 50)
Button.BackgroundColor3 = Color3.new(0.32549, 0, 0.611765)
Button.BackgroundTransparency = 0.30000001192092896
Button.BorderSizePixel = 0
Button.BorderColor3 = Color3.new(0, 0, 0)
Button.ZIndex = 100000
Button.AnchorPoint = Vector2.new(0.5, 0.5)
Button.Transparency = 0.3
Button.Text = "🔍"
Button.TextColor3 = Color3.new(0, 0, 0)
Button.TextSize = 30
Button.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Button.TextWrapped = true
Button.Parent = CheckUsingScreen

local UIAspectRatioConstraint4 = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint4.Name = "UIAspectRatioConstraint"

UIAspectRatioConstraint4.Parent = Button

local UICorner = Instance.new("UICorner")
UICorner.Name = "UICorner"
UICorner.CornerRadius = UDim.new(0.1, 0)
UICorner.Parent = Button

--=============================================================================================================--
-- SYSTEM
--=============================================================================================================--

--==========================
-- Config & Services
--==========================
local SCAN_INTERVAL = 2 -- seconds between checks when Main is visible

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screen = playerGui:WaitForChild("CheckUsingScreen")

-- SUPABASE / REST endpoint - sử dụng same project key như script Data của bạn
local SUPABASE_BASE = "https://koqaxxefwuosiplczazy.supabase.co"
local SUPABASE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvcWF4eGVmd3V3b3NpbHBjemF6eSIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzY2MjcwNTQzLCJleHAiOjIwODE4NDY1NDN9.c_hoE6Kr3N9OEgS2WOUlDj-2-EL3H_CRzKO3RLbBlwU"
local REST_MEMBERS = SUPABASE_BASE .. "/rest/v1/members"

local function defaultHeaders()
	return {
		["apikey"] = SUPABASE_KEY,
		["Authorization"] = "Bearer " .. SUPABASE_KEY,
		["Content-Type"] = "application/json",
		["Accept"] = "application/json"
	}
end

--==========================
-- HTTP Request auto-detect
--==========================
local function HttpRequest(data)
	if syn and syn.request then
		return syn.request(data)
	elseif http and http.request then
		return http.request(data)
	elseif http_request then
		return http_request(data)
	elseif request then
		return request(data)
	elseif fluxus and fluxus.request then
		return fluxus.request(data)
	else
		error("[CheckMembers] Executor không hỗ trợ http request!")
	end
end

local function safeDecode(body)
	if not body or body == "null" or body == "" then return nil end
	local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
	if ok and type(decoded) == "table" then return decoded end
	return nil
end

--==========================
-- GUI selectors (giữ nguyên cấu trúc của bạn)
--==========================
local main = screen:WaitForChild("Main")
local scrolling = main:WaitForChild("ScrollingFrame")
local template = scrolling:WaitForChild("Player0")
local button = screen:WaitForChild("Button")

local overlayFrame = screen:WaitForChild("Frame")
local overlayGradient = overlayFrame:FindFirstChildOfClass("UIGradient")

-- initial states (giữ như cũ)
main.Visible = false
overlayFrame.Visible = false
if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end
overlayFrame.BackgroundTransparency = 1

--==========================
-- Row utilities
--==========================
local START_Y = 0.01
local STEP_Y = 0.055

local function clearOldRows()
	for _, child in ipairs(scrolling:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^Player%d+") then
			if child ~= template then child:Destroy() end
		end
	end
end

local function createRow(index, playerObj, avatarUrl)
	local row = template:Clone()
	row.Name = "Player" .. tostring(index)
	row.Visible = true
	local y = START_Y + (index - 1) * STEP_Y
	row.Position = UDim2.new(0, 0, y, 0)

	local logo = row:FindFirstChild("Logo", true) or row:FindFirstChildOfClass("ImageLabel")
	local nameLabel = row:FindFirstChild("Name", true) or row:FindFirstChildOfClass("TextLabel")

	if nameLabel and playerObj then nameLabel.Text = playerObj.Name end
	if logo and avatarUrl then
		pcall(function() logo.Image = avatarUrl end)
	end

	row.Parent = scrolling
	return row
end

--==========================
-- Supabase: batch GET members by user_id
--==========================
local function buildIdQuery(ids)
	-- ids: array of numeric user ids
	if #ids == 0 then return nil end
	-- ensure values are numbers/strings without spaces
	local parts = {}
	for _, id in ipairs(ids) do
		table.insert(parts, tostring(id))
	end
	-- Supabase/PostgREST filter: user_id=in.(id1,id2,...)
	return "user_id=in.(" .. table.concat(parts, ",") .. ")"
end

local function GetMembersDataByUserIds(ids)
	local filter = buildIdQuery(ids)
	if not filter then return {} end

	-- select only needed fields to reduce payload
	local url = REST_MEMBERS .. "?" .. filter .. "&select=user_id,username,online,last_seen"
	local ok, res = pcall(function()
		return HttpRequest({
			Url = url,
			Method = "GET",
			Headers = defaultHeaders()
		})
	end)
	if not ok or not res then
		warn("[CheckMembers] HTTP request failed or executor returned nil")
		return {}
	end
	if type(res) == "table" and (res.StatusCode == 204 or res.StatusCode == 200) and res.Body then
		local decoded = safeDecode(res.Body)
		if decoded and type(decoded) == "table" then
			-- convert to map by user_id for O(1) lookup
			local map = {}
			for _, row in ipairs(decoded) do
				-- ensure user_id present
				local uid = tonumber(row.user_id) or tonumber(row.user_id and tostring(row.user_id))
				if uid then
					map[uid] = row
				end
			end
			return map
		end
	end

	-- if fallback: try if res is a string containing JSON
	if type(res) == "string" then
		local decoded = safeDecode(res)
		if decoded and type(decoded) == "table" then
			local map = {}
			for _, row in ipairs(decoded) do
				local uid = tonumber(row.user_id) or tonumber(row.user_id and tostring(row.user_id))
				if uid then map[uid] = row end
			end
			return map
		end
	end

	-- failure -> return empty map
	return {}
end

--==========================
-- Avatar helper (optional, non-blocking)
--==========================
local function GetAvatarUrl(userId, sizeEnum)
	sizeEnum = sizeEnum or Enum.ThumbnailSize.Size48x48
	local ok, thumbUrl = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, sizeEnum)
	end)
	if ok and thumbUrl then return thumbUrl end
	return nil
end

--==========================
-- RefreshMemberList (batch, non-blocking)
--==========================
local function RefreshMemberList()
	-- Guard: only run if menu is visible
	if not main or not main.Visible then return end

	clearOldRows()

	local players = Players:GetPlayers()
	if #players == 0 then return end

	-- build id list for batch request
	local ids = {}
	for _, plr in ipairs(players) do
		if plr and plr.UserId and plr.UserId > 0 then
			table.insert(ids, plr.UserId)
		end
	end
	if #ids == 0 then return end

	-- single batch GET
	local dataMap = GetMembersDataByUserIds(ids)
	-- dataMap keyed by numeric user_id

	-- Build confirmed list (preserve ordering by player name for stable UI)
	local confirmed = {}
	for _, plr in ipairs(players) do
		local row = dataMap[plr.UserId]
		if row and (row.online == true or tostring(row.online) == "true" or tonumber(row.online) == 1) then
			table.insert(confirmed, { player = plr })
		end
	end

	table.sort(confirmed, function(a, b) return a.player.Name:lower() < b.player.Name:lower() end)

	-- populate rows; we can fetch avatar async but keep simple (synchronous Avatar call is okay small scale)
	for idx, info in ipairs(confirmed) do
		local avatar = nil
		-- pcall avatar (not critical)
		pcall(function()
			avatar = GetAvatarUrl(info.player.UserId, Enum.ThumbnailSize.Size48x48)
		end)
		createRow(idx, info.player, avatar)
	end
end

--==========================
-- Polling control: start/stop when Main visible
--==========================
local pollRunning = false
local pollThread = nil

local function startPolling()
	if pollRunning then return end
	pollRunning = true
	pollThread = task.spawn(function()
		-- first immediate refresh
		pcall(RefreshMemberList)
		while pollRunning and main and main.Visible do
			local ok = pcall(function() RefreshMemberList() end)
			-- wait SCAN_INTERVAL but yield safely
			for i = 1, math.max(1, math.floor(SCAN_INTERVAL / 0.1)) do
				if not pollRunning or not main or not main.Visible then break end
				task.wait(0.1)
			end
		end
		pollRunning = false
		pollThread = nil
	end)
end

local function stopPolling()
	pollRunning = false
	-- pollThread will finish on its own
end

-- Hook player join/leave to refresh immediately if menu open (keeps UI responsive)
Players.PlayerAdded:Connect(function(plr)
	if main and main.Visible then
		task.wait(0.3)
		pcall(RefreshMemberList)
	end
end)
Players.PlayerRemoving:Connect(function(plr)
	if main and main.Visible then
		task.wait(0.1)
		pcall(RefreshMemberList)
	end
end)

--==========================
-- Overlay open/close (kept but start/stop polling appropriately)
--==========================
local PHASE_DURATION = 0.20
local PHASE_TWEEN = TweenInfo.new(PHASE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local animating = false
local menuOpen = false

local function tweenGradientTo(offset, callback)
	if not overlayGradient then
		if callback then callback() end
		return
	end
	local tw = TweenService:Create(overlayGradient, PHASE_TWEEN, { Offset = offset })
	tw:Play()
	if callback then tw.Completed:Once(callback) end
end

local function tweenOverlayFade(fromTransparency, toTransparency, callback)
	overlayFrame.BackgroundTransparency = fromTransparency
	local tw = TweenService:Create(overlayFrame, PHASE_TWEEN, { BackgroundTransparency = toTransparency })
	tw:Play()
	if callback then tw.Completed:Once(callback) end
end

local function openMainSequence()
	if animating or menuOpen then return end
	animating = true

	-- align overlay to main
	overlayFrame.Position = main.Position
	overlayFrame.Size = main.Size

	-- spawn refresh early
	task.spawn(RefreshMemberList)

	overlayFrame.Visible = true
	overlayFrame.BackgroundTransparency = 0
	if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end

	tweenGradientTo(Vector2.new(0, -1), function()
		main.Visible = true
		tweenOverlayFade(0, 1, function()
			overlayFrame.Visible = false
			if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end
			animating = false
			menuOpen = true
			-- Start polling when fully open
			startPolling()
		end)
	end)
end

local function closeMainSequence()
	if animating or (not menuOpen) then return end
	animating = true

	overlayFrame.Position = main.Position
	overlayFrame.Size = main.Size

	overlayFrame.Visible = true
	overlayFrame.BackgroundTransparency = 1
	tweenOverlayFade(1, 0, function()
		main.Visible = false
		if overlayGradient then overlayGradient.Offset = Vector2.new(0, -1) end
		tweenGradientTo(Vector2.new(0, 1), function()
			overlayFrame.Visible = false
			if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end
			animating = false
			menuOpen = false
			-- Stop polling when closed
			stopPolling()
		end)
	end)
end

local function toggleMain()
	if animating then return end
	if not menuOpen then openMainSequence() else closeMainSequence() end
end

--==========================
-- Drag + Click for floating button (kept as before)
--==========================
do
	local btn = button
	local dragSpeed = 0.12
	local dragging = false
	local dragStart
	local startPos
	local moved = false

	local function update(input)
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		TweenService:Create(btn, TweenInfo.new(dragSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = newPos }):Play()
	end

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = btn.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			moved = true
			update(input)
		end
	end)

	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not moved then toggleMain() end
		end
	end)
end

-- Ensure UI initially hidden (kept)
main.Visible = false
overlayFrame.Visible = false
if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end
overlayFrame.BackgroundTransparency = 1
