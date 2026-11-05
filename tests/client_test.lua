-- Smoke-test the real event adapter and real UI under a small WoW API harness.
-- API tables intentionally expose modern C_* functions, not old Classic globals.
local ns = {}
GetLocale = function()
    return TEST_LOCALE or "deDE"
end
local now, afk, combat, restricted, dead = 100, false, false, false, false
local level, xp, maximum = 20, 100, 23200
local auras, messages, frames = {}, {}, {}
local ready, missingReward, loadRequests = true, true, 0
local undeadTarget, extraFood = false, false
local locale = TEST_LOCALE or "deDE"
local aliases = { enGB = "enUS", esMX = "esES", ptPT = "ptBR" }
local language = aliases[locale] or locale
local nativeUndead = {
    enUS = "Undead",
    deDE = "Untoter",
    frFR = "Mort-vivant",
    esES = "No-muerto",
    itIT = "Non Morto",
    ptBR = "Morto-vivo",
    ruRU = "Нежить",
    koKR = "언데드",
    zhCN = "亡灵",
    zhTW = "不死族",
}
local nativeFood = {
    enUS = "Well Fed",
    deDE = "Satt",
    frFR = "Bien nourri",
    esES = "Bien alimentado",
    itIT = "Sazio",
    ptBR = "Bem Alimentado",
    ruRU = "Сытость",
    koKR = "포만감",
    zhCN = "进食充分",
    zhTW = "充分進食",
}
local tooltipXP = {
    enUS = "Experience from kills increased by 5%.",
    deDE = "Erfahrung durch Kills um 5% erhöht.",
    frFR = "Expérience gagnée augmentée de 5 %.",
    esES = "Experiencia aumentada un 5%.",
    itIT = "Esperienza aumentata del 5%.",
    ptBR = "Experiência aumentada em 5%.",
    ruRU = "Получаемый опыт увеличен на 5%.",
    koKR = "경험치 획득량이 5%만큼 증가합니다.",
    zhCN = "获得的经验提高5%。",
    zhTW = "獲得的經驗提高5%。",
}
local foodName = nativeFood[language] or nativeFood.enUS
local function noop() end
local methods = {}
function methods:SetScript(key, fn)
    self.scripts[key] = fn
end
function methods:GetPoint()
    return "CENTER", nil, "CENTER", 260, 0
end
function methods:SetText(value)
    self.text = value
end
function methods:GetStringHeight()
    return #(self.text or "") / 3
end
function methods:GetChecked()
    return self.checked
end
function methods:SetChecked(value)
    self.checked = value
end
function methods:Show()
    self.shown = true
end
function methods:Hide()
    self.shown = false
end
function methods:SetShown(value)
    self.shown = value
end
local function object()
    local f = { scripts = {} }
    return setmetatable(f, {
        __index = function(_, key)
            if methods[key] then
                return methods[key]
            end
            if key == "CreateFontString" or key == "CreateTexture" then
                return object
            end
            return noop
        end,
    })
