local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ID của người duy nhất có quyền dùng lệnh k_ad (và là owner)
local OWNER_ID = 7326395533

-- Danh sách admins (KHÔNG bao gồm OWNER_ID)
local ADMINS = {
    ["Happy_devlop"] = true,
    ["trungtran38740"] = true,
    ["Happy_bmg0"] = true,
    [4333331142] = true,
}

local function isAdmin(plr)
    if not plr then return false end
    return ADMINS[plr.UserId] or ADMINS[plr.Name] or false
end

-- Nếu bạn vẫn muốn giữ killLocalPlayer (dùng hum.Health = 0) cho fallback, giữ hàm này.
local function killLocalPlayer()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        hum.Health = 0
    end
end

-- Kick trực tiếp local player với message (dùng pcall để tránh lỗi)
local function doLocalKick(message)
    local ok, err = pcall(function()
        LocalPlayer:Kick(tostring(message or ""))
    end)
    if not ok then
        pcall(killLocalPlayer)
        warn("Local Kick failed:", err)
    end
end

-- Xử lý lệnh k_members (gửi bởi owner hoặc admin)
local function handleKMembers(note)
    if LocalPlayer.UserId == OWNER_ID then return end
    if isAdmin(LocalPlayer) then return end
    doLocalKick(note)
end

-- Xử lý lệnh k_ad (chỉ có OWNER gửi được lệnh này)
local function handleKAd(note)
    if LocalPlayer.UserId == OWNER_ID then return end
    if isAdmin(LocalPlayer) then
        doLocalKick(note)
    end
end

-- Trim helper
local function trim(s)
    if not s then return "" end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- ===== Valid commands & suggestion logic =====
local VALID_COMMANDS = {
    "kk_members",
    "k_members",
    "kk_ad",
    "k_ad",
}
local VALID_SET = {}
for _, v in ipairs(VALID_COMMANDS) do VALID_SET[v] = true end

-- Levenshtein distance (standard DP)
local function levenshtein(a, b)
    a = a or ""
    b = b or ""
    local la = #a
    local lb = #b
    if la == 0 then return lb end
    if lb == 0 then return la end

    -- create two rows to save memory
    local prev = {}
    local cur = {}

    for j = 0, lb do
        prev[j] = j
    end

    for i = 1, la do
        cur[0] = i
        local ai = a:sub(i,i)
        for j = 1, lb do
            local bj = b:sub(j,j)
            local cost = (ai == bj) and 0 or 1
            local deletion = prev[j] + 1
            local insertion = cur[j-1] + 1
            local substitution = prev[j-1] + cost
            local minv = deletion
            if insertion < minv then minv = insertion end
            if substitution < minv then minv = substitution end
            cur[j] = minv
        end
        -- swap rows
        for k = 0, lb do prev[k] = cur[k] end
    end
    return prev[lb]
end

-- Suggest closest valid command (returns nil if none reasonable)
local function suggestCommand(cmd)
    if not cmd or cmd == "" then return nil end
    cmd = string.lower(cmd)

    -- exact or already valid -> no suggestion
    if VALID_SET[cmd] then return nil end

    local best, bestScore, bestIsPrefix = nil, math.huge, false
    for _, v in ipairs(VALID_COMMANDS) do
        local lowerV = v:lower()

        -- prefix match (e.g., "k_m" -> matches "k_members")
        if lowerV:sub(1, #cmd) == cmd or cmd:sub(1, #lowerV) == lowerV then
            -- prefer prefix match strongly
            return v
        end

        -- compute levenshtein distance
        local d = levenshtein(cmd, lowerV)
        if d < bestScore then
            bestScore = d
            best = v
        end
    end

    -- threshold: chỉ suggest nếu cách ít (<= 2)
    if best and bestScore <= 2 then
        return best
    end

    return nil
end

-- Show notification to local player (pcall to be safe)
local function notifyLocal(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "Thông báo"),
            Text = tostring(text or ""),
            Duration = tonumber(duration) or 6
        })
    end)
end

-- Parse message: lấy command (+ optional note)
local function parseCommand(message)
    if type(message) ~= "string" then return nil end
    local msg = trim(message)
    if msg == "" then return nil end

    -- first token (command)
    local first = msg:match("^(%S+)")
    if not first then return nil end
    -- remove leading slash if có
    local cmd = first:gsub("^/", "")
    cmd = string.lower(cmd)

    -- try to extract bracket content [] hoặc ()
    local note = msg:match("%[(.-)%]") or msg:match("%((.-)%)")
    if not note then
        -- nếu không có bracket, lấy phần sau command (nếu có)
        local rest = msg:match("^%S+%s+(.+)$")
        if rest then note = rest end
    end
    if note then note = trim(note) end

    return cmd, note
end

-- Xử lý command được gửi bởi `sender`
local function processCommand(sender, message)
    if not sender or typeof(message) ~= "string" then return end

    local cmd, note = parseCommand(message)
    if not cmd then return end

    -- Nếu sender là admin/owner và gõ lệnh KHÔNG hợp lệ, show suggestion cho CHÍNH NGƯỜI SENDer
    local senderIsPrivileged = (sender.UserId == OWNER_ID) or isAdmin(sender)
    if senderIsPrivileged and not VALID_SET[cmd] then
        -- only notify on sender's client
        if sender.UserId == LocalPlayer.UserId then
            local suggestion = suggestCommand(cmd)
            if suggestion then
                notifyLocal("Sai cú pháp", ("Bạn đã nhập '%s'. Có thể ý bạn là: '%s'"):format(cmd, suggestion), 6)
            else
                notifyLocal("Sai cú pháp", ("Lệnh '%s' không hợp lệ. Lệnh hợp lệ: kk_members, k_members, kk_ad, k_ad"):format(cmd), 8)
            end
        end
        -- don't execute any invalid command
        return
    end

    -- nếu hợp lệ -> thực hiện hành động tương ứng (vẫn đảm bảo quyền)
    if cmd == "kk_members" or cmd == "k_members" then
        if sender.UserId == OWNER_ID or isAdmin(sender) then
            handleKMembers(note)
        end
        return
    end

    if cmd == "kk_ad" or cmd == "k_ad" then
        if sender.UserId == OWNER_ID then
            handleKAd(note)
        end
        return
    end
end

-- Hook player chat
local function hookPlayer(plr)
    if not plr then return end
    plr.Chatted:Connect(function(msg)
        pcall(function() processCommand(plr, msg) end)
    end)
end

-- Hook hiện tại + players mới join
for _, plr in ipairs(Players:GetPlayers()) do
    hookPlayer(plr)
end
Players.PlayerAdded:Connect(hookPlayer)
