local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Admin danh sách
local ADMINS = {
	["Happy_devlop"] = true,
	[7326395533] = true,
	[4333331142] = true,
}

local function isAdmin(plr)
	if not plr then return false end
	if ADMINS[plr.Name] then return true end
	if ADMINS[plr.UserId] then return true end
	return false
end

local function processCommand(sender, message)
	if not isAdmin(sender) then return end

	message = string.lower(message)

	if message:sub(1, 6) == "/kill " then
		local targetName = message:sub(7)

		if string.lower(targetName) == string.lower(LocalPlayer.Name) then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.Health = 0
			end
		end
	end
end

local function onPlayerAdded(plr)
	plr.Chatted:Connect(function(msg)
		processCommand(plr, msg)
	end)
end

for _, plr in ipairs(Players:GetPlayers()) do
	onPlayerAdded(plr)
end

Players.PlayerAdded:Connect(onPlayerAdded)
