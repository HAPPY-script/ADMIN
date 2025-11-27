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

-- Ví dụ: "Blox Fruits (2753915549)"
local CURRENT_GAME = tostring(game.Name .. " (" .. game.PlaceId .. ")")

local PROJECT_URL =
	"https://happy-script-bada6-default-rtdb.asia-southeast1.firebasedatabase.app/Member/" ..
	USERNAME .. ".json"

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
	if not data.Games[CURRENT_GAME] then
		data.Games[CURRENT_GAME] = true
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
