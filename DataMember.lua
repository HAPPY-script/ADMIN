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

-- Lấy tên game thật bằng API Roblox

-- Chuyển tên game thành key an toàn cho Firebase
local function MakeSafeKey(str)
    return str:gsub("[.%$#%[%]/]", "_")
end

local function GetRealGameName()
    local universeId = game.GameId
    local url = "https://games.roblox.com/v1/games?universeIds=" .. universeId

    local response = HttpRequest({
        Url = url,
        Method = "GET"
    })

    if not response or response.StatusCode ~= 200 then
        warn("[GetRealGameName] Lỗi API → dùng fallback")
        return "Unknown Game"
    end

    local data = HttpService:JSONDecode(response.Body)
    if data and data.data and data.data[1] and data.data[1].name then
        return data.data[1].name
    end

    return "Unknown Game"
end

-- Tên game thật + PlaceId
local REAL_GAME_NAME = GetRealGameName()
local CURRENT_GAME = REAL_GAME_NAME .. " (" .. game.PlaceId .. ")"
local SAFE_GAME_KEY = MakeSafeKey(CURRENT_GAME)

local PROJECT_URL = "https://happy-script-bada6-default-rtdb.asia-southeast1.firebasedatabase.app/Member/" .. USERNAME .. ".json"

--==================================================--
--  GET USER DATA (NEEDED TO AVOID OVERWRITE)
--==================================================--
local function GetUserData()
	local response = HttpRequest({
		Url = PROJECT_URL,
		Method = "GET"
	})

	if not response or response.StatusCode ~= 200 or response.Body == "null" then
		return nil
	end

	return HttpService:JSONDecode(response.Body)
end

--==================================================--
--  REPORT PLAYER + SAVE GAME HISTORY
--==================================================--
local function ReportPlayer()
	local data = GetUserData()

	if not data then
		-- Player chưa tồn tại -> tạo mới
		data = {
			ID = USERID,
			Games = {}
		}
	end

	-- Nếu chưa có bảng Games thì tạo
	data.Games = data.Games or {}

    -- Thêm game mới nếu chưa có
    if not data.Games[SAFE_GAME_KEY] then
        data.Games[SAFE_GAME_KEY] = true
    end

	print("[DataMember] Lưu:", USERNAME, USERID, CURRENT_GAME)

	-- Gửi dữ liệu hoàn chỉnh lên server
	local response = HttpRequest({
		Url = PROJECT_URL,
		Method = "PUT",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode(data)
	})

	if response and response.StatusCode == 200 then
		print("[DataMember] Thành công!")
	else
		warn("[DataMember] Thất bại! Status:", response and response.StatusCode)
	end
end

--==================================================--
--  AUTO SEND
--==================================================--
task.wait(1)

ReportPlayer()

print("Done DataMember✅")
