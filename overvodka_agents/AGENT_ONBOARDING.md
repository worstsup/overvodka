# Agent Onboarding — OVERVODKA

Короткий onboarding по реальной структуре этого репо.

## 1) Что это за проект
- Серверная и gameplay-логика: Lua в `game/overvodka/scripts/vscripts`
- KV и игровые данные: `game/overvodka/scripts/npc`
- Локализация: `game/overvodka/resource`
- UI: Panorama в `content/overvodka/panorama`

## 2) Что смотреть первым делом
- `game/overvodka/scripts/vscripts/addon_init.lua`
  Начальная инициализация, client/server split, часть ListenToGameEvent.
- `game/overvodka/scripts/vscripts/addon_game_mode.lua`
  Главный bootstrap игры: `require(...)`, `Precache`, `Activate`, `InitGameMode`.
- `content/overvodka/panorama/layout/custom_game/custom_ui_manifest.xml`
  Главный вход в Panorama-слой и список подключённых `CustomUIElement`.

## 3) Базовая карта репо

### Lua
- `game/overvodka/scripts/vscripts/heroes`
  Герои и их способности. Частый паттерн: `heroes/<hero>/<hero>_<spell>.lua`
- `game/overvodka/scripts/vscripts/items`
  Предметы
- `game/overvodka/scripts/vscripts/modifiers`
  Общие модификаторы
- `game/overvodka/scripts/vscripts/server`
  Серверные системы, API, guides и т.п.
- `game/overvodka/scripts/vscripts/util`
  Общие utility-модули

### KV
- `game/overvodka/scripts/npc/npc_abilities_custom.txt`
- `game/overvodka/scripts/npc/npc_heroes_custom.txt`
- `game/overvodka/scripts/npc/npc_items_custom.txt`
- `game/overvodka/scripts/npc/npc_units_custom.txt`
- Дополнительно в этой же директории есть ванильные/override-файлы, которые иногда тоже нужно учитывать

### Локализация
- `game/overvodka/resource/addon_russian.txt`
- `game/overvodka/resource/addon_english.txt`

### Panorama
- `content/overvodka/panorama/layout/custom_game`
- `content/overvodka/panorama/scripts/custom_game`
- `content/overvodka/panorama/styles/custom_game`

## 4) Реальные паттерны проекта
- В ability-файлах часто рядом живут сама способность и несколько modifier-классов.
- `LinkLuaModifier(...)` обычно объявляется сверху ability-файла.
- `Precache(ctx)` используется прямо внутри ability/item файла, если нужны particles/sounds.
- `OnCreated` / `OnRefresh` часто читают `GetSpecialValueFor(...)` и кэшируют значения в полях.
- Motion modifiers используют `ApplyHorizontalMotionController` / `SetAbsOrigin` / `FindClearSpaceForUnit`.
- Server/UI стыкуются через `CustomGameEventManager` и `CustomNetTables`.

## 5) Что агент должен проверить при типичной правке

### Если меняется способность
- Lua ability logic
- связанные modifiers
- `npc_abilities_custom.txt`
- локализация
- при необходимости `npc_heroes_custom.txt`
- precache / particles / sounds

### Если меняется герой
- набор и порядок способностей
- `npc_heroes_custom.txt`
- `npc_abilities_custom.txt`
- локализация героя и его способностей
- таланты / аспекты / innate / shard / scepter, если затронуты

### Если меняется предмет
- Lua item file
- `npc_items_custom.txt`
- локализация предмета
- UI/tooltips, если они читают эти данные отдельно

## 6) Как думать про UI ↔ server
- Команда или действие: `GameEvents.SendCustomGameEventToServer(...)`
- Состояние и данные для интерфейса: `CustomNetTables`
- Не надо спамить событиями там, где нужна просто подписка на состояние

## 7) Definition of done для локальной правки
- Нет сломанных `LinkLuaModifier`
- Нет `GetSpecialValueFor(...)` без KV-ключа
- Нет новой логики без локализации, если текст виден игроку
- Нет утечек particles/timers/motion
- Есть список ручных тестов в игре
