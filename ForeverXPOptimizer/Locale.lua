local _, ns = ...

-- GetLocale follows the WoW client's text language. English is loaded first,
-- so missing translations and future/unknown locales have a readable fallback.
ns.locale = GetLocale and GetLocale() or "enUS"
local aliases = { enGB = "enUS", esMX = "esES", ptPT = "ptBR" }
local supported = {
    enUS = true,
    deDE = true,
    frFR = true,
    esES = true,
    itIT = true,
    ptBR = true,
    ruRU = true,
    koKR = true,
    zhCN = true,
    zhTW = true,
}
ns.language = aliases[ns.locale] or ns.locale
if not supported[ns.language] then
    ns.language = "enUS"
end
ns.L = {}

local groups = { deDE = ".", esES = ".", itIT = ".", ptBR = ".", frFR = " ", ruRU = " ", ptPT = " " }
ns.groupSeparator = groups[ns.locale] or ","
ns.decimalSeparator = groups[ns.locale] and "," or "."

-- Spell/item IDs and native names remain authoritative. These terms only
-- cover tooltip text and UnitCreatureType, whose API returns localized text.
ns.xpWords = {
    "experience",
    "erfahrung",
    "expérience",
    "experiencia",
    "esperienza",
    "experiência",
    "опыт",
    "Опыт",
    "ОПЫТ",
    "경험치",
    "经验",
    "經驗",
}
local undead = {
    enUS = { "Undead" },
    deDE = { "Untoter", "Untote" },
    frFR = { "Mort-vivant" },
    esES = { "No-muerto", "No muerto" },
    itIT = { "Non Morto", "Non morto" },
    ptBR = { "Morto-vivo" },
    ruRU = { "Нежить" },
    koKR = { "언데드" },
    zhCN = { "亡灵" },
    zhTW = { "不死族", "亡靈" },
}
ns.undeadNames = {}
for _, name in ipairs(undead[ns.language]) do
    ns.undeadNames[name] = true
end
