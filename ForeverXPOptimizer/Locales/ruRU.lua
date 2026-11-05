local _, ns = ...
if ns.language ~= "ruRU" then
    return
end
local L = ns.L

L.FOOD = "Еда на опыт"
L.SLEEP = "Спальный мешок"
L.RESTED = "Опыт отдыха"
L.TENT = "Палатка"
L.PENDANT = "Подвеска опыта за нежить"
L.LEGACY = "Бонусы наследия"
L.FOOD_HELP =
    "+5% опыта за убийства от подходящей еды. Ешьте не менее 10 секунд. Достаточно одного эффекта."
L.FOOD_GET =
    "Приготовьте или купите еду на опыт, например Herb Baked Egg или Brilliant Smallfish."
L.SLEEP_HELP =
    "До 3 зарядов: по минуте отдыха за каждый. Остаток времени берётся из игры."
L.SLEEP_GET =
    "Цепочка с 14-го уровня: Альянс Westfall (37, 50), Орда Barrens (46, 74). Можно использовать мешки группы."
L.RESTED_HELP =
    "Расходуемый запас бонусного опыта за убийства, без таймера."
L.RESTED_GET =
    "Выходите из игры в тавернах/зонах отдыха или отдыхайте у палатки."
L.TENT_HELP =
    "Пополняет отдых до 5% уровня. Не даёт бонуса, если запас уже выше."
L.TENT_GET =
    "Для установки нужны кожевничество 20 и костёр. Чужие палатки тоже подходят. Перезарядка установки и личного эффекта различается."
L.PENDANT_HELP =
    "+10% опыта за нежить на 5 минут; базовая перезарядка 6 часов."
L.PENDANT_GET =
    "Archmagister's Faceted Pendant; источник базы: Shade of the Archmage, City of Dalaran."
L.LEGACY_HELP =
    "Well Rested: отдых; Gourmand: длительность еды; Field Guide: перезарядка лагеря. Это постоянные бонусы."
L.LEGACY_GET =
    "Откройте наследие (Y). Доступ с первым очком, обычно на 25-м уровне первого персонажа. Другие достижения/персонажи могут открыть его раньше."
L.DISABLED = "Отключено"
L.MAX_LEVEL = "Максимальный уровень"
L.STACKS_FMT = "%d/3 заряда%s"
L.EXPIRING = "Скоро истечёт"
L.FULL_STACKS = "3/3 активно"
L.ACTIVE = "Активно"
L.FROM_LEVEL = "С уровня "
L.RESERVE_UNKNOWN = "Запас недоступен"
L.XP_RESERVE = " ед. опыта в запасе"
L.RESERVE_EMPTY = "Запас исчерпан"
L.REST_UNKNOWN = "Отдых недоступен"
L.REST_ENOUGH = "Отдых уже ≥ 5%"
L.BENEFIT_LOCK = "Эффект недоступен · "
L.REST_AT_TENT = "Отдых у палатки …"
L.PLACEMENT = "Установка · "
L.PLACEMENT_UNKNOWN = "Перезарядка установки недоступна"
L.TENT_READY = "Палатка готова · проверьте личный таймер"
L.FIND_TENT = "Мало отдыха · используйте общую палатку"
L.LEGACY_STATUS = "Отдых / длительность еды · меню Y"
L.AURAS_RESTRICTED = "Данные эффектов ограничены"
L.FOOD_UNVERIFIED = "Еда: связь с опытом не проверена"
L.EATING = "Приём пищи · подождите 10 секунд"
L.MISSING_PREFIX = "Отсутствует · "
L.PORTIONS = " порций"
L.GET_FOOD = "Отсутствует · получите еду на опыт"
L.ITEM_CD_UNKNOWN = "Перезарядка предмета неизвестна"
L.MISSING_READY_IN = "Отсутствует · готово через "
L.SLEEP_READY = "Отсутствует · мешок готов"
L.GET_SLEEP = "Цепочка заданий / мешок группы"
L.GET_PENDANT = "Необязательно · получите подвеску"
L.UNDEAD_READY = "Готово для убийства нежити"
L.CD_UNKNOWN = "Перезарядка неизвестна"
L.READY_IN = "Готово через "
L.USE_UNDEAD = "Нежить в цели · используйте бонус"
L.STATUS_UNKNOWN = "Состояние неизвестно"
L.WARN_SOON = "Скоро истечёт"
L.WARN_STACKS = "Неполные заряды"
L.WARN_MISSING = "Бонус отсутствует"
L.WARN_UNLOCK = "Откройте доступный бонус"
L.XP_UNREADABLE = "Данные опыта недоступны"
L.ITEM_PREFIX = "Предмет "
L.QUEST_PREFIX = "Задание "
L.UNSUPPORTED =
    "Создано для WoW Forever (интерфейс 16001). Этот клиент не поддерживается."
L.NO_GUID = "ID персонажа недоступен; выполните /reload вне боя."
L.LOADED =
    " загружено. /fxp открывает окно; /fxp help показывает команды."
L.SESSION_RESET =
    "Скорость и счётчики сеанса сброшены; история сохранена."
L.ENABLED_SUFFIX = " включено."
L.DISABLED_SUFFIX = " отключено."
L.DIAGNOSTICS = "Сборка %s · Интерфейс %s · Ауры %s · Опыт %s · Изучено %d"
L.READABLE = "доступно"
L.RESTRICTED = "ограничено"
L.COMMANDS =
    "/fxp · hide · pause · reset · sound · scale 1 · warn 60 · level 14 · live · status · position"
