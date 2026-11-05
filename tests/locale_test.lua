local locales = {
    "enUS",
    "enGB",
    "deDE",
    "frFR",
    "esES",
    "esMX",
    "itIT",
    "ptBR",
    "ptPT",
    "ruRU",
    "koKR",
    "zhCN",
    "zhTW",
    "xxXX",
}
local function load(locale)
    GetLocale = locale and function()
        return locale
    end or nil
    local ns = {}
    for line in io.lines(PROJECT_ROOT .. "/ForeverXPOptimizer/ForeverXPOptimizer.toc") do
        if line:match("%.lua%s*$") then
            local path = line:gsub("\\", "/"):gsub("%s+$", "")
            if path == "Data.lua" then
                break
            end
            assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/" .. path))("ForeverXPOptimizer", ns)
        end
    end
    assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/Model.lua"))("ForeverXPOptimizer", ns)
    return ns
end
local english = load("enUS")
local files = { "enUS", "deDE", "frFR", "esES", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW" }
local keyCount = 0
for _ in pairs(english.L) do
    keyCount = keyCount + 1
end
assert(keyCount >= 140)
for _, code in ipairs(files) do
    local ns = { L = {}, language = code }
    assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/Locales/" .. code .. ".lua"))(
        "ForeverXPOptimizer",
        ns
    )
    for key in pairs(english.L) do
        assert(type(ns.L[key]) == "string" and ns.L[key] ~= "", code .. " missing " .. key)
    end
    for key in pairs(ns.L) do
        assert(english.L[key], code .. " unknown key " .. key)
    end
end
for _, locale in ipairs(locales) do
    local ns = load(locale)
    local L = ns.L
    assert(string.format(L.STACKS_FMT, 2, " · 5:00"))
    assert(string.format(L.DIAGNOSTICS, "70790", "16001", L.READABLE, L.READABLE, 2))
    local quest = string.format(L.QUEST_PREVIEW, 2, "", "1,000", 15, ns.Model.Decimal(50.5), "")
    assert(quest:find("15", 1, true) and quest:find("50", 1, true))
    assert(ns.Model.HasXPText("Expérience |cffffffff5|r %"))
    assert(ns.Model.HasXPText("经验提高5％"))
    assert(ns.Model.HasXPText("Опыт увеличен на 5%"))
    assert(not ns.Model.HasXPText("Critical strike increased by 5%"))
    assert(not ns.Model.HasXPText("Experience increased by 15%"), "15% must not match 5%")
    assert(not ns.Model.HasXPText("Experience increased by 0.5%"), "0.5% must not match 5%")
    if locale == "deDE" then
        assert(L.FOOD == "XP-Essen" and ns.Model.Number(1234567) == "1.234.567")
        assert(ns.Model.Decimal(50.5) == "50,5")
    elseif locale == "frFR" or locale == "ruRU" then
        assert(ns.Model.Number(1234567) == "1 234 567")
    elseif locale == "esMX" then
        assert(ns.Model.Number(1234567) == "1,234,567")
        assert(ns.Model.Decimal(50.5) == "50.5")
    elseif locale == "xxXX" or locale == "enGB" then
        assert(L.FOOD == "XP food")
    end
end
assert(load(nil).L.FOOD == "XP food", "No GetLocale must fall back to English")
local partial = { L = {}, language = "frFR" }
assert(loadfile(PROJECT_ROOT .. "/ForeverXPOptimizer/Locales/enUS.lua"))("ForeverXPOptimizer", partial)
local untouched = partial.L.FOOD
partial.L.PAUSE = "Pause"
assert(partial.L.FOOD == untouched)
for _, key in ipairs({ "STACKS_FMT", "DIAGNOSTICS", "QUEST_PREVIEW" }) do
    local function signature(value)
        local parts = {}
        for token in value:gmatch("%%[ds]") do
            parts[#parts + 1] = token
        end
        return table.concat(parts, ":")
    end
    for _, locale in ipairs(locales) do
        assert(
            signature(load(locale).L[key]) == signature(english.L[key]),
            locale .. " format mismatch: " .. key
        )
    end
end
print(
    "Locale tests passed: " .. keyCount .. " keys, 10 complete languages, locale aliases and English fallback"
)
