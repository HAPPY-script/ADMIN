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
-- Services & Helpers
--==========================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screen = playerGui:WaitForChild("CheckUsingScreen")

-- Firebase base (same base as your other scripts)
local MEMBER_BASE = "https://happy-script-bada6-default-rtdb.asia-southeast1.firebasedatabase.app/Member/"

-- Auto-detect http request function (compatible with many executors)
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

-- Make safe key for game (same logic as your Member script)
local function MakeSafeKey(str)
	return str:gsub("[.%$#%[%]/]", "_")
end

local function GetRealGameName()
	local url = "https://games.roblox.com/v1/games?universeIds=" .. game.GameId
	local ok, res = pcall(function() return HttpRequest({ Url = url, Method = "GET" }) end)
	if not ok or not res or res.StatusCode ~= 200 then
		return "Unknown Game"
	end
	local body = res.Body or res.body or res.Response
	local data = safeDecode(body)
	if data and data.data and data.data[1] and data.data[1].name then
		return data.data[1].name
	end
	return "Unknown Game"
end

local REAL_GAME_NAME = GetRealGameName()
local CURRENT_GAME = REAL_GAME_NAME .. " (" .. game.PlaceId .. ")"
local SAFE_GAME_KEY = MakeSafeKey(CURRENT_GAME)

--==========================
-- GUI selectors (structure you described)
--==========================
local main = screen:WaitForChild("Main")
local scrolling = main:WaitForChild("ScrollingFrame")
local template = scrolling:WaitForChild("Player0")
local button = screen:WaitForChild("Button")

local overlayFrame = screen:WaitForChild("Frame") -- Frame that has UIGradient
local overlayGradient = overlayFrame:FindFirstChildOfClass("UIGradient")

-- ensure initial states per your spec
main.Visible = false
overlayFrame.Visible = false
if overlayGradient then
	overlayGradient.Offset = Vector2.new(0, 1)
end
overlayFrame.BackgroundTransparency = 1 -- hidden initially

--==========================
-- Helper: get member data from Firebase by username
--==========================
local function GetMemberDataByName(username)
	-- Simple URL encoding for spaces (if needed). Adjust if your DB keys use different escaping.
	local safeName = username:gsub(" ", "%%20")
	local url = MEMBER_BASE .. safeName .. ".json"
	local ok, res = pcall(function()
		return HttpRequest({ Url = url, Method = "GET" })
	end)
	if not ok or not res then
		return nil
	end
	local body = res.Body or res.body or res.Response or res
	if not body or body == "null" then return nil end
	local data = safeDecode(body)
	return data
end

-- Helper: get headshot thumbnail URL
local function GetAvatarUrl(userId, sizeEnum)
	sizeEnum = sizeEnum or Enum.ThumbnailSize.Size48x48
	local ok, thumbUrl = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, sizeEnum)
	end)
	if ok and thumbUrl then
		return thumbUrl
	end
	return nil
end

--==========================
-- Build UI rows
--==========================
local START_Y = 0.01
local STEP_Y = 0.055

