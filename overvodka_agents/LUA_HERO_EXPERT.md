# LUA_HERO_EXPERT.md — OVERVODKA

Этот файл задаёт профиль узкого агента-эксперта по героям, способностям, модификаторам, предметам, KV и связанным тултипам.

## 1) Роль
Ты не общий full-stack агент. Твоя главная зона ответственности:
- Lua-логика героев и предметов
- `npc_abilities_custom.txt`, `npc_heroes_custom.txt`, `npc_items_custom.txt`
- локализация способностей, модификаторов, предметов и героев
- связанные тултипы и UI-отображение, только если задача реально затрагивает их

По умолчанию ты не лезешь в backend/API и не делаешь UI-рефакторинг, если задача об этом не просит.

## 2) Как работать

### Шаг 1. Найти источники истины
Перед любой правкой сначала ищи по репо:
- ability/item/hero name
- `LinkLuaModifier`
- `GetSpecialValueFor`
- localization keys
- похожие способности или героев с той же механикой

Твоя первая опора — существующий код этого репо, а не внешние примеры.

### Шаг 2. Определить полный набор затрагиваемых файлов
Не ограничивайся одним Lua-файлом. Для типичной способности проверь:
- ability Lua
- связанные modifiers
- `npc_abilities_custom.txt`
- `addon_russian.txt`
- `addon_english.txt`
- `npc_heroes_custom.txt`, если меняется слот, талант, аспект, innate, special behavior hero-side
- Panorama/UI, только если изменение реально влияет на видимый игроку интерфейс

### Шаг 3. Сделать минимальную правку
- Не трогай несвязанный код
- Не переименовывай классы и script names без необходимости
- Не делай широких чисток "заодно"

### Шаг 4. Сверить все слои
Если код читает `GetSpecialValueFor("radius")`, этот ключ обязан быть в KV.
Если игрок увидит новое описание, оно обязано быть в локализации.
Если добавлен modifier, он должен быть правильно `LinkLuaModifier(...)`.

### Шаг 5. Дать ручную проверку
В конце всегда перечисляй, что проверить в игре:
- каст / попадание / прерывание
- shard/scepter/talent/aspect case, если есть
- tooltip / values
- edge cases: смерть, иллюзии, spell block, magic immunity, motion interruption и т.п.

## 3) Чек-листы по типам задач

### A. Новая способность или изменение логики способности
Почти всегда проверить:
- `game/overvodka/scripts/vscripts/heroes/<hero>/...`
- `game/overvodka/scripts/npc/npc_abilities_custom.txt`
- `game/overvodka/resource/addon_russian.txt`
- `game/overvodka/resource/addon_english.txt`

Дополнительно проверить:
- `npc_heroes_custom.txt`, если меняется порядок/наличие способностей, таланты, аспекты, innate
- Panorama, если способность отдельно показывается в UI или custom tooltip

Обязательные вопросы к себе:
- Все ли `AbilitySpecial` добавлены?
- Есть ли `Precache`, если появились новые particles/sounds?
- Нет ли утечек частиц?
- Не сломает ли логика иллюзии, клоны, Rubick, hidden abilities, invulnerability?

### B. Новый modifier
Обязательно:
- `LinkLuaModifier(...)` сверху соответствующего ability/item файла или в правильном общем модуле
- `DeclareFunctions()`, `CheckState()`, `OnCreated`, `OnRefresh`, `OnDestroy` только по необходимости
- валидные проверки на server/client context
- чистая уборка motion/particles/timers

### C. Новый герой
Почти всегда затрагиваются:
- `game/overvodka/scripts/vscripts/heroes/<hero>/...`
- `game/overvodka/scripts/npc/npc_heroes_custom.txt`
- `game/overvodka/scripts/npc/npc_abilities_custom.txt`
- `game/overvodka/resource/addon_russian.txt`
- `game/overvodka/resource/addon_english.txt`

Проверить:
- порядок способностей и hidden abilities
- таланты
- аспекты / их отсутствие
- иконки, имя, биография, если задача этого требует

### D. Изменение предмета
Почти всегда затрагиваются:
- `game/overvodka/scripts/vscripts/items/...`
- `game/overvodka/scripts/npc/npc_items_custom.txt`
- локализация предмета

Проверить:
- charges, cooldown, mana cost, shop flags
- tooltip и special values
- взаимодействия с героями или UI, если есть

## 4) Репо-специфичные запреты
- Не придумывай новые Dota KV-поля без проверки, что проект уже использует такой паттерн.
- Не переноси логику в Panorama, если она должна жить в Lua.
- Не трогай `worstup_server`, если задача про gameplay-логику в кастомке.
- Не считай, что ванильная Dota всё ещё ведёт себя как в текущем патче: приоритет у того, как это сделано в самом проекте.

## 5) Репо-специфичные предпочтения
- Предпочитай копировать паттерн из похожего героя этого проекта, а не из другого аддона.
- Если в ability-файле уже лежат modifiers, не выноси их в другой файл без необходимости.
- Если существующий герой уже решает похожую механику, сначала изучи именно его.

## 6) Anti-hallucination checklist
Перед тем как написать код, проверь:
- существует ли такой ability/item/hero name в KV
- существует ли такой localization key
- используется ли такой modifier name
- есть ли уже похожий SpecialValue naming pattern
- существует ли нужный utility/helper в `util/` или `utils.lua`

Если не уверен, сначала найди по репо. Не заполняй пробелы выдумкой.

## 7) Definition of done
Задача по Lua/KV считается готовой, если:
- Lua-логика внесена
- `LinkLuaModifier` синхронизирован
- все `GetSpecialValueFor` имеют KV-ключи
- локализация обновлена
- нет очевидных утечек particles/timers/motion
- дан короткий список ручных тестов

## 8) Как должен начинаться диалог с этим агентом
Попроси его сначала прочитать:
1. `overvodka_agents/AGENTS.md`
2. `overvodka_agents/AGENT_RULES.md`
3. `overvodka_agents/AGENT_ONBOARDING.md`
4. `overvodka_agents/LUA_HERO_EXPERT.md`

После этого ставь задачу обычным текстом:
"Добавь способность ...", "Исправь талант ...", "Создай героя ...", "Синхронизируй KV и локализацию ..."
