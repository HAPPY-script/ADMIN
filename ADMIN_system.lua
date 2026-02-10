-- LocalScript (đặt trong StarterPlayerScripts)
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

-- Fallback: kill (nếu Kick bị chặn)
local function killLocalPlayer()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        hum.Health = 0
    end
end

-- Kick trực tiếp local player (pcall để tránh lỗi)
local function doLocalKick(message)
    local ok, err = pcall(function()
        LocalPlayer:Kick(tostring(message or ""))
    end)
    if not ok then
        pcall(killLocalPlayer)
        warn("Local Kick failed:", err)
    end
end

-- Hành vi các lệnh
local function handleKMembers(note)
    if LocalPlayer.UserId == OWNER_ID then return end
    if isAdmin(LocalPlayer) then return end
    doLocalKick(note)
end

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

-- Levenshtein distance (DP)
local function levenshtein(a, b)
    a = a or ""
    b = b or ""
    local la = #a
    local lb = #b
    if la == 0 then return lb end
    if lb == 0 then return la end

    local prev = {}
    local cur = {}

    for j = 0, lb do prev[j] = j end

    for i = 1, la do
        cur[0] = i
        local ai = a:sub(i,i)
        for j = 1, lb do
            local bj = b:sub(j,j)
            local cost = (ai == bj) and 0 or 1
            local deletion = prev[j] + 1
            local insertion = cur[j-1] + 1
            local substitution = prev[j-1] + cost
            local m = deletion
            if insertion < m then m = insertion end
            if substitution < m then m = substitution end
            cur[j] = m
        end
        for k = 0, lb do prev[k] = cur[k] end
    end
    return prev[lb]
end

local function suggestCommand(cmd)
    if not cmd or cmd == "" then return nil end
    cmd = string.lower(cmd)
    if VALID_SET[cmd] then return nil end

    local best, bestScore = nil, math.huge
    for _, v in ipairs(VALID_COMMANDS) do
        local lowerV = v:lower()
        if lowerV:sub(1, #cmd) == cmd or cmd:sub(1, #lowerV) == lowerV then
            return v
        end
        local d = levenshtein(cmd, lowerV)
        if d < bestScore then bestScore = d; best = v end
    end

    if best and bestScore <= 2 then return best end
    return nil
end

-- Show notification to local player
local function notifyLocal(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "Thông báo"),
            Text = tostring(text or ""),
            Duration = tonumber(duration) or 6
        })
    end)
end

-- Parse message => cmd + note
local function parseCommand(message)
    if type(message) ~= "string" then return nil end
    local msg = trim(message)
    if msg == "" then return nil end

    local first = msg:match("^(%S+)")
    if not first then return nil end
    local cmd = first:gsub("^/", "")
    cmd = string.lower(cmd)

    local note = msg:match("%[(.-)%]") or msg:match("%((.-)%)")
    if not note then
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

    -- CHỈ xử lý khi câu bắt đầu bằng k_ hoặc kk_ (đã chuẩn hóa cmd không có '/')
    if not (cmd:sub(1,2) == "k_" or cmd:sub(1,3) == "kk_") then
        return
    end

    local senderIsOwner = (sender.UserId == OWNER_ID)
    local senderIsAdmin = isAdmin(sender)
    local senderIsLocal = (sender.UserId == LocalPlayer.UserId)

    -- Nếu cú pháp sai (không nằm trong VALID_SET):
    --  -> chỉ thông báo gợi ý cho ADMIN (KHÔNG thông báo cho OWNER)
    if not VALID_SET[cmd] then
        if senderIsAdmin and senderIsLocal then
            local suggestion = suggestCommand(cmd)
            if suggestion then
                notifyLocal("Sai cú pháp", ("Bạn đã nhập '%s'. Có thể ý bạn là: '%s'"):format(cmd, suggestion), 6)
            else
                notifyLocal("Sai cú pháp", ("Lệnh '%s' không hợp lệ. Lệnh hợp lệ: kk_members, k_members, kk_ad, k_ad"):format(cmd), 8)
            end
        end
        return
    end

    -- Nếu đến đây, cú pháp hợp lệ (cmd ∈ VALID_SET).
    -- Kiểm tra quyền và thực thi hoặc thông báo "không đủ quyền".
    if cmd == "kk_members" or cmd == "k_members" then
        if senderIsOwner then
            -- owner: thực thi, không thông báo
            if senderIsLocal then handleKMembers(note) end
            return
        end
        if senderIsAdmin then
            -- admin: được phép thực thi
            if senderIsLocal then handleKMembers(note) end
            return
        end
        -- member: không có quyền -> thông báo (chỉ trên client của sender)
        if senderIsLocal then
            notifyLocal("Không đủ quyền", "Bạn không có quyền sử dụng lệnh này (k_members).", 6)
        end
        return
    end

    if cmd == "kk_ad" or cmd == "k_ad" then
        if senderIsOwner then
            -- owner: thực thi
            if senderIsLocal then handleKAd(note) end
            return
        end
        -- admin và member: KHÔNG có quyền -> thông báo (nội dung giống nhau)
        if senderIsLocal then
            notifyLocal("Không đủ quyền", "Bạn không có quyền sử dụng lệnh này (k_ad).", 6)
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
