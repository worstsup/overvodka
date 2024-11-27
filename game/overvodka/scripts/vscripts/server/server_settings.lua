-- Главная страница сервера
SERVER_URL = 'https://overvodka.ru/api/'

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
    188428188,
    409188637,
}

--Длительность перезарядки типа
SERVER_TIP_COOLDOWN = 40