local function clearOldRows()
	for _, child in ipairs(scrolling:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^Player%d+") then
			-- keep template (Player0) untouched
			if child ~= template then
				child:Destroy()
			end
		end
	end
end

local function createRow(index, playerObj, avatarUrl)
	local row = template:Clone()
	row.Name = "Player" .. tostring(index)
	row.Visible = true
	-- position: X = 0,0 ; Y = START_Y + (index-1)*STEP_Y
	local y = START_Y + (index - 1) * STEP_Y
	row.Position = UDim2.new(0, 0, y, 0)

	-- find Logo and Name inside row
	local logo = row:FindFirstChild("Logo", true) or row:FindFirstChildOfClass("ImageLabel")
	local nameLabel = row:FindFirstChild("Name", true) or row:FindFirstChildOfClass("TextLabel")

	if nameLabel and playerObj then
		nameLabel.Text = playerObj.Name
	end

	if logo and avatarUrl then
		-- set image safely
		pcall(function() logo.Image = avatarUrl end)
	end

	row.Parent = scrolling
	return row
end

--==========================
-- Main check flow: get players, check firebase, build UI
--==========================
local CHECK_LASTSEEN_THRESHOLD = 60 -- seconds

local function isMemberOnlineInThisServer(memberData)
	if not memberData then return false end
	if not memberData.Online then return false end
	-- last seen freshness
	local last = tonumber(memberData.LastSeen) or 0
	if os.time() - last > CHECK_LASTSEEN_THRESHOLD then
		return false
	end
	-- check Games contains SAFE_GAME_KEY
	if memberData.Games and memberData.Games[SAFE_GAME_KEY] then
		return true
	end
	return false
end

local function RefreshMemberList()
	-- clear old rows first (except template)
	clearOldRows()

	local players = Players:GetPlayers()
	local confirmed = {} -- list of {player = plr, avatar = url}

	-- Parallelize requests per player to avoid blocking
	local coros = {}
	for _, plr in ipairs(players) do
		table.insert(coros, coroutine.create(function()
			local data = GetMemberDataByName(plr.Name)
			if isMemberOnlineInThisServer(data) then
				local avatar = GetAvatarUrl(plr.UserId, Enum.ThumbnailSize.Size48x48)
				table.insert(confirmed, { player = plr, avatar = avatar })
			end
		end))
	end

	-- run coroutines and wait a tiny bit between starts to avoid spamming
	for _, co in ipairs(coros) do
		coroutine.resume(co)
		task.wait(0.02)
	end

	-- small wait to allow GETs to complete (simple approach)
	-- if your executor is fast you can make this smaller
	task.wait(0.25)

	-- create rows
	table.sort(confirmed, function(a,b) return a.player.Name < b.player.Name end) -- optional order
	for idx, info in ipairs(confirmed) do
		createRow(idx, info.player, info.avatar)
	end
end

-- Initial refresh
RefreshMemberList()

-- Optional: refresh periodically or when players join/leave
Players.PlayerAdded:Connect(function()
	task.wait(1)
	RefreshMemberList()
end)
Players.PlayerRemoving:Connect(function()
	task.wait(0.5)
	RefreshMemberList()
end)

--==========================
-- Overlay open/close animations (Frame with UIGradient)
--  - Opening and closing are exact inverses
--  - Total sequence is 2 * PHASE_DURATION, both phases use same duration
--  - overlayFrame.Position is set to main.Position BEFORE any animation starts
--==========================
local PHASE_DURATION = 0.20 -- single-phase duration (seconds). total open/close = 0.4s
local PHASE_TWEEN = TweenInfo.new(PHASE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local animating = false -- prevent re-entry while any animation running
local menuOpen = false -- actual state; only updated when sequence completes

local function tweenGradientTo(offset, callback)
	if not overlayGradient then
		if callback then callback() end
		return
	end
	local tw = TweenService:Create(overlayGradient, PHASE_TWEEN, { Offset = offset })
	tw:Play()
	if callback then
		tw.Completed:Once(callback)
	end
end

local function tweenOverlayFade(fromTransparency, toTransparency, callback)
	overlayFrame.BackgroundTransparency = fromTransparency
	local tw = TweenService:Create(overlayFrame, PHASE_TWEEN, { BackgroundTransparency = toTransparency })
	tw:Play()
	if callback then
		tw.Completed:Once(callback)
	end
end

-- OPEN sequence
local function openMainSequence()
	-- reject if animation in progress or already open
	if animating or menuOpen then return end
	animating = true

	-- align overlay to main BEFORE animation starts
	overlayFrame.Position = main.Position

	-- start refreshing content in background so rows load while animating
	task.spawn(RefreshMemberList)

	-- Phase 1: show overlay fully visible and sweep gradient (1 -> -1)
	overlayFrame.Visible = true
	overlayFrame.BackgroundTransparency = 0
	if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end

	tweenGradientTo(Vector2.new(0, -1), function()
		-- Phase 2: reveal main then fade overlay out (0 -> 1)
		main.Visible = true
		tweenOverlayFade(0, 1, function()
			-- done
			overlayFrame.Visible = false
			if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end
			animating = false
			menuOpen = true
		end)
	end)
end

-- CLOSE sequence (exact inverse)
local function closeMainSequence()
	-- reject if animation in progress or already closed
	if animating or (not menuOpen) then return end
	animating = true

	-- align overlay to main BEFORE animation starts
	overlayFrame.Position = main.Position

	-- Phase 1: make overlay visible and fade it in (1 -> 0)
	overlayFrame.Visible = true
	overlayFrame.BackgroundTransparency = 1
	tweenOverlayFade(1, 0, function()
		-- Phase 2: hide main and sweep gradient back (-1 -> 1)
		main.Visible = false
		if overlayGradient then overlayGradient.Offset = Vector2.new(0, -1) end
		tweenGradientTo(Vector2.new(0, 1), function()
			overlayFrame.Visible = false
			if overlayGradient then overlayGradient.Offset = Vector2.new(0, 1) end
			animating = false
			menuOpen = false
		end)
	end)
end

-- toggle state (safe: will ignore spurious clicks during animating)
local function toggleMain()
	-- if animating, ignore click
	if animating then return end
	if not menuOpen then
		openMainSequence()
	else
		closeMainSequence()
	end
end

--==========================
-- Drag + Click for Button (based on your template)
--  - Debounced by animating state in toggleMain
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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
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
			if not moved then
				-- click: toggle main (toggleMain already protects against spam via animating)
				toggleMain()
			end
		end
	end)
end
