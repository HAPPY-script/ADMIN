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

local function safeJsonEncode(t)
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    if ok and type(s) == "string" then return s end
    return "{}"
end

-- SaveUserData: INSERT if no row exists, otherwise PATCH the merged games (and update meta)
local function SaveUserData(data)
    local uid = data.ID or USERID
    local uname = data.Username or USERNAME
    local gamesTable = data.Games or {}
    local onlineVal = (data.Online == true)
    local lastSeenVal = data.LastSeen or os.time()

    -- Check if record exists
    local existing = GetUserData() -- returns full row or nil
    if existing then
        -- Merge existing.games and gamesTable without removing old keys
        local merged = {}
        -- existing.games may be nil or JSON decoded table
        if existing.games and type(existing.games) == "table" then
            for k,v in pairs(existing.games) do merged[k] = v end
        end
        if gamesTable and type(gamesTable) == "table" then
            for k,v in pairs(gamesTable) do
                -- only add if not exists (avoid replacing existing game entry)
                if merged[k] == nil then
                    merged[k] = v
                end
            end
        end

        -- Build body to PATCH only the fields we want to update
        local bodyObj = {
            username = uname,
            last_seen = lastSeenVal,
            online = onlineVal,
            games = merged
        }
        local body = safeJsonEncode(bodyObj)

        local ok, res = pcall(HttpRequest, {
            Url = REST_MEMBERS .. "?user_id=eq." .. tostring(uid),
            Method = "PATCH",
            Headers = defaultHeaders(),
            Body = body
        })

        if not ok or not res then
            warn("[DataMember] SaveUserData PATCH failed: no response")
            return false
        end
        if res.StatusCode >= 200 and res.StatusCode < 300 then
            return true
        end
        warn("[DataMember] SaveUserData PATCH status:", res.StatusCode, res.Body)
        return false
    else
        -- No existing row: create new record via POST (use on_conflict just in case)
        local payload = {
            user_id = uid,
            username = uname,
            games = gamesTable,
            online = onlineVal,
            last_seen = lastSeenVal
        }
        local body = safeJsonEncode(payload)

        local headers = defaultHeaders()
        headers["Prefer"] = "resolution=merge-duplicates"

        local ok, res = pcall(HttpRequest, {
            Url = REST_MEMBERS .. "?on_conflict=user_id",
            Method = "POST",
            Headers = headers,
            Body = body
        })

        if not ok or not res then
            warn("[DataMember] SaveUserData POST failed: no response")
            return false
        end
        if res.StatusCode >= 200 and res.StatusCode < 300 then
            return true
        end
        warn("[DataMember] SaveUserData POST status:", res.StatusCode, res.Body)
        return false
    end
end

--==================================================
--  REPORT + ONLINE STATUS
--==================================================
local function UpdateOnlineStatus(isOnline)
    local uid = USERID
    local body = safeJsonEncode({
        online = isOnline == true,
        last_seen = os.time()
    })

    local ok, res = pcall(HttpRequest, {
        Url = REST_MEMBERS .. "?user_id=eq." .. tostring(uid),
        Method = "PATCH",
        Headers = defaultHeaders(),
        Body = body
    })
    if not ok or not res then
        warn("[DataMember] UpdateOnlineStatus failed: no response")
        return false
    end
    if res.StatusCode >= 200 and res.StatusCode < 300 then
        return true
    end
    -- if 404/204 etc handle as needed
    return false
end

local function ReportPlayer()
    SaveGameIfNotExists()
    UpdateOnlineStatus(true)
    print("[DataMember] Lưu/Report:", USERNAME, USERID, CURRENT_GAME)
end

local function SaveGameIfNotExists()
    local uid = USERID
    local data = GetUserData()

    local newGameEntry = {
        name = REAL_GAME_NAME,
        placeId = game.PlaceId,
        firstSeen = os.time()
    }

    -- if no record, create one with this single game
    if not data then
        local payload = {
            ID = uid,
            Username = USERNAME,
            Games = { [SAFE_GAME_KEY] = newGameEntry },
            Online = true,
            LastSeen = os.time()
        }
        -- SaveUserData will POST
        SaveUserData(payload)
        print("[DataMember] Created new member with initial game:", CURRENT_GAME)
        return
    end

    data.Games = data.Games or {}

    -- If already exists, do nothing
    if data.Games[SAFE_GAME_KEY] then
        -- already recorded, but ensure last_seen/online updated separately
        return
    end

    -- Add game locally, then PATCH only the games + meta
    data.Games[SAFE_GAME_KEY] = newGameEntry
    data.Online = true
    data.LastSeen = os.time()
    data.ID = uid
    data.Username = USERNAME

    local ok = SaveUserData({ ID = uid, Username = data.Username, Games = data.Games, Online = data.Online, LastSeen = data.LastSeen })
    if ok then
        print("[DataMember] Thêm game mới:", CURRENT_GAME)
    else
        warn("[DataMember] Không thể thêm game:", CURRENT_GAME)
    end
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
