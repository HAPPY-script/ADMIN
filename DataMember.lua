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

-- Replace your SaveUserData with this version
local function SaveUserData(data)
    -- prepare fields
    local uid = data.ID or USERID
    local uname = data.Username or USERNAME
    local gamesTable = data.Games or {}
    local onlineVal = (data.Online == true)
    local lastSeenVal = data.LastSeen or os.time()

    -- encode games explicitly
    local okg, gamesJson = pcall(function() return HttpService:JSONEncode(gamesTable) end)
    if not okg then
        gamesJson = "{}"
    end

    -- build a payload object WITHOUT games and json-encode it
    local basicObj = {
        user_id = uid,
        username = uname,
        online = onlineVal,
        last_seen = lastSeenVal
    }
    local basicJson = HttpService:JSONEncode(basicObj)

    -- insert games JSON into the encoded string so games becomes a real JSON object
    -- basicJson is like: {"user_id":123,"username":"abc","online":true,"last_seen":1234567}
    -- we need: {"user_id":123,"username":"abc","online":true,"last_seen":1234567,"games":{...}}
    local body = basicJson:sub(1, #basicJson - 1) .. ',"games":' .. gamesJson .. '}'

    -- debug: (uncomment if you want to see actual payload in output)
    -- print("[DataMember] SaveUserData body:", body)

    local headers = defaultHeaders()
    headers["Prefer"] = "resolution=merge-duplicates"

    local ok, res = pcall(HttpRequest, {
        Url = REST_MEMBERS .. "?on_conflict=user_id",
        Method = "POST",
        Headers = headers,
        Body = body
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
	local body = HttpService:JSONEncode({
		online = isOnline == true,
		last_seen = os.time()
	})

	HttpRequest({
		Url = REST_MEMBERS .. "?user_id=eq." .. USERID,
		Method = "PATCH",
		Headers = defaultHeaders(),
		Body = body
	})
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

local function SaveGameIfNotExists()
	local data = GetUserData()

	-- Nếu chưa có user → tạo mới
	if not data then
		data = {
			ID = USERID,
			Username = USERNAME,
			Games = {
				[SAFE_GAME_KEY] = {
					name = REAL_GAME_NAME,
					placeId = game.PlaceId,
					firstSeen = os.time()
				}
			},
			Online = true,
			LastSeen = os.time()
		}
		SaveUserData(data)
		return
	end

	data.Games = data.Games or {}

	-- Nếu game đã tồn tại → KHÔNG GHI
	if data.Games[SAFE_GAME_KEY] then
		return
	end

	-- Thêm game mới
	data.Games[SAFE_GAME_KEY] = {
		name = REAL_GAME_NAME,
		placeId = game.PlaceId,
		firstSeen = os.time()
	}

	data.Online = true
	data.LastSeen = os.time()
	data.ID = USERID
	data.Username = USERNAME

	print("[DataMember] Thêm game mới:", CURRENT_GAME)
	SaveUserData(data)
end

--==================================================
--  AUTO SEND + HEARTBEAT
--==================================================
task.wait(1)
SaveGameIfNotExists()
UpdateOnlineStatus(true)

task.spawn(function()
	while task.wait(60) do
		UpdateOnlineStatus(true)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr == LocalPlayer then
		UpdateOnlineStatus(false)
	end
end)

print("✅Done DataMember")
