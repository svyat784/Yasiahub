local bootGetGenv = type(getgenv) == "function" and getgenv or nil
local BootEnv = type(_G) == "table" and _G or {}
if bootGetGenv then
    pcall(function()
        local candidate = bootGetGenv()
        if type(candidate) == "table" then
            BootEnv = candidate
        end
    end)
end

local BootShared = type(shared) == "table" and shared or BootEnv.shared
if type(BootShared) ~= "table" then
    BootShared = {}
end

local function bootstrapValue(newKey, legacyKey, defaultValue)
    local value = BootEnv[newKey]
    if value == nil then
        value = BootEnv[legacyKey]
    end
    if value == nil then
        value = BootShared[newKey]
    end
    if value == nil then
        value = BootShared[legacyKey]
    end
    if value == nil then
        value = defaultValue
    end
    BootEnv[newKey] = value
    BootEnv[legacyKey] = value
    BootShared[newKey] = value
    BootShared[legacyKey] = value
    return value
end

BootEnv.shared = BootShared
shared = BootShared
bootstrapValue("YasiaHubLanguage", "MegaHubLanguage", "ru")
bootstrapValue("YasiaHubTheme", "MegaHubTheme", "Default")
bootstrapValue("YasiaHubQuietLoad", "MegaHubQuietLoad", false)
bootstrapValue("YasiaHubHudEnabled", "MegaHubHudEnabled", false)
bootstrapValue("YasiaHubAutoLoad", "MegaHubAutoLoad", false)
if type(_G) == "table" then
    _G.shared = BootShared
end

local RootEnv = type(_G) == "table" and _G or BootEnv
local SharedFallback = type(shared) == "table" and shared or RootEnv.shared
if type(SharedFallback) ~= "table" then
    SharedFallback = {}
end
RootEnv.shared = SharedFallback
shared = SharedFallback

local nativeGetGenv = type(getgenv) == "function" and getgenv or nil
local function resolveScriptEnv()
    local env = nil
    if nativeGetGenv then
        pcall(function()
            local candidate = nativeGetGenv()
            if type(candidate) == "table" then
                env = candidate
            end
        end)
    end
    if type(env) ~= "table" then
        if type(shared) == "table" then
            env = shared
        elseif type(_G) == "table" then
            env = _G
        else
            env = SharedFallback
        end
    end
    if type(env) ~= "table" then
        env = {}
    end
    return env
end

getgenv = resolveScriptEnv
if type(_G) == "table" then
    _G.getgenv = resolveScriptEnv
    _G.shared = SharedFallback
end

local SharedEnv = resolveScriptEnv()
if type(SharedEnv) == "table" then
    SharedEnv.shared = SharedFallback
end

local function getSharedEnv()
    if type(SharedEnv) ~= "table" then
        SharedEnv = resolveScriptEnv()
    end
    return SharedEnv
end

local HUB_BRAND = "Yasia Hub"
local HUB_TAG = "YasiaHub"
local COMPAT_PREFIX = string.char(77, 101, 103, 97, 72, 117, 98)
local ENV_KEYS = {
    Language = "YasiaHubLanguage",
    Theme = "YasiaHubTheme",
    QuietLoad = "YasiaHubQuietLoad",
    HudEnabled = "YasiaHubHudEnabled",
    AutoLoad = "YasiaHubAutoLoad",
    LegacyLanguage = COMPAT_PREFIX .. "Language",
    LegacyTheme = COMPAT_PREFIX .. "Theme",
    LegacyQuietLoad = COMPAT_PREFIX .. "QuietLoad",
    LegacyHudEnabled = COMPAT_PREFIX .. "HudEnabled",
    LegacyAutoLoad = COMPAT_PREFIX .. "AutoLoad",
}

local function getStoredValue(primaryKey, legacyKey, defaultValue)
    local env = getSharedEnv()
    local value = env[primaryKey]
    if value == nil and legacyKey then
        value = env[legacyKey]
    end
    if value == nil then
        return defaultValue
    end
    return value
end

local function setStoredValue(primaryKey, legacyKey, value)
    local env = getSharedEnv()
    env[primaryKey] = value
    if legacyKey then
        env[legacyKey] = value
    end
end

local function ensureStoredValue(primaryKey, legacyKey, defaultValue)
    local value = getStoredValue(primaryKey, legacyKey, defaultValue)
    setStoredValue(primaryKey, legacyKey, value)
    return value
end

ensureStoredValue(ENV_KEYS.Language, ENV_KEYS.LegacyLanguage, "ru")
ensureStoredValue(ENV_KEYS.Theme, ENV_KEYS.LegacyTheme, "Default")
if getSharedEnv()[ENV_KEYS.QuietLoad] == nil then
    setStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, getStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, false) == true)
end
ensureStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, false)
if getSharedEnv()[ENV_KEYS.HudEnabled] == nil then
    setStoredValue(ENV_KEYS.HudEnabled, ENV_KEYS.LegacyHudEnabled, getStoredValue(ENV_KEYS.HudEnabled, ENV_KEYS.LegacyHudEnabled, false) == true)
end
ensureStoredValue(ENV_KEYS.HudEnabled, ENV_KEYS.LegacyHudEnabled, false)
if getSharedEnv()[ENV_KEYS.AutoLoad] == nil then
    setStoredValue(ENV_KEYS.AutoLoad, ENV_KEYS.LegacyAutoLoad, getStoredValue(ENV_KEYS.AutoLoad, ENV_KEYS.LegacyAutoLoad, false) == true)
end
ensureStoredValue(ENV_KEYS.AutoLoad, ENV_KEYS.LegacyAutoLoad, false)

local Translations = {
    Current = tostring(getStoredValue(ENV_KEYS.Language, ENV_KEYS.LegacyLanguage, "ru")),
    ru = {
        title = HUB_BRAND .. " | Premium",
        sub = "Оптимизация и большой набор инструментов",
        category_main = "Основное",
        category_combat = "BOY / AIM",
        category_world = "Мир / Фан",
        category_systems = "Системы",
        main = "Главная",
        visuals = "Визуалы",
        move = "Движение",
        combat = "Бой",
        aimbot = "AIMBOT",
        misc = "Разное",
        fun = "Фан",
        util = "Утилиты",
        farm = "Фарм",
        tp = "Телепорты",
        admin = "ADMIN",
        car = "Транспорт",
        touch_fling = "Touch Fling",
        anti_fling = "ANTI FLING",
        gall = "Галерея",
        cloud = "Облако",
        settings = "Настройки",
        oa_core = "Ядро аимбота",
        oa_enable = "Включить аимбот",
        oa_mode = "Режим",
        oa_part = "Цель (Part)",
        oa_silent = "Шанс Silent Aim %",
        oa_offset = "Смещение / Offset",
        oa_checks = "Проверки",
        oa_fov_vis = "FOV и визуал",
        oa_reset = "Сбросить состояние",
        lang_sel = "Выбор языка",
        theme_sel = "Акцентная тема",
        reload_hint = "Статичные подписи вкладок обновятся после перезапуска скрипта.",
        settings_info = "Информация",
        settings_info_text = "Тема применяется сразу. Для полного обновления названий вкладок просто перезапусти скрипт после выбора языка.",
        settings_show_notice = "Показывать уведомление",
        status_aim = "НАВОДКА",
        status_armed = "ГОТОВ",
        status_off = "ВЫКЛ",
        mode = "Режим",
        target = "Цель",
        msg_loaded = HUB_BRAND .. " успешно загружен!",
        msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. Новые вкладки добавлены.",
        msg_lang_changed = "Язык переключён на русский.",
        msg_theme_changed = "Тема применена",
        tp_mouse = "Телепорт к курсору",
        click_tp = "Клик-ТП (ЛКМ по миру)",
        tp_bind_button = "Назначить клавишу TP",
        tp_bind_status = "Текущая клавиша TP: %s",
        tp_bind_wait_title = "Назначение клавиши TP",
        tp_bind_wait_desc = "Нажмите клавишу или кнопку мыши. Esc — отмена.",
        tp_bind_set_title = "Клавиша TP изменена",
        tp_bind_set_desc = "Новый бинд: %s",
        tp_bind_cancel_desc = "Назначение клавиши отменено.",
        bring_all = "Подтянуть всех игроков",
        aim_key = "Клавиша аима",
        spin_key = "Клавиша SpinBot",
        trigger_key = "Клавиша TriggerBot",
        yes = "да",
        no = "нет",
        aimbot_caps = "Мышь: %s | Silent: %s",
        aimbot_bind_hint = "Режим клавиши задаётся в самом виджете keybind: Toggle / Hold / Always."
    },
    uk = {
        title = HUB_BRAND .. " | PREMIUM",
        sub = "Оптимізація та великий набір інструментів",
        category_main = "Основне",
        category_combat = "BIY / AIM",
        category_world = "Світ / Фан",
        category_systems = "Системи",
        main = "Головна",
        visuals = "Візуали",
        move = "Рух",
        combat = "Бій",
        aimbot = "AIMBOT",
        misc = "Різне",
        fun = "Фан",
        util = "Утиліти",
        farm = "Фарм",
        tp = "Телепорти",
        admin = "ADMIN",
        car = "Транспорт",
        touch_fling = "Touch Fling",
        anti_fling = "ANTI FLING",
        gall = "Галерея",
        cloud = "Хмара",
        settings = "Налаштування",
        oa_core = "Ядро аімбота",
        oa_enable = "Увімкнути аімбот",
        oa_mode = "Режим",
        oa_part = "Ціль (Part)",
        oa_silent = "Шанс Silent Aim %",
        oa_offset = "Зміщення / Offset",
        oa_checks = "Перевірки",
        oa_fov_vis = "FOV та візуал",
        oa_reset = "Скинути стан",
        lang_sel = "Вибір мови",
        theme_sel = "Акцентна тема",
        reload_hint = "Статичні підписи вкладок оновляться після перезапуску скрипта.",
        settings_info = "Інформація",
        settings_info_text = "Тема застосовується одразу. Для повного оновлення назв вкладок просто перезапусти скрипт після вибору мови.",
        settings_show_notice = "Показувати сповіщення",
        status_aim = "НАВОДКА",
        status_armed = "ГОТОВИЙ",
        status_off = "ВИМК",
        mode = "Режим",
        target = "Ціль",
        msg_loaded = HUB_BRAND .. " успішно завантажено!",
        msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. Нові вкладки додано.",
        msg_lang_changed = "Мову перемкнено на українську.",
        msg_theme_changed = "Тему застосовано",
        tp_mouse = "Телепорт до курсора",
        click_tp = "Клік-ТП (ЛКМ по світу)",
        tp_bind_button = "Призначити клавішу TP",
        tp_bind_status = "Поточна клавіша TP: %s",
        tp_bind_wait_title = "Призначення клавіші TP",
        tp_bind_wait_desc = "Натисніть клавішу або кнопку миші. Esc — скасування.",
        tp_bind_set_title = "Клавішу TP змінено",
        tp_bind_set_desc = "Новий бінд: %s",
        tp_bind_cancel_desc = "Призначення клавіші скасовано.",
        bring_all = "Підтягнути всіх гравців",
        aim_key = "Клавіша аіму",
        spin_key = "Клавіша SpinBot",
        trigger_key = "Клавіша TriggerBot",
        yes = "так",
        no = "ні",
        aimbot_caps = "Миша: %s | Silent: %s",
        aimbot_bind_hint = "Режим клавіші задається у самому віджеті keybind: Toggle / Hold / Always."
    },
    en = {
        title = HUB_BRAND .. " | Premium",
        sub = "Optimization & a huge tools pack",
        category_main = "Core",
        category_combat = "Combat / Aim",
        category_world = "World / Fun",
        category_systems = "Systems",
        main = "Main",
        visuals = "Visuals",
        move = "Movement",
        combat = "Combat",
        aimbot = "Aimbot",
        misc = "Misc",
        fun = "Fun",
        util = "Utility",
        farm = "Farm",
        tp = "Teleports",
        admin = "Admin",
        car = "Vehicles",
        touch_fling = "Touch Fling",
        anti_fling = "Anti Fling",
        gall = "Gallery",
        cloud = "Cloud",
        settings = "Settings",
        oa_core = "Aimbot Core",
        oa_enable = "Enable Aimbot",
        oa_mode = "Mode",
        oa_part = "Aim Part",
        oa_silent = "Silent Aim Chance %",
        oa_offset = "Offset Settings",
        oa_checks = "Checks",
        oa_fov_vis = "FOV / Visuals",
        oa_reset = "Reset State",
        lang_sel = "Language",
        theme_sel = "Accent Theme",
        reload_hint = "Static tab labels refresh after rerunning the script.",
        settings_info = "Info",
        settings_info_text = "Theme changes apply immediately. Rerun the script after choosing a language to refresh all tab names.",
        settings_show_notice = "Show Notification",
        status_aim = "AIMING",
        status_armed = "armed",
        status_off = "OFF",
        mode = "Mode",
        target = "Target",
        msg_loaded = HUB_BRAND .. " loaded successfully!",
        msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. New tabs added!",
        msg_lang_changed = "Language switched to English.",
        msg_theme_changed = "Theme applied",
        tp_mouse = "Teleport to Cursor",
        click_tp = "Click TP (LMB on world)",
        tp_bind_button = "Set TP Key",
        tp_bind_status = "Current TP key: %s",
        tp_bind_wait_title = "Set TP Key",
        tp_bind_wait_desc = "Press a key or mouse button. Esc to cancel.",
        tp_bind_set_title = "TP Key Updated",
        tp_bind_set_desc = "New bind: %s",
        tp_bind_cancel_desc = "Bind selection cancelled.",
        bring_all = "Bring All Players",
        aim_key = "Aim Key",
        spin_key = "Spin Key",
        trigger_key = "Trigger Key",
        yes = "yes",
        no = "no",
        aimbot_caps = "Mouse: %s | Silent: %s",
        aimbot_bind_hint = "The bind mode is set inside the keybind widget itself: Toggle / Hold / Always."
    }
}

Translations.ru = {
    title = HUB_BRAND .. " | Premium",
    sub = "Оптимизация и большой набор инструментов",
    category_main = "Основное",
    category_combat = "Бой / Aim",
    category_world = "Мир / Фан",
    category_systems = "Системы",
    main = "Главная",
    visuals = "Визуалы",
    move = "Движение",
    combat = "Бой",
    aimbot = "Aimbot",
    misc = "Разное",
    fun = "Фан",
    util = "Утилиты",
    farm = "Фарм",
    tp = "Телепорты",
    admin = "Админ",
    car = "Транспорт",
    touch_fling = "Touch Fling",
    anti_fling = "Anti Fling",
    gall = "Галерея",
    cloud = "Облако",
    settings = "Настройки",
    oa_core = "Ядро аимбота",
    oa_enable = "Включить аимбот",
    oa_mode = "Режим",
    oa_part = "Часть цели",
    oa_silent = "Шанс Silent Aim %",
    oa_offset = "Смещение / Offset",
    oa_checks = "Проверки",
    oa_fov_vis = "FOV и визуал",
    oa_reset = "Сбросить состояние",
    lang_sel = "Выбор языка",
    theme_sel = "Акцентная тема",
    reload_hint = "Статичные подписи вкладок обновятся после перезапуска скрипта.",
    settings_info = "Информация",
    settings_info_text = "Тема применяется сразу. Чтобы обновить названия вкладок и других статичных элементов, просто перезапусти скрипт после смены языка.",
    settings_show_notice = "Показывать уведомление",
    status_aim = "НАВОДКА",
    status_armed = "ГОТОВ",
    status_off = "ВЫКЛ",
    mode = "Режим",
    target = "Цель",
    msg_loaded = HUB_BRAND .. " успешно загружен!",
    msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. Новые вкладки добавлены.",
    msg_lang_changed = "Язык переключён на русский.",
    msg_theme_changed = "Тема применена",
    tp_mouse = "Телепорт к курсору",
    click_tp = "Клик-ТП (ЛКМ по миру)",
    tp_bind_button = "Назначить клавишу TP",
    tp_bind_status = "Текущая клавиша TP: %s",
    tp_bind_wait_title = "Назначение клавиши TP",
    tp_bind_wait_desc = "Нажмите клавишу или кнопку мыши. Esc для отмены.",
    tp_bind_set_title = "Клавиша TP изменена",
    tp_bind_set_desc = "Новый бинд: %s",
    tp_bind_cancel_desc = "Назначение клавиши отменено.",
    bring_all = "Подтянуть всех игроков",
    aim_key = "Клавиша аима",
    spin_key = "Клавиша SpinBot",
    trigger_key = "Клавиша TriggerBot",
    yes = "да",
    no = "нет",
    aimbot_caps = "Мышь: %s | Silent: %s",
    aimbot_bind_hint = "Режим бинда задаётся прямо в виджете keybind: Toggle / Hold / Always."
}

Translations.uk = {
    title = HUB_BRAND .. " | Premium",
    sub = "Оптимізація та великий набір інструментів",
    category_main = "Основне",
    category_combat = "Бій / Aim",
    category_world = "Світ / Фан",
    category_systems = "Системи",
    main = "Головна",
    visuals = "Візуали",
    move = "Рух",
    combat = "Бій",
    aimbot = "Aimbot",
    misc = "Різне",
    fun = "Фан",
    util = "Утиліти",
    farm = "Фарм",
    tp = "Телепорти",
    admin = "Адмін",
    car = "Транспорт",
    touch_fling = "Touch Fling",
    anti_fling = "Anti Fling",
    gall = "Галерея",
    cloud = "Хмара",
    settings = "Налаштування",
    oa_core = "Ядро аімбота",
    oa_enable = "Увімкнути аімбот",
    oa_mode = "Режим",
    oa_part = "Частина цілі",
    oa_silent = "Шанс Silent Aim %",
    oa_offset = "Зміщення / Offset",
    oa_checks = "Перевірки",
    oa_fov_vis = "FOV та візуал",
    oa_reset = "Скинути стан",
    lang_sel = "Вибір мови",
    theme_sel = "Акцентна тема",
    reload_hint = "Статичні підписи вкладок оновляться після перезапуску скрипта.",
    settings_info = "Інформація",
    settings_info_text = "Тема застосовується одразу. Щоб оновити назви вкладок та інших статичних елементів, просто перезапусти скрипт після зміни мови.",
    settings_show_notice = "Показувати сповіщення",
    status_aim = "НАВЕДЕННЯ",
    status_armed = "ГОТОВИЙ",
    status_off = "ВИМК",
    mode = "Режим",
    target = "Ціль",
    msg_loaded = HUB_BRAND .. " успішно завантажено!",
    msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. Нові вкладки додано.",
    msg_lang_changed = "Мову перемкнено на українську.",
    msg_theme_changed = "Тему застосовано",
    tp_mouse = "Телепорт до курсора",
    click_tp = "Клік-ТП (ЛКМ по світу)",
    tp_bind_button = "Призначити клавішу TP",
    tp_bind_status = "Поточна клавіша TP: %s",
    tp_bind_wait_title = "Призначення клавіші TP",
    tp_bind_wait_desc = "Натисни клавішу або кнопку миші. Esc для скасування.",
    tp_bind_set_title = "Клавішу TP змінено",
    tp_bind_set_desc = "Новий бінд: %s",
    tp_bind_cancel_desc = "Призначення клавіші скасовано.",
    bring_all = "Підтягнути всіх гравців",
    aim_key = "Клавіша аіму",
    spin_key = "Клавіша SpinBot",
    trigger_key = "Клавіша TriggerBot",
    yes = "так",
    no = "ні",
    aimbot_caps = "Миша: %s | Silent: %s",
    aimbot_bind_hint = "Режим бінда задається прямо у віджеті keybind: Toggle / Hold / Always."
}

Translations.ru = {
    title = HUB_BRAND .. " | Premium",
    sub = "Оптимизация и большой набор инструментов",
    category_main = "Основное",
    category_combat = "Бой / Aim",
    category_world = "Мир / Фан",
    category_systems = "Системы",
    main = "Главная",
    visuals = "Визуалы",
    move = "Движение",
    combat = "Бой",
    aimbot = "Aimbot",
    misc = "Разное",
    fun = "Фан",
    util = "Утилиты",
    farm = "Фарм",
    tp = "Телепорты",
    admin = "Админ",
    car = "Транспорт",
    touch_fling = "Touch Fling",
    anti_fling = "Anti Fling",
    gall = "Галерея",
    cloud = "Облако",
    settings = "Настройки",
    oa_core = "Ядро аимбота",
    oa_enable = "Включить аимбот",
    oa_mode = "Режим",
    oa_part = "Часть цели",
    oa_silent = "Шанс Silent Aim %",
    oa_offset = "Смещение / Offset",
    oa_checks = "Проверки",
    oa_fov_vis = "FOV и визуал",
    oa_reset = "Сбросить состояние",
    lang_sel = "Выбор языка",
    theme_sel = "Акцентная тема",
    reload_hint = "Статичные подписи вкладок обновятся после перезапуска скрипта.",
    settings_info = "Информация",
    settings_info_text = "Тема применяется сразу. Чтобы обновить названия вкладок и другие статичные элементы, просто перезапусти скрипт после смены языка.",
    settings_show_notice = "Показать уведомление",
    status_aim = "НАВОДКА",
    status_armed = "ГОТОВ",
    status_off = "ВЫКЛ",
    mode = "Режим",
    target = "Цель",
    msg_loaded = HUB_BRAND .. " успешно загружен!",
    msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. Новые вкладки и инструменты добавлены.",
    msg_lang_changed = "Язык переключён на русский.",
    msg_theme_changed = "Тема применена",
    tp_mouse = "Телепорт к курсору",
    click_tp = "Click TP (ЛКМ по миру)",
    tp_bind_button = "Назначить клавишу TP",
    tp_bind_status = "Текущая клавиша TP: %s",
    tp_bind_wait_title = "Назначение клавиши TP",
    tp_bind_wait_desc = "Нажмите клавишу или кнопку мыши. Esc для отмены.",
    tp_bind_set_title = "Клавиша TP изменена",
    tp_bind_set_desc = "Новый бинд: %s",
    tp_bind_cancel_desc = "Назначение клавиши отменено.",
    bring_all = "Подтянуть всех игроков",
    aim_key = "Клавиша аима",
    spin_key = "Клавиша SpinBot",
    trigger_key = "Клавиша TriggerBot",
    yes = "да",
    no = "нет",
    aimbot_caps = "Мышь: %s | Silent: %s",
    aimbot_bind_hint = "Режим бинда задаётся прямо в самом keybind-виджете: Toggle / Hold / Always."
}

Translations.uk = {
    title = HUB_BRAND .. " | Premium",
    sub = "Оптимізація та великий набір інструментів",
    category_main = "Основне",
    category_combat = "Бій / Aim",
    category_world = "Світ / Фан",
    category_systems = "Системи",
    main = "Головна",
    visuals = "Візуали",
    move = "Рух",
    combat = "Бій",
    aimbot = "Aimbot",
    misc = "Різне",
    fun = "Фан",
    util = "Утиліти",
    farm = "Фарм",
    tp = "Телепорти",
    admin = "Адмін",
    car = "Транспорт",
    touch_fling = "Touch Fling",
    anti_fling = "Anti Fling",
    gall = "Галерея",
    cloud = "Хмара",
    settings = "Налаштування",
    oa_core = "Ядро аімбота",
    oa_enable = "Увімкнути аімбот",
    oa_mode = "Режим",
    oa_part = "Частина цілі",
    oa_silent = "Шанс Silent Aim %",
    oa_offset = "Зміщення / Offset",
    oa_checks = "Перевірки",
    oa_fov_vis = "FOV та візуал",
    oa_reset = "Скинути стан",
    lang_sel = "Вибір мови",
    theme_sel = "Акцентна тема",
    reload_hint = "Статичні підписи вкладок оновляться після перезапуску скрипта.",
    settings_info = "Інформація",
    settings_info_text = "Тема застосовується одразу. Щоб оновити назви вкладок та інші статичні елементи, просто перезапусти скрипт після зміни мови.",
    settings_show_notice = "Показати сповіщення",
    status_aim = "НАВОДКА",
    status_armed = "ГОТОВИЙ",
    status_off = "ВИМК",
    mode = "Режим",
    target = "Ціль",
    msg_loaded = HUB_BRAND .. " успішно завантажено!",
    msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. Нові вкладки та інструменти додано.",
    msg_lang_changed = "Мову переключено на українську.",
    msg_theme_changed = "Тему застосовано",
    tp_mouse = "Телепорт до курсора",
    click_tp = "Click TP (ЛКМ по світу)",
    tp_bind_button = "Призначити клавішу TP",
    tp_bind_status = "Поточна клавіша TP: %s",
    tp_bind_wait_title = "Призначення клавіші TP",
    tp_bind_wait_desc = "Натисніть клавішу або кнопку миші. Esc для скасування.",
    tp_bind_set_title = "Клавішу TP змінено",
    tp_bind_set_desc = "Новий бінд: %s",
    tp_bind_cancel_desc = "Призначення клавіші скасовано.",
    bring_all = "Підтягнути всіх гравців",
    aim_key = "Клавіша аіму",
    spin_key = "Клавіша SpinBot",
    trigger_key = "Клавіша TriggerBot",
    yes = "так",
    no = "ні",
    aimbot_caps = "Миша: %s | Silent: %s",
    aimbot_bind_hint = "Режим бінда задається прямо у самому keybind-віджеті: Toggle / Hold / Always."
}

Translations.en = {
    title = HUB_BRAND .. " | Premium",
    sub = "Optimization and a large tools pack",
    category_main = "Core",
    category_combat = "Combat / Aim",
    category_world = "World / Fun",
    category_systems = "Systems",
    main = "Main",
    visuals = "Visuals",
    move = "Movement",
    combat = "Combat",
    aimbot = "Aimbot",
    misc = "Misc",
    fun = "Fun",
    util = "Utility",
    farm = "Farm",
    tp = "Teleports",
    admin = "Admin",
    car = "Vehicles",
    touch_fling = "Touch Fling",
    anti_fling = "Anti Fling",
    gall = "Gallery",
    cloud = "Cloud",
    settings = "Settings",
    oa_core = "Aimbot Core",
    oa_enable = "Enable Aimbot",
    oa_mode = "Mode",
    oa_part = "Aim Part",
    oa_silent = "Silent Aim Chance %",
    oa_offset = "Offset Settings",
    oa_checks = "Checks",
    oa_fov_vis = "FOV / Visuals",
    oa_reset = "Reset State",
    lang_sel = "Language",
    theme_sel = "Accent Theme",
    reload_hint = "Static tab labels refresh after rerunning the script.",
    settings_info = "Info",
    settings_info_text = "Theme changes apply immediately. Rerun the script after choosing a language to refresh all static tab titles.",
    settings_show_notice = "Show Notification",
    status_aim = "AIMING",
    status_armed = "ARMED",
    status_off = "OFF",
    mode = "Mode",
    target = "Target",
    msg_loaded = HUB_BRAND .. " loaded successfully!",
    msg_loaded_desc = "Touch Fling, Anti Fling, Vehicles, ESP, Fly, Cloud Scripts. New tabs and tools added.",
    msg_lang_changed = "Language switched to English.",
    msg_theme_changed = "Theme applied",
    tp_mouse = "Teleport to Cursor",
    click_tp = "Click TP (LMB on world)",
    tp_bind_button = "Set TP Key",
    tp_bind_status = "Current TP key: %s",
    tp_bind_wait_title = "Set TP Key",
    tp_bind_wait_desc = "Press a key or mouse button. Esc to cancel.",
    tp_bind_set_title = "TP Key Updated",
    tp_bind_set_desc = "New bind: %s",
    tp_bind_cancel_desc = "Bind selection cancelled.",
    bring_all = "Bring All Players",
    aim_key = "Aim Key",
    spin_key = "Spin Key",
    trigger_key = "Trigger Key",
    yes = "yes",
    no = "no",
    aimbot_caps = "Mouse: %s | Silent: %s",
    aimbot_bind_hint = "The bind mode is set inside the keybind widget itself: Toggle / Hold / Always."
}

if not Translations[Translations.Current] then
    Translations.Current = "ru"
end

local function T(key)
    local current = Translations[Translations.Current] or Translations.en or {}
    local fallback = Translations.en or {}
    return current[key] or fallback[key] or key
end

local function TF(key, ...)
    local pattern = T(key)
    local ok, formatted = pcall(string.format, pattern, ...)
    return ok and formatted or pattern
end

function TL(ruValue, ukValue, enValue)
    if Translations.Current == "uk" then
        return ukValue or enValue or ruValue
    end
    if Translations.Current == "ru" then
        return ruValue or enValue or ukValue
    end
    return enValue or ruValue or ukValue
end

local ThemeAccents = {
    Default = Color3.fromRGB(92, 144, 255),
    Aqua = Color3.fromRGB(0, 255, 255),
    Blood = Color3.fromRGB(200, 0, 0),
    Emerald = Color3.fromRGB(0, 200, 100),
    Gold = Color3.fromRGB(255, 200, 0),
    Midnight = Color3.fromRGB(45, 45, 60),
    Sunset = Color3.fromRGB(255, 124, 88),
    Ice = Color3.fromRGB(112, 198, 255),
    Mint = Color3.fromRGB(78, 224, 184),
    Rose = Color3.fromRGB(255, 110, 158),
    Steel = Color3.fromRGB(124, 146, 178),
}

local ThemeGradients = {
    Default = Color3.fromRGB(145, 181, 255),
    Aqua = Color3.fromRGB(120, 255, 255),
    Blood = Color3.fromRGB(255, 85, 85),
    Emerald = Color3.fromRGB(80, 255, 170),
    Gold = Color3.fromRGB(255, 225, 120),
    Midnight = Color3.fromRGB(90, 90, 120),
    Sunset = Color3.fromRGB(255, 174, 120),
    Ice = Color3.fromRGB(186, 231, 255),
    Mint = Color3.fromRGB(151, 255, 219),
    Rose = Color3.fromRGB(255, 168, 196),
    Steel = Color3.fromRGB(179, 194, 214),
}

local YasiaHubSettings = {
    Theme = ThemeAccents[tostring(getStoredValue(ENV_KEYS.Theme, ENV_KEYS.LegacyTheme, "Default"))] and tostring(getStoredValue(ENV_KEYS.Theme, ENV_KEYS.LegacyTheme, "Default")) or "Default",
}

local StubUiState = {
    Root = nil,
    ReasonLabel = nil,
    Created = false,
    Reason = "",
}

local function updateStubReason(reason)
    local safeReason = tostring(reason or "")
    if safeReason == "" then
        safeReason = TL(
            "Причина не получена. Проверь доступ к UI-библиотеке и функциям executor.",
            "Причину не отримано. Перевір доступ до UI-бібліотеки та функцій executor.",
            "No reason received. Check the UI library access and executor functions."
        )
    end
    StubUiState.Reason = safeReason
    if StubUiState.ReasonLabel then
        pcall(function()
            StubUiState.ReasonLabel.Text = safeReason
        end)
    end
end

local function ensureStubGui(reason)
    updateStubReason(reason)
    if StubUiState.Created then
        return
    end
    StubUiState.Created = true

    pcall(function()
        local holder = nil

        if type(gethui) == "function" then
            local ok, result = pcall(gethui)
            if ok and result then
                holder = result
            end
        end

        if not holder and game and type(game.GetService) == "function" then
            local coreOk, coreGui = pcall(function()
                return game:GetService("CoreGui")
            end)
            if coreOk and coreGui then
                holder = coreGui
            end
        end

        if not holder and game and type(game.GetService) == "function" then
            local playersOk, players = pcall(function()
                return game:GetService("Players")
            end)
            if playersOk and players and players.LocalPlayer then
                local playerGuiOk, playerGui = pcall(function()
                    return players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                end)
                if playerGuiOk and playerGui then
                    holder = playerGui
                end
            end
        end

        if not holder then
            return
        end

        local gui = Instance.new("ScreenGui")
        gui.Name = HUB_TAG .. "_FallbackGui"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function()
            gui.IgnoreGuiInset = true
        end)
        pcall(function()
            gui.DisplayOrder = 2147483600
        end)
        gui.Parent = holder

        local frame = Instance.new("Frame")
        frame.Name = "Window"
        frame.Size = UDim2.new(0, 420, 0, 180)
        frame.Position = UDim2.new(0.5, -210, 0.5, -90)
        frame.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local stroke = Instance.new("UIStroke")
        stroke.Color = ThemeAccents.Default
        stroke.Thickness = 1.5
        stroke.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -24, 0, 28)
        title.Position = UDim2.new(0, 12, 0, 10)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Text = HUB_BRAND .. " | UI Fallback"
        title.Parent = frame

        local body = Instance.new("TextLabel")
        body.Name = "Body"
        body.BackgroundTransparency = 1
        body.Size = UDim2.new(1, -24, 0, 54)
        body.Position = UDim2.new(0, 12, 0, 42)
        body.Font = Enum.Font.Gotham
        body.TextSize = 13
        body.TextWrapped = true
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.TextColor3 = Color3.fromRGB(214, 219, 230)
        body.Text = TL(
            "Основная UI-библиотека не загрузилась, поэтому полноценное окно не создалось. Ниже показана причина, чтобы было проще понять, что именно сломалось.",
            "Основна UI-бібліотека не завантажилась, тому повноцінне вікно не створилося. Нижче показана причина, щоб було простіше зрозуміти, що саме зламалося.",
            "The main UI library did not load, so the full window could not be created. The reason is shown below to make the failure easier to debug."
        )
        body.Parent = frame

        local reasonTitle = Instance.new("TextLabel")
        reasonTitle.Name = "ReasonTitle"
        reasonTitle.BackgroundTransparency = 1
        reasonTitle.Size = UDim2.new(1, -24, 0, 20)
        reasonTitle.Position = UDim2.new(0, 12, 0, 102)
        reasonTitle.Font = Enum.Font.GothamBold
        reasonTitle.TextSize = 13
        reasonTitle.TextXAlignment = Enum.TextXAlignment.Left
        reasonTitle.TextColor3 = ThemeAccents.Default
        reasonTitle.Text = TL("Причина:", "Причина:", "Reason:")
        reasonTitle.Parent = frame

        local reasonLabel = Instance.new("TextLabel")
        reasonLabel.Name = "Reason"
        reasonLabel.BackgroundTransparency = 1
        reasonLabel.Size = UDim2.new(1, -24, 0, 44)
        reasonLabel.Position = UDim2.new(0, 12, 0, 124)
        reasonLabel.Font = Enum.Font.Code
        reasonLabel.TextSize = 12
        reasonLabel.TextWrapped = true
        reasonLabel.TextXAlignment = Enum.TextXAlignment.Left
        reasonLabel.TextYAlignment = Enum.TextYAlignment.Top
        reasonLabel.TextColor3 = Color3.fromRGB(255, 203, 203)
        reasonLabel.Text = StubUiState.Reason
        reasonLabel.Parent = frame

        StubUiState.Root = gui
        StubUiState.ReasonLabel = reasonLabel
    end)
end

local function createUiStub(reason)
    ensureStubGui(reason)

    local function newElement()
        local content = Instance.new("Frame")
        local element = {
            Items = {
                Content = {
                    Instance = content
                }
            }
        }

        function element:Category()
            return self
        end

        function element:TabDivider()
            return self
        end

        function element:Window()
            return newElement()
        end

        function element:Page()
            return newElement()
        end

        function element:Section()
            return newElement()
        end

        function element:Button()
            return newElement()
        end

        function element:Toggle(config)
            local widget = newElement()
            widget.Value = config and config.Default or false
            return widget
        end

        function element:Slider(config)
            local widget = newElement()
            widget.Value = config and config.Default or 0
            return widget
        end

        function element:Dropdown(config)
            local widget = newElement()
            widget.Value = config and config.Default or nil
            return widget
        end

        function element:Textbox(config)
            local widget = newElement()
            widget.Value = config and (config.Default or config.Placeholder) or ""
            return widget
        end

        function element:Colorpicker(config)
            local widget = newElement()
            widget.Value = config and config.Default or nil
            return widget
        end

        function element:Keybind(config)
            local widget = newElement()
            widget.Value = config and config.Default or nil
            return widget
        end

        function element:Label(text)
            local widget = newElement()
            widget.Value = text
            return widget
        end

        function element:Set(value)
            self.Value = value
            return self
        end

        function element:SetText(value)
            self.Value = value
            return self
        end

        function element:Refresh(values)
            self.Values = values
            return self
        end

        function element:SetAccent()
            return self
        end

        return setmetatable(element, {
            __index = function(_, key)
                if key == "Notification" then
                    return function(_, payload)
                        if type(payload) == "table" then
                            print("[" .. HUB_TAG .. "]", tostring(payload.Title or HUB_BRAND), tostring(payload.Description or ""))
                        end
                    end
                end
                return function()
                    return newElement()
                end
            end
        })
    end

    return newElement()
end

local function compileChunk(source, chunkName)
    local loader = type(loadstring) == "function" and loadstring or type(load) == "function" and load or nil
    if not loader then
        return nil, "loadstring/load is unavailable"
    end
    local ok, chunkOrErr = pcall(loader, source, chunkName)
    if not ok then
        return nil, chunkOrErr
    end
    if type(chunkOrErr) ~= "function" then
        return nil, "compiled chunk is not callable"
    end
    return chunkOrErr
end

local function executeLibrarySource(source, chunkName)
    local chunk, compileErr = compileChunk(source, chunkName)
    if not chunk then
        return nil, compileErr
    end
    local ok, result = pcall(chunk)
    if not ok then
        return nil, result
    end
    if type(result) ~= "table" then
        return nil, "library chunk returned " .. type(result)
    end
    return result
end

local function fetchRemoteSource(url)
    local source = nil
    pcall(function()
        if type(game.HttpGet) == "function" then
            source = game:HttpGet(url)
        end
    end)
    if type(source) ~= "string" or source == "" then
        pcall(function()
            source = game:GetService("HttpService"):GetAsync(url, true)
        end)
    end
    return source
end

local function loadLibraryFromLocalFiles()
    local candidates = {
        "mentality_library_tmp.lua",
        "../mentality_library_tmp.lua",
        "getebt/../mentality_library_tmp.lua",
        "C:/Users/Svyatoslav/Downloads/python/mentality_library_tmp.lua",
        "C:\\Users\\Svyatoslav\\Downloads\\python\\mentality_library_tmp.lua",
    }
    local lastError = nil

    for _, path in ipairs(candidates) do
        if type(loadfile) == "function" then
            local okChunk, chunkOrErr = pcall(loadfile, path)
            if okChunk and type(chunkOrErr) == "function" then
                local okRun, resultOrErr = pcall(chunkOrErr)
                if okRun and type(resultOrErr) == "table" then
                    return resultOrErr, path
                end
                if not okRun then
                    lastError = "loadfile(" .. path .. "): " .. tostring(resultOrErr)
                end
            elseif not okChunk then
                lastError = "loadfile(" .. path .. "): " .. tostring(chunkOrErr)
            end
        end

        if type(readfile) == "function" then
            local okRead, sourceOrErr = pcall(readfile, path)
            if okRead and type(sourceOrErr) == "string" and sourceOrErr ~= "" then
                local library, execErr = executeLibrarySource(sourceOrErr, "@" .. path)
                if library then
                    return library, path
                end
                lastError = "readfile(" .. path .. "): " .. tostring(execErr)
            elseif not okRead then
                lastError = "readfile(" .. path .. "): " .. tostring(sourceOrErr)
            end
        end
    end

    return nil, lastError
end

local Library
do
    local LIB_URL = "https://raw.githubusercontent.com/samuraa1/MentalityUI/main/Library.lua"
    local success, err = pcall(function()
        local source = fetchRemoteSource(LIB_URL)
        if type(source) ~= "string" or source == "" then
            error("library source is empty")
        end
        local library, execErr = executeLibrarySource(source, "@MentalityUIRemote")
        if not library then
            error(execErr)
        end
        Library = library
    end)
    if not success or not Library then
        local remoteError = tostring(err)
        warn("[" .. HUB_TAG .. "] Failed to load remote UI Library: " .. remoteError)
        local localLibrary, localPathOrErr = loadLibraryFromLocalFiles()
        if localLibrary then
            Library = localLibrary
            print("[" .. HUB_TAG .. "] Loaded local UI library backup from: " .. tostring(localPathOrErr))
        else
            local fallbackReason = "Remote: " .. tostring(remoteError) .. " | Local: " .. tostring(localPathOrErr or "unavailable")
            warn("[" .. HUB_TAG .. "] Local UI library fallback failed: " .. tostring(localPathOrErr))
            Library = createUiStub(fallbackReason)
        end
    end
end

local Window = {}
do
    local success2, err2 = pcall(function()
        Window = Library:Window({
            Name = T("title"),
            SubName = T("sub"),
            Logo = "107898873183710",
        })
    end)
    if not success2 or type(Window) ~= "table" then
        warn("[" .. HUB_TAG .. "] Window creation failed: " .. tostring(err2))
        Window = createUiStub("Window creation failed: " .. tostring(err2))
    end
end

local function applyAccentTheme(themeName)
    local resolved = ThemeAccents[themeName] and themeName or "Default"
    local accent = ThemeAccents[resolved]
    local gradient = ThemeGradients[resolved] or accent
    YasiaHubSettings.Theme = resolved
    setStoredValue(ENV_KEYS.Theme, ENV_KEYS.LegacyTheme, resolved)
    if Library and type(Library.ChangeTheme) == "function" then
        pcall(function()
            Library.Theme = Library.Theme or {}
            Library.Theme.Accent = accent
            Library.Theme.AccentGradient = gradient
            Library:ChangeTheme("Accent", accent)
            Library:ChangeTheme("AccentGradient", gradient)
        end)
    elseif Window and type(Window.SetAccent) == "function" then
        pcall(function()
            Window:SetAccent(accent)
        end)
    end
end

applyAccentTheme(YasiaHubSettings.Theme)

-- BEZOPASNAYa ZAGRUZKA SERVISOV
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Lighting = game:GetService("Lighting")
HttpService = game:GetService("HttpService")
MarketplaceService = pcall(function() return game:GetService("MarketplaceService") end) and game:GetService("MarketplaceService") or nil
TeleportService = pcall(function() return game:GetService("TeleportService") end) and game:GetService("TeleportService") or nil
VirtualUser = pcall(function() return game:GetService("VirtualUser") end) and game:GetService("VirtualUser") or nil
LP = Players.LocalPlayer
Mouse = LP and LP:GetMouse() or nil

if not LP then
    warn("[" .. HUB_TAG .. "] LocalPlayer not found!")
    return
end

Window:Category(T("category_main"))
pageMain = Window:Page({ Name = HUB_BRAND .. " | " .. T("main"), Icon = "home" })
pageESP = Window:Page({ Name = HUB_BRAND .. " | " .. T("visuals"), Icon = "eye" })
pageMovement = Window:Page({ Name = HUB_BRAND .. " | " .. T("move"), Icon = "move" })
Window:TabDivider()
Window:Category(T("category_combat"))
pageCombat = Window:Page({ Name = HUB_BRAND .. " | " .. T("combat"), Icon = "sword" })
pageAimbot = Window:Page({ Name = HUB_BRAND .. " | " .. T("aimbot"), Icon = "crosshair" })
Window:TabDivider()
Window:Category(T("category_world"))
pageMisc = Window:Page({ Name = HUB_BRAND .. " | " .. T("misc"), Icon = "settings" })
pageFun = Window:Page({ Name = HUB_BRAND .. " | " .. T("fun"), Icon = "smile" })
pageUtility = Window:Page({ Name = HUB_BRAND .. " | " .. T("util"), Icon = "tool" })
pageFarm = Window:Page({ Name = HUB_BRAND .. " | " .. T("farm"), Icon = "pickaxe" })
pageTeleports = Window:Page({ Name = HUB_BRAND .. " | " .. T("tp"), Icon = "map-pin" })
Window:TabDivider()
Window:Category(T("category_systems"))
pageAdmin = Window:Page({ Name = HUB_BRAND .. " | " .. T("admin"), Icon = "shield" })
pageVehicles = Window:Page({ Name = HUB_BRAND .. " | " .. T("car"), Icon = "car" })
pageTouchFling = Window:Page({ Name = HUB_BRAND .. " | " .. T("touch_fling"), Icon = "zap" })
pageAntiFling = Window:Page({ Name = HUB_BRAND .. " | " .. T("anti_fling"), Icon = "shield" })
pageGallery = Window:Page({ Name = HUB_BRAND .. " | " .. T("gall"), Icon = "image" })
pageCloudScripts = Window:Page({ Name = HUB_BRAND .. " | " .. T("cloud"), Icon = "cloud" })
pageSettings = Window:Page({ Name = HUB_BRAND .. " | " .. T("settings"), Icon = "sliders" })

HubKeybindList = nil
pcall(function()
    if Library and type(Library.KeybindList) == "function" then
        HubKeybindList = Library:KeybindList(HUB_BRAND .. " Keybinds")
    end
end)

BuiltInUiSettingsPage = nil
pcall(function()
    if Library and type(Library.CreateSettingsPage) == "function" then
        BuiltInUiSettingsPage = Library:CreateSettingsPage(Window, HubKeybindList, { PinToBottom = true })
    end
end)

-- OBEDINYaEM VSE SOSTOYaNIYa V ODNU TABLITsU DLYa EKONOMII LOKALNYKh PEREMENNYKh
GlobalState = {
    -- ESP
    espEnabled = false,
    espObjects = {},
    espRunConnection = nil,
    espBoxColor = Color3.fromRGB(255, 0, 0),
    espTeamColor = false,
    espShowBox = true,
    espShowText = true,
    espShowHealthBar = false,
    espShowDistance = true,
    espTextSize = 16,
    espShowTracer = false,
    espShowHeadDot = false,
    espUseDisplayName = false,
    espShowHealthText = true,
    espMaxDistance = 2500,
    espHideTeammates = false,
    espOnlyAlive = true,
    espRainbow = false,
    _lastESPTick = 0,
    _lastScanTick = 0,
    _lastVehicleInfoTick = 0,
    _lastScanTick = 0,
    _lastVehicleInfoTick = 0,
    
    -- Fly
    flyEnabled = false,
    flyBodyVelocity = nil,
    flyBodyGyro = nil,
    flyConnection = nil,
    flySpeed = 50,
    
    -- Movement
    noclipEnabled = false,
    infiniteJump = false,
    speedHackEnabled = false,
    speedHackConnection = nil,
    speedSliderValue = 16,
    jumpPowerValue = 50,
    gravityValue = 196.2,
    godMode = false,
    
    -- Teleport
    tpBindKey = Enum.KeyCode.T,
    bindingTPKey = false,
    clickTPEnabled = false,
    MainHeartbeatConnection = nil,
    MainInputBeganConnection = nil,
    MainInputEndedConnection = nil,
    MainJumpRequestConnection = nil,
    MainRenderConnection = nil,
    MainPlayerAddedConnection = nil,
    MainPlayerRemovingConnection = nil,
    SafeUpdateConnection = nil,
    CharacterAddedConnection = nil,
    CharacterDiedConnection = nil,
    UnloadInProgress = false,
    Unloaded = false,
    LibraryUnloadProxyInstalled = false,
    OriginalLibraryUnload = type(Library) == "table" and type(Library.Unload) == "function" and Library.Unload or nil,
    ScriptReadfileCandidates = {
        "getebt/qefwwef.lua",
        "qefwwef.lua",
        "C:/Users/Svyatoslav/Downloads/python/getebt/qefwwef.lua",
        "C:\\Users\\Svyatoslav\\Downloads\\python\\getebt\\qefwwef.lua",
    },
}

-- PEREMENNYE DLYa PRYaMOGO DOSTUPA
espEnabled = GlobalState.espEnabled == true
flyEnabled = GlobalState.flyEnabled == true
noclipEnabled = GlobalState.noclipEnabled == true
espObjects = type(GlobalState.espObjects) == "table" and GlobalState.espObjects or {}
GlobalState.espObjects = espObjects
espBoxColor = typeof(GlobalState.espBoxColor) == "Color3" and GlobalState.espBoxColor or Color3.fromRGB(255, 0, 0)
espTeamColor = GlobalState.espTeamColor == true
espShowBox = GlobalState.espShowBox ~= false
espShowText = GlobalState.espShowText ~= false
espShowHealthBar = GlobalState.espShowHealthBar == true
espShowDistance = GlobalState.espShowDistance ~= false
espTextSize = tonumber(GlobalState.espTextSize) or 16
espShowTracer = GlobalState.espShowTracer == true
espShowHeadDot = GlobalState.espShowHeadDot == true
espUseDisplayName = GlobalState.espUseDisplayName == true
espShowHealthText = GlobalState.espShowHealthText ~= false
espMaxDistance = tonumber(GlobalState.espMaxDistance) or 2500
espHideTeammates = GlobalState.espHideTeammates == true
espOnlyAlive = GlobalState.espOnlyAlive ~= false
espRainbow = GlobalState.espRainbow == true
infiniteJump = GlobalState.infiniteJump == true
speedHackEnabled = GlobalState.speedHackEnabled == true
speedSliderValue = tonumber(GlobalState.speedSliderValue) or 16
jumpPowerValue = tonumber(GlobalState.jumpPowerValue) or 50
gravityValue = tonumber(GlobalState.gravityValue) or 196.2
godMode = GlobalState.godMode == true
flySpeed = tonumber(GlobalState.flySpeed) or 50
tpBindKey = GlobalState.tpBindKey or Enum.KeyCode.T
bindingTPKey = GlobalState.bindingTPKey == true
clickTPEnabled = GlobalState.clickTPEnabled == true
GlobalState.tpBindKey = tpBindKey
GlobalState.bindingTPKey = bindingTPKey
GlobalState.clickTPEnabled = clickTPEnabled

local tpClickModifierActive = false
local hubNotify
local runChatLoopTick
local performRocketJump

VehicleSystem = {
    FlyEnabled = false,
    FwF = false,
    AntiLock = false,
    Pitch = false,
    Speed = 100,
    UpSpeed = 50,
    RotationSpeed = 5,
    VelocityHandler = nil,
    GyroHandler = nil,
    MovementDirection = {},
    seatConnection = nil,
    unseatConnection = nil,
    velocityName = "YasiaHub_Velocity",
    gyroName = "YasiaHub_Gyro",
    SpeedHackEnabled = false,
    SpeedHackMaxSpeed = 200,
    speedHackConnection = nil,
    NoclipEnabled = false,
    NoclipLastVehicle = nil,
    NoclipProcessed = false,
    ShiftBoost = false,
    BoostMultiplier = 1.75,
    NoclipCache = {},
}

FlingSystem = {
    Active = false,
    SelectedTargets = {},
    PickName = "",
    Dropdown = nil,
    FlingThread = nil,
    OldPos = nil,
    FPDH = nil,
    StatusLabel = nil,
    SkidLoopActive = false,
}

CombatSettings = { Reach = 1.5, SilentAim = false, Triggerbot = false }
MiscSettings = {
    AntiAfk = false,
    AntiAfkConn = nil,
    Fullbright = false,
    NoFog = false,
    SavedBrightness = nil,
    SavedFogEnd = nil,
    SavedClockTime = nil,
    Invis = false,
    InvisConn = nil,
    FOV = 70,
    BrightnessValue = nil,
    ClockTimeValue = nil,
    NoTextures = false,
    NoParticles = false,
    UnlockZoom = false,
    TextureStates = {},
    ParticleStates = {},
    TerrainState = nil,
    Xray = false,
    XrayTransparency = 0.7,
    XrayStates = {},
    HideOtherGuis = false,
}
FunSettings = {
    Spin = false,
    SpinConn = nil,
    SpinVel = nil,
    SpinSpeed = 32,
    Orbit = false,
    OrbitTarget = "",
    OrbitRadius = 8,
    OrbitSpeed = 2,
    OrbitCachedTarget = nil,
    OrbitCacheTime = 0,
    Bounce = false,
    BouncePower = 60,
}
FarmSettings = {
    AutoRadius = 50,
    AutoEnabled = false,
    PromptEnabled = false,
    PromptFilter = "",
    ClickEnabled = false,
    ClickFilter = "",
    TouchEnabled = false,
    TouchFilter = "",
    AutoCollectTools = false,
    Interval = 0.35,
    MaxPerCycle = 8,
    TeleportToTargets = false,
    LastRun = 0,
}
TeleportSettings = {
    SavedName = "",
    CheckpointCF = nil,
    LastCF = nil,
    SearchName = "",
    PlayerYOffset = 3,
    Slots = {},
}
AdminSettings = {
    SpectateName = "",
    Freecam = false,
    FollowTarget = "",
    FollowEnabled = false,
    FollowDistance = 4,
    FollowCachedTarget = nil,
    FollowCacheTime = 0,
    HighlightTarget = false,
    HighlightObject = nil,
    PlayerCache = {},
    PlayerCacheTime = 0,
}
CombatSettings.AimAssist = false
CombatSettings.AimFov = 180
CombatSettings.AimPart = "Head"
CombatSettings.TeamCheck = false
CombatSettings.AutoToolSpam = false
CombatSettings.ToolSpamInterval = 0.15
CombatSettings.HitboxExpand = false
CombatSettings.HitboxSize = 5
CombatSettings.HitboxTransparency = 0.5
CombatSettings.HitboxCache = {}
CombatSettings.LastToolSpam = 0
CombatSettings.TargetLockName = ""
CombatSettings.TargetLockEnabled = false

MovementSettings = {
    BunnyHop = false,
    AntiVoid = false,
    VoidY = -40,
    RescueOffset = 6,
    LastSafeCF = nil,
    LastSafeAt = 0,
    LastRescueAt = 0,
    SafeVelocityLimit = 90,
    Glide = false,
    GlideFallSpeed = -25,
    AirStuck = false,
    AntiSit = false,
    AntiPlatformStand = false,
    AutoRotateNearest = false,
    AutoRotateLastUpdate = 0,
    AutoRotateUpdateInterval = 0.1,
}

TouchFlingSettings = {
    VelocityMultiplier = 10000,
    UpwardBoost = 10000,
    RestoreYOffset = 0.1,
}

AntiFlingState = {
    LastSafeCF = nil,
    LastAnchorAt = 0,
    LastTeleportAt = 0,
    GuardedHumanoid = nil,
}

AimbotSettings = {
    Enabled = false,
    BindActive = false,
    Mode = "Camera",
    AvailableModes = { "Camera" },
    SilentAimMethods = { "Mouse.Hit / Mouse.Target", "GetMouseLocation" },
    SilentAimChance = 100,
    OffAfterKill = false,
    AimPartValues = { "Head", "HumanoidRootPart" },
    AimPart = "HumanoidRootPart",
    RandomAimPart = false,
    UseOffset = false,
    OffsetType = "Static",
    StaticOffsetIncrement = 10,
    DynamicOffsetIncrement = 10,
    AutoOffset = false,
    MaxAutoOffset = 50,
    UseSensitivity = false,
    Sensitivity = 50,
    UseNoise = false,
    NoiseFrequency = 50,
    FoVCheck = false,
    FoVRadius = 120,
    ShowFoV = false,
    FoVThickness = 2,
    FoVOpacity = 0.8,
    FoVFilled = false,
    FoVColour = Color3.fromRGB(255, 255, 255),
    RainbowFoV = false,
    AliveCheck = false,
    GodCheck = false,
    TeamCheck = false,
    FriendCheck = false,
    FollowCheck = false,
    VerifiedBadgeCheck = false,
    WallCheck = false,
    WaterCheck = false,
    MagnitudeCheck = false,
    TriggerMagnitude = 500,
    TransparencyCheck = false,
    IgnoredTransparency = 0.5,
    WhitelistedGroupCheck = false,
    WhitelistedGroup = 0,
    BlacklistedGroupCheck = false,
    BlacklistedGroup = 0,
    IgnoredPlayersCheck = false,
    IgnoredPlayersDropdownValues = {},
    IgnoredPlayers = {},
    TargetPlayersCheck = false,
    TargetPlayersDropdownValues = {},
    TargetPlayers = {},
    PremiumCheck = false,
    SpinBot = false,
    SpinBindActive = false,
    SpinBotVelocity = 50,
    SpinPartValues = { "Head", "HumanoidRootPart" },
    SpinPart = "HumanoidRootPart",
    RandomSpinPart = false,
    TriggerBot = false,
    TriggerBindActive = false,
    SmartTriggerBot = false,
    TriggerBotChance = 100,
    LastRandomTick = 0,
    LastTriggerTick = 0,
    TriggerCooldown = 0.06,
    LastAimbotFrameUpdate = 0,
    AimbotFrameUpdateInterval = 0.05,
}

AimbotRuntime = {
    AimPartDropdown = nil,
    SpinPartDropdown = nil,
    IgnoredPlayersDropdown = nil,
    TargetPlayersDropdown = nil,
    AimKeybind = nil,
    SpinKeybind = nil,
    TriggerKeybind = nil,
    CurrentTargetData = nil,
    FoVCircle = nil,
    SilentHooksInstalled = false,
    ManualActivation = false,
    KeybindActive = false,
    SpinKeybindActive = false,
    TriggerKeybindActive = false,
}

ValidArguments = nil
ValidateArguments = nil

RuntimeRefs = {
    OrbitDropdown = nil,
    AdminFollowDropdown = nil,
    AdminSpectateDropdown = nil,
    CheckpointStatusLabel = nil,
    PlayerInfoLabel = nil,
    VehicleInfoLabel = nil,
    CombatTargetDropdown = nil,
    ScanInfoLabel = nil,
    TeleportPlayerDropdown = nil,
    TeleportInfoLabel = nil,
    TpBindStatusLabel = nil,
    AimbotStatusLabel = nil,
    FarmHelperLabel = nil,
    CloudGameLabel = nil,
    CloudStatusLabel = nil,
    ChatStatusLabel = nil,
    MainLiveLabel = nil,
    SettingsLiveLabel = nil,
    DiagnosticsLabel = nil,
    ThemePreviewLabel = nil,
    AutoLoadStatusLabel = nil,
}

HubBootAt = tick()

GallerySettings = {
    CardHeight = 236,
    Images = {
        { Name = "Yasia Cat #1", AssetId = "rbxassetid://82614908604499" },
        { Name = "Yasia Cat #2", AssetId = "rbxassetid://89479018780005" },
        { Name = "Yasia Cat #3", AssetId = "rbxassetid://136143883111885" },
        { Name = "Yasia Cat #4", AssetId = "rbxassetid://82623721618437" },
        { Name = "Yasia Cat #5", AssetId = "rbxassetid://74004257042666" },
        { Name = "Yasia Cat #6", AssetId = "rbxassetid://124772127778680" },
        { Name = "Yasia Cat #7", AssetId = "rbxassetid://116466520519390" },
        { Name = "Yasia Cat #8", AssetId = "rbxassetid://86904172460631" },
        { Name = "Yasia Cat #9", AssetId = "rbxassetid://77079244866794" },
        { Name = "Yasia Cat #10", AssetId = "rbxassetid://90961266998506" },
        { Name = "Yasia Cat #11", AssetId = "rbxassetid://91636419726738" },
        { Name = "Yasia Cat #12", AssetId = "rbxassetid://120714608892506" },
        { Name = "Yasia Cat #13", AssetId = "rbxassetid://91160129945227" },
        { Name = "Yasia Cat #14", AssetId = "rbxassetid://136628474117121" },
        { Name = "Yasia Cat #15", AssetId = "rbxassetid://84883513058673" },
        { Name = "Yasia Cat #16", AssetId = "rbxassetid://88811980009473" },
        { Name = "Yasia Fresh #1", AssetId = "rbxassetid://107898873183710" },
        { Name = "Yasia Fresh #2", AssetId = "rbxassetid://135955487893706" },
        { Name = "Yasia Fresh #3", AssetId = "rbxassetid://116615807564150" },
        { Name = "Yasia Fresh #4", AssetId = "rbxassetid://131078710213137" },
        { Name = "Yasia Fresh #5", AssetId = "rbxassetid://117400744599788" },
        { Name = "Yasia Fresh #6", AssetId = "rbxassetid://106062271252340" },
        { Name = "Yasia Fresh #7", AssetId = "rbxassetid://107351730524342" },
    },
}

CloudScriptsSettings = {
    CardHeight = 176,
    Results = {},
    Page = 1,
    TotalPages = 1,
    NextPage = nil,
    Max = 10,
    SortBy = "updatedAt",
    Order = "desc",
    FreeOnly = false,
    VerifiedOnly = false,
    NoKey = false,
    UniversalOnly = false,
    HidePatched = false,
    GameName = "",
    LastError = "",
    Fetching = false,
}

CloudScriptsRuntime = {
    ResultsSection = nil,
    PageSlider = nil,
    MaxSlider = nil,
}

MainSettings = {
    QuietLoad = getStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, false) == true,
    HudEnabled = getStoredValue(ENV_KEYS.HudEnabled, ENV_KEYS.LegacyHudEnabled, false) == true,
    AutoLoad = getStoredValue(ENV_KEYS.AutoLoad, ENV_KEYS.LegacyAutoLoad, false) == true,
}

ChatSettings = {
    Enabled = false,
    Mode = "Rotate",
    Interval = 2.5,
    BurstCount = 3,
    MessageSource = "gg | :) | Yasia Hub moment",
    Prefix = "",
    IncludeCounter = false,
    SelectedPreset = "Friendly",
    LastSentAt = 0,
    SentCount = 0,
    RotateIndex = 0,
    Presets = {
        Friendly = { "gg", "nice", ":)" },
        Yasia = { "Yasia Hub moment", "hi chat", ":)" },
        Trade = { "team up?", "follow me", "need help?" },
        Farm = { "starting farm", "route ready", "loot reset?" },
    },
}

ChatRuntime = {
    LastMessage = "",
}

HudRuntime = {
    Gui = nil,
    Frame = nil,
    Title = nil,
    Body = nil,
    Connection = nil,
    LastUpdate = 0,
}

local function getHudParent()
    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and coreGui then
        return coreGui
    end
    return LP and LP:FindFirstChildOfClass("PlayerGui") or nil
end

local function getHudModuleList()
    local modules = {}
    local function add(enabled, name)
        if enabled then
            modules[#modules + 1] = name
        end
    end

    add(AimbotSettings and AimbotSettings.Enabled, "Aimbot")
    add(AimbotSettings and AimbotSettings.SpinBot, "SpinBot")
    add(AimbotSettings and AimbotSettings.TriggerBot, "TriggerBot")
    add((GlobalState and GlobalState.espEnabled) or espEnabled, "ESP")
    add(flyEnabled, "Fly")
    add(noclipEnabled, "Noclip")
    add(infiniteJump, "InfJump")
    add(speedHackEnabled, "Speed")
    add(godMode, "GodMode")
    add(clickTPEnabled, "ClickTP")
    add(MiscSettings and MiscSettings.Fullbright, "Fullbright")
    add(HighlightSettings and HighlightSettings.Enabled, "Highlight")
    add(FarmSettings and (FarmSettings.AutoEnabled or FarmSettings.PromptEnabled or FarmSettings.ClickEnabled or FarmSettings.TouchEnabled or FarmSettings.AutoCollectTools), "Farm")
    add(AdminSettings and AdminSettings.FollowEnabled, "Follow")
    add(AdminSettings and AdminSettings.SpectateName ~= "", "Spectate")
    add(touchFlingEnabled, "TouchFling")
    add(antiFlingEnabled, "AntiFling")
    add(VehicleSystem and (VehicleSystem.SpeedHackEnabled or VehicleSystem.NoclipEnabled or VehicleSystem.FlyEnabled), "Vehicle")
    add(ChatSettings and ChatSettings.Enabled, "ChatLoop")

    table.sort(modules)
    return modules
end

local function destroyHudGui()
    if HudRuntime.Connection then
        HudRuntime.Connection:Disconnect()
        HudRuntime.Connection = nil
    end
    if HudRuntime.Gui then
        pcall(function()
            HudRuntime.Gui:Destroy()
        end)
    end
    HudRuntime.Gui = nil
    HudRuntime.Frame = nil
    HudRuntime.Title = nil
    HudRuntime.Body = nil
end

local function ensureHudGui()
    if HudRuntime.Gui and HudRuntime.Gui.Parent then
        return true
    end

    local parent = getHudParent()
    if not parent then
        return false
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "YasiaHubHud"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        gui.IgnoreGuiInset = true
    end)

    local frame = Instance.new("Frame")
    frame.Name = "Holder"
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -18, 0, 18)
    frame.Size = UDim2.new(0, 230, 0, 84)
    frame.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
    frame.BackgroundTransparency = 0.14
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(90, 144, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.15
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Size = UDim2.new(1, -24, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = HUB_BRAND
    title.Parent = frame

    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 12, 0, 32)
    body.Size = UDim2.new(1, -24, 1, -40)
    body.Font = Enum.Font.Code
    body.TextSize = 13
    body.LineHeight = 1.1
    body.RichText = false
    body.TextWrapped = false
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextColor3 = Color3.fromRGB(220, 230, 255)
    body.Text = ""
    body.Parent = frame

    gui.Parent = parent

    HudRuntime.Gui = gui
    HudRuntime.Frame = frame
    HudRuntime.Title = title
    HudRuntime.Body = body
    return true
end

local function renderHud()
    if not MainSettings.HudEnabled then
        if HudRuntime.Gui then
            HudRuntime.Gui.Enabled = false
        end
        return
    end

    if not ensureHudGui() then
        return
    end

    local modules = getHudModuleList()
    local coordsText = "Coords: unavailable"
    if type(getRootPart) == "function" then
        local root = getRootPart()
        if root then
            local p = root.Position
            coordsText = string.format("Coords: %.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        end
    end

    local bodyLines = {
        "Hub: " .. HUB_BRAND,
        coordsText,
        "Modules:",
    }

    if #modules > 0 then
        for _, moduleName in ipairs(modules) do
            bodyLines[#bodyLines + 1] = moduleName
        end
    else
        bodyLines[#bodyLines + 1] = "No active modules"
    end

    local bodyText = table.concat(bodyLines, "\n")
    local lineCount = #bodyLines
    local bodyHeight = math.max(22, lineCount * 16)

    HudRuntime.Gui.Enabled = true
    HudRuntime.Title.Text = string.format("%s  [%d]", HUB_BRAND, #modules)
    HudRuntime.Body.Text = bodyText
    HudRuntime.Body.Size = UDim2.new(1, -24, 0, bodyHeight)
    HudRuntime.Frame.Size = UDim2.new(0, 230, 0, 46 + bodyHeight)
end

local function setHudEnabled(state)
    MainSettings.HudEnabled = state == true
    setStoredValue(ENV_KEYS.HudEnabled, ENV_KEYS.LegacyHudEnabled, MainSettings.HudEnabled)

    if MainSettings.HudEnabled then
        renderHud()
        if not HudRuntime.Connection then
            HudRuntime.Connection = RunService.Heartbeat:Connect(function()
                if not MainSettings.HudEnabled then
                    if HudRuntime.Gui then
                        HudRuntime.Gui.Enabled = false
                    end
                    return
                end
                if tick() - (HudRuntime.LastUpdate or 0) >= 0.2 then
                    HudRuntime.LastUpdate = tick()
                    renderHud()
                end
            end)
        end
    else
        destroyHudGui()
    end
end

HighlightSettings = {
    Enabled = false,
    EnemyOnly = false,
    Rainbow = false,
    FillTransparency = 0.65,
    OutlineTransparency = 0,
    Cache = {},
    LastUpdate = 0,
}

UtilityFeatureSettings = {
    HideLocalName = false,
    SavedDisplayDistanceType = nil,
}

MovementSettings.CameraSmooth = false
MovementSettings.StrafeMultiplier = 1
MovementSettings.CameraTiltAmount = 0.85
MovementSettings.DashPower = 70

FunSettings.RocketJump = false
FunSettings.LastRocketJump = 0
FunSettings.RocketJumpPower = 85
FunSettings.RocketForwardPower = 45
FunSettings.RainbowBody = false
FunSettings.RainbowRate = 0.2

FarmSettings.IgnorePlayers = true
FarmSettings.PreferNearest = true

uiReady = false
refreshAllPlayerDropdowns = nil
updatePlayerHighlights = function() end
handleAimbotBotsAndRandom = function() end
findPlayer = function() return nil end
runFarmCycle = function() end
setTargetHighlight = function() end
setLocalNameHidden = function() return false end
setLocalCharacterColor = function() return false end

touchFlingEnabled = false
touchFlingConnection = nil
antiFlingEnabled = false
antiFlingConnection = nil
_G.AntiFlingConfig = {
    disable_rotation = false,
    limit_velocity = false,
    limit_velocity_sensitivity = 100,
    limit_velocity_slow = 0,
    limit_angular_velocity = true,
    angular_velocity_sensitivity = 60,
    anti_ragdoll = true,
    anti_seat = true,
    block_states = false,
    zero_all_parts = false,
    auto_jump_recover = true,
    anchor = true,
    smart_anchor = true,
    anchor_dist = 15,
    teleport = true,
    smart_teleport = true,
    teleport_dist = 15,
    safe_velocity_threshold = 50,
    safe_on_ground_only = false,
    max_rescue_per_second = 8,
}

local slidersToReset = {}
function trackSlider(slider, defaultValue)
    if slider and slider.Set and type(defaultValue) == "number" then
        table.insert(slidersToReset, { s = slider, d = defaultValue })
    end
    return slider
end

function safeDropdownRefresh(dropdown, names)
    if not uiReady or not dropdown or type(dropdown.Refresh) ~= "function" then return end
    pcall(function()
        dropdown:Refresh(names)
    end)
end

local setNoFog

function isFiniteNumber(v)
    return type(v) == "number" and v == v and v > -math.huge and v < math.huge
end

function galleryNotify(title, description, duration)
    pcall(function()
        if Library and Library.Notification then
            Library:Notification({
                Title = title or "GALEREYa",
                Description = description or "",
                Duration = duration or 3,
            })
        end
    end)
end

function createGalleryCard(section, entry)
    local content = section and section.Items and section.Items.Content and section.Items.Content.Instance
    if not content or not entry or type(entry.AssetId) ~= "string" then return end

    local card = Instance.new("Frame")
    card.Name = "YasiaHubGalleryCard"
    card.BackgroundColor3 = Color3.fromRGB(28, 29, 36)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, GallerySettings.CardHeight)
    card.LayoutOrder = #content:GetChildren() + 10
    card.ZIndex = 4
    card.Parent = content

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cardStroke.Color = Color3.fromRGB(92, 97, 120)
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local preview = Instance.new("ImageLabel")
    preview.Name = "Preview"
    preview.BackgroundColor3 = Color3.fromRGB(236, 239, 246)
    preview.BorderSizePixel = 0
    preview.Active = true
    preview.Position = UDim2.new(0, 8, 0, 8)
    preview.Size = UDim2.new(1, -16, 1, -66)
    preview.Image = entry.AssetId
    preview.ImageColor3 = Color3.fromRGB(255, 255, 255)
    preview.ImageTransparency = 0
    preview.ScaleType = Enum.ScaleType.Fit
    preview.ZIndex = 5
    preview.Parent = card

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 8)
    previewCorner.Parent = preview

    local previewStroke = Instance.new("UIStroke")
    previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    previewStroke.Color = Color3.fromRGB(190, 196, 210)
    previewStroke.Thickness = 1
    previewStroke.Parent = preview

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 1, -50)
    titleLabel.Size = UDim2.new(1, -135, 0, 18)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = entry.Name
    titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 6
    titleLabel.Parent = card

    local assetLabel = Instance.new("TextLabel")
    assetLabel.Name = "AssetId"
    assetLabel.BackgroundTransparency = 1
    assetLabel.Position = UDim2.new(0, 10, 1, -29)
    assetLabel.Size = UDim2.new(1, -135, 0, 16)
    assetLabel.Font = Enum.Font.Gotham
    assetLabel.Text = entry.AssetId
    assetLabel.TextColor3 = Color3.fromRGB(198, 202, 216)
    assetLabel.TextSize = 11
    assetLabel.TextXAlignment = Enum.TextXAlignment.Left
    assetLabel.TextTruncate = Enum.TextTruncate.AtEnd
    assetLabel.ZIndex = 6
    assetLabel.Parent = card

    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyButton"
    copyButton.AutoButtonColor = false
    copyButton.BackgroundColor3 = Color3.fromRGB(82, 144, 255)
    copyButton.BorderSizePixel = 0
    copyButton.Position = UDim2.new(1, -118, 1, -40)
    copyButton.Size = UDim2.new(0, 108, 0, 28)
    copyButton.Font = Enum.Font.GothamSemibold
    copyButton.Text = "Copy ID"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.TextSize = 13
    copyButton.ZIndex = 6
    copyButton.Parent = card

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = copyButton

    local function copyAssetId()
        local copied = false
        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(entry.AssetId)
                copied = true
            end
        end)
        galleryNotify(
            entry.Name,
            copied and (TL("Скопировано", "Скопійовано", "Copied") .. ": " .. entry.AssetId) or ("Asset ID: " .. entry.AssetId),
            3
        )
    end

    copyButton.MouseButton1Click:Connect(copyAssetId)
    preview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            copyAssetId()
        end
    end)
end

function populateGallerySection(section, entries)
    for _, entry in ipairs(entries) do
        createGalleryCard(section, entry)
    end
end

function cloudScriptsNotify(title, description, duration)
    pcall(function()
        if Library and Library.Notification then
            Library:Notification({
                Title = title or "Cloud Scripts",
                Description = description or "",
                Duration = duration or 3,
            })
        end
    end)
end

function tryCopyText(text)
    local copied = false
    pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(tostring(text or ""))
            copied = true
        end
    end)
    return copied
end

function formatCloudCount(value)
    value = tonumber(value) or 0
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end
    return tostring(math.floor(value))
end

function formatCloudDate(value)
    value = tostring(value or "")
    if #value >= 10 then
        return string.sub(value, 1, 10)
    end
    return value ~= "" and value or "unknown"
end

function setCloudStatusText(text)
    if RuntimeRefs.CloudStatusLabel and RuntimeRefs.CloudStatusLabel.SetText then
        RuntimeRefs.CloudStatusLabel:SetText(tostring(text or "Cloud Scripts ready"))
    end
end

function refreshCloudGameLabel()
    local gameName = CloudScriptsSettings.GameName
    if gameName == "" then
        gameName = tostring(game.PlaceId)
    end
    if RuntimeRefs.CloudGameLabel and RuntimeRefs.CloudGameLabel.SetText then
        RuntimeRefs.CloudGameLabel:SetText(TL("Игра", "Гра", "Game") .. ": " .. gameName .. " | PlaceId: " .. tostring(game.PlaceId))
    end
end

function resolveCloudGameName()
    if CloudScriptsSettings.GameName ~= "" then
        refreshCloudGameLabel()
        return CloudScriptsSettings.GameName
    end
    local name = tostring(game.PlaceId)
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
            name = info.Name
        end
    end)
    CloudScriptsSettings.GameName = name
    refreshCloudGameLabel()
    return name
end

function clearCloudScriptCards(section)
    local content = section and section.Items and section.Items.Content and section.Items.Content.Instance
    if not content then return end
    for _, child in ipairs(content:GetChildren()) do
        if child.Name == "YasiaHubCloudScriptCard" then
            child:Destroy()
        end
    end
end

function createCloudScriptCard(section, entry, isPlaceholder)
    local content = section and section.Items and section.Items.Content and section.Items.Content.Instance
    if not content or type(entry) ~= "table" then return end

    local card = Instance.new("Frame")
    card.Name = "YasiaHubCloudScriptCard"
    card.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, CloudScriptsSettings.CardHeight)
    card.LayoutOrder = #content:GetChildren() + 10
    card.ZIndex = 4
    card.Parent = content

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cardStroke.Color = isPlaceholder and Color3.fromRGB(88, 94, 115) or Color3.fromRGB(78, 136, 255)
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 12, 0, 10)
    titleLabel.Size = UDim2.new(1, -24, 0, 36)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = tostring(entry.Title or "Cloud Scripts")
    titleLabel.TextColor3 = Color3.fromRGB(247, 248, 252)
    titleLabel.TextSize = 15
    titleLabel.TextWrapped = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Top
    titleLabel.ZIndex = 5
    titleLabel.Parent = card

    local gameLabel = Instance.new("TextLabel")
    gameLabel.Name = "Game"
    gameLabel.BackgroundTransparency = 1
    gameLabel.Position = UDim2.new(0, 12, 0, 49)
    gameLabel.Size = UDim2.new(1, -24, 0, 16)
    gameLabel.Font = Enum.Font.Gotham
    gameLabel.Text = tostring(entry.GameName or "")
    gameLabel.TextColor3 = Color3.fromRGB(176, 185, 204)
    gameLabel.TextSize = 11
    gameLabel.TextWrapped = true
    gameLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameLabel.ZIndex = 5
    gameLabel.Parent = card

    local flagsLabel = Instance.new("TextLabel")
    flagsLabel.Name = "Flags"
    flagsLabel.BackgroundTransparency = 1
    flagsLabel.Position = UDim2.new(0, 12, 0, 70)
    flagsLabel.Size = UDim2.new(1, -24, 0, 16)
    flagsLabel.Font = Enum.Font.GothamMedium
    flagsLabel.Text = tostring(entry.FlagsText or "")
    flagsLabel.TextColor3 = Color3.fromRGB(141, 203, 255)
    flagsLabel.TextSize = 11
    flagsLabel.TextWrapped = true
    flagsLabel.TextXAlignment = Enum.TextXAlignment.Left
    flagsLabel.ZIndex = 5
    flagsLabel.Parent = card

    local metaLabel = Instance.new("TextLabel")
    metaLabel.Name = "Meta"
    metaLabel.BackgroundTransparency = 1
    metaLabel.Position = UDim2.new(0, 12, 0, 92)
    metaLabel.Size = UDim2.new(1, -24, 0, 30)
    metaLabel.Font = Enum.Font.Gotham
    metaLabel.Text = tostring(entry.MetaText or "")
    metaLabel.TextColor3 = Color3.fromRGB(211, 214, 223)
    metaLabel.TextSize = 11
    metaLabel.TextWrapped = true
    metaLabel.TextXAlignment = Enum.TextXAlignment.Left
    metaLabel.TextYAlignment = Enum.TextYAlignment.Top
    metaLabel.ZIndex = 5
    metaLabel.Parent = card

    if isPlaceholder then
        return
    end

    local leftButton = Instance.new("TextButton")
    leftButton.Name = "CopySlugButton"
    leftButton.AutoButtonColor = false
    leftButton.BackgroundColor3 = Color3.fromRGB(68, 112, 206)
    leftButton.BorderSizePixel = 0
    leftButton.Position = UDim2.new(0, 12, 1, -42)
    leftButton.Size = UDim2.new(0.5, -18, 0, 30)
    leftButton.Font = Enum.Font.GothamSemibold
    leftButton.Text = "Copy Slug"
    leftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftButton.TextSize = 12
    leftButton.ZIndex = 6
    leftButton.Parent = card

    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 8)
    leftCorner.Parent = leftButton

    local rightButton = Instance.new("TextButton")
    rightButton.Name = "CopyInfoButton"
    rightButton.AutoButtonColor = false
    rightButton.BackgroundColor3 = Color3.fromRGB(45, 51, 64)
    rightButton.BorderSizePixel = 0
    rightButton.Position = UDim2.new(0.5, 6, 1, -42)
    rightButton.Size = UDim2.new(0.5, -18, 0, 30)
    rightButton.Font = Enum.Font.GothamSemibold
    rightButton.Text = "Copy Info"
    rightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightButton.TextSize = 12
    rightButton.ZIndex = 6
    rightButton.Parent = card

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 8)
    rightCorner.Parent = rightButton

    leftButton.MouseButton1Click:Connect(function()
        local copied = tryCopyText(entry.Slug or "")
        cloudScriptsNotify(entry.Title, copied and ("Slug copied: " .. tostring(entry.Slug or "")) or ("Slug: " .. tostring(entry.Slug or "")), 3)
    end)

    rightButton.MouseButton1Click:Connect(function()
        local infoText = table.concat({
            "Title: " .. tostring(entry.Title or ""),
            "Game: " .. tostring(entry.GameName or ""),
            "Slug: " .. tostring(entry.Slug or ""),
            "ScriptId: " .. tostring(entry.ScriptId or ""),
            "Views: " .. tostring(entry.Views or 0),
        }, "\n")
        local copied = tryCopyText(infoText)
        cloudScriptsNotify(entry.Title, copied and "Script info copied" or infoText, copied and 2 or 5)
    end)
end

function renderCloudScripts()
    local section = CloudScriptsRuntime.ResultsSection
    if not section then return end
    clearCloudScriptCards(section)

    if CloudScriptsSettings.LastError ~= "" then
        createCloudScriptCard(section, {
            Title = TL("Ошибка загрузки", "Помилка завантаження", "Load Error"),
            GameName = resolveCloudGameName(),
            FlagsText = "ScriptBlox fetch",
            MetaText = CloudScriptsSettings.LastError,
        }, true)
        return
    end

    if #CloudScriptsSettings.Results == 0 then
        createCloudScriptCard(section, {
            Title = TL("Скрипты ещё не загружены", "Скрипти ще не завантажені", "Scripts Not Loaded Yet"),
            GameName = resolveCloudGameName(),
            FlagsText = TL("Нажми Fetch для текущей игры", "Натисни Fetch для поточної гри", "Press Fetch For The Current Game"),
            MetaText = TL(
                "Вкладка использует ScriptBlox fetch endpoint и показывает только метаданные без автозапуска удалённых скриптов.",
                "Вкладка використовує ScriptBlox fetch endpoint і показує лише метадані без автозапуску віддалених скриптів.",
                "This tab uses the ScriptBlox fetch endpoint and only shows metadata without auto-running remote scripts."
            ),
        }, true)
        return
    end

    for _, scriptInfo in ipairs(CloudScriptsSettings.Results) do
        local gameInfo = type(scriptInfo.game) == "table" and scriptInfo.game or {}
        local flags = {}
        table.insert(flags, tostring(scriptInfo.scriptType or "unknown"))
        if scriptInfo.verified then table.insert(flags, "verified") end
        if scriptInfo.key then table.insert(flags, "key") else table.insert(flags, "no-key") end
        if scriptInfo.isUniversal then table.insert(flags, "universal") end
        if scriptInfo.isPatched then table.insert(flags, "patched") else table.insert(flags, "working?") end

        createCloudScriptCard(section, {
            Title = tostring(scriptInfo.title or "Untitled"),
            GameName = tostring((type(gameInfo.name) == "string" and gameInfo.name ~= "") and gameInfo.name or resolveCloudGameName()),
            FlagsText = table.concat(flags, " | "),
            MetaText = string.format(
                "Views: %s | Updated: %s\nSlug: %s",
                formatCloudCount(scriptInfo.views),
                formatCloudDate(scriptInfo.updatedAt or scriptInfo.createdAt),
                tostring(scriptInfo.slug or "")
            ),
            Slug = tostring(scriptInfo.slug or ""),
            ScriptId = tostring(scriptInfo._id or ""),
            Views = tonumber(scriptInfo.views) or 0,
        }, false)
    end
end

function buildCloudScriptsFetchUrl()
    local params = {
        "page=" .. tostring(math.max(1, math.floor(CloudScriptsSettings.Page))),
        "max=" .. tostring(math.clamp(math.floor(CloudScriptsSettings.Max), 1, 20)),
        "sortBy=" .. HttpService:UrlEncode(tostring(CloudScriptsSettings.SortBy or "updatedAt")),
        "order=" .. HttpService:UrlEncode(tostring(CloudScriptsSettings.Order or "desc")),
        "placeId=" .. tostring(game.PlaceId),
    }

    if CloudScriptsSettings.FreeOnly then
        table.insert(params, "mode=free")
    end
    if CloudScriptsSettings.VerifiedOnly then
        table.insert(params, "verified=1")
    end
    if CloudScriptsSettings.NoKey then
        table.insert(params, "key=0")
    end
    if CloudScriptsSettings.UniversalOnly then
        table.insert(params, "universal=1")
    end
    if CloudScriptsSettings.HidePatched then
        table.insert(params, "patched=0")
    end

    return "https://scriptblox.com/api/script/fetch?" .. table.concat(params, "&")
end

function fetchCloudScripts()
    if CloudScriptsSettings.Fetching then return end
    CloudScriptsSettings.Fetching = true
    CloudScriptsSettings.LastError = ""
    resolveCloudGameName()
    setCloudStatusText("Cloud Scripts: loading...")

    local url = buildCloudScriptsFetchUrl()
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        CloudScriptsSettings.Results = {}
        CloudScriptsSettings.LastError = "NE UDALOS POLUChIT OTVET OT ScriptBlox."
        CloudScriptsSettings.Fetching = false
        renderCloudScripts()
        setCloudStatusText("Cloud Scripts: fetch error")
        cloudScriptsNotify("Cloud Scripts", CloudScriptsSettings.LastError, 4)
        return
    end

    local decodedOk, payload = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not decodedOk or type(payload) ~= "table" then
        CloudScriptsSettings.Results = {}
        CloudScriptsSettings.LastError = "OTVET ScriptBlox NE UDALOS RAZOBRAT."
        CloudScriptsSettings.Fetching = false
        renderCloudScripts()
        setCloudStatusText("Cloud Scripts: invalid JSON")
        cloudScriptsNotify("Cloud Scripts", CloudScriptsSettings.LastError, 4)
        return
    end

    if type(payload.message) == "string" and type(payload.result) ~= "table" then
        CloudScriptsSettings.Results = {}
        CloudScriptsSettings.LastError = payload.message
        CloudScriptsSettings.Fetching = false
        renderCloudScripts()
        setCloudStatusText("Cloud Scripts: " .. payload.message)
        cloudScriptsNotify("Cloud Scripts", payload.message, 4)
        return
    end

    local result = type(payload.result) == "table" and payload.result or {}
    local scripts = type(result.scripts) == "table" and result.scripts or {}
    CloudScriptsSettings.Results = scripts
    CloudScriptsSettings.TotalPages = math.max(1, tonumber(result.totalPages) or 1)
    CloudScriptsSettings.Page = math.clamp(math.max(1, tonumber(CloudScriptsSettings.Page) or 1), 1, CloudScriptsSettings.TotalPages)
    CloudScriptsSettings.Max = math.clamp(math.floor(tonumber(result.max) or CloudScriptsSettings.Max or 10), 1, 20)
    CloudScriptsSettings.NextPage = tonumber(result.nextPage)
    CloudScriptsSettings.LastError = ""
    CloudScriptsSettings.Fetching = false

    renderCloudScripts()
    setCloudStatusText(string.format(
        "Cloud Scripts: %d results | Page %d/%d | Next: %s",
        #scripts,
        CloudScriptsSettings.Page,
        CloudScriptsSettings.TotalPages,
        CloudScriptsSettings.NextPage and tostring(CloudScriptsSettings.NextPage) or "-"
    ))
    cloudScriptsNotify("Cloud Scripts", string.format("ZAGRUZhENO %d REZULTATOV DLYa %s", #scripts, resolveCloudGameName()), 3)
end

function getCharacter()
    return LP.Character
end

function getHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

function getRootPart(character)
    character = character or getCharacter()
    return character and (
        character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
    )
end

function getHead(character)
    character = character or getCharacter()
    return character and character:FindFirstChild("Head")
end

function getCharacterBounds(character)
    character = character or getCharacter()
    if not character then return nil, nil end

    local ok, bboxCf, bboxSize = pcall(function()
        return character:GetBoundingBox()
    end)
    if ok and typeof(bboxCf) == "CFrame" and typeof(bboxSize) == "Vector3" then
        return bboxCf, bboxSize
    end

    local minVec, maxVec
    for _, inst in ipairs(character:GetDescendants()) do
        if inst:IsA("BasePart") then
            local pos = inst.Position
            local half = inst.Size * 0.5
            local pMin = pos - half
            local pMax = pos + half
            minVec = minVec and Vector3.new(
                math.min(minVec.X, pMin.X),
                math.min(minVec.Y, pMin.Y),
                math.min(minVec.Z, pMin.Z)
            ) or pMin
            maxVec = maxVec and Vector3.new(
                math.max(maxVec.X, pMax.X),
                math.max(maxVec.Y, pMax.Y),
                math.max(maxVec.Z, pMax.Z)
            ) or pMax
        end
    end
    if not minVec or not maxVec then return nil, nil end
    local size = maxVec - minVec
    local center = (minVec + maxVec) * 0.5
    return CFrame.new(center), size
end

function getESPBoxData(character, root, camera)
    if not character or not root or not camera then return nil end
    local center2D, centerOnScreen = camera:WorldToViewportPoint(root.Position)
    if not centerOnScreen then return nil end
    local top2D = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.8, 0))
    local bottom2D = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))
    local boxHeight = math.abs(bottom2D.Y - top2D.Y)
    if not isFiniteNumber(boxHeight) or boxHeight < 4 then return nil end
    local boxWidth = math.max(14, boxHeight * 0.55)
    local topLeft = Vector2.new(center2D.X - boxWidth * 0.5, math.min(top2D.Y, bottom2D.Y))
    local bottomRight = Vector2.new(center2D.X + boxWidth * 0.5, math.max(top2D.Y, bottom2D.Y))
    return { center2D = center2D, topLeft = topLeft, bottomRight = bottomRight, boxSize = bottomRight - topLeft }
end

function isAlivePlayer(player)
    local char = player and player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = getRootPart(char)
    return hum and hum.Health > 0 and root ~= nil
end

function matchesFilter(text, filter)
    filter = tostring(filter or ""):lower()
    if filter == "" then return true end
    text = tostring(text or ""):lower()
    return text:find(filter, 1, true) ~= nil
end

function isEnemyPlayer(player)
    if not player or player == LP then return false end
    if not CombatSettings.TeamCheck then return true end
    if LP.Team == nil or player.Team == nil then return true end
    return LP.Team ~= player.Team
end

function rememberCurrentPosition()
    local root = getRootPart()
    if root then
        TeleportSettings.LastCF = root.CFrame
    end
end

function teleportLocalTo(cf)
    if typeof(cf) ~= "CFrame" then return end
    local root = getRootPart()
    if not root then return end
    rememberCurrentPosition()
    root.CFrame = cf
end

function getCurrentTool()
    local character = getCharacter()
    if not character then return nil end
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            return obj
        end
    end
    return nil
end

function equipAllTools()
    local backpack = LP:FindFirstChildOfClass("Backpack")
    local humanoid = getHumanoid()
    if not backpack or not humanoid then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            humanoid:EquipTool(tool)
        end
    end
end

function unequipTools()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid:UnequipTools()
    end
end

function setCameraFOV(v)
    if not isFiniteNumber(v) then return end
    MiscSettings.FOV = v
    pcall(function()
        workspace.CurrentCamera.FieldOfView = v
    end)
end

function setClockTime(v)
    if not isFiniteNumber(v) then return end
    MiscSettings.ClockTimeValue = v
    pcall(function()
        Lighting.ClockTime = v
    end)
end

function setBrightnessValue(v)
    if not isFiniteNumber(v) then return end
    MiscSettings.BrightnessValue = v
    pcall(function()
        Lighting.Brightness = v
    end)
end

function setUnlockZoom(on)
    MiscSettings.UnlockZoom = on
    pcall(function()
        LP.CameraMaxZoomDistance = on and 100000 or 128
        LP.CameraMinZoomDistance = 0.5
    end)
end

function setNoTextures(on)
    MiscSettings.NoTextures = on
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Texture") or inst:IsA("Decal") then
            if on then
                if MiscSettings.TextureStates[inst] == nil then
                    MiscSettings.TextureStates[inst] = inst.Transparency
                end
                inst.Transparency = 1
            elseif MiscSettings.TextureStates[inst] ~= nil then
                inst.Transparency = MiscSettings.TextureStates[inst]
            end
        end
    end
end

function setNoParticles(on)
    MiscSettings.NoParticles = on
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Smoke")
            or inst:IsA("Fire") or inst:IsA("Sparkles")
        then
            if on then
                if MiscSettings.ParticleStates[inst] == nil then
                    MiscSettings.ParticleStates[inst] = inst.Enabled
                end
                inst.Enabled = false
            elseif MiscSettings.ParticleStates[inst] ~= nil then
                inst.Enabled = MiscSettings.ParticleStates[inst]
            end
        end
    end
end

function applyLowGraphics()
    if MiscSettings.TerrainState == nil then
        MiscSettings.TerrainState = {
            WaterWaveSize = workspace.Terrain.WaterWaveSize,
            WaterWaveSpeed = workspace.Terrain.WaterWaveSpeed,
            WaterReflectance = workspace.Terrain.WaterReflectance,
            WaterTransparency = workspace.Terrain.WaterTransparency,
            GlobalShadows = Lighting.GlobalShadows,
        }
    end
    setNoTextures(true)
    setNoParticles(true)
    setNoFog(true)
    pcall(function()
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
        Lighting.GlobalShadows = false
    end)
end

function restoreGraphics()
    setNoTextures(false)
    setNoParticles(false)
    if MiscSettings.TerrainState then
        pcall(function()
            workspace.Terrain.WaterWaveSize = MiscSettings.TerrainState.WaterWaveSize
            workspace.Terrain.WaterWaveSpeed = MiscSettings.TerrainState.WaterWaveSpeed
            workspace.Terrain.WaterReflectance = MiscSettings.TerrainState.WaterReflectance
            workspace.Terrain.WaterTransparency = MiscSettings.TerrainState.WaterTransparency
            Lighting.GlobalShadows = MiscSettings.TerrainState.GlobalShadows
        end)
    end
end

function savePositionSlot(index)
    local root = getRootPart()
    if root then
        TeleportSettings.Slots[index] = root.CFrame
    end
end

function loadPositionSlot(index)
    local cf = TeleportSettings.Slots[index]
    if cf then
        teleportLocalTo(cf)
    end
end

function getTargetPart(player, partName)
    local char = player and player.Character
    if not char then return nil end
    return char:FindFirstChild(partName) or getHead(char) or getRootPart(char)
end

function getClosestAimPart()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local bestPart, bestDist = nil, CombatSettings.AimFov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlivePlayer(plr) and isEnemyPlayer(plr) then
            local aimPart = getTargetPart(plr, CombatSettings.AimPart)
            if aimPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPart = aimPart
                    end
                end
            end
        end
    end
    return bestPart
end

local function rollChance(percent)
    percent = tonumber(percent) or 0
    return Random.new():NextNumber(0, 100) <= math.clamp(percent, 0, 100)
end

local function addUniqueValue(list, value)
    if type(list) ~= "table" or value == nil or value == "" then return end
    if not table.find(list, value) then
        table.insert(list, value)
    end
end

local function removeValue(list, value)
    if type(list) ~= "table" then return end
    local index = table.find(list, value)
    if index then
        table.remove(list, index)
    end
end

local function resolvePlayerNameInput(value)
    value = tostring(value or "")
    if value == "" then return "" end

    local direct = Players:FindFirstChild(value) or findPlayer(value)
    if direct then
        return direct.Name
    end

    if value:sub(1, 1) == "@" then
        local match = Players:FindFirstChild(value:sub(2)) or findPlayer(value:sub(2))
        if match then
            return match.Name
        end
    elseif value:sub(1, 1) == "#" then
        local userId = tonumber(value:sub(2))
        if userId then
            local ok, name = pcall(function()
                return Players:GetNameFromUserIdAsync(userId)
            end)
            if ok and type(name) == "string" then
                return name
            end
        end
    end

    local okUserId, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(value)
    end)
    if okUserId and userId then
        local okName, name = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        if okName and type(name) == "string" then
            return name
        end
    end

    return ""
end

local function getAimbotTargetPart(player)
    return getTargetPart(player, AimbotSettings.AimPart)
end

local function getAimbotLocalOrigin()
    local character = getCharacter()
    return getRootPart(character) or getHead(character)
end

local function isPremiumPlayer(player)
    local ok, premium = pcall(function()
        return player and player.MembershipType == Enum.MembershipType.Premium
    end)
    return ok and premium or false
end

local function sharesTeamWithLocal(player)
    if not player or not LP then return false end
    if LP.Team == nil or player.Team == nil then return false end
    return LP.Team == player.Team
end

local function canUseSilentAim()
    local env = getfenv()
    return env.hookmetamethod and env.newcclosure and env.checkcaller and env.getnamecallmethod
end

local function canUseMouseAim()
    local env = getfenv()
    return env.mousemoverel and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
end

local function getAimbotAdjustedPosition(part, humanoid, localOrigin)
    if not part or not localOrigin then
        return part and part.Position or nil
    end

    local position = part.Position
    if AimbotSettings.UseOffset then
        local yOffset = 0
        local dynamicOffset = Vector3.zero
        local distance = (part.Position - localOrigin.Position).Magnitude

        if AimbotSettings.AutoOffset then
            yOffset = math.min(AimbotSettings.MaxAutoOffset / 10, distance * (AimbotSettings.StaticOffsetIncrement / 1000))
        elseif AimbotSettings.OffsetType == "Static" or AimbotSettings.OffsetType == "Static & Dynamic" then
            yOffset = AimbotSettings.StaticOffsetIncrement / 10
        end

        if humanoid and (
            AimbotSettings.OffsetType == "Dynamic"
            or AimbotSettings.OffsetType == "Static & Dynamic"
            or AimbotSettings.AutoOffset
        ) then
            dynamicOffset = humanoid.MoveDirection * (AimbotSettings.DynamicOffsetIncrement / 10)
        end

        position = position + Vector3.new(0, yOffset, 0) + dynamicOffset
    end

    if AimbotSettings.UseNoise then
        local f = AimbotSettings.NoiseFrequency / 100
        position = position + Vector3.new(
            Random.new():NextNumber(-f, f),
            Random.new():NextNumber(-f, f),
            Random.new():NextNumber(-f, f)
        )
    end

    return position
end

local function isAimbotTargetAllowed(player)
    if not player or player == LP or not player.Character then return false end

    local character = player.Character
    local humanoid = getHumanoid(character)
    local localOrigin = getAimbotLocalOrigin()
    local targetPart = getAimbotTargetPart(player)
    local head = getHead(character)
    if not humanoid or not targetPart or not localOrigin then return false end

    if AimbotSettings.AliveCheck and humanoid.Health <= 0 then
        return false
    end

    if AimbotSettings.GodCheck and (humanoid.Health >= 1e9 or character:FindFirstChildWhichIsA("ForceField")) then
        return false
    end

    if AimbotSettings.TeamCheck and sharesTeamWithLocal(player) then
        return false
    end

    if AimbotSettings.FriendCheck then
        local ok, isFriend = pcall(function()
            return player:IsFriendsWith(LP.UserId)
        end)
        if ok and isFriend then
            return false
        end
    end

    if AimbotSettings.FollowCheck then
        local ok, followUserId = pcall(function()
            return player.FollowUserId
        end)
        if ok and tonumber(followUserId) == LP.UserId then
            return false
        end
    end

    if AimbotSettings.VerifiedBadgeCheck then
        local ok, hasBadge = pcall(function()
            return player.HasVerifiedBadge
        end)
        if ok and hasBadge then
            return false
        end
    end

    if AimbotSettings.PremiumCheck and isPremiumPlayer(player) then
        return false
    end

    if AimbotSettings.TransparencyCheck and head and head:IsA("BasePart") and head.Transparency >= AimbotSettings.IgnoredTransparency then
        return false
    end

    if AimbotSettings.WhitelistedGroupCheck and tonumber(AimbotSettings.WhitelistedGroup) and AimbotSettings.WhitelistedGroup > 0 then
        local ok, inGroup = pcall(function()
            return player:IsInGroup(AimbotSettings.WhitelistedGroup)
        end)
        if ok and inGroup then
            return false
        end
    end

    if AimbotSettings.BlacklistedGroupCheck and tonumber(AimbotSettings.BlacklistedGroup) and AimbotSettings.BlacklistedGroup > 0 then
        local ok, inGroup = pcall(function()
            return player:IsInGroup(AimbotSettings.BlacklistedGroup)
        end)
        if ok and inGroup then
            return false
        end
    end

    if AimbotSettings.IgnoredPlayersCheck and table.find(AimbotSettings.IgnoredPlayers, player.Name) then
        return false
    end

    if AimbotSettings.TargetPlayersCheck and not table.find(AimbotSettings.TargetPlayers, player.Name) then
        return false
    end

    local adjustedPosition = getAimbotAdjustedPosition(targetPart, humanoid, localOrigin)
    if not adjustedPosition then
        return false
    end

    if AimbotSettings.MagnitudeCheck and (adjustedPosition - localOrigin.Position).Magnitude > AimbotSettings.TriggerMagnitude then
        return false
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return false
    end

    local screenPosition, onScreen = camera:WorldToViewportPoint(adjustedPosition)
    if not onScreen then
        return false
    end

    if AimbotSettings.FoVCheck then
        local mousePos = UserInputService:GetMouseLocation()
        local distance2D = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
        if distance2D > AimbotSettings.FoVRadius then
            return false
        end
    end

    if AimbotSettings.WallCheck then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = { getCharacter() }
        rayParams.IgnoreWater = not AimbotSettings.WaterCheck
        local direction = adjustedPosition - localOrigin.Position
        local result = workspace:Raycast(localOrigin.Position, direction, rayParams)
        if result and result.Instance and not result.Instance:IsDescendantOf(character) then
            return false
        end
    end

    return true
end

local function getAimbotTargetData(player)
    if not isAimbotTargetAllowed(player) then
        return nil
    end

    local localOrigin = getAimbotLocalOrigin()
    local targetPart = getAimbotTargetPart(player)
    local humanoid = getHumanoid(player.Character)
    local camera = workspace.CurrentCamera
    if not localOrigin or not targetPart or not humanoid or not camera then
        return nil
    end

    local worldPosition = getAimbotAdjustedPosition(targetPart, humanoid, localOrigin)
    if not worldPosition then
        return nil
    end

    local screenPosition, onScreen = camera:WorldToViewportPoint(worldPosition)
    if not onScreen then
        return nil
    end

    return {
        player = player,
        character = player.Character,
        humanoid = humanoid,
        part = targetPart,
        worldPosition = worldPosition,
        screenPosition = Vector2.new(screenPosition.X, screenPosition.Y),
        distance = (worldPosition - localOrigin.Position).Magnitude,
    }
end

local function getBestAimbotTargetData()
    local mousePos = UserInputService:GetMouseLocation()
    local bestData, bestDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        local data = getAimbotTargetData(player)
        if data then
            local distance2D = (data.screenPosition - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
            local withinFov = not AimbotSettings.FoVCheck or distance2D <= AimbotSettings.FoVRadius
            if withinFov and distance2D < bestDistance then
                bestDistance = distance2D
                bestData = data
            end
        end
    end

    return bestData
end

local function getActiveAimbotTargetData()
    if not AimbotSettings.Enabled or not AimbotSettings.BindActive then
        return nil
    end

    local data = AimbotRuntime.CurrentTargetData
    if data and data.player and data.player.Parent and data.part and data.part.Parent and isAimbotTargetAllowed(data.player) then
        return getAimbotTargetData(data.player)
    end

    return getBestAimbotTargetData()
end

local function getAimbotStatusText()
    local mode = AimbotSettings.Mode
    local state = AimbotSettings.Enabled and (AimbotSettings.BindActive and T("status_aim") or T("status_armed")) or T("status_off")
    local targetName = AimbotRuntime.CurrentTargetData and AimbotRuntime.CurrentTargetData.player and AimbotRuntime.CurrentTargetData.player.Name or "-"
    return string.format("%s: %s | %s: %s | %s: %s", T("aimbot"), state, T("mode"), mode, T("target"), targetName)
end

local function updateAimbotStatusLabel()
    if not RuntimeRefs.AimbotStatusLabel or not RuntimeRefs.AimbotStatusLabel.SetText then
        return
    end

    RuntimeRefs.AimbotStatusLabel:SetText(getAimbotStatusText())
end

ValidArguments = {
    Raycast = {
        Required = 3,
        Arguments = { "Instance", "Vector3", "Vector3", "RaycastParams" }
    },
    FindPartOnRay = {
        Required = 2,
        Arguments = { "Instance", "Ray", "Instance", "boolean", "boolean" }
    },
    FindPartOnRayWithIgnoreList = {
        Required = 3,
        Arguments = { "Instance", "Ray", "table", "boolean", "boolean" }
    },
    FindPartOnRayWithWhitelist = {
        Required = 3,
        Arguments = { "Instance", "Ray", "table", "boolean" }
    }
}

ValidateArguments = function(argumentsList, methodData)
    if typeof(argumentsList) ~= "table" or typeof(methodData) ~= "table" or #argumentsList < methodData.Required then
        return false
    end

    local matches = 0
    for index, argument in next, argumentsList do
        if typeof(argument) == methodData.Arguments[index] then
            matches = matches + 1
        end
    end

    return matches >= methodData.Required
end

local function ensureAimbotFoVCircle()
    if AimbotRuntime.FoVCircle or not getfenv().Drawing or not getfenv().Drawing.new then
        return AimbotRuntime.FoVCircle
    end

    local circle = getfenv().Drawing.new("Circle")
    circle.Visible = false
    circle.ZIndex = 7
    circle.NumSides = 90
    circle.Radius = AimbotSettings.FoVRadius
    circle.Thickness = AimbotSettings.FoVThickness
    circle.Transparency = AimbotSettings.FoVOpacity
    circle.Filled = AimbotSettings.FoVFilled
    circle.Color = AimbotSettings.FoVColour
    AimbotRuntime.FoVCircle = circle
    return circle
end

local function updateAimbotFoVCircle()
    local circle = ensureAimbotFoVCircle()
    if not circle then
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    circle.Position = Vector2.new(mousePos.X, mousePos.Y)
    circle.Radius = AimbotSettings.FoVRadius
    circle.Thickness = AimbotSettings.FoVThickness
    circle.Transparency = AimbotSettings.FoVOpacity
    circle.Filled = AimbotSettings.FoVFilled
    circle.Color = AimbotSettings.RainbowFoV
        and Color3.fromHSV((tick() % 5) / 5, 1, 1)
        or AimbotSettings.FoVColour
    circle.Visible = AimbotSettings.ShowFoV
end

local function installAimbotSilentHooks()
    if AimbotRuntime.SilentHooksInstalled or not canUseSilentAim() then
        return
    end

    local env = getfenv()
    local oldIndex
    oldIndex = env.hookmetamethod(game, "__index", env.newcclosure(function(self, index)
        local data = getActiveAimbotTargetData()
        if not env.checkcaller()
            and self == Mouse
            and data
            and AimbotSettings.Mode == "Silent"
            and rollChance(AimbotSettings.SilentAimChance)
            and table.find(AimbotSettings.SilentAimMethods, "Mouse.Hit / Mouse.Target")
        then
            local worldPosition = data.worldPosition
            if index == "Hit" or index == "hit" then
                return CFrame.new(worldPosition)
            elseif index == "Target" or index == "target" then
                return data.part
            elseif index == "X" or index == "x" then
                return data.screenPosition.X
            elseif index == "Y" or index == "y" then
                return data.screenPosition.Y
            elseif index == "UnitRay" or index == "unitRay" then
                local origin = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position or Vector3.zero
                return Ray.new(origin, worldPosition - origin)
            end
        end
        return oldIndex(self, index)
    end))

    local oldNamecall
    oldNamecall = env.hookmetamethod(game, "__namecall", env.newcclosure(function(...)
        local method = env.getnamecallmethod()
        local args = { ... }
        local self = args[1]
        local data = getActiveAimbotTargetData()

        if not env.checkcaller()
            and data
            and AimbotSettings.Mode == "Silent"
            and rollChance(AimbotSettings.SilentAimChance)
        then
            if table.find(AimbotSettings.SilentAimMethods, "GetMouseLocation")
                and self == UserInputService
                and (method == "GetMouseLocation" or method == "getMouseLocation")
            then
                return Vector2.new(data.screenPosition.X, data.screenPosition.Y)
            elseif table.find(AimbotSettings.SilentAimMethods, "Raycast")
                and self == workspace
                and (method == "Raycast" or method == "raycast")
                and ValidateArguments(args, ValidArguments.Raycast)
            then
                args[3] = data.worldPosition - args[2]
                return oldNamecall(table.unpack(args))
            elseif table.find(AimbotSettings.SilentAimMethods, "FindPartOnRay")
                and self == workspace
                and (method == "FindPartOnRay" or method == "findPartOnRay")
                and ValidateArguments(args, ValidArguments.FindPartOnRay)
            then
                args[2] = Ray.new(args[2].Origin, data.worldPosition - args[2].Origin)
                return oldNamecall(table.unpack(args))
            elseif table.find(AimbotSettings.SilentAimMethods, "FindPartOnRayWithIgnoreList")
                and self == workspace
                and (method == "FindPartOnRayWithIgnoreList" or method == "findPartOnRayWithIgnoreList")
                and ValidateArguments(args, ValidArguments.FindPartOnRayWithIgnoreList)
            then
                args[2] = Ray.new(args[2].Origin, data.worldPosition - args[2].Origin)
                return oldNamecall(table.unpack(args))
            elseif table.find(AimbotSettings.SilentAimMethods, "FindPartOnRayWithWhitelist")
                and self == workspace
                and (method == "FindPartOnRayWithWhitelist" or method == "findPartOnRayWithWhitelist")
                and ValidateArguments(args, ValidArguments.FindPartOnRayWithWhitelist)
            then
                args[2] = Ray.new(args[2].Origin, data.worldPosition - args[2].Origin)
                return oldNamecall(table.unpack(args))
            end
        end
        return oldNamecall(...)
    end))

    AimbotRuntime.SilentHooksInstalled = true
end

if canUseMouseAim() then
    table.insert(AimbotSettings.AvailableModes, "Mouse")
end

if canUseSilentAim() then
    table.insert(AimbotSettings.AvailableModes, "Silent")
    installAimbotSilentHooks()
end

local function handleAimbotFrame()
    if not AimbotSettings.Enabled or not AimbotSettings.BindActive then
        AimbotRuntime.CurrentTargetData = nil
        updateAimbotStatusLabel()
        return
    end

    local previousData = AimbotRuntime.CurrentTargetData
    local data = getBestAimbotTargetData()
    AimbotRuntime.CurrentTargetData = data

    if not data then
        if AimbotSettings.OffAfterKill and previousData and previousData.humanoid and previousData.humanoid.Health <= 0 then
            AimbotSettings.BindActive = false
        end
        updateAimbotStatusLabel()
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        updateAimbotStatusLabel()
        return
    end

    if AimbotSettings.Mode == "Camera" then
        local targetCFrame = CFrame.new(camera.CFrame.Position, data.worldPosition)
        if AimbotSettings.UseSensitivity then
            local alpha = math.clamp(AimbotSettings.Sensitivity / 100, 0.09, 0.99)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)
        else
            camera.CFrame = targetCFrame
        end
    elseif AimbotSettings.Mode == "Mouse" and canUseMouseAim() then
        local mousePosition = UserInputService:GetMouseLocation()
        local sensitivity = AimbotSettings.UseSensitivity and math.max(AimbotSettings.Sensitivity / 5, 1) or 10
        getfenv().mousemoverel(
            (data.screenPosition.X - mousePosition.X) / sensitivity,
            (data.screenPosition.Y - mousePosition.Y) / sensitivity
        )
    end

    updateAimbotStatusLabel()
end

handleAimbotBotsAndRandom = function()
    if tick() - AimbotSettings.LastRandomTick >= 1 then
        if AimbotSettings.RandomAimPart and #AimbotSettings.AimPartValues > 0 then
            AimbotSettings.AimPart = AimbotSettings.AimPartValues[Random.new():NextInteger(1, #AimbotSettings.AimPartValues)]
            if AimbotRuntime.AimPartDropdown then
                pcall(function()
                    AimbotRuntime.AimPartDropdown:Set(AimbotSettings.AimPart, true)
                end)
            end
        end

        if AimbotSettings.RandomSpinPart and #AimbotSettings.SpinPartValues > 0 then
            AimbotSettings.SpinPart = AimbotSettings.SpinPartValues[Random.new():NextInteger(1, #AimbotSettings.SpinPartValues)]
            if AimbotRuntime.SpinPartDropdown then
                pcall(function()
                    AimbotRuntime.SpinPartDropdown:Set(AimbotSettings.SpinPart, true)
                end)
            end
        end

        AimbotSettings.LastRandomTick = tick()
    end

    if AimbotSettings.SpinBot and AimbotSettings.SpinBindActive then
        local character = getCharacter()
        local part = character and character:FindFirstChild(AimbotSettings.SpinPart)
        if part and part:IsA("BasePart") then
            part.CFrame = part.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(AimbotSettings.SpinBotVelocity), 0)
        end
    end

    if AimbotSettings.TriggerBot
        and AimbotSettings.TriggerBindActive
        and getfenv().mouse1click
        and tick() - AimbotSettings.LastTriggerTick >= AimbotSettings.TriggerCooldown
    then
        local shouldShoot = not AimbotSettings.SmartTriggerBot or (AimbotSettings.Enabled and AimbotSettings.BindActive)
        if shouldShoot and Mouse.Target then
            local targetModel = Mouse.Target:FindFirstAncestorWhichIsA("Model")
            local targetPlayer = targetModel and Players:GetPlayerFromCharacter(targetModel)
            if targetPlayer and getAimbotTargetData(targetPlayer) and rollChance(AimbotSettings.TriggerBotChance) then
                AimbotSettings.LastTriggerTick = tick()
                pcall(function()
                    getfenv().mouse1click()
                end)
            end
        end
    end
end

setTargetHighlight = function(player)
    if not AdminSettings.HighlightTarget or not player or not player.Character then return end
    if AdminSettings.HighlightObject and AdminSettings.HighlightObject.Adornee == player.Character then
        return
    end
    if AdminSettings.HighlightObject then
        pcall(function() AdminSettings.HighlightObject:Destroy() end)
        AdminSettings.HighlightObject = nil
    end
    local hl = Instance.new("Highlight")
    hl.Name = "YasiaHub_TargetHighlight"
    hl.FillColor = Color3.fromRGB(255, 170, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Adornee = player.Character
    hl.Parent = player.Character
    AdminSettings.HighlightObject = hl
end

local function updateHitboxForPlayer(player, enabled)
    if player == LP or not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    if enabled then
        if not CombatSettings.HitboxCache[root] then
            CombatSettings.HitboxCache[root] = {
                Size = root.Size,
                Transparency = root.Transparency,
                CanCollide = root.CanCollide,
            }
        end
        root.Size = Vector3.new(CombatSettings.HitboxSize, CombatSettings.HitboxSize, CombatSettings.HitboxSize)
        root.Transparency = CombatSettings.HitboxTransparency
        root.CanCollide = false
    else
        local cache = CombatSettings.HitboxCache[root]
        if cache then
            root.Size = cache.Size
            root.Transparency = cache.Transparency
            root.CanCollide = cache.CanCollide
            CombatSettings.HitboxCache[root] = nil
        end
    end
end

local function restoreAllHitboxes()
    for part, cache in pairs(CombatSettings.HitboxCache) do
        pcall(function()
            if part and part.Parent and cache then
                part.Size = cache.Size
                part.Transparency = cache.Transparency
                part.CanCollide = cache.CanCollide
            end
        end)
        CombatSettings.HitboxCache[part] = nil
    end
end

-- Event-driven hitbox expansion SISTEMA DLYa IZBEZhANIYa O(n) ITERATsIY KAZhDYY FREYM
CombatSettings.HitboxConnections = CombatSettings.HitboxConnections or {}

local function setupHitboxMonitoring()
    -- OChISchAEM STARYE PODKLYuChENIYa
    if CombatSettings.HitboxConnections.playerAdded then
        CombatSettings.HitboxConnections.playerAdded:Disconnect()
    end
    if CombatSettings.HitboxConnections.playerRemoving then
        CombatSettings.HitboxConnections.playerRemoving:Disconnect()
    end
    
    if not CombatSettings.HitboxExpand then
        -- OTKLYuChAEM MONITORING I VOSSTANAVLIVAEM KhITBOKSY
        for _, player in pairs(Players:GetPlayers()) do
            if CombatSettings.HitboxConnections[player] then
                CombatSettings.HitboxConnections[player]:Disconnect()
                CombatSettings.HitboxConnections[player] = nil
            end
        end
        restoreAllHitboxes()
        return
    end
    
    -- PRIMENYaEM RASShIRENIE K UZhE ZAGRUZhENNYM IGROKAM
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            updateHitboxForPlayer(player, true)
        end
    end
    
    -- SLUShAEM NOVYKh IGROKOV
    CombatSettings.HitboxConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        local charConn
        charConn = player.CharacterAdded:Connect(function(character)
            task.wait(0.1) -- DAEM VREMYa ZAGRUZITSYa
            if CombatSettings.HitboxExpand then
                updateHitboxForPlayer(player, true)
            end
        end)
        CombatSettings.HitboxConnections[player] = charConn
    end)
    
    CombatSettings.HitboxConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        if CombatSettings.HitboxConnections[player] then
            CombatSettings.HitboxConnections[player]:Disconnect()
            CombatSettings.HitboxConnections[player] = nil
        end
    end)
end

local function getNearestSeat(maxDistance)
    local root = getRootPart()
    if not root then return nil end
    local best, dist = nil, maxDistance or math.huge
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("VehicleSeat") or inst:IsA("Seat") then
            local d = (inst.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                best = inst
            end
        end
    end
    return best
end

local function seatInNearestSeat()
    local seat = getNearestSeat(250)
    if seat then
        teleportLocalTo(seat.CFrame + Vector3.new(0, 3, 0))
        local hum = getHumanoid()
        if hum then
            task.delay(0.1, function()
                pcall(function()
                    seat:Sit(hum)
                end)
            end)
        end
    end
end

local function setWorldXray(on)
    MiscSettings.Xray = on
    local char = getCharacter()
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and not (char and inst:IsDescendantOf(char)) then
            if on then
                if MiscSettings.XrayStates[inst] == nil then
                    MiscSettings.XrayStates[inst] = inst.LocalTransparencyModifier
                end
                inst.LocalTransparencyModifier = MiscSettings.XrayTransparency
            elseif MiscSettings.XrayStates[inst] ~= nil then
                inst.LocalTransparencyModifier = MiscSettings.XrayStates[inst]
                MiscSettings.XrayStates[inst] = nil
            end
        end
    end
end

local function setHideOtherGuis(on)
    MiscSettings.HideOtherGuis = on
    for _, gui in ipairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
        if gui:IsA("ScreenGui") then
            local guiName = tostring(gui.Name or "")
            if not guiName:lower():find("mentality", 1, true)
                and not guiName:lower():find("yasia", 1, true)
            then
                pcall(function()
                    gui.Enabled = not on
                end)
            end
        end
    end
end

local function findNearestFromWorkspace(getTargetPartFn, maxDistance)
    local root = getRootPart()
    if not root then return nil end
    local best, bestDist = nil, maxDistance or math.huge
    for _, inst in ipairs(workspace:GetDescendants()) do
        local part = getTargetPartFn(inst)
        if part and part:IsA("BasePart") then
            local d = (part.Position - root.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = inst
            end
        end
    end
    return best, bestDist
end

local function getNearestPrompt(radius)
    return findNearestFromWorkspace(function(inst)
        if inst:IsA("ProximityPrompt") then
            local parent = inst.Parent
            return parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart"))
        end
    end, radius)
end

local function getNearestClickDetector(radius)
    return findNearestFromWorkspace(function(inst)
        if inst:IsA("ClickDetector") then
            local parent = inst.Parent
            return parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart"))
        end
    end, radius)
end

local function getNearestToolInWorld(radius)
    return findNearestFromWorkspace(function(inst)
        if inst:IsA("Tool") and inst.Parent == workspace then
            return inst:FindFirstChild("Handle")
        end
    end, radius)
end

local function getNearestSpawn(radius)
    return findNearestFromWorkspace(function(inst)
        if inst:IsA("SpawnLocation") then
            return inst
        end
    end, radius)
end

local function teleportToNearestObject(kind)
    local obj
    if kind == "prompt" then
        obj = getNearestPrompt(500)
    elseif kind == "click" then
        obj = getNearestClickDetector(500)
    elseif kind == "tool" then
        obj = getNearestToolInWorld(500)
    elseif kind == "spawn" then
        obj = getNearestSpawn(2000)
    elseif kind == "seat" then
        obj = getNearestSeat(500)
    end
    local part
    if obj then
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") or obj:IsA("SpawnLocation") then
            part = obj
        elseif obj:IsA("Tool") then
            part = obj:FindFirstChild("Handle")
        else
            local parent = obj.Parent
            part = parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart"))
        end
    end
    if part then
        teleportLocalTo(part.CFrame + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

local function scanNearbyCounts(radius)
    local root = getRootPart()
    if not root then
        return { prompts = 0, clicks = 0, tools = 0, seats = 0, spawns = 0 }
    end
    local out = { prompts = 0, clicks = 0, tools = 0, seats = 0, spawns = 0 }
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("ProximityPrompt") then
            local parent = inst.Parent
            local part = parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart"))
            if part and (part.Position - root.Position).Magnitude <= radius then
                out.prompts = out.prompts + 1
            end
        elseif inst:IsA("ClickDetector") then
            local parent = inst.Parent
            local part = parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart"))
            if part and (part.Position - root.Position).Magnitude <= radius then
                out.clicks = out.clicks + 1
            end
        elseif inst:IsA("Tool") and inst.Parent == workspace then
            local handle = inst:FindFirstChild("Handle")
            if handle and (handle.Position - root.Position).Magnitude <= radius then
                out.tools = out.tools + 1
            end
        elseif (inst:IsA("Seat") or inst:IsA("VehicleSeat")) and (inst.Position - root.Position).Magnitude <= radius then
            out.seats = out.seats + 1
        elseif inst:IsA("SpawnLocation") and (inst.Position - root.Position).Magnitude <= radius then
            out.spawns = out.spawns + 1
        end
    end
    return out
end

local function getLockedTargetPart()
    if not CombatSettings.TargetLockEnabled or CombatSettings.TargetLockName == "" then
        return nil
    end
    local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName)
    return plr and getTargetPart(plr, CombatSettings.AimPart) or nil
end

local function setVehicleModelCollision(model, canCollide)
    if not model then
        for part, oldCanCollide in pairs(VehicleSystem.NoclipCache or {}) do
            pcall(function()
                if part and part.Parent then
                    part.CanCollide = oldCanCollide
                end
            end)
            VehicleSystem.NoclipCache[part] = nil
        end
        return
    end
    -- GetDescendants() OChEN TYaZhELAYa OPERATsIYa, VYZYVAT TOLKO ODIN RAZ
    -- A NE KAZhDYY FREYM!
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if VehicleSystem.NoclipEnabled then
                if VehicleSystem.NoclipCache[part] == nil then
                    VehicleSystem.NoclipCache[part] = part.CanCollide
                end
                part.CanCollide = canCollide
            elseif VehicleSystem.NoclipCache[part] ~= nil then
                part.CanCollide = VehicleSystem.NoclipCache[part]
                VehicleSystem.NoclipCache[part] = nil
            end
        end
    end
end

local function getSeatedVehicleModel()
    local hum = getHumanoid()
    local seat = hum and hum.SeatPart
    return seat and seat:FindFirstAncestorOfClass("Model") or nil
end

local function getSeatedVehiclePrimaryPart()
    local model = getSeatedVehicleModel()
    if not model then return nil, nil end
    local pp = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    return model, pp
end

local function teleportSeatedVehicleTo(cf)
    if typeof(cf) ~= "CFrame" then return false end
    local _, pp = getSeatedVehiclePrimaryPart()
    if not pp then return false end
    pcall(function()
        pp.CFrame = cf
        pp.AssemblyLinearVelocity = Vector3.zero
        pp.AssemblyAngularVelocity = Vector3.zero
    end)
    return true
end

local function flipSeatedVehicleUpright()
    local _, pp = getSeatedVehiclePrimaryPart()
    if not pp then return false end
    local look = pp.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 1e-3 then
        flat = Vector3.new(0, 0, -1)
    else
        flat = flat.Unit
    end
    return teleportSeatedVehicleTo(CFrame.new(pp.Position, pp.Position + flat))
end

local function usePrompt(prompt)
    if not prompt then return false end
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
        return true
    end
    local ok = pcall(function()
        local oldHold = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()
        prompt.HoldDuration = oldHold
    end)
    return ok
end

local function useClickDetector(click)
    if not click then return false end
    if fireclickdetector then
        pcall(function()
            fireclickdetector(click)
        end)
        return true
    end
    return false
end

local function touchPart(part)
    local root = getRootPart()
    if not root or not part then return false end
    if firetouchinterest then
        pcall(function()
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
        end)
        return true
    end
    return false
end

local function startSpeedHack()
    if speedHackConnection then return end
    speedHackConnection = RunService.Heartbeat:Connect(function()
        if not speedHackEnabled then return end
        local char = LP.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local v = speedSliderValue
        if type(v) == "number" and v == v then
            humanoid.WalkSpeed = v
        end
    end)
end

local function stopSpeedHack()
    if speedHackConnection then
        speedHackConnection:Disconnect()
        speedHackConnection = nil
    end
end

local function startVehicleSpeedHack()
    if VehicleSystem.speedHackConnection then return end
    VehicleSystem.speedHackConnection = RunService.Heartbeat:Connect(function(dt)
        if not VehicleSystem.SpeedHackEnabled then return end
        if VehicleSystem.FlyEnabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.SeatPart then return end
        local seat = hum.SeatPart
        local cap = VehicleSystem.SpeedHackMaxSpeed
        if type(cap) ~= "number" or cap ~= cap or cap <= 0 then return end
        if VehicleSystem.ShiftBoost and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            cap = cap * VehicleSystem.BoostMultiplier
        end

        if seat:IsA("VehicleSeat") then
            pcall(function()
                seat.MaxSpeed = cap
            end)
            return
        end

        local model = seat:FindFirstAncestorOfClass("Model")
        local pp = model and model.PrimaryPart
        if not pp or not pp:IsA("BasePart") then return end
        local look = seat.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude < 1e-3 then return end
        flat = flat.Unit
        local v = pp.AssemblyLinearVelocity
        local fwd = v:Dot(flat)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) and fwd < cap then
            local add = math.min(cap - fwd, 45 * dt * 60)
            pp.AssemblyLinearVelocity = v + flat * add
        end
    end)
end

local function stopVehicleSpeedHack()
    if VehicleSystem.speedHackConnection then
        VehicleSystem.speedHackConnection:Disconnect()
        VehicleSystem.speedHackConnection = nil
    end
end

local flyOriginalGravity = nil
local noclipCollisionCache = {}

local function clearBasePartMotion(part)
    if not part or not part:IsA("BasePart") then return end
    pcall(function()
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function clearCharacterMotion(character)
    if not character then return end
    for _, inst in ipairs(character:GetDescendants()) do
        if inst:IsA("BasePart") then
            clearBasePartMotion(inst)
        end
    end
end

local function restoreNoclipCollisionState()
    for part, canCollide in pairs(noclipCollisionCache) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = canCollide == true
            end)
        end
        noclipCollisionCache[part] = nil
    end
end

local function startFly()
    if flyEnabled then return end
    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    flyEnabled = true
    GlobalState.flyEnabled = true
    if not isFiniteNumber(flySpeed) or flySpeed <= 0 then
        flySpeed = tonumber(GlobalState.flySpeed) or 50
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    clearCharacterMotion(char)
    
    pcall(function()
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Name = "YasiaHubFlyVelocity"
        flyBodyVelocity.P = 9e4
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = rootPart
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "YasiaHubFlyGyro"
        flyBodyGyro.P = 9e4
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = rootPart.CFrame
        flyBodyGyro.Parent = rootPart
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
    end)
    
    flyOriginalGravity = workspace.Gravity
    workspace.Gravity = 0
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or LP.Character ~= char or not rootPart.Parent then
            flyEnabled = false
            GlobalState.flyEnabled = false
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
            flyBodyVelocity = nil
            flyBodyGyro = nil
            pcall(function()
                workspace.Gravity = (isFiniteNumber(gravityValue) and gravityValue) or flyOriginalGravity or 196.2
            end)
            flyOriginalGravity = nil
            return
        end
        if not flyBodyVelocity or not flyBodyGyro then return end
        local camera = workspace.CurrentCamera
        if not camera then return end

        local forwardInput = (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
        local strafeInput = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
        local verticalInput = (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0)
            - ((UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) and 1 or 0)

        local flatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
        if flatLook.Magnitude < 1e-3 then
            flatLook = Vector3.new(0, 0, -1)
        else
            flatLook = flatLook.Unit
        end

        local flatRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
        if flatRight.Magnitude < 1e-3 then
            flatRight = Vector3.new(1, 0, 0)
        else
            flatRight = flatRight.Unit
        end

        local moveDirection = flatLook * forwardInput + flatRight * strafeInput + Vector3.new(0, verticalInput, 0)
        if moveDirection.Magnitude > 1e-3 then
            moveDirection = moveDirection.Unit
        else
            moveDirection = Vector3.zero
        end
        flyBodyVelocity.Velocity = moveDirection * flySpeed
        flyBodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + flatLook)
    end)
end

local function stopFly()
    flyEnabled = false
    GlobalState.flyEnabled = false
    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
    pcall(function()
        workspace.Gravity = (isFiniteNumber(gravityValue) and gravityValue) or flyOriginalGravity or 196.2
    end)
    if humanoid then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if char then
        clearCharacterMotion(char)
    end
    flyBodyVelocity = nil
    flyBodyGyro = nil
    flyConnection = nil
    flyOriginalGravity = nil
end

local noclipConnection = nil
local function startNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    GlobalState.noclipEnabled = true
    restoreNoclipCollisionState()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = LP.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if noclipCollisionCache[part] == nil then
                        noclipCollisionCache[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    noclipEnabled = false
    GlobalState.noclipEnabled = false
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = nil
    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if char then clearCharacterMotion(char) end
    task.delay(0.05, function()
        if noclipEnabled then return end
        restoreNoclipCollisionState()
        if char and LP.Character == char then
            clearCharacterMotion(char)
            if humanoid and humanoid.Parent then
                pcall(function()
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end
    end)
end

local infiniteJumpConnection = nil
local function startInfiniteJump()
    if infiniteJump then return end
    infiniteJump = true
    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    infiniteJump = false
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
end

local godModeConnection = nil
local function startGodMode()
    if godMode then return end
    godMode = true
    pcall(function()
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.MaxHealth = 999999
            LP.Character.Humanoid.Health = 999999
            LP.Character.Humanoid.BreakJointsOnDeath = false
            LP.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if godMode and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                    LP.Character.Humanoid.Health = 999999
                end
            end)
        end
    end)
    
    godModeConnection = LP.CharacterAdded:Connect(function(char)
        pcall(function()
            char:WaitForChild("Humanoid").MaxHealth = 999999
            char.Humanoid.Health = 999999
            char.Humanoid.BreakJointsOnDeath = false
            char.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if godMode then
                    char.Humanoid.Health = 999999
                end
            end)
        end)
    end)
end

local function stopGodMode()
    godMode = false
    if godModeConnection then godModeConnection:Disconnect() end
    pcall(function()
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.MaxHealth = 100
            LP.Character.Humanoid.Health = 100
        end
    end)
end

-- VSPOMOGATELNAYa FUNKTsIYa DLYa OChISTKI RISUNKOV ESP
local function cleanupESPObject(espData)
    if espData.Box then espData.Box:Remove() end
    if espData.Text then espData.Text:Remove() end
    if espData.HealthBar then espData.HealthBar:Remove() end
    if espData.Tracer then espData.Tracer:Remove() end
    if espData.HeadDot then espData.HeadDot:Remove() end
end

-- VSPOMOGATELNAYa FUNKTsIYa DLYa SKRYTIYa VSEKh OBEKTOV ESP
local function hideESPObject(espData)
    if espData.Box then espData.Box.Visible = false end
    if espData.Text then espData.Text.Visible = false end
    if espData.HealthBar then espData.HealthBar.Visible = false end
    if espData.Tracer then espData.Tracer.Visible = false end
    if espData.HeadDot then espData.HeadDot.Visible = false end
end

local function updateESP()
    if not GlobalState.espEnabled then
        for playerRef, obj in pairs(espObjects) do
            cleanupESPObject(obj)
            espObjects[playerRef] = nil
        end
        GlobalState.espObjects = espObjects
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local maxDistance = tonumber(espMaxDistance) or tonumber(GlobalState.espMaxDistance) or 2500
    local textSize = tonumber(espTextSize) or tonumber(GlobalState.espTextSize) or 16
    local baseColor = typeof(espBoxColor) == "Color3" and espBoxColor or (typeof(GlobalState.espBoxColor) == "Color3" and GlobalState.espBoxColor or Color3.fromRGB(255, 0, 0))
    local showBox = espShowBox ~= false
    local showText = espShowText ~= false
    local showHealthBar = espShowHealthBar == true
    local showDistance = espShowDistance ~= false
    local showTracer = espShowTracer == true
    local showHeadDot = espShowHeadDot == true
    local useDisplayName = espUseDisplayName == true
    local showHealthText = espShowHealthText ~= false
    local hideTeammates = espHideTeammates == true
    local onlyAlive = espOnlyAlive ~= false
    local teamColorEnabled = espTeamColor == true
    local rainbowEnabled = espRainbow == true

    espMaxDistance = maxDistance
    espTextSize = textSize
    espBoxColor = baseColor
    GlobalState.espMaxDistance = maxDistance
    GlobalState.espTextSize = textSize
    GlobalState.espBoxColor = baseColor
    
    -- SOZDAEM TABLITsU AKTIVNYKh IGROKOV ZA O(n) VMESTO PROVERKI KAZhDYY RAZ
    local playersDict = {}
    local players = Players:GetPlayers()
    for _, p in pairs(players) do
        playersDict[p] = true
    end
    
    -- UDALYaEM ESP DLYa IGROKOV KOTORYE VYShLI - ODNA ITERATsIYa VMESTO DVUKh VLOZhENNYKh
    for objPlayer, data in pairs(espObjects) do
        if not playersDict[objPlayer] then
            cleanupESPObject(data)
            espObjects[objPlayer] = nil
        end
    end

    local myRoot = getRootPart()
    for _, player in pairs(players) do
        if player ~= LP and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- PROVERYaEM root ODIN RAZ
                local root = character:FindFirstChild("HumanoidRootPart")
                    or character:FindFirstChild("UpperTorso")
                    or character:FindFirstChild("Torso")
                    or character:FindFirstChild("Head")
                
                if root then
                    -- PROVERYaEM FILTRY
                    local sameTeam = LP.Team ~= nil and player.Team ~= nil and LP.Team == player.Team
                    if not ((hideTeammates and sameTeam) or (onlyAlive and humanoid.Health <= 0)) then
                        -- VYChISLYaEM RASSTOYaNIE
                        local distance = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                        if distance <= maxDistance then
                            -- POLUChAEM DANNYE DLYa RISOVANIYa
                            local boxData = getESPBoxData(character, root, camera)
                            if boxData then
                                -- SOZDAEM OBEKT ESP ESLI EGO NET
                                if not espObjects[player] then
                                    local box = Drawing.new("Square")
                                    box.Thickness = 2
                                    box.Filled = false
                                    box.Color = baseColor
                                    
                                    local text = Drawing.new("Text")
                                    text.Size = textSize
                                    text.Center = true
                                    text.Outline = true
                                    text.OutlineColor = Color3.new(0,0,0)
                                    text.Color = Color3.new(1,1,1)
                                    
                                    local healthBar = Drawing.new("Line")
                                    healthBar.Visible = false
                                    healthBar.Color = Color3.fromRGB(0, 255, 0)
                                    healthBar.Thickness = 4
                                    
                                    local tracer = Drawing.new("Line")
                                    tracer.Thickness = 1.5
                                    tracer.Visible = false
                                    tracer.Color = baseColor
                                    
                                    local headDot = Drawing.new("Circle")
                                    headDot.Visible = false
                                    headDot.Filled = false
                                    headDot.NumSides = 18
                                    headDot.Radius = 4
                                    headDot.Thickness = 1.5
                                    headDot.Color = baseColor
                                    
                                    espObjects[player] = {
                                        Box = box,
                                        Text = text,
                                        HealthBar = healthBar,
                                        Tracer = tracer,
                                        HeadDot = headDot,
                                    }
                                end
                                
                                -- OBNOVLYaEM OBEKT ESP
                                local espData = espObjects[player]
                                local pos = boxData.center2D
                                local topLeft = boxData.topLeft
                                local bottomRight = boxData.bottomRight
                                local boxSize = boxData.boxSize
                                
                                -- VYChISLYaEM TsVET
                                local drawColor = rainbowEnabled
                                    and Color3.fromHSV((tick() * 0.15) % 1, 1, 1)
                                    or (teamColorEnabled and (player.TeamColor and player.TeamColor.Color or baseColor) or baseColor)
                                
                                -- OBNOVLYaEM Box
                                espData.Box.Visible = showBox
                                espData.Box.Position = topLeft
                                espData.Box.Size = boxSize
                                espData.Box.Color = drawColor
                                
                                -- OBNOVLYaEM Text
                                if showText then
                                    espData.Text.Visible = true
                                    espData.Text.Size = textSize
                                    espData.Text.Position = Vector2.new(pos.X, topLeft.Y - 15)
                                    
                                    local dist = showDistance and string.format(" | %.0fm", distance) or ""
                                    local display = useDisplayName and (player.DisplayName or player.Name) or player.Name
                                    local hpText = showHealthText and (" | " .. math.floor(humanoid.Health) .. " HP") or ""
                                    espData.Text.Text = display .. hpText .. dist
                                    espData.Text.Color = drawColor
                                else
                                    espData.Text.Visible = false
                                end
                                
                                -- OBNOVLYaEM HealthBar
                                if showHealthBar then
                                    local hp = tonumber(humanoid.Health) or 0
                                    local maxHp = tonumber(humanoid.MaxHealth) or 0
                                    local pct = (maxHp > 0 and hp / maxHp) or 0
                                    pct = math.clamp(pct, 0, 1)
                                    espData.HealthBar.Visible = true
                                    espData.HealthBar.From = Vector2.new(topLeft.X, bottomRight.Y + 5)
                                    espData.HealthBar.To = Vector2.new(topLeft.X + boxSize.X * pct, bottomRight.Y + 5)
                                    espData.HealthBar.Color = Color3.new(1 - pct, pct, 0)
                                else
                                    espData.HealthBar.Visible = false
                                end

                                -- OBNOVLYaEM Tracer
                                if showTracer then
                                    espData.Tracer.Visible = true
                                    espData.Tracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 2)
                                    espData.Tracer.To = Vector2.new(pos.X, pos.Y)
                                    espData.Tracer.Color = drawColor
                                else
                                    espData.Tracer.Visible = false
                                end

                                -- OBNOVLYaEM HeadDot
                                if showHeadDot then
                                    local head = character:FindFirstChild("Head") or root
                                    local headPos, headOnScreen = camera:WorldToViewportPoint(head.Position)
                                    espData.HeadDot.Visible = headOnScreen
                                    espData.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                                    espData.HeadDot.Color = drawColor
                                else
                                    espData.HeadDot.Visible = false
                                end
                            else
                                if espObjects[player] then hideESPObject(espObjects[player]) end
                            end
                        else
                            if espObjects[player] then hideESPObject(espObjects[player]) end
                        end
                    else
                        if espObjects[player] then hideESPObject(espObjects[player]) end
                    end
                else
                    if espObjects[player] then hideESPObject(espObjects[player]) end
                end
            else
                if espObjects[player] then hideESPObject(espObjects[player]) end
            end
        elseif espObjects[player] then
            hideESPObject(espObjects[player])
        end
    end
end

local function startESP()
    if GlobalState.espRunConnection then return end
    GlobalState.espEnabled = true
    espEnabled = true
    GlobalState.espRunConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - (GlobalState._lastESPTick or 0) < 0.05 then return end
        GlobalState._lastESPTick = now
        updateESP()
    end)
    print("[ESP] VKLYuChEN")
end

local function stopESP()
    GlobalState.espEnabled = false
    espEnabled = false
    if GlobalState.espRunConnection then GlobalState.espRunConnection:Disconnect() end
    GlobalState.espRunConnection = nil
    updateESP()
    print("[ESP] OTKLYuChEN")
end

local function setWalkSpeed(speed)
    if type(speed) ~= "number" or speed ~= speed then return end
    speedSliderValue = speed
    pcall(function()
        if LP and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = speed
        end
    end)
end

local function setJumpPower(power)
    if type(power) ~= "number" or power ~= power then return end
    jumpPowerValue = power
    pcall(function()
        if LP and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.JumpPower = power
        end
    end)
end

local function setGravity(grav)
    if type(grav) ~= "number" or grav ~= grav then return end
    gravityValue = grav
    pcall(function()
        if workspace then
            workspace.Gravity = grav
        end
    end)
end

local function teleportToMouse()
    pcall(function()
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") and Mouse then
            local hit = Mouse.Hit
            if hit and hit.Position then
                local mousePos = hit.Position + Vector3.new(0, 2, 0)
                if mousePos.X == mousePos.X and mousePos.Y == mousePos.Y and mousePos.Z == mousePos.Z then
                    rememberCurrentPosition()
                    char.HumanoidRootPart.CFrame = CFrame.new(mousePos)
                else
                    print("[TP] " .. TL("Ошибка: позиция мышки невалидна (NaN)", "Помилка: позиція мишки невалідна (NaN)", "Error: mouse position is invalid (NaN)"))
                end
            end
        end
    end)
end

local function teleportToPlayer(targetPlayer)
    pcall(function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, TeleportSettings.PlayerYOffset, 0)
            if targetPos.X == targetPos.X and targetPos.Y == targetPos.Y and targetPos.Z == targetPos.Z then
                rememberCurrentPosition()
                LP.Character.HumanoidRootPart.CFrame = targetPos
            else
                print("[TP] " .. TL("Ошибка: позиция цели невалидна (NaN)", "Помилка: позиція цілі невалідна (NaN)", "Error: target position is invalid (NaN)"))
            end
        end
    end)
end

local function startBindingTPKey()
    bindingTPKey = true
    GlobalState.bindingTPKey = true
    pcall(function()
        if Library and Library.Notification then
            Library:Notification({
                Title = T("tp_bind_wait_title"),
                Description = T("tp_bind_wait_desc"),
                Duration = 15
            })
        end
    end)
end

local function isClickTPModifierMode()
    return clickTPEnabled
        and typeof(tpBindKey) == "EnumItem"
        and not (tpBindKey.EnumType == Enum.UserInputType and tpBindKey == Enum.UserInputType.MouseButton1)
end

function formatBoundInput(boundInput)
    if typeof(boundInput) ~= "EnumItem" then
        return tostring(boundInput or "?")
    end

    if boundInput.EnumType == Enum.UserInputType then
        if boundInput == Enum.UserInputType.MouseButton1 then return "LMB" end
        if boundInput == Enum.UserInputType.MouseButton2 then return "RMB" end
        if boundInput == Enum.UserInputType.MouseButton3 then return "MMB" end
        return boundInput.Name
    end

    local aliases = {
        LeftShift = "Left Shift",
        RightShift = "Right Shift",
        LeftControl = "Left Ctrl",
        RightControl = "Right Ctrl",
        Backquote = "`",
    }
    return aliases[boundInput.Name] or boundInput.Name
end

function getBindableInputFromUserInput(input)
    if not input then
        return nil
    end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3 then
        return input.UserInputType
    end
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode
    end
    return nil
end

function matchesBoundInput(boundInput, input)
    if typeof(boundInput) ~= "EnumItem" or not input then
        return false
    end
    if boundInput.EnumType == Enum.KeyCode then
        return input.KeyCode == boundInput
    end
    if boundInput.EnumType == Enum.UserInputType then
        return input.UserInputType == boundInput
    end
    return false
end

function getRuntimeKeybindBinding(keybindObject, defaultEnumItem, defaultMode)
    local keyString = defaultEnumItem and tostring(defaultEnumItem) or ""
    local modeString = defaultMode or "Hold"
    if keybindObject and keybindObject.Get then
        local ok, storedKey, storedMode = pcall(function()
            return keybindObject:Get()
        end)
        if ok then
            if type(storedKey) == "string" and storedKey ~= "" then
                keyString = storedKey
            end
            if type(storedMode) == "string" and storedMode ~= "" then
                modeString = storedMode
            end
        end
    end
    return keyString, modeString
end

function matchesRuntimeKeybind(keybindObject, defaultEnumItem, input, requiredMode)
    local keyString, modeString = getRuntimeKeybindBinding(keybindObject, defaultEnumItem, requiredMode or "Hold")
    if requiredMode and modeString ~= requiredMode then
        return false
    end
    return keyString == tostring(input.KeyCode) or keyString == tostring(input.UserInputType)
end

local function normalizeRuntimeKeybindMode(modeString, fallbackMode)
    local mode = tostring(modeString or fallbackMode or "Hold")
    if mode ~= "Hold" and mode ~= "Toggle" and mode ~= "Always" then
        mode = tostring(fallbackMode or "Hold")
    end
    return mode
end

local function getRuntimeKeybindMatchData(keybindObject, defaultEnumItem, input, fallbackMode)
    if not input then
        return false, normalizeRuntimeKeybindMode(fallbackMode, "Hold")
    end
    local keyString, modeString = getRuntimeKeybindBinding(keybindObject, defaultEnumItem, fallbackMode or "Hold")
    local mode = normalizeRuntimeKeybindMode(modeString, fallbackMode or "Hold")
    local matches = keyString == tostring(input.KeyCode) or keyString == tostring(input.UserInputType)
    return matches, mode
end

local function refreshAimbotBindState()
    local _, modeString = getRuntimeKeybindBinding(AimbotRuntime.AimKeybind, Enum.UserInputType.MouseButton2, "Hold")
    local mode = normalizeRuntimeKeybindMode(modeString, "Hold")
    local keybindActive = AimbotRuntime.KeybindActive or mode == "Always"
    AimbotSettings.BindActive = AimbotSettings.Enabled and (AimbotRuntime.ManualActivation or keybindActive) or false
end

local function refreshSpinBindState()
    local _, modeString = getRuntimeKeybindBinding(AimbotRuntime.SpinKeybind, Enum.KeyCode.Q, "Hold")
    local mode = normalizeRuntimeKeybindMode(modeString, "Hold")
    local keybindActive = AimbotRuntime.SpinKeybindActive or mode == "Always"
    AimbotSettings.SpinBindActive = AimbotSettings.SpinBot and keybindActive or false
end

local function refreshTriggerBindState()
    local _, modeString = getRuntimeKeybindBinding(AimbotRuntime.TriggerKeybind, Enum.KeyCode.E, "Hold")
    local mode = normalizeRuntimeKeybindMode(modeString, "Hold")
    local keybindActive = AimbotRuntime.TriggerKeybindActive or mode == "Always"
    AimbotSettings.TriggerBindActive = AimbotSettings.TriggerBot and keybindActive or false
end

local function refreshCombatBindStates()
    refreshAimbotBindState()
    refreshSpinBindState()
    refreshTriggerBindState()
end

function updateTpBindStatusLabel()
    if RuntimeRefs and RuntimeRefs.TpBindStatusLabel and RuntimeRefs.TpBindStatusLabel.SetText then
        RuntimeRefs.TpBindStatusLabel:SetText(TF("tp_bind_status", formatBoundInput(tpBindKey)))
    end
end

local function changeTPBind(newKey)
    if newKey == Enum.KeyCode.Escape then
        bindingTPKey = false
        GlobalState.bindingTPKey = false
        tpClickModifierActive = false
        pcall(function()
            if Library and Library.Notification then
                Library:Notification({
                    Title = T("tp_bind_wait_title"),
                    Description = T("tp_bind_cancel_desc"),
                    Duration = 3
                })
            end
        end)
        return
    end
    tpBindKey = newKey
    bindingTPKey = false
    GlobalState.tpBindKey = newKey
    GlobalState.bindingTPKey = false
    tpClickModifierActive = false
    updateTpBindStatusLabel()
    pcall(function()
        if Library and Library.Notification then
            Library:Notification({
                Title = T("tp_bind_set_title"),
                Description = TF("tp_bind_set_desc", formatBoundInput(newKey)),
                Duration = 3
            })
        end
    end)
end

local function bringAll()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame
            end
        end
    end)
end

local function setupVehicleFlyInstances(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if hrp:FindFirstChild(VehicleSystem.velocityName) then 
        hrp:FindFirstChild(VehicleSystem.velocityName):Destroy() 
    end
    if hrp:FindFirstChild(VehicleSystem.gyroName) then 
        hrp:FindFirstChild(VehicleSystem.gyroName):Destroy() 
    end
    
    VehicleSystem.VelocityHandler = Instance.new("BodyVelocity")
    VehicleSystem.VelocityHandler.Name = VehicleSystem.velocityName
    VehicleSystem.VelocityHandler.Parent = hrp
    VehicleSystem.VelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    VehicleSystem.VelocityHandler.Velocity = Vector3.zero
    
    VehicleSystem.GyroHandler = Instance.new("BodyGyro")
    VehicleSystem.GyroHandler.Name = VehicleSystem.gyroName
    VehicleSystem.GyroHandler.Parent = hrp
    VehicleSystem.GyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    VehicleSystem.GyroHandler.P = 1000
    VehicleSystem.GyroHandler.D = 50
    VehicleSystem.GyroHandler.CFrame = hrp.CFrame
end

local function disableVehicleFly()
    if VehicleSystem.VelocityHandler then
        VehicleSystem.VelocityHandler:Destroy()
        VehicleSystem.VelocityHandler = nil
    end
    if VehicleSystem.GyroHandler then
        VehicleSystem.GyroHandler:Destroy()
        VehicleSystem.GyroHandler = nil
    end
    VehicleSystem.MovementDirection = {}
    
    if VehicleSystem.seatConnection then
        VehicleSystem.seatConnection:Disconnect()
        VehicleSystem.seatConnection = nil
    end
    if VehicleSystem.unseatConnection then
        VehicleSystem.unseatConnection:Disconnect()
        VehicleSystem.unseatConnection = nil
    end
end

local function handleVehicleInput()
    local character = LP.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local canFly = VehicleSystem.FlyEnabled and (humanoid.SeatPart or VehicleSystem.FwF)
    
    if canFly then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not VehicleSystem.VelocityHandler then return end
        
        local gyro = hrp:FindFirstChild(VehicleSystem.gyroName)
        local speed = VehicleSystem.Speed
        local velocity = Vector3.zero
        
        local function getMovementCFrame()
            if VehicleSystem.Pitch and gyro then
                return gyro.CFrame
            elseif gyro then
                local lookVector = gyro.CFrame.LookVector
                return CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            end
            return hrp.CFrame
        end
        
        local movementCFrame = getMovementCFrame()
        local dirs = VehicleSystem.MovementDirection
        
        if table.find(dirs, "forward") then
            velocity = velocity + movementCFrame.LookVector * speed
        end
        if table.find(dirs, "backward") then
            velocity = velocity - movementCFrame.LookVector * speed
        end
        if table.find(dirs, "left") then
            velocity = velocity - movementCFrame.RightVector * speed
        end
        if table.find(dirs, "right") then
            velocity = velocity + movementCFrame.RightVector * speed
        end
        if table.find(dirs, "up") then
            velocity = velocity + Vector3.new(0, VehicleSystem.UpSpeed, 0)
        end
        if table.find(dirs, "down") then
            velocity = velocity + Vector3.new(0, -VehicleSystem.UpSpeed, 0)
        end
        
        if table.find(dirs, "rotateLeft") and gyro then
            gyro.CFrame = gyro.CFrame * CFrame.Angles(0, math.rad(-VehicleSystem.RotationSpeed), 0)
        end
        if table.find(dirs, "rotateRight") and gyro then
            gyro.CFrame = gyro.CFrame * CFrame.Angles(0, math.rad(VehicleSystem.RotationSpeed), 0)
        end
        
        if VehicleSystem.AntiLock and humanoid.SeatPart then
            local seat = humanoid.SeatPart
            local seatCF = seat.CFrame
            local seatVelocity = Vector3.zero
            
            if table.find(dirs, "forward") then seatVelocity = seatVelocity + seatCF.LookVector * speed
            elseif table.find(dirs, "backward") then seatVelocity = seatVelocity - seatCF.LookVector * speed end
            if table.find(dirs, "left") then seatVelocity = seatVelocity - seatCF.RightVector * speed
            elseif table.find(dirs, "right") then seatVelocity = seatVelocity + seatCF.RightVector * speed end
            if table.find(dirs, "up") then seatVelocity = seatVelocity + seatCF.UpVector * VehicleSystem.UpSpeed
            elseif table.find(dirs, "down") then seatVelocity = seatVelocity - seatCF.UpVector * VehicleSystem.UpSpeed end
            
            VehicleSystem.VelocityHandler.Velocity = seatVelocity
        else
            VehicleSystem.VelocityHandler.Velocity = velocity
        end
        
        if not VehicleSystem.AntiLock and gyro then
            local camera = workspace.CurrentCamera
            if VehicleSystem.Pitch then
                gyro.CFrame = camera.CFrame
            else
                local flatLook = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                gyro.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
            end
        end
    else
        if VehicleSystem.VelocityHandler then
            VehicleSystem.VelocityHandler.Velocity = Vector3.zero
        end
    end
end

findPlayer = function(name)
    name = tostring(name or ""):lower()
    if name == "" then return nil end
    
    -- GRUZIM KESh S TTL 1 SEK DLYa IZBEZhANIYa DVOYNOGO O(n) POISKA KAZhDYY FREYM
    local now = tick()
    if not AdminSettings.PlayerCache[name] or now - AdminSettings.PlayerCacheTime > 1 then
        AdminSettings.PlayerCacheTime = now
        
        -- BYSTRYY POISK - TOChNOE SOVPADENIE
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and (plr.Name:lower() == name or ((plr.DisplayName and plr.DisplayName:lower()) == name)) then
                AdminSettings.PlayerCache[name] = plr
                return plr
            end
        end
        
        -- POISK PO PODSTROKE ESLI TOChNOE SOVPADENIE NE NAYDENO
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                if plr.Name:lower():find(name, 1, true) or (plr.DisplayName and plr.DisplayName:lower():find(name, 1, true)) then
                    AdminSettings.PlayerCache[name] = plr
                    return plr
                end
            end
        end
        
        AdminSettings.PlayerCache[name] = false
        return nil
    end
    
    -- VOZVRASchAEM KEShIROVANNOE ZNAChENIE
    local cached = AdminSettings.PlayerCache[name]
    if cached == false then
        return nil
    end
    if cached and cached.Parent then
        return cached
    end
    
    -- ESLI OBEKT UDALEN, OChISchAEM KESh
    AdminSettings.PlayerCache[name] = nil
    return nil
end

local function flingNotify(title, desc, dur)
    pcall(function()
        Library:Notification({ Title = title or "Fling", Description = desc or "", Duration = dur or 3 })
    end)
end

local function skidFlingTarget(TargetPlayer)
    local Player = LP
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and (Humanoid.RootPart or Character:FindFirstChild("HumanoidRootPart"))
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and (THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart"))
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if Character and Humanoid and RootPart then
        if RootPart.AssemblyLinearVelocity.Magnitude < 50 then
            FlingSystem.OldPos = RootPart.CFrame
        end

        if THumanoid and THumanoid:GetState() == Enum.HumanoidStateType.Seated then
            flingNotify("OShIBKA", TargetPlayer.Name .. " SIDIT", 2)
            return
        end

        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local function FPos(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            if Character.PrimaryPart then
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            end
            RootPart.AssemblyLinearVelocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local function SFBasePart(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.AssemblyLinearVelocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingSystem.SkidLoopActive or not FlingSystem.Active
        end

        if FlingSystem.FPDH == nil then
            FlingSystem.FPDH = workspace.FallenPartsDestroyHeight
        end
        workspace.FallenPartsDestroyHeight = 0 / 0

        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.zero
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            flingNotify("OShIBKA", TargetPlayer.Name .. "  NET ChASTEY", 2)
            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.CurrentCamera.CameraSubject = Humanoid
            return
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        if FlingSystem.OldPos then
            local oldCf = FlingSystem.OldPos
            repeat
                RootPart.CFrame = oldCf * CFrame.new(0, 0.5, 0)
                if Character.PrimaryPart then
                    Character:SetPrimaryPartCFrame(oldCf * CFrame.new(0, 0.5, 0))
                end
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                task.wait()
            until (RootPart.Position - oldCf.Position).Magnitude < 25
            workspace.FallenPartsDestroyHeight = FlingSystem.FPDH
        end
    else
        flingNotify("OShIBKA", "PERSONAZh NE GOTOV", 2)
    end
end

local function stopSkidFling()
    FlingSystem.Active = false
    FlingSystem.SkidLoopActive = false
    if FlingSystem.FlingThread then
        pcall(function()
            task.cancel(FlingSystem.FlingThread)
        end)
        FlingSystem.FlingThread = nil
    end
end

local function updateFlingStatusText()
    local n = 0
    for _ in pairs(FlingSystem.SelectedTargets) do
        n = n + 1
    end
    if FlingSystem.StatusLabel and FlingSystem.StatusLabel.SetText then
        pcall(function()
            FlingSystem.StatusLabel:SetText(
                TL("Целей в списке", "Цілей у списку", "Targets selected")
                .. ": "
                .. n
                .. " | "
                .. (FlingSystem.Active and TL("АКТИВЕН", "АКТИВНИЙ", "ACTIVE") or TL("СТОП", "СТОП", "STOP"))
            )
        end)
    end
end

local function startMultiSkidFling()
    if FlingSystem.FlingThread then
        task.cancel(FlingSystem.FlingThread)
        FlingSystem.FlingThread = nil
    end
    FlingSystem.SkidLoopActive = true
    FlingSystem.FlingThread = task.spawn(function()
        while FlingSystem.Active do
            local valid = {}
            for name, plr in pairs(FlingSystem.SelectedTargets) do
                if plr and plr.Parent then
                    valid[name] = plr
                else
                    FlingSystem.SelectedTargets[name] = nil
                end
            end
            for _, plr in pairs(valid) do
                if not FlingSystem.Active then break end
                skidFlingTarget(plr)
                task.wait(0.1)
            end
            updateFlingStatusText()
            task.wait(0.5)
        end
        FlingSystem.SkidLoopActive = false
    end)
end

local function applyInvisToCharacter(char)
    if not char or not MiscSettings.Invis then return end
    pcall(function()
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                d.LocalTransparencyModifier = 1
            end
        end
    end)
end

local function clearInvisFromCharacter(char)
    if not char then return end
    pcall(function()
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                d.LocalTransparencyModifier = 0
            end
        end
    end)
end

local function setInvisToggle(on)
    MiscSettings.Invis = on
    if MiscSettings.InvisConn then
        MiscSettings.InvisConn:Disconnect()
        MiscSettings.InvisConn = nil
    end
    local char = LP.Character
    if on then
        applyInvisToCharacter(char)
        MiscSettings.InvisConn = LP.CharacterAdded:Connect(function(c)
            task.defer(function()
                applyInvisToCharacter(c)
            end)
        end)
    else
        clearInvisFromCharacter(char)
    end
end

local function setAntiAfk(on)
    if MiscSettings.AntiAfkConn then
        MiscSettings.AntiAfkConn:Disconnect()
        MiscSettings.AntiAfkConn = nil
    end
    if on then
        MiscSettings.AntiAfkConn = LP.Idled:Connect(function()
            pcall(function()
                pcall(function()
                    VirtualUser:CaptureController()
                end)
                VirtualUser:Button2Down(Vector2.new(0, 0))
                task.wait(0.05)
                VirtualUser:Button2Up(Vector2.new(0, 0))
            end)
        end)
    end
end

local function setFullbright(on)
    if on then
        MiscSettings.SavedBrightness = Lighting.Brightness
        MiscSettings.SavedFogEnd = Lighting.FogEnd
        MiscSettings.SavedClockTime = Lighting.ClockTime
        Lighting.Brightness = 2.5
        Lighting.FogEnd = 1e9
        Lighting.ClockTime = 14
    else
        if MiscSettings.SavedBrightness ~= nil then
            Lighting.Brightness = MiscSettings.SavedBrightness
            Lighting.FogEnd = MiscSettings.SavedFogEnd
            Lighting.ClockTime = MiscSettings.SavedClockTime
        end
    end
end

setNoFog = function(on)
    if on then
        if MiscSettings.SavedFogEnd == nil then
            MiscSettings.SavedFogEnd = Lighting.FogEnd
        end
        Lighting.FogEnd = 1e9
    elseif MiscSettings.SavedFogEnd ~= nil then
        Lighting.FogEnd = MiscSettings.SavedFogEnd
    end
end

local function setSpinCharacter(on)
    if FunSettings.SpinConn then
        FunSettings.SpinConn:Disconnect()
        FunSettings.SpinConn = nil
    end
    if FunSettings.SpinVel then
        pcall(function() FunSettings.SpinVel:Destroy() end)
        FunSettings.SpinVel = nil
    end
    if not on then return end
    FunSettings.SpinConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not FunSettings.SpinVel or not FunSettings.SpinVel.Parent then
            FunSettings.SpinVel = Instance.new("BodyAngularVelocity")
            FunSettings.SpinVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            FunSettings.SpinVel.AngularVelocity = Vector3.new(0, FunSettings.SpinSpeed, 0)
            FunSettings.SpinVel.Parent = hrp
        else
            FunSettings.SpinVel.AngularVelocity = Vector3.new(0, FunSettings.SpinSpeed, 0)
        end
    end)
end

local function runFarmCycleOptimized()
    if not (FarmSettings.AutoEnabled or FarmSettings.PromptEnabled or FarmSettings.ClickEnabled or FarmSettings.TouchEnabled or FarmSettings.AutoCollectTools) then
        return
    end
    local root = getRootPart()
    if not root then return end

    local actions = 0
    local rootPos = root.Position
    local usePrompts = FarmSettings.AutoEnabled or FarmSettings.PromptEnabled
    local useClicks = FarmSettings.AutoEnabled or FarmSettings.ClickEnabled
    local useTouches = FarmSettings.AutoEnabled or FarmSettings.TouchEnabled
    local useTools = FarmSettings.AutoEnabled or FarmSettings.AutoCollectTools
    
    -- OPTIMIZIROVANNYY LOKALNYY POISK VMESTO sKANIROVANIYa VSEY IGRY
    local function checkInstanceNearby(inst)
        if actions >= FarmSettings.MaxPerCycle then return end
        
        local part = inst:IsA("BasePart") and inst or inst.Parent
        if not (part and part:IsA("BasePart")) then return end
        if FarmSettings.IgnorePlayers then
            local ownerModel = part:FindFirstAncestorOfClass("Model")
            if ownerModel and Players:GetPlayerFromCharacter(ownerModel) then
                return
            end
        end
        
        local dist = (part.Position - rootPos).Magnitude
        if dist > FarmSettings.AutoRadius then return end

        if usePrompts and inst:IsA("ProximityPrompt") then
            local targetPart = part:IsA("BasePart") and part or part:FindFirstChildWhichIsA("BasePart")
            if targetPart and (matchesFilter(inst.Name, FarmSettings.PromptFilter) or matchesFilter(targetPart.Name, FarmSettings.PromptFilter)) then
                if FarmSettings.TeleportToTargets then
                    teleportLocalTo(targetPart.CFrame + Vector3.new(0, 3, 0))
                end
                if usePrompt(inst) then
                    actions = actions + 1
                end
            end
        elseif useClicks and inst:IsA("ClickDetector") then
            local targetPart = part:IsA("BasePart") and part or part:FindFirstChildWhichIsA("BasePart")
            if targetPart and (matchesFilter(inst.Name, FarmSettings.ClickFilter) or matchesFilter(targetPart.Name, FarmSettings.ClickFilter)) then
                if FarmSettings.TeleportToTargets then
                    teleportLocalTo(targetPart.CFrame + Vector3.new(0, 3, 0))
                end
                if useClickDetector(inst) then
                    actions = actions + 1
                end
            end
        end
    end

    -- PROVERYaEM TOLKO RYaDOM, A NE VSYu IGRU
    local region = workspace:FindPartBoundsInRadius(rootPos, FarmSettings.AutoRadius)
    if FarmSettings.PreferNearest then
        table.sort(region, function(a, b)
            return (a.Position - rootPos).Magnitude < (b.Position - rootPos).Magnitude
        end)
    end
    for _, part in pairs(region) do
        if actions >= FarmSettings.MaxPerCycle then break end
        local skipPart = false
        if FarmSettings.IgnorePlayers then
            local ownerModel = part:FindFirstAncestorOfClass("Model")
            skipPart = ownerModel and Players:GetPlayerFromCharacter(ownerModel) ~= nil or false
        end
        if not skipPart then
        
            -- ISchEM ProximityPrompt I ClickDetector V ETOY ChASTI
            if usePrompts then
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("ProximityPrompt") and (matchesFilter(child.Name, FarmSettings.PromptFilter) or matchesFilter(part.Name, FarmSettings.PromptFilter)) then
                        if FarmSettings.TeleportToTargets then
                            teleportLocalTo(part.CFrame + Vector3.new(0, 3, 0))
                        end
                        if usePrompt(child) then
                            actions = actions + 1
                        end
                    end
                end
            end

            if useClicks then
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("ClickDetector") and (matchesFilter(child.Name, FarmSettings.ClickFilter) or matchesFilter(part.Name, FarmSettings.ClickFilter)) then
                        if FarmSettings.TeleportToTargets then
                            teleportLocalTo(part.CFrame + Vector3.new(0, 3, 0))
                        end
                        if useClickDetector(child) then
                            actions = actions + 1
                        end
                    end
                end
            end

            if useTouches then
                local hasTouchInterest = part:FindFirstChildWhichIsA("TouchTransmitter") ~= nil
                if hasTouchInterest and matchesFilter(part.Name, FarmSettings.TouchFilter) then
                    if FarmSettings.TeleportToTargets then
                        teleportLocalTo(part.CFrame + Vector3.new(0, 3, 0))
                    end
                    if touchPart(part) then
                        actions = actions + 1
                    end
                end
            end
        end
    end
    
    -- AutoCollectTools - PROVERYaEM TOLKO V Backpack I workspace
    if useTools and actions < FarmSettings.MaxPerCycle then
        for _, tool in pairs(workspace:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle and (handle.Position - rootPos).Magnitude <= FarmSettings.AutoRadius then
                    if touchPart(handle) then
                        actions = actions + 1
                    end
                end
            end
            if actions >= FarmSettings.MaxPerCycle then break end
        end
    end
end

runFarmCycle = function()
    runFarmCycleOptimized()
end

GlobalState.MainHeartbeatConnection = RunService.Heartbeat:Connect(function()
    local character = getCharacter()
    local humanoid = getHumanoid(character)
    local root = getRootPart(character)
    if not humanoid or not root then
        return
    end

    if MovementSettings.BunnyHop and humanoid.MoveDirection.Magnitude > 0.05 and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if MovementSettings.Glide and humanoid.FloorMaterial == Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local vel = root.AssemblyLinearVelocity
        if vel.Y < MovementSettings.GlideFallSpeed then
            root.AssemblyLinearVelocity = Vector3.new(vel.X, MovementSettings.GlideFallSpeed, vel.Z)
        end
    end

    if MovementSettings.AirStuck then
        root.Anchored = true
        root.AssemblyLinearVelocity = Vector3.zero
    elseif root.Anchored and not antiFlingEnabled then
        root.Anchored = false
    end

    if MovementSettings.AntiSit and humanoid.Sit then
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    if MovementSettings.AntiPlatformStand and humanoid.PlatformStand and not flyEnabled then
        humanoid.PlatformStand = false
    end

    if MovementSettings.AntiVoid then
        local now = tick()
        local voidY = tonumber(MovementSettings.VoidY) or -40
        local rescueOffset = math.clamp(tonumber(MovementSettings.RescueOffset) or 6, 2, 30)
        local vel = root.AssemblyLinearVelocity
        local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
        local stableForSave = humanoid.FloorMaterial ~= Enum.Material.Air
            and not humanoid.Sit
            and not root.Anchored
            and not flyEnabled
            and not noclipEnabled
            and horizontalSpeed <= (tonumber(MovementSettings.SafeVelocityLimit) or 90)
            and math.abs(vel.Y) <= 25

        if stableForSave and root.Position.Y > voidY + math.max(4, rescueOffset) and now - (MovementSettings.LastSafeAt or 0) >= 0.15 then
            MovementSettings.LastSafeCF = root.CFrame
            MovementSettings.LastSafeAt = now
        end
        if not flyEnabled and not noclipEnabled
            and root.Position.Y < voidY
            and typeof(MovementSettings.LastSafeCF) == "CFrame"
            and now - (MovementSettings.LastRescueAt or 0) >= 0.75
        then
            MovementSettings.LastRescueAt = now
            local safeCF = MovementSettings.LastSafeCF
            local safeLook = Vector3.new(safeCF.LookVector.X, 0, safeCF.LookVector.Z)
            if safeLook.Magnitude < 1e-3 then
                safeLook = Vector3.new(0, 0, -1)
            else
                safeLook = safeLook.Unit
            end
            local safePos = safeCF.Position + Vector3.new(0, rescueOffset, 0)
            if safePos.Y < voidY + rescueOffset then
                safePos = Vector3.new(safePos.X, voidY + rescueOffset + 4, safePos.Z)
            end
            root.CFrame = CFrame.new(safePos, safePos + safeLook)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            pcall(function()
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end

    if MovementSettings.CameraSmooth then
        local moveDir = humanoid.MoveDirection
        local targetOffset = Vector3.new(-moveDir.X * (MovementSettings.CameraTiltAmount or 0.85), 0, 0)
        humanoid.CameraOffset = humanoid.CameraOffset:Lerp(targetOffset, 0.16)
    elseif humanoid.CameraOffset.Magnitude > 0.01 then
        humanoid.CameraOffset = humanoid.CameraOffset:Lerp(Vector3.zero, 0.2)
    end

    local strafeMultiplier = tonumber(MovementSettings.StrafeMultiplier) or 1
    if strafeMultiplier > 1 and not flyEnabled and not root.Anchored then
        local strafeInput = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
        local camera = workspace.CurrentCamera
        if camera then
            local flatRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
            if flatRight.Magnitude > 1e-3 then
                local rightUnit = flatRight.Unit
                local vel = root.AssemblyLinearVelocity
                local horizontal = Vector3.new(vel.X, 0, vel.Z)
                local baseSpeed = math.max(tonumber(humanoid.WalkSpeed) or 16, 16)
                local sideCap = math.max(0, (strafeMultiplier - 1) * baseSpeed * 0.9)
                local sideStep = math.max(1.25, sideCap * 0.18)
                local currentSideSpeed = horizontal:Dot(rightUnit)
                local targetSideSpeed = strafeInput * sideCap
                local nextSideSpeed = currentSideSpeed + math.clamp(targetSideSpeed - currentSideSpeed, -sideStep, sideStep)
                local forwardOnly = horizontal - rightUnit * currentSideSpeed
                local newHorizontal = forwardOnly + rightUnit * nextSideSpeed
                local totalCap = math.max(baseSpeed * strafeMultiplier, baseSpeed + sideCap)
                if newHorizontal.Magnitude > totalCap then
                    newHorizontal = newHorizontal.Unit * totalCap
                end
                root.AssemblyLinearVelocity = Vector3.new(newHorizontal.X, vel.Y, newHorizontal.Z)
            end
        end
    end

    if UtilityFeatureSettings.HideLocalName then
        setLocalNameHidden(true)
    end

    if FunSettings.RainbowBody then
        FunSettings.LastRainbowTick = FunSettings.LastRainbowTick or 0
        if tick() - FunSettings.LastRainbowTick >= 0.08 then
            FunSettings.LastRainbowTick = tick()
            setLocalCharacterColor(Color3.fromHSV((tick() * (FunSettings.RainbowRate or 0.2)) % 1, 0.85, 1))
        end
    end

    handleAimbotBotsAndRandom()

    if CombatSettings.AutoToolSpam and tick() - CombatSettings.LastToolSpam >= CombatSettings.ToolSpamInterval then
        local tool = getCurrentTool()
        if tool then
            CombatSettings.LastToolSpam = tick()
            pcall(function()
                tool:Activate()
            end)
        end
    end

    if CombatSettings.Triggerbot and tick() - (CombatSettings.LastQuickTrigger or 0) >= math.max(0.05, CombatSettings.ToolSpamInterval or 0.15) then
        local targetPlayer
        local targetPart = Mouse and Mouse.Target
        local ownerModel = targetPart and targetPart:FindFirstAncestorOfClass("Model")
        if ownerModel then
            targetPlayer = Players:GetPlayerFromCharacter(ownerModel)
        end
        if targetPlayer and targetPlayer ~= LP and isAlivePlayer(targetPlayer) and isEnemyPlayer(targetPlayer) then
            local targetRoot = getRootPart(targetPlayer.Character)
            if targetRoot and (targetRoot.Position - root.Position).Magnitude <= math.max(8, (CombatSettings.Reach or 1.5) * 12) then
                local tool = getCurrentTool()
                if tool then
                    CombatSettings.LastQuickTrigger = tick()
                    pcall(function()
                        tool:Activate()
                    end)
                end
            end
        end
    end

    -- Hitbox expansion ISPOLZUET event-driven SISTEMU VMESTO OBNOVLENIYa KAZhDYY FREYM
    -- ETO PREDOTVRASchAET O(n) ITERATsII ChEREZ VSEKh IGROKOV I VYZYVAET LAG

    if FunSettings.Bounce and humanoid.FloorMaterial ~= Enum.Material.Air and math.abs(root.AssemblyLinearVelocity.Y) < 1.5 then
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X, FunSettings.BouncePower, v.Z)
    end

    if MovementSettings.AutoRotateNearest and tick() - MovementSettings.AutoRotateLastUpdate >= MovementSettings.AutoRotateUpdateInterval then
        MovementSettings.AutoRotateLastUpdate = tick()
        local targetPart = getClosestAimPart()
        if targetPart then
            root.CFrame = CFrame.new(root.Position, Vector3.new(targetPart.Position.X, root.Position.Y, targetPart.Position.Z))
        end
    end

    if FunSettings.Orbit then
        -- KEShIRUEM TsEL Orbit NA 0.5 SEK ChTOBY NE VYZYVAT findPlayer KAZhDYY FREYM
        local now = tick()
        if now - FunSettings.OrbitCacheTime > 0.5 then
            FunSettings.OrbitCacheTime = now
            FunSettings.OrbitCachedTarget = Players:FindFirstChild(FunSettings.OrbitTarget) or findPlayer(FunSettings.OrbitTarget)
        end
        
        if FunSettings.OrbitCachedTarget and FunSettings.OrbitCachedTarget.Parent then
            local targetRoot = getRootPart(FunSettings.OrbitCachedTarget.Character)
            if targetRoot then
                local angle = tick() * FunSettings.OrbitSpeed
                local offset = Vector3.new(math.cos(angle) * FunSettings.OrbitRadius, 2.5, math.sin(angle) * FunSettings.OrbitRadius)
                root.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
            end
        end
    end

    if AdminSettings.FollowEnabled then
        -- KEShIRUEM TsEL Follow NA 0.5 SEK ChTOBY NE VYZYVAT findPlayer KAZhDYY FREYM
        local now = tick()
        if now - AdminSettings.FollowCacheTime > 0.5 then
            AdminSettings.FollowCacheTime = now
            AdminSettings.FollowCachedTarget = Players:FindFirstChild(AdminSettings.FollowTarget) or findPlayer(AdminSettings.FollowTarget)
        end
        
        if AdminSettings.FollowCachedTarget and AdminSettings.FollowCachedTarget.Parent then
            local targetRoot = getRootPart(AdminSettings.FollowCachedTarget.Character)
            if targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, AdminSettings.FollowDistance)
            end
        end
    end

    if AdminSettings.HighlightTarget then
        local target = Players:FindFirstChild(AdminSettings.FollowTarget ~= "" and AdminSettings.FollowTarget or AdminSettings.SpectateName)
            or findPlayer(AdminSettings.FollowTarget ~= "" and AdminSettings.FollowTarget or AdminSettings.SpectateName)
        if target then
            setTargetHighlight(target)
        elseif AdminSettings.HighlightObject then
            pcall(function() AdminSettings.HighlightObject:Destroy() end)
            AdminSettings.HighlightObject = nil
        end
    elseif AdminSettings.HighlightObject then
        pcall(function() AdminSettings.HighlightObject:Destroy() end)
        AdminSettings.HighlightObject = nil
    end

    if tick() - (HighlightSettings.LastUpdate or 0) >= 0.15 then
        HighlightSettings.LastUpdate = tick()
        updatePlayerHighlights()
    end

    -- Noclip DLYa MAShIN - TOLKO ODIN RAZ PRI VKhODE, A NE KAZhDYY FREYM!
    if VehicleSystem.NoclipEnabled and humanoid.SeatPart then
        local vehicle = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
        if vehicle and vehicle ~= VehicleSystem.NoclipLastVehicle then
            -- NOVAYa MAShINA, OBNOVLYaEM noclip ODIN RAZ
            VehicleSystem.NoclipLastVehicle = vehicle
            setVehicleModelCollision(vehicle, false)
            VehicleSystem.NoclipProcessed = true
        end
    elseif VehicleSystem.NoclipProcessed or humanoid.SeatPart == nil then
        -- VYShLI IZ MAShINY ILI OTKLYuChILI noclip, VOSSTANAVLIVAEM
        VehicleSystem.NoclipLastVehicle = nil
        VehicleSystem.NoclipProcessed = false
        for part, oldCanCollide in pairs(VehicleSystem.NoclipCache) do
            pcall(function()
                if part and part.Parent then part.CanCollide = oldCanCollide end
            end)
            VehicleSystem.NoclipCache[part] = nil
        end
    elseif next(VehicleSystem.NoclipCache) ~= nil then
        for part, oldCanCollide in pairs(VehicleSystem.NoclipCache) do
            pcall(function()
                if part and part.Parent then part.CanCollide = oldCanCollide end
            end)
            VehicleSystem.NoclipCache[part] = nil
        end
    end

    if (FarmSettings.AutoEnabled or FarmSettings.PromptEnabled or FarmSettings.ClickEnabled or FarmSettings.TouchEnabled or FarmSettings.AutoCollectTools)
        and tick() - FarmSettings.LastRun >= FarmSettings.Interval
    then
        FarmSettings.LastRun = tick()
        runFarmCycle()
    end

    runChatLoopTick()

    if RuntimeRefs.PlayerInfoLabel and RuntimeRefs.PlayerInfoLabel.SetText then
        local pickName = AdminSettings.SpectateName ~= "" and AdminSettings.SpectateName or AdminSettings.FollowTarget
        local plr = Players:FindFirstChild(pickName) or findPlayer(pickName)
        if plr and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local tRoot = getRootPart(plr.Character)
            local hp = hum and math.floor(hum.Health) or 0
            local dist = (tRoot and root and math.floor((tRoot.Position - root.Position).Magnitude)) or 0
            RuntimeRefs.PlayerInfoLabel:SetText(plr.Name .. " | HP: " .. hp .. " | Dist: " .. dist)
        else
            RuntimeRefs.PlayerInfoLabel:SetText(TL("Игрок не выбран", "Гравця не вибрано", "No player selected"))
        end
    end

    if RuntimeRefs.VehicleInfoLabel and RuntimeRefs.VehicleInfoLabel.SetText and root then
        local currentTick = tick()
        if (GlobalState._lastVehicleInfoTick or 0) == 0 or (currentTick - (GlobalState._lastVehicleInfoTick or 0)) >= 0.5 then
            GlobalState._lastVehicleInfoTick = currentTick
            local speed = root.AssemblyLinearVelocity and math.floor(root.AssemblyLinearVelocity.Magnitude) or 0
            RuntimeRefs.VehicleInfoLabel:SetText(TL("Скорость", "Швидкість", "Speed") .. ": " .. speed .. " | Seat: " .. tostring(humanoid and humanoid.SeatPart ~= nil or false))
        end
    end

    local liveTick = tick()
    if (GlobalState._lastLiveStatusTick or 0) == 0 or (liveTick - (GlobalState._lastLiveStatusTick or 0)) >= 0.35 then
        GlobalState._lastLiveStatusTick = liveTick
        refreshLiveStatusLabels()
    end
end)

GlobalState.MainInputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if bindingTPKey then
        if input.KeyCode == Enum.KeyCode.Escape then
            changeTPBind(Enum.KeyCode.Escape)
            return
        end

        local bindableInput = getBindableInputFromUserInput(input)
        if bindableInput then
            changeTPBind(bindableInput)
        end
        return
    end

    if UserInputService:GetFocusedTextBox() then
        return
    end

    if input.KeyCode == Enum.KeyCode.Home then
        setHudEnabled(not MainSettings.HudEnabled)
        hubNotify("HUD", MainSettings.HudEnabled and "HUD enabled" or "HUD disabled", 2, true)
        return
    end

    local aimMatched, aimMode = getRuntimeKeybindMatchData(AimbotRuntime.AimKeybind, Enum.UserInputType.MouseButton2, input, "Hold")
    if aimMatched then
        if aimMode == "Hold" then
            AimbotRuntime.KeybindActive = true
        elseif aimMode == "Toggle" then
            AimbotRuntime.KeybindActive = not AimbotRuntime.KeybindActive
        elseif aimMode == "Always" then
            AimbotRuntime.KeybindActive = true
        end
        refreshAimbotBindState()
        updateAimbotStatusLabel()
    end

    local spinMatched, spinMode = getRuntimeKeybindMatchData(AimbotRuntime.SpinKeybind, Enum.KeyCode.Q, input, "Hold")
    if spinMatched then
        if spinMode == "Hold" then
            AimbotRuntime.SpinKeybindActive = true
        elseif spinMode == "Toggle" then
            AimbotRuntime.SpinKeybindActive = not AimbotRuntime.SpinKeybindActive
        elseif spinMode == "Always" then
            AimbotRuntime.SpinKeybindActive = true
        end
        refreshSpinBindState()
    end

    local triggerMatched, triggerMode = getRuntimeKeybindMatchData(AimbotRuntime.TriggerKeybind, Enum.KeyCode.E, input, "Hold")
    if triggerMatched then
        if triggerMode == "Hold" then
            AimbotRuntime.TriggerKeybindActive = true
        elseif triggerMode == "Toggle" then
            AimbotRuntime.TriggerKeybindActive = not AimbotRuntime.TriggerKeybindActive
        elseif triggerMode == "Always" then
            AimbotRuntime.TriggerKeybindActive = true
        end
        refreshTriggerBindState()
    end

    if matchesBoundInput(tpBindKey, input) then
        if isClickTPModifierMode() then
            tpClickModifierActive = true
        else
            teleportToMouse()
        end
        return
    end

    if gameProcessed then return end

    if VehicleSystem.FlyEnabled then
        local key = input.KeyCode
        if key == Enum.KeyCode.W or key == Enum.KeyCode.Up then
            if not table.find(VehicleSystem.MovementDirection, "forward") then
                table.insert(VehicleSystem.MovementDirection, "forward")
            end
        elseif key == Enum.KeyCode.S or key == Enum.KeyCode.Down then
            if not table.find(VehicleSystem.MovementDirection, "backward") then
                table.insert(VehicleSystem.MovementDirection, "backward")
            end
        elseif key == Enum.KeyCode.A or key == Enum.KeyCode.Left then
            if not table.find(VehicleSystem.MovementDirection, "left") then
                table.insert(VehicleSystem.MovementDirection, "left")
            end
        elseif key == Enum.KeyCode.D or key == Enum.KeyCode.Right then
            if not table.find(VehicleSystem.MovementDirection, "right") then
                table.insert(VehicleSystem.MovementDirection, "right")
            end
        elseif key == Enum.KeyCode.Space then
            if not table.find(VehicleSystem.MovementDirection, "up") then
                table.insert(VehicleSystem.MovementDirection, "up")
            end
        elseif key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.LeftShift then
            if not table.find(VehicleSystem.MovementDirection, "down") then
                table.insert(VehicleSystem.MovementDirection, "down")
            end
        elseif key == Enum.KeyCode.Q then
            if not table.find(VehicleSystem.MovementDirection, "rotateLeft") then
                table.insert(VehicleSystem.MovementDirection, "rotateLeft")
            end
        elseif key == Enum.KeyCode.E then
            if not table.find(VehicleSystem.MovementDirection, "rotateRight") then
                table.insert(VehicleSystem.MovementDirection, "rotateRight")
            end
        end
    end

    if clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isClickTPModifierMode() and not tpClickModifierActive then
            return
        end
        teleportToMouse()
    end
end)

GlobalState.MainInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
    local aimMatched, aimMode = getRuntimeKeybindMatchData(AimbotRuntime.AimKeybind, Enum.UserInputType.MouseButton2, input, "Hold")
    if aimMatched and aimMode == "Hold" then
        AimbotRuntime.KeybindActive = false
        refreshAimbotBindState()
        updateAimbotStatusLabel()
    end

    local spinMatched, spinMode = getRuntimeKeybindMatchData(AimbotRuntime.SpinKeybind, Enum.KeyCode.Q, input, "Hold")
    if spinMatched and spinMode == "Hold" then
        AimbotRuntime.SpinKeybindActive = false
        refreshSpinBindState()
    end

    local triggerMatched, triggerMode = getRuntimeKeybindMatchData(AimbotRuntime.TriggerKeybind, Enum.KeyCode.E, input, "Hold")
    if triggerMatched and triggerMode == "Hold" then
        AimbotRuntime.TriggerKeybindActive = false
        refreshTriggerBindState()
    end
    if matchesBoundInput(tpBindKey, input) then
        tpClickModifierActive = false
    end

    local key = input.KeyCode
    
    if key == Enum.KeyCode.W or key == Enum.KeyCode.Up then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "forward" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.S or key == Enum.KeyCode.Down then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "backward" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.A or key == Enum.KeyCode.Left then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "left" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.D or key == Enum.KeyCode.Right then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "right" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.Space then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "up" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.LeftShift then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "down" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.Q then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "rotateLeft" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    elseif key == Enum.KeyCode.E then
        for i = #VehicleSystem.MovementDirection, 1, -1 do
            if VehicleSystem.MovementDirection[i] == "rotateRight" then table.remove(VehicleSystem.MovementDirection, i) end
        end
    end
end)

GlobalState.MainJumpRequestConnection = UserInputService.JumpRequest:Connect(function()
    if FunSettings.RocketJump then
        performRocketJump()
    end
end)

GlobalState.MainRenderConnection = RunService.RenderStepped:Connect(function()
    refreshCombatBindStates()
    handleVehicleInput()
    updateAimbotFoVCircle()
    -- Rate limit aimbot frame updates DLYa IZBEZhANIYa O(n) PROVEROK KAZhDYY FREYM
    if AimbotSettings.Enabled and tick() - AimbotSettings.LastAimbotFrameUpdate >= AimbotSettings.AimbotFrameUpdateInterval then
        AimbotSettings.LastAimbotFrameUpdate = tick()
        handleAimbotFrame()
    elseif not AimbotSettings.Enabled then
        handleAimbotFrame()
    end
    
    if CombatSettings.AimAssist then
        local targetPart = getLockedTargetPart() or getClosestAimPart()
        local camera = workspace.CurrentCamera
        if targetPart and camera then
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
        end
    end
end)

local function zeroCharacterMomentum(character)
    character = character or getCharacter()
    if not character then return end
    for _, inst in ipairs(character:GetDescendants()) do
        if inst:IsA("BasePart") then
            pcall(function()
                inst.AssemblyLinearVelocity = Vector3.zero
                inst.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end

local function updateAntiFlingSafePosition(character, humanoid, root)
    if not character or not humanoid or not root then return end
    local vel = root.AssemblyLinearVelocity
    local threshold = _G.AntiFlingConfig.safe_velocity_threshold or 50
    local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
    if (not _G.AntiFlingConfig.safe_on_ground_only or grounded)
        and vel.Magnitude <= threshold
        and not humanoid.Sit
        and humanoid:GetState() ~= Enum.HumanoidStateType.Ragdoll
    then
        AntiFlingState.LastSafeCF = root.CFrame + Vector3.new(0, 3, 0)
    end
end

local function guardAntiFlingHumanoid(humanoid)
    if not humanoid or AntiFlingState.GuardedHumanoid == humanoid then return end
    AntiFlingState.GuardedHumanoid = humanoid
    if _G.AntiFlingConfig.block_states then
        pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
        pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
        pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
        pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false) end)
        pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false) end)
    end
    if _G.AntiFlingConfig.anti_seat then
        pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
    end
end

local function unguardAntiFlingHumanoid()
    local humanoid = AntiFlingState.GuardedHumanoid
    if not humanoid then return end
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
    AntiFlingState.GuardedHumanoid = nil
end

local function antiFlingRecover(character, humanoid, root, reason)
    if not character or not humanoid or not root then return end
    local maxRescues = math.max(1, _G.AntiFlingConfig.max_rescue_per_second or 6)
    local minDelay = 1 / maxRescues
    local now = tick()
    if now - AntiFlingState.LastTeleportAt < minDelay then return end
    AntiFlingState.LastTeleportAt = now

    if _G.AntiFlingConfig.zero_all_parts then
        zeroCharacterMomentum(character)
    else
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end

    if _G.AntiFlingConfig.anchor then
        local shouldAnchor = true
        if _G.AntiFlingConfig.smart_anchor and AntiFlingState.LastSafeCF then
            shouldAnchor = (root.Position - AntiFlingState.LastSafeCF.Position).Magnitude >= (_G.AntiFlingConfig.anchor_dist or 20)
        end
        if shouldAnchor and now - AntiFlingState.LastAnchorAt > 0.12 then
            AntiFlingState.LastAnchorAt = now
            root.Anchored = true
            task.delay(0.12, function()
                pcall(function()
                    if root and root.Parent then root.Anchored = false end
                end)
            end)
        end
    end

    if _G.AntiFlingConfig.teleport and AntiFlingState.LastSafeCF then
        local shouldTeleport = true
        if _G.AntiFlingConfig.smart_teleport then
            shouldTeleport = (root.Position - AntiFlingState.LastSafeCF.Position).Magnitude >= (_G.AntiFlingConfig.teleport_dist or 20)
        end
        if shouldTeleport then
            root.CFrame = AntiFlingState.LastSafeCF
        end
    end

    humanoid.PlatformStand = false
    if _G.AntiFlingConfig.anti_seat then
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if _G.AntiFlingConfig.auto_jump_recover then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        humanoid.Jump = true
    end

    if reason and RuntimeRefs.TeleportInfoLabel and RuntimeRefs.TeleportInfoLabel.SetText then
        RuntimeRefs.TeleportInfoLabel:SetText("Anti-Fling activated: " .. tostring(reason))
    end
end

local function startTouchFling()
    if touchFlingEnabled then return end
    touchFlingEnabled = true
    touchFlingConnection = RunService.Heartbeat:Connect(function()
        if not touchFlingEnabled then return end
        local lp = Players.LocalPlayer
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * TouchFlingSettings.VelocityMultiplier + Vector3.new(0, TouchFlingSettings.UpwardBoost, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, TouchFlingSettings.RestoreYOffset, 0)
        end
    end)
end

local function stopTouchFling()
    touchFlingEnabled = false
    if touchFlingConnection then
        touchFlingConnection:Disconnect()
        touchFlingConnection = nil
    end
end

local function performEmergencyAntiFling(character, humanoid, root)
    if not character or not humanoid or not root then return end
    
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end
    
    humanoid.PlatformStand = false
    humanoid.Sit = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    humanoid.Jump = true
    
    if AntiFlingState.LastSafeCF then
        root.CFrame = AntiFlingState.LastSafeCF
    end
end

local function startAntiFling()
    if antiFlingEnabled then return end
    antiFlingEnabled = true
    antiFlingConnection = RunService.Heartbeat:Connect(function()
        if not antiFlingEnabled then return end
        local lp = Players.LocalPlayer
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            guardAntiFlingHumanoid(hum)
            updateAntiFlingSafePosition(c, hum, hrp)
            
            local velMag = hrp.AssemblyLinearVelocity.Magnitude
            local angMag = hrp.AssemblyAngularVelocity.Magnitude
            
            if _G.AntiFlingConfig.disable_rotation then
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            
            if _G.AntiFlingConfig.anti_ragdoll then
                hum.PlatformStand = false
            end
            
            if _G.AntiFlingConfig.anti_seat and hum.Sit then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            
            if _G.AntiFlingConfig.block_states then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Ragdoll
                    or state == Enum.HumanoidStateType.FallingDown
                    or state == Enum.HumanoidStateType.Physics
                    or state == Enum.HumanoidStateType.Flying
                then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    antiFlingRecover(c, hum, hrp, "bad_state")
                end
            end
            
            if velMag > 200 or angMag > 150 then
                performEmergencyAntiFling(c, hum, hrp)
            elseif _G.AntiFlingConfig.limit_velocity and velMag > _G.AntiFlingConfig.limit_velocity_sensitivity then
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity.Unit * math.max(0, _G.AntiFlingConfig.limit_velocity_slow or 0)
                for _, part in pairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                    end
                end
                antiFlingRecover(c, hum, hrp, "velocity")
            elseif _G.AntiFlingConfig.limit_angular_velocity and angMag > (_G.AntiFlingConfig.angular_velocity_sensitivity or 60) then
                hrp.AssemblyAngularVelocity = Vector3.zero
                for _, part in pairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                antiFlingRecover(c, hum, hrp, "angular")
            end
        end
    end)
end

local function stopAntiFling()
    antiFlingEnabled = false
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    local root = getRootPart()
    if root and not MovementSettings.AirStuck then
        pcall(function()
            root.Anchored = false
        end)
    end
    unguardAntiFlingHumanoid()
end

_G.disable = function()
    stopAntiFling()
end

CombatSettings.TeamHighlightEnabled = false
CombatSettings.LastQuickTrigger = 0

hubNotify = function(title, description, duration, force)
    if MainSettings.QuietLoad and not force then
        return
    end
    pcall(function()
        if Library and Library.Notification then
            Library:Notification({
                Title = title or HUB_BRAND,
                Description = tostring(description or ""),
                Duration = duration or 3,
            })
        else
            print("[" .. HUB_TAG .. "]", tostring(title or "Info"), tostring(description or ""))
        end
    end)
end

local function addActionButtons(section, actions)
    if not section or type(actions) ~= "table" then return end
    for _, action in ipairs(actions) do
        if type(action) == "table" and type(action.Name) == "string" and type(action.Callback) == "function" then
            section:Button({
                Name = action.Name,
                Callback = function()
                    local ok, err = pcall(action.Callback)
                    if not ok then
                        hubNotify(HUB_BRAND .. " Error", tostring(err), 4, true)
                    end
                end
            })
        end
    end
end

local function getNearestPlayer(maxDistance, enemyOnly)
    local root = getRootPart()
    if not root then return nil end
    local best, bestDist = nil, tonumber(maxDistance) or math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and isAlivePlayer(player) and (not enemyOnly or isEnemyPlayer(player)) then
            local targetRoot = getRootPart(player.Character)
            if targetRoot then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = player
                end
            end
        end
    end
    return best, bestDist
end

local function getFarthestPlayer(maxDistance, enemyOnly)
    local root = getRootPart()
    if not root then return nil end
    local best, bestDist = nil, -1
    local limit = tonumber(maxDistance) or math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and isAlivePlayer(player) and (not enemyOnly or isEnemyPlayer(player)) then
            local targetRoot = getRootPart(player.Character)
            if targetRoot then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist <= limit and dist > bestDist then
                    bestDist = dist
                    best = player
                end
            end
        end
    end
    return best, bestDist
end

local function facePart(part)
    local root = getRootPart()
    if not root or not part then return false end
    local targetPos = part.Position
    root.CFrame = CFrame.new(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
    return true
end

local function facePlayer(player)
    return facePart(player and getRootPart(player.Character))
end

local function dashLocal(directionVector, power)
    local root = getRootPart()
    if not root or typeof(directionVector) ~= "Vector3" then return false end
    if directionVector.Magnitude < 1e-3 then return false end
    local boost = tonumber(power) or MovementSettings.DashPower or 70
    local y = math.max(root.AssemblyLinearVelocity.Y, 0)
    root.AssemblyLinearVelocity = directionVector.Unit * boost + Vector3.new(0, y, 0)
    return true
end

local function dashForward()
    local camera = workspace.CurrentCamera
    return camera and dashLocal(Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z), MovementSettings.DashPower)
end

local function dashBackward()
    local camera = workspace.CurrentCamera
    return camera and dashLocal(Vector3.new(-camera.CFrame.LookVector.X, 0, -camera.CFrame.LookVector.Z), MovementSettings.DashPower)
end

local function dashRight()
    local camera = workspace.CurrentCamera
    return camera and dashLocal(Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z), MovementSettings.DashPower)
end

local function dashLeft()
    local camera = workspace.CurrentCamera
    return camera and dashLocal(Vector3.new(-camera.CFrame.RightVector.X, 0, -camera.CFrame.RightVector.Z), MovementSettings.DashPower)
end

performRocketJump = function()
    local now = tick()
    if now - (FunSettings.LastRocketJump or 0) < 0.35 then
        return false
    end
    local root = getRootPart()
    if not root then return false end
    FunSettings.LastRocketJump = now
    local camera = workspace.CurrentCamera
    local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
    root.AssemblyLinearVelocity = Vector3.new(
        look.X * (FunSettings.RocketForwardPower or 45),
        FunSettings.RocketJumpPower or 85,
        look.Z * (FunSettings.RocketForwardPower or 45)
    )
    return true
end

setLocalNameHidden = function(on)
    UtilityFeatureSettings.HideLocalName = on
    local humanoid = getHumanoid()
    if not humanoid then return false end
    if on then
        if UtilityFeatureSettings.SavedDisplayDistanceType == nil then
            UtilityFeatureSettings.SavedDisplayDistanceType = humanoid.DisplayDistanceType
        end
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    else
        humanoid.DisplayDistanceType = UtilityFeatureSettings.SavedDisplayDistanceType or Enum.HumanoidDisplayDistanceType.Viewer
    end
    return true
end

local function setCharacterScale(multiplier)
    local humanoid = getHumanoid()
    if not humanoid then return false end
    local targetScale = math.clamp(tonumber(multiplier) or 1, 0.25, 4)
    local changed = false

    local descriptionWorked = pcall(function()
        if humanoid.GetAppliedDescription and humanoid.ApplyDescription then
            local description = humanoid:GetAppliedDescription()
            if description then
                description.HeightScale = targetScale
                description.WidthScale = targetScale
                description.DepthScale = targetScale
                description.HeadScale = targetScale
                humanoid:ApplyDescription(description)
                changed = true
            end
        end
    end)

    if changed then
        return true
    end

    if not descriptionWorked then
        changed = false
    end

    local scaleNames = {
        "BodyHeightScale",
        "BodyWidthScale",
        "BodyDepthScale",
        "HeadScale",
    }
    for _, name in ipairs(scaleNames) do
        local scale = humanoid:FindFirstChild(name)
        if scale and scale:IsA("NumberValue") then
            scale.Value = targetScale
            changed = true
        end
    end
    return changed
end

setLocalCharacterColor = function(color)
    local character = getCharacter()
    if not character or typeof(color) ~= "Color3" then return false end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.Color = color
            end)
        end
    end
    return true
end

local function setRandomCharacterColor()
    return setLocalCharacterColor(Color3.fromHSV((tick() * 0.17) % 1, 0.85, 1))
end

local function playLocalAnimation(animationId)
    animationId = tostring(animationId or "")
    if animationId == "" then return false end
    local humanoid = getHumanoid()
    if not humanoid then return false end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId:find("rbxassetid://", 1, true) and animationId or ("rbxassetid://" .. animationId)
    local track = animator:LoadAnimation(animation)
    track:Play()
    return true
end

local function sendChatMessage(text)
    text = tostring(text or "")
    if text == "" then return false end
    local sent = false
    pcall(function()
        local tcs = game:GetService("TextChatService")
        local channels = tcs:FindFirstChild("TextChannels")
        local general = channels and channels:FindFirstChild("RBXGeneral")
        if general and general.SendAsync then
            general:SendAsync(text)
            sent = true
        end
    end)
    if sent then
        return true
    end
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local chatEvents = rep:FindFirstChild("DefaultChatSystemChatEvents")
        local sayRequest = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")
        if sayRequest then
            sayRequest:FireServer(text, "All")
            sent = true
        end
    end)
    return sent
end

local function trimText(value)
    return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function getChatPresetMessages()
    local presetName = tostring(ChatSettings.SelectedPreset or "Friendly")
    local preset = ChatSettings.Presets and ChatSettings.Presets[presetName]
    if type(preset) ~= "table" then
        preset = ChatSettings.Presets and ChatSettings.Presets.Friendly or {}
    end
    return preset
end

local function parseChatMessages(source)
    local messages = {}
    source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
    for chunk in source:gmatch("[^\n|]+") do
        local text = trimText(chunk)
        if text ~= "" then
            messages[#messages + 1] = text
        end
    end
    if #messages == 0 then
        for _, text in ipairs(getChatPresetMessages()) do
            text = trimText(text)
            if text ~= "" then
                messages[#messages + 1] = text
            end
        end
    end
    return messages
end

local function getNextChatMessage()
    local messages = parseChatMessages(ChatSettings.MessageSource)
    if #messages == 0 then
        return ""
    end

    local mode = tostring(ChatSettings.Mode or "Rotate")
    local chosen
    if mode == "Single" then
        chosen = messages[1]
    elseif mode == "Random" then
        chosen = messages[Random.new():NextInteger(1, #messages)]
    else
        ChatSettings.RotateIndex = (tonumber(ChatSettings.RotateIndex) or 0) + 1
        if ChatSettings.RotateIndex > #messages then
            ChatSettings.RotateIndex = 1
        end
        chosen = messages[ChatSettings.RotateIndex]
    end

    local prefix = trimText(ChatSettings.Prefix)
    if prefix ~= "" then
        chosen = prefix .. " " .. tostring(chosen or "")
    end
    if ChatSettings.IncludeCounter then
        chosen = string.format("%s [%d]", tostring(chosen or ""), (tonumber(ChatSettings.SentCount) or 0) + 1)
    end
    return trimText(chosen)
end

local function getChatStatusText()
    local enabledText = ChatSettings.Enabled
        and TL("ВКЛ", "УВІМК", "ON")
        or TL("ВЫКЛ", "ВИМК", "OFF")
    local preview = ChatRuntime.LastMessage
    if trimText(preview) == "" then
        local oldRotateIndex = ChatSettings.RotateIndex
        preview = getNextChatMessage()
        ChatSettings.RotateIndex = oldRotateIndex
    end
    preview = trimText(preview)
    if preview == "" then
        preview = TL("нет текста", "нема тексту", "no text")
    end

    return string.format(
        "%s | %s: %s | %s: %.1fs | %s: %d | %s: %s",
        TL("Чат-луп", "Чат-луп", "Chat Loop"),
        TL("режим", "режим", "mode"),
        tostring(ChatSettings.Mode or "Rotate"),
        TL("интервал", "інтервал", "interval"),
        math.max(0.4, tonumber(ChatSettings.Interval) or 2.5),
        TL("отправлено", "відправлено", "sent"),
        math.max(0, math.floor(tonumber(ChatSettings.SentCount) or 0)),
        enabledText,
        preview
    )
end

local function updateChatStatusLabel()
    if RuntimeRefs.ChatStatusLabel and RuntimeRefs.ChatStatusLabel.SetText then
        RuntimeRefs.ChatStatusLabel:SetText(getChatStatusText())
    end
end

local function applyChatPreset(presetName)
    presetName = tostring(presetName or "")
    if type(ChatSettings.Presets[presetName]) ~= "table" then
        return false
    end
    ChatSettings.SelectedPreset = presetName
    ChatSettings.RotateIndex = 0
    ChatSettings.MessageSource = table.concat(ChatSettings.Presets[presetName], " | ")
    updateChatStatusLabel()
    return true
end

local function pushChatMessage(optionalMessage)
    local message = trimText(optionalMessage)
    if message == "" then
        message = getNextChatMessage()
    end
    if message == "" then
        updateChatStatusLabel()
        return false, ""
    end

    ChatSettings.LastSentAt = tick()
    local sent = sendChatMessage(message)
    if sent then
        ChatSettings.SentCount = math.max(0, math.floor(tonumber(ChatSettings.SentCount) or 0)) + 1
        ChatRuntime.LastMessage = message
    end
    updateChatStatusLabel()
    return sent, message
end

local function setChatLoopEnabled(state)
    ChatSettings.Enabled = state == true
    updateChatStatusLabel()
    return ChatSettings.Enabled
end

runChatLoopTick = function()
    if not ChatSettings.Enabled then
        return
    end
    local interval = math.max(0.4, tonumber(ChatSettings.Interval) or 2.5)
    if tick() - (tonumber(ChatSettings.LastSentAt) or 0) < interval then
        return
    end
    pushChatMessage()
end

local function sendChatBurst(count)
    count = math.clamp(math.floor(tonumber(count) or ChatSettings.BurstCount or 1), 1, 10)
    local pause = math.max(0.25, math.min(math.max(0.4, tonumber(ChatSettings.Interval) or 2.5) * 0.35, 1))
    task.spawn(function()
        local sentCount = 0
        for i = 1, count do
            local sent = pushChatMessage()
            if sent then
                sentCount = sentCount + 1
            end
            if i < count then
                task.wait(pause)
            end
        end
        hubNotify(
            TL("Чат", "Чат", "Chat"),
            string.format(
                "%s: %d/%d",
                TL("пакет отправлен", "пакет відправлено", "burst sent"),
                sentCount,
                count
            ),
            2,
            true
        )
    end)
end

local function clearPlayerHighlights()
    for player, highlight in pairs(HighlightSettings.Cache) do
        pcall(function()
            if highlight then
                highlight:Destroy()
            end
        end)
        HighlightSettings.Cache[player] = nil
    end
end

updatePlayerHighlights = function()
    local enabled = HighlightSettings.Enabled or CombatSettings.TeamHighlightEnabled
    if not enabled then
        clearPlayerHighlights()
        return
    end

    local enemyOnly = HighlightSettings.EnemyOnly or CombatSettings.TeamHighlightEnabled
    local active = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and isAlivePlayer(player) and (not enemyOnly or isEnemyPlayer(player)) then
            local character = player.Character
            if character then
                active[player] = true
                local highlight = HighlightSettings.Cache[player]
                if not highlight or not highlight.Parent then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "YasiaHub_PlayerHighlight"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    HighlightSettings.Cache[player] = highlight
                end
                local baseColor = HighlightSettings.Rainbow
                    and Color3.fromHSV((tick() * 0.15) % 1, 1, 1)
                    or (player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 80, 80))
                highlight.FillColor = baseColor
                highlight.OutlineColor = baseColor:Lerp(Color3.new(1, 1, 1), 0.4)
                highlight.FillTransparency = HighlightSettings.FillTransparency
                highlight.OutlineTransparency = HighlightSettings.OutlineTransparency
                highlight.Adornee = character
                highlight.Parent = character
                highlight.Enabled = true
            end
        end
    end

    for player, highlight in pairs(HighlightSettings.Cache) do
        if not active[player] then
            pcall(function()
                if highlight then
                    highlight:Destroy()
                end
            end)
            HighlightSettings.Cache[player] = nil
        end
    end
end

local PresetActions = {}

function PresetActions.applyFarm(mode)
    mode = tostring(mode or "all")
    FarmSettings.AutoEnabled = mode == "all"
    FarmSettings.PromptEnabled = mode == "all" or mode == "prompt"
    FarmSettings.ClickEnabled = mode == "all" or mode == "click"
    FarmSettings.TouchEnabled = mode == "all" or mode == "touch"
    FarmSettings.AutoCollectTools = mode == "all" or mode == "tools"
end

function PresetActions.resetFarmFilters()
    FarmSettings.PromptFilter = ""
    FarmSettings.ClickFilter = ""
    FarmSettings.TouchFilter = ""
    FarmSettings.Interval = 0.35
    FarmSettings.MaxPerCycle = 8
    FarmSettings.TeleportToTargets = false
end

local function setFarmSourceStates(autoEnabled, promptEnabled, clickEnabled, touchEnabled, toolEnabled)
    FarmSettings.AutoEnabled = autoEnabled == true
    FarmSettings.PromptEnabled = promptEnabled == true
    FarmSettings.ClickEnabled = clickEnabled == true
    FarmSettings.TouchEnabled = touchEnabled == true
    FarmSettings.AutoCollectTools = toolEnabled == true
end

local function formatFarmNearbyCountsText(counts)
    counts = counts or { prompts = 0, clicks = 0, tools = 0, seats = 0, spawns = 0 }
    return string.format(
        "P:%d | C:%d | T:%d | S:%d | Sp:%d",
        counts.prompts or 0,
        counts.clicks or 0,
        counts.tools or 0,
        counts.seats or 0,
        counts.spawns or 0
    )
end

local function updateFarmHelperLabel(text)
    if RuntimeRefs and RuntimeRefs.FarmHelperLabel and RuntimeRefs.FarmHelperLabel.SetText then
        RuntimeRefs.FarmHelperLabel:SetText(tostring(text or ""))
    end
end

local function applyBeginnerFarmPreset(style)
    style = tostring(style or "starter"):lower()
    PresetActions.resetFarmFilters()
    FarmSettings.IgnorePlayers = true
    FarmSettings.PreferNearest = true

    local presetLabel = TL("Безопасный старт", "Безпечний старт", "Safe Starter")
    if style == "balanced" then
        presetLabel = TL("Сбалансированный старт", "Збалансований старт", "Balanced Starter")
        FarmSettings.AutoRadius = 55
        FarmSettings.Interval = 0.28
        FarmSettings.MaxPerCycle = 5
        FarmSettings.TeleportToTargets = false
        setFarmSourceStates(false, true, true, false, true)
    elseif style == "looter" then
        presetLabel = TL("Лут-сборщик", "Лут-збирач", "Loot Gatherer")
        FarmSettings.AutoRadius = 70
        FarmSettings.Interval = 0.2
        FarmSettings.MaxPerCycle = 6
        FarmSettings.TeleportToTargets = true
        setFarmSourceStates(false, true, true, false, true)
    else
        FarmSettings.AutoRadius = 35
        FarmSettings.Interval = 0.45
        FarmSettings.MaxPerCycle = 3
        FarmSettings.TeleportToTargets = false
        setFarmSourceStates(false, true, false, false, true)
    end

    local counts = scanNearbyCounts(FarmSettings.AutoRadius)
    updateFarmHelperLabel(presetLabel .. " | " .. formatFarmNearbyCountsText(counts))
    return presetLabel, counts
end

local function applySmartNearbyFarmSetup()
    local counts = scanNearbyCounts(FarmSettings.AutoRadius)
    local usePrompts = (counts.prompts or 0) > 0
    local useClicks = (counts.clicks or 0) > 0 and ((counts.prompts or 0) == 0 or (counts.clicks or 0) >= (counts.prompts or 0))
    local useTools = (counts.tools or 0) > 0
    local found = usePrompts or useClicks or useTools

    PresetActions.resetFarmFilters()
    FarmSettings.IgnorePlayers = true
    FarmSettings.PreferNearest = true
    FarmSettings.TeleportToTargets = false
    FarmSettings.Interval = usePrompts and 0.3 or 0.4
    FarmSettings.MaxPerCycle = math.clamp((usePrompts and 3 or 0) + (useClicks and 2 or 0) + (useTools and 2 or 0), 2, 6)
    setFarmSourceStates(false, usePrompts, useClicks, false, useTools)

    updateFarmHelperLabel(TL("Автоподбор рядом", "Автопідбір поруч", "Nearby Auto Setup") .. " | " .. formatFarmNearbyCountsText(counts))
    return counts, found
end

local function useBestNearbyFarmTarget()
    local prompt = getNearestPrompt(FarmSettings.AutoRadius)
    if prompt then
        usePrompt(prompt)
        return "prompt"
    end

    local click = getNearestClickDetector(FarmSettings.AutoRadius)
    if click then
        useClickDetector(click)
        return "click"
    end

    local tool = getNearestToolInWorld(FarmSettings.AutoRadius)
    local handle = tool and tool:FindFirstChild("Handle")
    if handle and touchPart(handle) then
        return "tool"
    end

    return nil
end

local function stopAllFarmModes()
    setFarmSourceStates(false, false, false, false, false)
    FarmSettings.TeleportToTargets = false
    updateFarmHelperLabel(TL("Все режимы фарма выключены.", "Усі режими фарму вимкнено.", "All farm modes are disabled."))
end

function PresetActions.applyTouchFling(multiplier, upwardBoost, restoreYOffset)
    TouchFlingSettings.VelocityMultiplier = tonumber(multiplier) or TouchFlingSettings.VelocityMultiplier
    TouchFlingSettings.UpwardBoost = tonumber(upwardBoost) or TouchFlingSettings.UpwardBoost
    TouchFlingSettings.RestoreYOffset = tonumber(restoreYOffset) or TouchFlingSettings.RestoreYOffset
end

function PresetActions.applyAntiFling(name)
    name = tostring(name or "default"):lower()
    if name == "light" then
        _G.AntiFlingConfig.limit_velocity = true
        _G.AntiFlingConfig.limit_velocity_sensitivity = 130
        _G.AntiFlingConfig.limit_angular_velocity = true
        _G.AntiFlingConfig.angular_velocity_sensitivity = 80
        _G.AntiFlingConfig.anchor = false
        _G.AntiFlingConfig.teleport = true
    elseif name == "aggressive" then
        _G.AntiFlingConfig.limit_velocity = true
        _G.AntiFlingConfig.limit_velocity_sensitivity = 75
        _G.AntiFlingConfig.limit_angular_velocity = true
        _G.AntiFlingConfig.angular_velocity_sensitivity = 40
        _G.AntiFlingConfig.anchor = true
        _G.AntiFlingConfig.teleport = true
        _G.AntiFlingConfig.zero_all_parts = true
    else
        _G.AntiFlingConfig.limit_velocity = false
        _G.AntiFlingConfig.limit_velocity_sensitivity = 100
        _G.AntiFlingConfig.limit_angular_velocity = true
        _G.AntiFlingConfig.angular_velocity_sensitivity = 60
        _G.AntiFlingConfig.anchor = true
        _G.AntiFlingConfig.teleport = true
        _G.AntiFlingConfig.zero_all_parts = false
    end
end

function PresetActions.resetMovement()
    setWalkSpeed(16)
    setJumpPower(50)
    setGravity(196.2)
    flySpeed = 50
    MovementSettings.StrafeMultiplier = 1
    MovementSettings.CameraSmooth = false
    MovementSettings.DashPower = 70
end

function PresetActions.resetVisual()
    espBoxColor = Color3.fromRGB(255, 0, 0)
    espShowBox = true
    espShowText = true
    espShowHealthBar = false
    espShowDistance = true
    espShowTracer = false
    espShowHeadDot = false
    espUseDisplayName = false
    espShowHealthText = true
    espHideTeammates = false
    espOnlyAlive = true
    espRainbow = false
    HighlightSettings.Enabled = false
    HighlightSettings.EnemyOnly = false
    HighlightSettings.Rainbow = false
    setWorldXray(false)
    clearPlayerHighlights()
end

function PresetActions.resetCombat()
    CombatSettings.AimAssist = false
    CombatSettings.SilentAim = false
    CombatSettings.Triggerbot = false
    CombatSettings.TeamHighlightEnabled = false
    AimbotSettings.TriggerBot = false
    AimbotSettings.TriggerBindActive = false
    AimbotRuntime.ManualActivation = false
    AimbotRuntime.KeybindActive = false
    AimbotRuntime.SpinKeybindActive = false
    AimbotRuntime.TriggerKeybindActive = false
    AimbotSettings.BindActive = false
    if AimbotSettings.Mode == "Silent" then
        AimbotSettings.Enabled = false
    end
    refreshCombatBindStates()
    clearPlayerHighlights()
    updateAimbotStatusLabel()
end

do
local mainLeft = pageMain:Section({
    Name = TL("Yasia Hub | Главные переключатели", "Yasia Hub | Головні перемикачі", "Yasia Hub | Main Toggles"),
    Icon = "toggle-left",
    Side = 1
})
mainLeft:Toggle({
    Name = TL("ESP (Боксы / Имена)", "ESP (Бокси / Імена)", "ESP (Boxes / Names)"),
    Flag = "ESP_Toggle",
    Default = false,
    Callback = function(val)
        if val then startESP() else stopESP() end
    end
})
mainLeft:Toggle({
    Name = TL("Fly (Полет)", "Fly (Політ)", "Fly (Flight)"),
    Flag = "Fly_Toggle",
    Default = false,
    Callback = function(val)
        if val then startFly() else stopFly() end
    end
})
mainLeft:Toggle({
    Name = TL("Noclip (Сквозь стены)", "Noclip (Крізь стіни)", "Noclip (Through Walls)"),
    Flag = "Noclip_Toggle",
    Default = false,
    Callback = function(val)
        if val then startNoclip() else stopNoclip() end
    end
})
mainLeft:Toggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump_Toggle",
    Default = false,
    Callback = function(val)
        if val then startInfiniteJump() else stopInfiniteJump() end
    end
})
mainLeft:Toggle({
    Name = TL("God Mode (Бессмертие)", "God Mode (Безсмертя)", "God Mode (Immortality)"),
    Flag = "GodMode_Toggle",
    Default = false,
    Callback = function(val)
        if val then startGodMode() else stopGodMode() end
    end
})

local mainRight = pageMain:Section({
    Name = TL("Yasia Hub | Настройки", "Yasia Hub | Налаштування", "Yasia Hub | Settings"),
    Icon = "sliders",
    Side = 2
})
trackSlider(mainRight:Slider({
    Name = "Walk Speed",
    Flag = "WalkSpeed_Slider",
    Min = 16, Max = 250, Default = 16, Decimals = 1,
    Callback = function(val) 
        if type(val) == "number" and val == val then setWalkSpeed(val) end
    end
}), 16)
trackSlider(mainRight:Slider({
    Name = "Jump Power",
    Flag = "JumpPower_Slider",
    Min = 50, Max = 500, Default = 50, Decimals = 1,
    Callback = function(val) 
        if type(val) == "number" and val == val then setJumpPower(val) end
    end
}), 50)
trackSlider(mainRight:Slider({
    Name = "Gravity",
    Flag = "Gravity_Slider",
    Min = -200, Max = 500, Default = 196.2, Decimals = 0.1,
    Callback = function(val) 
        if type(val) == "number" and val == val then setGravity(val) end
    end
}), 196.2)
trackSlider(mainRight:Slider({
    Name = "Fly Speed",
    Flag = "FlySpeed_Slider",
    Min = 10, Max = 500, Default = 50, Decimals = 1,
    Callback = function(val) 
        if type(val) == "number" and val == val then
            flySpeed = val
            GlobalState.flySpeed = val
        end
    end
}), 50)
mainRight:Button({
    Name = T("tp_mouse"),
    Callback = function() teleportToMouse() end
})
mainRight:Toggle({
    Name = T("click_tp"),
    Flag = "ClickTP_Toggle",
    Default = false,
    Callback = function(val)
        clickTPEnabled = val
        GlobalState.clickTPEnabled = val
        tpClickModifierActive = false
    end,
})
mainRight:Label(TL(
    "Click TP: удерживай TP-bind и кликай ЛКМ по миру. Если bind = ЛКМ, телепорт остаётся мгновенным.",
    "Click TP: утримуй TP-bind і клікай ЛКМ по світу. Якщо bind = ЛКМ, телепорт залишається миттєвим.",
    "Click TP: hold the TP bind and left-click the world. If the bind is LMB, teleport stays instant."
))
RuntimeRefs.TpBindStatusLabel = mainRight:Label(TF("tp_bind_status", formatBoundInput(tpBindKey)))
mainRight:Button({
    Name = T("tp_bind_button"),
    Callback = function() startBindingTPKey() end
})
mainRight:Button({
    Name = T("bring_all"),
    Callback = function() bringAll() end
})

local mainExtra = pageMain:Section({
    Name = TL("Yasia Hub | Доп. главная", "Yasia Hub | Додаткова головна", "Yasia Hub | Main Extras"),
    Icon = "sliders",
    Side = 2
})
mainExtra:Toggle({
    Name = TL("Тихая загрузка (без уведомления о запуске)", "Тихе завантаження (без сповіщення про запуск)", "Quiet Load (no load notification)"),
    Flag = "Main_QuietLoad",
    Default = MainSettings.QuietLoad,
    Callback = function(val)
        MainSettings.QuietLoad = val
        setStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, val)
    end
})
mainExtra:Button({
    Name = TL("Один раз вывести FPS в консоль", "Один раз вивести FPS у консоль", "Print FPS once"),
    Callback = function()
        local t = tick()
        for _ = 1, 30 do RunService.RenderStepped:Wait() end
        local fps = math.floor(30 / math.max(tick() - t, 1e-4))
        print("[" .. HUB_TAG .. "] FPS ~", fps)
    end
})
mainExtra:Label(TL(
    "Подсказка: TP Bind и Click TP находятся справа на главной.",
    "Підказка: TP Bind і Click TP знаходяться праворуч на головній.",
    "Tip: TP Bind and Click TP are on the right side of Main."
))
end

do
local espLeft = pageESP:Section({ Name = "Yasia Hub | ESP Settings", Side = 1 })
espLeft:Label("ESP Box Color"):Colorpicker({
    Flag = "ESPColor",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(col) espBoxColor = col end
})
espLeft:Toggle({
    Name = "Team Color ESP",
    Flag = "ESPTeamColor",
    Default = false,
    Callback = function(val) espTeamColor = val end
})

local espRight = pageESP:Section({ Name = TL("Yasia Hub | Доп. ESP", "Yasia Hub | Дод. ESP", "Yasia Hub | Extra ESP"), Icon = "crosshair", Side = 2 })
espRight:Toggle({
    Name = TL("Показывать ESP-боксы", "Показувати ESP-бокси", "Show ESP Boxes"),
    Flag = "ESP_ShowBox",
    Default = true,
    Callback = function(val) espShowBox = val end
})
espRight:Toggle({
    Name = TL("Показывать текст ESP", "Показувати текст ESP", "Show ESP Text"),
    Flag = "ESP_ShowText",
    Default = true,
    Callback = function(val) espShowText = val end
})
espRight:Toggle({
    Name = TL("Показывать полосу здоровья", "Показувати смугу здоров'я", "Show Health Bar"),
    Flag = "ESP_ShowHealthBar",
    Default = false,
    Callback = function(val) espShowHealthBar = val end
})
espRight:Toggle({
    Name = TL("Показывать дистанцию (м)", "Показувати дистанцію (м)", "Show Distance (m)"),
    Flag = "ESP_Distance",
    Default = true,
    Callback = function(val) espShowDistance = val end
})
trackSlider(espRight:Slider({
    Name = TL("Размер текста ESP", "Розмір тексту ESP", "ESP Text Size"),
    Flag = "ESP_TextSize",
    Min = 10, Max = 28, Default = 16, Decimals = 1,
    Callback = function(val)
        if type(val) == "number" and val == val then espTextSize = val end
    end
}), 16)
espRight:Toggle({
    Name = TL("Highlight / Chams игроков", "Highlight / Chams гравців", "Highlight / Chams Players"),
    Flag = "ESP_ChamsStub",
    Default = false,
    Callback = function(val)
        HighlightSettings.Enabled = val
        if not val and not CombatSettings.TeamHighlightEnabled then
            clearPlayerHighlights()
        end
    end
})
espRight:Label(TL(
    "Highlight работает через Roblox Highlight, а дистанция обновляется в реальном времени.",
    "Highlight працює через Roblox Highlight, а дистанція оновлюється в реальному часі.",
    "Highlight uses Roblox Highlight and updates distance in real time."
))
end

do
local moveLeft = pageMovement:Section({ Name = "Yasia Hub | Speed", Icon = "zap", Side = 1 })
moveLeft:Toggle({
    Name = "Speedhack (UDERZhANIE SKOROSTI)",
    Flag = "SpeedHack_Toggle",
    Default = false,
    Callback = function(val)
        speedHackEnabled = val
        if val then
            startSpeedHack()
        else
            stopSpeedHack()
        end
    end
})
moveLeft:Label(TL(
    "Использует значение Walk Speed с главной страницы каждый кадр.",
    "Використовує значення Walk Speed з головної сторінки кожен кадр.",
    "Uses the Walk Speed value from the main page every frame."
))

local moveRight = pageMovement:Section({ Name = TL("Yasia Hub | Доп. движение", "Yasia Hub | Дод. рух", "Yasia Hub | Movement Extras"), Icon = "wind", Side = 2 })
moveRight:Toggle({
    Name = TL("Сглаживание камеры", "Згладжування камери", "Camera Smoothing"),
    Flag = "Move_CamSmooth",
    Default = false,
    Callback = function(val)
        MovementSettings.CameraSmooth = val
    end
})
trackSlider(moveRight:Slider({
    Name = TL("Множитель стрейфа", "Множник стрейфу", "Strafe Multiplier"),
    Flag = "Move_StrafeMul",
    Min = 1, Max = 2, Default = 1, Decimals = 0.01,
    Callback = function(val)
        if isFiniteNumber(val) then
            MovementSettings.StrafeMultiplier = val
        end
    end
}), 1)
moveRight:Label(TL(
    "Сглаживание и стрейф теперь действительно работают через Heartbeat.",
    "Згладжування і стрейф тепер справді працюють через Heartbeat.",
    "Smoothing and strafe now run properly through Heartbeat."
))
end

do
combatLeft = pageCombat:Section({ Name = TL("Yasia Hub | Бой", "Yasia Hub | Бій", "Yasia Hub | Combat"), Icon = "sword", Side = 1 })
trackSlider(combatLeft:Slider({
    Name = "Reach / Quick Trigger Radius",
    Flag = "Combat_Reach",
    Min = 1, Max = 5, Default = 1.5, Decimals = 0.01,
    Callback = function(val)
        if type(val) == "number" and val == val then CombatSettings.Reach = val end
    end
}), 1.5)
combatLeft:Toggle({
    Name = "Silent Aim Shortcut",
    Flag = "Combat_Silent",
    Default = false,
    Callback = function(val)
        CombatSettings.SilentAim = val
        if val then
            AimbotSettings.Enabled = true
            AimbotRuntime.ManualActivation = true
            AimbotSettings.BindActive = true
            if table.find(AimbotSettings.AvailableModes, "Silent") then
                AimbotSettings.Mode = "Silent"
            end
            refreshAimbotBindState()
            updateAimbotStatusLabel()
        elseif AimbotSettings.Mode == "Silent" then
            AimbotRuntime.ManualActivation = false
            AimbotRuntime.KeybindActive = false
            AimbotSettings.BindActive = false
            refreshAimbotBindState()
            updateAimbotStatusLabel()
        end
    end
})
combatLeft:Toggle({
    Name = "Quick Triggerbot",
    Flag = "Combat_Trigger",
    Default = false,
    Callback = function(val)
        CombatSettings.Triggerbot = val
    end
})
combatLeft:Label(TL(
    "Быстрые переключатели теперь действительно работают и синхронизированы с рантаймом.",
    "Швидкі перемикачі тепер справді працюють і синхронізовані з рантаймом.",
    "Shortcut toggles now work properly and stay synced with runtime state."
))

combatRight = pageCombat:Section({ Name = TL("Yasia Hub | PvP-утилиты", "Yasia Hub | PvP-утиліти", "Yasia Hub | PvP Utility"), Icon = "target", Side = 2 })
combatRight:Button({
    Name = TL("Телепорт к ближайшему игроку", "Телепорт до найближчого гравця", "Teleport To Nearest Player"),
    Callback = function()
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local best, dist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if d < dist then dist, best = d, plr end
            end
        end
        if best then teleportToPlayer(best) end
    end
})
combatRight:Toggle({
    Name = TL("Подсветка врагов", "Підсвітка ворогів", "Enemy Highlight"),
    Flag = "Combat_TeamHighlight",
    Default = false,
    Callback = function(val)
        CombatSettings.TeamHighlightEnabled = val
        if not val and not HighlightSettings.Enabled then
            clearPlayerHighlights()
        end
    end
})
end

do
miscLeft = pageMisc:Section({ Name = TL("Yasia Hub | Визуал / Клиент", "Yasia Hub | Візуал / Клієнт", "Yasia Hub | Visual / Client"), Icon = "eye", Side = 1 })
miscLeft:Toggle({
    Name = "Anti-AFK",
    Flag = "Misc_AntiAfk",
    Default = false,
    Callback = function(val)
        MiscSettings.AntiAfk = val
        setAntiAfk(val)
    end
})
miscLeft:Toggle({
    Name = TL("Инвиз (только локально, LocalTransparency)", "Інвіз (лише локально, LocalTransparency)", "Invis (Local Only, LocalTransparency)"),
    Flag = "Misc_Invis",
    Default = false,
    Callback = function(val)
        setInvisToggle(val)
    end
})
miscLeft:Toggle({
    Name = "Fullbright",
    Flag = "Misc_Fullbright",
    Default = false,
    Callback = function(val)
        MiscSettings.Fullbright = val
        setFullbright(val)
    end
})
miscLeft:Toggle({
    Name = TL("Убрать туман", "Прибрати туман", "Remove Fog"),
    Flag = "Misc_NoFog",
    Default = false,
    Callback = function(val)
        MiscSettings.NoFog = val
        setNoFog(val)
    end
})
miscLeft:Toggle({
    Name = TL("Отключить тени (GlobalShadows)", "Вимкнути тіні (GlobalShadows)", "Disable Shadows (GlobalShadows)"),
    Flag = "Misc_NoShadows",
    Default = false,
    Callback = function(val)
        pcall(function() Lighting.GlobalShadows = not val end)
    end
})

miscRight = pageMisc:Section({ Name = TL("Yasia Hub | Звук / Прочее", "Yasia Hub | Звук / Інше", "Yasia Hub | Sound / Misc"), Icon = "volume-2", Side = 2 })
miscRight:Toggle({
    Name = TL("Заглушить звук игры (SoundService)", "Заглушити звук гри (SoundService)", "Mute Game Audio (SoundService)"),
    Flag = "Misc_MuteAll",
    Default = false,
    Callback = function(val)
        pcall(function()
            for _, s in ipairs(game:GetService("SoundService"):GetDescendants()) do
                if s:IsA("Sound") then s.Volume = val and 0 or 1 end
            end
        end)
    end
})
miscRight:Button({
    Name = TL("Сбросить яркость/туман", "Скинути яскравість/туман", "Reset Brightness/Fog"),
    Callback = function()
        setFullbright(false)
        setNoFog(false)
        pcall(function()
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
        end)
    end
})
end

do
funLeft = pageFun:Section({ Name = TL("Yasia Hub | Развлечения", "Yasia Hub | Розваги", "Yasia Hub | Fun"), Icon = "smile", Side = 1 })
funLeft:Toggle({
    Name = TL("Крутиться (HRP)", "Крутитися (HRP)", "Spin (HRP)"),
    Flag = "Fun_Spin",
    Default = false,
    Callback = function(val)
        FunSettings.Spin = val
        setSpinCharacter(val)
    end
})
funLeft:Button({
    Name = TL("Рэгдолл себя", "Реґдолл себе", "Ragdoll Yourself"),
    Callback = function()
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Physics) end
        end)
    end
})
funLeft:Toggle({
    Name = "Rainbow Body",
    Flag = "Fun_RainbowBody",
    Default = false,
    Callback = function(val)
        FunSettings.RainbowBody = val
        if not val then
            FunSettings.LastRainbowTick = 0
        end
    end
})
trackSlider(funLeft:Slider({
    Name = "Rainbow Speed",
    Flag = "Fun_RainbowSpeed",
    Min = 0.05,
    Max = 2,
    Default = 0.2,
    Precision = 2,
    Callback = function(val)
        if isFiniteNumber(val) then
            FunSettings.RainbowRate = val
        end
    end
}), 0.2)
funLeft:Label(TL(
    "Осторожно: spin может кикать в играх с жёсткой защитой.",
    "Обережно: spin може кікати в іграх із жорстким захистом.",
    "Caution: spin may get you kicked in stricter games."
))

funRight = pageFun:Section({ Name = TL("Yasia Hub | Фан-пак", "Yasia Hub | Фан-пак", "Yasia Hub | Fun Pack"), Icon = "star", Side = 2 })
funRight:Toggle({
    Name = TL("Ракетный прыжок", "Ракетний стрибок", "Rocket Jump"),
    Flag = "Fun_RocketJump",
    Default = false,
    Callback = function(val)
        FunSettings.RocketJump = val
    end
})
funRight:Button({
    Name = TL("Отправить :) в чат", "Надіслати :) в чат", "Send :) to chat"),
    Callback = function()
        sendChatMessage(":)")
    end
})
funRight:Button({
    Name = "Grow Character",
    Callback = function()
        if not setCharacterScale(1.15) then
            hubNotify("Fun", "Scale values not found on this rig", 2, true)
        end
    end
})
funRight:Button({
    Name = "Shrink Character",
    Callback = function()
        if not setCharacterScale(0.85) then
            hubNotify("Fun", "Scale values not found on this rig", 2, true)
        end
    end
})
funRight:Button({
    Name = "Reset Character Scale",
    Callback = function()
        if not setCharacterScale(1) then
            hubNotify("Fun", "Scale values not found on this rig", 2, true)
        end
    end
})
end

do
funChat = pageFun:Section({
    Name = TL("Yasia Hub | Чат-инструменты", "Yasia Hub | Чат-інструменти", "Yasia Hub | Chat Tools"),
    Icon = "message-circle",
    Side = 2
})
RuntimeRefs.ChatStatusLabel = funChat:Label(getChatStatusText())
funChat:Label(TL(
    "Сообщения разделяй через | или Enter. Пример: gg | nice | :)",
    "Повідомлення розділяй через | або Enter. Приклад: gg | nice | :)",
    "Separate messages with | or Enter. Example: gg | nice | :)"
))
funChat:Textbox({
    Flag = "Chat_MessageSource",
    Placeholder = TL(
        "Введи 1 или несколько сообщений и нажми Enter",
        "Введи 1 або кілька повідомлень і натисни Enter",
        "Enter one or more chat messages and press Enter"
    ),
    Default = ChatSettings.MessageSource,
    Finished = true,
    Callback = function(val)
        ChatSettings.MessageSource = tostring(val or "")
        ChatSettings.RotateIndex = 0
        updateChatStatusLabel()
    end
})
funChat:Textbox({
    Flag = "Chat_Prefix",
    Placeholder = TL(
        "Префикс перед сообщением, если нужен",
        "Префікс перед повідомленням, якщо потрібен",
        "Optional prefix added before each message"
    ),
    Default = ChatSettings.Prefix,
    Finished = true,
    Callback = function(val)
        ChatSettings.Prefix = tostring(val or "")
        updateChatStatusLabel()
    end
})
funChat:Dropdown({
    Name = TL("Режим отправки", "Режим надсилання", "Send Mode"),
    Flag = "Chat_Mode",
    Values = { "Single", "Rotate", "Random" },
    Default = ChatSettings.Mode,
    Callback = function(val)
        ChatSettings.Mode = tostring(val or "Rotate")
        ChatSettings.RotateIndex = 0
        updateChatStatusLabel()
    end
})
funChat:Dropdown({
    Name = TL("Готовый набор", "Готовий набір", "Preset Pack"),
    Flag = "Chat_Preset",
    Values = { "Friendly", "Yasia", "Trade", "Farm" },
    Default = ChatSettings.SelectedPreset,
    Callback = function(val)
        if applyChatPreset(val) then
            hubNotify(
                TL("Чат", "Чат", "Chat"),
                TL("Загружен набор", "Завантажено набір", "Preset loaded") .. ": " .. tostring(val),
                2,
                true
            )
        end
    end
})
trackSlider(funChat:Slider({
    Name = TL("Интервал лупа", "Інтервал лупу", "Loop Interval"),
    Flag = "Chat_Interval",
    Min = 0.4,
    Max = 15,
    Default = ChatSettings.Interval,
    Decimals = 0.1,
    Callback = function(val)
        if isFiniteNumber(val) then
            ChatSettings.Interval = val
            updateChatStatusLabel()
        end
    end
}), 2.5)
trackSlider(funChat:Slider({
    Name = TL("Размер burst-пакета", "Розмір burst-пакета", "Burst Size"),
    Flag = "Chat_BurstCount",
    Min = 1,
    Max = 10,
    Default = ChatSettings.BurstCount,
    Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then
            ChatSettings.BurstCount = math.clamp(math.floor(val), 1, 10)
            updateChatStatusLabel()
        end
    end
}), 3)
funChat:Toggle({
    Name = TL("Добавлять счётчик", "Додавати лічильник", "Append Counter"),
    Flag = "Chat_IncludeCounter",
    Default = ChatSettings.IncludeCounter,
    Callback = function(val)
        ChatSettings.IncludeCounter = val == true
        updateChatStatusLabel()
    end
})
funChat:Button({
    Name = TL("Отправить 1 раз", "Надіслати 1 раз", "Send Once"),
    Callback = function()
        local sent, message = pushChatMessage()
        hubNotify(
            TL("Чат", "Чат", "Chat"),
            sent and (TL("Отправлено", "Надіслано", "Sent") .. ": " .. tostring(message))
                or TL("Не удалось отправить сообщение", "Не вдалося надіслати повідомлення", "Failed to send message"),
            2,
            true
        )
    end
})
funChat:Button({
    Name = TL("Burst xN", "Burst xN", "Burst xN"),
    Callback = function()
        sendChatBurst(ChatSettings.BurstCount)
    end
})
funChat:Button({
    Name = TL("Чат-луп ВКЛ", "Чат-луп УВІМК", "Chat Loop ON"),
    Callback = function()
        setChatLoopEnabled(true)
        hubNotify(TL("Чат", "Чат", "Chat"), TL("Чат-луп включён", "Чат-луп увімкнено", "Chat loop enabled"), 2, true)
    end
})
funChat:Button({
    Name = TL("Чат-луп ВЫКЛ", "Чат-луп ВИМК", "Chat Loop OFF"),
    Callback = function()
        setChatLoopEnabled(false)
        hubNotify(TL("Чат", "Чат", "Chat"), TL("Чат-луп выключен", "Чат-луп вимкнено", "Chat loop disabled"), 2, true)
    end
})
funChat:Button({
    Name = TL("Скопировать чат-пак", "Скопіювати чат-пак", "Copy Chat Pack"),
    Callback = function()
        local text = tostring(ChatSettings.MessageSource or "")
        local copied = tryCopyText(text)
        hubNotify(
            TL("Чат", "Чат", "Chat"),
            copied and TL("Чат-пак скопирован", "Чат-пак скопійовано", "Chat pack copied") or text,
            copied and 2 or 5,
            true
        )
    end
})
end

do
utilLeft = pageUtility:Section({ Name = TL("Yasia Hub | Сервер", "Yasia Hub | Сервер", "Yasia Hub | Server"), Icon = "server", Side = 1 })
utilLeft:Button({
    Name = TL("Перезайти в этот же сервер", "Перезайти в цей самий сервер", "Rejoin Same Server"),
    Callback = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end)
    end
})
utilLeft:Button({
    Name = TL("Скопировать PlaceId", "Скопіювати PlaceId", "Copy PlaceId"),
    Callback = function()
        print("PlaceId:", game.PlaceId)
        Library:Notification({ Title = "PlaceId", Description = tostring(game.PlaceId), Duration = 3 })
    end
})
utilLeft:Label(TL(
    "JobId / PlaceId можно посмотреть в Output после нажатия.",
    "JobId / PlaceId можна подивитися в Output після натискання.",
    "You can check JobId / PlaceId in Output after pressing the button."
))

utilRight = pageUtility:Section({ Name = TL("Yasia Hub | Персонаж", "Yasia Hub | Персонаж", "Yasia Hub | Character"), Icon = "user", Side = 2 })
utilRight:Button({
    Name = TL("Респавн персонажа", "Респавн персонажа", "Respawn Character"),
    Callback = function()
        pcall(function() LP:LoadCharacter() end)
    end
})
utilRight:Toggle({
    Name = TL("Скрыть ник", "Сховати нік", "Hide Name"),
    Flag = "Util_HideName",
    Default = false,
    Callback = function(val)
        setLocalNameHidden(val)
    end
})
end

do
farmLeft = pageFarm:Section({ Name = TL("Yasia Hub | Авто-фарм", "Yasia Hub | Авто-фарм", "Yasia Hub | Auto Farm"), Icon = "pickaxe", Side = 1 })
farmLeft:Toggle({
    Name = "Auto Farm Master",
    Flag = "Farm_Auto",
    Default = false,
    Callback = function(val)
        FarmSettings.AutoEnabled = val
        if val then
            PresetActions.applyFarm("all")
        else
            FarmSettings.PromptEnabled = false
            FarmSettings.ClickEnabled = false
            FarmSettings.TouchEnabled = false
            FarmSettings.AutoCollectTools = false
        end
    end
})
trackSlider(farmLeft:Slider({
    Name = TL("Радиус поиска (studs)", "Радіус пошуку (studs)", "Search Radius (studs)"),
    Flag = "Farm_Radius",
    Min = 10, Max = 200, Default = 50, Decimals = 1,
    Callback = function(val)
        if type(val) == "number" and val == val then FarmSettings.AutoRadius = val end
    end
}), 50)
farmLeft:Label(TL(
    "При необходимости подключи свои party/collectors прямо в callback.",
    "За потреби підключи свої party/collectors прямо в callback.",
    "If needed, connect your own party/collectors directly in the callback."
))

farmRight = pageFarm:Section({ Name = TL("Yasia Hub | Фильтры", "Yasia Hub | Фільтри", "Yasia Hub | Filters"), Icon = "filter", Side = 2 })
farmRight:Toggle({
    Name = TL("Игнорировать игроков", "Ігнорувати гравців", "Ignore Players"),
    Flag = "Farm_IgnorePlayers",
    Default = true,
    Callback = function(val)
        FarmSettings.IgnorePlayers = val
    end
})
farmRight:Toggle({
    Name = TL("Приоритет ближайшего", "Пріоритет найближчого", "Prefer Nearest"),
    Flag = "Farm_Nearest",
    Default = true,
    Callback = function(val)
        FarmSettings.PreferNearest = val
    end
})
end

do
farmEasy = pageFarm:Section({ Name = TL("Yasia Hub | Легкий старт фарма", "Yasia Hub | Легкий старт фарму", "Yasia Hub | Farm Easy Start"), Icon = "sparkles", Side = 1 })
RuntimeRefs.FarmHelperLabel = farmEasy:Label(TL(
    "Нажми «Автоподбор рядом», если не знаешь, с чего начать.",
    "Натисни «Автопідбір поруч», якщо не знаєш, з чого почати.",
    "Press \"Nearby Auto Setup\" if you are not sure how to start."
))
farmEasy:Button({
    Name = TL("Новичок: безопасный старт", "Новачок: безпечний старт", "Beginner: Safe Start"),
    Callback = function()
        local presetLabel, counts = applyBeginnerFarmPreset("starter")
        hubNotify("Farm", presetLabel .. " | " .. formatFarmNearbyCountsText(counts), 4, true)
    end
})
farmEasy:Button({
    Name = TL("Новичок: сбалансированный старт", "Новачок: збалансований старт", "Beginner: Balanced Start"),
    Callback = function()
        local presetLabel, counts = applyBeginnerFarmPreset("balanced")
        hubNotify("Farm", presetLabel .. " | " .. formatFarmNearbyCountsText(counts), 4, true)
    end
})
farmEasy:Button({
    Name = TL("Новичок: лут-маршрут с ТП", "Новачок: лут-маршрут з ТП", "Beginner: Loot Route With TP"),
    Callback = function()
        local presetLabel, counts = applyBeginnerFarmPreset("looter")
        hubNotify("Farm", presetLabel .. " | " .. formatFarmNearbyCountsText(counts), 4, true)
    end
})
farmEasy:Button({
    Name = TL("Автоподбор рядом", "Автопідбір поруч", "Nearby Auto Setup"),
    Callback = function()
        local counts, found = applySmartNearbyFarmSetup()
        if found then
            hubNotify("Farm", TL("Режим рядом настроен: ", "Режим поруч налаштовано: ", "Nearby setup applied: ") .. formatFarmNearbyCountsText(counts), 4, true)
        else
            hubNotify("Farm", TL("Рядом не найдено prompt/click/tool объектов.", "Поруч не знайдено prompt/click/tool об'єктів.", "No nearby prompt/click/tool objects were found."), 4, true)
        end
    end
})
farmEasy:Button({
    Name = TL("1 лучшее действие рядом", "1 найкраща дія поруч", "Use Best Nearby Action"),
    Callback = function()
        local used = useBestNearbyFarmTarget()
        if used then
            hubNotify("Farm", TL("Использован ближайший источник: ", "Використано найближче джерело: ", "Used nearest source: ") .. tostring(used), 3, true)
        else
            hubNotify("Farm", TL("Рядом нет доступного prompt/click/tool.", "Поруч немає доступного prompt/click/tool.", "No nearby prompt/click/tool source is available."), 3, true)
        end
    end
})
farmEasy:Button({
    Name = TL("1 умный цикл фарма", "1 розумний цикл фарму", "Run 1 Smart Farm Cycle"),
    Callback = function()
        local counts, found = applySmartNearbyFarmSetup()
        if found then
            runFarmCycle()
            hubNotify("Farm", TL("Умный цикл выполнен. ", "Розумний цикл виконано. ", "Smart cycle finished. ") .. formatFarmNearbyCountsText(counts), 4, true)
        else
            hubNotify("Farm", TL("Сначала подойди ближе к объектам фарма.", "Спочатку підійди ближче до об'єктів фарму.", "Move closer to farm objects first."), 3, true)
        end
    end
})
farmEasy:Button({
    Name = TL("Остановить весь фарм", "Зупинити весь фарм", "Stop All Farm"),
    Callback = function()
        stopAllFarmModes()
        hubNotify("Farm", TL("Весь фарм выключен.", "Увесь фарм вимкнено.", "All farm modes are disabled."), 2, true)
    end
})
end

do
tpLeft = pageTeleports:Section({ Name = TL("Yasia Hub | Быстрые точки", "Yasia Hub | Швидкі точки", "Yasia Hub | Quick Points"), Icon = "map-pin", Side = 1 })
tpLeft:Button({
    Name = TL("ТП к Baseplate (если есть)", "ТП до Baseplate (якщо є)", "TP To Baseplate (If Present)"),
    Callback = function()
        pcall(function()
            local b = workspace:FindFirstChild("Baseplate") or workspace:FindFirstChild("Baseplate", true)
            if b and b:IsA("BasePart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = b.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
})
tpLeft:Button({
    Name = TL("ТП к спавну (SpawnLocation)", "ТП до спавну (SpawnLocation)", "TP To Spawn (SpawnLocation)"),
    Callback = function()
        pcall(function()
            local sp = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
            if sp and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = sp.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
})

tpCheckpoint = pageTeleports:Section({ Name = TL("Yasia Hub | Чекпоинт", "Yasia Hub | Чекпоінт", "Yasia Hub | Checkpoint"), Icon = "flag", Side = 1 })
RuntimeRefs.CheckpointStatusLabel = tpCheckpoint:Label(TL("Чекпоинт: нет", "Чекпоінт: немає", "Checkpoint: none"))
tpCheckpoint:Button({
    Name = TL("Сохранить чекпоинт", "Зберегти чекпоінт", "Save Checkpoint"),
    Callback = function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        TeleportSettings.CheckpointCF = hrp.CFrame
        local p = hrp.Position
        pcall(function()
            if RuntimeRefs.CheckpointStatusLabel and RuntimeRefs.CheckpointStatusLabel.SetText then
                RuntimeRefs.CheckpointStatusLabel:SetText(string.format("%s: %.0f, %.0f, %.0f", TL("Чекпоинт", "Чекпоінт", "Checkpoint"), p.X, p.Y, p.Z))
            end
        end)
        Library:Notification({ Title = TL("Чекпоинт", "Чекпоінт", "Checkpoint"), Description = TL("Позиция сохранена", "Позицію збережено", "Position saved"), Duration = 2 })
    end
})
tpCheckpoint:Button({
    Name = TL("ТП к чекпоинту", "ТП до чекпоінта", "TP To Checkpoint"),
    Callback = function()
        local cf = TeleportSettings.CheckpointCF
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not cf or not hrp then
            Library:Notification({ Title = TL("Чекпоинт", "Чекпоінт", "Checkpoint"), Description = TL("Сначала сохрани позицию", "Спочатку збережи позицію", "Save a position first"), Duration = 2 })
            return
        end
        pcall(function()
            rememberCurrentPosition()
            hrp.CFrame = cf
        end)
    end
})

tpRight = pageTeleports:Section({ Name = TL("Yasia Hub | Игроки", "Yasia Hub | Гравці", "Yasia Hub | Players"), Icon = "users", Side = 2 })
RuntimeRefs.TeleportPlayerDropdown = tpRight:Dropdown({
    Name = TL("Игрок для ТП", "Гравець для ТП", "Player For TP"),
    Flag = "TP_PlayerPick",
    Items = {},
    Default = "",
    Callback = function(s) TeleportSettings.SavedName = s or "" end
})
tpRight:Button({
    Name = TL("Телепорт к выбранному", "Телепорт до вибраного", "Teleport To Selected"),
    Callback = function()
        local p = Players:FindFirstChild(TeleportSettings.SavedName)
        if p then teleportToPlayer(p) end
    end
})
tpRight:Button({
    Name = TL("Обновить список", "Оновити список", "Refresh List"),
    Callback = function()
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end
})
end

do
adminLeft = pageAdmin:Section({ Name = TL("Yasia Hub | Камера / Наблюдение", "Yasia Hub | Камера / Спостереження", "Yasia Hub | Camera / Spectate"), Icon = "video", Side = 1 })
RuntimeRefs.AdminSpectateDropdown = adminLeft:Dropdown({
    Name = TL("Игрок для спектейта", "Гравець для спектейта", "Spectate Player"),
    Flag = "Admin_SpecPick",
    Items = {},
    Default = "",
    Callback = function(s) AdminSettings.SpectateName = s or "" end
})
adminLeft:Button({
    Name = TL("Смотреть за выбранным", "Дивитися за вибраним", "Spectate Selected"),
    Callback = function()
        local p = Players:FindFirstChild(AdminSettings.SpectateName)
        if p and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            workspace.CurrentCamera.CameraSubject = p.Character.Humanoid
        end
    end
})
adminLeft:Button({
    Name = TL("Камера на себя", "Камера на себе", "Reset Camera To Self"),
    Callback = function()
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then workspace.CurrentCamera.CameraSubject = h end
    end
})
adminLeft:Button({
    Name = TL("Обновить список", "Оновити список", "Refresh List"),
    Callback = function()
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end
})

adminRight = pageAdmin:Section({ Name = "Yasia Hub | INFO", Icon = "info", Side = 2 })
adminRight:Button({
    Name = TL("Вывести JobId в консоль", "Вивести JobId в консоль", "Print JobId To Console"),
    Callback = function()
        print("JobId:", game.JobId)
        Library:Notification({ Title = "JobId", Description = tostring(game.JobId), Duration = 4 })
    end
})
adminRight:Toggle({
    Name = "POKAZAT verified / premium IGROKOV",
    Flag = "Admin_ListAdmins",
    Default = false,
    Callback = function(val)
        if not val then
            return
        end
        local names = {}
        for _, player in ipairs(Players:GetPlayers()) do
            local okPremium, isPremium = pcall(function()
                return player.MembershipType == Enum.MembershipType.Premium
            end)
            local okVerified, isVerified = pcall(function()
                return player.HasVerifiedBadge
            end)
            if (okPremium and isPremium) or (okVerified and isVerified) then
                table.insert(names, player.Name)
            end
        end
        local text = #names > 0 and table.concat(names, ", ") or "NIKOGO NE NAYDENO"
        print("[" .. HUB_TAG .. "] verified/premium:", text)
        hubNotify("Players", text, 4, true)
    end
})
end


do
vehicleLeft = pageVehicles:Section({ Name = "Yasia Hub | Vehicle Fly", Icon = "plane", Side = 1 })

vehicleLeft:Toggle({
    Name = "Vehicle Fly (TREBUETSYa SIDET)",
    Flag = "VehicleFly_Toggle",
    Default = false,
    Callback = function(val)
        VehicleSystem.FlyEnabled = val
        if val then
            local char = LP.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid.SeatPart then
                    setupVehicleFlyInstances(char)
                else
                    VehicleSystem.seatConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
                        if humanoid.SeatPart and VehicleSystem.FlyEnabled then
                            setupVehicleFlyInstances(LP.Character)
                        end
                    end)
                end
                VehicleSystem.unseatConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
                    if not humanoid.SeatPart and not VehicleSystem.FwF then
                        disableVehicleFly()
                    end
                end)
            end
        else
            disableVehicleFly()
        end
    end
})

vehicleLeft:Toggle({
    Name = "FwF (POLET BEZ SIDENIYa)",
    Flag = "VehicleFly_FwF",
    Default = false,
    Callback = function(val)
        VehicleSystem.FwF = val
        if VehicleSystem.FlyEnabled then
            if val then
                setupVehicleFlyInstances(LP.Character)
            elseif not (LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") and LP.Character:FindFirstChildOfClass("Humanoid").SeatPart) then
                disableVehicleFly()
            end
        end
    end
})

vehicleLeft:Toggle({
    Name = "Anti-Lock (OTNOSITELNO KRESLA)",
    Flag = "VehicleFly_AntiLock",
    Default = false,
    Callback = function(val)
        VehicleSystem.AntiLock = val
    end
})

vehicleLeft:Toggle({
    Name = "Pitch (NAKLON PO KAMERE)",
    Flag = "VehicleFly_Pitch",
    Default = false,
    Callback = function(val)
        VehicleSystem.Pitch = val
    end
})

trackSlider(vehicleLeft:Slider({
    Name = "SKOROST POLETA",
    Flag = "VehicleFly_Speed",
    Min = 10, Max = 500, Default = 100, Decimals = 1,
    Callback = function(val) VehicleSystem.Speed = val end
}), 100)

trackSlider(vehicleLeft:Slider({
    Name = TL("Скорость подъёма", "Швидкість підйому", "Lift Speed"),
    Flag = "VehicleFly_UpSpeed",
    Min = 10, Max = 200, Default = 50, Decimals = 1,
    Callback = function(val) VehicleSystem.UpSpeed = val end
}), 50)

vehicleLeft:Label(TL(
    "Управление: WASD движение, Space вверх, Ctrl вниз, Q/E поворот.",
    "Керування: WASD рух, Space вгору, Ctrl вниз, Q/E поворот.",
    "Controls: WASD move, Space up, Ctrl down, Q/E rotate."
))

vehicleSpeedHackSec = pageVehicles:Section({ Name = TL("Yasia Hub | Спидхак машины", "Yasia Hub | Спідхак машини", "Yasia Hub | Vehicle Speedhack"), Icon = "gauge", Side = 1 })
vehicleSpeedHackSec:Toggle({
    Name = TL("Vehicle Speedhack (в транспорте)", "Vehicle Speedhack (у транспорті)", "Vehicle Speedhack (While Seated)"),
    Flag = "Vehicle_SpeedHack",
    Default = false,
    Callback = function(val)
        VehicleSystem.SpeedHackEnabled = val
        if val then
            startVehicleSpeedHack()
        else
            stopVehicleSpeedHack()
        end
    end
})
trackSlider(vehicleSpeedHackSec:Slider({
    Name = TL("Целевая скорость / MaxSpeed", "Цільова швидкість / MaxSpeed", "Target Speed / MaxSpeed"),
    Flag = "Vehicle_SpeedHack_Value",
    Min = 50, Max = 500, Default = 200, Decimals = 1,
    Callback = function(val)
        if type(val) == "number" and val == val then
            VehicleSystem.SpeedHackMaxSpeed = val
        end
    end
}), 200)
vehicleSpeedHackSec:Label(TL(
    "VehicleSeat удерживает MaxSpeed. Отключается при Vehicle Fly.",
    "VehicleSeat утримує MaxSpeed. Вимикається при Vehicle Fly.",
    "VehicleSeat keeps MaxSpeed applied. Disabled while Vehicle Fly is active."
))

vehicleRight = pageVehicles:Section({ Name = TL("Yasia Hub | Multi Fling (с ног)", "Yasia Hub | Multi Fling (з ніг)", "Yasia Hub | Multi Fling (On Foot)"), Icon = "wind", Side = 2 })

FlingSystem.StatusLabel = vehicleRight:Label(TL("Целей: 0 | СТОП", "Цілей: 0 | СТОП", "Targets: 0 | STOP"))

FlingSystem.Dropdown = vehicleRight:Dropdown({
    Name = TL("Игрок из списка", "Гравець зі списку", "Player From List"),
    Flag = "Fling_Pick",
    Items = {},
    Default = "",
    Callback = function(selected)
        FlingSystem.PickName = selected or ""
    end
})

vehicleRight:Button({
    Name = TL("Добавить в цели", "Додати в цілі", "Add To Targets"),
    Callback = function()
        local n = FlingSystem.PickName
        if n and n ~= "" then
            local p = Players:FindFirstChild(n)
            if p and p ~= LP then
                FlingSystem.SelectedTargets[n] = p
            end
        end
        updateFlingStatusText()
    end
})

vehicleRight:Button({
    Name = TL("Убрать из целей", "Прибрати з цілей", "Remove From Targets"),
    Callback = function()
        local n = FlingSystem.PickName
        if n and n ~= "" then
            FlingSystem.SelectedTargets[n] = nil
        end
        updateFlingStatusText()
    end
})

vehicleRight:Button({
    Name = TL("Выбрать всех", "Вибрати всіх", "Select All"),
    Callback = function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                FlingSystem.SelectedTargets[plr.Name] = plr
            end
        end
        updateFlingStatusText()
    end
})

vehicleRight:Button({
    Name = TL("Снять выбор", "Зняти вибір", "Clear Selection"),
    Callback = function()
        for k in pairs(FlingSystem.SelectedTargets) do
            FlingSystem.SelectedTargets[k] = nil
        end
        updateFlingStatusText()
    end
})

refreshAllPlayerDropdowns = function()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then table.insert(names, plr.Name) end
    end
    for _, name in ipairs(AimbotSettings.IgnoredPlayersDropdownValues) do
        addUniqueValue(names, name)
    end
    for _, name in ipairs(AimbotSettings.TargetPlayersDropdownValues) do
        addUniqueValue(names, name)
    end
    table.sort(names)
    safeDropdownRefresh(FlingSystem.Dropdown, names)
    safeDropdownRefresh(RuntimeRefs.TeleportPlayerDropdown, names)
    safeDropdownRefresh(RuntimeRefs.AdminSpectateDropdown, names)
    safeDropdownRefresh(RuntimeRefs.OrbitDropdown, names)
    safeDropdownRefresh(RuntimeRefs.AdminFollowDropdown, names)
    safeDropdownRefresh(RuntimeRefs.CombatTargetDropdown, names)
    safeDropdownRefresh(AimbotRuntime.IgnoredPlayersDropdown, names)
    safeDropdownRefresh(AimbotRuntime.TargetPlayersDropdown, names)
    pcall(function()
        if AimbotRuntime.IgnoredPlayersDropdown and type(AimbotRuntime.IgnoredPlayersDropdown.Set) == "function" then
            AimbotRuntime.IgnoredPlayersDropdown:Set(AimbotSettings.IgnoredPlayers, true)
        end
        if AimbotRuntime.TargetPlayersDropdown and type(AimbotRuntime.TargetPlayersDropdown.Set) == "function" then
            AimbotRuntime.TargetPlayersDropdown:Set(AimbotSettings.TargetPlayers, true)
        end
    end)
    updateFlingStatusText()
end

vehicleRight:Toggle({
    Name = TL("Multi Skid Fling (цикл)", "Multi Skid Fling (цикл)", "Multi Skid Fling (Loop)"),
    Flag = "Fling_MultiActive",
    Default = false,
    Callback = function(val)
        if val then
            if next(FlingSystem.SelectedTargets) == nil then
                Library:Notification({ Title = TL("Ошибка", "Помилка", "Error"), Description = TL("Сначала добавь игроков в цели кнопкой ниже.", "Спочатку додай гравців у цілі кнопкою нижче.", "Add players to targets first using the button below."), Duration = 3 })
                return
            end
            FlingSystem.Active = true
            startMultiSkidFling()
        else
            stopSkidFling()
        end
        updateFlingStatusText()
    end
})

vehicleRight:Button({
    Name = TL("Обновить список игроков", "Оновити список гравців", "Refresh Player List"),
    Callback = function()
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end
})

vehicleRight:Label(TL(
    "Fling с ног (Skid): твой HRP идёт к цели. Останови тумблером Multi Skid Fling.",
    "Fling з ніг (Skid): твій HRP іде до цілі. Зупини тумблером Multi Skid Fling.",
    "On-foot fling (Skid): your HRP pushes into the target. Stop it with the Multi Skid Fling toggle."
))
end

do
touchFlingLeft = pageTouchFling:Section({ Name = "Yasia Hub | Touch Fling", Icon = "zap", Side = 1 })
touchFlingLeft:Toggle({
    Name = "Touch Fling",
    Flag = "TouchFling_Toggle",
    Default = false,
    Callback = function(val)
        if val then startTouchFling() else stopTouchFling() end
    end
})
touchFlingLeft:Label(TL(
    "Touch Fling срабатывает при касании. Будь осторожен.",
    "Touch Fling спрацьовує при дотику. Будь обережний.",
    "Touch Fling triggers on contact. Use with caution."
))
end

do
antiFlingLeft = pageAntiFling:Section({ Name = "Yasia Hub | Anti Fling", Icon = "shield", Side = 1 })
antiFlingLeft:Toggle({
    Name = "Anti Fling",
    Flag = "AntiFling_Toggle",
    Default = false,
    Callback = function(val)
        if val then startAntiFling() else stopAntiFling() end
    end
})
antiFlingLeft:Label(TL(
    "Anti Fling защищает от fling со стороны других игроков.",
    "Anti Fling захищає від fling з боку інших гравців.",
    "Anti Fling protects you from other players flinging you."
))
antiFlingLeft:Button({
    Name = "Disable Anti Fling",
    Callback = function()
        _G.disable()
    end
})
end

do
mainActions = pageMain:Section({
    Name = TL("Yasia Hub | Быстрые действия", "Yasia Hub | Швидкі дії", "Yasia Hub | Quick Actions"),
    Icon = "bolt",
    Side = 1
})
mainActions:Button({
    Name = TL("Сесть", "Сісти", "Sit"),
    Callback = function()
        local hum = getHumanoid()
        if hum then hum.Sit = true end
    end
})
mainActions:Button({
    Name = TL("Встать", "Встати", "Stand Up"),
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
})
mainActions:Button({
    Name = TL("Назад к прошлому TP", "Назад до минулого TP", "Back to Last TP"),
    Callback = function()
        if TeleportSettings.LastCF then
            local cf = TeleportSettings.LastCF
            TeleportSettings.LastCF = nil
            teleportLocalTo(cf)
        end
    end
})
mainActions:Button({
    Name = TL("Сбросить Speed/Jump/Gravity", "Скинути Speed/Jump/Gravity", "Reset Speed/Jump/Gravity"),
    Callback = function()
        setWalkSpeed(16)
        setJumpPower(50)
        setGravity(196.2)
    end
})
mainActions:Button({
    Name = TL("Экипировать все Tools", "Екіпірувати всі Tools", "Equip All Tools"),
    Callback = function()
        equipAllTools()
    end
})
end

do
espExtra = pageESP:Section({ Name = TL("Yasia Hub | Расширенный ESP", "Yasia Hub | Розширений ESP", "Yasia Hub | Advanced ESP"), Icon = "radar", Side = 1 })
espExtra:Toggle({
    Name = "Tracer Lines",
    Flag = "ESP_Tracers",
    Default = false,
    Callback = function(val) espShowTracer = val end
})
espExtra:Toggle({
    Name = "Head Dot",
    Flag = "ESP_HeadDot",
    Default = false,
    Callback = function(val) espShowHeadDot = val end
})
espExtra:Toggle({
    Name = TL("Показывать DisplayName", "Показувати DisplayName", "Show DisplayName"),
    Flag = "ESP_DisplayName",
    Default = false,
    Callback = function(val) espUseDisplayName = val end
})
espExtra:Toggle({
    Name = TL("HP в тексте", "HP у тексті", "HP in Text"),
    Flag = "ESP_ShowHPText",
    Default = true,
    Callback = function(val) espShowHealthText = val end
})
espExtra:Toggle({
    Name = "Hide Teammates",
    Flag = "ESP_HideTeammates",
    Default = false,
    Callback = function(val) espHideTeammates = val end
})
espExtra:Toggle({
    Name = "Only Alive",
    Flag = "ESP_OnlyAlive",
    Default = true,
    Callback = function(val) espOnlyAlive = val end
})
espExtra:Toggle({
    Name = "Rainbow ESP",
    Flag = "ESP_Rainbow",
    Default = false,
    Callback = function(val) espRainbow = val end
})
trackSlider(espExtra:Slider({
    Name = TL("Макс. дистанция ESP", "Макс. дистанція ESP", "Max ESP Distance"),
    Flag = "ESP_MaxDistance",
    Min = 100, Max = 5000, Default = 2500, Decimals = 10,
    Callback = function(val)
        if isFiniteNumber(val) then espMaxDistance = val end
    end
}), 2500)
end

do
moveAdvanced = pageMovement:Section({ Name = TL("Yasia Hub | Продвинутое движение", "Yasia Hub | Просунутий рух", "Yasia Hub | Advanced Movement"), Icon = "chevrons-up", Side = 2 })
moveAdvanced:Toggle({
    Name = "Bunny Hop",
    Flag = "Move_BHop",
    Default = false,
    Callback = function(val) MovementSettings.BunnyHop = val end
})
moveAdvanced:Toggle({
    Name = "Glide (Space)",
    Flag = "Move_Glide",
    Default = false,
    Callback = function(val) MovementSettings.Glide = val end
})
trackSlider(moveAdvanced:Slider({
    Name = "SKOROST PADENIYa Glide",
    Flag = "Move_GlideSpeed",
    Min = -120, Max = -5, Default = -25, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then MovementSettings.GlideFallSpeed = val end
    end
}), -25)
moveAdvanced:Toggle({
    Name = "Anti Void",
    Flag = "Move_AntiVoid",
    Default = false,
    Callback = function(val)
        MovementSettings.AntiVoid = val
        if val then
            local root = getRootPart()
            if root then
                MovementSettings.LastSafeCF = root.CFrame
                MovementSettings.LastSafeAt = tick()
            end
            MovementSettings.LastRescueAt = 0
        end
    end
})
trackSlider(moveAdvanced:Slider({
    Name = "POROG Void PO Y",
    Flag = "Move_VoidY",
    Min = -500, Max = 50, Default = -40, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then MovementSettings.VoidY = val end
    end
}), -40)
trackSlider(moveAdvanced:Slider({
    Name = "VYSOTA SPASENIYa",
    Flag = "Move_VoidRescue",
    Min = 2, Max = 40, Default = 6, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then MovementSettings.RescueOffset = val end
    end
}), 6)
moveAdvanced:Toggle({
    Name = "Air Stuck",
    Flag = "Move_AirStuck",
    Default = false,
    Callback = function(val) MovementSettings.AirStuck = val end
})
moveAdvanced:Toggle({
    Name = "Anti Sit",
    Flag = "Move_AntiSit",
    Default = false,
    Callback = function(val) MovementSettings.AntiSit = val end
})
moveAdvanced:Toggle({
    Name = "Anti PlatformStand",
    Flag = "Move_AntiPS",
    Default = false,
    Callback = function(val) MovementSettings.AntiPlatformStand = val end
})
moveAdvanced:Toggle({
    Name = TL("Поворачивать к ближайшему", "Повертати до найближчого", "Rotate To Nearest"),
    Flag = "Move_AutoRotateNearest",
    Default = false,
    Callback = function(val) MovementSettings.AutoRotateNearest = val end
})
moveAdvanced:Button({
    Name = TL("Запомнить safe position", "Запам'ятати safe position", "Remember Safe Position"),
    Callback = function()
        local root = getRootPart()
        if root then
            MovementSettings.LastSafeCF = root.CFrame
            MovementSettings.LastSafeAt = tick()
        end
    end
})
end

do
combatAssist = pageCombat:Section({ Name = "Yasia Hub | Aim / Hitbox", Icon = "crosshair", Side = 2 })
combatAssist:Toggle({
    Name = "Aim Assist",
    Flag = "Combat_AimAssist",
    Default = false,
    Callback = function(val) CombatSettings.AimAssist = val end
})
trackSlider(combatAssist:Slider({
    Name = "Aim FOV (px)",
    Flag = "Combat_AimFov",
    Min = 25, Max = 500, Default = 180, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then CombatSettings.AimFov = val end
    end
}), 180)
combatAssist:Dropdown({
    Name = "Aim Part",
    Flag = "Combat_AimPart",
    Items = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" },
    Default = "Head",
    Callback = function(val)
        CombatSettings.AimPart = val or "Head"
    end
})
RuntimeRefs.CombatTargetDropdown = combatAssist:Dropdown({
    Name = "Target Lock",
    Flag = "Combat_TargetLockName",
    Items = {},
    Default = "",
    Callback = function(val)
        CombatSettings.TargetLockName = val or ""
    end
})
combatAssist:Toggle({
    Name = "VKL. Target Lock",
    Flag = "Combat_TargetLockEnabled",
    Default = false,
    Callback = function(val)
        CombatSettings.TargetLockEnabled = val
    end
})
combatAssist:Toggle({
    Name = TL("Проверка команды", "Перевірка команди", "Team Check"),
    Flag = "Combat_TeamCheck",
    Default = false,
    Callback = function(val) CombatSettings.TeamCheck = val end
})
combatAssist:Toggle({
    Name = TL("Авто-спам инструментом", "Авто-спам інструментом", "Auto Tool Spam"),
    Flag = "Combat_ToolSpam",
    Default = false,
    Callback = function(val) CombatSettings.AutoToolSpam = val end
})
trackSlider(combatAssist:Slider({
    Name = TL("Интервал спама инструментом", "Інтервал спаму інструментом", "Tool Spam Interval"),
    Flag = "Combat_ToolSpamInterval",
    Min = 0.05, Max = 1, Default = 0.15, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then CombatSettings.ToolSpamInterval = val end
    end
}), 0.15)
combatAssist:Toggle({
    Name = TL("Расширение хитбокса", "Розширення хітбокса", "Hitbox Expander"),
    Flag = "Combat_HitboxExpand",
    Default = false,
    Callback = function(val)
        CombatSettings.HitboxExpand = val
        setupHitboxMonitoring()
    end
})
trackSlider(combatAssist:Slider({
    Name = TL("Размер хитбокса", "Розмір хітбокса", "Hitbox Size"),
    Flag = "Combat_HitboxSize",
    Min = 2, Max = 15, Default = 5, Decimals = 0.5,
    Callback = function(val)
        if isFiniteNumber(val) then CombatSettings.HitboxSize = val end
    end
}), 5)
trackSlider(combatAssist:Slider({
    Name = TL("Прозрачность хитбокса", "Прозорість хітбокса", "Hitbox Transparency"),
    Flag = "Combat_HitboxTransparency",
    Min = 0, Max = 1, Default = 0.5, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then CombatSettings.HitboxTransparency = val end
    end
}), 0.5)
combatAssist:Button({
    Name = TL("ТП к lock-цели", "ТП до lock-цілі", "TP To Locked Target"),
    Callback = function()
        local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName)
        local root = plr and getRootPart(plr.Character)
        if root then
            teleportLocalTo(root.CFrame * CFrame.new(0, 0, 3))
        end
    end
})
combatAssist:Button({
    Name = TL("Смотреть на lock-цель", "Дивитися на lock-ціль", "Look At Locked Target"),
    Callback = function()
        local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName)
        local root = plr and getRootPart(plr.Character)
        local myRoot = getRootPart()
        if root and myRoot then
            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(root.Position.X, myRoot.Position.Y, root.Position.Z))
        end
    end
})
end

do
aimbotCore = pageAimbot:Section({ Name = T("oa_core"), Icon = "crosshair", Side = 1 })
RuntimeRefs.AimbotStatusLabel = aimbotCore:Label(getAimbotStatusText())
aimbotCore:Label(TF("aimbot_caps", canUseMouseAim() and T("yes") or T("no"), canUseSilentAim() and T("yes") or T("no")))
aimbotCore:Label(T("aimbot_bind_hint"))
aimbotCore:Label(TL(
    "Если keybind неудобен или перекрывается меню, используй кнопки ручной активации ниже.",
    "Якщо keybind незручний або перекривається меню, використовуй кнопки ручної активації нижче.",
    "If the keybind is awkward or blocked by the menu, use the manual activation buttons below."
))
aimbotCore:Toggle({
    Name = T("oa_enable"),
    Flag = "Aimbot_Enable",
    Default = false,
    Callback = function(val)
        AimbotSettings.Enabled = val
        if not val then
            AimbotRuntime.KeybindActive = false
            AimbotSettings.BindActive = false
            AimbotRuntime.CurrentTargetData = nil
            AimbotRuntime.ManualActivation = false
        end
        refreshAimbotBindState()
        updateAimbotStatusLabel()
    end
})
aimbotCore:Button({
    Name = TL("Активировать аимбот сейчас", "Активувати аімбот зараз", "Activate Aimbot Now"),
    Callback = function()
        AimbotSettings.Enabled = true
        AimbotRuntime.ManualActivation = true
        AimbotSettings.BindActive = true
        refreshAimbotBindState()
        updateAimbotStatusLabel()
        hubNotify(T("aimbot"), TL("Аимбот активирован вручную.", "Аімбот активовано вручну.", "Aimbot armed manually."), 2, true)
    end
})
aimbotCore:Button({
    Name = TL("Выключить ручную активацию", "Вимкнути ручну активацію", "Disable Manual Activation"),
    Callback = function()
        AimbotRuntime.ManualActivation = false
        AimbotSettings.BindActive = false
        AimbotRuntime.CurrentTargetData = nil
        refreshAimbotBindState()
        updateAimbotStatusLabel()
        hubNotify(T("aimbot"), TL("Ручная активация аимбота выключена.", "Ручну активацію аімбота вимкнено.", "Manual aimbot activation disabled."), 2, true)
    end
})
AimbotRuntime.AimKeybind = aimbotCore:Keybind({
    Name = T("aim_key"),
    Flag = "Aimbot_AimKey",
    Default = Enum.UserInputType.MouseButton2,
    Mode = "Hold",
    Callback = function(state)
        AimbotRuntime.KeybindActive = state == true
        refreshAimbotBindState()
        updateAimbotStatusLabel()
    end
})
aimbotCore:Dropdown({
    Name = T("oa_mode"),
    Flag = "Aimbot_Mode",
    Items = AimbotSettings.AvailableModes,
    Default = AimbotSettings.Mode,
    Callback = function(val)
        if val and table.find(AimbotSettings.AvailableModes, val) then
            AimbotSettings.Mode = val
        else
            AimbotSettings.Mode = "Camera"
        end
        updateAimbotStatusLabel()
    end
})
aimbotCore:Dropdown({
    Name = TL("Методы Silent Aim", "Методи Silent Aim", "Silent Aim Methods"),
    Flag = "Aimbot_SilentMethods",
    Items = {
        "Mouse.Hit / Mouse.Target",
        "GetMouseLocation",
        "Raycast",
        "FindPartOnRay",
        "FindPartOnRayWithIgnoreList",
        "FindPartOnRayWithWhitelist",
    },
    Multi = true,
    Search = true,
    Default = AimbotSettings.SilentAimMethods,
    Callback = function(val)
        AimbotSettings.SilentAimMethods = val or {}
    end
})
trackSlider(aimbotCore:Slider({
    Name = T("oa_silent"),
    Flag = "Aimbot_SilentChance",
    Min = 1, Max = 100, Default = 100, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.SilentAimChance = val end
    end
}), 100)
aimbotCore:Toggle({
    Name = TL("Выключать после убийства", "Вимикати після вбивства", "Disable After Kill"),
    Flag = "Aimbot_OffAfterKill",
    Default = false,
    Callback = function(val) AimbotSettings.OffAfterKill = val end
})
end

do
aimbotParts = pageAimbot:Section({ Name = T("oa_offset"), Icon = "target", Side = 1 })
AimbotRuntime.AimPartDropdown = aimbotParts:Dropdown({
    Name = T("oa_part"),
    Flag = "Aimbot_AimPart",
    Items = AimbotSettings.AimPartValues,
    Default = AimbotSettings.AimPart,
    Callback = function(val)
        AimbotSettings.AimPart = val or "HumanoidRootPart"
    end
})
aimbotParts:Toggle({
    Name = TL("Случайная часть цели", "Випадкова частина цілі", "Random Aim Part"),
    Flag = "Aimbot_RandomAimPart",
    Default = false,
    Callback = function(val) AimbotSettings.RandomAimPart = val end
})
aimbotParts:Textbox({
    Flag = "Aimbot_AddAimPart",
    Placeholder = TL("Добавь часть цели и нажми Enter", "Додай частину цілі й натисни Enter", "Add an aim part and press Enter"),
    Default = "",
    Finished = true,
    Callback = function(val)
        val = tostring(val or "")
        if val ~= "" then
            addUniqueValue(AimbotSettings.AimPartValues, val)
            if AimbotRuntime.AimPartDropdown then
                AimbotRuntime.AimPartDropdown:Refresh(AimbotSettings.AimPartValues)
                AimbotRuntime.AimPartDropdown:Set(val, true)
            end
            AimbotSettings.AimPart = val
        end
    end
})
aimbotParts:Textbox({
    Flag = "Aimbot_RemoveAimPart",
    Placeholder = TL("Удали часть цели и нажми Enter", "Видали частину цілі й натисни Enter", "Remove an aim part and press Enter"),
    Default = "",
    Finished = true,
    Callback = function(val)
        val = tostring(val or "")
        if val ~= "" and table.find(AimbotSettings.AimPartValues, val) then
            removeValue(AimbotSettings.AimPartValues, val)
            if AimbotSettings.AimPart == val then
                AimbotSettings.AimPart = AimbotSettings.AimPartValues[1] or "HumanoidRootPart"
            end
            if AimbotRuntime.AimPartDropdown then
                AimbotRuntime.AimPartDropdown:Refresh(AimbotSettings.AimPartValues)
                if table.find(AimbotSettings.AimPartValues, AimbotSettings.AimPart) then
                    AimbotRuntime.AimPartDropdown:Set(AimbotSettings.AimPart, true)
                end
            end
        end
    end
})
aimbotParts:Toggle({
    Name = TL("Использовать смещение", "Використовувати зміщення", "Use Offset"),
    Flag = "Aimbot_UseOffset",
    Default = false,
    Callback = function(val) AimbotSettings.UseOffset = val end
})
aimbotParts:Dropdown({
    Name = TL("Тип смещения", "Тип зміщення", "Offset Type"),
    Flag = "Aimbot_OffsetType",
    Items = { "Static", "Dynamic", "Static & Dynamic" },
    Default = AimbotSettings.OffsetType,
    Callback = function(val) AimbotSettings.OffsetType = val or "Static" end
})
trackSlider(aimbotParts:Slider({
    Name = TL("Статическое смещение", "Статичне зміщення", "Static Offset"),
    Flag = "Aimbot_StaticOffset",
    Min = 1, Max = 50, Default = 10, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.StaticOffsetIncrement = val end
    end
}), 10)
trackSlider(aimbotParts:Slider({
    Name = TL("Динамическое смещение", "Динамічне зміщення", "Dynamic Offset"),
    Flag = "Aimbot_DynamicOffset",
    Min = 1, Max = 50, Default = 10, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.DynamicOffsetIncrement = val end
    end
}), 10)
aimbotParts:Toggle({
    Name = TL("Авто-смещение", "Авто-зміщення", "Auto Offset"),
    Flag = "Aimbot_AutoOffset",
    Default = false,
    Callback = function(val) AimbotSettings.AutoOffset = val end
})
trackSlider(aimbotParts:Slider({
    Name = TL("Макс. авто-смещение", "Макс. авто-зміщення", "Max Auto Offset"),
    Flag = "Aimbot_MaxAutoOffset",
    Min = 1, Max = 50, Default = 50, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.MaxAutoOffset = val end
    end
}), 50)
aimbotParts:Toggle({
    Name = TL("Использовать чувствительность", "Використовувати чутливість", "Use Sensitivity"),
    Flag = "Aimbot_UseSensitivity",
    Default = false,
    Callback = function(val) AimbotSettings.UseSensitivity = val end
})
trackSlider(aimbotParts:Slider({
    Name = TL("Чувствительность", "Чутливість", "Sensitivity"),
    Flag = "Aimbot_Sensitivity",
    Min = 1, Max = 100, Default = 50, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.Sensitivity = val end
    end
}), 50)
aimbotParts:Toggle({
    Name = TL("Добавить шум", "Додати шум", "Use Noise"),
    Flag = "Aimbot_UseNoise",
    Default = false,
    Callback = function(val) AimbotSettings.UseNoise = val end
})
trackSlider(aimbotParts:Slider({
    Name = TL("Частота шума", "Частота шуму", "Noise Frequency"),
    Flag = "Aimbot_NoiseFreq",
    Min = 1, Max = 100, Default = 50, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.NoiseFrequency = val end
    end
}), 50)
end

do
aimbotChecks = pageAimbot:Section({ Name = T("oa_checks"), Icon = "shield-check", Side = 2 })
aimbotChecks:Toggle({ Name = TL("Проверка на живых", "Перевірка на живих", "Alive Check"), Flag = "Aimbot_AliveCheck", Default = false, Callback = function(val) AimbotSettings.AliveCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка на God Mode", "Перевірка на God Mode", "God Check"), Flag = "Aimbot_GodCheck", Default = false, Callback = function(val) AimbotSettings.GodCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка команды", "Перевірка команди", "Team Check"), Flag = "Aimbot_TeamCheck", Default = false, Callback = function(val) AimbotSettings.TeamCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка друзей", "Перевірка друзів", "Friend Check"), Flag = "Aimbot_FriendCheck", Default = false, Callback = function(val) AimbotSettings.FriendCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка follow-цели", "Перевірка follow-цілі", "Follow Check"), Flag = "Aimbot_FollowCheck", Default = false, Callback = function(val) AimbotSettings.FollowCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка verified badge", "Перевірка verified badge", "Verified Badge Check"), Flag = "Aimbot_VerifiedCheck", Default = false, Callback = function(val) AimbotSettings.VerifiedBadgeCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка стены", "Перевірка стіни", "Wall Check"), Flag = "Aimbot_WallCheck", Default = false, Callback = function(val) AimbotSettings.WallCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка воды", "Перевірка води", "Water Check"), Flag = "Aimbot_WaterCheck", Default = false, Callback = function(val) AimbotSettings.WaterCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка FoV", "Перевірка FoV", "FoV Check"), Flag = "Aimbot_FovCheck", Default = false, Callback = function(val) AimbotSettings.FoVCheck = val end })
trackSlider(aimbotChecks:Slider({
    Name = TL("Радиус FoV", "Радіус FoV", "FoV Radius"),
    Flag = "Aimbot_FovRadius",
    Min = 10, Max = 1000, Default = 120, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.FoVRadius = val end
    end
}), 120)
aimbotChecks:Toggle({ Name = TL("Проверка дистанции", "Перевірка дистанції", "Magnitude Check"), Flag = "Aimbot_MagnitudeCheck", Default = false, Callback = function(val) AimbotSettings.MagnitudeCheck = val end })
trackSlider(aimbotChecks:Slider({
    Name = TL("Дистанция триггера", "Дистанція тригера", "Trigger Magnitude"),
    Flag = "Aimbot_TriggerMagnitude",
    Min = 10, Max = 1000, Default = 500, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.TriggerMagnitude = val end
    end
}), 500)
aimbotChecks:Toggle({ Name = TL("Проверка прозрачности", "Перевірка прозорості", "Transparency Check"), Flag = "Aimbot_TransparencyCheck", Default = false, Callback = function(val) AimbotSettings.TransparencyCheck = val end })
trackSlider(aimbotChecks:Slider({
    Name = TL("Игнорируемая прозрачность", "Ігнорована прозорість", "Ignored Transparency"),
    Flag = "Aimbot_IgnoredTransparency",
    Min = 0.1, Max = 1, Default = 0.5, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.IgnoredTransparency = val end
    end
}), 0.5)
aimbotChecks:Toggle({ Name = TL("Игнорировать Premium", "Ігнорувати Premium", "Ignore Premium Users"), Flag = "Aimbot_PremiumCheck", Default = false, Callback = function(val) AimbotSettings.PremiumCheck = val end })
aimbotChecks:Toggle({ Name = TL("Проверка whitelist-группы", "Перевірка whitelist-групи", "Whitelist Group Check"), Flag = "Aimbot_WhitelistGroupCheck", Default = false, Callback = function(val) AimbotSettings.WhitelistedGroupCheck = val end })
aimbotChecks:Textbox({
    Flag = "Aimbot_WhitelistGroup",
    Placeholder = TL("ID whitelist-группы", "ID whitelist-групи", "Whitelist Group ID"),
    Default = "",
    Finished = true,
    Callback = function(val) AimbotSettings.WhitelistedGroup = tonumber(val) or 0 end
})
aimbotChecks:Toggle({ Name = TL("Проверка blacklist-группы", "Перевірка blacklist-групи", "Blacklist Group Check"), Flag = "Aimbot_BlacklistGroupCheck", Default = false, Callback = function(val) AimbotSettings.BlacklistedGroupCheck = val end })
aimbotChecks:Textbox({
    Flag = "Aimbot_BlacklistGroup",
    Placeholder = TL("ID blacklist-группы", "ID blacklist-групи", "Blacklist Group ID"),
    Default = "",
    Finished = true,
    Callback = function(val) AimbotSettings.BlacklistedGroup = tonumber(val) or 0 end
})
end

do
aimbotPlayers = pageAimbot:Section({ Name = TL("Yasia Hub | Списки игроков", "Yasia Hub | Списки гравців", "Yasia Hub | Player Lists"), Icon = "users", Side = 1 })
aimbotPlayers:Toggle({ Name = TL("Проверка игнор-листа", "Перевірка ігнор-листа", "Ignored Players Check"), Flag = "Aimbot_IgnoredCheck", Default = false, Callback = function(val) AimbotSettings.IgnoredPlayersCheck = val end })
AimbotRuntime.IgnoredPlayersDropdown = aimbotPlayers:Dropdown({
    Name = TL("Игнорируемые игроки", "Ігноровані гравці", "Ignored Players"),
    Flag = "Aimbot_IgnoredPlayers",
    Items = {},
    Multi = true,
    Search = true,
    Default = {},
    Callback = function(val)
        AimbotSettings.IgnoredPlayers = val or {}
    end
})
aimbotPlayers:Textbox({
    Flag = "Aimbot_AddIgnored",
    Placeholder = TL("Добавь игрока в игнор", "Додай гравця в ігнор", "Add ignored player"),
    Default = "",
    Finished = true,
    Callback = function(val)
        local resolved = resolvePlayerNameInput(val)
        if resolved ~= "" then
            addUniqueValue(AimbotSettings.IgnoredPlayersDropdownValues, resolved)
            addUniqueValue(AimbotSettings.IgnoredPlayers, resolved)
            if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
        end
    end
})
aimbotPlayers:Textbox({
    Flag = "Aimbot_RemoveIgnored",
    Placeholder = TL("Удали игрока из игнора", "Видали гравця з ігнору", "Remove ignored player"),
    Default = "",
    Finished = true,
    Callback = function(val)
        local resolved = resolvePlayerNameInput(val)
        if resolved ~= "" then
            removeValue(AimbotSettings.IgnoredPlayersDropdownValues, resolved)
            removeValue(AimbotSettings.IgnoredPlayers, resolved)
            if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
        end
    end
})
aimbotPlayers:Button({
    Name = TL("Очистить игнор-лист", "Очистити ігнор-лист", "Clear Ignored Players"),
    Callback = function()
        AimbotSettings.IgnoredPlayers = {}
        AimbotSettings.IgnoredPlayersDropdownValues = {}
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end
})
aimbotPlayers:Toggle({ Name = TL("Проверка списка целей", "Перевірка списку цілей", "Target Players Check"), Flag = "Aimbot_TargetCheck", Default = false, Callback = function(val) AimbotSettings.TargetPlayersCheck = val end })
AimbotRuntime.TargetPlayersDropdown = aimbotPlayers:Dropdown({
    Name = TL("Целевые игроки", "Цільові гравці", "Target Players"),
    Flag = "Aimbot_TargetPlayers",
    Items = {},
    Multi = true,
    Search = true,
    Default = {},
    Callback = function(val)
        AimbotSettings.TargetPlayers = val or {}
    end
})
aimbotPlayers:Textbox({
    Flag = "Aimbot_AddTargetPlayer",
    Placeholder = TL("Добавь целевого игрока", "Додай цільового гравця", "Add target player"),
    Default = "",
    Finished = true,
    Callback = function(val)
        local resolved = resolvePlayerNameInput(val)
        if resolved ~= "" then
            addUniqueValue(AimbotSettings.TargetPlayersDropdownValues, resolved)
            addUniqueValue(AimbotSettings.TargetPlayers, resolved)
            if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
        end
    end
})
aimbotPlayers:Textbox({
    Flag = "Aimbot_RemoveTargetPlayer",
    Placeholder = TL("Удали целевого игрока", "Видали цільового гравця", "Remove target player"),
    Default = "",
    Finished = true,
    Callback = function(val)
        local resolved = resolvePlayerNameInput(val)
        if resolved ~= "" then
            removeValue(AimbotSettings.TargetPlayersDropdownValues, resolved)
            removeValue(AimbotSettings.TargetPlayers, resolved)
            if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
        end
    end
})
aimbotPlayers:Button({
    Name = TL("Очистить список целей", "Очистити список цілей", "Clear Target Players"),
    Callback = function()
        AimbotSettings.TargetPlayers = {}
        AimbotSettings.TargetPlayersDropdownValues = {}
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end
})
end

do
aimbotBots = pageAimbot:Section({ Name = TL("Yasia Hub | Боты", "Yasia Hub | Боти", "Yasia Hub | Bots"), Icon = "bot", Side = 2 })
aimbotBots:Toggle({
    Name = TL("SpinBot", "SpinBot", "SpinBot"),
    Flag = "Aimbot_SpinBot",
    Default = false,
    Callback = function(val)
        AimbotSettings.SpinBot = val
        if not val then
            AimbotRuntime.SpinKeybindActive = false
        end
        refreshSpinBindState()
    end
})
AimbotRuntime.SpinKeybind = aimbotBots:Keybind({
    Name = T("spin_key"),
    Flag = "Aimbot_SpinKey",
    Default = Enum.KeyCode.Q,
    Mode = "Hold",
    Callback = function(state)
        AimbotRuntime.SpinKeybindActive = state == true
        refreshSpinBindState()
    end
})
trackSlider(aimbotBots:Slider({
    Name = TL("Скорость спина", "Швидкість спіну", "Spin Velocity"),
    Flag = "Aimbot_SpinVelocity",
    Min = 1, Max = 180, Default = 50, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.SpinBotVelocity = val end
    end
}), 50)
AimbotRuntime.SpinPartDropdown = aimbotBots:Dropdown({
    Name = TL("Часть для спина", "Частина для спіну", "Spin Part"),
    Flag = "Aimbot_SpinPart",
    Items = AimbotSettings.SpinPartValues,
    Default = AimbotSettings.SpinPart,
    Callback = function(val)
        AimbotSettings.SpinPart = val or "HumanoidRootPart"
    end
})
aimbotBots:Toggle({
    Name = TL("Случайная часть для спина", "Випадкова частина для спіну", "Random Spin Part"),
    Flag = "Aimbot_RandomSpinPart",
    Default = false,
    Callback = function(val) AimbotSettings.RandomSpinPart = val end
})
aimbotBots:Textbox({
    Flag = "Aimbot_AddSpinPart",
    Placeholder = TL("Добавь часть для спина", "Додай частину для спіну", "Add spin part"),
    Default = "",
    Finished = true,
    Callback = function(val)
        val = tostring(val or "")
        if val ~= "" then
            addUniqueValue(AimbotSettings.SpinPartValues, val)
            if AimbotRuntime.SpinPartDropdown then
                AimbotRuntime.SpinPartDropdown:Refresh(AimbotSettings.SpinPartValues)
                AimbotRuntime.SpinPartDropdown:Set(val, true)
            end
            AimbotSettings.SpinPart = val
        end
    end
})
aimbotBots:Textbox({
    Flag = "Aimbot_RemoveSpinPart",
    Placeholder = TL("Удали часть для спина", "Видали частину для спіну", "Remove spin part"),
    Default = "",
    Finished = true,
    Callback = function(val)
        val = tostring(val or "")
        if val ~= "" and table.find(AimbotSettings.SpinPartValues, val) then
            removeValue(AimbotSettings.SpinPartValues, val)
            if AimbotSettings.SpinPart == val then
                AimbotSettings.SpinPart = AimbotSettings.SpinPartValues[1] or "HumanoidRootPart"
            end
            if AimbotRuntime.SpinPartDropdown then
                AimbotRuntime.SpinPartDropdown:Refresh(AimbotSettings.SpinPartValues)
                if table.find(AimbotSettings.SpinPartValues, AimbotSettings.SpinPart) then
                    AimbotRuntime.SpinPartDropdown:Set(AimbotSettings.SpinPart, true)
                end
            end
        end
    end
})
aimbotBots:Toggle({
    Name = TL("TriggerBot", "TriggerBot", "TriggerBot"),
    Flag = "Aimbot_TriggerBot",
    Default = false,
    Callback = function(val)
        AimbotSettings.TriggerBot = val
        if not val then
            AimbotRuntime.TriggerKeybindActive = false
        end
        refreshTriggerBindState()
    end
})
AimbotRuntime.TriggerKeybind = aimbotBots:Keybind({
    Name = T("trigger_key"),
    Flag = "Aimbot_TriggerKey",
    Default = Enum.KeyCode.E,
    Mode = "Hold",
    Callback = function(state)
        AimbotRuntime.TriggerKeybindActive = state == true
        refreshTriggerBindState()
    end
})
aimbotBots:Toggle({
    Name = TL("Умный TriggerBot", "Розумний TriggerBot", "Smart TriggerBot"),
    Flag = "Aimbot_SmartTriggerBot",
    Default = false,
    Callback = function(val) AimbotSettings.SmartTriggerBot = val end
})
trackSlider(aimbotBots:Slider({
    Name = TL("Шанс TriggerBot", "Шанс TriggerBot", "Trigger Chance"),
    Flag = "Aimbot_TriggerChance",
    Min = 1, Max = 100, Default = 100, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.TriggerBotChance = val end
    end
}), 100)
end

do
aimbotVisuals = pageAimbot:Section({ Name = T("oa_fov_vis"), Icon = "circle", Side = 2 })
aimbotVisuals:Toggle({
    Name = TL("Показывать круг FoV", "Показувати коло FoV", "Show FoV Circle"),
    Flag = "Aimbot_ShowFoV",
    Default = false,
    Callback = function(val) AimbotSettings.ShowFoV = val end
})
trackSlider(aimbotVisuals:Slider({
    Name = TL("Толщина FoV", "Товщина FoV", "FoV Thickness"),
    Flag = "Aimbot_FovThickness",
    Min = 1, Max = 10, Default = 2, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.FoVThickness = val end
    end
}), 2)
trackSlider(aimbotVisuals:Slider({
    Name = TL("Прозрачность FoV", "Прозорість FoV", "FoV Opacity"),
    Flag = "Aimbot_FovOpacity",
    Min = 0.1, Max = 1, Default = 0.8, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then AimbotSettings.FoVOpacity = val end
    end
}), 0.8)
aimbotVisuals:Toggle({
    Name = TL("Заполненный FoV", "Заповнений FoV", "FoV Filled"),
    Flag = "Aimbot_FovFilled",
    Default = false,
    Callback = function(val) AimbotSettings.FoVFilled = val end
})
aimbotVisuals:Toggle({
    Name = TL("Радужный FoV", "Райдужний FoV", "Rainbow FoV"),
    Flag = "Aimbot_RainbowFoV",
    Default = false,
    Callback = function(val) AimbotSettings.RainbowFoV = val end
})
aimbotVisuals:Label(TL("Цвет FoV", "Колір FoV", "FoV Color")):Colorpicker({
    Flag = "Aimbot_FovColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(col) AimbotSettings.FoVColour = col end
})
aimbotVisuals:Button({
    Name = T("oa_reset"),
    Callback = function()
        AimbotRuntime.ManualActivation = false
        AimbotRuntime.KeybindActive = false
        AimbotSettings.BindActive = false
        AimbotRuntime.CurrentTargetData = nil
        refreshAimbotBindState()
        updateAimbotStatusLabel()
    end
})
aimbotVisuals:Label(TL(
    "ESP из этого аимбота не дублируется: в хабе уже есть отдельная рабочая вкладка ESP.",
    "ESP з цього аімбота не дублюється: у хабі вже є окрема робоча вкладка ESP.",
    "ESP from this aimbot is not duplicated because the hub already has a separate working ESP tab."
))
end

do
miscWorld = pageMisc:Section({ Name = TL("Yasia Hub | Мир / Камера", "Yasia Hub | Світ / Камера", "Yasia Hub | World / Camera"), Icon = "sun", Side = 2 })
trackSlider(miscWorld:Slider({
    Name = "Camera FOV",
    Flag = "Misc_CameraFOV",
    Min = 40, Max = 120, Default = 70, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then setCameraFOV(val) end
    end
}), 70)
trackSlider(miscWorld:Slider({
    Name = "Brightness",
    Flag = "Misc_Brightness",
    Min = 0, Max = 10, Default = 2.5, Decimals = 0.1,
    Callback = function(val)
        if isFiniteNumber(val) then setBrightnessValue(val) end
    end
}), 2.5)
trackSlider(miscWorld:Slider({
    Name = "Clock Time",
    Flag = "Misc_ClockTime",
    Min = 0, Max = 24, Default = 14, Decimals = 0.5,
    Callback = function(val)
        if isFiniteNumber(val) then setClockTime(val) end
    end
}), 14)
miscWorld:Toggle({
    Name = "Unlock Zoom",
    Flag = "Misc_UnlockZoom",
    Default = false,
    Callback = function(val)
        setUnlockZoom(val)
    end
})
miscWorld:Toggle({
    Name = TL("Убрать текстуры", "Прибрати текстури", "Remove Textures"),
    Flag = "Misc_NoTextures",
    Default = false,
    Callback = function(val)
        setNoTextures(val)
    end
})
miscWorld:Toggle({
    Name = TL("Убрать частицы", "Прибрати частинки", "Remove Particles"),
    Flag = "Misc_NoParticles",
    Default = false,
    Callback = function(val)
        setNoParticles(val)
    end
})
miscWorld:Toggle({
    Name = "Xray",
    Flag = "Misc_Xray",
    Default = false,
    Callback = function(val)
        setWorldXray(val)
    end
})
trackSlider(miscWorld:Slider({
    Name = "Xray Transparency",
    Flag = "Misc_XrayTransparency",
    Min = 0.1, Max = 0.95, Default = 0.7, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then
            MiscSettings.XrayTransparency = val
            if MiscSettings.Xray then
                setWorldXray(false)
                setWorldXray(true)
            end
        end
    end
}), 0.7)
miscWorld:Toggle({
    Name = "Hide Other GUIs",
    Flag = "Misc_HideOtherGuis",
    Default = false,
    Callback = function(val)
        setHideOtherGuis(val)
    end
})
miscWorld:Button({
    Name = "Low Graphics",
    Callback = function()
        applyLowGraphics()
    end
})
miscWorld:Button({
    Name = "Restore Graphics",
    Callback = function()
        restoreGraphics()
    end
})
end

do
funAdvanced = pageFun:Section({ Name = "Yasia Hub | Orbit / Bounce", Icon = "rotate-cw", Side = 2 })
RuntimeRefs.OrbitDropdown = funAdvanced:Dropdown({
    Name = "Orbit target",
    Flag = "Fun_OrbitTarget",
    Items = {},
    Default = "",
    Callback = function(val)
        FunSettings.OrbitTarget = val or ""
    end
})
funAdvanced:Toggle({
    Name = "Orbit Player",
    Flag = "Fun_Orbit",
    Default = false,
    Callback = function(val)
        FunSettings.Orbit = val
    end
})
trackSlider(funAdvanced:Slider({
    Name = "Orbit Radius",
    Flag = "Fun_OrbitRadius",
    Min = 3, Max = 30, Default = 8, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then FunSettings.OrbitRadius = val end
    end
}), 8)
trackSlider(funAdvanced:Slider({
    Name = "Orbit Speed",
    Flag = "Fun_OrbitSpeed",
    Min = 1, Max = 10, Default = 2, Decimals = 0.1,
    Callback = function(val)
        if isFiniteNumber(val) then FunSettings.OrbitSpeed = val end
    end
}), 2)
funAdvanced:Toggle({
    Name = "Bounce",
    Flag = "Fun_Bounce",
    Default = false,
    Callback = function(val)
        FunSettings.Bounce = val
    end
})
trackSlider(funAdvanced:Slider({
    Name = "Bounce Power",
    Flag = "Fun_BouncePower",
    Min = 25, Max = 150, Default = 60, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then FunSettings.BouncePower = val end
    end
}), 60)
trackSlider(funAdvanced:Slider({
    Name = "Spin Speed",
    Flag = "Fun_SpinSpeed",
    Min = 5, Max = 120, Default = 32, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then
            FunSettings.SpinSpeed = val
        end
    end
}), 32)
end

do
utilPositions = pageUtility:Section({ Name = TL("Yasia Hub | Позиции / Tools", "Yasia Hub | Позиції / Tools", "Yasia Hub | Positions / Tools"), Icon = "save", Side = 2 })
utilPositions:Button({
    Name = TL("Сохранить слот 1", "Зберегти слот 1", "Save Slot 1"),
    Callback = function() savePositionSlot(1) end
})
utilPositions:Button({
    Name = TL("ТП к слоту 1", "ТП до слота 1", "TP To Slot 1"),
    Callback = function() loadPositionSlot(1) end
})
utilPositions:Button({
    Name = TL("Сохранить слот 2", "Зберегти слот 2", "Save Slot 2"),
    Callback = function() savePositionSlot(2) end
})
utilPositions:Button({
    Name = TL("ТП к слоту 2", "ТП до слота 2", "TP To Slot 2"),
    Callback = function() loadPositionSlot(2) end
})
utilPositions:Button({
    Name = TL("Сохранить слот 3", "Зберегти слот 3", "Save Slot 3"),
    Callback = function() savePositionSlot(3) end
})
utilPositions:Button({
    Name = TL("ТП к слоту 3", "ТП до слота 3", "TP To Slot 3"),
    Callback = function() loadPositionSlot(3) end
})
utilPositions:Button({
    Name = TL("Вывести Position", "Вивести Position", "Print Position"),
    Callback = function()
        local root = getRootPart()
        if root then print("[" .. HUB_TAG .. "] Position:", root.Position) end
    end
})
utilPositions:Button({
    Name = TL("Вывести CFrame", "Вивести CFrame", "Print CFrame"),
    Callback = function()
        local root = getRootPart()
        if root then print("[" .. HUB_TAG .. "] CFrame:", tostring(root.CFrame)) end
    end
})
utilPositions:Button({
    Name = "Unequip Tools",
    Callback = function()
        unequipTools()
    end
})
for i = 4, 8 do
    utilPositions:Button({
        Name = TL("Сохранить слот ", "Зберегти слот ", "Save Slot ") .. i,
        Callback = function()
            savePositionSlot(i)
        end
    })
    utilPositions:Button({
        Name = TL("ТП к слоту ", "ТП до слота ", "TP To Slot ") .. i,
        Callback = function()
            loadPositionSlot(i)
        end
    })
end
end

do
utilityScan = pageUtility:Section({ Name = "Yasia Hub | World Scan", Icon = "search", Side = 1 })
RuntimeRefs.ScanInfoLabel = utilityScan:Label("P:0 C:0 T:0 S:0 Sp:0")
utilityScan:Button({
    Name = TL("Сканировать nearby objects", "Сканувати nearby objects", "Scan Nearby Objects"),
    Callback = function()
        local c = scanNearbyCounts(FarmSettings.AutoRadius)
        print("[" .. HUB_TAG .. "][Scan]", c.prompts, c.clicks, c.tools, c.seats, c.spawns)
        if RuntimeRefs.ScanInfoLabel and RuntimeRefs.ScanInfoLabel.SetText then
            RuntimeRefs.ScanInfoLabel:SetText(string.format("P:%d C:%d T:%d S:%d Sp:%d", c.prompts, c.clicks, c.tools, c.seats, c.spawns))
        end
    end
})
utilityScan:Button({
    Name = "Use nearest Prompt",
    Callback = function()
        local prompt = getNearestPrompt(FarmSettings.AutoRadius)
        if prompt then usePrompt(prompt) end
    end
})
utilityScan:Button({
    Name = "Use nearest Click",
    Callback = function()
        local click = getNearestClickDetector(FarmSettings.AutoRadius)
        if click then useClickDetector(click) end
    end
})
utilityScan:Button({
    Name = "Pickup nearest Tool",
    Callback = function()
        local tool = getNearestToolInWorld(FarmSettings.AutoRadius)
        local handle = tool and tool:FindFirstChild("Handle")
        if handle then touchPart(handle) end
    end
})
end

do
farmAutomation = pageFarm:Section({ Name = "Yasia Hub | AVTO-VZAIMODEYSTVIE", Icon = "cpu", Side = 2 })
farmAutomation:Toggle({
    Name = "Auto ProximityPrompt",
    Flag = "Farm_AutoPrompt",
    Default = false,
    Callback = function(val) FarmSettings.PromptEnabled = val end
})
farmAutomation:Textbox({
    Flag = "Farm_PromptFilter",
    Placeholder = "FILTR prompt name",
    Default = "",
    Finished = true,
    Callback = function(val) FarmSettings.PromptFilter = tostring(val or "") end
})
farmAutomation:Toggle({
    Name = "Auto ClickDetector",
    Flag = "Farm_AutoClick",
    Default = false,
    Callback = function(val) FarmSettings.ClickEnabled = val end
})
farmAutomation:Textbox({
    Flag = "Farm_ClickFilter",
    Placeholder = "FILTR click name",
    Default = "",
    Finished = true,
    Callback = function(val) FarmSettings.ClickFilter = tostring(val or "") end
})
farmAutomation:Toggle({
    Name = "Auto Touch Parts",
    Flag = "Farm_AutoTouch",
    Default = false,
    Callback = function(val) FarmSettings.TouchEnabled = val end
})
farmAutomation:Textbox({
    Flag = "Farm_TouchFilter",
    Placeholder = "FILTR part name",
    Default = "",
    Finished = true,
    Callback = function(val) FarmSettings.TouchFilter = tostring(val or "") end
})
farmAutomation:Toggle({
    Name = "Auto Collect Tools",
    Flag = "Farm_AutoTools",
    Default = false,
    Callback = function(val) FarmSettings.AutoCollectTools = val end
})
farmAutomation:Toggle({
    Name = TL("ТП к target перед действием", "ТП до target перед дією", "TP To Target Before Action"),
    Flag = "Farm_TeleportToTarget",
    Default = false,
    Callback = function(val) FarmSettings.TeleportToTargets = val end
})
trackSlider(farmAutomation:Slider({
    Name = TL("Интервал фарма", "Інтервал фарму", "Farm Interval"),
    Flag = "Farm_Interval",
    Min = 0.05, Max = 2, Default = 0.35, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then FarmSettings.Interval = val end
    end
}), 0.35)
trackSlider(farmAutomation:Slider({
    Name = TL("Действий за цикл", "Дій за цикл", "Actions Per Cycle"),
    Flag = "Farm_MaxPerCycle",
    Min = 1, Max = 25, Default = 8, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then FarmSettings.MaxPerCycle = val end
    end
}), 8)
farmAutomation:Button({
    Name = TL("Запустить 1 цикл фарма", "Запустити 1 цикл фарму", "Run 1 Farm Cycle"),
    Callback = function()
        runFarmCycle()
    end
})
farmAutomation:Button({
    Name = "Use nearest Prompt now",
    Callback = function()
        local prompt = getNearestPrompt(FarmSettings.AutoRadius)
        if prompt then usePrompt(prompt) end
    end
})
end

do
tpAdvanced = pageTeleports:Section({ Name = TL("Yasia Hub | Расширенный ТП", "Yasia Hub | Розширений ТП", "Yasia Hub | Advanced TP"), Icon = "navigation", Side = 2 })
tpAdvanced:Textbox({
    Flag = "TP_SearchName",
    Placeholder = TL("Имя или часть ника", "Ім'я або частина ніка", "Name Or Partial Nick"),
    Default = "",
    Finished = true,
    Callback = function(val)
        TeleportSettings.SearchName = tostring(val or "")
    end
})
tpAdvanced:Button({
    Name = TL("ТП по поиску", "ТП за пошуком", "TP By Search"),
    Callback = function()
        local plr = findPlayer(TeleportSettings.SearchName)
        if plr then teleportToPlayer(plr) end
    end
})
tpAdvanced:Button({
    Name = TL("ТП к случайному игроку", "ТП до випадкового гравця", "TP To Random Player"),
    Callback = function()
        local candidates = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then table.insert(candidates, plr) end
        end
        if #candidates > 0 then
            teleportToPlayer(candidates[math.random(1, #candidates)])
        end
    end
})
tpAdvanced:Button({
    Name = TL("Вернуться назад", "Повернутися назад", "Go Back"),
    Callback = function()
        if TeleportSettings.LastCF then
            teleportLocalTo(TeleportSettings.LastCF)
        end
    end
})
trackSlider(tpAdvanced:Slider({
    Name = TL("YOffset к игроку", "YOffset до гравця", "YOffset To Player"),
    Flag = "TP_YOffset",
    Min = 0, Max = 20, Default = 3, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then TeleportSettings.PlayerYOffset = val end
    end
}), 3)
tpAdvanced:Button({
    Name = TL("ТП вверх +50", "ТП вгору +50", "TP Up +50"),
    Callback = function()
        local root = getRootPart()
        if root then teleportLocalTo(root.CFrame + Vector3.new(0, 50, 0)) end
    end
})
tpAdvanced:Button({
    Name = TL("ТП вниз -10", "ТП вниз -10", "TP Down -10"),
    Callback = function()
        local root = getRootPart()
        if root then teleportLocalTo(root.CFrame + Vector3.new(0, -10, 0)) end
    end
})
tpAdvanced:Button({
    Name = TL("ТП к nearest Prompt", "ТП до nearest Prompt", "TP To Nearest Prompt"),
    Callback = function()
        teleportToNearestObject("prompt")
    end
})
tpAdvanced:Button({
    Name = TL("ТП к nearest Click", "ТП до nearest Click", "TP To Nearest Click"),
    Callback = function()
        teleportToNearestObject("click")
    end
})
tpAdvanced:Button({
    Name = TL("ТП к nearest Tool", "ТП до nearest Tool", "TP To Nearest Tool"),
    Callback = function()
        teleportToNearestObject("tool")
    end
})
tpAdvanced:Button({
    Name = TL("ТП к nearest Seat", "ТП до nearest Seat", "TP To Nearest Seat"),
    Callback = function()
        teleportToNearestObject("seat")
    end
})
tpAdvanced:Button({
    Name = TL("ТП к nearest Spawn", "ТП до nearest Spawn", "TP To Nearest Spawn"),
    Callback = function()
        teleportToNearestObject("spawn")
    end
})
RuntimeRefs.TeleportInfoLabel = tpAdvanced:Label("Nearest TP helpers ready")
end

do
adminFollow = pageAdmin:Section({ Name = "Yasia Hub | Follow / Target", Icon = "user-check", Side = 2 })
RuntimeRefs.AdminFollowDropdown = adminFollow:Dropdown({
    Name = "Follow target",
    Flag = "Admin_FollowTarget",
    Items = {},
    Default = "",
    Callback = function(val)
        AdminSettings.FollowTarget = val or ""
    end
})
adminFollow:Toggle({
    Name = "Follow Player",
    Flag = "Admin_FollowEnabled",
    Default = false,
    Callback = function(val)
        AdminSettings.FollowEnabled = val
    end
})
trackSlider(adminFollow:Slider({
    Name = "Follow Distance",
    Flag = "Admin_FollowDistance",
    Min = -15, Max = 15, Default = 4, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then AdminSettings.FollowDistance = val end
    end
}), 4)
adminFollow:Toggle({
    Name = "Highlight Target",
    Flag = "Admin_HighlightTarget",
    Default = false,
    Callback = function(val)
        AdminSettings.HighlightTarget = val
        if not val and AdminSettings.HighlightObject then
            pcall(function() AdminSettings.HighlightObject:Destroy() end)
            AdminSettings.HighlightObject = nil
        end
    end
})
RuntimeRefs.PlayerInfoLabel = adminFollow:Label(TL("Игрок не выбран", "Гравця не вибрано", "No player selected"))
adminFollow:Button({
    Name = TL("ТП за target", "ТП за target", "TP Behind Target"),
    Callback = function()
        local name = AdminSettings.FollowTarget ~= "" and AdminSettings.FollowTarget or AdminSettings.SpectateName
        local plr = Players:FindFirstChild(name) or findPlayer(name)
        local targetRoot = plr and getRootPart(plr.Character)
        if targetRoot then
            teleportLocalTo(targetRoot.CFrame * CFrame.new(0, 0, 3))
        end
    end
})
end

do
vehicleUtility = pageVehicles:Section({ Name = "Yasia Hub | Vehicle Utility", Icon = "truck", Side = 1 })
vehicleUtility:Button({
    Name = TL("Сесть в ближайший Seat", "Сісти в найближчий Seat", "Sit In Nearest Seat"),
    Callback = function()
        seatInNearestSeat()
    end
})
vehicleUtility:Toggle({
    Name = "Vehicle Noclip",
    Flag = "Vehicle_Noclip",
    Default = false,
    Callback = function(val)
        VehicleSystem.NoclipEnabled = val
        if not val then
            setVehicleModelCollision(nil, true)
        end
    end
})
vehicleUtility:Toggle({
    Name = "Shift Boost",
    Flag = "Vehicle_ShiftBoost",
    Default = false,
    Callback = function(val)
        VehicleSystem.ShiftBoost = val
    end
})
trackSlider(vehicleUtility:Slider({
    Name = "Boost Multiplier",
    Flag = "Vehicle_BoostMultiplier",
    Min = 1, Max = 4, Default = 1.75, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then VehicleSystem.BoostMultiplier = val end
    end
}), 1.75)
vehicleUtility:Button({
    Name = TL("Выйти из seat", "Вийти з seat", "Exit Seat"),
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.Sit = false
            hum.Jump = true
        end
    end
})
vehicleUtility:Button({
    Name = "Flip Vehicle Upright",
    Callback = function()
        flipSeatedVehicleUpright()
    end
})
vehicleUtility:Button({
    Name = TL("ТП машины к мышке", "ТП машини до мишки", "TP Vehicle To Mouse"),
    Callback = function()
        local hit = Mouse and Mouse.Hit
        if hit then
            teleportSeatedVehicleTo(CFrame.new(hit.Position + Vector3.new(0, 5, 0)))
        end
    end
})
vehicleUtility:Button({
    Name = "Vehicle Boost Once",
    Callback = function()
        local _, pp = getSeatedVehiclePrimaryPart()
        if pp then
            pp.AssemblyLinearVelocity = pp.CFrame.LookVector * (VehicleSystem.SpeedHackMaxSpeed * VehicleSystem.BoostMultiplier)
        end
    end
})
RuntimeRefs.VehicleInfoLabel = vehicleUtility:Label(TL("Скорость", "Швидкість", "Speed") .. ": 0 | Seat: false")
end

do
touchFlingConfig = pageTouchFling:Section({ Name = "Yasia Hub | Touch Fling Config", Icon = "sliders", Side = 2 })
trackSlider(touchFlingConfig:Slider({
    Name = "Velocity Mult",
    Flag = "TouchFling_Velocity",
    Min = 1000, Max = 30000, Default = 10000, Decimals = 100,
    Callback = function(val)
        if isFiniteNumber(val) then TouchFlingSettings.VelocityMultiplier = val end
    end
}), 10000)
trackSlider(touchFlingConfig:Slider({
    Name = "Upward Boost",
    Flag = "TouchFling_Upward",
    Min = 1000, Max = 30000, Default = 10000, Decimals = 100,
    Callback = function(val)
        if isFiniteNumber(val) then TouchFlingSettings.UpwardBoost = val end
    end
}), 10000)
trackSlider(touchFlingConfig:Slider({
    Name = "Restore Y",
    Flag = "TouchFling_RestoreY",
    Min = 0, Max = 2, Default = 0.1, Decimals = 0.05,
    Callback = function(val)
        if isFiniteNumber(val) then TouchFlingSettings.RestoreYOffset = val end
    end
}), 0.1)
end

do
antiFlingConfig = pageAntiFling:Section({ Name = "Yasia Hub | Anti Fling Config", Icon = "sliders", Side = 2 })
antiFlingConfig:Toggle({
    Name = "Disable Rotation",
    Flag = "AF_DisableRotation",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.disable_rotation = val end
})
antiFlingConfig:Toggle({
    Name = "Limit Velocity",
    Flag = "AF_LimitVelocity",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.limit_velocity = val end
})
trackSlider(antiFlingConfig:Slider({
    Name = "Velocity Sensitivity",
    Flag = "AF_VelSensitivity",
    Min = 50, Max = 500, Default = 150, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.limit_velocity_sensitivity = val end
    end
}), 150)
trackSlider(antiFlingConfig:Slider({
    Name = "Velocity Slow",
    Flag = "AF_VelSlow",
    Min = 0, Max = 50, Default = 0, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.limit_velocity_slow = val end
    end
}), 0)
antiFlingConfig:Toggle({
    Name = "Anti Ragdoll",
    Flag = "AF_AntiRagdoll",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.anti_ragdoll = val end
})
antiFlingConfig:Toggle({
    Name = "Anti Seat",
    Flag = "AF_AntiSeat",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.anti_seat = val end
})
antiFlingConfig:Toggle({
    Name = "Block Bad States",
    Flag = "AF_BlockStates",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.block_states = val end
})
antiFlingConfig:Toggle({
    Name = "Zero All Parts",
    Flag = "AF_ZeroAllParts",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.zero_all_parts = val end
})
antiFlingConfig:Toggle({
    Name = "Auto Jump Recover",
    Flag = "AF_AutoJumpRecover",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.auto_jump_recover = val end
})
antiFlingConfig:Toggle({
    Name = "Anchor",
    Flag = "AF_Anchor",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.anchor = val end
})
antiFlingConfig:Toggle({
    Name = "Smart Anchor",
    Flag = "AF_SmartAnchor",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.smart_anchor = val end
})
trackSlider(antiFlingConfig:Slider({
    Name = "Anchor Dist",
    Flag = "AF_AnchorDist",
    Min = 5, Max = 100, Default = 30, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.anchor_dist = val end
    end
}), 30)
antiFlingConfig:Toggle({
    Name = "Limit Angular Velocity",
    Flag = "AF_LimitAngular",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.limit_angular_velocity = val end
})
trackSlider(antiFlingConfig:Slider({
    Name = "Angular Sensitivity",
    Flag = "AF_AngularSensitivity",
    Min = 10, Max = 400, Default = 80, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.angular_velocity_sensitivity = val end
    end
}), 80)
antiFlingConfig:Toggle({
    Name = "Teleport Back",
    Flag = "AF_Teleport",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.teleport = val end
})
antiFlingConfig:Toggle({
    Name = "Smart Teleport",
    Flag = "AF_SmartTeleport",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.smart_teleport = val end
})
trackSlider(antiFlingConfig:Slider({
    Name = "Teleport Dist",
    Flag = "AF_TeleportDist",
    Min = 5, Max = 100, Default = 30, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.teleport_dist = val end
    end
}), 30)
trackSlider(antiFlingConfig:Slider({
    Name = "Safe Velocity",
    Flag = "AF_SafeVelocity",
    Min = 20, Max = 200, Default = 70, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.safe_velocity_threshold = val end
    end
}), 70)
antiFlingConfig:Toggle({
    Name = "Save Safe Only On Ground",
    Flag = "AF_SafeGroundOnly",
    Default = true,
    Callback = function(val) _G.AntiFlingConfig.safe_on_ground_only = val end
})
trackSlider(antiFlingConfig:Slider({
    Name = "Max Rescues / sec",
    Flag = "AF_MaxRescues",
    Min = 1, Max = 12, Default = 4, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then _G.AntiFlingConfig.max_rescue_per_second = val end
    end
}), 4)
antiFlingConfig:Button({
    Name = "Save Current Safe Position",
    Callback = function()
        local root = getRootPart()
        if root then
            AntiFlingState.LastSafeCF = root.CFrame
        end
    end
})
antiFlingConfig:Button({
    Name = "Force Anti Fling Rescue",
    Callback = function()
        local char = getCharacter()
        local hum = getHumanoid(char)
        local root = getRootPart(char)
        antiFlingRecover(char, hum, root, "manual")
    end
})
antiFlingConfig:Button({
    Name = "Zero Momentum Now",
    Callback = function()
        zeroCharacterMomentum()
    end
})
end

do
cloudLeft = pageCloudScripts:Section({ Name = "Yasia Hub | ScriptBlox Fetch", Icon = "cloud", Side = 1 })
cloudRight = pageCloudScripts:Section({ Name = TL("Yasia Hub | Результаты", "Yasia Hub | Результати", "Yasia Hub | Results"), Icon = "file-text", Side = 2 })

RuntimeRefs.CloudGameLabel = cloudLeft:Label(TL("Игра", "Гра", "Game") .. ": " .. tostring(game.PlaceId) .. " | PlaceId: " .. tostring(game.PlaceId))
RuntimeRefs.CloudStatusLabel = cloudLeft:Label("Cloud Scripts: ready")

cloudLeft:Label(TL(
    "Поиск идёт через ScriptBlox fetch endpoint по текущему PlaceId. Во вкладке только метаданные и копирование info/slug, без автозапуска чужих скриптов.",
    "Пошук іде через ScriptBlox fetch endpoint по поточному PlaceId. У вкладці лише метадані та копіювання info/slug, без автозапуску чужих скриптів.",
    "This tab uses the ScriptBlox fetch endpoint for the current PlaceId. It only shows metadata and info/slug copying, with no auto-execution of external scripts."
))

CloudScriptsRuntime.PageSlider = trackSlider(cloudLeft:Slider({
    Name = "Page",
    Flag = "CloudScripts_Page",
    Min = 1, Max = 50, Default = CloudScriptsSettings.Page, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then
            CloudScriptsSettings.Page = math.max(1, math.floor(val))
        end
    end
}), CloudScriptsSettings.Page)

CloudScriptsRuntime.MaxSlider = trackSlider(cloudLeft:Slider({
    Name = "Max Results",
    Flag = "CloudScripts_Max",
    Min = 1, Max = 20, Default = CloudScriptsSettings.Max, Decimals = 1,
    Callback = function(val)
        if isFiniteNumber(val) then
            CloudScriptsSettings.Max = math.clamp(math.floor(val), 1, 20)
        end
    end
}), CloudScriptsSettings.Max)

cloudLeft:Dropdown({
    Name = "Sort By",
    Flag = "CloudScripts_SortBy",
    Items = { "updatedAt", "createdAt", "views", "likeCount", "dislikeCount" },
    Default = CloudScriptsSettings.SortBy,
    Callback = function(val)
        CloudScriptsSettings.SortBy = val or "updatedAt"
    end
})

cloudLeft:Dropdown({
    Name = "Order",
    Flag = "CloudScripts_Order",
    Items = { "desc", "asc" },
    Default = CloudScriptsSettings.Order,
    Callback = function(val)
        CloudScriptsSettings.Order = val or "desc"
    end
})

cloudLeft:Toggle({
    Name = "Free Only",
    Flag = "CloudScripts_FreeOnly",
    Default = false,
    Callback = function(val) CloudScriptsSettings.FreeOnly = val end
})
cloudLeft:Toggle({
    Name = "Verified Only",
    Flag = "CloudScripts_VerifiedOnly",
    Default = false,
    Callback = function(val) CloudScriptsSettings.VerifiedOnly = val end
})
cloudLeft:Toggle({
    Name = "Without Key",
    Flag = "CloudScripts_NoKey",
    Default = false,
    Callback = function(val) CloudScriptsSettings.NoKey = val end
})
cloudLeft:Toggle({
    Name = "Universal Only",
    Flag = "CloudScripts_UniversalOnly",
    Default = false,
    Callback = function(val) CloudScriptsSettings.UniversalOnly = val end
})
cloudLeft:Toggle({
    Name = "Hide Patched",
    Flag = "CloudScripts_HidePatched",
    Default = false,
    Callback = function(val) CloudScriptsSettings.HidePatched = val end
})

cloudLeft:Button({
    Name = "Fetch Current Game",
    Callback = function()
        task.spawn(fetchCloudScripts)
    end
})
cloudLeft:Button({
    Name = "Previous Page",
    Callback = function()
        CloudScriptsSettings.Page = math.max(1, CloudScriptsSettings.Page - 1)
        if CloudScriptsRuntime.PageSlider and CloudScriptsRuntime.PageSlider.Set then
            CloudScriptsRuntime.PageSlider:Set(CloudScriptsSettings.Page, true)
        end
        task.spawn(fetchCloudScripts)
    end
})
cloudLeft:Button({
    Name = "Next Page",
    Callback = function()
        local maxPage = math.max(1, CloudScriptsSettings.TotalPages or 1)
        CloudScriptsSettings.Page = math.min(maxPage, CloudScriptsSettings.Page + 1)
        if CloudScriptsRuntime.PageSlider and CloudScriptsRuntime.PageSlider.Set then
            CloudScriptsRuntime.PageSlider:Set(CloudScriptsSettings.Page, true)
        end
        task.spawn(fetchCloudScripts)
    end
})
cloudLeft:Button({
    Name = "Copy Fetch URL",
    Callback = function()
        local url = buildCloudScriptsFetchUrl()
        local copied = tryCopyText(url)
        cloudScriptsNotify("Cloud Scripts", copied and "Fetch URL copied" or url, copied and 2 or 5)
    end
})

CloudScriptsRuntime.ResultsSection = cloudRight
    cloudRight:Label(TL(
        "Карточки ниже подтягиваются через ScriptBlox fetch endpoint.",
        "Картки нижче підтягуються через ScriptBlox fetch endpoint.",
        "The cards below are loaded through the ScriptBlox fetch endpoint."
    ))
renderCloudScripts()
resolveCloudGameName()
end

do
galleryLeft = pageGallery:Section({ Name = "Yasia Hub | Gallery", Icon = "image", Side = 1 })
galleryRight = pageGallery:Section({ Name = "Yasia Hub | Photos", Icon = "camera", Side = 2 })
galleryFresh = pageGallery:Section({ Name = "Yasia Hub | Fresh Pack", Icon = "sparkles", Side = 1 })

    galleryLeft:Label(TL(
        "Отдельная фотогалерея Yasia. Нажми на изображение или кнопку, чтобы скопировать asset id.",
        "Окрема фотогалерея Yasia. Натисни на зображення або кнопку, щоб скопіювати asset id.",
        "A dedicated Yasia photo gallery. Click an image or button to copy the asset id."
    ))
    galleryRight:Label(TL(
        "Все изображения встроены прямо в UI без дополнительных команд и лишних переходов.",
        "Усі зображення вбудовані прямо в UI без додаткових команд і зайвих переходів.",
        "All images are embedded directly in the UI with no extra commands and no extra tab switching."
    ))
    galleryFresh:Label(TL(
        "Свежий пользовательский пак из новых asset id.",
        "Свіжий користувацький пак із нових asset id.",
        "Latest custom pack added from your new asset ids."
    ))

populateGallerySection(galleryLeft, {
    GallerySettings.Images[1],
    GallerySettings.Images[2],
    GallerySettings.Images[3],
    GallerySettings.Images[4],
    GallerySettings.Images[5],
    GallerySettings.Images[6],
    GallerySettings.Images[7],
    GallerySettings.Images[8],
})

populateGallerySection(galleryRight, {
    GallerySettings.Images[9],
    GallerySettings.Images[10],
    GallerySettings.Images[11],
    GallerySettings.Images[12],
    GallerySettings.Images[13],
    GallerySettings.Images[14],
    GallerySettings.Images[15],
    GallerySettings.Images[16],
})

populateGallerySection(galleryFresh, {
    GallerySettings.Images[17],
    GallerySettings.Images[18],
    GallerySettings.Images[19],
    GallerySettings.Images[20],
    GallerySettings.Images[21],
    GallerySettings.Images[22],
    GallerySettings.Images[23],
})
end

do
languageLabelByCode = {
    ru = "Russian",
    uk = "Ukrainian",
    en = "English",
}
languageCodeByLabel = {
    ["Russian"] = "ru",
    ["Ukrainian"] = "uk",
    ["English"] = "en",
}

settingsLeft = pageSettings:Section({ Name = T("settings"), Icon = "globe", Side = 1 })
settingsRight = pageSettings:Section({ Name = T("settings_info"), Icon = "info", Side = 2 })

settingsLeft:Dropdown({
    Name = T("lang_sel"),
    Flag = ENV_KEYS.Language,
    Items = { "Russian", "Ukrainian", "English" },
    Default = languageLabelByCode[Translations.Current] or "Russian",
    Callback = function(val)
        local nextLanguage = languageCodeByLabel[val] or "ru"
        if Translations.Current == nextLanguage then
            return
        end
        Translations.Current = nextLanguage
        setStoredValue(ENV_KEYS.Language, ENV_KEYS.LegacyLanguage, nextLanguage)
        updateAimbotStatusLabel()
        updateTpBindStatusLabel()
        updateChatStatusLabel()
        pcall(function()
            if Library and Library.Notification then
                Library:Notification({
                    Title = HUB_BRAND,
                    Description = T("msg_lang_changed") .. " " .. T("reload_hint"),
                    Duration = 4
                })
            end
        end)
    end
})

settingsLeft:Dropdown({
    Name = T("theme_sel"),
    Flag = ENV_KEYS.Theme,
    Items = { "Default", "Aqua", "Blood", "Emerald", "Gold", "Midnight", "Sunset", "Ice", "Mint", "Rose", "Steel" },
    Default = YasiaHubSettings.Theme,
    Callback = function(val)
        applyAccentTheme(val)
        pcall(function()
            if Library and Library.Notification then
                Library:Notification({
                    Title = HUB_BRAND,
                    Description = T("msg_theme_changed") .. ": " .. tostring(YasiaHubSettings.Theme),
                    Duration = 3
                })
            end
        end)
    end
})

settingsLeft:Label(T("reload_hint"))
settingsRight:Label(T("settings_info_text"))
RuntimeRefs.ThemePreviewLabel = settingsRight:Label("Theme preview: loading...")
settingsRight:Button({
    Name = T("settings_show_notice"),
    Callback = function()
        pcall(function()
            if Library and Library.Notification then
                Library:Notification({
                    Title = T("title"),
                    Description = T("msg_loaded") .. " " .. LP.Name,
                    Duration = 4
                })
            end
        end)
    end
})
settingsRight:Label(TL(
    "Ниже собраны быстрые действия, синхронизация, диагностика и session tools.",
    "Нижче зібрані швидкі дії, синхронізація, діагностика та session tools.",
    "Use the sections below for quick actions, sync, diagnostics, and session tools."
))
end

function syncDropdownValue(dropdown, value)
    if dropdown and dropdown.Set then
        pcall(function()
            dropdown:Set(value, true)
        end)
    end
end

function getCompactPositionText()
    local root = getRootPart()
    if not root then return "" end
    local p = root.Position
    return string.format("Vector3.new(%.2f, %.2f, %.2f)", p.X, p.Y, p.Z)
end

function setRootAnchored(on)
    local root = getRootPart()
    if not root then
        return false
    end
    root.Anchored = on and true or false
    return true
end

function teleportByOffset(offset)
    local root = getRootPart()
    if not root or typeof(offset) ~= "Vector3" then
        return false
    end
    teleportLocalTo(root.CFrame + offset)
    return true
end

function respawnLocalCharacter()
    local ok = pcall(function()
        LP:LoadCharacter()
    end)
    if ok then
        return true
    end
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.Health = 0
        return true
    end
    return false
end

function tryRejoinSameServer()
    if not TeleportService then
        return false
    end
    return pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)
end

function tryServerHop()
    if not TeleportService then
        return false
    end
    return pcall(function()
        TeleportService:Teleport(game.PlaceId, LP)
    end)
end

function getPlayersListText()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    table.sort(names)
    return table.concat(names, ", ")
end

function getServerSummaryText()
    return string.format(
        "PlaceId=%s | JobId=%s | Players=%d",
        tostring(game.PlaceId),
        tostring(game.JobId),
        #Players:GetPlayers()
    )
end

function getCurrentLanguageLabel()
    local current = tostring(Translations.Current or "ru")
    if current == "uk" then
        return "Ukrainian"
    end
    if current == "en" then
        return "English"
    end
    return "Russian"
end

function getSavedSlotsSummaryText()
    local states = {}
    for i = 1, 3 do
        states[#states + 1] = string.format(
            "Slot%d=%s",
            i,
            TeleportSettings.Slots[i] and "saved" or "empty"
        )
    end
    return table.concat(states, " | ")
end

function getHubSessionSummaryText()
    return table.concat({
        "Hub=" .. HUB_BRAND,
        "Theme=" .. tostring(YasiaHubSettings.Theme or "Default"),
        "Language=" .. getCurrentLanguageLabel(),
        "QuietLoad=" .. tostring(MainSettings.QuietLoad == true),
        "ChatLoop=" .. tostring(ChatSettings.Enabled == true),
        getServerSummaryText(),
        getSavedSlotsSummaryText(),
    }, "\n")
end

function assignTargetPlayer(player)
    if not player then
        return false
    end
    CombatSettings.TargetLockName = player.Name
    AdminSettings.FollowTarget = player.Name
    AdminSettings.SpectateName = player.Name
    FunSettings.OrbitTarget = player.Name
    syncDropdownValue(RuntimeRefs.CombatTargetDropdown, player.Name)
    syncDropdownValue(RuntimeRefs.AdminFollowDropdown, player.Name)
    syncDropdownValue(RuntimeRefs.AdminSpectateDropdown, player.Name)
    syncDropdownValue(RuntimeRefs.OrbitDropdown, player.Name)
    return true
end

function stopCoreMovementStates()
    flyEnabled = false
    stopFly()
    noclipEnabled = false
    stopNoclip()
    infiniteJump = false
    stopInfiniteJump()
    speedHackEnabled = false
    stopSpeedHack()
    clickTPEnabled = false
    GlobalState.clickTPEnabled = false
    tpClickModifierActive = false
    setRootAnchored(false)
    zeroCharacterMomentum()
    return true
end

function stopFunEffects()
    FunSettings.Orbit = false
    FunSettings.OrbitTarget = ""
    FunSettings.Bounce = false
    FunSettings.RainbowBody = false
    FunSettings.RocketJump = false
    FunSettings.Spin = false
    setSpinCharacter(false)
    return true
end

function resetWorldVisualState()
    setFullbright(false)
    setNoFog(false)
    setNoTextures(false)
    setNoParticles(false)
    setWorldXray(false)
    setHideOtherGuis(false)
    HighlightSettings.Enabled = false
    HighlightSettings.Rainbow = false
    updatePlayerHighlights()
    return true
end

updateAutoLoadStatusLabel = function()
    if RuntimeRefs and RuntimeRefs.AutoLoadStatusLabel and RuntimeRefs.AutoLoadStatusLabel.SetText then
        RuntimeRefs.AutoLoadStatusLabel:SetText(TL(
            "Автозагрузка после телепорта: " .. (MainSettings.AutoLoad and "ВКЛ" or "ВЫКЛ"),
            "Автозавантаження після телепорту: " .. (MainSettings.AutoLoad and "УВІМК" or "ВИМК"),
            "Autoload after teleport: " .. (MainSettings.AutoLoad and "ON" or "OFF")
        ))
    end
end

getTeleportQueueFunction = function()
    local env = getSharedEnv()
    local direct = env.queue_on_teleport or env.queueonteleport or queue_on_teleport or queueonteleport
    if type(direct) == "function" then
        return direct
    end

    local containers = { syn, fluxus, krnl }
    for _, container in ipairs(containers) do
        if type(container) == "table" then
            if type(container.queue_on_teleport) == "function" then
                return container.queue_on_teleport
            end
            if type(container.queueonteleport) == "function" then
                return container.queueonteleport
            end
        end
    end

    return nil
end

buildTeleportAutoloadSource = function()
    local quotedPaths = {}
    for _, path in ipairs(GlobalState.ScriptReadfileCandidates or {}) do
        quotedPaths[#quotedPaths + 1] = string.format("%q", tostring(path))
    end

    return table.concat({
        "pcall(function()",
        "    local loader = loadstring or load",
        "    local reader = readfile",
        "    local checker = isfile or is_file",
        "    if type(loader) ~= 'function' or type(reader) ~= 'function' then return end",
        "    local candidates = { " .. table.concat(quotedPaths, ", ") .. " }",
        "    local function tryLoad(path)",
        "        if type(checker) == 'function' then",
        "            local okCheck, exists = pcall(checker, path)",
        "            if okCheck and not exists then",
        "                return false",
        "            end",
        "        end",
        "        local okRead, source = pcall(reader, path)",
        "        if not okRead or type(source) ~= 'string' or source == '' then",
        "            return false",
        "        end",
        "        local okCompile, chunk = pcall(loader, source, '@YasiaHubAutoLoad')",
        "        if okCompile and type(chunk) == 'function' then",
        "            local okRun = pcall(chunk)",
        "            if okRun then",
        "                return true",
        "            end",
        "        end",
        "        return false",
        "    end",
        "    for _, path in ipairs(candidates) do",
        "        if tryLoad(path) then",
        "            break",
        "        end",
        "    end",
        "end)",
    }, "\n")
end

applyTeleportAutoload = function(silent)
    local queueFn = getTeleportQueueFunction()
    updateAutoLoadStatusLabel()

    if type(queueFn) ~= "function" then
        if not silent and hubNotify then
            hubNotify("Settings", TL(
                "Очередь телепорта недоступна в этом executor.",
                "Черга телепорту недоступна в цьому executor.",
                "Teleport queue is unavailable in this executor."
            ), 3, true)
        end
        return false
    end

    local payload = MainSettings.AutoLoad and buildTeleportAutoloadSource() or ""
    local ok, err = pcall(queueFn, payload)
    if not ok then
        if not silent and hubNotify then
            hubNotify("Settings", TL(
                "Не удалось обновить автозагрузку: ",
                "Не вдалося оновити автозавантаження: ",
                "Failed to update autoload: "
            ) .. tostring(err), 4, true)
        end
        return false
    end

    return true
end

setHubAutoLoadEnabled = function(state, silent)
    MainSettings.AutoLoad = state == true
    setStoredValue(ENV_KEYS.AutoLoad, ENV_KEYS.LegacyAutoLoad, MainSettings.AutoLoad)
    local queued = applyTeleportAutoload(true)
    updateAutoLoadStatusLabel()

    if not silent and hubNotify then
        if MainSettings.AutoLoad then
            hubNotify("Settings", queued and TL(
                "Автозагрузка добавлена в очередь телепорта.",
                "Автозавантаження додано в чергу телепорту.",
                "Autoload was queued for teleport."
            ) or TL(
                "Флаг автозагрузки сохранён, но очередь телепорта недоступна.",
                "Прапорець автозавантаження збережено, але черга телепорту недоступна.",
                "Autoload flag was saved, but teleport queue is unavailable."
            ), 3, true)
        else
            hubNotify("Settings", queued and TL(
                "Автозагрузка убрана из очереди телепорта.",
                "Автозавантаження прибрано з черги телепорту.",
                "Autoload was removed from the teleport queue."
            ) or TL(
                "Автозагрузка выключена.",
                "Автозавантаження вимкнено.",
                "Autoload disabled."
            ), 3, true)
        end
    end

    return queued
end

unloadYasiaHub = function(reason)
    if GlobalState.UnloadInProgress or GlobalState.Unloaded then
        return false
    end

    GlobalState.UnloadInProgress = true
    local success, err = pcall(function()
        GlobalState.Unloaded = true
        MainSettings.HudEnabled = false
        setChatLoopEnabled(false)
        stopCoreMovementStates()
        stopTouchFling()
        stopAntiFling()
        stopFunEffects()
        stopESP()
        stopGodMode()
        setHudEnabled(false)
        setInvisToggle(false)
        setAntiAfk(false)
        setLocalNameHidden(false)
        restoreGraphics()
        resetWorldVisualState()
        setUnlockZoom(false)

        CombatSettings.HitboxExpand = false
        if setupHitboxMonitoring then
            setupHitboxMonitoring()
        end

        VehicleSystem.FlyEnabled = false
        VehicleSystem.NoclipEnabled = false
        VehicleSystem.SpeedHackEnabled = false
        stopVehicleSpeedHack()
        disableVehicleFly()
        setVehicleModelCollision(nil, true)

        AimbotSettings.Enabled = false
        AimbotSettings.BindActive = false
        AimbotSettings.SpinBindActive = false
        AimbotSettings.TriggerBindActive = false
        AimbotRuntime.ManualActivation = false
        AimbotRuntime.KeybindActive = false
        AimbotRuntime.SpinKeybindActive = false
        AimbotRuntime.TriggerKeybindActive = false

        if AimbotRuntime.FoVCircle then
            pcall(function()
                AimbotRuntime.FoVCircle.Visible = false
                AimbotRuntime.FoVCircle:Remove()
            end)
            AimbotRuntime.FoVCircle = nil
        end

        if AdminSettings.HighlightObject then
            pcall(function()
                AdminSettings.HighlightObject:Destroy()
            end)
            AdminSettings.HighlightObject = nil
        end

        for _, field in ipairs({
            "MainHeartbeatConnection",
            "MainInputBeganConnection",
            "MainInputEndedConnection",
            "MainJumpRequestConnection",
            "MainRenderConnection",
            "MainPlayerAddedConnection",
            "MainPlayerRemovingConnection",
            "SafeUpdateConnection",
            "CharacterAddedConnection",
            "CharacterDiedConnection",
        }) do
            if GlobalState[field] then
                pcall(function()
                    GlobalState[field]:Disconnect()
                end)
                GlobalState[field] = nil
            end
        end

        if type(GlobalState.OriginalLibraryUnload) == "function" then
            pcall(GlobalState.OriginalLibraryUnload, Library)
        elseif Window and Window.Instance then
            pcall(function()
                Window.Instance:Destroy()
            end)
        end
    end)

    GlobalState.UnloadInProgress = false
    if not success then
        warn("[" .. HUB_TAG .. "] unload error (" .. tostring(reason or "unknown") .. "): " .. tostring(err))
    end
    return success
end

function getThemeList()
    return { "Default", "Aqua", "Blood", "Emerald", "Gold", "Midnight", "Sunset", "Ice", "Mint", "Rose", "Steel" }
end

function getToggleWord(value)
    return value and "ON" or "OFF"
end

function getEnabledModuleCount()
    local count = 0
    local flags = {
        GlobalState and GlobalState.espEnabled == true,
        flyEnabled == true,
        noclipEnabled == true,
        infiniteJump == true,
        godModeEnabled == true,
        MovementSettings.AntiVoid == true,
        MovementSettings.BunnyHop == true,
        MovementSettings.Glide == true,
        CombatSettings.SilentAim == true,
        CombatSettings.Triggerbot == true,
        AimbotSettings.Enabled == true,
        ChatSettings.Enabled == true,
        FarmSettings.AutoEnabled == true,
        MainSettings.HudEnabled == true,
    }

    for _, enabled in ipairs(flags) do
        if enabled then
            count = count + 1
        end
    end

    return count
end

function getThemePreviewText()
    return table.concat({
        TL("Тема", "Тема", "Theme") .. "=" .. tostring(YasiaHubSettings.Theme or "Default"),
        TL("Язык", "Мова", "Language") .. "=" .. getCurrentLanguageLabel(),
        "HUD=" .. getToggleWord(MainSettings.HudEnabled == true),
        "Auto=" .. getToggleWord(MainSettings.AutoLoad == true),
    }, " | ")
end

function getMovementSnapshotText()
    return table.concat({
        "Fly=" .. getToggleWord(flyEnabled == true),
        "Noclip=" .. getToggleWord(noclipEnabled == true),
        "BHop=" .. getToggleWord(MovementSettings.BunnyHop == true),
        "AntiVoid=" .. getToggleWord(MovementSettings.AntiVoid == true),
        "Glide=" .. getToggleWord(MovementSettings.Glide == true),
        "Speed=" .. tostring(math.floor(tonumber(GlobalState.flySpeed or flySpeed or 0) or 0)),
    }, " | ")
end

function getVisualSnapshotText()
    return table.concat({
        "ESP=" .. getToggleWord(GlobalState and GlobalState.espEnabled == true),
        "Fullbright=" .. getToggleWord(MiscSettings.Fullbright == true),
        "NoFog=" .. getToggleWord(MiscSettings.NoFog == true),
        "NoTextures=" .. getToggleWord(MiscSettings.NoTextures == true),
        "NoParticles=" .. getToggleWord(MiscSettings.NoParticles == true),
        "Xray=" .. getToggleWord(MiscSettings.Xray == true),
    }, " | ")
end

function getFarmSnapshotText()
    return table.concat({
        "Auto=" .. getToggleWord(FarmSettings.AutoEnabled == true),
        "Prompt=" .. getToggleWord(FarmSettings.PromptEnabled == true),
        "Click=" .. getToggleWord(FarmSettings.ClickEnabled == true),
        "Touch=" .. getToggleWord(FarmSettings.TouchEnabled == true),
        "Tools=" .. getToggleWord(FarmSettings.AutoCollectTools == true),
        "TP=" .. getToggleWord(FarmSettings.TeleportToTargets == true),
        "Interval=" .. tostring(FarmSettings.Interval or 0),
    }, " | ")
end

function getCombatSnapshotText()
    return table.concat({
        "Silent=" .. getToggleWord(CombatSettings.SilentAim == true),
        "Trigger=" .. getToggleWord(CombatSettings.Triggerbot == true),
        "AimAssist=" .. getToggleWord(CombatSettings.AimAssist == true),
        "Aimbot=" .. getToggleWord(AimbotSettings.Enabled == true),
        "Target=" .. tostring(CombatSettings.TargetLockName ~= "" and CombatSettings.TargetLockName or "-"),
    }, " | ")
end

function getGalleryIdsText(onlyFresh)
    local ids = {}
    for _, entry in ipairs(GallerySettings.Images or {}) do
        local isFresh = string.find(tostring(entry.Name or ""), "Fresh", 1, true) ~= nil
        if (onlyFresh and isFresh) or (not onlyFresh) then
            table.insert(ids, tostring(entry.AssetId or ""))
        end
    end
    return table.concat(ids, "\n")
end

function getHubDiagnosticsText()
    return table.concat({
        "Hub=" .. HUB_BRAND,
        "Theme=" .. tostring(YasiaHubSettings.Theme or "Default"),
        "Language=" .. getCurrentLanguageLabel(),
        "AutoLoad=" .. getToggleWord(MainSettings.AutoLoad == true),
        "ActiveModules=" .. tostring(getEnabledModuleCount()),
        "Coords=" .. tostring(getCompactPositionText() ~= "" and getCompactPositionText() or "-"),
        getServerSummaryText(),
        getSavedSlotsSummaryText(),
        getVisualSnapshotText(),
        getMovementSnapshotText(),
        getCombatSnapshotText(),
        getFarmSnapshotText(),
        "GalleryImages=" .. tostring(#(GallerySettings.Images or {})),
        "CloudPage=" .. tostring(CloudScriptsSettings.Page or 1) .. "/" .. tostring(CloudScriptsSettings.TotalPages or "?"),
        "CloudResults=" .. tostring(#(CloudScriptsSettings.Results or {})),
    }, "\n")
end

function getLiveStatusText()
    return table.concat({
        "Modules=" .. tostring(getEnabledModuleCount()),
        "Coords=" .. tostring(getCompactPositionText() ~= "" and getCompactPositionText() or "-"),
        "Chat=" .. getToggleWord(ChatSettings.Enabled == true),
        "Farm=" .. getToggleWord(FarmSettings.AutoEnabled == true),
        "Aimbot=" .. getToggleWord(AimbotSettings.Enabled == true),
    }, " | ")
end

function cycleAccentTheme(step)
    local themes = getThemeList()
    local current = tostring(YasiaHubSettings.Theme or "Default")
    local currentIndex = 1

    for index, themeName in ipairs(themes) do
        if themeName == current then
            currentIndex = index
            break
        end
    end

    local nextIndex = ((currentIndex - 1 + (step or 1)) % #themes) + 1
    local nextTheme = themes[nextIndex]
    applyAccentTheme(nextTheme)
    refreshLiveStatusLabels()
    hubNotify(TL("Тема", "Тема", "Theme"), nextTheme, 2, true)
    return nextTheme
end

function showBeginnerTipsNotice()
    hubNotify(
        TL("Советы", "Поради", "Tips"),
        TL(
            "Начни с Settings, сохрани позицию перед тестом и включай функции по одной.",
            "Почни з Settings, збережи позицію перед тестом і вмикай функції по одній.",
            "Start in Settings, save a position before testing, and enable features one by one."
        ),
        6,
        true
    )
end

function refreshLiveStatusLabels()
    local liveText = getLiveStatusText()
    local diagnosticsText = getHubDiagnosticsText()
    local themeText = getThemePreviewText()

    if RuntimeRefs.MainLiveLabel and RuntimeRefs.MainLiveLabel.SetText then
        RuntimeRefs.MainLiveLabel:SetText(liveText)
    end
    if RuntimeRefs.SettingsLiveLabel and RuntimeRefs.SettingsLiveLabel.SetText then
        RuntimeRefs.SettingsLiveLabel:SetText(liveText)
    end
    if RuntimeRefs.DiagnosticsLabel and RuntimeRefs.DiagnosticsLabel.SetText then
        RuntimeRefs.DiagnosticsLabel:SetText(diagnosticsText)
    end
    if RuntimeRefs.ThemePreviewLabel and RuntimeRefs.ThemePreviewLabel.SetText then
        RuntimeRefs.ThemePreviewLabel:SetText(themeText)
    end
end

do
local mainYasia = pageMain:Section({ Name = "Yasia Hub | Quick Pack", Icon = "zap", Side = 1 })
addActionButtons(mainYasia, {
    { Name = "Save Last Position", Callback = function() rememberCurrentPosition(); hubNotify("Main", "Last position saved", 2) end },
    { Name = "Back To Last Position", Callback = function() if TeleportSettings.LastCF then teleportLocalTo(TeleportSettings.LastCF); hubNotify("Main", "Returned to saved position", 2) end end },
    { Name = "Seat Nearest Seat", Callback = function() seatInNearestSeat(); hubNotify("Main", "Moving to nearest seat", 2) end },
    { Name = "Dash Forward", Callback = function() dashForward() end },
    { Name = "Zero Momentum", Callback = function() zeroCharacterMomentum(); hubNotify("Main", "Momentum cleared", 2) end },
    { Name = "Equip All Tools", Callback = function() equipAllTools(); hubNotify("Main", "All tools equipped", 2) end },
})
end

do
local espYasia = pageESP:Section({ Name = "Yasia Hub | ESP Presets", Icon = "eye", Side = 2 })
addActionButtons(espYasia, {
    { Name = "Full ESP Preset", Callback = function() startESP(); espShowBox = true; espShowText = true; espShowHealthBar = true; espShowDistance = true; espShowTracer = true; espShowHeadDot = true; espShowHealthText = true; hubNotify("ESP", "Full preset applied", 2) end },
    { Name = "Minimal ESP Preset", Callback = function() startESP(); espShowBox = true; espShowText = true; espShowHealthBar = false; espShowDistance = false; espShowTracer = false; espShowHeadDot = false; espShowHealthText = false; hubNotify("ESP", "Minimal preset applied", 2) end },
    { Name = "Rainbow ESP Preset", Callback = function() startESP(); espRainbow = true; espShowTracer = true; espShowHeadDot = true; hubNotify("ESP", "Rainbow preset applied", 2) end },
    { Name = "Enemy Highlight Only", Callback = function() HighlightSettings.Enabled = true; HighlightSettings.EnemyOnly = true; CombatSettings.TeamHighlightEnabled = true; updatePlayerHighlights(); hubNotify("ESP", "Enemy highlight enabled", 2) end },
    { Name = "Default ESP Colors", Callback = function() espBoxColor = Color3.fromRGB(255, 0, 0); HighlightSettings.Rainbow = false; hubNotify("ESP", "Default colors restored", 2) end },
    { Name = "Reset Visual Preset", Callback = function() PresetActions.resetVisual(); hubNotify("ESP", "Visual preset reset", 2) end },
})
end

do
local moveYasia = pageMovement:Section({ Name = "Yasia Hub | Movement Pack", Icon = "move", Side = 1 })
addActionButtons(moveYasia, {
    { Name = "Legit Move Preset", Callback = function() setWalkSpeed(16); setJumpPower(50); setGravity(196.2); hubNotify("Move", "Legit preset applied", 2) end },
    { Name = "Runner Preset", Callback = function() setWalkSpeed(32); setJumpPower(70); setGravity(196.2); hubNotify("Move", "Runner preset applied", 2) end },
    { Name = "Moon Preset", Callback = function() setWalkSpeed(24); setJumpPower(120); setGravity(80); hubNotify("Move", "Moon preset applied", 2) end },
    { Name = "Dash Left", Callback = function() dashLeft() end },
    { Name = "Dash Right", Callback = function() dashRight() end },
    { Name = "Reset Move Preset", Callback = function() PresetActions.resetMovement(); hubNotify("Move", "Movement reset", 2) end },
})
end

do
local combatYasia = pageCombat:Section({ Name = "Yasia Hub | Combat Quick Tools", Icon = "crosshair", Side = 1 })
addActionButtons(combatYasia, {
    { Name = "Face Nearest Enemy", Callback = function() local plr = getNearestPlayer(1500, true); if plr then facePlayer(plr) end end },
    { Name = "TP Behind Nearest Enemy", Callback = function() local plr = getNearestPlayer(1500, true); local root = plr and getRootPart(plr.Character); if root then teleportLocalTo(root.CFrame * CFrame.new(0, 0, 3)) end end },
    { Name = "Lock Nearest Enemy", Callback = function() local plr = getNearestPlayer(1500, true); if plr then CombatSettings.TargetLockName = plr.Name; syncDropdownValue(RuntimeRefs.CombatTargetDropdown, plr.Name); hubNotify("Combat", "Locked: " .. plr.Name, 2) end end },
    { Name = "Quick PvP Preset", Callback = function() CombatSettings.AimAssist = true; CombatSettings.Triggerbot = true; CombatSettings.TeamCheck = true; CombatSettings.TeamHighlightEnabled = true; hubNotify("Combat", "Quick PvP preset enabled", 2) end },
    { Name = "Silent Shortcut ON", Callback = function() CombatSettings.SilentAim = true; AimbotSettings.Enabled = true; AimbotRuntime.ManualActivation = true; AimbotSettings.BindActive = true; if table.find(AimbotSettings.AvailableModes, "Silent") then AimbotSettings.Mode = "Silent" end; refreshAimbotBindState(); updateAimbotStatusLabel(); hubNotify("Combat", "Silent shortcut enabled", 2) end },
    { Name = "Reset Combat Shortcuts", Callback = function() PresetActions.resetCombat(); hubNotify("Combat", "Combat shortcuts reset", 2) end },
})
end

do
local miscYasia = pageMisc:Section({ Name = "Yasia Hub | World Presets", Icon = "sun", Side = 1 })
addActionButtons(miscYasia, {
    { Name = "Day Preset", Callback = function() setClockTime(14); setBrightnessValue(2.5); setNoFog(false); pcall(function() Lighting.GlobalShadows = true end); hubNotify("World", "Day preset applied", 2) end },
    { Name = "Night Preset", Callback = function() setClockTime(0); setBrightnessValue(0.7); setNoFog(false); pcall(function() Lighting.GlobalShadows = true end); hubNotify("World", "Night preset applied", 2) end },
    { Name = "Low Graphics", Callback = function() setNoTextures(true); setNoParticles(true); pcall(function() Lighting.GlobalShadows = false end); hubNotify("World", "Low graphics enabled", 2) end },
    { Name = "Restore Graphics", Callback = function() setNoTextures(false); setNoParticles(false); setNoFog(false); pcall(function() Lighting.GlobalShadows = true end); hubNotify("World", "Graphics restored", 2) end },
    { Name = "Xray ON", Callback = function() setWorldXray(true); hubNotify("World", "Xray enabled", 2) end },
    { Name = "Xray OFF", Callback = function() setWorldXray(false); hubNotify("World", "Xray disabled", 2) end },
})
end

do
local funYasia = pageFun:Section({ Name = "Yasia Hub | Fun Pack", Icon = "smile", Side = 1 })
addActionButtons(funYasia, {
    { Name = "Random Character Color", Callback = function() setRandomCharacterColor() end },
    { Name = "Rainbow Body ON", Callback = function() FunSettings.RainbowBody = true; hubNotify("Fun", "Rainbow body enabled", 2) end },
    { Name = "Rainbow Body OFF", Callback = function() FunSettings.RainbowBody = false; hubNotify("Fun", "Rainbow body disabled", 2) end },
    { Name = "Grow Character", Callback = function() if not setCharacterScale(1.15) then hubNotify("Fun", "Scale values not found on this rig", 2, true) end end },
    { Name = "Shrink Character", Callback = function() if not setCharacterScale(0.85) then hubNotify("Fun", "Scale values not found on this rig", 2, true) end end },
    { Name = "Reset Character Scale", Callback = function() if not setCharacterScale(1) then hubNotify("Fun", "Scale values not found on this rig", 2, true) end end },
    { Name = "Launch Up", Callback = function() local root = getRootPart(); if root then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 120, root.AssemblyLinearVelocity.Z) end end },
    { Name = "Dance 1", Callback = function() playLocalAnimation("507771019") end },
    { Name = "Dance 2", Callback = function() playLocalAnimation("507776043") end },
    { Name = "Orbit Nearest Player", Callback = function() local plr = getNearestPlayer(1500, false); if plr then FunSettings.OrbitTarget = plr.Name; FunSettings.Orbit = true; syncDropdownValue(RuntimeRefs.OrbitDropdown, plr.Name); hubNotify("Fun", "Orbiting: " .. plr.Name, 2) end end },
    { Name = "Say ':)'", Callback = function() sendChatMessage(":)") end },
    { Name = "Say 'Yasia Hub moment'", Callback = function() sendChatMessage("Yasia Hub moment") end },
})
end

do
local utilYasia = pageUtility:Section({ Name = "Yasia Hub | Quick Utility Pack", Icon = "tool", Side = 1 })
addActionButtons(utilYasia, {
    { Name = "Copy JobId", Callback = function() local copied = tryCopyText(game.JobId); hubNotify("Utility", copied and "JobId copied" or tostring(game.JobId), copied and 2 or 4, true) end },
    { Name = "Copy Position", Callback = function() local text = getCompactPositionText(); local copied = tryCopyText(text); hubNotify("Utility", copied and "Position copied" or text, copied and 2 or 4, true) end },
    { Name = "Equip All Tools", Callback = function() equipAllTools() end },
    { Name = "Unequip Tools", Callback = function() unequipTools() end },
    { Name = "Seat Nearest Seat", Callback = function() seatInNearestSeat() end },
    { Name = "TP Nearest Spawn", Callback = function() teleportToNearestObject("spawn") end },
})
end

do
local farmYasia = pageFarm:Section({ Name = "Yasia Hub | Farm Presets", Icon = "cpu", Side = 1 })
addActionButtons(farmYasia, {
    { Name = "Preset: All Sources", Callback = function() PresetActions.applyFarm("all"); hubNotify("Farm", "All-source preset applied", 2) end },
    { Name = "Preset: Prompts Only", Callback = function() PresetActions.applyFarm("prompt"); hubNotify("Farm", "Prompt preset applied", 2) end },
    { Name = "Preset: Touch Only", Callback = function() PresetActions.applyFarm("touch"); hubNotify("Farm", "Touch preset applied", 2) end },
    { Name = "Preset: Tools Only", Callback = function() PresetActions.applyFarm("tools"); hubNotify("Farm", "Tool preset applied", 2) end },
    { Name = "Clear Farm Filters", Callback = function() PresetActions.resetFarmFilters(); hubNotify("Farm", "Filters cleared", 2) end },
    { Name = "Use Nearest Prompt", Callback = function() local prompt = getNearestPrompt(FarmSettings.AutoRadius); if prompt then usePrompt(prompt) end end },
    { Name = "Use Nearest Click", Callback = function() local click = getNearestClickDetector(FarmSettings.AutoRadius); if click then useClickDetector(click) end end },
    { Name = "Take Nearest Tool", Callback = function() local tool = getNearestToolInWorld(FarmSettings.AutoRadius); local handle = tool and tool:FindFirstChild("Handle"); if handle then touchPart(handle) end end },
})
end

do
local tpYasia = pageTeleports:Section({ Name = "Yasia Hub | World TP Tools", Icon = "map-pin", Side = 2 })
addActionButtons(tpYasia, {
    { Name = "TP Nearest Prompt", Callback = function() teleportToNearestObject("prompt") end },
    { Name = "TP Nearest Click", Callback = function() teleportToNearestObject("click") end },
    { Name = "TP Nearest Tool", Callback = function() teleportToNearestObject("tool") end },
    { Name = "TP Nearest Seat", Callback = function() teleportToNearestObject("seat") end },
    { Name = "TP Nearest Spawn", Callback = function() teleportToNearestObject("spawn") end },
    { Name = "Back To Last Position", Callback = function() if TeleportSettings.LastCF then teleportLocalTo(TeleportSettings.LastCF) end end },
    { Name = "Copy Position", Callback = function() local text = getCompactPositionText(); local copied = tryCopyText(text); hubNotify("TP", copied and "Position copied" or text, copied and 2 or 4, true) end },
})
end

do
local adminYasia = pageAdmin:Section({ Name = "Yasia Hub | Admin Quick Pack", Icon = "shield", Side = 2 })
addActionButtons(adminYasia, {
    { Name = "Spectate Nearest Player", Callback = function() local plr = getNearestPlayer(1500, false); local hum = plr and getHumanoid(plr.Character); if plr and hum then AdminSettings.SpectateName = plr.Name; syncDropdownValue(RuntimeRefs.AdminSpectateDropdown, plr.Name); workspace.CurrentCamera.CameraSubject = hum; hubNotify("Admin", "Spectating: " .. plr.Name, 2) end end },
    { Name = "Follow Nearest Player", Callback = function() local plr = getNearestPlayer(1500, false); if plr then AdminSettings.FollowTarget = plr.Name; AdminSettings.FollowEnabled = true; syncDropdownValue(RuntimeRefs.AdminFollowDropdown, plr.Name); hubNotify("Admin", "Following: " .. plr.Name, 2) end end },
    { Name = "Highlight Current Target", Callback = function() AdminSettings.HighlightTarget = true; hubNotify("Admin", "Target highlight enabled", 2) end },
    { Name = "Copy Target Name", Callback = function() local name = AdminSettings.FollowTarget ~= "" and AdminSettings.FollowTarget or AdminSettings.SpectateName; if name ~= "" then local copied = tryCopyText(name); hubNotify("Admin", copied and "Target name copied" or name, copied and 2 or 4, true) end end },
    { Name = "Clear Follow / Spectate", Callback = function() AdminSettings.FollowEnabled = false; AdminSettings.HighlightTarget = false; AdminSettings.FollowTarget = ""; AdminSettings.SpectateName = ""; workspace.CurrentCamera.CameraSubject = getHumanoid() or workspace.CurrentCamera.CameraSubject; hubNotify("Admin", "Admin assists cleared", 2) end },
    { Name = "Pick Farthest Player", Callback = function() local plr = getFarthestPlayer(5000, false); if plr then AdminSettings.SpectateName = plr.Name; syncDropdownValue(RuntimeRefs.AdminSpectateDropdown, plr.Name); hubNotify("Admin", "Picked: " .. plr.Name, 2) end end },
})
end

do
local vehicleYasia = pageVehicles:Section({ Name = "Yasia Hub | Vehicle Presets", Icon = "truck", Side = 2 })
addActionButtons(vehicleYasia, {
    { Name = "Vehicle Preset: Cruise", Callback = function() VehicleSystem.Speed = 80; VehicleSystem.UpSpeed = 35; VehicleSystem.RotationSpeed = 4; hubNotify("Vehicle", "Cruise preset applied", 2) end },
    { Name = "Vehicle Preset: Race", Callback = function() VehicleSystem.Speed = 160; VehicleSystem.UpSpeed = 65; VehicleSystem.RotationSpeed = 8; hubNotify("Vehicle", "Race preset applied", 2) end },
    { Name = "Vehicle Preset: Air", Callback = function() VehicleSystem.Speed = 120; VehicleSystem.UpSpeed = 90; VehicleSystem.RotationSpeed = 6; hubNotify("Vehicle", "Air preset applied", 2) end },
    { Name = "Flip Upright", Callback = function() flipSeatedVehicleUpright() end },
    { Name = "Brake Vehicle", Callback = function() local _, pp = getSeatedVehiclePrimaryPart(); if pp then pp.AssemblyLinearVelocity = Vector3.zero; pp.AssemblyAngularVelocity = Vector3.zero end end },
    { Name = "TP Vehicle To Spawn", Callback = function() local spawn = getNearestSpawn(5000); if spawn then teleportSeatedVehicleTo(spawn.CFrame + Vector3.new(0, 5, 0)) end end },
    { Name = "Seat Nearest Seat", Callback = function() seatInNearestSeat() end },
})
end

do
local touchYasia = pageTouchFling:Section({ Name = "Yasia Hub | Touch Quick Presets", Icon = "zap", Side = 1 })
addActionButtons(touchYasia, {
    { Name = "Touch Preset: Light", Callback = function() PresetActions.applyTouchFling(2500, 2000, 0.05); hubNotify("Touch Fling", "Light preset applied", 2) end },
    { Name = "Touch Preset: Balanced", Callback = function() PresetActions.applyTouchFling(10000, 10000, 0.1); hubNotify("Touch Fling", "Balanced preset applied", 2) end },
    { Name = "Touch Preset: Insane", Callback = function() PresetActions.applyTouchFling(25000, 18000, 0.15); hubNotify("Touch Fling", "Insane preset applied", 2) end },
    { Name = "Start Touch Fling", Callback = function() startTouchFling(); hubNotify("Touch Fling", "Enabled", 2) end },
    { Name = "Stop Touch Fling", Callback = function() stopTouchFling(); hubNotify("Touch Fling", "Disabled", 2) end },
    { Name = "Zero Momentum", Callback = function() zeroCharacterMomentum() end },
})
end

do
local antiYasia = pageAntiFling:Section({ Name = "Yasia Hub | Safety Presets", Icon = "shield-check", Side = 1 })
addActionButtons(antiYasia, {
    { Name = "Anti-Fling Light", Callback = function() PresetActions.applyAntiFling("light"); hubNotify("Anti Fling", "Light preset applied", 2) end },
    { Name = "Anti-Fling Default", Callback = function() PresetActions.applyAntiFling("default"); hubNotify("Anti Fling", "Default preset applied", 2) end },
    { Name = "Anti-Fling Aggressive", Callback = function() PresetActions.applyAntiFling("aggressive"); hubNotify("Anti Fling", "Aggressive preset applied", 2) end },
    { Name = "Start Anti-Fling", Callback = function() startAntiFling(); hubNotify("Anti Fling", "Enabled", 2) end },
    { Name = "Stop Anti-Fling", Callback = function() stopAntiFling(); hubNotify("Anti Fling", "Disabled", 2) end },
    { Name = "Save Safe Position", Callback = function() local root = getRootPart(); if root then AntiFlingState.LastSafeCF = root.CFrame + Vector3.new(0, 3, 0); hubNotify("Anti Fling", "Safe position saved", 2) end end },
})
end

do
local cloudYasia = pageCloudScripts:Section({ Name = "Yasia Hub | Cloud Quick Tools", Icon = "cloud", Side = 1 })
addActionButtons(cloudYasia, {
    { Name = "Reset Cloud Filters", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.Max = 10; CloudScriptsSettings.SortBy = "updatedAt"; CloudScriptsSettings.Order = "desc"; CloudScriptsSettings.FreeOnly = false; CloudScriptsSettings.VerifiedOnly = false; CloudScriptsSettings.NoKey = false; CloudScriptsSettings.UniversalOnly = false; CloudScriptsSettings.HidePatched = false; hubNotify("Cloud", "Filters reset", 2) end },
    { Name = "Fetch Current Game", Callback = function() task.spawn(fetchCloudScripts) end },
    { Name = "Previous Cloud Page", Callback = function() CloudScriptsSettings.Page = math.max(1, CloudScriptsSettings.Page - 1); if CloudScriptsRuntime.PageSlider and CloudScriptsRuntime.PageSlider.Set then CloudScriptsRuntime.PageSlider:Set(CloudScriptsSettings.Page, true) end; task.spawn(fetchCloudScripts) end },
    { Name = "Next Cloud Page", Callback = function() CloudScriptsSettings.Page = math.min(math.max(1, CloudScriptsSettings.TotalPages or 1), CloudScriptsSettings.Page + 1); if CloudScriptsRuntime.PageSlider and CloudScriptsRuntime.PageSlider.Set then CloudScriptsRuntime.PageSlider:Set(CloudScriptsSettings.Page, true) end; task.spawn(fetchCloudScripts) end },
    { Name = "Copy Fetch URL", Callback = function() local url = buildCloudScriptsFetchUrl(); local copied = tryCopyText(url); hubNotify("Cloud", copied and "Fetch URL copied" or url, copied and 2 or 4, true) end },
})
end

do
local galleryYasia = pageGallery:Section({ Name = "Yasia Hub | Gallery Tools", Icon = "image", Side = 2 })
addActionButtons(galleryYasia, {
    { Name = "Copy Random Cat Asset", Callback = function() local pick = GallerySettings.Images[Random.new():NextInteger(1, #GallerySettings.Images)]; local copied = tryCopyText(pick.AssetId); hubNotify("Gallery", copied and (pick.Name .. " copied") or pick.AssetId, copied and 2 or 4, true) end },
    { Name = "Copy First Cat Asset", Callback = function() local pick = GallerySettings.Images[1]; local copied = tryCopyText(pick.AssetId); hubNotify("Gallery", copied and "First asset copied" or pick.AssetId, copied and 2 or 4, true) end },
    { Name = "Show Random Cat Notify", Callback = function() local pick = GallerySettings.Images[Random.new():NextInteger(1, #GallerySettings.Images)]; galleryNotify("Gallery", pick.Name .. " | " .. pick.AssetId, 3) end },
    { Name = "Copy Gallery Count", Callback = function() local copied = tryCopyText(tostring(#GallerySettings.Images)); hubNotify("Gallery", copied and "Image count copied" or tostring(#GallerySettings.Images), copied and 2 or 4, true) end },
    { Name = "Copy All Gallery IDs", Callback = function() local text = getGalleryIdsText(false); local copied = tryCopyText(text); hubNotify("Gallery", copied and "All gallery IDs copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Fresh Gallery IDs", Callback = function() local text = getGalleryIdsText(true); local copied = tryCopyText(text); hubNotify("Gallery", copied and "Fresh gallery IDs copied" or text, copied and 2 or 5, true) end },
    { Name = "Show Fresh Pack Notify", Callback = function() local fresh = {}; for _, entry in ipairs(GallerySettings.Images or {}) do if string.find(tostring(entry.Name or ""), "Fresh", 1, true) then table.insert(fresh, entry) end end; if #fresh > 0 then local pick = fresh[Random.new():NextInteger(1, #fresh)]; galleryNotify("Gallery", pick.Name .. " | " .. pick.AssetId, 3) else hubNotify("Gallery", "Fresh pack is empty", 3, true) end end },
    { Name = "Copy Gallery Summary", Callback = function() local freshCount = 0; for _, entry in ipairs(GallerySettings.Images or {}) do if string.find(tostring(entry.Name or ""), "Fresh", 1, true) then freshCount = freshCount + 1 end end; local text = table.concat({ "Total=" .. tostring(#(GallerySettings.Images or {})), "Fresh=" .. tostring(freshCount), "Theme=" .. tostring(YasiaHubSettings.Theme or "Default") }, " | "); local copied = tryCopyText(text); hubNotify("Gallery", copied and "Gallery summary copied" or text, copied and 2 or 5, true) end },
})
end

do
local settingsYasia = pageSettings:Section({ Name = "Yasia Hub | Appearance Lab", Icon = "settings", Side = 2 })
addActionButtons(settingsYasia, {
    { Name = "Toggle Quiet Load", Callback = function() MainSettings.QuietLoad = not MainSettings.QuietLoad; setStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, MainSettings.QuietLoad); hubNotify("Settings", "Quiet load: " .. tostring(MainSettings.QuietLoad), 2, true) end },
    { Name = "Theme: Default", Callback = function() applyAccentTheme("Default"); hubNotify("Settings", "Theme -> Default", 2, true) end },
    { Name = "Theme: Aqua", Callback = function() applyAccentTheme("Aqua"); hubNotify("Settings", "Theme -> Aqua", 2, true) end },
    { Name = "Theme: Blood", Callback = function() applyAccentTheme("Blood"); hubNotify("Settings", "Theme -> Blood", 2, true) end },
    { Name = "Theme: Emerald", Callback = function() applyAccentTheme("Emerald"); hubNotify("Settings", "Theme -> Emerald", 2, true) end },
    { Name = "Theme: Gold", Callback = function() applyAccentTheme("Gold"); hubNotify("Settings", "Theme -> Gold", 2, true) end },
    { Name = "Theme: Midnight", Callback = function() applyAccentTheme("Midnight"); hubNotify("Settings", "Theme -> Midnight", 2, true) end },
    { Name = "Theme: Sunset", Callback = function() applyAccentTheme("Sunset"); hubNotify("Settings", "Theme -> Sunset", 2, true) end },
    { Name = "Theme: Ice", Callback = function() applyAccentTheme("Ice"); hubNotify("Settings", "Theme -> Ice", 2, true) end },
    { Name = "Theme: Mint", Callback = function() applyAccentTheme("Mint"); hubNotify("Settings", "Theme -> Mint", 2, true) end },
    { Name = "Theme: Rose", Callback = function() applyAccentTheme("Rose"); hubNotify("Settings", "Theme -> Rose", 2, true) end },
    { Name = "Theme: Steel", Callback = function() applyAccentTheme("Steel"); hubNotify("Settings", "Theme -> Steel", 2, true) end },
    { Name = "Theme: Cycle Next", Callback = function() cycleAccentTheme(1) end },
    { Name = "Theme: Cycle Back", Callback = function() cycleAccentTheme(-1) end },
    { Name = "Reset Visual Preset", Callback = function() PresetActions.resetVisual(); hubNotify("Settings", "Visual preset reset", 2, true) end },
})
end

do
local mainUltra = pageMain:Section({ Name = "Yasia Hub | Main Extra Pack", Icon = "sparkles", Side = 2 })
addActionButtons(mainUltra, {
    { Name = "Save Position Slot 1", Callback = function() savePositionSlot(1); hubNotify("Main", "Slot 1 saved", 2) end },
    { Name = "Load Position Slot 1", Callback = function() loadPositionSlot(1); hubNotify("Main", "Slot 1 loaded", 2) end },
    { Name = "Save Position Slot 2", Callback = function() savePositionSlot(2); hubNotify("Main", "Slot 2 saved", 2) end },
    { Name = "Load Position Slot 2", Callback = function() loadPositionSlot(2); hubNotify("Main", "Slot 2 loaded", 2) end },
    { Name = "Restore Defaults", Callback = function() PresetActions.resetMovement(); PresetActions.resetVisual(); PresetActions.resetCombat(); hubNotify("Main", "Core presets restored", 2) end },
})
end

do
local espUltra = pageESP:Section({ Name = "Yasia Hub | ESP Extra Pack", Icon = "scan-eye", Side = 1 })
addActionButtons(espUltra, {
    { Name = "Box Only Preset", Callback = function() startESP(); espShowBox = true; espShowText = false; espShowHealthBar = false; espShowDistance = false; espShowTracer = false; espShowHeadDot = false; espShowHealthText = false; hubNotify("ESP", "Box only preset applied", 2) end },
    { Name = "Text Only Preset", Callback = function() startESP(); espShowBox = false; espShowText = true; espShowHealthBar = false; espShowDistance = true; espShowTracer = false; espShowHeadDot = false; espShowHealthText = true; hubNotify("ESP", "Text only preset applied", 2) end },
    { Name = "Disable Highlight", Callback = function() HighlightSettings.Enabled = false; CombatSettings.TeamHighlightEnabled = false; updatePlayerHighlights(); hubNotify("ESP", "Highlight disabled", 2) end },
    { Name = "Rainbow Highlight", Callback = function() HighlightSettings.Enabled = true; HighlightSettings.Rainbow = true; updatePlayerHighlights(); hubNotify("ESP", "Rainbow highlight enabled", 2) end },
})
end

do
local moveUltra = pageMovement:Section({ Name = "Yasia Hub | Movement Extra Pack", Icon = "gauge", Side = 2 })
addActionButtons(moveUltra, {
    { Name = "Dash Forward", Callback = function() dashForward() end },
    { Name = "Dash Backward", Callback = function() dashBackward() end },
    { Name = "Low Gravity Sprint", Callback = function() setWalkSpeed(40); setJumpPower(85); setGravity(120); hubNotify("Move", "Low gravity sprint applied", 2) end },
    { Name = "Zero Momentum", Callback = function() zeroCharacterMomentum(); hubNotify("Move", "Momentum cleared", 2) end },
})
end

do
local combatUltra = pageCombat:Section({ Name = "Yasia Hub | Combat Extra Pack", Icon = "swords", Side = 2 })
addActionButtons(combatUltra, {
    { Name = "Lock Farthest Enemy", Callback = function() local plr = getFarthestPlayer(5000, true); if plr then CombatSettings.TargetLockName = plr.Name; syncDropdownValue(RuntimeRefs.CombatTargetDropdown, plr.Name); hubNotify("Combat", "Locked far target: " .. plr.Name, 2) end end },
    { Name = "Face Locked Target", Callback = function() local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName); if plr then facePlayer(plr) end end },
    { Name = "Clear Locked Target", Callback = function() CombatSettings.TargetLockName = ""; syncDropdownValue(RuntimeRefs.CombatTargetDropdown, ""); hubNotify("Combat", "Target lock cleared", 2) end },
    { Name = "Trigger + Aim Preset", Callback = function() CombatSettings.AimAssist = true; CombatSettings.Triggerbot = true; CombatSettings.AutoToolSpam = true; hubNotify("Combat", "Trigger+Aim preset enabled", 2) end },
})
end

do
local miscUltra = pageMisc:Section({ Name = "Yasia Hub | World Extra Pack", Icon = "lamp", Side = 2 })
addActionButtons(miscUltra, {
    { Name = "Fullbright ON", Callback = function() setFullbright(true); hubNotify("World", "Fullbright enabled", 2) end },
    { Name = "Fullbright OFF", Callback = function() setFullbright(false); hubNotify("World", "Fullbright disabled", 2) end },
    { Name = "Hide Other GUIs", Callback = function() setHideOtherGuis(true); hubNotify("World", "Other GUIs hidden", 2) end },
    { Name = "Show Other GUIs", Callback = function() setHideOtherGuis(false); hubNotify("World", "Other GUIs restored", 2) end },
})
end

do
local funUltra = pageFun:Section({ Name = "Yasia Hub | Fun Extra Pack", Icon = "party-popper", Side = 2 })
addActionButtons(funUltra, {
    { Name = "Orbit Fast", Callback = function() FunSettings.OrbitSpeed = 4; FunSettings.OrbitRadius = 7; hubNotify("Fun", "Fast orbit preset applied", 2) end },
    { Name = "Orbit Wide", Callback = function() FunSettings.OrbitSpeed = 2; FunSettings.OrbitRadius = 14; hubNotify("Fun", "Wide orbit preset applied", 2) end },
    { Name = "Stop Orbit", Callback = function() FunSettings.Orbit = false; FunSettings.OrbitTarget = ""; hubNotify("Fun", "Orbit stopped", 2) end },
    { Name = "Random Scale", Callback = function() if not setCharacterScale(Random.new():NextNumber(0.7, 1.6)) then hubNotify("Fun", "Scale values not found on this rig", 2, true) end end },
})
end

do
local utilUltra = pageUtility:Section({ Name = "Yasia Hub | Utility Extra Pack", Icon = "clipboard", Side = 2 })
addActionButtons(utilUltra, {
    { Name = "Copy PlaceId", Callback = function() local copied = tryCopyText(tostring(game.PlaceId)); hubNotify("Utility", copied and "PlaceId copied" or tostring(game.PlaceId), copied and 2 or 4, true) end },
    { Name = "Copy UserId", Callback = function() local copied = tryCopyText(tostring(LP.UserId)); hubNotify("Utility", copied and "UserId copied" or tostring(LP.UserId), copied and 2 or 4, true) end },
    { Name = "Nearby Scan 150", Callback = function() local c = scanNearbyCounts(150); hubNotify("Utility", string.format("P:%d C:%d T:%d S:%d Sp:%d", c.prompts, c.clicks, c.tools, c.seats, c.spawns), 4, true) end },
    { Name = "Nearby Scan 400", Callback = function() local c = scanNearbyCounts(400); hubNotify("Utility", string.format("P:%d C:%d T:%d S:%d Sp:%d", c.prompts, c.clicks, c.tools, c.seats, c.spawns), 4, true) end },
})
end

do
local farmUltra = pageFarm:Section({ Name = "Yasia Hub | Farm Extra Pack", Icon = "pickaxe", Side = 2 })
addActionButtons(farmUltra, {
    { Name = "Run Farm Once", Callback = function() runFarmCycle(); hubNotify("Farm", "Single farm cycle finished", 2) end },
    { Name = "TP And Use Prompt", Callback = function() if teleportToNearestObject("prompt") then task.wait(0.15); local prompt = getNearestPrompt(20); if prompt then usePrompt(prompt) end end end },
    { Name = "TP And Use Click", Callback = function() if teleportToNearestObject("click") then task.wait(0.15); local click = getNearestClickDetector(20); if click then useClickDetector(click) end end end },
    { Name = "TP And Take Tool", Callback = function() if teleportToNearestObject("tool") then task.wait(0.15); local tool = getNearestToolInWorld(20); local handle = tool and tool:FindFirstChild("Handle"); if handle then touchPart(handle) end end end },
})
end

do
local tpUltra = pageTeleports:Section({ Name = "Yasia Hub | TP Extra Pack", Icon = "milestone", Side = 1 })
addActionButtons(tpUltra, {
    { Name = "Save Slot 3", Callback = function() savePositionSlot(3); hubNotify("TP", "Slot 3 saved", 2) end },
    { Name = "Load Slot 3", Callback = function() loadPositionSlot(3); hubNotify("TP", "Slot 3 loaded", 2) end },
    { Name = "TP To Locked Target", Callback = function() local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName); if plr then teleportToPlayer(plr) end end },
    { Name = "TP To Farthest Player", Callback = function() local plr = getFarthestPlayer(5000, false); if plr then teleportToPlayer(plr) end end },
})
end

do
local adminUltra = pageAdmin:Section({ Name = "Yasia Hub | Admin Extra Pack", Icon = "radar", Side = 1 })
addActionButtons(adminUltra, {
    { Name = "Follow Farthest Player", Callback = function() local plr = getFarthestPlayer(5000, false); if plr then AdminSettings.FollowTarget = plr.Name; AdminSettings.FollowEnabled = true; syncDropdownValue(RuntimeRefs.AdminFollowDropdown, plr.Name); hubNotify("Admin", "Following farthest: " .. plr.Name, 2) end end },
    { Name = "Highlight Nearest Player", Callback = function() local plr = getNearestPlayer(5000, false); if plr then AdminSettings.FollowTarget = plr.Name; AdminSettings.HighlightTarget = true; hubNotify("Admin", "Highlighting: " .. plr.Name, 2) end end },
    { Name = "Reset Camera Subject", Callback = function() local hum = getHumanoid(); if hum and workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum; hubNotify("Admin", "Camera reset to local player", 2) end end },
    { Name = "Clear Highlight Object", Callback = function() AdminSettings.HighlightTarget = false; if AdminSettings.HighlightObject then pcall(function() AdminSettings.HighlightObject:Destroy() end); AdminSettings.HighlightObject = nil end; hubNotify("Admin", "Highlight cleared", 2) end },
})
end

do
local vehicleUltra = pageVehicles:Section({ Name = "Yasia Hub | Vehicle Extra Pack", Icon = "car-front", Side = 1 })
addActionButtons(vehicleUltra, {
    { Name = "Vehicle Stop Hard", Callback = function() local _, pp = getSeatedVehiclePrimaryPart(); if pp then pp.AssemblyLinearVelocity = Vector3.zero; pp.AssemblyAngularVelocity = Vector3.zero; hubNotify("Vehicle", "Vehicle stopped", 2) end end },
    { Name = "Vehicle Hop Up", Callback = function() local _, pp = getSeatedVehiclePrimaryPart(); if pp then pp.CFrame = pp.CFrame + Vector3.new(0, 20, 0); pp.AssemblyLinearVelocity = Vector3.zero; hubNotify("Vehicle", "Vehicle lifted", 2) end end },
    { Name = "Vehicle To Local Spawn", Callback = function() local spawn = getNearestSpawn(5000); if spawn then teleportSeatedVehicleTo(spawn.CFrame + Vector3.new(0, 6, 0)); hubNotify("Vehicle", "Vehicle moved to spawn", 2) end end },
    { Name = "Vehicle To Saved Position", Callback = function() if TeleportSettings.LastCF then teleportSeatedVehicleTo(TeleportSettings.LastCF + Vector3.new(0, 6, 0)); hubNotify("Vehicle", "Vehicle moved to saved position", 2) end end },
})
end

do
local yasiaMain = pageMain:Section({ Name = "Yasia Hub | Control", Icon = "shield", Side = 1 })
addActionButtons(yasiaMain, {
    { Name = "Emergency Stop Core", Callback = function() stopCoreMovementStates(); stopTouchFling(); stopAntiFling(); hubNotify("Yasia", "Core systems stopped", 2, true) end },
    { Name = "Respawn Character", Callback = function() respawnLocalCharacter(); hubNotify("Yasia", "Respawn requested", 2) end },
    { Name = "Rejoin Same Server", Callback = function() if not tryRejoinSameServer() then hubNotify("Yasia", "Rejoin unavailable", 3, true) end end },
    { Name = "Server Hop", Callback = function() if not tryServerHop() then hubNotify("Yasia", "Server hop unavailable", 3, true) end end },
    { Name = "Anchor Character", Callback = function() if setRootAnchored(true) then hubNotify("Yasia", "Character anchored", 2) end end },
    { Name = "Unanchor Character", Callback = function() if setRootAnchored(false) then hubNotify("Yasia", "Character unanchored", 2) end end },
})
end

do
local yasiaEsp = pageESP:Section({ Name = "Yasia Hub | Vision Pack", Icon = "eye", Side = 1 })
addActionButtons(yasiaEsp, {
    { Name = "Health ESP Preset", Callback = function() startESP(); espShowBox = false; espShowText = true; espShowHealthBar = true; espShowDistance = false; espShowTracer = false; espShowHeadDot = false; espShowHealthText = true; hubNotify("ESP", "Health preset applied", 2) end },
    { Name = "Tracer Combat Preset", Callback = function() startESP(); espShowBox = true; espShowText = true; espShowHealthBar = false; espShowDistance = true; espShowTracer = true; espShowHeadDot = true; hubNotify("ESP", "Tracer preset applied", 2) end },
    { Name = "DisplayName ESP", Callback = function() startESP(); espUseDisplayName = true; espShowText = true; hubNotify("ESP", "DisplayName mode enabled", 2) end },
    { Name = "Hide Teammates ESP", Callback = function() startESP(); espHideTeammates = true; espTeamColor = true; hubNotify("ESP", "Teammates hidden from ESP", 2) end },
    { Name = "Reset ESP Filters", Callback = function() espUseDisplayName = false; espHideTeammates = false; espOnlyAlive = true; espRainbow = false; HighlightSettings.Enabled = false; HighlightSettings.Rainbow = false; updatePlayerHighlights(); hubNotify("ESP", "ESP filters reset", 2) end },
})
end

do
local yasiaMove = pageMovement:Section({ Name = "Yasia Hub | Motion Pack", Icon = "move", Side = 2 })
addActionButtons(yasiaMove, {
    { Name = "Turbo Sprint", Callback = function() setWalkSpeed(60); setJumpPower(90); setGravity(196.2); hubNotify("Move", "Turbo sprint applied", 2) end },
    { Name = "Sky Jump", Callback = function() setWalkSpeed(28); setJumpPower(160); setGravity(100); hubNotify("Move", "Sky jump applied", 2) end },
    { Name = "Heavy Mode", Callback = function() setWalkSpeed(18); setJumpPower(45); setGravity(260); hubNotify("Move", "Heavy mode applied", 2) end },
    { Name = "Auto Rotate Nearest ON", Callback = function() MovementSettings.AutoRotateNearest = true; hubNotify("Move", "Auto rotate nearest enabled", 2) end },
    { Name = "Auto Rotate Nearest OFF", Callback = function() MovementSettings.AutoRotateNearest = false; hubNotify("Move", "Auto rotate nearest disabled", 2) end },
    { Name = "Stop Movement Systems", Callback = function() stopCoreMovementStates(); hubNotify("Move", "Movement systems stopped", 2) end },
})
end

do
local yasiaCombat = pageCombat:Section({ Name = "Yasia Hub | Combat Pack", Icon = "crosshair", Side = 2 })
addActionButtons(yasiaCombat, {
    { Name = "Target Nearest Enemy", Callback = function() local plr = getNearestPlayer(3000, true); if plr and assignTargetPlayer(plr) then CombatSettings.TargetLockEnabled = true; hubNotify("Combat", "Targeted: " .. plr.Name, 2) end end },
    { Name = "Target Farthest Enemy", Callback = function() local plr = getFarthestPlayer(6000, true); if plr and assignTargetPlayer(plr) then CombatSettings.TargetLockEnabled = true; hubNotify("Combat", "Targeted: " .. plr.Name, 2) end end },
    { Name = "Face Current Lock", Callback = function() local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName); if plr then facePlayer(plr); hubNotify("Combat", "Facing: " .. plr.Name, 2) end end },
    { Name = "Aggro Preset", Callback = function() CombatSettings.AimAssist = true; CombatSettings.Triggerbot = true; CombatSettings.AutoToolSpam = true; CombatSettings.TeamCheck = false; CombatSettings.Reach = 3; hubNotify("Combat", "Aggro preset applied", 2) end },
    { Name = "Safe PvP Preset", Callback = function() CombatSettings.AimAssist = true; CombatSettings.Triggerbot = false; CombatSettings.AutoToolSpam = false; CombatSettings.TeamCheck = true; CombatSettings.Reach = 1.5; hubNotify("Combat", "Safe PvP preset applied", 2) end },
    { Name = "Hard Reset Combat", Callback = function() PresetActions.resetCombat(); CombatSettings.TargetLockEnabled = false; CombatSettings.TargetLockName = ""; syncDropdownValue(RuntimeRefs.CombatTargetDropdown, ""); hubNotify("Combat", "Combat reset", 2) end },
})
end

do
local yasiaMisc = pageMisc:Section({ Name = "Yasia Hub | World Pack", Icon = "sun", Side = 2 })
addActionButtons(yasiaMisc, {
    { Name = "Sunset Preset", Callback = function() setClockTime(18); setBrightnessValue(1.4); setNoFog(false); hubNotify("World", "Sunset preset applied", 2) end },
    { Name = "Deep Night Preset", Callback = function() setClockTime(2); setBrightnessValue(0.3); setNoFog(false); hubNotify("World", "Deep night preset applied", 2) end },
    { Name = "Ultra Low Graphics", Callback = function() applyLowGraphics(); hubNotify("World", "Ultra low graphics applied", 2) end },
    { Name = "Unlock Zoom ON", Callback = function() setUnlockZoom(true); hubNotify("World", "Zoom unlocked", 2) end },
    { Name = "Restore World State", Callback = function() restoreGraphics(); resetWorldVisualState(); setUnlockZoom(false); hubNotify("World", "World state restored", 2) end },
})
end

do
local yasiaFun = pageFun:Section({ Name = "Yasia Hub | Fun Plus", Icon = "party-popper", Side = 2 })
addActionButtons(yasiaFun, {
    { Name = "Rocket Jump Burst", Callback = function() performRocketJump(); hubNotify("Fun", "Rocket jump burst", 2) end },
    { Name = "Bounce ON", Callback = function() FunSettings.Bounce = true; hubNotify("Fun", "Bounce enabled", 2) end },
    { Name = "Bounce OFF", Callback = function() FunSettings.Bounce = false; hubNotify("Fun", "Bounce disabled", 2) end },
    { Name = "Dance Combo", Callback = function() playLocalAnimation("507771019"); task.delay(1.1, function() pcall(function() playLocalAnimation("507776043") end) end); hubNotify("Fun", "Dance combo started", 2) end },
    { Name = "Random Character Color", Callback = function() setRandomCharacterColor(); hubNotify("Fun", "Random color applied", 2) end },
    { Name = "Stop Fun Effects", Callback = function() stopFunEffects(); hubNotify("Fun", "Fun effects stopped", 2) end },
})
end

do
local yasiaUtility = pageUtility:Section({ Name = "Yasia Hub | Utility Pack", Icon = "tool", Side = 1 })
addActionButtons(yasiaUtility, {
    { Name = "Copy Player List", Callback = function() local text = getPlayersListText(); local copied = tryCopyText(text); hubNotify("Utility", copied and "Player list copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Server Summary", Callback = function() local text = getServerSummaryText(); local copied = tryCopyText(text); hubNotify("Utility", copied and "Server summary copied" or text, copied and 2 or 5, true) end },
    { Name = "Refresh Player Lists", Callback = function() if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end; hubNotify("Utility", "Player lists refreshed", 2) end },
    { Name = "Print Current Position", Callback = function() local root = getRootPart(); if root then print("[" .. HUB_TAG .. "] Position:", root.Position); hubNotify("Utility", "Position printed to console", 2, true) end end },
    { Name = "Nearby Scan 800", Callback = function() local c = scanNearbyCounts(800); hubNotify("Utility", string.format("P:%d C:%d T:%d S:%d Sp:%d", c.prompts, c.clicks, c.tools, c.seats, c.spawns), 4, true) end },
    { Name = "Anchor Toggle", Callback = function() local root = getRootPart(); if root then root.Anchored = not root.Anchored; hubNotify("Utility", "Anchored: " .. tostring(root.Anchored), 2) end end },
})
end

do
local yasiaFarm = pageFarm:Section({ Name = "Yasia Hub | Farm Pack", Icon = "pickaxe", Side = 2 })
addActionButtons(yasiaFarm, {
    { Name = "Loot Runner Preset", Callback = function() FarmSettings.AutoEnabled = true; FarmSettings.PromptEnabled = true; FarmSettings.ClickEnabled = true; FarmSettings.TouchEnabled = true; FarmSettings.AutoCollectTools = true; FarmSettings.TeleportToTargets = true; FarmSettings.IgnorePlayers = true; FarmSettings.PreferNearest = true; FarmSettings.Interval = 0.15; FarmSettings.MaxPerCycle = 6; hubNotify("Farm", "Loot runner preset applied", 2) end },
    { Name = "Nearby Safe Preset", Callback = function() FarmSettings.AutoEnabled = true; FarmSettings.PromptEnabled = true; FarmSettings.ClickEnabled = false; FarmSettings.TouchEnabled = false; FarmSettings.AutoCollectTools = false; FarmSettings.TeleportToTargets = false; FarmSettings.Interval = 0.25; FarmSettings.MaxPerCycle = 4; hubNotify("Farm", "Nearby safe preset applied", 2) end },
    { Name = "Teleport Farm ON", Callback = function() FarmSettings.TeleportToTargets = true; hubNotify("Farm", "Teleport farm enabled", 2) end },
    { Name = "Teleport Farm OFF", Callback = function() FarmSettings.TeleportToTargets = false; hubNotify("Farm", "Teleport farm disabled", 2) end },
    { Name = "Run Double Farm Cycle", Callback = function() runFarmCycle(); task.wait(0.1); runFarmCycle(); hubNotify("Farm", "Double farm cycle finished", 2) end },
    { Name = "Disable All Farm", Callback = function() FarmSettings.AutoEnabled = false; FarmSettings.PromptEnabled = false; FarmSettings.ClickEnabled = false; FarmSettings.TouchEnabled = false; FarmSettings.AutoCollectTools = false; FarmSettings.TeleportToTargets = false; hubNotify("Farm", "All farm systems disabled", 2) end },
})
end

do
local yasiaTp = pageTeleports:Section({ Name = "Yasia Hub | TP Pack", Icon = "map-pin", Side = 2 })
addActionButtons(yasiaTp, {
    { Name = "TP Up +50", Callback = function() teleportByOffset(Vector3.new(0, 50, 0)); hubNotify("TP", "Teleported up", 2) end },
    { Name = "TP Down -20", Callback = function() teleportByOffset(Vector3.new(0, -20, 0)); hubNotify("TP", "Teleported down", 2) end },
    { Name = "TP Forward +25", Callback = function() local root = getRootPart(); if root then teleportLocalTo(root.CFrame + root.CFrame.LookVector * 25); hubNotify("TP", "Teleported forward", 2) end end },
    { Name = "TP Nearest Player", Callback = function() local plr = getNearestPlayer(5000, false); if plr then teleportToPlayer(plr); hubNotify("TP", "Teleported to: " .. plr.Name, 2) end end },
    { Name = "TP Farthest Player", Callback = function() local plr = getFarthestPlayer(10000, false); if plr then teleportToPlayer(plr); hubNotify("TP", "Teleported to: " .. plr.Name, 2) end end },
    { Name = "TP To Mouse", Callback = function() teleportToMouse(); hubNotify("TP", "Teleported to mouse", 2) end },
})
end

do
local yasiaAdmin = pageAdmin:Section({ Name = "Yasia Hub | Admin Pack", Icon = "shield", Side = 2 })
addActionButtons(yasiaAdmin, {
    { Name = "Select Nearest Player Everywhere", Callback = function() local plr = getNearestPlayer(4000, false); if plr and assignTargetPlayer(plr) then hubNotify("Admin", "Selected: " .. plr.Name, 2) end end },
    { Name = "Follow Locked Target", Callback = function() local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName); if plr then AdminSettings.FollowTarget = plr.Name; AdminSettings.FollowEnabled = true; syncDropdownValue(RuntimeRefs.AdminFollowDropdown, plr.Name); hubNotify("Admin", "Following: " .. plr.Name, 2) end end },
    { Name = "Spectate Locked Target", Callback = function() local plr = Players:FindFirstChild(CombatSettings.TargetLockName) or findPlayer(CombatSettings.TargetLockName); local hum = plr and getHumanoid(plr.Character); if plr and hum then workspace.CurrentCamera.CameraSubject = hum; AdminSettings.SpectateName = plr.Name; syncDropdownValue(RuntimeRefs.AdminSpectateDropdown, plr.Name); hubNotify("Admin", "Spectating: " .. plr.Name, 2) end end },
    { Name = "Copy Active Target", Callback = function() local name = CombatSettings.TargetLockName ~= "" and CombatSettings.TargetLockName or (AdminSettings.FollowTarget ~= "" and AdminSettings.FollowTarget or AdminSettings.SpectateName); if name ~= "" then local copied = tryCopyText(name); hubNotify("Admin", copied and "Active target copied" or name, copied and 2 or 5, true) end end },
    { Name = "Clear Admin State", Callback = function() AdminSettings.FollowEnabled = false; AdminSettings.HighlightTarget = false; AdminSettings.FollowTarget = ""; AdminSettings.SpectateName = ""; if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = getHumanoid() or workspace.CurrentCamera.CameraSubject end; hubNotify("Admin", "Admin state cleared", 2) end },
})
end

do
local yasiaVehicle = pageVehicles:Section({ Name = "Yasia Hub | Vehicle Pack", Icon = "truck", Side = 2 })
addActionButtons(yasiaVehicle, {
    { Name = "Vehicle Speed Safe", Callback = function() VehicleSystem.SpeedHackEnabled = true; VehicleSystem.SpeedHackMaxSpeed = 120; startVehicleSpeedHack(); hubNotify("Vehicle", "Vehicle speed safe preset", 2) end },
    { Name = "Vehicle Speed Max", Callback = function() VehicleSystem.SpeedHackEnabled = true; VehicleSystem.SpeedHackMaxSpeed = 300; startVehicleSpeedHack(); hubNotify("Vehicle", "Vehicle speed max preset", 2) end },
    { Name = "Shift Boost x2.5", Callback = function() VehicleSystem.ShiftBoost = true; VehicleSystem.BoostMultiplier = 2.5; hubNotify("Vehicle", "Shift boost set to x2.5", 2) end },
    { Name = "Vehicle Noclip ON", Callback = function() VehicleSystem.NoclipEnabled = true; hubNotify("Vehicle", "Vehicle noclip enabled", 2) end },
    { Name = "Vehicle Noclip OFF", Callback = function() VehicleSystem.NoclipEnabled = false; hubNotify("Vehicle", "Vehicle noclip disabled", 2) end },
    { Name = "Stop Vehicle Assists", Callback = function() VehicleSystem.SpeedHackEnabled = false; VehicleSystem.NoclipEnabled = false; VehicleSystem.FlyEnabled = false; stopVehicleSpeedHack(); disableVehicleFly(); hubNotify("Vehicle", "Vehicle assists stopped", 2) end },
})
end

do
local yasiaTouch = pageTouchFling:Section({ Name = "Yasia Hub | Touch Pack", Icon = "zap", Side = 2 })
addActionButtons(yasiaTouch, {
    { Name = "Touch Combo Safe", Callback = function() PresetActions.applyTouchFling(8000, 6000, 0.08); startTouchFling(); hubNotify("Touch Fling", "Safe combo enabled", 2) end },
    { Name = "Touch Combo Max", Callback = function() PresetActions.applyTouchFling(18000, 14000, 0.12); startTouchFling(); hubNotify("Touch Fling", "Max combo enabled", 2) end },
    { Name = "Touch + Anti-Fling", Callback = function() PresetActions.applyTouchFling(12000, 10000, 0.1); PresetActions.applyAntiFling("default"); startTouchFling(); startAntiFling(); hubNotify("Touch Fling", "Touch + anti-fling enabled", 2) end },
    { Name = "Save Safe Before Touch", Callback = function() local root = getRootPart(); if root then AntiFlingState.LastSafeCF = root.CFrame + Vector3.new(0, 3, 0); hubNotify("Touch Fling", "Safe position saved", 2) end end },
    { Name = "Stop Touch + Zero", Callback = function() stopTouchFling(); zeroCharacterMomentum(); hubNotify("Touch Fling", "Touch stopped and momentum cleared", 2) end },
})
end

do
local yasiaSafety = pageAntiFling:Section({ Name = "Yasia Hub | Safety Pack", Icon = "shield", Side = 2 })
addActionButtons(yasiaSafety, {
    { Name = "Panic Safe Mode", Callback = function() local root = getRootPart(); if root then AntiFlingState.LastSafeCF = root.CFrame + Vector3.new(0, 3, 0) end; PresetActions.applyAntiFling("aggressive"); startAntiFling(); zeroCharacterMomentum(); hubNotify("Anti Fling", "Panic safe mode enabled", 2) end },
    { Name = "Restore Safe Position", Callback = function() if AntiFlingState.LastSafeCF then teleportLocalTo(AntiFlingState.LastSafeCF); hubNotify("Anti Fling", "Returned to safe position", 2) end end },
    { Name = "Anchor Rescue ON", Callback = function() _G.AntiFlingConfig.anchor = true; _G.AntiFlingConfig.smart_anchor = true; hubNotify("Anti Fling", "Anchor rescue enabled", 2) end },
    { Name = "Anchor Rescue OFF", Callback = function() _G.AntiFlingConfig.anchor = false; _G.AntiFlingConfig.smart_anchor = false; hubNotify("Anti Fling", "Anchor rescue disabled", 2) end },
    { Name = "Teleport Rescue Toggle", Callback = function() _G.AntiFlingConfig.teleport = not _G.AntiFlingConfig.teleport; hubNotify("Anti Fling", "Teleport rescue: " .. tostring(_G.AntiFlingConfig.teleport), 2) end },
})
end

do
local yasiaCloud = pageCloudScripts:Section({ Name = "Yasia Hub | Cloud Pack", Icon = "cloud", Side = 2 })
addActionButtons(yasiaCloud, {
    { Name = "Fetch Free Only", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.FreeOnly = true; CloudScriptsSettings.VerifiedOnly = false; CloudScriptsSettings.UniversalOnly = false; task.spawn(fetchCloudScripts); hubNotify("Cloud", "Fetching free scripts", 2) end },
    { Name = "Fetch Verified Only", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.FreeOnly = false; CloudScriptsSettings.VerifiedOnly = true; CloudScriptsSettings.UniversalOnly = false; task.spawn(fetchCloudScripts); hubNotify("Cloud", "Fetching verified scripts", 2) end },
    { Name = "Fetch Universal Only", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.FreeOnly = false; CloudScriptsSettings.VerifiedOnly = false; CloudScriptsSettings.UniversalOnly = true; task.spawn(fetchCloudScripts); hubNotify("Cloud", "Fetching universal scripts", 2) end },
    { Name = "Copy Cloud Game Name", Callback = function() local text = resolveCloudGameName(); local copied = tryCopyText(text); hubNotify("Cloud", copied and "Game name copied" or text, copied and 2 or 5, true) end },
    { Name = "Reset And Fetch", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.Max = 10; CloudScriptsSettings.SortBy = "updatedAt"; CloudScriptsSettings.Order = "desc"; CloudScriptsSettings.FreeOnly = false; CloudScriptsSettings.VerifiedOnly = false; CloudScriptsSettings.NoKey = false; CloudScriptsSettings.UniversalOnly = false; CloudScriptsSettings.HidePatched = false; task.spawn(fetchCloudScripts); hubNotify("Cloud", "Cloud filters reset and fetch started", 2) end },
})
end

do
local yasiaGallery = pageGallery:Section({ Name = "Yasia Hub | Gallery Pack", Icon = "image", Side = 1 })
addActionButtons(yasiaGallery, {
    { Name = "Copy Last Asset", Callback = function() local pick = GallerySettings.Images[#GallerySettings.Images]; if pick then local copied = tryCopyText(pick.AssetId); hubNotify("Gallery", copied and "Last asset copied" or pick.AssetId, copied and 2 or 5, true) end end },
    { Name = "Copy Asset Names", Callback = function() local names = {}; for _, item in ipairs(GallerySettings.Images) do table.insert(names, tostring(item.Name or "")) end; local text = table.concat(names, ", "); local copied = tryCopyText(text); hubNotify("Gallery", copied and "Asset names copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy All Asset IDs", Callback = function() local ids = {}; for _, item in ipairs(GallerySettings.Images) do table.insert(ids, tostring(item.AssetId or "")) end; local text = table.concat(ids, ", "); local copied = tryCopyText(text); hubNotify("Gallery", copied and "All asset IDs copied" or text, copied and 2 or 5, true) end },
    { Name = "Random Dual Notify", Callback = function() if #GallerySettings.Images >= 2 then local rng = Random.new(); local a = GallerySettings.Images[rng:NextInteger(1, #GallerySettings.Images)]; local b = GallerySettings.Images[rng:NextInteger(1, #GallerySettings.Images)]; galleryNotify("Gallery", tostring(a.Name) .. " + " .. tostring(b.Name), 3) end end },
    { Name = "Copy First Two IDs", Callback = function() if #GallerySettings.Images >= 2 then local text = tostring(GallerySettings.Images[1].AssetId) .. ", " .. tostring(GallerySettings.Images[2].AssetId); local copied = tryCopyText(text); hubNotify("Gallery", copied and "First two IDs copied" or text, copied and 2 or 5, true) end end },
})
end

do
local yasiaSettings = pageSettings:Section({ Name = "Yasia Hub | Instant Controls", Icon = "settings", Side = 1 })
addActionButtons(yasiaSettings, {
    { Name = "Language -> RU", Callback = function() Translations.Current = "ru"; setStoredValue(ENV_KEYS.Language, ENV_KEYS.LegacyLanguage, "ru"); updateAimbotStatusLabel(); updateTpBindStatusLabel(); updateChatStatusLabel(); hubNotify("Settings", "Language set to Russian", 2, true) end },
    { Name = "Language -> UK", Callback = function() Translations.Current = "uk"; setStoredValue(ENV_KEYS.Language, ENV_KEYS.LegacyLanguage, "uk"); updateAimbotStatusLabel(); updateTpBindStatusLabel(); updateChatStatusLabel(); hubNotify("Settings", "Language set to Ukrainian", 2, true) end },
    { Name = "Language -> EN", Callback = function() Translations.Current = "en"; setStoredValue(ENV_KEYS.Language, ENV_KEYS.LegacyLanguage, "en"); updateAimbotStatusLabel(); updateTpBindStatusLabel(); updateChatStatusLabel(); hubNotify("Settings", "Language set to English", 2, true) end },
    { Name = "Quiet Load ON", Callback = function() MainSettings.QuietLoad = true; setStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, true); hubNotify("Settings", "Quiet load enabled", 2, true) end },
    { Name = "Quiet Load OFF", Callback = function() MainSettings.QuietLoad = false; setStoredValue(ENV_KEYS.QuietLoad, ENV_KEYS.LegacyQuietLoad, false); hubNotify("Settings", "Quiet load disabled", 2, true) end },
    { Name = "Copy Current Theme", Callback = function() local copied = tryCopyText(tostring(YasiaHubSettings.Theme)); hubNotify("Settings", copied and "Theme copied" or tostring(YasiaHubSettings.Theme), copied and 2 or 5, true) end },
    { Name = "Reset Move + Visual + Combat", Callback = function() PresetActions.resetMovement(); PresetActions.resetVisual(); PresetActions.resetCombat(); stopFunEffects(); hubNotify("Settings", "Core packs reset", 2, true) end },
})
end

do
local hubControl = pageSettings:Section({ Name = "Yasia Hub | Control Center", Icon = "tool", Side = 1 })
addActionButtons(hubControl, {
    { Name = "Show Hub Summary", Callback = function() hubNotify("Yasia Hub", getHubSessionSummaryText(), 5, true) end },
    { Name = "Copy Hub Summary", Callback = function() local text = getHubSessionSummaryText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Hub summary copied" or text, copied and 2 or 5, true) end },
    { Name = "Refresh Player Lists", Callback = function() if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end; hubNotify("Settings", "Player lists refreshed", 2, true) end },
    { Name = "Reapply Current Theme", Callback = function() applyAccentTheme(YasiaHubSettings.Theme); hubNotify("Settings", "Theme reapplied: " .. tostring(YasiaHubSettings.Theme), 2, true) end },
    { Name = "Show Welcome Notice", Callback = function() hubNotify(T("title"), T("msg_loaded") .. " " .. LP.Name, 4, true) end },
})
end

do
local hubSessionTools = pageSettings:Section({ Name = "Yasia Hub | Session Tools", Icon = "clipboard", Side = 2 })
addActionButtons(hubSessionTools, {
    { Name = "Copy Server Summary", Callback = function() local text = getServerSummaryText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Server summary copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Player List", Callback = function() local text = getPlayersListText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Player list copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Saved Slots Status", Callback = function() local text = getSavedSlotsSummaryText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Slot summary copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Place + Job IDs", Callback = function() local text = "PlaceId=" .. tostring(game.PlaceId) .. " | JobId=" .. tostring(game.JobId); local copied = tryCopyText(text); hubNotify("Settings", copied and "Place and Job IDs copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Position Snapshot", Callback = function() local text = getCompactPositionText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Position copied" or text, copied and 2 or 5, true) end },
})
end

do
local settingsTravel = pageSettings:Section({ Name = "Yasia Hub | Quick Travel", Icon = "map-pin", Side = 1 })
addActionButtons(settingsTravel, {
    { Name = "Save Last Position", Callback = function() rememberCurrentPosition(); hubNotify("Settings", "Last position saved", 2, true) end },
    { Name = "Back To Last Position", Callback = function() if TeleportSettings.LastCF then teleportLocalTo(TeleportSettings.LastCF); hubNotify("Settings", "Returned to last position", 2, true) else hubNotify("Settings", "No last position saved", 2, true) end end },
    { Name = "Save Slot 1", Callback = function() savePositionSlot(1); hubNotify("Settings", "Slot 1 saved", 2, true) end },
    { Name = "Load Slot 1", Callback = function() loadPositionSlot(1); hubNotify("Settings", TeleportSettings.Slots[1] and "Slot 1 loaded" or "Slot 1 is empty", 2, true) end },
    { Name = "Save Slot 2", Callback = function() savePositionSlot(2); hubNotify("Settings", "Slot 2 saved", 2, true) end },
    { Name = "Load Slot 2", Callback = function() loadPositionSlot(2); hubNotify("Settings", TeleportSettings.Slots[2] and "Slot 2 loaded" or "Slot 2 is empty", 2, true) end },
    { Name = "Save Slot 3", Callback = function() savePositionSlot(3); hubNotify("Settings", "Slot 3 saved", 2, true) end },
    { Name = "Load Slot 3", Callback = function() loadPositionSlot(3); hubNotify("Settings", TeleportSettings.Slots[3] and "Slot 3 loaded" or "Slot 3 is empty", 2, true) end },
    { Name = "Seat Nearest Seat", Callback = function() seatInNearestSeat(); hubNotify("Settings", "Moving to nearest seat", 2, true) end },
})
end

do
local settingsRecovery = pageSettings:Section({ Name = "Yasia Hub | Recovery Tools", Icon = "shield", Side = 1 })
addActionButtons(settingsRecovery, {
    { Name = "Zero Momentum", Callback = function() zeroCharacterMomentum(); hubNotify("Settings", "Momentum cleared", 2, true) end },
    { Name = "Stop Fun Effects", Callback = function() stopFunEffects(); hubNotify("Settings", "Fun effects stopped", 2, true) end },
    { Name = "Stop Touch + Zero", Callback = function() stopTouchFling(); zeroCharacterMomentum(); hubNotify("Settings", "Touch stopped and momentum cleared", 2, true) end },
    { Name = "Enable Anti Fling", Callback = function() startAntiFling(); hubNotify("Settings", "Anti fling enabled", 2, true) end },
    { Name = "Reset Core Packs", Callback = function() PresetActions.resetMovement(); PresetActions.resetVisual(); PresetActions.resetCombat(); stopFunEffects(); hubNotify("Settings", "Core packs reset", 2, true) end },
})
end

do
local settingsMedia = pageSettings:Section({ Name = "Yasia Hub | Cloud + Gallery", Icon = "cloud", Side = 2 })
addActionButtons(settingsMedia, {
    { Name = "Fetch Free Only", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.FreeOnly = true; CloudScriptsSettings.VerifiedOnly = false; CloudScriptsSettings.UniversalOnly = false; task.spawn(fetchCloudScripts); hubNotify("Settings", "Fetching free scripts", 2, true) end },
    { Name = "Fetch Verified Only", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.FreeOnly = false; CloudScriptsSettings.VerifiedOnly = true; CloudScriptsSettings.UniversalOnly = false; task.spawn(fetchCloudScripts); hubNotify("Settings", "Fetching verified scripts", 2, true) end },
    { Name = "Fetch Universal Only", Callback = function() CloudScriptsSettings.Page = 1; CloudScriptsSettings.FreeOnly = false; CloudScriptsSettings.VerifiedOnly = false; CloudScriptsSettings.UniversalOnly = true; task.spawn(fetchCloudScripts); hubNotify("Settings", "Fetching universal scripts", 2, true) end },
    { Name = "Copy Cloud Game Name", Callback = function() local text = resolveCloudGameName(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Cloud game name copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy Last Asset", Callback = function() local pick = GallerySettings.Images[#GallerySettings.Images]; if pick then local copied = tryCopyText(pick.AssetId); hubNotify("Settings", copied and "Last asset copied" or pick.AssetId, copied and 2 or 5, true) end end },
    { Name = "Copy Fresh Pack IDs", Callback = function() local ids = {}; for i = 17, math.min(#GallerySettings.Images, 23) do table.insert(ids, tostring(GallerySettings.Images[i].AssetId or "")) end; local text = table.concat(ids, ", "); local copied = tryCopyText(text); hubNotify("Settings", copied and "Fresh pack ids copied" or text, copied and 2 or 5, true) end },
    { Name = "Show Fresh Pack Notify", Callback = function() local pick = GallerySettings.Images[16 + Random.new():NextInteger(1, 7)]; if pick then galleryNotify("Fresh Pack", tostring(pick.Name) .. " | " .. tostring(pick.AssetId), 3) end end },
    { Name = "Copy Asset Names", Callback = function() local names = {}; for _, item in ipairs(GallerySettings.Images) do table.insert(names, tostring(item.Name or "")) end; local text = table.concat(names, ", "); local copied = tryCopyText(text); hubNotify("Settings", copied and "Asset names copied" or text, copied and 2 or 5, true) end },
    { Name = "Copy All Asset IDs", Callback = function() local ids = {}; for _, item in ipairs(GallerySettings.Images) do table.insert(ids, tostring(item.AssetId or "")) end; local text = table.concat(ids, ", "); local copied = tryCopyText(text); hubNotify("Settings", copied and "All asset IDs copied" or text, copied and 2 or 5, true) end },
})
end

do
local settingsHud = pageSettings:Section({ Name = "Yasia Hub | HUD", Icon = "monitor", Side = 2 })
settingsHud:Label("HUD toggle key: HOME")
addActionButtons(settingsHud, {
    { Name = "HUD ON", Callback = function() setHudEnabled(true); hubNotify("HUD", "HUD enabled", 2, true) end },
    { Name = "HUD OFF", Callback = function() setHudEnabled(false); hubNotify("HUD", "HUD disabled", 2, true) end },
    { Name = "HUD TOGGLE", Callback = function() setHudEnabled(not MainSettings.HudEnabled); hubNotify("HUD", MainSettings.HudEnabled and "HUD enabled" or "HUD disabled", 2, true) end },
    { Name = "HUD REFRESH", Callback = function() renderHud(); hubNotify("HUD", MainSettings.HudEnabled and "HUD refreshed" or "HUD is off", 2, true) end },
    { Name = "COPY HUD MODULES", Callback = function() local modules = getHudModuleList(); local text = #modules > 0 and table.concat(modules, ", ") or "No active modules"; local copied = tryCopyText(text); hubNotify("HUD", copied and "HUD module list copied" or text, copied and 2 or 5, true) end },
})
end

do
local settingsUtility = pageSettings:Section({ Name = "Yasia Hub | Quick Utility", Icon = "tool", Side = 2 })
addActionButtons(settingsUtility, {
    { Name = "REJOIN SAME SERVER", Callback = function() local ok = tryRejoinSameServer(); hubNotify("Settings", ok and "Rejoining same server" or "Rejoin is unavailable", 2, true) end },
    { Name = "SERVER HOP", Callback = function() local ok = tryServerHop(); hubNotify("Settings", ok and "Server hop started" or "Server hop is unavailable", 2, true) end },
    { Name = "COPY PLACE ID", Callback = function() local text = tostring(game.PlaceId); local copied = tryCopyText(text); hubNotify("Settings", copied and "PlaceId copied" or text, copied and 2 or 5, true) end },
    { Name = "COPY JOB ID", Callback = function() local text = tostring(game.JobId); local copied = tryCopyText(text); hubNotify("Settings", copied and "JobId copied" or text, copied and 2 or 5, true) end },
    { Name = "COPY USER ID", Callback = function() local text = tostring(LP.UserId); local copied = tryCopyText(text); hubNotify("Settings", copied and "UserId copied" or text, copied and 2 or 5, true) end },
    { Name = "EMERGENCY STOP CORE", Callback = function() stopCoreMovementStates(); stopTouchFling(); stopAntiFling(); hubNotify("Settings", "Core systems stopped", 2, true) end },
})
end

do
local settingsStartupExit = pageSettings:Section({ Name = "Yasia Hub | Startup + Exit", Icon = "power", Side = 2 })
RuntimeRefs.AutoLoadStatusLabel = settingsStartupExit:Label("Autoload after teleport: loading...")
settingsStartupExit:Label(TL(
    "Автозагрузка ставит хаб в очередь на следующий телепорт, а Exit полностью выгружает окно и системы.",
    "Автозавантаження ставить хаб у чергу на наступний телепорт, а Exit повністю вивантажує вікно та системи.",
    "Autoload queues the hub for the next teleport, and Exit fully unloads the UI and systems."
))
addActionButtons(settingsStartupExit, {
    { Name = TL("Автозагрузка ВКЛ", "Автозавантаження УВІМК", "Autoload ON"), Callback = function() setHubAutoLoadEnabled(true, false) end },
    { Name = TL("Автозагрузка ВЫКЛ", "Автозавантаження ВИМК", "Autoload OFF"), Callback = function() setHubAutoLoadEnabled(false, false) end },
    { Name = TL("Обновить очередь автозагрузки", "Оновити чергу автозавантаження", "Refresh Autoload Queue"), Callback = function() local ok = applyTeleportAutoload(false); if ok and hubNotify then hubNotify("Settings", TL("Очередь автозагрузки обновлена.", "Чергу автозавантаження оновлено.", "Autoload queue refreshed."), 2, true) end end },
    { Name = TL("Выйти из хаба", "Вийти з хаба", "Exit Hub"), Callback = function() task.defer(function() unloadYasiaHub("settings_exit") end) end },
})
updateAutoLoadStatusLabel()
end

do
local settingsChat = pageSettings:Section({ Name = "Yasia Hub | Chat Quick Tools", Icon = "message-circle", Side = 1 })
settingsChat:Label(TL(
    "Быстрый доступ к чату: основной конструктор находится на вкладке Fun.",
    "Швидкий доступ до чату: основний конструктор знаходиться на вкладці Fun.",
    "Quick chat access: the full builder lives on the Fun tab."
))
addActionButtons(settingsChat, {
    { Name = TL("Отправить 1 раз", "Надіслати 1 раз", "Send Once"), Callback = function() local sent, message = pushChatMessage(); hubNotify(TL("Чат", "Чат", "Chat"), sent and (TL("Отправлено", "Надіслано", "Sent") .. ": " .. tostring(message)) or TL("Не удалось отправить сообщение", "Не вдалося надіслати повідомлення", "Failed to send message"), 2, true) end },
    { Name = TL("Burst xN", "Burst xN", "Burst xN"), Callback = function() sendChatBurst(ChatSettings.BurstCount) end },
    { Name = TL("Чат-луп ВКЛ", "Чат-луп УВІМК", "Chat Loop ON"), Callback = function() setChatLoopEnabled(true); hubNotify(TL("Чат", "Чат", "Chat"), TL("Чат-луп включён", "Чат-луп увімкнено", "Chat loop enabled"), 2, true) end },
    { Name = TL("Чат-луп ВЫКЛ", "Чат-луп ВИМК", "Chat Loop OFF"), Callback = function() setChatLoopEnabled(false); hubNotify(TL("Чат", "Чат", "Chat"), TL("Чат-луп выключен", "Чат-луп вимкнено", "Chat loop disabled"), 2, true) end },
    { Name = TL("Загрузить Friendly Pack", "Завантажити Friendly Pack", "Load Friendly Pack"), Callback = function() if applyChatPreset("Friendly") then hubNotify(TL("Чат", "Чат", "Chat"), TL("Загружен набор Friendly", "Завантажено набір Friendly", "Loaded Friendly pack"), 2, true) end end },
    { Name = TL("Загрузить Yasia Pack", "Завантажити Yasia Pack", "Load Yasia Pack"), Callback = function() if applyChatPreset("Yasia") then hubNotify(TL("Чат", "Чат", "Chat"), TL("Загружен набор Yasia", "Завантажено набір Yasia", "Loaded Yasia pack"), 2, true) end end },
    { Name = TL("Скопировать чат-пак", "Скопіювати чат-пак", "Copy Chat Pack"), Callback = function() local text = tostring(ChatSettings.MessageSource or ""); local copied = tryCopyText(text); hubNotify(TL("Чат", "Чат", "Chat"), copied and TL("Чат-пак скопирован", "Чат-пак скопійовано", "Chat pack copied") or text, copied and 2 or 5, true) end },
})
end

do
local settingsChatPlus = pageSettings:Section({ Name = "Yasia Hub | Chat Studio", Icon = "message-circle", Side = 1 })
settingsChatPlus:Label(TL(
    "Чистые чат-инструменты: пресеты, копирование статуса и быстрый запуск цикла без транслита.",
    "Чисті чат-інструменти: пресети, копіювання статусу та швидкий запуск циклу без трансліту.",
    "Clean chat tools: presets, status copy, and quick loop controls without translit."
))
addActionButtons(settingsChatPlus, {
    { Name = TL("Отправить один раз", "Надіслати один раз", "Send Once"), Callback = function() local sent, message = pushChatMessage(); hubNotify(TL("Чат", "Чат", "Chat"), sent and (TL("Отправлено", "Надіслано", "Sent") .. ": " .. tostring(message)) or TL("Не удалось отправить сообщение", "Не вдалося надіслати повідомлення", "Failed to send message"), 2, true) end },
    { Name = "Burst xN", Callback = function() sendChatBurst(ChatSettings.BurstCount) end },
    { Name = TL("Chat Loop ON", "Chat Loop ON", "Chat Loop ON"), Callback = function() setChatLoopEnabled(true); hubNotify(TL("Чат", "Чат", "Chat"), TL("Чат-луп включён", "Чат-луп увімкнено", "Chat loop enabled"), 2, true) end },
    { Name = TL("Chat Loop OFF", "Chat Loop OFF", "Chat Loop OFF"), Callback = function() setChatLoopEnabled(false); hubNotify(TL("Чат", "Чат", "Chat"), TL("Чат-луп выключен", "Чат-луп вимкнено", "Chat loop disabled"), 2, true) end },
    { Name = TL("Загрузить Friendly Pack", "Завантажити Friendly Pack", "Load Friendly Pack"), Callback = function() if applyChatPreset("Friendly") then hubNotify(TL("Чат", "Чат", "Chat"), TL("Загружен Friendly pack", "Завантажено Friendly pack", "Loaded Friendly pack"), 2, true) end end },
    { Name = TL("Загрузить Yasia Pack", "Завантажити Yasia Pack", "Load Yasia Pack"), Callback = function() if applyChatPreset("Yasia") then hubNotify(TL("Чат", "Чат", "Chat"), TL("Загружен Yasia pack", "Завантажено Yasia pack", "Loaded Yasia pack"), 2, true) end end },
    { Name = TL("Загрузить Trade Pack", "Завантажити Trade Pack", "Load Trade Pack"), Callback = function() if applyChatPreset("Trade") then hubNotify(TL("Чат", "Чат", "Chat"), TL("Загружен Trade pack", "Завантажено Trade pack", "Loaded Trade pack"), 2, true) end end },
    { Name = TL("Загрузить Farm Pack", "Завантажити Farm Pack", "Load Farm Pack"), Callback = function() if applyChatPreset("Farm") then hubNotify(TL("Чат", "Чат", "Chat"), TL("Загружен Farm pack", "Завантажено Farm pack", "Loaded Farm pack"), 2, true) end end },
    { Name = TL("Копировать чат-пак", "Копіювати чат-пак", "Copy Chat Pack"), Callback = function() local text = tostring(ChatSettings.MessageSource or ""); local copied = tryCopyText(text); hubNotify(TL("Чат", "Чат", "Chat"), copied and TL("Чат-пак скопирован", "Чат-пак скопійовано", "Chat pack copied") or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать статус чата", "Копіювати статус чату", "Copy Chat Status"), Callback = function() local text = getChatStatusText(); local copied = tryCopyText(text); hubNotify(TL("Чат", "Чат", "Chat"), copied and TL("Статус чата скопирован", "Статус чату скопійовано", "Chat status copied") or text, copied and 2 or 5, true) end },
})
end

do
local mainStatus = pageMain:Section({ Name = "Yasia Hub | Live Status", Icon = "monitor", Side = 2 })
RuntimeRefs.MainLiveLabel = mainStatus:Label("Live status: loading...")
mainStatus:Label(TL(
    "Здесь можно быстро снять live-статус, summary и подсказки для безопасного старта.",
    "Тут можна швидко зняти live-статус, summary та підказки для безпечного старту.",
    "Use this block for live status, summaries, and safe-start tips."
))
addActionButtons(mainStatus, {
    { Name = TL("Копировать live-статус", "Копіювати live-статус", "Copy Live Status"), Callback = function() local text = getLiveStatusText(); local copied = tryCopyText(text); hubNotify("Main", copied and "Live status copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать summary сессии", "Копіювати summary сесії", "Copy Session Summary"), Callback = function() local text = getHubSessionSummaryText(); local copied = tryCopyText(text); hubNotify("Main", copied and "Session summary copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать координаты", "Копіювати координати", "Copy Coords"), Callback = function() local text = getCompactPositionText(); local copied = tryCopyText(text); hubNotify("Main", copied and "Coords copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Обновить статус", "Оновити статус", "Refresh Status"), Callback = function() refreshLiveStatusLabels(); hubNotify("Main", "Live status refreshed", 2, true) end },
    { Name = TL("Показать советы", "Показати поради", "Show Tips"), Callback = function() showBeginnerTipsNotice() end },
})
end

do
local settingsDiagnostics = pageSettings:Section({ Name = "Yasia Hub | Diagnostics", Icon = "clipboard", Side = 2 })
RuntimeRefs.SettingsLiveLabel = settingsDiagnostics:Label("Live status: loading...")
RuntimeRefs.DiagnosticsLabel = settingsDiagnostics:Label("Diagnostics: loading...")
addActionButtons(settingsDiagnostics, {
    { Name = TL("Обновить диагностику", "Оновити діагностику", "Refresh Diagnostics"), Callback = function() refreshLiveStatusLabels(); hubNotify("Settings", "Diagnostics refreshed", 2, true) end },
    { Name = TL("Копировать диагностику", "Копіювати діагностику", "Copy Diagnostics"), Callback = function() local text = getHubDiagnosticsText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Diagnostics copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать visual snapshot", "Копіювати visual snapshot", "Copy Visual Snapshot"), Callback = function() local text = getVisualSnapshotText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Visual snapshot copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать movement snapshot", "Копіювати movement snapshot", "Copy Movement Snapshot"), Callback = function() local text = getMovementSnapshotText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Movement snapshot copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать combat snapshot", "Копіювати combat snapshot", "Copy Combat Snapshot"), Callback = function() local text = getCombatSnapshotText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Combat snapshot copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать farm snapshot", "Копіювати farm snapshot", "Copy Farm Snapshot"), Callback = function() local text = getFarmSnapshotText(); local copied = tryCopyText(text); hubNotify("Settings", copied and "Farm snapshot copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать все gallery ID", "Копіювати всі gallery ID", "Copy All Gallery IDs"), Callback = function() local text = getGalleryIdsText(false); local copied = tryCopyText(text); hubNotify("Settings", copied and "Gallery IDs copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Копировать fresh gallery ID", "Копіювати fresh gallery ID", "Copy Fresh Gallery IDs"), Callback = function() local text = getGalleryIdsText(true); local copied = tryCopyText(text); hubNotify("Settings", copied and "Fresh gallery IDs copied" or text, copied and 2 or 5, true) end },
    { Name = TL("Тема: следующий акцент", "Тема: наступний акцент", "Theme: Next Accent"), Callback = function() cycleAccentTheme(1) end },
    { Name = TL("Тема: предыдущий акцент", "Тема: попередній акцент", "Theme: Previous Accent"), Callback = function() cycleAccentTheme(-1) end },
})
end

if type(GlobalState.OriginalLibraryUnload) == "function" and not GlobalState.LibraryUnloadProxyInstalled then
    Library.Unload = function()
        return unloadYasiaHub("window_close")
    end
    GlobalState.LibraryUnloadProxyInstalled = true
end

pcall(function()
    Window:Init()
    uiReady = true

    task.defer(function()
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        if refreshAllPlayerDropdowns then
            refreshAllPlayerDropdowns()
        end
        for _, entry in ipairs(slidersToReset) do
            pcall(function()
                if entry.s and entry.s.Set and type(entry.d) == "number" and entry.d == entry.d then
                    entry.s:Set(entry.d, true)
                end
            end)
        end
        refreshLiveStatusLabels()
        updateAutoLoadStatusLabel()
    end)

    GlobalState.MainPlayerAddedConnection = Players.PlayerAdded:Connect(function()
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end)
    GlobalState.MainPlayerRemovingConnection = Players.PlayerRemoving:Connect(function()
        if refreshAllPlayerDropdowns then refreshAllPlayerDropdowns() end
    end)

    if not MainSettings.QuietLoad then
        Library:Notification({
            Title = T("title"),
            Description = T("msg_loaded_desc"),
            Duration = 5
        })
    end

    if MainSettings.HudEnabled then
        setHudEnabled(true)
    end

    if MainSettings.AutoLoad then
        applyTeleportAutoload(true)
    end
end)

print("========================================")
print("[Info] " .. HUB_BRAND .. " loaded")
print("[Info] Core pages: UI, ESP, Movement, Utility, Farm, Settings")
print("[Info] Live status and diagnostics are ready")
print("========================================")

-- ============================================
-- 1000 NOVYKh FUNKTsIY
-- ============================================

-- DOBAVLENIE STRUKTURY KhABA S 20 VKLADKAMI
local yasiaHub = {
    tabs = {},
    metadata = {
        brand = HUB_BRAND,
        tag = HUB_TAG,
        mode = "stable",
    },
}

-- FUNKTsIYa DLYa INITsIALIZATsII VKLADOK
function yasiaHub.initTabs()
    yasiaHub.tabs = {
        { name = T("main"), content = "Quick actions and live status" },
        { name = T("visuals"), content = "ESP, highlights, and visual presets" },
        { name = T("move"), content = "Movement tools and stabilizers" },
        { name = T("combat"), content = "Combat helpers and target tools" },
        { name = T("aimbot"), content = "Aim settings and status controls" },
        { name = T("misc"), content = "World tweaks and cleanup tools" },
        { name = T("fun"), content = "Fun tools, chat presets, and effects" },
        { name = T("util"), content = "Clipboard, scans, and utility helpers" },
        { name = T("farm"), content = "Auto-farm presets and route helpers" },
        { name = T("tp"), content = "Teleport shortcuts and saved positions" },
        { name = T("admin"), content = "Follow, spectate, and camera tools" },
        { name = T("car"), content = "Vehicle helpers and assist presets" },
        { name = T("touch_fling"), content = "Touch system controls" },
        { name = T("anti_fling"), content = "Safety and anti-fling recovery" },
        { name = T("gall"), content = "Gallery images and copy tools" },
        { name = T("cloud"), content = "Cloud fetch helpers and filters" },
        { name = T("settings"), content = "Themes, diagnostics, HUD, and session tools" },
    }
    return yasiaHub.tabs
end

-- FUNKTsIYa DLYa OTOBRAZhENIYa VKLADOK
function yasiaHub.showTabs()
    return yasiaHub.tabs
end

-- INITsIALIZATsIYa KhABA
yasiaHub.initTabs()
print("[" .. HUB_TAG .. "] Utility registry ready: " .. tostring(#yasiaHub.showTabs()) .. " pages.")

local Utils = {}

-- FUNKTsII 1-50: BAZOVYE UTILITY
function Utils.add(a, b) return a + b end
function Utils.sub(a, b) return a - b end
function Utils.mul(a, b) return a * b end
function Utils.div(a, b) return b ~= 0 and a / b or 0 end
function Utils.mod(a, b) return a % b end
function Utils.pow(a, b) return a ^ b end
function Utils.sqrt(a) return math.sqrt(a) end
function Utils.abs(a) return math.abs(a) end
function Utils.floor(a) return math.floor(a) end
function Utils.ceil(a) return math.ceil(a) end
function Utils.round(a) return math.floor(a + 0.5) end
function Utils.min(a, b) return a < b and a or b end
function Utils.max(a, b) return a > b and a or b end
function Utils.clamp(a, min, max) return Utils.min(Utils.max(a, min), max) end
function Utils.lerp(a, b, t) return a + (b - a) * t end
function Utils.distance(x1, y1, x2, y2) return math.sqrt((x2-x1)^2 + (y2-y1)^2) end
function Utils.getAngle(x1, y1, x2, y2) return math.atan2(y2-y1, x2-x1) end
function Utils.randomInt(min, max) return math.random(min, max) end
function Utils.randomFloat(min, max) return min + math.random() * (max - min) end
function Utils.isPositive(a) return a > 0 end
function Utils.isNegative(a) return a < 0 end
function Utils.isZero(a) return a == 0 end
function Utils.isEven(a) return a % 2 == 0 end
function Utils.isOdd(a) return a % 2 ~= 0 end
function Utils.isPrime(n) if n < 2 then return false end for i = 2, n/2 do if n % i == 0 then return false end end return true end
function Utils.factorial(n) if n <= 1 then return 1 end return n * Utils.factorial(n - 1) end
function Utils.fibonacci(n) if n <= 1 then return n end return Utils.fibonacci(n-1) + Utils.fibonacci(n-2) end
function Utils.toRadian(deg) return deg * math.pi / 180 end
function Utils.toDegree(rad) return rad * 180 / math.pi end
function Utils.sine(a) return math.sin(a) end
function Utils.cosine(a) return math.cos(a) end
function Utils.tangent(a) return math.tan(a) end
function Utils.asin(a) return math.asin(a) end
function Utils.acos(a) return math.acos(a) end
function Utils.atan(a) return math.atan(a) end
function Utils.log(a, base) return math.log(a) / math.log(base or 10) end
function Utils.ln(a) return math.log(a) end
function Utils.exp(a) return math.exp(a) end

-- FUNKTsII 51-100: RABOTA SO STROKAMI
function Utils.length(str) return string.len(str) end
function Utils.upper(str) return string.upper(str) end
function Utils.lower(str) return string.lower(str) end
function Utils.reverse(str) return string.reverse(str) end
function Utils.charAt(str, index) return string.sub(str, index, index) end
function Utils.substring(str, start, endPos) return string.sub(str, start, endPos) end
function Utils.indexOf(str, char) return string.find(str, char) or -1 end
function Utils.lastIndexOf(str, char) local _, pos = string.find(str, char, -1) return pos or -1 end
function Utils.split(str, sep) local t = {} for part in string.gmatch(str, "([^"..sep.."]+)") do table.insert(t, part) end return t end
function Utils.join(t, sep) return table.concat(t, sep) end
function Utils.trim(str) return string.gsub(str, "^%s*(.-)%s*$", "%1") end
function Utils.ltrim(str) return string.gsub(str, "^%s+", "") end
function Utils.rtrim(str) return string.gsub(str, "%s+$", "") end
function Utils.startsWith(str, prefix) return string.sub(str, 1, string.len(prefix)) == prefix end
function Utils.endsWith(str, suffix) return string.sub(str, -string.len(suffix)) == suffix end
function Utils.contains(str, sub) return string.find(str, sub) ~= nil end
function Utils.replace(str, old, new) return string.gsub(str, old, new) end
function Utils.replaceFirst(str, old, new) return string.gsub(str, old, new, 1) end
function Utils.capitalize(str) return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2) end
function Utils.capitalizeWords(str) return string.gsub(str, "%S+", function(w) return Utils.capitalize(w) end) end
function Utils.strRepeat(str, count) local result = "" for i = 1, count do result = result .. str end return result end
function Utils.padLeft(str, len, char) char = char or " " return Utils.strRepeat(char, len - string.len(str)) .. str end
function Utils.padRight(str, len, char) char = char or " " return str .. Utils.strRepeat(char, len - string.len(str)) end
function Utils.toCharArray(str) local t = {} for i = 1, string.len(str) do table.insert(t, string.sub(str, i, i)) end return t end
function Utils.fromCharArray(t) return table.concat(t, "") end
function Utils.encode(str) return string.upper(string.gsub(str, "(.)","%%%02x",str)) end
function Utils.isNumeric(str) return tonumber(str) ~= nil end
function Utils.isAlpha(str) return string.match(str, "^[a-zA-Z]+$") ~= nil end
function Utils.isAlphanumeric(str) return string.match(str, "^[a-zA-Z0-9]+$") ~= nil end

-- FUNKTsII 101-150: RABOTA S TABLITsAMI
function Utils.tableLength(t) local count = 0 for _ in pairs(t) do count = count + 1 end return count end
function Utils.tableContains(t, value) for _, v in pairs(t) do if v == value then return true end end return false end
function Utils.tableCopy(t) local copy = {} for k, v in pairs(t) do copy[k] = v end return copy end
function Utils.tableDeepCopy(t) local copy = {} for k, v in pairs(t) do copy[k] = type(v) == "table" and Utils.tableDeepCopy(v) or v end return copy end
function Utils.tableReverse(t) local reversed = {} for i = #t, 1, -1 do table.insert(reversed, t[i]) end return reversed end
function Utils.tableJoin(t1, t2) local result = Utils.tableCopy(t1) for _, v in pairs(t2) do table.insert(result, v) end return result end
function Utils.tableMerge(t1, t2) local result = Utils.tableCopy(t1) for k, v in pairs(t2) do result[k] = v end return result end
function Utils.tableFilter(t, fn) local result = {} for k, v in pairs(t) do if fn(v, k) then table.insert(result, v) end end return result end
function Utils.tableMap(t, fn) local result = {} for k, v in pairs(t) do table.insert(result, fn(v, k)) end return result end
function Utils.tableReduce(t, fn, initial) local acc = initial for _, v in pairs(t) do acc = fn(acc, v) end return acc end
function Utils.tableSome(t, fn) for _, v in pairs(t) do if fn(v) then return true end end return false end
function Utils.tableEvery(t, fn) for _, v in pairs(t) do if not fn(v) then return false end end return true end
function Utils.tableFind(t, fn) for _, v in pairs(t) do if fn(v) then return v end end return nil end
function Utils.tableFindIndex(t, fn) for i, v in pairs(t) do if fn(v) then return i end end return -1 end
function Utils.tableSort(t, fn) table.sort(t, fn) return t end
function Utils.tableUnique(t) local seen = {} local result = {} for _, v in pairs(t) do if not seen[v] then seen[v] = true table.insert(result, v) end end return result end
function Utils.tableFlat(t, depth) depth = depth or 1 if depth == 0 then return t end local result = {} for _, v in pairs(t) do if type(v) == "table" then for _, vv in pairs(Utils.tableFlat(v, depth - 1)) do table.insert(result, vv) end else table.insert(result, v) end end return result end
function Utils.tableKeys(t) local result = {} for k in pairs(t) do table.insert(result, k) end return result end
function Utils.tableValues(t) local result = {} for _, v in pairs(t) do table.insert(result, v) end return result end
function Utils.tableEntries(t) local result = {} for k, v in pairs(t) do table.insert(result, {k, v}) end return result end
function Utils.tableForEach(t, fn) for k, v in pairs(t) do fn(v, k) end end
function Utils.tableIncludes(t, value) return Utils.tableContains(t, value) end
function Utils.tableIndexOf(t, value) for i, v in pairs(t) do if v == value then return i end end return -1 end
function Utils.tableShuffle(t) for i = #t, 2, -1 do local j = math.random(i) t[i], t[j] = t[j], t[i] end return t end
function Utils.tableSum(t) return Utils.tableReduce(t, function(a, b) return a + b end, 0) end
function Utils.tableAverage(t) return #t > 0 and Utils.tableSum(t) / #t or 0 end
function Utils.tableMax(t) return Utils.tableReduce(t, function(a, b) return a > b and a or b end, -math.huge) end
function Utils.tableMin(t) return Utils.tableReduce(t, function(a, b) return a < b and a or b end, math.huge) end

-- FUNKTsII 151-200: RABOTA S Vector3
function Utils.vec3(x, y, z) return Vector3.new(x, y, z) end
function Utils.vec3Add(v1, v2) return v1 + v2 end
function Utils.vec3Sub(v1, v2) return v1 - v2 end
function Utils.vec3Mul(v, scalar) return v * scalar end
function Utils.vec3Div(v, scalar) return v / scalar end
function Utils.vec3Dot(v1, v2) return v1:Dot(v2) end
function Utils.vec3Cross(v1, v2) return v1:Cross(v2) end
function Utils.vec3Length(v) return v.Magnitude end
function Utils.vec3Normalize(v) return v.Unit end
function Utils.vec3Distance(v1, v2) return (v1 - v2).Magnitude end
function Utils.vec3Lerp(v1, v2, t) return v1:Lerp(v2, t) end
function Utils.vec3Rotate(v, angle, axis) local cos = math.cos(angle) local sin = math.sin(angle) return v * cos + axis:Cross(v) * sin + axis * axis:Dot(v) * (1 - cos) end
function Utils.vec3Zero() return Vector3.new(0, 0, 0) end
function Utils.vec3One() return Vector3.new(1, 1, 1) end
function Utils.vec3Up() return Vector3.new(0, 1, 0) end
function Utils.vec3Down() return Vector3.new(0, -1, 0) end
function Utils.vec3Left() return Vector3.new(-1, 0, 0) end
function Utils.vec3Right() return Vector3.new(1, 0, 0) end
function Utils.vec3Forward() return Vector3.new(0, 0, -1) end
function Utils.vec3Back() return Vector3.new(0, 0, 1) end
function Utils.vec3Angle(v1, v2) return math.acos(v1:Dot(v2) / (v1.Magnitude * v2.Magnitude)) end
function Utils.vec3Project(v, plane) return v - plane * v:Dot(plane) / plane:Dot(plane) end
function Utils.vec3Reflect(v, normal) return v - 2 * v:Dot(normal) * normal end
function Utils.vec3Min(v1, v2) return Vector3.new(math.min(v1.X, v2.X), math.min(v1.Y, v2.Y), math.min(v1.Z, v2.Z)) end
function Utils.vec3Max(v1, v2) return Vector3.new(math.max(v1.X, v2.X), math.max(v1.Y, v2.Y), math.max(v1.Z, v2.Z)) end
function Utils.vec3Clamp(v, min, max) return Utils.vec3Max(min, Utils.vec3Min(v, max)) end

-- FUNKTsII 201-250: RABOTA S Color3
function Utils.color3(r, g, b) return Color3.fromRGB(r, g, b) end
function Utils.color3HSV(h, s, v) return Color3.fromHSV(h, s, v) end
function Utils.color3White() return Color3.new(1, 1, 1) end
function Utils.color3Black() return Color3.new(0, 0, 0) end
function Utils.color3Red() return Color3.new(1, 0, 0) end
function Utils.color3Green() return Color3.new(0, 1, 0) end
function Utils.color3Blue() return Color3.new(0, 0, 1) end
function Utils.color3Yellow() return Color3.new(1, 1, 0) end
function Utils.color3Cyan() return Color3.new(0, 1, 1) end
function Utils.color3Magenta() return Color3.new(1, 0, 1) end
function Utils.color3Gray() return Color3.new(0.5, 0.5, 0.5) end
function Utils.color3Lerp(c1, c2, t) return Color3.new(c1.R + (c2.R - c1.R) * t, c1.G + (c2.G - c1.G) * t, c1.B + (c2.B - c1.B) * t) end
function Utils.color3Invert(c) return Color3.new(1 - c.R, 1 - c.G, 1 - c.B) end
function Utils.color3Brighten(c, amount) return Color3.new(math.min(1, c.R + amount), math.min(1, c.G + amount), math.min(1, c.B + amount)) end
function Utils.color3Darken(c, amount) return Color3.new(math.max(0, c.R - amount), math.max(0, c.G - amount), math.max(0, c.B - amount)) end
function Utils.color3Grayscale(c) local gray = (c.R + c.G + c.B) / 3 return Color3.new(gray, gray, gray) end
function Utils.color3Hue(c) local max = math.max(c.R, c.G, c.B) local min = math.min(c.R, c.G, c.B) if max == min then return 0 end if max == c.R then return ((c.G - c.B) / (max - min)) * 60 end if max == c.G then return (2 + (c.B - c.R) / (max - min)) * 60 end return (4 + (c.R - c.G) / (max - min)) * 60 end
function Utils.color3Saturation(c) local max = math.max(c.R, c.G, c.B) local min = math.min(c.R, c.G, c.B) if max == 0 then return 0 end return (max - min) / max end
function Utils.color3Value(c) return math.max(c.R, c.G, c.B) end
function Utils.color3Random() return Color3.new(math.random(), math.random(), math.random()) end

-- FUNKTsII 251-300: RABOTA SO VREMENEM
function Utils.getCurrentTime() return tick() end
function Utils.getUnixTime() return os.time() end
function Utils.getDeltaTime(lastTime) return tick() - lastTime end
function Utils.waitUntil(fn, timeout) local start = tick() timeout = timeout or math.huge while not fn() and tick() - start < timeout do game:GetService("RunService").Heartbeat:Wait() end end
function Utils.formatTime(seconds) local hours = math.floor(seconds / 3600) local minutes = math.floor((seconds % 3600) / 60) local secs = seconds % 60 return string.format("%02d:%02d:%02d", hours, minutes, secs) end
function Utils.secondsToTime(sec) return {hours = math.floor(sec / 3600), minutes = math.floor((sec % 3600) / 60), seconds = sec % 60} end
function Utils.timeToSeconds(h, m, s) return h * 3600 + m * 60 + s end
function Utils.isToday(timestamp) local today = os.date("*t") local thenDate = os.date("*t", timestamp) return today.year == thenDate.year and today.month == thenDate.month and today.day == thenDate.day end
function Utils.getDayOfWeek(timestamp) local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"} return days[os.date("*t", timestamp).wday] end
function Utils.getMonthName(month) local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"} return months[month] end
function Utils.addSeconds(timestamp, seconds) return timestamp + seconds end
function Utils.addMinutes(timestamp, minutes) return timestamp + minutes * 60 end

-- FUNKTsII 301-350: PROVERKI TIPOV
function Utils.isNil(value) return value == nil end
function Utils.isBoolean(value) return type(value) == "boolean" end
function Utils.isNumber(value) return type(value) == "number" end
function Utils.isString(value) return type(value) == "string" end
function Utils.isTable(value) return type(value) == "table" end
function Utils.isFunction(value) return type(value) == "function" end
function Utils.isUserdata(value) return type(value) == "userdata" end
function Utils.isThread(value) return type(value) == "thread" end
function Utils.isInteger(value) return type(value) == "number" and value == math.floor(value) end
function Utils.isFloat(value) return type(value) == "number" and value ~= math.floor(value) end
function Utils.isVector3(value) return typeof(value) == "Vector3" end
function Utils.isCFrame(value) return typeof(value) == "CFrame" end
function Utils.isColor3(value) return typeof(value) == "Color3" end
function Utils.isUDim2(value) return typeof(value) == "UDim2" end
function Utils.isInstance(value) return typeof(value) == "Instance" end
function Utils.isNotEmpty(value) return not Utils.isEmpty(value) end
function Utils.isEqual(a, b) return a == b end
function Utils.isNotEqual(a, b) return a ~= b end
function Utils.isGreater(a, b) return a > b end
function Utils.isLess(a, b) return a < b end
function Utils.isGreaterOrEqual(a, b) return a >= b end
function Utils.isLessOrEqual(a, b) return a <= b end
function Utils.isInRange(value, min, max) return value >= min and value <= max end
function Utils.isOutOfRange(value, min, max) return not Utils.isInRange(value, min, max) end

-- FUNKTsII 351-400: RABOTA S OBEKTAMI
function Utils.createObject(proto) local obj = {} if proto then for k, v in pairs(proto) do obj[k] = v end end return obj end
function Utils.objectKeys(obj) return Utils.tableKeys(obj) end
function Utils.objectValues(obj) return Utils.tableValues(obj) end
function Utils.objectEntries(obj) return Utils.tableEntries(obj) end
function Utils.objectHasKey(obj, key) return obj[key] ~= nil end
function Utils.objectGet(obj, key, default) return obj[key] or default end
function Utils.objectSet(obj, key, value) obj[key] = value return obj end
function Utils.objectDelete(obj, key) obj[key] = nil return obj end
function Utils.objectAssign(target, source) for k, v in pairs(source) do target[k] = v end return target end
function Utils.objectMerge(obj1, obj2) local result = Utils.tableCopy(obj1) return Utils.objectAssign(result, obj2) end
function Utils.objectFreeze(obj) return obj end
function Utils.objectSeal(obj) return obj end
function Utils.objectCreate(proto) return Utils.createObject(proto) end
function Utils.objectDefineProperty(obj, key, descriptor) obj[key] = descriptor.value return obj end
function Utils.objectGetOwnPropertyNames(obj) return Utils.objectKeys(obj) end
function Utils.isObject(value) return type(value) == "table" and next(value) ~= nil end

-- FUNKTsII 401-450: MATEMATIChESKIE OPERATsII
function Utils.gcd(a, b) while b ~= 0 do local temp = b b = a % b a = temp end return a end
function Utils.lcm(a, b) return (a * b) / Utils.gcd(a, b) end
function Utils.isPowerOfTwo(n) return n > 0 and (n % (n - 1)) == 0 end
function Utils.nextPowerOfTwo(n) if Utils.isPowerOfTwo(n) then return n end local p = 1 while p < n do p = p * 2 end return p end
function Utils.binomial(n, k) if k > n then return 0 end if k == 0 or k == n then return 1 end local result = 1 for i = 1, k do result = result * (n - i + 1) / i end return result end
function Utils.permutation(n, k) if k > n then return 0 end local result = 1 for i = 0, k - 1 do result = result * (n - i) end return result end
function Utils.combination(n, k) return Utils.binomial(n, k) end
function Utils.degreeToRadian(deg) return deg * math.pi / 180 end
function Utils.radianToDegree(rad) return rad * 180 / math.pi end
function Utils.sigmoid(x) return 1 / (1 + math.exp(-x)) end
function Utils.relu(x) return x > 0 and x or 0 end
function Utils.leakyRelu(x, alpha) return x > 0 and x or alpha * x end
function Utils.tanh(x) return math.tanh(x) end
function Utils.isNaN(x) return x ~= x end
function Utils.isInfinite(x) return x == math.huge or x == -math.huge end
function Utils.isFinite(x) return not (Utils.isNaN(x) or Utils.isInfinite(x)) end
function Utils.sign(x) if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end end
function Utils.truncate(x) return x >= 0 and math.floor(x) or math.ceil(x) end
function Utils.nearlyEqual(a, b, tolerance) tolerance = tolerance or 0.0001 return math.abs(a - b) < tolerance end
function Utils.degreeNormalize(deg) while deg >= 360 do deg = deg - 360 end while deg < 0 do deg = deg + 360 end return deg end
function Utils.degreeDifference(deg1, deg2) local diff = deg1 - deg2 while diff > 180 do diff = diff - 360 end while diff < -180 do diff = diff + 360 end return diff end

-- FUNKTsII 451-500: RABOTA S BITAMI
function Utils.bitAnd(a, b) local result = 0 local bit = 1 while a > 0 or b > 0 do if (a % 2 == 1) and (b % 2 == 1) then result = result + bit end a = math.floor(a / 2) b = math.floor(b / 2) bit = bit * 2 end return result end
function Utils.bitOr(a, b) local result = 0 local bit = 1 while a > 0 or b > 0 do if (a % 2 == 1) or (b % 2 == 1) then result = result + bit end a = math.floor(a / 2) b = math.floor(b / 2) bit = bit * 2 end return result end
function Utils.bitXor(a, b) local result = 0 local bit = 1 while a > 0 or b > 0 do if ((a % 2 == 1) and (b % 2 == 0)) or ((a % 2 == 0) and (b % 2 == 1)) then result = result + bit end a = math.floor(a / 2) b = math.floor(b / 2) bit = bit * 2 end return result end
function Utils.bitNot(a) return -a - 1 end
function Utils.bitLeftShift(a, n) return a * (2 ^ n) end
function Utils.bitRightShift(a, n) return math.floor(a / (2 ^ n)) end
function Utils.isBitSet(num, bit) return (Utils.bitAnd(num, 2 ^ bit)) ~= 0 end
function Utils.setBit(num, bit) return Utils.bitOr(num, 2 ^ bit) end
function Utils.clearBit(num, bit) return Utils.bitAnd(num, Utils.bitNot(2 ^ bit)) end
function Utils.toggleBit(num, bit) return Utils.bitXor(num, 2 ^ bit) end
function Utils.countBits(a) local count = 0 while a > 0 do count = count + a % 2 a = math.floor(a / 2) end return count end

-- FUNKTsII 501-550: RABOTA S MASSIVAMI
function Utils.arrayCreate(size, value) local arr = {} for i = 1, size do arr[i] = value or nil end return arr end
function Utils.arrayPush(arr, value) table.insert(arr, value) return arr end
function Utils.arrayPop(arr) return table.remove(arr) end
function Utils.arrayShift(arr) return table.remove(arr, 1) end
function Utils.arrayUnshift(arr, value) table.insert(arr, 1, value) return arr end
function Utils.arraySlice(arr, start, endPos) return Utils.tableDeepCopy({unpack(arr, start, endPos or #arr)}) end
function Utils.arraySplice(arr, start, deleteCount, ...) local args = {...} for i = 1, deleteCount do table.remove(arr, start) end for i = 1, #args do table.insert(arr, start + i - 1, args[i]) end return arr end
function Utils.arrayConcat(arr1, arr2) local result = Utils.tableCopy(arr1) for _, v in pairs(arr2) do table.insert(result, v) end return result end
function Utils.arrayJoin(arr, sep) return table.concat(arr, sep) end
function Utils.arrayReverse(arr) local result = {} for i = #arr, 1, -1 do table.insert(result, arr[i]) end return result end
function Utils.arraySort(arr, compareFn) table.sort(arr, compareFn) return arr end
function Utils.arrayFind(arr, fn) for _, v in pairs(arr) do if fn(v) then return v end end return nil end
function Utils.arrayFindIndex(arr, fn) for i, v in pairs(arr) do if fn(v) then return i end end return -1 end
function Utils.arrayFilter(arr, fn) local result = {} for _, v in pairs(arr) do if fn(v) then table.insert(result, v) end end return result end
function Utils.arrayMap(arr, fn) local result = {} for i, v in pairs(arr) do table.insert(result, fn(v, i)) end return result end
function Utils.arrayReduce(arr, fn, initial) local acc = initial for i, v in pairs(arr) do acc = fn(acc, v, i) end return acc end
function Utils.arrayForEach(arr, fn) for i, v in pairs(arr) do fn(v, i) end end
function Utils.arrayEvery(arr, fn) for _, v in pairs(arr) do if not fn(v) then return false end end return true end
function Utils.arraySome(arr, fn) for _, v in pairs(arr) do if fn(v) then return true end end return false end
function Utils.arrayIncludes(arr, value) for _, v in pairs(arr) do if v == value then return true end end return false end
function Utils.arrayIndexOf(arr, value) for i, v in pairs(arr) do if v == value then return i end end return -1 end
function Utils.arrayLastIndexOf(arr, value) for i = #arr, 1, -1 do if arr[i] == value then return i end end return -1 end
function Utils.arrayFlat(arr, depth) depth = depth or 1 if depth == 0 then return arr end local result = {} for _, v in pairs(arr) do if type(v) == "table" then for _, vv in pairs(Utils.arrayFlat(v, depth - 1)) do table.insert(result, vv) end else table.insert(result, v) end end return result end
function Utils.arrayFlatMap(arr, fn) local result = {} for i, v in pairs(arr) do local mapped = fn(v, i) if type(mapped) == "table" then for _, vv in pairs(mapped) do table.insert(result, vv) end else table.insert(result, mapped) end end return result end
function Utils.arrayCopyWithin(arr, target, start, endPos) start = start or 1 endPos = endPos or #arr local toCopy = Utils.arraySlice(arr, start, endPos) for i, v in pairs(toCopy) do arr[target + i - 1] = v end return arr end

-- FUNKTsII 551-600: GENERATORY SLUChAYNYKh ZNAChENIY
function Utils.randomBoolean() return math.random() < 0.5 end
function Utils.randomByte() return math.random(0, 255) end
function Utils.randomChar() return string.char(math.random(32, 126)) end
function Utils.randomString(length) local str = "" for i = 1, length do str = str .. Utils.randomChar() end return str end
function Utils.randomAlphanumeric(length) local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" local str = "" for i = 1, length do str = str .. string.sub(chars, math.random(1, #chars), math.random(1, #chars)) end return str end
function Utils.randomUUID() local uuid = "" for i = 1, 32 do if i == 13 or i == 18 or i == 23 then uuid = uuid .. "-" else uuid = uuid .. string.format("%x", math.random(0, 15)) end end return uuid end
function Utils.randomChoice(arr) return arr[math.random(1, #arr)] end
function Utils.randomChoices(arr, count) local result = {} for i = 1, count do table.insert(result, Utils.randomChoice(arr)) end return result end
function Utils.randomSample(arr, count) count = math.min(count, #arr) local copy = Utils.tableCopy(arr) local result = {} for i = 1, count do local idx = math.random(1, #copy) table.insert(result, copy[idx]) table.remove(copy, idx) end return result end
function Utils.randomWeighted(options) local totalWeight = 0 for _, opt in pairs(options) do totalWeight = totalWeight + opt.weight end local rand = math.random() * totalWeight local current = 0 for _, opt in pairs(options) do current = current + opt.weight if rand <= current then return opt.value end end return options[#options].value end
function Utils.randomGaussian(mean, stdDev) mean = mean or 0 stdDev = stdDev or 1 local u1 = math.random() local u2 = math.random() return mean + stdDev * math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2) end
function Utils.randomNormal(mean, stdDev) return Utils.randomGaussian(mean, stdDev) end
function Utils.randomColor() return Utils.color3Random() end
function Utils.randomVector(min, max) return Vector3.new(Utils.randomFloat(min, max), Utils.randomFloat(min, max), Utils.randomFloat(min, max)) end

-- FUNKTsII 601-650: VALIDATsIYa
function Utils.isValidEmail(email) return string.match(email, "^[%w%.+-]+@[%w%-]+%.[%w%.-]+$") ~= nil end
function Utils.isValidURL(url) return string.match(url, "^https?://[%w%.%-]+%.[%w%.%-]+") ~= nil end
function Utils.isValidIPv4(ip) local parts = Utils.split(ip, ".") if #parts ~= 4 then return false end for _, part in pairs(parts) do local num = tonumber(part) if not num or num < 0 or num > 255 then return false end end return true end
function Utils.isValidHex(hex) return string.match(hex, "^#?[0-9a-fA-F]{6}$") ~= nil end
function Utils.isValidJSON(json) local success = pcall(function() game:GetService("HttpService"):JSONDecode(json) end) return success end
function Utils.isValidDate(year, month, day) if month < 1 or month > 12 then return false end local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31} if year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then daysInMonth[2] = 29 end return day >= 1 and day <= daysInMonth[month] end
function Utils.isValidTime(hour, minute, second) return hour >= 0 and hour <= 23 and minute >= 0 and minute <= 59 and second >= 0 and second <= 59 end
function Utils.isValidPhoneNumber(phone) return string.match(phone, "^%+?%d[%d%-%s]*$") ~= nil end
function Utils.isValidUsername(username) return string.match(username, "^[%w_%-]{3,20}$") ~= nil end
function Utils.isValidPassword(password) return #password >= 8 end

-- FUNKTsII 651-700: KODIROVANIE/DEKODIROVANIE
function Utils.encodeBase64(str) local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" local encoded = "" for i = 1, #str, 3 do local b1, b2, b3 = string.byte(str, i), string.byte(str, i+1) or 0, string.byte(str, i+2) or 0 local n = (b1 * 65536) + (b2 * 256) + b3 encoded = encoded .. string.sub(b64, math.floor(n / 262144) + 1, math.floor(n / 262144) + 1) encoded = encoded .. string.sub(b64, math.floor((n % 262144) / 4096) + 1, math.floor((n % 262144) / 4096) + 1) if i + 1 <= #str then encoded = encoded .. string.sub(b64, math.floor((n % 4096) / 64) + 1, math.floor((n % 4096) / 64) + 1) else encoded = encoded .. "=" end if i + 2 <= #str then encoded = encoded .. string.sub(b64, (n % 64) + 1, (n % 64) + 1) else encoded = encoded .. "=" end end return encoded end
function Utils.decodeBase64(str) local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" local decoded = "" for i = 1, #str, 4 do local c1 = string.find(b64, string.sub(str, i, i)) or 0 local c2 = string.find(b64, string.sub(str, i+1, i+1)) or 0 local c3 = string.find(b64, string.sub(str, i+2, i+2)) or 0 local c4 = string.find(b64, string.sub(str, i+3, i+3)) or 0 local n = ((c1-1) * 262144) + ((c2-1) * 4096) + ((c3-1) * 64) + (c4-1) decoded = decoded .. string.char(math.floor(n / 65536)) if string.sub(str, i+2, i+2) ~= "=" then decoded = decoded .. string.char(math.floor((n % 65536) / 256)) end if string.sub(str, i+3, i+3) ~= "=" then decoded = decoded .. string.char(n % 256) end end return decoded end
function Utils.encodeHex(str) local hex = "" for i = 1, #str do hex = hex .. string.format("%02x", string.byte(str, i)) end return hex end
function Utils.decodeHex(hex) local str = "" for i = 1, #hex, 2 do str = str .. string.char(tonumber(string.sub(hex, i, i+1), 16)) end return str end
function Utils.encodeURL(str) return string.gsub(str, "([^%w%.%-_~])", function(c) return string.format("%%%02X", string.byte(c)) end) end
function Utils.decodeURL(str) return string.gsub(str, "%%([0-9a-fA-F][0-9a-fA-F])", function(hex) return string.char(tonumber(hex, 16)) end) end

-- FUNKTsII 701-750: RABOTA S JSON
function Utils.jsonEncode(obj) local HttpService = game:GetService("HttpService") return HttpService:JSONEncode(obj) end
function Utils.jsonDecode(str) local HttpService = game:GetService("HttpService") return HttpService:JSONDecode(str) end
function Utils.jsonPrettyPrint(obj) return Utils.jsonEncode(obj) end
function Utils.jsonToString(obj) return Utils.jsonEncode(obj) end
function Utils.jsonFromString(str) return Utils.jsonDecode(str) end

-- FUNKTsII 751-800: UTILITY DLYa RABOTY S FAYLAMI (FUNKTsII, NE TREBUYuSchIE DOSTUPA K FS)
function Utils.getFileExtension(filename) return string.match(filename, "%.([^%.]+)$") or "" end
function Utils.getFileName(path) return string.match(path, "([^/\\]+)$") or "" end
function Utils.getFilePath(path) return string.match(path, "^(.*)[/\\]") or "" end
function Utils.removeExtension(filename) return string.gsub(filename, "%.([^%.]+)$", "") end
function Utils.changeExtension(filename, newExt) return Utils.removeExtension(filename) .. "." .. newExt end
function Utils.normalizeSlashes(path) return string.gsub(path, "\\", "/") end
function Utils.normalizePath(path) return Utils.ltrim(Utils.rtrim(Utils.normalizeSlashes(path))) end
function Utils.isAbsolutePath(path) return string.match(path, "^[a-zA-Z]:") ~= nil or string.match(path, "^/") ~= nil end
function Utils.isRelativePath(path) return not Utils.isAbsolutePath(path) end
function Utils.joinPaths(...) local args = {...} local result = "" for i, part in pairs(args) do if i == 1 then result = part else result = result .. "/" .. part end end return Utils.normalizeSlashes(result) end

-- FUNKTsII 801-850: LOGIROVANIE I OTLADKA
function Utils.logInfo(message) print("[INFO] " .. message) end
function Utils.logWarn(message) warn("[WARN] " .. message) end
function Utils.logError(message) error("[ERROR] " .. message, 2) end
function Utils.logDebug(message) print("[DEBUG] " .. message) end
function Utils.logTrace(message) print("[TRACE] " .. message) end
function Utils.printTable(t, indent) indent = indent or "" for k, v in pairs(t) do if type(v) == "table" then print(indent .. k .. " = {") Utils.printTable(v, indent .. "  ") print(indent .. "}") else print(indent .. k .. " = " .. tostring(v)) end end end
function Utils.warn(message) warn(message) end

-- FUNKTsII 851-900: UTILITY DLYa Roblox
function Utils.getPlayers() return game:GetService("Players"):GetPlayers() end
function Utils.getPlayer(name) return game:GetService("Players"):FindFirstChild(name) end
function Utils.getLocalPlayer() return game:GetService("Players").LocalPlayer end
function Utils.getMousePosition() return game:GetService("Players").LocalPlayer:GetMouse() end
function Utils.getCharacter() return game:GetService("Players").LocalPlayer.Character end
function Utils.getHumanoid() local char = Utils.getCharacter() return char and char:FindFirstChild("Humanoid") end
function Utils.getRootPart() local char = Utils.getCharacter() return char and char:FindFirstChild("HumanoidRootPart") end
function Utils.getHeadPart() local char = Utils.getCharacter() return char and char:FindFirstChild("Head") end
function Utils.getTorso() local char = Utils.getCharacter() return char and char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end
function Utils.getUserId() return game:GetService("Players").LocalPlayer.UserId end
function Utils.getUserName() return game:GetService("Players").LocalPlayer.Name end
function Utils.getDisplayName() return game:GetService("Players").LocalPlayer.DisplayName end
function Utils.getPlatform() return game:GetService("UserInputService").TouchEnabled and "Mobile" or "Desktop" end
function Utils.isPlaying() return game:GetService("RunService"):IsRunning() end
function Utils.isStudio() return game:GetService("RunService"):IsStudio() end
function Utils.isServer() return game:GetService("RunService"):IsServer() end
function Utils.isClient() return game:GetService("RunService"):IsClient() end
function Utils.waitForCharacter(timeout) local start = tick() while not Utils.getCharacter() and tick() - start < (timeout or math.huge) do game:GetService("RunService").Heartbeat:Wait() end return Utils.getCharacter() end
function Utils.teleport(position) local root = Utils.getRootPart() if root then root.CFrame = CFrame.new(position) end end
function Utils.teleportToPlayer(player) if player.Character then Utils.teleport(player.Character:FindFirstChild("HumanoidRootPart").Position) end end

-- FUNKTsII 901-950: BOLShE UTILIT DLYa Roblox
function Utils.createPart(parent, name) local part = Instance.new("Part") part.Name = name part.Parent = parent return part end
function Utils.createModel(parent, name) local model = Instance.new("Model") model.Name = name model.Parent = parent return model end
function Utils.createHumanoid(parent) local humanoid = Instance.new("Humanoid") humanoid.Parent = parent return humanoid end
function Utils.destroyInstance(instance) if instance then instance:Destroy() end end
function Utils.findFirstChild(parent, name) return parent:FindFirstChild(name) end
function Utils.findFirstChildOfClass(parent, className) return parent:FindFirstChildOfClass(className) end
function Utils.getDescendants(instance) return instance:GetDescendants() end
function Utils.getChildren(instance) return instance:GetChildren() end
function Utils.getService(serviceName) return game:GetService(serviceName) end
function Utils.findService(serviceName) pcall(function() return Utils.getService(serviceName) end) return nil end
function Utils.waitForService(serviceName, timeout) local start = tick() while not game:FindService(serviceName) and tick() - start < (timeout or math.huge) do game:GetService("RunService").Heartbeat:Wait() end return game:GetService(serviceName) end

-- FUNKTsII 951-1000: FINALNYE UTILITY
function Utils.delay(callback, seconds) task.delay(seconds, callback) end
function Utils.spawn(callback) task.spawn(callback) end
function Utils.defer(callback) task.defer(callback) end
function Utils.throttle(fn, delay) local lastCall = 0 return function(...) local now = tick() if now - lastCall >= delay then lastCall = now fn(...) end end end
function Utils.debounce(fn, delay) local timeout = nil return function(...) if timeout then task.cancel(timeout) end local args = {...} timeout = task.delay(delay, function() fn(unpack(args)) end) end end
function Utils.once(fn) local called = false return function(...) if not called then called = true return fn(...) end end end
function Utils.memoize(fn) local cache = {} return function(...) local key = Utils.jsonEncode({...}) if cache[key] then return cache[key] end local result = fn(...) cache[key] = result return result end end
function Utils.compose(...) local fns = {...} return function(x) for i = #fns, 1, -1 do x = fns[i](x) end return x end end
function Utils.pipe(...) local fns = {...} return function(x) for _, fn in pairs(fns) do x = fn(x) end return x end end
function Utils.partial(fn, ...) local args = {...} return function(...) return fn(Utils.tableJoin(args, {...})) end end
function Utils.curry(fn) local arity = debug.getinfo(fn).nups or 0 return function(...) local args = {...} if #args >= arity then return fn(...) else return Utils.curry(function(...) return fn(Utils.tableJoin(args, {...})) end) end end end
function Utils.retry(fn, attempts, delay) delay = delay or 1 local lastError for attempt = 1, attempts do local success, result = pcall(fn) if success then return result end lastError = result if attempt < attempts then task.wait(delay) end end error("Max retries reached: " .. lastError) end
function Utils.tryCatch(fn, catchFn) local success, result = pcall(fn) if success then return result else if catchFn then catchFn(result) end return nil end end
function Utils.deepEquals(a, b) if type(a) ~= type(b) then return false end if type(a) ~= "table" then return a == b end for k in pairs(a) do if not Utils.deepEquals(a[k], b[k]) then return false end end for k in pairs(b) do if a[k] == nil then return false end end return true end
function Utils.shallowEquals(a, b) if type(a) ~= type(b) then return false end if type(a) ~= "table" then return a == b end local lenA = Utils.tableLength(a) local lenB = Utils.tableLength(b) if lenA ~= lenB then return false end for k in pairs(a) do if a[k] ~= b[k] then return false end end return true end
function Utils.createWrapper(fn, before, after) return function(...) if before then before(...) end local result = fn(...) if after then after(...) end return result end end
function Utils.createEventEmitter() local listeners = {} return {on = function(self, event, fn) if not listeners[event] then listeners[event] = {} end table.insert(listeners[event], fn) end, off = function(self, event, fn) if listeners[event] then for i, f in pairs(listeners[event]) do if f == fn then table.remove(listeners[event], i) break end end end end, emit = function(self, event, ...) if listeners[event] then for _, fn in pairs(listeners[event]) do fn(...) end end end, once = function(self, event, fn) local wrapped = function(...) self:off(event, wrapped) fn(...) end self:on(event, wrapped) end} end
function Utils.createPromise(executor) 
    local promise = {_state = "pending", _value = nil, _handlers = {}} 
    
    function promise:thenDo(onFulfilled, onRejected) 
        local newPromise = Utils.createPromise(function(resolve, reject) 
            table.insert(self._handlers, {
                onFulfilled = onFulfilled, 
                onRejected = onRejected, 
                resolve = resolve, 
                reject = reject
            }) 
        end) 
        return newPromise 
    end 
    
    function promise:catchDo(onRejected) 
        return promise:thenDo(nil, onRejected) 
    end 
    
    function promise:finallyDo(onFinally) 
        return promise:thenDo(function(v) 
            onFinally() 
            return v 
        end, function(e) 
            onFinally() 
            error(e) 
        end) 
    end 
    
    if executor then 
        executor(function(value) 
            promise._state = "fulfilled" 
            promise._value = value 
            for _, handler in pairs(promise._handlers) do 
                if handler.onFulfilled then 
                    handler.resolve(handler.onFulfilled(value)) 
                end 
            end 
        end, function(reason) 
            promise._state = "rejected" 
            promise._value = reason 
            for _, handler in pairs(promise._handlers) do 
                if handler.onRejected then 
                    handler.resolve(handler.onRejected(reason)) 
                end 
            end 
        end) 
    end 
    
    return promise 
end

-- ========== DOPOLNITELNYE FUNKTsII FLINGA S MAShINY ==========
yasiaHub.advancedVehicleFling = function(power)
    power = power or 1000
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local seat = char:FindFirstChild("VehicleSeat") or char.Parent:FindFirstChildOfClass("VehicleSeat")
        if seat then
            for i = 1, 10 do
                seat.Velocity = Vector3.new(math.random(-power, power), power, math.random(-power, power))
                wait(0.05)
            end
            print("[Info] Advanced fling executed!")
        end
    end
end

yasiaHub.vehicleFlingRotation = function()
    local char = game.Players.LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            humanoid.SeatPart.CFrame = humanoid.SeatPart.CFrame * CFrame.Angles(math.rad(360), math.rad(360), math.rad(360))
            humanoid.SeatPart.Velocity = Vector3.new(500, 500, 500)
        end
    end
end

-- ========== RASShIRENNYY NABOR FUNKTsIY ==========
yasiaHub.callGeneratedFunction = function(index, param)
    index = math.floor(tonumber(index) or 1)
    if index < 1 then
        index = 1
    elseif index > 500 then
        index = 500
    end

    if index % 5 == 0 then
        print("[Info] Yasia Hub function " .. index)
    elseif index % 3 == 0 then
        print("[Info] Function " .. index .. " activated")
    else
        print("[Info] Function " .. index .. " executed")
    end

    return "REZULTAT FUNKTsII " .. index
end

-- FUNKTsII DLYa UPRAVLENIYa IGROKOM
yasiaHub.teleportToRandomPlayer = function()
    local players = game.Players:GetPlayers()
    if #players > 1 then
        local randomPlayer = players[math.random(1, #players)]
        if randomPlayer.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
        end
    end
end

yasiaHub.setSpeed = function(speed)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed or 50
    end
end

yasiaHub.setJumpPower = function(power)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = power or 100
    end
end

-- FUNKTsII DLYa VIZUALNYKh EFFEKTOV
yasiaHub.spawnParticles = function(count)
    local char = game.Players.LocalPlayer.Character
    if char then
        for i = 1, (count or 50) do
            local part = Instance.new("Part")
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.BrickColor = BrickColor.random()
            part.CanCollide = false
            part.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(math.random(-10, 10), math.random(0, 10), math.random(-10, 10))
            part.Velocity = Vector3.new(math.random(-50, 50), math.random(20, 50), math.random(-50, 50))
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 5)
        end
    end
end

-- FUNKTsII DLYa SOZDANIYa OBEKTOV
yasiaHub.createCube = function(size, color)
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Block
    part.Size = Vector3.new(size or 2, size or 2, size or 2)
    part.BrickColor = BrickColor.new(color or "Bright red")
    part.CanCollide = true
    part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    part.Parent = workspace
    return part
end

yasiaHub.createSphere = function(size, color)
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(size or 2, size or 2, size or 2)
    part.BrickColor = BrickColor.new(color or "Bright blue")
    part.CanCollide = true
    part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    part.Parent = workspace
    return part
end

-- FUNKTsII DLYa RABOTY S KhARAKTERISTIKAMI
yasiaHub.increaseHealth = function(amount)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = char.Humanoid.Health + (amount or 50)
    end
end

yasiaHub.setHealth = function(health)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = health or 100
    end
end

-- FUNKTsII DLYa ZVUKOV
yasiaHub.playSound = function(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. (soundId or 6062677264)
    sound.Volume = volume or 1
    sound.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
    sound:Play()
    return sound
end

-- FUNKTsII DLYa KAMERY
yasiaHub.zoomCamera = function(zoom)
    game.Workspace.CurrentCamera.FieldOfView = zoom or 30
end

yasiaHub.resetCamera = function()
    game.Workspace.CurrentCamera.FieldOfView = 70
end

-- FUNKTsII DLYa OSVESchENIYa
yasiaHub.changeLighting = function(brightness, ambient)
    local lighting = game:GetService("Lighting")
    lighting.Brightness = brightness or 2
    lighting.Ambient = Color3.fromRGB(ambient or 255, ambient or 255, ambient or 255)
end

yasiaHub.nightMode = function()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 0
    lighting.Ambient = Color3.fromRGB(50, 50, 50)
end

yasiaHub.dayMode = function()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
end

-- FUNKTsII DLYa ANIMATsIY
yasiaHub.playAnimation = function(animationId)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. (animationId or 0)
        local animator = char.Humanoid:FindFirstChild("Animator") or Instance.new("Animator", char.Humanoid)
        animator:LoadAnimation(animation):Play()
    end
end

-- FUNKTsII DLYa RABOTY S ChASTYaMI PERSONAZhA
yasiaHub.makeCharacterTransparent = function(transparency)
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = transparency or 0.5
            end
        end
    end
end

yasiaHub.makeCharacterSolid = function()
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end

-- FUNKTsII DLYa RABOTY S TsVETOM
yasiaHub.changeCharacterColor = function(r, g, b)
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.fromRGB(r or 255, g or 0, b or 0)
            end
        end
    end
end

-- FUNKTsII UTILITY
yasiaHub.getPlayerCount = function()
    return #game.Players:GetPlayers()
end

yasiaHub.getPlayers = function()
    return game.Players:GetPlayers()
end

yasiaHub.findPlayer = function(name)
    return game.Players:FindFirstChild(name)
end

yasiaHub.teleportToPlayer = function(playerName)
    local player = game.Players:FindFirstChild(playerName)
    if player and player.Character then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
    end
end

-- FUNKTsII DLYa RABOTY S UI
yasiaHub.createNotification = function(text, duration)
    print("[UVEDOMLENIE] " .. text)
end

-- FUNKTsII DLYa RABOTY S INVENTAREM
yasiaHub.getTools = function()
    local tools = {}
    for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        table.insert(tools, tool.Name)
    end
    return tools
end

yasiaHub.equipTool = function(toolName)
    local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(toolName)
    if tool then
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

-- FUNKTsII DLYa RABOTY S ChASTITsAMI
yasiaHub.spawnRainbow = function()
    for i = 1, 100 do
        yasiaHub.spawnParticles(10)
        wait(0.1)
    end
end

-- FUNKTsII DLYa RABOTY S FIZIKOY
yasiaHub.antiGravity = function()
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
            end
        end
    end
end

yasiaHub.normalGravity = function()
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = nil
            end
        end
    end
end

-- DOPOLNITELNYE FUNKTsII FLINGA
yasiaHub.vehicleFlingCombo = function(times)
    times = times or 5
    for i = 1, times do
        yasiaHub.advancedVehicleFling(800)
        wait(0.5)
    end
end

-- FUNKTsII DLYa SOZDANIYa EFFEKTOV
yasiaHub.createExplosion = function(position, size)
    local explosion = Instance.new("Explosion")
    explosion.Position = position or game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    explosion.Parent = workspace
end

yasiaHub.createLightning = function(position1, position2)
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Cylinder
    part.BrickColor = BrickColor.new("Bright yellow")
    part.CanCollide = false
    part.CFrame = CFrame.new((position1 + position2) / 2, position2)
    part.Size = Vector3.new(0.5, (position1 - position2).Magnitude, 0.5)
    part.Parent = workspace
    return part
end

-- FUNKTsII DLYa RABOTY S VIDIMOSTYu
yasiaHub.hideAllPlayers = function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end
    end
end

yasiaHub.showAllPlayers = function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
end

-- FUNKTsII DLYa RABOTY S RAZMEROM
yasiaHub.makeCharacterBig = function(scale)
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * (scale or 2)
            end
        end
    end
end

yasiaHub.makeCharacterSmall = function(scale)
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size / (scale or 2)
            end
        end
    end
end

print("[Info] Utility helpers loaded")
print("[Info] Utils object is ready")
print("[" .. HUB_TAG .. "] Systems initialized")

-- GLAVNYY ZASchISchENNYY TsIKL OBNOVLENIYa
yasiaHub._lastUpdate = 0
yasiaHub._updateInterval = 0.1

yasiaHub.safeUpdate = function()
    local success, err = pcall(function()
        if tick() - (yasiaHub._lastUpdate or 0) > (yasiaHub._updateInterval or 0.1) then
            yasiaHub._lastUpdate = tick()
            -- OSNOVNYE OBNOVLENIYa ZDES
        end
    end)
    if not success then
        warn("[" .. HUB_TAG .. "] Update error: " .. tostring(err))
    end
end

-- PODKLYuChAEM OSNOVNOY TsIKL OBNOVLENIYa
GlobalState.SafeUpdateConnection = RunService.Heartbeat:Connect(yasiaHub.safeUpdate)

-- OBRABOTKA OTKLYuChENIYa SKRIPTA
yasiaHub.handleCharacterDeath = function()
    print("[" .. HUB_TAG .. "] Character died, cleaning up...")
    if GlobalState.flyConnection then
        GlobalState.flyConnection:Disconnect()
    end
    if GlobalState.espRunConnection then
        GlobalState.espRunConnection:Disconnect()
    end
    if GlobalState.speedHackConnection then
        GlobalState.speedHackConnection:Disconnect()
    end
end

yasiaHub.bindCharacterDeath = function(character)
    if GlobalState.CharacterDiedConnection then
        pcall(function()
            GlobalState.CharacterDiedConnection:Disconnect()
        end)
        GlobalState.CharacterDiedConnection = nil
    end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        GlobalState.CharacterDiedConnection = humanoid.Died:Connect(yasiaHub.handleCharacterDeath)
        return
    end
    task.spawn(function()
        local waitedHumanoid = character and character:WaitForChild("Humanoid", 10)
        if waitedHumanoid then
            GlobalState.CharacterDiedConnection = waitedHumanoid.Died:Connect(yasiaHub.handleCharacterDeath)
        end
    end)
end

if LP and LP.Character then
    yasiaHub.bindCharacterDeath(LP.Character)
end

if LP then
    GlobalState.CharacterAddedConnection = LP.CharacterAdded:Connect(function(character)
        yasiaHub.bindCharacterDeath(character)
    end)
end

print("[Info] [" .. HUB_TAG .. "] Script fully loaded and ready to use!")

function formatCompactDuration(totalSeconds)
    totalSeconds = math.max(0, math.floor(tonumber(totalSeconds) or 0))

    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, seconds)
    end
    if minutes > 0 then
        return string.format("%dm %ds", minutes, seconds)
    end
    return string.format("%ds", seconds)
end

function getThemePreviewText()
    return table.concat({
        TL("Тема", "Тема", "Theme") .. "=" .. tostring(YasiaHubSettings.Theme or "Default"),
        TL("Язык", "Мова", "Language") .. "=" .. getCurrentLanguageLabel(),
        "HUD=" .. getToggleWord(MainSettings.HudEnabled == true),
        TL("Аптайм", "Аптайм", "Uptime") .. "=" .. formatCompactDuration(tick() - (HubBootAt or tick())),
    }, " | ")
end

function getHubDiagnosticsText()
    return table.concat({
        "Hub=" .. HUB_BRAND,
        "Theme=" .. tostring(YasiaHubSettings.Theme or "Default"),
        "Language=" .. getCurrentLanguageLabel(),
        "Uptime=" .. formatCompactDuration(tick() - (HubBootAt or tick())),
        "ActiveModules=" .. tostring(getEnabledModuleCount()),
        "Coords=" .. tostring(getCompactPositionText() ~= "" and getCompactPositionText() or "-"),
        getServerSummaryText(),
        getSavedSlotsSummaryText(),
        getVisualSnapshotText(),
        getMovementSnapshotText(),
        getCombatSnapshotText(),
        getFarmSnapshotText(),
        "GalleryImages=" .. tostring(#(GallerySettings.Images or {})),
        "CloudPage=" .. tostring(CloudScriptsSettings.Page or 1) .. "/" .. tostring(CloudScriptsSettings.TotalPages or "?"),
        "CloudResults=" .. tostring(#(CloudScriptsSettings.Results or {})),
    }, "\n")
end

function getLiveStatusText()
    return table.concat({
        "Modules=" .. tostring(getEnabledModuleCount()),
        "Theme=" .. tostring(YasiaHubSettings.Theme or "Default"),
        "Uptime=" .. formatCompactDuration(tick() - (HubBootAt or tick())),
        "Coords=" .. tostring(getCompactPositionText() ~= "" and getCompactPositionText() or "-"),
        "Chat=" .. getToggleWord(ChatSettings.Enabled == true),
        "Farm=" .. getToggleWord(FarmSettings.AutoEnabled == true),
        "Aimbot=" .. getToggleWord(AimbotSettings.Enabled == true),
    }, " | ")
end

function cycleAccentTheme(step)
    local themes = getThemeList()
    local current = tostring(YasiaHubSettings.Theme or "Default")
    local currentIndex = 1

    for index, themeName in ipairs(themes) do
        if themeName == current then
            currentIndex = index
            break
        end
    end

    local nextIndex = ((currentIndex - 1 + (step or 1)) % #themes) + 1
    local nextTheme = themes[nextIndex]
    applyAccentTheme(nextTheme)
    refreshLiveStatusLabels()
    hubNotify(TL("Тема", "Тема", "Theme"), nextTheme, 2, true)
    return nextTheme
end

function showBeginnerTipsNotice()
    hubNotify(
        TL("Советы", "Поради", "Tips"),
        TL(
            "Начни с Settings, сохрани позицию перед тестом и включай функции по одной.",
            "Почни з Settings, збережи позицію перед тестом і вмикай функції по одній.",
            "Start in Settings, save a position before testing, and enable features one by one."
        ),
        6,
        true
    )
end

if Utils then
    function Utils.isPowerOfTwo(n) if type(n) ~= "number" or n < 1 or n % 1 ~= 0 then return false end while n > 1 do if n % 2 ~= 0 then return false end n = n / 2 end return true end
    function Utils.encode(str) return (tostring(str or ""):gsub(".", function(ch) return string.format("%%%02X", string.byte(ch)) end)) end
    function Utils.arrayCreate(size, value) local arr = {} for i = 1, size do arr[i] = value end return arr end
    function Utils.randomAlphanumeric(length) local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" local str = "" for i = 1, length do local index = math.random(1, #chars) str = str .. string.sub(chars, index, index) end return str end
    function Utils.isValidHex(hex) local raw = tostring(hex or "") local normalized = raw:gsub("^#", "") return #normalized == 6 and string.match(normalized, "^[0-9a-fA-F]+$") ~= nil end
    function Utils.isValidUsername(username) local value = tostring(username or "") return #value >= 3 and #value <= 20 and string.match(value, "^[%w_%-]+$") ~= nil end
    function Utils.getTorso() local char = Utils.getCharacter() if not char then return nil end return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end
    function Utils.findService(serviceName) local success, service = pcall(function() return Utils.getService(serviceName) end) return success and service or nil end
    function Utils.partial(fn, ...) local args = {...} return function(...) local merged = Utils.tableJoin(args, {...}) return fn(unpack(merged, 1, #merged)) end end
    function Utils.curry(fn, arity) arity = tonumber(arity) or 1 local function build(collected) return function(...) local merged = Utils.tableJoin(collected, {...}) if #merged >= arity then return fn(unpack(merged, 1, #merged)) end return build(merged) end end return build({}) end
end

print("[Info] Utility pack loaded successfully")
print("[Info] Utils registry initialized")
print("[" .. HUB_TAG .. "] All systems initialized")
