local addonName, ns = ...
local L = ns.L
local M = ns.Model
local C = { warnings = {}, foodSpells = {}, inventory = {}, diagnostic = {} }
ns.Client = C

function C.Readable(value)
    if issecretvalue and issecretvalue(value) then
        return false
    end
    if type(value) == "table" and issecrettable and issecrettable(value) then
        return false
    end
    return true
end

function C.Call(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, value = pcall(fn, ...)
    if not ok or not C.Readable(value) then
        return nil
    end
    return value
end

function C.Field(t, key)
    if type(t) ~= "table" or not C.Readable(t) then
        return nil
    end
    local value = t[key]
    if C.Readable(value) then
        return value
    end
end

local function number(value)
    if C.Readable(value) and type(value) == "number" then
        return value
    end
end

function C:Print(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff58d8b0Forever XP|r " .. text)
    end
end

function C:ItemName(id)
    local name = C.Call(C_Item and C_Item.GetItemNameByID, id)
    if name then
        return name
    end
    self.requestedItemNames = self.requestedItemNames or {}
    if not self.requestedItemNames[id] and C_Item and C_Item.RequestLoadItemDataByID then
        self.requestedItemNames[id] = true
        C.Call(C_Item.RequestLoadItemDataByID, id)
    end
    local food = ns.foodByID[id]
    return ns.language == "enUS" and food and food.name or (L.ITEM_PREFIX .. id)
end

function C:Cooldown(id)
    if not C_Item or not C_Item.GetItemCooldown then
        return nil
    end
    local ok, start, duration, enabled = pcall(C_Item.GetItemCooldown, id)
    if not C.Readable(enabled) then
        return nil
    end
    start, duration = number(start), number(duration)
    if not ok or not start or not duration or enabled == false or enabled == 0 then
        return nil
    end
    return math.max(0, start + duration - GetTime())
end

local function tooltipText(data)
    local lines = C.Field(data, "lines")
    if not lines or not C.Readable(lines) then
        return ""
    end
    local text = {}
    for _, line in ipairs(lines) do
        local value = C.Field(line, "leftText")
        if type(value) == "string" then
            text[#text + 1] = value
        end
    end
    return table.concat(text, " ")
end

function C:ScanInventory()
    if InCombatLockdown() then
        self.inventoryDirty = true
        return
    end
    self.inventoryDirty = false
    self.inventory, self.foodSpells = {}, {}
    local count, choices = 0, {}
    if not C_Container or not C_Container.GetContainerNumSlots then
        return
    end
    local maxBag = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4
    for bag = 0, maxBag do
        local slots = number(C.Call(C_Container.GetContainerNumSlots, bag)) or 0
        for slot = 1, slots do
            local item = C.Call(C_Container.GetContainerItemInfo, bag, slot)
            local id = number(C.Field(item, "itemID"))
            if id then
                local quantity = number(C.Field(item, "stackCount")) or 1
                self.inventory[id] = (self.inventory[id] or 0) + quantity
            end
        end
    end
    for id, quantity in pairs(self.inventory) do
        local known = ns.foodByID[id]
        local text = tooltipText(C.Call(C_TooltipInfo and C_TooltipInfo.GetItemByID, id))
        if known or M.HasXPText(text) then
            local required = known and known.level or nil
            if C_Item and C_Item.GetItemInfo then
                local ok, _, _, _, _, minLevel = pcall(C_Item.GetItemInfo, id)
                if ok and number(minLevel) then
                    required = minLevel
                end
            end
            if required and required <= self.tracker.level then
                choices[#choices + 1] = { id = id, count = quantity, name = self:ItemName(id) }
                count = count + quantity
                if C_Item and C_Item.GetItemSpell then
                    local ok, _, spellID = pcall(C_Item.GetItemSpell, id)
                    spellID = number(spellID)
                    if ok and spellID then
                        self.foodSpells[spellID] = id
                    end
                end
            end
        end
    end
    table.sort(choices, function(a, b)
        return a.id < b.id
    end)
    self.foodCount, self.foodChoices = count, choices
    local lw = false
    if GetProfessions and GetProfessionInfo then
        local ok, first, second = pcall(GetProfessions)
        if ok then
            for _, index in pairs({ first, second }) do
                if number(index) then
                    local valid, _, _, rank, _, _, _, skillLine = pcall(GetProfessionInfo, index)
                    if valid and number(skillLine) == 165 and (number(rank) or 0) >= 20 then
                        lw = true
                    end
                end
            end
        end
    end
    self.leatherworking = lw
end

function C:Auras()
    local auras, all, uncertain, eating, tentLock, tentResting = {}, {}, false, false, nil, false
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then
        return auras, false
    end
    if C_Secrets and C_Secrets.ShouldAurasBeSecret then
        local restricted = C.Call(C_Secrets.ShouldAurasBeSecret)
        if restricted == nil or restricted then
            return auras, false
        end
    elseif InCombatLockdown() then
        return auras, false
    end
    local wellFedName = C.Call(C_Spell and C_Spell.GetSpellName, 1249519)
    local tentName = C.Call(C_Spell and C_Spell.GetSpellName, 1229487)
    for _, filter in ipairs({ "HELPFUL", "HARMFUL" }) do
        for i = 1, 255 do
            local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, filter)
            if not ok or not C.Readable(aura) then
                return {}, false
            end
            if not aura then
                break
            end
            local id = number(C.Field(aura, "spellId"))
            if not id then
                return {}, false
            end
            local expiration = number(C.Field(aura, "expirationTime"))
            if expiration and expiration <= 0 then
                expiration = nil
            end
            local entry = {
                spellId = id,
                expiration = expiration,
                stacks = number(C.Field(aura, "applications")) or 1,
                name = C.Field(aura, "name"),
            }
            all[id] = entry
            if ns.sleepAuras[id] then
                auras.sleep = entry
            end
            if ns.pendantAuras[id] then
                auras.pendant = entry
            end
            if M.FoodAura(entry, self.character.learnedFoods) then
                auras.food = entry
            end
            if ns.eatingAuras[id] then
                eating = true
            end
            if
                wellFedName
                and entry.name == wellFedName
                and not M.FoodAura(entry, self.character.learnedFoods)
            then
                uncertain = true
            end
            if id == 1229487 then
                tentResting = true
            end
            -- Only a readable harmful aura with the actual Camp Tent name is
            -- used as a personal lock. The object's cooldown is never reused.
            if filter == "HARMFUL" and tentName and entry.name == tentName and expiration then
                tentLock = math.max(0, expiration - GetTime())
            end
        end
    end
    local pending = self.pendingFood
    if pending then
        local elapsed = GetTime() - pending.at
        if elapsed > 45 then
            self.pendingFood = nil
        elseif elapsed >= 9.5 then
            for id, aura in pairs(all) do
                local old = pending.before[id]
                if
                    wellFedName
                    and aura.name == wellFedName
                    and aura.expiration
                    and (not old or not old.expiration or aura.expiration > old.expiration + 5)
                then
                    self.character.learnedFoods[id] = { item = pending.item, build = self.build }
                    auras.food, uncertain = aura, false
                    self.pendingFood = nil
                    break
                end
            end
        end
    end
    self.allAuras = all
    return auras, true, uncertain, eating, tentLock, tentResting
end

function C:Snapshot()
    local auras, readable, uncertain, eating, lock, tentResting = self:Auras()
    local rested = number(C.Call(GetXPExhaustion))
    if GetXPExhaustion and rested == nil then
        -- The documented nil means no rested XP. A failed/secret result is
        -- kept distinct from that legitimate nil return.
        local ok, value = pcall(GetXPExhaustion)
        if ok and C.Readable(value) and value == nil then
            rested = 0
        end
    end
    local creature = C.Call(UnitCreatureType, "target")
    return {
        level = self.tracker.level,
        maximum = self.tracker.maximum,
        now = GetTime(),
        auras = auras,
        auraReadable = readable,
        rested = rested,
        foodUncertain = uncertain,
        eating = eating or (self.pendingFood and GetTime() - self.pendingFood.at < 10.5),
        tentLock = lock,
        tentResting = tentResting,
        foodCount = self.foodCount or 0,
        sleepOwned = (self.inventory[211527] or 0) > 0,
        tentOwned = (self.inventory[279978] or 0) > 0,
        pendantOwned = (self.inventory[273049] or 0) > 0
            or number(C.Call(GetInventoryItemID, "player", 2)) == 273049,
        leatherworking = self.leatherworking,
        sleepCooldown = self:Cooldown(211527),
        tentCooldown = self:Cooldown(279978),
        pendantCooldown = self:Cooldown(273049),
        undeadTarget = creature ~= nil and ns.undeadNames[creature] == true,
    }
end

function C:Sample()
    if not self.tracker then
        return
    end
    local level = number(C.Call(UnitLevel, "player"))
    local xp = number(C.Call(UnitXP, "player"))
    local maximum = number(C.Call(UnitXPMax, "player"))
    if not level or not xp or not maximum then
        self.diagnostic.xp = L.XP_UNREADABLE
        self.tracker:Advance(GetTime())
        return
    end
    -- XP and level events are not guaranteed to arrive in the same order.
    -- Defer a temporarily reset XP bar until the new level is observable.
    if
        (self.expectedLevel and level < self.expectedLevel)
        or (self.levelSettlesAt and GetTime() < self.levelSettlesAt)
    then
        self.tracker:Advance(GetTime())
        return
    end
    if level == self.tracker.level and xp < self.tracker.xp then
        self.correctionSince = self.correctionSince or GetTime()
        if GetTime() - self.correctionSince < 5 then
            self.tracker:Advance(GetTime())
            return
        end
    else
        self.correctionSince = nil
    end
    self.expectedLevel, self.levelSettlesAt = nil, nil
    self.diagnostic.xp = nil
    self.tracker:Observe(level, xp, maximum, GetTime())
end

function C:Refresh()
    if not self.tracker then
        return
    end
    self:Sample()
    if self.inventoryDirty then
        self:ScanInventory()
    end
    if self.questsDirty or not self.quests then
        self:ScanQuests()
    end
    self.snapshot = self:Snapshot()
    self.states = {}
    local suppressed = self.tracker.mode ~= "active"
        or InCombatLockdown()
        or C.Call(UnitIsDeadOrGhost, "player") == true
        or GetTime() < self.readyAt
    for _, source in ipairs(ns.sources) do
        local state = M.SourceState(source, self.snapshot, self.options)
        self.states[#self.states + 1] = state
        local message = M.Warning(state, self.warnings, GetTime(), self.options, suppressed)
        if message then
            self:Print(message)
            if self.options.sound and PlaySound then
                PlaySound(8959, "Master")
            end
        end
    end
    if ns.UI then
        ns.UI:Render()
    end
end

function C:Mode()
    local afk = C.Call(UnitIsAFK, "player") == true
    self.tracker:SetMode(GetTime(), afk, self.manualPause == true)
end

function C:RequestPlayed()
    if RequestTimePlayed then
        if self.requestedLevel and GetTime() - (self.playedRequestedAt or 0) < 10 then
            return
        end
        self.requestedLevel = self.tracker.level
        self.playedRequestedAt = GetTime()
        C.Call(RequestTimePlayed)
    end
end

function C:ScanQuests()
    local result = { xp = 0, count = 0, unknown = 0, rows = {} }
    if not C_QuestLog or not C_QuestLog.GetNumQuestLogEntries or not GetQuestLogRewardXP then
        result.unavailable = true
        self.quests = result
        return
    end
    local entries = number(C.Call(C_QuestLog.GetNumQuestLogEntries))
    if not entries then
        result.unavailable = true
        self.quests = result
        return
    end
    local seen = {}
    self.questsRequested = self.questsRequested or {}
    for i = 1, entries do
        local info = C.Call(C_QuestLog.GetInfo, i)
        local id = number(C.Field(info, "questID"))
        if
            id
            and id > 0
            and not seen[id]
            and C.Field(info, "isHeader") ~= true
            and C.Field(info, "isHidden") ~= true
        then
            seen[id] = true
            local ready = C.Call(C_QuestLog.ReadyForTurnIn or C_QuestLog.IsComplete, id)
            if ready == true then
                -- Explicit quest ID: never change the player's quest selection.
                -- The client reward is used as-is; do not multiply XP buffs again.
                local reward = number(C.Call(GetQuestLogRewardXP, id))
                result.count = result.count + 1
                if reward and reward >= 0 then
                    result.xp = result.xp + reward
                else
                    result.unknown = result.unknown + 1
                    if not self.questsRequested[id] and C_QuestLog.RequestLoadQuestByID then
                        self.questsRequested[id] = true
                        C.Call(C_QuestLog.RequestLoadQuestByID, id)
                    end
                end
                result.rows[#result.rows + 1] =
                    { id = id, xp = reward, title = C.Field(info, "title") or (L.QUEST_PREFIX .. id) }
            elseif ready == nil then
                result.unknown = result.unknown + 1
            end
        elseif not info then
            result.unknown = result.unknown + 1
        end
    end
    self.quests = result
    self.questsDirty = false
end

function C:Start()
    local _, build, _, interface = GetBuildInfo()
    self.build, self.interface = build, interface
    if interface < 16000 or interface >= 17000 then
        self:Print(L.UNSUPPORTED)
        return
    end
    ForeverXPOptimizerDB = ForeverXPOptimizerDB or {}
    local db = ForeverXPOptimizerDB
    db.schema, db.options, db.characters = 1, db.options or {}, db.characters or {}
    for k, value in pairs(ns.defaults) do
        if db.options[k] == nil then
            db.options[k] = type(value) == "table" and {} or value
        end
    end
    self.options = db.options
    local id = C.Call(UnitGUID, "player")
    if not id then
        self:Print(L.NO_GUID)
        return
    end
    db.characters[id] = db.characters[id] or {}
    self.character = db.characters[id]
    self.character.learnedFoods = self.character.learnedFoods or {}
    for spellID, evidence in pairs(self.character.learnedFoods) do
        if type(evidence) ~= "table" or evidence.build ~= build then
            self.character.learnedFoods[spellID] = nil
        end
    end
    self.character.name = C.Call(UnitName, "player") or id
    local level, xp, maximum =
        C.Call(UnitLevel, "player"), C.Call(UnitXP, "player"), C.Call(UnitXPMax, "player")
    if not number(level) or not number(xp) or not number(maximum) then
        return
    end
    local reload = self.isReload and self.character.reloadPending
    self.tracker = M.NewTracker(self.character, level, xp, maximum, GetTime(), time, reload)
    if not reload then
        self.character.played = nil
    end
    self.readyAt = GetTime() + 15
    self.inventoryDirty = true
    self:Mode()
    self:ScanInventory()
    ns.UI:Create()
    self:RequestPlayed()
    self:Refresh()
    self:Print("v" .. ns.VERSION .. L.LOADED)
end

function C:Command(input)
    if not self.tracker then
        return
    end
    local command, value = input:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")
    if command == "" or command == "show" then
        self.options.shown = true
        ns.UI.frame:Show()
    elseif command == "hide" then
        self.options.shown = false
        ns.UI.frame:Hide()
    elseif command == "pause" then
        self.manualPause = not self.manualPause
        self:Mode()
    elseif command == "neu" or command == "reset" then
        self.character.session = M.NewCounters()
        self.tracker:ResetRate()
        self:Print(L.SESSION_RESET)
    elseif command == "ton" or command == "sound" then
        self.options.sound = not self.options.sound
    elseif command == "scale" and tonumber(value) then
        self.options.scale = math.max(0.65, math.min(1.6, tonumber(value)))
        ns.UI.frame:SetScale(self.options.scale)
    elseif command == "warn" and tonumber(value) then
        self.options.warning = math.max(0, math.min(600, tonumber(value)))
    elseif command == "level" and tonumber(value) then
        ns.UI.preview = math.max(1, math.min(60, math.floor(tonumber(value))))
        self.options.expanded = true
    elseif command == "live" then
        ns.UI.preview = nil
    elseif command == "quelle" or command == "source" then
        for _, source in ipairs(ns.sources) do
            if source.key == value then
                self.options.enabled[value] = self.options.enabled[value] == false
                self:Print(
                    source.name .. (self.options.enabled[value] and L.ENABLED_SUFFIX or L.DISABLED_SUFFIX)
                )
            end
        end
    elseif command == "diagnose" or command == "status" then
        self:Print(
            string.format(
                L.DIAGNOSTICS,
                tostring(self.build),
                tostring(self.interface),
                self.snapshot.auraReadable and L.READABLE or L.RESTRICTED,
                self.diagnostic.xp or L.READABLE,
                ns.UI:LearnedCount()
            )
        )
        self:RequestPlayed()
    elseif command == "position" then
        self.options.point, self.options.x, self.options.y = "CENTER", 260, 0
        ns.UI.frame:ClearAllPoints()
        ns.UI.frame:SetPoint("CENTER", UIParent, "CENTER", 260, 0)
    else
        self:Print(L.COMMANDS)
        self:Print(L.COMMAND_SOURCE)
    end
    self:Refresh()
end

local frame = CreateFrame("Frame")
C.frame = frame
for _, event in ipairs({
    "PLAYER_ENTERING_WORLD",
    "PLAYER_LOGOUT",
    "PLAYER_XP_UPDATE",
    "PLAYER_LEVEL_UP",
    "TIME_PLAYED_MSG",
    "UNIT_AURA",
    "PLAYER_FLAGS_CHANGED",
    "PLAYER_REGEN_ENABLED",
    "PLAYER_REGEN_DISABLED",
    "BAG_UPDATE_DELAYED",
    "GET_ITEM_INFO_RECEIVED",
    "SPELL_UPDATE_COOLDOWN",
    "PLAYER_TARGET_CHANGED",
    "UNIT_SPELLCAST_SUCCEEDED",
    "PLAYER_EQUIPMENT_CHANGED",
    "SKILL_LINES_CHANGED",
    "QUEST_LOG_UPDATE",
    "QUEST_DATA_LOAD_RESULT",
    "QUEST_TURNED_IN",
}) do
    frame:RegisterEvent(event)
end

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, reload = ...
        C.isReload = reload
        if not C.tracker then
            C:Start()
        else
            C:Mode()
            C:Refresh()
        end
        return
    end
    if not C.tracker then
        return
    end
    if event == "PLAYER_LOGOUT" then
        C:Sample()
        C.character.reloadPending = true
    elseif event == "TIME_PLAYED_MSG" then
        local total, levelTime = ...
        C.tracker:Advance(GetTime())
        local requestedLevel = C.requestedLevel
        C.requestedLevel = nil
        if
            number(total)
            and number(levelTime)
            and (not requestedLevel or requestedLevel == C.tracker.level)
        then
            C.tracker:Played(total, levelTime)
        elseif requestedLevel and requestedLevel ~= C.tracker.level then
            C:RequestPlayed()
        end
    elseif event == "QUEST_LOG_UPDATE" or event == "QUEST_DATA_LOAD_RESULT" or event == "QUEST_TURNED_IN" then
        C.questsDirty = true
    elseif event == "PLAYER_FLAGS_CHANGED" then
        C:Mode()
    elseif
        event == "BAG_UPDATE_DELAYED"
        or event == "GET_ITEM_INFO_RECEIVED"
        or event == "SKILL_LINES_CHANGED"
    then
        C.inventoryDirty = true
    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        C.expectedLevel = number(newLevel)
        C.levelSettlesAt = GetTime() + 0.2
        -- Wait for UnitLevel/XP to agree; PLAYER_LEVEL_UP may arrive first.
        C_Timer.After(0.25, function()
            C:Sample()
            C:RequestPlayed()
            C.inventoryDirty = true
            C.questsDirty = true
        end)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if C.Readable(unit) and unit == "player" and number(spellID) and C.foodSpells[spellID] then
            C.pendingFood = { item = C.foodSpells[spellID], at = GetTime(), before = C.allAuras or {} }
        end
    elseif event == "PLAYER_XP_UPDATE" then
        C:Sample()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        C.inventoryDirty = true
    end
    C.dirty = true
end)

local elapsed = 0
frame:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed < 1 then
        return
    end
    elapsed = 0
    if C.tracker then
        C:Mode()
        C:Refresh()
    end
end)

SLASH_FOREVERXPOPTIMIZER1 = "/fxp"
SLASH_FOREVERXPOPTIMIZER2 = "/foreverxp"
SlashCmdList.FOREVERXPOPTIMIZER = function(input)
    C:Command(input or "")
end
