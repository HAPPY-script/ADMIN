local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ADMINS = {
	["Happy_devlop"] = true,
	[7326395533] = true,
	[4333331142] = true,
}

local function isAdmin(plr)
	if not plr then return false end
	return ADMINS[plr.UserId] or ADMINS[plr.Name] or false
end

local function killLocalPlayer()
	local char = LocalPlayer.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		hum.Health = 0
	end
end

local function processCommand(sender, message)
	if not isAdmin(sender) then return end
	if type(message) ~= "string" then return end

	local cmd, arg = message:match("^(%S+)%s*(.*)$")
	if not cmd then return end

	if string.lower(cmd) == "/kill" then
		if string.lower(arg) == string.lower(LocalPlayer.Name) then
			killLocalPlayer()
		end
	end
end

local function hookPlayer(plr)
	plr.Chatted:Connect(function(msg)
		processCommand(plr, msg)
	end)
end

for _, plr in ipairs(Players:GetPlayers()) do
	hookPlayer(plr)
end

Players.PlayerAdded:Connect(hookPlayer)