L.COMMAND_SOURCE =
    "/fxp source food|sleep|rested|tent|pendant|legacy переключает источник. Подробности: правая кнопка мыши."
L.TAG_SOON = "СКР"
L.TAG_PARTIAL = "ЧАСТ"
L.TAG_MISSING = "НЕТ"
L.TAG_OBTAIN = "ВЗЯТЬ"
L.TAG_LOCKED = "ПОЗЖЕ"
L.TAG_OFF = "ВЫКЛ"
L.FOOD_LEARN =
    "Снова съешьте проверенную еду на опыт для определения нового эффекта."
L.ROW_HELP =
    "Флажок: переключить источник. Правая кнопка: подробности."
L.QUEST_TOOLTIP = "Опыт за сдачу заданий сейчас"
L.BAR_LEGEND =
    "Фиолетовый: опыт · Золотой: готовые задания · Синий: отдых"
L.UNKNOWN = "неизвестно"
L.QUEST_UNAVAILABLE = "Данные заданий недоступны."
L.QUEST_LOWER_BOUND = " записей неполные; сумма — нижняя граница."
L.QUEST_CAVEAT =
    "Прогноз использует текущие награды. Порядок сдачи, эффекты и уровни могут изменить последующие награды."
L.QUEST_RATE_NOTE =
    "Опыт заданий учитывается в скорости только после сдачи."
L.PAUSE = "Пауза"
L.DETAILS = "Детали"
L.NEW_SESSION = "Новый сеанс"
L.SOUND_OFF = "Звук выкл."
L.SOUND_ON = "Звук вкл."
L.LIVE_LEVEL = "Тек. уровень"
L.LESS = "Свернуть"
L.LEVEL_TIME = "Время на уровне: "
L.SESSION_TIME = "Время сеанса: "
L.AFK_SHORT = " · АФК "
L.LEVEL_PREFIX = "Уровень "
L.ETA_PREFIX = "Новый уровень через: "
L.ETA_COLLECT = "Новый уровень: сбор данных"
L.ETA_EMPTY = "Новый уровень: нет опыта в окне"
L.PAUSED_SUFFIX = " · пауза"
L.ACTIVE_RATE_SUFFIX = " опыта/ч активно)"
L.RESTED_PREFIX = "Отдых: "
L.QUEST_XP_UNAVAILABLE = "Готовые задания: опыт недоступен"
L.QUEST_PREVIEW = "Готово: %d заданий · %s%s опыта  →  Уровень %d · %s %%%s"
L.INCOMPLETE_SUFFIX = " · данные неполные"
L.BUFF_HOVER = "Эффекты: наведите на значки"
L.BUFF_RESTRICTED = "Данные ограничены · без ложных тревог"
L.PLAYED_TOTAL = "Всего /played: "
L.REQUESTING = "запрос …"
L.SESSION_ACTIVE = "   ·   Активно: "
L.AFK_METRIC = "   ·   АФК: "
L.PAUSE_METRIC = "   ·   Пауза: "
L.SESSION_XP = "\nОпыт сеанса: "
L.SESSION_RATE = "   ·   Опыт/ч активно (сеанс): "
L.RATE_NOTE =
    "\nПрогноз по активному времени; окно: последние 15 активных минут."
L.RESUME = "Продолжить"
L.SOURCES_LEVEL = "Источники для уровня "
L.SOURCES_HEADING = "|cff58d8b0Доступные источники|r"
L.PREVIEW_NOTE =
    "Прогноз проверяет требования уровня. Предметы и открытия зависят от персонажа."
L.FROM_LEVEL_SUFFIX = ": с уровня "
L.LEVELING_OVER = ": обычная прокачка завершена"
L.FOODS_LEVEL = "\n|cff58d8b0Еда для уровня "
L.ITEM_LEVEL = " · с "
L.FOOD_CATALOG_NOTE =
    "Другая еда определяется по тексту опыта в игре. Student Fodder не даёт бонус опыта."
L.HISTORY_HEADING = "\n|cff58d8b0История уровней|r"
L.HISTORY_COLUMNS =
    "Уровень → следующий: в игре / АФК / активно / опыт за активный час"
L.READY_HEADING = "\n|cff58d8b0Задания для сдачи|r"
L.QUEST_PREVIEW_NOTE =
    "Прогноз использует текущие награды. Порядок, эффекты и уровни могут изменить последующие."
L.SKIPPED_LEVEL = ": пройдено за одно событие опыта"
L.PARTIAL_SUFFIX = " · неполная запись"
L.NO_HISTORY = "Пока нет записанных повышений уровня."
L.CURRENT_ACTIVE = "Запись текущего уровня: активно "
L.AFK_INLINE = ", АФК "
L.PAUSED_INLINE = ", пауза "
L.SINCE_ONLINE = "С начала записи: в игре "
L.ACTIVE_INLINE = ", активно "
L.HISTORY_NOTE =
    "Прошлое АФК и уровни не восстановить. АФК определяется статусом игры."
L.SETTINGS_HEADING = "\n|cff58d8b0Настройки|r"
L.SETTINGS_HELP =
    "/fxp warn 60 · предупреждение, секунд\n/fxp scale 1 · размер 0,65–1,6\n/fxp status · данные и сборка\n/fxp position · сброс позиции"
L.LIMITS_NOTE =
    "Длительность мешка берётся из ауры. Непроверенные ранги наследия и события не считаются отсутствующими временными эффектами."
