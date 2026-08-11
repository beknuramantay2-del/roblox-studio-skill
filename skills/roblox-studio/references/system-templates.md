# Шаблоны игровых систем

Средней модели полезнее дать проверенный каркас и точки расширения, чем просить придумать архитектуру с нуля. Но шаблон не заменяет разведку проекта и тестирование.

## Базовые шаблоны

Используй существующие модули и не создавай второй экземпляр: `InventoryService`, `ShopService`, `QuestService`, `DialogueService`, `CombatService`, `RoundService`, `LobbyService`, `MatchmakingService`, `TycoonService`, `SimulatorService`, `ObbyService`, `TowerDefenseService`, `NpcService`, `BossService`, `DataService`, `LeaderboardService`, `DailyRewardService`, `LevelService`, `AbilityService`, `WeaponService`, `PetService`, `TradingService`, `CraftingService`.

Для каждой системы фиксируй:

- серверный владелец состояния;
- публичный API модуля;
- конфиг и типы;
- remote-контракт;
- клиентский controller;
- очистку connections/instances;
- сохранение и миграцию данных;
- позитивные, негативные и edge-case тесты.

## Выбор каркаса

- Inventory: item definitions в `Shared/Config`, counts в DataStore, серверная выдача, UI grid.
- Shop: whitelist id, серверная цена, атомарная покупка, сохранение после покупки.
- Quest/Dialogue: data-driven nodes, server validates transition, client renders.
- Combat/Weapon/Ability: client input/FX, server cooldown, distance, target and damage validation.
- Round/Lobby/Matchmaking: state machine, participant snapshot, timeout, cleanup.
- NPC/Boss: server state machine, throttled target search, pathfinding fallback, telegraphed attacks.
- Tycoon/Simulator: numeric production, not physical spam, saved unlock IDs, server economy.
- Obby: persistent checkpoints, fast respawn, server movement sanity checks.
- Tower Defense: wave budget, fixed paths when possible, throttled targeting.
- Pet/Trading/Crafting: server ownership, atomic swaps, whitelist recipes, explicit confirmation for irreversible actions.
- Data/Leaderboard/Daily/Level: `pcall`, retry, migration, UTC dates, cached reads, no save after failed load.

Сначала собери минимальный вертикальный срез одной системы, запусти тест, затем добавляй расширения. Не создавай все перечисленные системы только потому, что они есть в каталоге.