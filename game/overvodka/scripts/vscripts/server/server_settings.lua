-- Главная страница сервера
SERVER_URL = 'http://overvodka.com/api/'

-- Ключ кастомки
SERVER_KEY = GetDedicatedServerKeyV3('overvodka')

-- Сколько милисекунд ждать ответ от сервера за каждую попытку соединения
SERVER_ONE_TRY_WAIT_TIME = 10000

-- Сколько всего может быть попыток подключения
SERVER_MAX_ATTEMPTS = 5

--Интервал попыток подключения в секундах
SERVER_ATTEMPT_INTERVAL = 1

--Список для оффлайн игры (без сервера)
SERVER_PLAYERS_WITH_PERMANENT_PRIVILEGES = {
    188428188,  -- nears
    409188637,  -- worstsup
    885116894, -- dolbayobi
    1010078422, -- mikeil
    349446348,  -- mefisto 
    1248303404, -- sega
    1133110680, -- buyer
}

SERVER_RANKS_DEFINITION = {
    NONE = 0,
    BRONZE = 1,
    SILVER = 2,
    GOLD = 3,
    PLATINUM = 4,
    DIAMOND = 5,
    EPIC = 6,
    LEGEND = 7,
    DIVINE = 8,
    HAMSTERGOD = 9
}

--Длительность перезарядки типа
SERVER_TIP_COOLDOWN = 40

--Длительность возможности поставить Дабл рейт
SERVER_DOUBLE_RATING_TIME = 10

SERVER_RATING_WHEN_ABANDONED_GAME = -100

--Настройки рейтинга
SERVER_RATING = {
    [GAME_CATEGORY_DEFINITIONS.SOLO] = {
        {
            min_full = 65,
            max_full = 75,
            min_full_kills = 75,
            max_full_kills = 100,
            min_less6 = 65,
            max_less6 = 75,
            min_less6_kills = 75,
            max_less6_kills = 75,
        },
        {
            min_full = 45,
            max_full = 55,
            min_less6 = 45,
            max_less6 = 55,
            min_full_after_epic = -10,
            max_full_after_epic = -15,
        },
        {
            min_full = 35,
            max_full = 45,
            min_less6 = 35,
            max_less6 = 45,
            min_full_after_epic = -15,
            max_full_after_epic = -25,
        },
        {
            min_full = 15,
            max_full = 25,
            min_full_after_gold = -15,
            max_full_after_gold = -25,
            min_less6 = 25,
            max_less6 = 35,
            min_full_after_epic = -25,
            max_full_after_epic = -35,
        },
        {
            min_full = 15,
            max_full = 25,
            min_full_after_gold = -15,
            max_full_after_gold = -25,
            min_less6 = 10,
            max_less6 = 15,
            min_full_after_epic = -25,
            max_full_after_epic = -35,
        },
        {
            min_full = 15,
            max_full = 25,
            min_full_after_gold = -15,
            max_full_after_gold = -25,
            min_full_after_diamond = -25,
            max_full_after_diamond = -35,
            min_less6 = -25,
            max_less6 = -35,
            min_full_after_epic = -45,
            max_full_after_epic = -55,
        },
        {
            min_full = 15,
            max_full = 25,
            min_full_after_gold = -15,
            max_full_after_gold = -25,
            min_full_after_diamond = -25,
            max_full_after_diamond = -35,
            min_less6 = -25,
            max_less6 = -35,
            min_full_after_epic = -45,
            max_full_after_epic = -55,
        },
        {
            min_full = -35,
            max_full = -45,
            min_full_after_diamond = -55,
            max_full_after_diamond = -65,
            min_less6 = -25,
            max_less6 = -35,
            min_full_after_epic = -75,
            max_full_after_epic = -85,
        },
        {
            min_full = -35,
            max_full = -45,
            min_full_after_diamond = -55,
            max_full_after_diamond = -65,
            min_less6 = -25,
            max_less6 = -35,
            min_full_after_epic = -75,
            max_full_after_epic = -85,
        },
        {
            min_full = -35,
            max_full = -45,
            min_full_after_diamond = -55,
            max_full_after_diamond = -65,
            min_less6 = -25,
            max_less6 = -35,
            min_full_after_epic = -75,
            max_full_after_epic = -85,
        },
    },
    [GAME_CATEGORY_DEFINITIONS.DUO] = {
        {
            min_full = 65,
            min_less3 = 45,
            min_full_kills = 75,
            min_less3_kills = 55,
            max_full = 75,
            max_less3 = 55,
            max_full_kills = 100,
            max_less3_kills = 75,
        },
        {
            min_full = 35,
            max_full = 45,
            min_less3 = -25,
            max_less3 = -35,
            min_full_after_epic = -35,
            max_full_after_epic = -45,
        },
        {
            min_full_before_diamond = 15,
            max_full_before_diamond = 25,
            min_full_after_diamond = -15,
            max_full_after_diamond = -25,
            min_less3 = -25,
            max_less3 = -35,
            min_full_after_epic = -35,
            max_full_after_epic = -45,
        },
        {
            min_full_before_diamond = -25,
            max_full_before_diamond = -45,
            min_full_after_diamond = -35,
            max_full_after_diamond = -55,
            min_less3 = -25,
            max_less3 = -35,
            min_full_after_epic = -55,
            max_full_after_epic = -75,
        },
        {
            min_full_before_diamond = -25,
            max_full_before_diamond = -45,
            min_full_after_diamond = -35,
            max_full_after_diamond = -55,
            min_less3 = -25,
            max_less3 = -35,
            min_full_after_epic = -55,
            max_full_after_epic = -75,
        },
    }
}