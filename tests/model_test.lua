local ns = {}
assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/Data.lua"))("ForeverXPOptimizer", ns)
assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/Model.lua"))("ForeverXPOptimizer", ns)
local M = ns.Model
local count = 0
local function eq(actual, expected, message)
    assert(
        actual == expected,
        (message or "Mismatch") .. ": " .. tostring(actual) .. " ~= " .. tostring(expected)
    )
end
local function test(name, fn)
    fn()
    count = count + 1
    print("PASS " .. name)
end
local function tracker(level, xp, maximum)
    return M.NewTracker({}, level or 1, xp or 0, maximum or 400, 0, function()
        return 1000
    end, false)
end

test("rate excludes AFK time and AFK awards", function()
    local t = tracker()
    t:Observe(1, 100, 400, 120)
    eq(t:Rate(), 3000)
    t:SetMode(120, true, false)
    t:Observe(1, 200, 400, 720)
    eq(t.db.session.afk, 600)
    eq(t.db.session.active, 120)
    eq(t:Rate(), 3000)
    t:SetMode(720, false, false)
    t:Advance(840)
    eq(t:Rate(), 1500)
    eq(t.db.session.online, 840)
end)
test("manual pause excludes time and awarded XP", function()
    local t = tracker()
    t:SetMode(0, false, true)
    t:Observe(1, 100, 400, 600)
    eq(t.db.session.paused, 600)
    eq(t.db.session.xp, 0)
    eq(t:Rate(), nil)
    t:SetMode(600, false, false)
    t:Observe(1, 200, 400, 720)
    eq(t:Rate(), 3000)
end)
test("single level overflow splits XP without losing reward", function()
    local t = tracker(1, 350, 400)
    t:Observe(2, 100, 900, 120)
    eq(t.db.session.xp, 150)
    eq(t.db.history[1].xp, 50)
    eq(t.db.current.xp, 100)
    eq(t.db.history[1].online, 120)
    eq(t.db.current.online, 0)
    eq(t:Rate(), 4500)
    eq(t:ETA(4500), 640)
end)
test("multi level reward uses all crossed thresholds", function()
    local t = tracker(1, 350, 400)
    t:Observe(4, 75, 2100, 120)
    eq(t.db.session.xp, 2425)
    eq(t.db.history[2].xp, 900)
    eq(t.db.history[3].xp, 1400)
    eq(t.db.history[2].skipped, true)
end)
test("initial current-level time is marked partial", function()
    local t = tracker(20, 15000, 23200)
    eq(t.db.current.partial, true)
    t:Played(90000, 1500)
    t:Advance(60)
    eq(t.db.played.total, 90060)
    eq(t.db.played.level, 1560)
end)
test("reload resumes session but cold login starts a new one", function()
    local t = tracker()
    t:Observe(1, 100, 400, 120)
    local db = t.db
    local reload = M.NewTracker(db, 1, 100, 400, 5000, function()
        return 2000
    end, true)
    eq(reload.db.session.online, 120)
    eq(reload.db.session.xp, 100)
    eq(reload:Rate(), nil)
    local login = M.NewTracker(db, 1, 100, 400, 9000, function()
        return 3000
    end, false)
    eq(login.db.session.online, 0)
    eq(login.db.totals.online, 120)
end)
test("long AFK invalidates stale rate", function()
    local t = tracker()
    t:Observe(1, 100, 400, 120)
    t:SetMode(120, true, false)
    t:SetMode(1320, false, false)
    eq(t:Rate(), nil)
    eq(t.db.session.afk, 1200)
end)
test("rolling window drops old XP and includes active idle", function()
    local t = tracker(20, 0, 23200)
    t:Observe(20, 100, 23200, 120)
    t:Advance(1020)
    eq(t:Rate(), 0)
    eq(t:ETA(0), nil)
    t:Observe(20, 200, 23200, 1021)
    eq(t:Rate(), 400)
end)
test("repeated same XP event never double counts", function()
    local t = tracker()
    t:Observe(1, 100, 400, 120)
    t:Observe(1, 100, 400, 120)
    eq(t.db.session.xp, 100)
end)
test("level cap has no ETA", function()
    local t = tracker(59, 209700, 209800)
    t:Observe(60, 0, 0, 120)
    eq(t.db.session.xp, 100)
    eq(t:ETA(3000), nil)
end)

local options = { enabled = {}, warning = 60, repeatAfter = 300 }
local function snapshot()
    return {
        level = 20,
        maximum = 23200,
        now = 100,
        auras = {},
        auraReadable = true,
        rested = 0,
        foodCount = 4,
        sleepOwned = true,
        sleepCooldown = 0,
        tentOwned = true,
        leatherworking = true,
        tentCooldown = 0,
    }
