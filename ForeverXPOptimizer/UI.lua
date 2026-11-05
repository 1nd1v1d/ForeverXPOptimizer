local _, ns = ...
local L = ns.L
local C, M = ns.Client, ns.Model
local UI = {}
ns.UI = UI
local colors = {
    active = "66dbb0",
    soon = "ffbb55",
    partial = "ffbb55",
    missing = "ff7777",
    obtain = "e5c785",
    cooldown = "98b5d8",
    unknown = "aab1be",
    locked = "737b8a",
    ignored = "737b8a",
    info = "aabbd0",
}
local labels = {
    active = "OK",
    soon = L.TAG_SOON,
    partial = L.TAG_PARTIAL,
    missing = L.TAG_MISSING,
    obtain = L.TAG_OBTAIN,
    cooldown = "CD",
    unknown = "?",
    locked = L.TAG_LOCKED,
    ignored = L.TAG_OFF,
    info = "INFO",
}

local function text(parent, size, x, y, width)
    local font = parent:CreateFontString(nil, "OVERLAY", size or "GameFontHighlightSmall")
    font:SetPoint("TOPLEFT", x, y)
    font:SetJustifyH("LEFT")
    if width then
        font:SetWidth(width)
    end
    return font
end

local function button(parent, label, x, y, width, action)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 23)
    b:SetPoint("TOPLEFT", x, y)
    b:SetText(label)
    b:SetScript("OnClick", action)
    return b
end

