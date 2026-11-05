local _, ns = ...
local L = ns.L
local M = {}
ns.Model = M

function M.NewCounters()
    return { online = 0, active = 0, afk = 0, paused = 0, xp = 0 }
end

local function add(c, dt, mode)
    c.online = c.online + dt
    c[mode] = c[mode] + dt
end

function M.NewTracker(db, level, xp, maximum, now, wall, reload)
    db.totals = db.totals or M.NewCounters()
    db.history = db.history or {}
    -- Only PLAYER_LOGOUT marked as a UI reload may resume the session.
    if not reload or not db.session then
        db.session = M.NewCounters()
    end
    if not db.current or db.current.level ~= level then
        db.current = M.NewCounters()
        db.current.level, db.current.partial = level, xp ~= 0
    end
    db.reloadPending = nil
    local tracker = {
        db = db,
        level = level,
        xp = xp,
        maximum = maximum,
        last = now,
        wall = wall,
        clock = 0,
        samples = {},
        mode = "active",
        paused = false,
        afk = false,
        rateGeneration = 0,
    }
    return setmetatable(tracker, { __index = M })
end

function M:Advance(now)
    local dt = math.max(0, now - self.last)
    self.last = now
    if dt == 0 then
        return
    end
    add(self.db.totals, dt, self.mode)
    add(self.db.session, dt, self.mode)
    add(self.db.current, dt, self.mode)
    if self.db.played then
        self.db.played.total = self.db.played.total + dt
        self.db.played.level = self.db.played.level + dt
    end
    if self.mode == "active" then
        self.clock = self.clock + dt
    end
    self:Prune()
end

function M:ResetRate()
    self.clock, self.samples = 0, {}
    self.rateGeneration = self.rateGeneration + 1
end

function M:SetMode(now, afk, paused)
    self:Advance(now)
    local nextMode = afk and "afk" or (paused and "paused" or "active")
    if self.mode ~= nextMode then
        if self.mode == "active" then
            self.breakStarted = now
        end
        if nextMode == "active" and self.breakStarted and now - self.breakStarted >= 900 then
            self:ResetRate()
        end
        self.mode = nextMode
    end
    self.afk, self.paused = afk, paused
end

