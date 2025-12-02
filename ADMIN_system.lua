
_G.AdminLoaded = true

--============================--
--  CLIENT-ONLY ADMIN SYSTEM
--============================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Admin danh sách
local ADMINS = {
	["Happy_bmg"] = true,
	[7326395533] = true,
}

-- Kiểm tra người gửi có phải admin không
local function isAdmin(plr)
	if not plr then return false end
	if ADMINS[plr.Name] then return true end
	if ADMINS[plr.UserId] then return true end
	return false
end

-- Xử lý lệnh
local function processCommand(sender, message)
	if not isAdmin(sender) then return end  -- không phải admin thì bỏ qua

	message = string.lower(message)

	-- Lệnh /kill username
	if message:sub(1, 6) == "/kill " then
		local targetName = message:sub(7)

		-- nếu đúng tên mình thì tự kill
		if string.lower(targetName) == string.lower(LocalPlayer.Name) then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.Health = 0
			end
		end
	end
end

-- Theo dõi chat của người chơi khác
local function onPlayerAdded(plr)
	plr.Chatted:Connect(function(msg)
		processCommand(plr, msg)
	end)
end

-- Gán cho tất cả người chơi đã có
for _, plr in ipairs(Players:GetPlayers()) do
	onPlayerAdded(plr)
end

-- Khi có người mới vào
Players.PlayerAdded:Connect(onPlayerAdded)