end
local function state(key, s, o)
    for _, source in ipairs(ns.sources) do
        if source.key == key then
            return M.SourceState(source, s, o or options)
        end
    end
end
test("missing usable food is actionable", function()
    eq(state("food", snapshot()).actionable, true)
end)
test("ordinary well-fed without evidence stays unknown", function()
    local s = snapshot()
    s.foodUncertain = true
    eq(state("food", s).kind, "unknown")
end)
test("hidden aura access never produces missing buff alert", function()
    local s = snapshot()
    s.auraReadable = false
    eq(state("food", s).kind, "unknown")
    eq(state("sleep", s).kind, "unknown")
end)
test("eating suppresses missing food", function()
    local s = snapshot()
    s.eating = true
    eq(state("food", s).kind, "info")
end)
test("sleep partial stacks and real cooldown", function()
    local s = snapshot()
    s.auras.sleep = { expiration = 800, stacks = 1 }
    eq(state("sleep", s).kind, "partial")
    eq(state("sleep", s).actionable, true)
    s.sleepCooldown = 800
    eq(state("sleep", s).actionable, false)
    s.auras.sleep.stacks = 3
    eq(state("sleep", s).kind, "active")
    s.auras.sleep.expiration = 130
    eq(state("sleep", s).kind, "soon")
end)
test("tent cannot overfill or conflate personal/object cooldown", function()
    local s = snapshot()
    s.rested = s.maximum * 0.05
    eq(state("tent", s).kind, "active")
    s.rested = 0
    s.tentLock = 500
    eq(state("tent", s).kind, "cooldown")
    s.tentLock = nil
    eq(state("tent", s).actionable, true)
    s.tentOwned = false
    eq(state("tent", s).kind, "obtain")
end)
test("level gates, disabled sources and active borrowed sleeping bag", function()
    local s = snapshot()
    s.level = 5
    eq(state("sleep", s).kind, "locked")
    s.auras.sleep = { stacks = 3, expiration = 900 }
    eq(state("sleep", s).kind, "active")
    eq(state("food", s, { enabled = { food = false } }).kind, "ignored")
    s.level = 60
    eq(state("food", s).kind, "info")
end)
test("pendant only prompts on undead target when owned", function()
    local s = snapshot()
    s.level = 30
    s.pendantOwned = true
    s.pendantCooldown = 0
    eq(state("pendant", s).kind, "info")
    s.undeadTarget = true
    eq(state("pendant", s).actionable, true)
end)
test("suppression does not consume warning, reminders are throttled", function()
    local memory, s = {}, state("food", snapshot())
    eq(M.Warning(s, memory, 100, options, true), nil)
    assert(M.Warning(s, memory, 100, options, false))
    eq(M.Warning(s, memory, 101, options, false), nil)
    assert(M.Warning(s, memory, 400, options, false))
end)
test("acquisition reminder is once until state changes", function()
    local memory, s = {}, snapshot()
    s.sleepOwned = false
    assert(M.Warning(state("sleep", s), memory, 100, options, false))
    eq(M.Warning(state("sleep", s), memory, 1000, options, false), nil)
end)
test("formatting and live food classifier", function()
    eq(M.Number(1234567), "1.234.567")
    eq(M.Duration(3661), "1:01:01")
    eq(M.HasXPText("Erfahrung durch Kills um 5% erhöht"), true)
    eq(M.HasXPText("Experience gained increased by 5%."), true)
    eq(M.HasXPText("5% critical strike"), false)
    eq(M.FoodAura({ spellId = 99999 }, {}), false)
end)
test("quest projection within a level", function()
    local p = M.ProjectQuests(13, 4162, 11400, 3270)
    eq(p.level, 13)
    eq(p.xp, 7432)
    eq(p.levels, 0)
    assert(math.abs(p.percent - 65.1929824561) < 0.00001)
end)
test("quest projection spans multiple levels and exact boundaries", function()
    local p = M.ProjectQuests(1, 350, 400, 2425)
    eq(p.level, 4)
    eq(p.xp, 75)
    eq(p.levels, 3)
    p = M.ProjectQuests(1, 350, 400, 50)
    eq(p.level, 2)
    eq(p.xp, 0)
    eq(p.percent, 0)
end)
test("quest projection caps at 60 without mutating tracker", function()
    local t = tracker(59, 209700, 209800)
    local p = M.ProjectQuests(59, t.xp, t.maximum, 900000)
    eq(p.level, 60)
    eq(p.percent, 100)
    eq(t.db.session.xp, 0)
    eq(t.xp, 209700)
end)
print("Model tests passed: " .. count)