function M:Prune()
    local cutoff = self.clock - (self.window or 900)
    local i = 1
    while self.samples[i] and self.samples[i].at <= cutoff do
        i = i + 1
    end
    if i > 1 then
        local trimmed = {}
        for j = i, #self.samples do
            trimmed[#trimmed + 1] = self.samples[j]
        end
        self.samples = trimmed
    end
end

function M:Observe(level, xp, maximum, now)
    self:Advance(now)
    if level < self.level or (level == self.level and xp < self.xp) then
        -- A reset/correction cannot be interpreted as earned XP.
        self.level, self.xp, self.maximum = level, xp, maximum
        self:ResetRate()
        return 0
    end
    local gained = xp - self.xp
    if level > self.level then
        gained = self.maximum - self.xp + xp
        for l = self.level + 1, level - 1 do
            gained = gained + (ns.xpToNext[l] or 0)
        end
        local row = self.db.current
        row.level, row.finishedAt = self.level, self.wall()
        row.gameTime = self.db.played and self.db.played.level or nil
        self.db.history[self.level] = row
        for l = self.level + 1, level - 1 do
            self.db.history[l] = {
                level = l,
                partial = true,
                skipped = true,
                online = 0,
                active = 0,
                afk = 0,
                paused = 0,
                xp = 0,
            }
        end
        self.db.current = M.NewCounters()
        self.db.current.level, self.db.current.partial = level, false
        if self.db.played then
            self.db.played.level = 0
        end
    end
    gained = math.max(0, gained)
    -- AFK awards are real but must not inflate the active XP rate. A manual
    -- pause excludes both XP and time from all measured rate counters.
    if self.mode == "active" and gained > 0 then
        self.db.totals.xp = self.db.totals.xp + gained
        self.db.session.xp = self.db.session.xp + gained
        self.samples[#self.samples + 1] = { at = self.clock, xp = gained }
    end
    -- Split a crossing award at the level boundary, rather than assigning
    -- the entire quest reward to the newly entered level.
    if self.mode == "active" then
        if level > self.level then
            self.db.history[self.level].xp = self.db.history[self.level].xp + self.maximum - self.xp
            for l = self.level + 1, level - 1 do
                self.db.history[l].xp = ns.xpToNext[l] or 0
            end
            self.db.current.xp = xp
        else
            self.db.current.xp = self.db.current.xp + gained
        end
    end
    self.level, self.xp, self.maximum = level, xp, maximum
    self:Prune()
    return gained
end

function M:Rate(window, minimum)
    self.window = window or 900
    self:Prune()
    local seconds = math.min(self.clock, self.window)
    if seconds < (minimum or 120) then
        return nil, seconds
    end
    local xp = 0
    for _, sample in ipairs(self.samples) do
        xp = xp + sample.xp
    end
    return xp * 3600 / seconds, seconds
end

function M:ETA(rate)
    if self.level >= 60 or not rate or rate <= 0 then
        return nil
    end
    return math.max(0, self.maximum - self.xp) * 3600 / rate
end

function M.ProjectQuests(level, xp, maximum, questXP)
    local startLevel = level
    local projected = xp + math.max(0, questXP or 0)
    local threshold = maximum
    while level < 60 and threshold and threshold > 0 and projected >= threshold do
        projected = projected - threshold
        level = level + 1
        threshold = ns.xpToNext[level]
    end
    if level >= 60 then
        return { level = 60, xp = 0, percent = 100, levels = 60 - startLevel }
    end
    return {
        level = level,
        xp = projected,
        percent = threshold and projected / threshold * 100 or 0,
        levels = level - startLevel,
    }
end

function M:Played(total, levelTime)
    self.db.played = { total = total, level = levelTime }
    if levelTime > self.db.current.online + 5 then
        self.db.current.partial = true
    end
end

function M.Duration(seconds)
    if seconds == nil then
        return "–"
    end
    seconds = math.max(0, math.floor(seconds))
    local h, m, s = math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%d:%02d", m, s)
end

function M.Number(value)
    if value == nil then
        return "–"
    end
    local text = tostring(math.floor(value + 0.5))
    local formatted = text:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
    return (formatted:gsub("%.", ns.groupSeparator))
end

function M.Decimal(value)
    return (string.format("%.1f", value):gsub("%.", ns.decimalSeparator))
end

function M.HasXPText(text)
    -- Lua 5.1's byte-oriented lower() can corrupt UTF-8 on some host locales.
    text = (text or ""):gsub("[A-Z]", function(c)
        return string.char(c:byte() + 32)
    end)
    text = text:gsub("É", "é"):gsub("Ê", "ê"):gsub("È", "è")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("\194\160", " "):gsub("％", "%%")
    if not (text:match("^5%s*%%") or text:find("[^%d%.,]5%s*%%")) then
        return false
    end
    for _, word in ipairs(ns.xpWords) do
        if text:find(word, 1, true) then
            return true
        end
    end
    return false
end

function M.FoodAura(aura, learned)
    return ns.foodAuras[aura.spellId] or (learned and learned[aura.spellId]) ~= nil
end

function M.SourceState(source, s, options)
    local state = { key = source.key, name = source.name, source = source, kind = "info" }
    local function set(kind, text, actionable)
        state.kind, state.text, state.actionable = kind, text, actionable
        return state
    end
    if options.enabled[source.key] == false then
        return set("ignored", L.DISABLED)
    end
    if s.level >= 60 then
        return set("info", L.MAX_LEVEL)
    end
    local aura = s.auras[source.key]
    if aura then
        state.remaining = aura.expiration and math.max(0, aura.expiration - s.now) or nil
        state.stacks = aura.stacks
        local time = state.remaining and (" · " .. M.Duration(state.remaining)) or ""
        if source.key == "sleep" and (aura.stacks or 1) < 3 then
            return set("partial", string.format(L.STACKS_FMT, aura.stacks or 1, time), s.sleepCooldown == 0)
        end
        if state.remaining and state.remaining <= options.warning then
            return set("soon", L.EXPIRING .. time, false)
        end
        return set("active", (source.key == "sleep" and L.FULL_STACKS or L.ACTIVE) .. time)
    end
    if s.level < source.minLevel then
        return set("locked", L.FROM_LEVEL .. source.minLevel)
    end
    if source.key == "rested" then
        if s.rested == nil then
            return set("unknown", L.RESERVE_UNKNOWN)
        end
        if s.rested > 0 then
            return set("active", M.Number(s.rested) .. L.XP_RESERVE)
        end
        return set("missing", L.RESERVE_EMPTY, false)
    elseif source.key == "tent" then
        if s.rested == nil then
            return set("unknown", L.REST_UNKNOWN)
        end
        if s.rested >= s.maximum * 0.05 then
            return set("active", L.REST_ENOUGH)
        end
        if s.tentLock then
            return set("cooldown", L.BENEFIT_LOCK .. M.Duration(s.tentLock))
        end
        if s.tentResting then
            return set("info", L.REST_AT_TENT)
        end
        if s.tentCooldown and s.tentCooldown > 0 then
            return set("cooldown", L.PLACEMENT .. M.Duration(s.tentCooldown))
        end
        if s.tentOwned and s.leatherworking then
            if s.tentCooldown == nil then
                return set("unknown", L.PLACEMENT_UNKNOWN)
            end
            return set("missing", L.TENT_READY, true)
        end
        return set("obtain", L.FIND_TENT)
    elseif source.key == "legacy" then
        return set("info", L.LEGACY_STATUS)
    end
    if not s.auraReadable then
        return set("unknown", L.AURAS_RESTRICTED)
    end
    if source.key == "food" then
        if s.foodUncertain then
            return set("unknown", L.FOOD_UNVERIFIED)
        end
        if s.eating then
            return set("info", L.EATING)
        end
        if s.foodCount > 0 then
            return set("missing", L.MISSING_PREFIX .. s.foodCount .. L.PORTIONS, true)
        end
        return set("obtain", L.GET_FOOD, true)
    elseif source.key == "sleep" then
        if s.sleepOwned then
            if s.sleepCooldown == nil then
                return set("unknown", L.ITEM_CD_UNKNOWN)
            end
            if s.sleepCooldown > 0 then
                return set("cooldown", L.MISSING_READY_IN .. M.Duration(s.sleepCooldown))
            end
            return set("missing", L.SLEEP_READY, true)
        end
        return set("obtain", L.GET_SLEEP, true)
    elseif source.key == "pendant" then
        if not s.pendantOwned then
            return set("obtain", L.GET_PENDANT, true)
        end
        if not s.undeadTarget then
            return set("info", L.UNDEAD_READY)
        end
        if s.pendantCooldown == nil then
            return set("unknown", L.CD_UNKNOWN)
        end
        if s.pendantCooldown > 0 then
            return set("cooldown", L.READY_IN .. M.Duration(s.pendantCooldown))
        end
        return set("missing", L.USE_UNDEAD, true)
    end
    return set("unknown", L.STATUS_UNKNOWN)
end

-- Warning state is only advanced after suppression ends, so combat/AFK/death
-- does not consume the reminder that should be shown on returning.
function M.Warning(state, memory, now, options, suppressed)
    if suppressed or state.kind == "unknown" then
        return nil
    end
    local previous = memory[state.key]
    local reason
    if state.kind == "soon" then
        reason = L.WARN_SOON
    elseif state.kind == "partial" and state.actionable then
        reason = L.WARN_STACKS
    elseif state.kind == "missing" and (state.actionable or (previous and previous.active)) then
        reason = L.WARN_MISSING
    elseif state.kind == "obtain" and state.actionable then
        reason = L.WARN_UNLOCK
    end
    local active = state.kind == "active" or state.kind == "soon" or state.kind == "partial"
    if not previous then
        previous = {}
        memory[state.key] = previous
    end
    if reason then
        local changed = previous.kind ~= state.kind
        local repeatable = state.kind ~= "obtain"
        if
            (changed or not previous.warned) and (not previous.last or now - previous.last >= 5)
            or (repeatable and previous.last and now - previous.last >= options.repeatAfter)
        then
            previous.last, previous.warned = now, true
            previous.kind, previous.active = state.kind, active
            return reason .. ": " .. state.name .. " – " .. state.text
        end
    else
        previous.warned = nil
    end
    previous.kind, previous.active = state.kind, active
end
