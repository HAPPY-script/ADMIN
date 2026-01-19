local WORKER_URL = "https://supabase.happy37135535.workers.dev/"

--==================================================
--  FIREBASE MAINTENANCE SWITCH (kept)
--==================================================
if getgenv().DataMember = false then
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

local USERNAME = LocalPlayer and LocalPlayer.Name or "Unknown"
local USERID = LocalPlayer and LocalPlayer.UserId or 0

--==================================================
--  UTILS
--==================================================
local function MakeSafeKey(str)
	return str:gsub("[.%$#%[%]/]", "_")
end

local function safeJsonEncode(t)
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    if ok and type(s) == "string" then return s end
    return "{}"
end

local function safeJsonDecode(s)
    local ok, t = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then return t end
    return nil
end

local function GetRealGameName()
	local url = "https://games.roblox.com/v1/games?universeIds=" .. game.GameId
	local ok, res = pcall(HttpRequest, { Url = url, Method = "GET" })
	if not ok or not res or res.StatusCode ~= 200 then
		return "Unknown Game"
	end
	local body = safeJsonDecode(res.Body)
	if body and body.data and type(body.data) == "table" and body.data[1] and body.data[1].name then
		return body.data[1].name
	end
	return "Unknown Game"
end

--==================================================
--  GAME INFO
--==================================================
local REAL_GAME_NAME = GetRealGameName()
local CURRENT_GAME = REAL_GAME_NAME .. " (" .. tostring(game.PlaceId) .. ")"
local SAFE_GAME_KEY = MakeSafeKey("place_" .. tostring(game.PlaceId))

--==================================================
--  SEND TO WORKER (primary change)
--  Worker chịu trách nhiệm gom + upsert vào Supabase
--==================================================
local function SendToWorker(payload)
	local headers = {
		["Content-Type"] = "application/json"
	}
	-- If you set getgenv().WorkerSecret = "xxx", it'll be sent in header for Worker auth
	if getgenv().WorkerSecret then
		headers["X-Worker-Secret"] = tostring(getgenv().WorkerSecret)
	end

	local body = safeJsonEncode(payload)

	-- Retry loop: 3 attempts with small backoff
	for attempt = 1, 3 do
		local ok, res = pcall(HttpRequest, {
			Url = WORKER_URL,
			Method = "POST",
			Headers = headers,
			Body = body
		})

		if ok and res and res.StatusCode and res.StatusCode >= 200 and res.StatusCode < 300 then
			return true, res
		end

		-- exponential-ish backoff (non-blocking)
		local waitTime = 0.25 * attempt
		task.wait(waitTime)
	end

	return false, "failed after retries"
end

--==================================================
--  Save / Update (client now sends to Worker)
--  Worker sẽ xử lý merge/insert/upsert vào Supabase
--==================================================
local function SaveUserData(data)
    -- Build payload describing desired upsert/update.
    -- Let Worker handle whether to create or merge existing.
    local payload = {
        action = "upsert_user", -- for readability on server logs; Worker may ignore
        user_id = data.ID or USERID,
        username = data.Username or USERNAME,
        games = data.Games or {},
        online = (data.Online == true),
        last_seen = data.LastSeen or os.time()
    }

    local ok, res = SendToWorker(payload)
    if not ok then
        warn("[DataMember] SaveUserData: failed to send to worker:", res)
        return false
    end
    return true
end

local function UpdateOnlineStatus(isOnline)
    local payload = {
        action = "update_online",
        user_id = USERID,
        online = (isOnline == true),
        last_seen = os.time()
    }

    local ok, res = SendToWorker(payload)
    if not ok then
        warn("[DataMember] UpdateOnlineStatus failed:", res)
        return false
    end
    return true
end

--==================================================
--  REPORT + GAME MANAGEMENT (kept semantics)
--  Các hàm giờ chỉ gửi intent -> Worker sẽ thực hiện merge / upsert
--==================================================
local function ReportPlayer()
    SaveGameIfNotExists()
    UpdateOnlineStatus(true)
    print("[DataMember] Lưu/Report:", USERNAME, USERID, CURRENT_GAME)
end

local function findGameKeyByPlaceId(gamesTable, placeId)
    if not gamesTable then return nil end
    for key, entry in pairs(gamesTable) do
        if type(entry) == "table" and entry.placeId and tonumber(entry.placeId) == tonumber(placeId) then
            return key, entry
        end
    end
    return nil
end

local function SaveGameIfNotExists()
    -- New approach: don't GET from DB on client. Instead send desired state to Worker,
    -- Worker sẽ kiểm tra tồn tại/merge/upsert khi flush.
    local newGameEntry = {
        name = REAL_GAME_NAME,
        placeId = game.PlaceId,
        firstSeen = os.time()
    }

    local payload = {
        action = "ensure_game",
        user_id = USERID,
        username = USERNAME,
        game_key = SAFE_GAME_KEY,
        game_entry = newGameEntry,
        online = true,
        last_seen = os.time()
    }

    local ok, res = SendToWorker(payload)
    if ok then
        print("[DataMember] Requested ensure_game:", CURRENT_GAME)
    else
        warn("[DataMember] Failed ensure_game request:", res)
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

print("✅ Done DataMember (proxy -> Worker)")
