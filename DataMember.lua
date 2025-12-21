--==================================================--
--  FIREBASE MAINTENANCE SWITCH
--==================================================--
if getgenv().RestFireBase == true then
	warn("[DataMember] Database đang bảo trì, hệ thống tạm dừng")
	return
end

--==================================================--
--  HTTP REQUEST AUTO-DETECT
--==================================================--
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
		error("[DataMember] Executor không hỗ trợ http request!")
	end
end

--==================================================--
--  SERVICES
--==================================================--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local USERNAME = LocalPlayer.Name
local USERID = LocalPlayer.UserId

--==================================================--
--  UTILS
--==================================================--
local function MakeSafeKey(str)
	return str:gsub("[.%$#%[%]/]", "_")
end

local function GetRealGameName()
	local url = "https://games.roblox.com/v1/games?universeIds=" .. game.GameId
	local res = HttpRequest({ Url = url, Method = "GET" })

	if not res or res.StatusCode ~= 200 then
		return "Unknown Game"
	end

	local data = HttpService:JSONDecode(res.Body)
	if data and data.data and data.data[1] and data.data[1].name then
		return data.data[1].name
	end

	return "Unknown Game"
end

--==================================================--
--  GAME INFO
--==================================================--
local REAL_GAME_NAME = GetRealGameName()
local CURRENT_GAME = REAL_GAME_NAME .. " (" .. game.PlaceId .. ")"
local SAFE_GAME_KEY = MakeSafeKey(CURRENT_GAME)

local PROJECT_URL =
	"https://happy-script-bada6-default-rtdb.asia-southeast1.firebasedatabase.app/Member/"
	.. USERNAME .. ".json"

--==================================================--
--  DATA
--==================================================--
local function GetUserData()
	local res = HttpRequest({ Url = PROJECT_URL, Method = "GET" })
	if not res or res.StatusCode ~= 200 or res.Body == "null" then
		return nil
	end
	return HttpService:JSONDecode(res.Body)
end

local function SaveUserData(data)
	HttpRequest({
		Url = PROJECT_URL,
		Method = "PUT",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode(data)
	})
end

--==================================================--
--  REPORT + ONLINE STATUS
--==================================================--
local function UpdateOnlineStatus(isOnline)
	local data = GetUserData() or {
		ID = USERID,
		Games = {}
	}

	data.Online = isOnline
	data.LastSeen = os.time()

	SaveUserData(data)
end

local function ReportPlayer()
	local data = GetUserData() or {
		ID = USERID,
		Games = {}
	}

	data.Games = data.Games or {}
	data.Games[SAFE_GAME_KEY] = true
	data.Online = true
	data.LastSeen = os.time()

	print("[DataMember] Lưu:", USERNAME, USERID, CURRENT_GAME)
	SaveUserData(data)
end

--==================================================--
--  AUTO SEND
--==================================================--
task.wait(1)

ReportPlayer()

-- Heartbeat giữ trạng thái Online
task.spawn(function()
	while task.wait(30) do
		UpdateOnlineStatus(true)
	end
end)

-- Thoát game → Offline
Players.PlayerRemoving:Connect(function(plr)
	if plr == LocalPlayer then
		UpdateOnlineStatus(false)
	end
end)

print("Done DataMember✅")
