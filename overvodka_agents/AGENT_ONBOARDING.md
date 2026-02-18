# Agent Onboarding — OVERVODKA

Короткий набор файлов и правил, чтобы новый агент быстро вник в проект.

1) Краткий контекст
- Сервер: Lua (`game/overvodka/scripts/vscripts`) — основная логика, `Server:SendRequest` использует `CreateHTTPRequestScriptVM` к `SERVER_URL`.
- UI: Panorama (JS/XML/CSS) в `content/overvodka/panorama`.
- Бэкенд: Node.js + MySQL (API-примеры в `worstup_server/routes/api.js` приложенном к репо).

2) Быстрый старт — что посмотреть первым делом
- `game/overvodka/scripts/vscripts/addon_init.lua` — инициализация игры.
- `game/overvodka/scripts/vscripts/addon_game_mode.lua` и `server.lua` — основная серверная логика и `Server:SendRequest`.
- `game/overvodka/scripts/vscripts/store.lua`, `quests.lua`, `vote.lua`, `events.lua` — пример взаимодействий с внешним API и CustomNetTables.
- `content/overvodka/panorama/layout/custom_game/custom_ui_manifest.xml` — манифест UI.

### Core gameplay (Lua)
- `vscripts/` (heroes, abilities, items, modifiers)
- Typical patterns:
  - abilities: `heroes/<hero>/<hero>_<spell>.lua`
  - shared: `modifiers/`, `utils/`, `modifier_generic_<name>.lua`

### KV / data
- `npc_abilities_custom.txt`
- `npc_items_custom.txt`
- `npc_heroes_custom.txt`
- `npc_units_custom.txt`
- `game/scripts/npc/`

### Localization
- `resource/addon_<lang>.txt`
- `panorama/localization/addon_<lang>.txt`
- Keys:
  - `dota_tooltip_ability_<name>`, `_description`
  - `dota_tooltip_modifier_<name>`, `_description`
  - shard/scepter keys as dedicated entries

### Panorama UI
- `panorama/layout/custom_game/` (XML)
- `panorama/scripts/custom_game/` (JS)
- `panorama/styles/custom_game/` (CSS)
- `content/overvodka/panorama/layout/custom_game/custom_ui_manifest.xml` (if used)

### UI ↔ server sync primitives
- Commands: CustomGameEventManager events (Panorama → Server)
- State: CustomNetTables (Server → Panorama)

3) Какие документы уже есть (и где их читать)
- `AGENT_RULES.md` — обязательные код-стандарты и anti-prompts.
- `agent-config.json` — машинная конфигурация с точками входа и разрешёнными источниками.
- `api_contract.json` — машинный контракт HTTP API (создан по `api.js`).
- `endpoint_map.json` — где в Lua вызываются endpoint'ы из API.

4) Ключевые вещи, которые агент всегда должен делать
- Всегда сверять все изменения с `AGENT_RULES.md`.
- При изменении Lua: вставлять полные патчи (diff), указывать путь/класс и `LinkLuaModifier` если добавляется модификатор.
- При добавлении/изменении endpoint'ов: обновить `api_contract.json` и `endpoint_map.json`.

5) Что спросить разработчику перед изменением
- Какая точная цель правки (файл/функция)?
- Где лежит соответствующее KV / локализация (path)?
- Какие `SpecialValue` уже существуют в ability KV?
- Есть ли изменения в внешнем API (`api.js`) или ключах (SERVER_KEY)?

6) Быстрые команды для локальной проверки
Если хотите поднять mock-server на основе `api.js`, используйте Node/Express (см. `worstup_server`):

```bash
# Запуск (пример):
cd worstup_server
npm install
NODE_ENV=development node server.js
```

7) Чек-лист для PR/изменений
- Вставил `if not IsServer() then return end` в серверные хуки — да/нет?
- Проверил `GetAbsOrigin()` vs `GetOrigin()` — нет `GetOrigin()` в проде.
- Все таймеры имеют условия завершения или `Timers:RemoveTimer` — да/нет?
- Все партиклы уничтожаются и освобождаются — да/нет?
- Нет хранения “голых” entity handles без `IsValidEntity()`/`IsNull()` — да/нет?

8) Куда добавлять знания/доки
- Расширяйте `AGENT_RULES.md` и `AGENT_ONBOARDING.md` по мере появления новых практик.
