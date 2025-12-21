-- DataMember -> Supabase version
-- Minimal & clear

-- HTTP request auto-detect (giữ nguyên logic executor)
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local USERNAME = LocalPlayer.Name
local USERID = tostring(LocalPlayer.UserId) -- dùng string cho URL

-- Supabase config (bạn đã cung cấp)
local SUPABASE_URL = "https://koqaxxefwuosiplczazy.supabase.co"
local SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvcWF4eGVmd3Vvc2lwbGN6YXp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYyNzA1NDMsImV4cCI6MjA4MTg0NjU0M30.c_hoE6Kr3N9OEgS2WOUlDj-2-EL3H_CRzKO3RLbBlwU"
local TABLE_NAME = "members"
local BASE_API = SUPABASE_URL .. "/rest/v1/" .. TABLE_NAME

local function MakeSafeKey(str)
	return str:gsub("[.%$#%[%]/]", "_")
end

local function GetRealGameName()
	local url = "https://games.roblox.com/v1/games?universeIds=" .. game.GameId
	local ok, res = pcall(function()
		return HttpRequest({ Url = url, Method = "GET" })
	end)
	if not ok or not res or res.StatusCode ~= 200 then return "Unknown Game" end
	local body = HttpService:JSONDecode(res.Body)
	return (body and body.data and body.data[1] and body.data[1].name) and body.data[1].name or "Unknown Game"
end

local REAL_GAME_NAME = GetRealGameName()
local CURRENT_GAME = REAL_GAME_NAME .. " (" .. game.PlaceId .. ")"
local SAFE_GAME_KEY = MakeSafeKey(CURRENT_GAME)

-- Common headers for Supabase
local function SupabaseHeaders()
	return {
		["apikey"] = SUPABASE_KEY,
		["Authorization"] = "Bearer " .. SUPABASE_KEY,
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["Accept-Profile"] = "public",
		["Content-Profile"] = "public",
	}
end

-- Get user row by user_id (returns Lua table or nil)
local function GetUserData()
	local url = BASE_API .. "?user_id=eq." .. USERID
	local res = HttpRequest({ Url = url, Method = "GET", Headers = SupabaseHeaders() })
	if not res or (res.StatusCode ~= 200 and res.StatusCode ~= 204) then
		warn("[DataMember] GetUserData failed", res and res.StatusCode)
		return nil
	end
	if not res.Body or res.Body == "null" or res.Body == "[]" then
		return nil
	end
	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, res.Body)
	if not ok then
		warn("[DataMember] JSON decode error:", decoded)
		return nil
	end
	if type(decoded) == "table" and #decoded > 0 then
		return decoded[1] -- supabase trả về mảng
	end
	return nil
end

-- Save user data: upsert logic (GET -> PATCH or POST)
local function SaveUserData(data)
	-- ensure mandatory fields
	data.user_id = tonumber(USERID) or USERID
	data.username = USERNAME

	-- Supabase expects proper JSON for jsonb fields; HttpService:JSONEncode will do
	local existing = GetUserData()

	if existing then
		-- PATCH existing row where user_id = eq.USERID
		local url = BASE_API .. "?user_id=eq." .. USERID
		local body = HttpService:JSONEncode(data)
		local headers = SupabaseHeaders()
		headers["Prefer"] = "return=representation"
		local res = HttpRequest({ Url = url, Method = "PATCH", Headers = headers, Body = body })
		if not res or not (res.StatusCode == 200 or res.StatusCode == 204) then
			warn("[DataMember] Patch failed", res and res.StatusCode)
		end
	else
		-- POST create new
		local url = BASE_API
		local body = HttpService:JSONEncode(data)
		local headers = SupabaseHeaders()
		headers["Prefer"] = "return=representation"
		local res = HttpRequest({ Url = url, Method = "POST", Headers = headers, Body = body })
		if not res or not (res.StatusCode == 201 or res.StatusCode == 200) then
			warn("[DataMember] Post create failed", res and res.StatusCode)
		end
	end
end

-- High-level operations
local function UpdateOnlineStatus(isOnline)
	local data = GetUserData() or {
		user_id = tonumber(USERID) or USERID,
		username = USERNAME,
		games = {},
	}
	data.online = isOnline
	data.last_seen = os.time()
	-- keep existing games table if present
	SaveUserData(data)
end

local function ReportPlayer()
	local data = GetUserData() or {
		user_id = tonumber(USERID) or USERID,
		username = USERNAME,
		games = {},
	}
	data.games = data.games or {}
	data.games[SAFE_GAME_KEY] = true
	data.online = true
	data.last_seen = os.time()
	print("[DataMember] Lưu:", USERNAME, USERID, CURRENT_GAME)
	SaveUserData(data)
end

-- Run
task.wait(1)
ReportPlayer()

task.spawn(function()
	while task.wait(30) do
		UpdateOnlineStatus(true)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr == LocalPlayer then
		UpdateOnlineStatus(false)
	end
end)

print("Done DataMember✅")