end
function CreateFrame(_, name)
    local f = object()
    frames[#frames + 1] = f
    if name then
        _G[name] = f
    end
    return f
end
UIParent = object()
GameTooltip = object()
DEFAULT_CHAT_FRAME = {
    AddMessage = function(_, message)
        messages[#messages + 1] = message
    end,
}
SlashCmdList = {}
NUM_BAG_SLOTS = 4
function GetTime()
    return now
end
function time()
    return 100000 + now
end
function GetBuildInfo()
    return "1.60.1", "70790", "Nov 5 2026", 16001
end
function UnitGUID()
    return "Player-TEST"
end
function UnitName()
    return "Tester"
end
function UnitLevel()
    return level
end
function UnitXP()
    return xp
end
function UnitXPMax()
    return maximum
end
function UnitIsAFK()
    return afk
end
function UnitIsDeadOrGhost()
    return dead
end
function InCombatLockdown()
    return combat
end
function GetXPExhaustion()
    return nil
end
function GetInventoryItemID()
    return nil
end
function UnitCreatureType()
    return undeadTarget and (nativeUndead[language] or "Undead") or "Humanoid"
end
function RequestTimePlayed() end
function PlaySound() end
function issecretvalue(value)
    return type(value) == "table" and value.secret == true
end
C_Timer = {
    After = function(_, fn)
        fn()
    end,
}
C_Secrets = {
    ShouldAurasBeSecret = function()
        return restricted
    end,
}
C_UnitAuras = {
    GetAuraDataByIndex = function(_, i, filter)
        assert(not restricted, "Should not query restricted auras")
        if filter == "HARMFUL" then
            return nil
        end
        return auras[i]
    end,
}
C_Item = {
    GetItemCooldown = function()
        return 0, 0, true
    end,
    GetItemNameByID = function(id)
        return "Item " .. id
    end,
    GetItemInfo = function(id)
        return "Item", "link", 1, 10, 1
    end,
    GetItemSpell = function()
        return "Essen", 1248377
    end,
}
C_Container = {
    GetContainerNumSlots = function(bag)
        return bag == 0 and (extraFood and 2 or 1) or 0
    end,
    GetContainerItemInfo = function(_, slot)
        if slot == 2 then
            return { itemID = 77777, stackCount = 2 }
        end
        return { itemID = 6888, stackCount = 8 }
    end,
}
C_Spell = {
    GetSpellName = function(id)
        return id == 1249519 and foodName or ("NativeTent-" .. locale)
    end,
}
C_TooltipInfo = {
    GetItemByID = function()
        return { lines = { { leftText = tooltipXP[language] or tooltipXP.enUS } } }
    end,
}

local questLog = {
    { isHeader = true, title = "Zone" },
    { questID = 100, title = "Fertige Quest" },
    { questID = 200, title = "Unfertige Quest" },
    { questID = 300, title = "Fehlende XP-Daten" },
    { questID = 100, title = "Doppelter Eintrag" },
    { questID = 400, title = "Versteckte Quest", isHidden = true },
}
C_QuestLog = {
    GetNumQuestLogEntries = function()
        return #questLog, 4
    end,
    GetInfo = function(index)
        return questLog[index]
    end,
    ReadyForTurnIn = function(id)
        return ready and id ~= 200
    end,
    RequestLoadQuestByID = function()
        loadRequests = loadRequests + 1
    end,
}
function GetQuestLogRewardXP(id)
    if id == 300 and missingReward then
        return nil
    end
    return id == 100 and 300 or 500
end

for line in io.lines(PROJECT_ROOT .. "/ForeverXPOptimizer/ForeverXPOptimizer.toc") do
    if line:match("%.lua%s*$") then
        local file = line:gsub("\\", "/"):gsub("%s+$", "")
        assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/" .. file))("ForeverXPOptimizer", ns)
    end
end
local C = ns.Client
local dispatch = C.frame.scripts.OnEvent
dispatch(C.frame, "PLAYER_ENTERING_WORLD", true, false)
assert(C.tracker and ns.UI.frame, "Login creates model and real UI")
assert(C.foodCount == 8, "Taschenbestand")
assert(ns.UI.levelTime.text:find(ns.L.LEVEL_TIME, 1, true) == 1, "client-language heading")
undeadTarget = true
assert(C:Snapshot().undeadTarget == true, "localized undead detection: " .. locale)
undeadTarget = false
extraFood = true
C:ScanInventory()
assert(C.foodCount == 10, "localized XP tooltip detects new food: " .. locale)
extraFood = false
C:ScanInventory()
assert(C.snapshot.rested == 0, "documented nil exhausted rested")
assert(
    C.quests.xp == 300 and C.quests.count == 2 and C.quests.unknown == 1,
    "only ready, visible, unique quests; unknown reward is not zero"
)
assert(C.character.session.xp == 0, "pending quest rewards never count as earned XP")
assert(loadRequests == 1, "request missing reward data once")
assert(ns.UI.questLabel.text:find("300", 1, true), "quest reward displayed")
missingReward = false
dispatch(C.frame, "QUEST_DATA_LOAD_RESULT", 300, true)
C:Refresh()
assert(C.quests.xp == 800 and C.quests.unknown == 0, "async reward refresh")
ready = false
dispatch(C.frame, "QUEST_TURNED_IN", 100, 300)
C:Refresh()
assert(C.quests.xp == 0 and C.quests.count == 0, "quest turn-in refresh")
dispatch(C.frame, "TIME_PLAYED_MSG", 10000, 500)
assert(C.character.played.total == 10000)
assert(C:Cooldown(211527) == 0, "modern cooldown boolean")
C_Item.GetItemCooldown = function()
    return 0, 0, false
end
assert(C:Cooldown(211527) == nil, "disabled cooldown is unknown, not ready")
C_Item.GetItemCooldown = function()
    return 0, 0, true
end
now = 220
xp = 200
dispatch(C.frame, "PLAYER_XP_UPDATE", "player")
assert(C.tracker:Rate() == 3000, "XP event rate")
afk = true
dispatch(C.frame, "PLAYER_FLAGS_CHANGED", "player")
now = 820
C:Refresh()
assert(C.character.session.afk == 600, "AFK integration")
afk = false
dispatch(C.frame, "PLAYER_FLAGS_CHANGED", "player")
restricted = true
C:Refresh()
assert(C.states[1].kind == "unknown", "secrecy produces unknown")
restricted = false
auras = { { spellId = 1249519, name = foodName, expirationTime = now + 900, applications = 1 } }
C:Refresh()
assert(C.states[1].kind == "active", "verified visible stat aura")
auras = { { spellId = 99999, name = foodName, expirationTime = now + 900, applications = 1 } }
C:Refresh()
assert(C.states[1].kind == "unknown", "unverified Well Fed not blindly accepted")
auras = {}
C:Refresh()
dispatch(C.frame, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", 1248377)
now = now + 10
auras = { { spellId = 88888, name = foodName, expirationTime = now + 900, applications = 1 } }
C:Refresh()
assert(C.character.learnedFoods[88888], "live learning from verified food")
assert(C.states[1].kind == "active")
C:Command("pause")
assert(C.tracker.mode == "paused")
C:Command("pause")
assert(C.tracker.mode == "active")
C:Command("sound")
assert(C.options.sound == true, "English sound command")
C:Command("ton")
assert(C.options.sound == false, "German command stays compatible")
C:Command("quelle food")
assert(C.states[1].kind == "ignored")
C:Command("quelle food")
assert(C.states[1].kind == "active")
C:Command("source food")
assert(C.states[1].kind == "ignored", "English source command")
C:Command("source food")
C:Command("level 14")
assert(ns.UI.preview == 14)
C:Command("live")
assert(ns.UI.preview == nil)
C:Command("diagnose")
C:Command("hide")
assert(ns.UI.frame.shown == false)
C:Command("")
assert(ns.UI.frame.shown == true)
C:Command("scale 9")
assert(C.options.scale == 1.6)
C:Command("neu")
assert(C.character.session.online == 0)
assert(C.character.totals.online > 0)
-- XP bar reset arrives before the corresponding level update.
auras = {}
xp = 50
C:Sample()
assert(C.tracker.xp == 200 and C.tracker.level == 20, "defer inconsistent XP reset")
dispatch(C.frame, "PLAYER_LEVEL_UP", 21)
assert(C.tracker.level == 20, "level announcement before UnitLevel")
level, maximum = 21, 25200
now = now + 1
C:Sample()
assert(C.tracker.level == 21 and C.character.session.xp == 23050, "crossing award counted once")
C:Sample()
assert(C.character.session.xp == 23050, "duplicate level/XP event")
dispatch(C.frame, "PLAYER_LOGOUT")
assert(C.character.reloadPending)
print("Client/UI smoke test passed: " .. locale)
