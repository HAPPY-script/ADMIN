-- LocalScript (đặt trong StarterPlayerScripts)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ID của người duy nhất có quyền dùng lệnh k_ad (và là owner)
local OWNER_ID = 7326395533

-- Danh sách admins (KHÔNG bao gồm OWNER_ID)
local ADMINS = {
    ["Happy_devlop"] = true,
    [4333331142] = true,
    -- thêm userId khác nếu cần: [123456789] = true
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

-- Xử lý lệnh k_members (gửi bởi owner hoặc admin)
local function handleKMembers()
    -- nếu local là owner thì không kill
    if LocalPlayer.UserId == OWNER_ID then return end
    -- nếu local là admin thì không bị kill bởi k_members
    if isAdmin(LocalPlayer) then return end
    -- còn lại (member) => kill
    killLocalPlayer()
end

-- Xử lý lệnh k_ad (chỉ có OWNER gửi được lệnh này)
local function handleKAd()
    -- owner không bị kill
    if LocalPlayer.UserId == OWNER_ID then return end
    -- chỉ kill nếu local là admin
    if isAdmin(LocalPlayer) then
        killLocalPlayer()
    end
end

local function processCommand(sender, message)
    if not sender or typeof(message) ~= "string" then return end

    -- chuẩn hoá message: trim + lowercase
    local msg = message:match("^%s*(.-)%s*$") or ""
    local cmd = string.lower(msg:match("^(%S+)") or "")

    if cmd == "" then return end

    -- Quy tắc:
    -- - k_members: hợp lệ nếu sender là OWNER hoặc sender là ADMIN
    -- - k_ad: hợp lệ chỉ khi sender là OWNER

    -- nếu là k_members và sender là owner hoặc admin => thực thi k_members
    if (cmd == "k_members" or cmd == "/k_members") and (sender.UserId == OWNER_ID or isAdmin(sender)) then
        handleKMembers()
        return
    end

    -- nếu là k_ad và sender là owner => thực thi k_ad
    if (cmd == "k_ad" or cmd == "/k_ad") and sender.UserId == OWNER_ID then
        handleKAd()
        return
    end

    -- các lệnh khác: bỏ qua
end

local function hookPlayer(plr)
    plr.Chatted:Connect(function(msg)
        pcall(function() processCommand(plr, msg) end)
    end)
end

-- Hook player đã có
for _, plr in ipairs(Players:GetPlayers()) do
    hookPlayer(plr)
end

-- Hook player mới join
Players.PlayerAdded:Connect(hookPlayer)
