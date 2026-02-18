# Правила и инструкции для агента (OVERVODKA)

## 0) Контекст проекта
- Серверный код: Lua (vscripts). UI: Panorama JS (HTML/XML/CSS). Backend/store: Node.js (Express) + MySQL.
- Часто используются: создание героев/способностей, модификаторы, таланты/аспекты, парсеры KV/локализаций.
- Код и стиль: аккуратные null-check, server guards, чистые таймеры/партиклы, отсутствие утечек сущностей.

## 1) Обязательные код-стандарты (не нарушать)

Lua (сервер)
- Всегда: `if not IsServer() then return end` в серверных хуках.
- Всегда: использовать `GetAbsOrigin()` (не `GetOrigin()`).
- Юниты: создаём через `CreateUnitByName(...)`.
- Задержки/таймеры: использовать `Timers:CreateTimer(...)`.
- Кулдауны/ресурсы: использовать `UseResources(...)`, не применять костыли на `GameModeEntity`.
- `Modifiers`: отдельные классы; реализовывать `DeclareFunctions()`, `CheckState()`, `OnCreated`/`OnDestroy`.
- Партиклы: обязательно `ParticleManager:DestroyParticle` (если нужно) и `ParticleManager:ReleaseParticleIndex` — никаких утечек. Prefer `self:AddParticle(...)` for modifier-owned particles.
- Не хранить «голые» entity handles без проверок `IsValidEntity()` / `IsNull()`.
- В контекстах motion modifier: не применять `SetForwardVector` (ломает движение), использовать `FaceTowards` или корректно обновлять после перемещения.

Доп. предпочтение по transmitters
- В модификаторах с кастомными передатчиками переиспользовать кешированную таблицу `self._txData` в `AddCustomTransmitterData`, а не создавать новый литерал таблицы при каждом вызове — это снижает аллокации при частых `SendBuffRefreshToClients`.

## 2) Как я хочу, чтобы ты отвечал
- Если даёшь код: целиком готовый кусок, с указанием пути файла, имени класса, `LinkLuaModifier` сверху и куда подключать.
- Если меняешь существующий файл: показывай дифф / заменяемые функции (что удалить / что вставить).
- Если предлагаешь механику: указывай сложность `сложно/средне/легко` и почему (на основании Dota 2 реализации).
- Не предлагай несуществующие методы Dota API; при сомнении отмечай это и давай проверяемую альтернативу.
- Проверяемые API: https://moddota.com/api/#!/vscripts и https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Panorama/Javascript/API

## 3) Частые ошибки — запрещено
- Не оставлять таймеры без удаления/условий завершения.
- Не допускать утечек партиклов и сущностей.

## 4) Что ты должен спросить в начале (если данных нет)
Минимум необходимого:
- путь/имя файла (куда вносить изменения),
- где лежит KV/локализация,
- какие `SpecialValue`/ключи уже есть в ability KV.
Если чего-то нет — делай разумные дефолты и помечай их явно в ответе.

## 5) Источники знаний (рекомендуемые)
- Valve / Dota 2 Workshop Tools docs (Panorama API)
- moddota.com API (Dota 2 Lua API)
- Официальные примеры из Workshop Tools и существующие популярные аддоны

## 6) Формат машинной конфигурации
- Дополнительно в `agent-config.json` лежат: `allowedSources`, `forbiddenActions`, `entrypoints`, `codeStyle`.

## 7) Panorama ↔ Lua contract (how we wire things)
Use **events for commands** and **net tables for state**.

**Panorama → Server (command)**
- `GameEvents.SendCustomGameEventToServer("event_name", payload)`

**Server side listener**
- `CustomGameEventManager:RegisterListener("event_name", function(_, payload) ... end)`

**Server → Clients (notifications / one-shot)**
- `CustomGameEventManager:Send_ServerToPlayer(player, "event_name", payload)`
- `CustomGameEventManager:Send_ServerToAllClients("event_name", payload)`

**State replication (persistent / UI reads)**
- `CustomNetTables:SetTableValue("table_name", key, value)`
- Panorama: `CustomNetTables.SubscribeNetTableListener("table_name", callback)`
- Panorama: `CustomNetTables.GetTableValue("table_name", key)`

Rule of thumb:
- If UI needs to “press a button” → **CustomGameEvent**.
- If UI needs to “show data / keep updated” → **CustomNetTables**.

## 8) KV + Localization are part of the change
Whenever adding/changing SpecialValues, ability behavior, shard/scepter, etc:
- Update KV (`npc_abilities_custom.txt` / items / heroes) accordingly.
- Update localization keys (tooltips, modifiers, shard/scepter descriptions).
- Keep tooltips concise: prefer one scepter/shard description key instead of many micro-keys.

---

Вопросы по правилам: если хотите расширить или добавить конкретные ленты CI/линтеров (lua-format, eslint для panorama), пришлите команды/конфиги или укажите, чтобы я добавил разумные дефолты.