function UI:Tooltip(row)
    local state = C.states and C.states[row.index]
    if not state then
        return
    end
    local source = state.source
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(source.name, 0.4, 0.9, 0.75)
    GameTooltip:AddLine(state.text, 1, 1, 1, true)
    GameTooltip:AddLine(source.help, 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine(source.obtain, 0.8, 0.85, 0.95, true)
    if source.item then
        GameTooltip:AddLine(C:ItemName(source.item) .. " · ID " .. source.item, 0.8, 0.8, 0.8, true)
    end
    if source.key == "food" then
        for _, food in ipairs(C.foodChoices or {}) do
            GameTooltip:AddLine(food.count .. " × " .. food.name, 0.7, 1, 0.8, true)
        end
        if C.snapshot.foodUncertain then
            GameTooltip:AddLine(L.FOOD_LEARN, 1, 0.8, 0.4, true)
        end
    end
    GameTooltip:AddLine(L.ROW_HELP, 0.6, 0.65, 0.7, true)
    GameTooltip:Show()
end

local WIDTH, BAR_WIDTH = 760, 736
local function label(parent, x, y, width, align, template)
    local f = text(parent, template, x, y, width)
    f:SetJustifyH(align or "LEFT")
    f:SetWordWrap(false)
    f:SetShadowColor(0, 0, 0, 1)
    f:SetShadowOffset(1, -1)
    return f
end

function UI:QuestTooltip()
    local q = C.quests
    if not q then
        return
    end
    GameTooltip:SetOwner(self.bar, "ANCHOR_TOP")
    GameTooltip:AddLine(L.QUEST_TOOLTIP, 1, 0.78, 0.3)
    GameTooltip:AddLine(L.BAR_LEGEND, 0.85, 0.85, 0.9, true)
    for _, quest in ipairs(q.rows) do
        GameTooltip:AddDoubleLine(
            quest.title,
            quest.xp and M.Number(quest.xp) .. " XP" or L.UNKNOWN,
            1,
            1,
            1,
            1,
            0.8,
            0.3
        )
    end
    if q.unavailable then
        GameTooltip:AddLine(L.QUEST_UNAVAILABLE, 1, 0.6, 0.4, true)
    elseif q.unknown > 0 then
        GameTooltip:AddLine(q.unknown .. L.QUEST_LOWER_BOUND, 1, 0.6, 0.4, true)
    end
    GameTooltip:AddLine(L.QUEST_CAVEAT, 0.7, 0.75, 0.8, true)
    GameTooltip:AddLine(L.QUEST_RATE_NOTE, 0.7, 0.75, 0.8, true)
    GameTooltip:Show()
end

function UI:Create()
    if self.frame then
        return
    end
    local f = CreateFrame("Frame", "ForeverXPOptimizerFrame", UIParent, "BackdropTemplate")
    self.frame = f
    f:SetSize(WIDTH, 126)
    f:SetPoint(C.options.point, UIParent, C.options.point, C.options.x, C.options.y)
    f:SetScale(C.options.scale)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetFrameStrata("MEDIUM")
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0.025, 0.025, 0.04, 0.8)
    f:SetBackdropBorderColor(0.22, 0.18, 0.3, 0.7)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function()
        f:StartMoving()
    end)
    f:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point, _, _, x, y = f:GetPoint()
        C.options.point, C.options.x, C.options.y = point, x, y
    end)
    f:SetScript("OnMouseUp", function(_, which)
        if which == "RightButton" then
            self:ToggleDetails()
        end
    end)
    self.levelTime = label(f, 12, -8, 355)
    self.sessionTime = label(f, 376, -8, 372, "RIGHT")
    local bar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    self.bar = bar
    bar:SetSize(BAR_WIDTH, 23)
    bar:SetPoint("TOPLEFT", 12, -27)
    bar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    bar:SetBackdropColor(0.055, 0.04, 0.075, 1)
    bar:SetBackdropBorderColor(0.45, 0.35, 0.25, 1)
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function()
        self:QuestTooltip()
    end)
    bar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    bar:SetScript("OnMouseUp", function(_, which)
        if which == "RightButton" then
            self:ToggleDetails()
        end
    end)
    self.fill = bar:CreateTexture(nil, "ARTWORK", nil, 0)
    self.fill:SetColorTexture(0.47, 0.2, 0.78, 0.95)
    self.rested = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    self.rested:SetColorTexture(0.2, 0.4, 0.9, 0.4)
    self.questFill = bar:CreateTexture(nil, "ARTWORK", nil, 2)
    self.questFill:SetColorTexture(0.9, 0.59, 0.16, 0.85)
    local shine = bar:CreateTexture(nil, "ARTWORK", nil, 3)
    shine:SetColorTexture(1, 1, 1, 0.13)
    shine:SetPoint("TOPLEFT", 1, -1)
    shine:SetSize(BAR_WIDTH - 2, 6)
    self.levelLabel = label(bar, 6, -5, 100, "LEFT", "GameFontNormal")
    self.xpLabel = label(bar, 116, -5, 390, "CENTER", "GameFontHighlight")
    self.percentLabel = label(bar, 510, -5, 218, "RIGHT", "GameFontHighlight")
    self.estimate = label(f, 12, -55, 475)
    self.restLabel = label(f, 490, -55, 258, "RIGHT")
    self.questLabel = label(f, 12, -75, 736)
    self.questLabel:SetTextColor(1, 0.79, 0.36)
    self.icons = {}
    for i, source in ipairs(ns.sources) do
        local row = CreateFrame("Frame", nil, f, "BackdropTemplate")
        self.icons[i], row.index = row, i
        row:SetSize(23, 23)
        row:SetPoint("TOPLEFT", 12 + (i - 1) * 29, -96)
        row:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetAllPoints()
        row.icon:SetTexture(source.icon)
        row.badge = label(row, 1, -11, 21, "RIGHT")
        row:EnableMouse(true)
        row:SetScript("OnEnter", function()
            self:Tooltip(row)
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        row:SetScript("OnMouseUp", function(_, which)
            if which == "RightButton" then
                self:ToggleDetails()
            end
        end)
    end
    self.summary = label(f, 196, -102, 330)
    self.pauseButton = button(f, L.PAUSE, 538, -96, 65, function()
        C:Command("pause")
    end)
    self.detailsButton = button(f, L.DETAILS, 609, -96, 70, function()
        self:ToggleDetails()
    end)
    button(f, "×", 685, -96, 63, function()
        C:Command("hide")
    end)
    self.detail = CreateFrame("Frame", nil, f)
    self.detail:SetPoint("TOPLEFT", 12, -137)
    self.detail:SetSize(BAR_WIDTH, 480)
    self.metrics = label(self.detail, 0, 0, BAR_WIDTH)
    self.metrics:SetWordWrap(true)
    self.metrics:SetSpacing(4)
    self.rows = {}
    for i, source in ipairs(ns.sources) do
        local row = CreateFrame("Frame", nil, self.detail)
        self.rows[i], row.index = row, i
        row:SetPoint("TOPLEFT", 0, -63 - (i - 1) * 27)
        row:SetSize(BAR_WIDTH, 26)
        row:EnableMouse(true)
        local key = source.key
        row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        row.check:SetSize(24, 24)
        row.check:SetPoint("LEFT", 0, 0)
        row.check:SetScript("OnClick", function(check)
            C.options.enabled[key] = check:GetChecked() == true
            C:Refresh()
        end)
        label(row, 31, -5, 160):SetText(source.name)
        row.state = label(row, 195, -5, 529)
        row:SetScript("OnEnter", function()
            self:Tooltip(row)
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    button(self.detail, L.NEW_SESSION, 0, -230, 110, function()
        C:Command("neu")
    end)
    self.soundButton = button(self.detail, L.SOUND_OFF, 117, -230, 85, function()
        C:Command("ton")
    end)
    button(self.detail, "<", 230, -230, 28, function()
        self.preview = math.max(1, (self.preview or C.tracker.level) - 1)
        self:RenderDetails()
    end)
    button(self.detail, ">", 263, -230, 28, function()
        self.preview = math.min(60, (self.preview or C.tracker.level) + 1)
        self:RenderDetails()
    end)
    button(self.detail, L.LIVE_LEVEL, 298, -230, 90, function()
        self.preview = nil
        self:RenderDetails()
    end)
    self.previewLabel = label(self.detail, 405, -236, 300)
    self.scroll = CreateFrame("ScrollFrame", nil, self.detail, "UIPanelScrollFrameTemplate")
    self.scroll:SetPoint("TOPLEFT", 0, -265)
    self.scroll:SetSize(708, 220)
    self.detailChild = CreateFrame("Frame", nil, self.scroll)
    self.detailChild:SetSize(700, 1)
    self.scroll:SetScrollChild(self.detailChild)
    self.detailText = label(self.detailChild, 0, 0, 697)
    self.detailText:SetWordWrap(true)
    self.detailText:SetSpacing(4)
    if not C.options.shown then
        f:Hide()
    end
    self:Layout()
end

function UI:Layout()
    local available = (UIParent:GetHeight() or 900) / C.options.scale - 35
    local height = C.options.expanded and math.min(672, math.max(530, available)) or 126
    self.frame:SetHeight(height)
    self.detail:SetShown(C.options.expanded)
    self.scroll:SetHeight(math.max(100, height - 425))
    self.detailsButton:SetText(C.options.expanded and L.LESS or L.DETAILS)
end
function UI:ToggleDetails()
    C.options.expanded = not C.options.expanded
    self:Layout()
    self:Render()
end
function UI:LearnedCount()
    local n = 0
    for _ in pairs(C.character.learnedFoods) do
        n = n + 1
    end
    return n
end

local function segment(texture, start, length)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", 1 + (BAR_WIDTH - 2) * start, -1)
    texture:SetSize(math.max(0.01, (BAR_WIDTH - 2) * length), 21)
    texture:SetShown(length > 0)
end

function UI:Render()
    if not self.frame or not C.snapshot then
        return
    end
    local t, db, q = C.tracker, C.character, C.quests or { xp = 0, count = 0, unknown = 0 }
    local rate = t:Rate(C.options.window, C.options.minimumSample)
    local eta, played = t:ETA(rate), db.played
    local fraction = t.maximum > 0 and math.min(1, t.xp / t.maximum) or 1
    local projection = M.ProjectQuests(t.level, t.xp, t.maximum, q.xp)
    self.levelTime:SetText(L.LEVEL_TIME .. M.Duration(played and played.level or db.current.online))
    self.sessionTime:SetText(
        L.SESSION_TIME .. M.Duration(db.session.online) .. L.AFK_SHORT .. M.Duration(db.session.afk)
    )
    segment(self.fill, 0, fraction)
    segment(
        self.rested,
        fraction,
        math.min(1 - fraction, t.maximum > 0 and (C.snapshot.rested or 0) / t.maximum or 0)
    )
    segment(self.questFill, fraction, math.min(1 - fraction, t.maximum > 0 and q.xp / t.maximum or 0))
    self.levelLabel:SetText(L.LEVEL_PREFIX .. t.level)
    self.xpLabel:SetText(
        M.Number(t.xp)
            .. " / "
            .. M.Number(t.maximum)
            .. " ("
            .. M.Number(math.max(0, t.maximum - t.xp))
            .. ")"
    )
    local after = projection.levels > 0
            and ("→ L" .. projection.level .. " · " .. M.Decimal(projection.percent) .. " %")
        or ("(" .. M.Decimal(projection.percent) .. " %)")
    self.percentLabel:SetText(M.Decimal(fraction * 100) .. " %  " .. after)
    local estimate = t.level >= 60 and L.MAX_LEVEL
        or (eta and L.ETA_PREFIX .. M.Duration(eta) or L.ETA_COLLECT)
    if rate == 0 and t.level < 60 then
        estimate = L.ETA_EMPTY
    end
    if t.mode ~= "active" then
        estimate = estimate .. L.PAUSED_SUFFIX
    end
    self.estimate:SetText(estimate .. " (" .. M.Number(rate) .. L.ACTIVE_RATE_SUFFIX)
    local restPercent = t.maximum > 0 and (C.snapshot.rested or 0) / t.maximum * 100 or 0
    self.restLabel:SetText(
        L.RESTED_PREFIX .. (C.snapshot.rested and (M.Decimal(restPercent) .. " %") or L.UNKNOWN)
    )
    if q.unavailable then
        self.questLabel:SetText(L.QUEST_XP_UNAVAILABLE)
    else
        self.questLabel:SetText(
            string.format(
                L.QUEST_PREVIEW,
                q.count,
                q.unknown > 0 and "≥ " or "",
                M.Number(q.xp),
                projection.level,
                M.Decimal(projection.percent),
                q.unknown > 0 and L.INCOMPLETE_SUFFIX or ""
            )
        )
    end
    for i, state in ipairs(C.states) do
        local color = colors[state.kind] or colors.info
        local r, g, b =
            tonumber(color:sub(1, 2), 16) / 255,
            tonumber(color:sub(3, 4), 16) / 255,
            tonumber(color:sub(5, 6), 16) / 255
        local icon, row = self.icons[i], self.rows[i]
        icon:SetBackdropBorderColor(r, g, b, 1)
        icon.icon:SetDesaturated(state.kind ~= "active" and state.kind ~= "soon")
        icon.badge:SetText(
            "|cff"
                .. color
                .. (state.key == "sleep" and state.stacks and tostring(state.stacks) .. "/3" or labels[state.kind])
                .. "|r"
        )
        row.check:SetChecked(C.options.enabled[state.key] ~= false)
        row.state:SetText("|cff" .. color .. state.text .. "|r")
    end
    self.summary:SetText(C.diagnostic.xp or (C.snapshot.auraReadable and L.BUFF_HOVER or L.BUFF_RESTRICTED))
    local s = db.session
    self.metrics:SetText(
        L.PLAYED_TOTAL
            .. (played and M.Duration(played.total) or L.REQUESTING)
            .. L.SESSION_ACTIVE
            .. M.Duration(s.active)
            .. L.AFK_METRIC
            .. M.Duration(s.afk)
            .. L.PAUSE_METRIC
            .. M.Duration(s.paused)
            .. L.SESSION_XP
            .. M.Number(s.xp)
            .. L.SESSION_RATE
            .. M.Number(s.active > 0 and s.xp * 3600 / s.active or nil)
            .. L.RATE_NOTE
    )
    self.pauseButton:SetText(C.manualPause and L.RESUME or L.PAUSE)
    self.soundButton:SetText(C.options.sound and L.SOUND_ON or L.SOUND_OFF)
    self:Layout()
    if C.options.expanded then
        self:RenderDetails()
    end
end

function UI:RenderDetails()
    if not self.detailText then
        return
    end
    local level = self.preview or C.tracker.level
    self.previewLabel:SetText(L.SOURCES_LEVEL .. level)
    local lines = {
        L.SOURCES_HEADING,
        L.PREVIEW_NOTE,
    }
    for _, source in ipairs(ns.sources) do
        if level < source.minLevel then
            lines[#lines + 1] = "|cff737b8a" .. source.name .. L.FROM_LEVEL_SUFFIX .. source.minLevel .. "|r"
        elseif level >= 60 then
            lines[#lines + 1] = source.name .. L.LEVELING_OVER
        else
            lines[#lines + 1] = "|cffe4c480" .. source.name .. "|r – " .. source.obtain
        end
    end
    lines[#lines + 1] = L.FOODS_LEVEL .. level .. "|r"
    for _, food in ipairs(ns.foods) do
        if level >= food.level then
            lines[#lines + 1] = C:ItemName(food.id) .. L.ITEM_LEVEL .. food.level .. " · ID " .. food.id
        end
    end
    lines[#lines + 1] = L.FOOD_CATALOG_NOTE
    lines[#lines + 1] = L.HISTORY_HEADING
    lines[#lines + 1] = L.HISTORY_COLUMNS
    lines[#lines + 1] = L.READY_HEADING
    for _, quest in ipairs(C.quests and C.quests.rows or {}) do
        lines[#lines + 1] = quest.title .. " – " .. M.Number(quest.xp) .. " XP"
    end
    lines[#lines + 1] = L.QUEST_PREVIEW_NOTE
    local found = false
    for l = 1, 59 do
        local row = C.character.history[l]
        if row then
            found = true
            if row.skipped then
                lines[#lines + 1] = l .. " → " .. l + 1 .. L.SKIPPED_LEVEL
            else
                local rate = row.active > 0 and row.xp * 3600 / row.active or nil
                lines[#lines + 1] = string.format(
                    "%d → %d: %s / %s / %s / %s%s",
                    l,
                    l + 1,
                    M.Duration(row.gameTime or row.online),
                    M.Duration(row.afk),
                    M.Duration(row.active),
                    M.Number(rate),
                    row.partial and L.PARTIAL_SUFFIX or ""
                )
            end
        end
    end
    if not found then
        lines[#lines + 1] = L.NO_HISTORY
    end
    local current, totals = C.character.current, C.character.totals
    lines[#lines + 1] = L.CURRENT_ACTIVE
        .. M.Duration(current.active)
        .. L.AFK_INLINE
        .. M.Duration(current.afk)
        .. L.PAUSED_INLINE
        .. M.Duration(current.paused)
        .. (current.partial and L.PARTIAL_SUFFIX or "")
    lines[#lines + 1] = L.SINCE_ONLINE
        .. M.Duration(totals.online)
        .. L.AFK_INLINE
        .. M.Duration(totals.afk)
        .. L.ACTIVE_INLINE
        .. M.Duration(totals.active)
        .. L.PAUSED_INLINE
        .. M.Duration(totals.paused)
    lines[#lines + 1] = L.HISTORY_NOTE
    lines[#lines + 1] = L.SETTINGS_HEADING
    lines[#lines + 1] = L.SETTINGS_HELP
    lines[#lines + 1] = L.LIMITS_NOTE
    self.detailText:SetText(table.concat(lines, "\n"))
    self.detailChild:SetHeight(self.detailText:GetStringHeight() + 10)
end
