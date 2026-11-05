local _, ns = ...
local L = ns.L

ns.VERSION = "0.2.0"
ns.sources = {
    {
        key = "food",
        name = L.FOOD,
        icon = 133906,
        minLevel = 1,
        help = L.FOOD_HELP,
        obtain = L.FOOD_GET,
        url = "https://www.wowhead.com/forever/news/382928",
    },
    {
        key = "sleep",
        name = L.SLEEP,
        icon = 133199,
        minLevel = 14,
        item = 211527,
        help = L.SLEEP_HELP,
        obtain = L.SLEEP_GET,
        url = "https://www.wowhead.com/forever/guide/cozy-sleeping-bag-locations-rewards",
    },
    {
        key = "rested",
        name = L.RESTED,
        icon = 136106,
        minLevel = 1,
        help = L.RESTED_HELP,
        obtain = L.RESTED_GET,
    },
    {
        key = "tent",
        name = L.TENT,
        icon = 133633,
        minLevel = 1,
        item = 279978,
        help = L.TENT_HELP,
        obtain = L.TENT_GET,
        url = "https://www.wowhead.com/forever/item=279978",
    },
    {
        key = "pendant",
        name = L.PENDANT,
        icon = 133280,
        minLevel = 30,
        item = 273049,
        help = L.PENDANT_HELP,
        obtain = L.PENDANT_GET,
        url = "https://www.wowhead.com/forever/item=273049",
    },
    {
        key = "legacy",
        name = L.LEGACY,
        icon = 134400,
        minLevel = 1,
        help = L.LEGACY_HELP,
        obtain = L.LEGACY_GET,
        url = "https://worldofwarcraft.blizzard.com/en-gb/news/24307383/get-to-know-the-world-of-warcraft-forever-legacy-system",
    },
}

-- Confirmed Forever item tooltips; other foods are detected from their live tooltip.
ns.foods = {
    { id = 6290, level = 1, name = "Brilliant Smallfish" },
    { id = 6888, level = 1, name = "Herb Baked Egg" },
    { id = 12224, level = 1, name = "Crispy Bat Wing" },
    { id = 2680, level = 1, name = "Spiced Wolf Meat" },
    { id = 21072, level = 10, name = "Smoked Sagefish" },
    { id = 12218, level = 35, name = "Monster Omelet" },
    { id = 13931, level = 35, name = "Nightfin Soup" },
}
ns.foodByID = {}
for _, food in ipairs(ns.foods) do
    ns.foodByID[food.id] = food
end

-- Visible stat auras belonging to verified nutritious-food spells. Never match
-- every buff called Well Fed: some older dishes have no XP benefit.
ns.foodAuras = { [1249519] = true, [1249520] = true, [1243969] = true }
ns.sleepAuras = { [429959] = true }
ns.pendantAuras = { [1292997] = true, [1293736] = true }
ns.eatingAuras = {
    [433] = true,
    [434] = true,
    [435] = true,
    [1127] = true,
    [1129] = true,
    [1131] = true,
    [5004] = true,
    [5005] = true,
    [5006] = true,
    [10256] = true,
    [27089] = true,
}

-- Original 1–60 curve. UnitXPMax is authoritative for the current level;
-- this table is only needed to account for an award crossing several levels.
ns.xpToNext = {
    400,
    900,
    1400,
    2100,
    2800,
    3600,
    4500,
    5400,
    6500,
    7600,
    8800,
    10100,
    11400,
    12900,
    14400,
    16000,
    17700,
    19400,
    21300,
    23200,
    25200,
    27300,
    29400,
    31700,
    34000,
    36400,
    38900,
    41400,
    44300,
    47400,
    50800,
    54500,
    58600,
    62800,
    67100,
    71600,
    76100,
    80800,
    85700,
    90700,
    95800,
    101000,
    106300,
    111800,
    117500,
    123200,
    129100,
    135100,
    141200,
    147500,
    153900,
    160400,
    167100,
    173900,
    180800,
    187900,
    195000,
    202300,
    209800,
}

ns.defaults = {
    shown = true,
    expanded = false,
    scale = 0.85,
    warning = 60,
    repeatAfter = 300,
    sound = false,
    window = 900,
    minimumSample = 120,
    enabled = {},
    point = "BOTTOM",
    x = 0,
    y = 160,
}
