local WORKER_URL = "https://supabase.happy37135535.workers.dev/"
local WORKER_SECRET = nil

local SUPABASE_BASE = nil
local SUPABASE_KEY  = nil

--==================================================
--  HTTP REQUEST AUTO-DETECT (giữ nguyên)
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

local function GetRealGameName()
	local url = "https://games.roblox.com/v1/games?universeIds=" .. tostring(game.GameId)
	local ok, res = pcall(HttpRequest, { Url = url, Method = "GET" })
	if not ok or not res or res.StatusCode ~= 200 then
		return "Unknown Game"
	end
	local success, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
	if success and data and data.data and data.data[1] and data.data[1].name then
		return data.data[1].name
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
--  WORKER SENDER + QUEUE
--==================================================
local pendingQueue = {} -- lưu payload nếu gửi thất bại
local queueLock = false

local function buildHeaders()
	local h = {
		["Content-Type"] = "application/json"
	}
	if WORKER_SECRET and WORKER_SECRET ~= "" then
		h["X-Worker-Secret"] = WORKER_SECRET
	end
	return h
end

local function sendHttpPayload(payload)
	local body = nil
	local okEnc, s = pcall(function() return HttpService:JSONEncode(payload) end)
	if not okEnc then
		warn("[DataMember] JSONEncode failed for payload")
		return false
	end
	body = s

	local ok, res = pcall(HttpRequest, {
		Url = WORKER_URL,
		Method = "POST",
		Headers = buildHeaders(),
		Body = body
	})
	if not ok or not res then
		return false
	end
	-- treat 2xx as success
	if res.StatusCode >= 200 and res.StatusCode < 300 then
		return true
	end
	return false
end

local function enqueuePayload(payload)
	table.insert(pendingQueue, payload)
end

local function tryFlushQueue()
	if queueLock then return end
	if #pendingQueue == 0 then return end
	queueLock = true
	local i = 1
	while i <= #pendingQueue do
		local payload = pendingQueue[i]
		local ok = sendHttpPayload(payload)
		if ok then
			-- remove element i
			table.remove(pendingQueue, i)
			-- do not advance i (next element shifted into position i)
		else
			-- failed: keep it and move to next
			i = i + 1
		end
		-- avoid tight loop; yield a tick so other tasks run
		task.wait(0.01)
	end
	queueLock = false
end

-- background flush: thử gửi lại hàng đợi mỗi 30s
task.spawn(function()
	while true do
		tryFlushQueue()
		task.wait(30)
	end
end)

-- wrapper an toàn: sẽ gửi ngay, hoặc lưu hàng đợi nếu thất bại
local function SendToWorkerAsync(payload)
	task.spawn(function()
		local ok = sendHttpPayload(payload)
		if not ok then
			-- lưu để retry
			enqueuePayload(payload)
			warn("[DataMember] SendToWorker failed - queued for retry")
		end
	end)
end

--==================================================
--  PUBLIC ACTIONS => gửi action cho Worker xử lý
--  Worker của bạn nên chấp nhận các action: "save_game", "update_online", "report"
--==================================================
local function UpdateOnlineStatus(isOnline)
	local payload = {
		action = "update_online",
		user_id = USERID,
		online = (isOnline == true),
		last_seen = os.time()
	}
	SendToWorkerAsync(payload)
end

local function SaveGameIfNotExists()
	local newGameEntry = {
		name = REAL_GAME_NAME,
		placeId = game.PlaceId,
		firstSeen = os.time()
	}

	local payload = {
		action = "save_game",
		user_id = USERID,
		username = USERNAME,
		games = { [SAFE_GAME_KEY] = newGameEntry },
		online = true,
		last_seen = os.time()
	}

	SendToWorkerAsync(payload)
end

local function ReportPlayer()
	-- gửi một báo cáo ngắn cho Worker; Worker sẽ gom/patch lên DB
	local payload = {
		action = "report",
		user_id = USERID,
		username = USERNAME,
		placeId = game.PlaceId,
		game = REAL_GAME_NAME,
		online = true,
		last_seen = os.time()
	}
	SendToWorkerAsync(payload)
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

print("✅ Done DataMember (worker-backed)")
