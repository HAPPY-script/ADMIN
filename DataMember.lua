local SUPABASE_BASE = "https://koqaxxefwuosiplczazy.supabase.co"
local SUPABASE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvcWF4eGVmd3Vvc2lwbGN6YXp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYyNzA1NDMsImV4cCI6MjA4MTg0NjU0M30.c_hoE6Kr3N9OEgS2WOUlDj-2-EL3H_CRzKO3RLbBlwU"
local REST_MEMBERS = SUPABASE_BASE .. "/rest/v1/members"

--==================================================
--  FIREBASE MAINTENANCE SWITCH (kept)
--==================================================
if getgenv().RestFireBase == true then
	warn("[DataMember] Database đang bảo trì, hệ thống tạm dừng")
	return
end

--==================================================
--  HTTP REQUEST AUTO-DETECT (kept)
--==================================================
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

--==================================================
--  SERVICES / CONTEXT
--==================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local USERNAME = LocalPlayer.Name
local USERID = LocalPlayer.UserId

--==================================================
--  UTILS
--==================================================
local function MakeSafeKey(str)
	return str:gsub("[.%$#%[%]/]", "_")
end

local function GetRealGameName()
	local url = "https://games.roblox.com/v1/games?universeIds=" .. game.GameId
	local res = HttpRequest({ Url = url, Method = "GET" })
	if not res or res.StatusCode ~= 200 then
		return "Unknown Game"
	end
	local ok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
	if ok and data and data.data and data.data[1] and data.data[1].name then
		return data.data[1].name
	end
	return "Unknown Game"
end

--==================================================
--  GAME INFO
--==================================================
local REAL_GAME_NAME = GetRealGameName()
local CURRENT_GAME = REAL_GAME_NAME .. " (" .. game.PlaceId .. ")"
local SAFE_GAME_KEY = MakeSafeKey(CURRENT_GAME)

--==================================================
--  SUPABASE HELPERS (GET + UPSERT)
--==================================================
local function defaultHeaders()
	return {
		["apikey"] = SUPABASE_KEY,
		["Authorization"] = "Bearer " .. SUPABASE_KEY,
		["Content-Type"] = "application/json",
		["Accept"] = "application/json"
	}
end

-- Lấy record member theo user_id (trả về nil nếu không có)
local function GetUserData()
	local url = REST_MEMBERS .. "?user_id=eq." .. tostring(USERID) .. "&select=*"
	local ok, res = pcall(HttpRequest, { Url = url, Method = "GET", Headers = defaultHeaders() })
	if not ok or not res then return nil end
	if res.StatusCode ~= 200 then
		-- không tồn tại hoặc lỗi
		return nil
	end
	local success, body = pcall(function() return HttpService:JSONDecode(res.Body) end)
	if not success or type(body) ~= "table" or #body == 0 then
		return nil
	end
	return body[1] -- PostgREST trả về mảng
end

-- Upsert member (POST với Prefer: resolution=merge-duplicates)
-- Yêu cầu: `members` có unique/primary key trên `user_id`
local function SaveUserData(data)
	local payload = {
		user_id   = data.ID or USERID,
		username  = data.Username or USERNAME,
		games     = data.Games or {},
		online    = data.Online == true,
		last_seen = data.LastSeen or os.time()
	}

	local headers = defaultHeaders()
	headers["Prefer"] = "resolution=merge-duplicates"

	local ok, res = pcall(HttpRequest, {
		Url = REST_MEMBERS .. "?on_conflict=user_id",
		Method = "POST",
		Headers = headers,
		Body = HttpService:JSONEncode(payload)
	})

	if not ok or not res then
		warn("[DataMember] SaveUserData failed: no response")
		return false
	end

	if res.StatusCode >= 200 and res.StatusCode < 300 then
		return true
	end

	warn("[DataMember] SaveUserData status:", res.StatusCode, res.Body)
	return false
end

--==================================================
--  REPORT + ONLINE STATUS
--==================================================
local function UpdateOnlineStatus(isOnline)
	local data = GetUserData() or {
		ID = USERID,
		Username = USERNAME,
		Games = {}
	}

	-- Ensure types/fields match what SaveUserData expects
	data.Online = isOnline == true
	data.LastSeen = os.time()
	data.ID = USERID
	data.Username = USERNAME

	SaveUserData(data)
end

local function ReportPlayer()
	local data = GetUserData() or {
		ID = USERID,
		Username = USERNAME,
		Games = {}
	}

	data.Games = data.Games or {}
	-- mark current game
	data.Games[SAFE_GAME_KEY] = true
	data.Online = true
	data.LastSeen = os.time()
	data.ID = USERID
	data.Username = USERNAME

	print("[DataMember] Lưu:", USERNAME, USERID, CURRENT_GAME)
	SaveUserData(data)
end

--==================================================
--  AUTO SEND + HEARTBEAT
--==================================================
task.wait(1)
ReportPlayer()

-- Heartbeat: giữ online (thay 30s -> 60s để giảm writes)
task.spawn(function()
	while task.wait(60) do
		UpdateOnlineStatus(true)
	end
end)

-- Thoát game → Offline
Players.PlayerRemoving:Connect(function(plr)
	if plr == LocalPlayer then
		UpdateOnlineStatus(false)
	end
end)

print("✅Done DataMember")
