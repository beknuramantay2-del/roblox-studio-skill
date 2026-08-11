# roblox-studio-skill

Agent Skill для разработки в **Roblox Studio через MCP**.

Что внутри: единый набор правил, по которым ИИ-агент делает мультяшный детский UI, чистые модульные скрипты на Luau, игровые системы, модели и автономную проверку результата.

Скилл написан по стандарту [Agent Skills](https://agentskills.io/specification), поэтому подходит для **Claude / Claude Code**, **OpenCode** и **Codex**.

## Главное в v3

- Поиск по DataModel: имя, класс, содержимое, references, `require`, теги и зависимости.
- Карта проекта до изменений, проверка состояния Studio и проверка дубликатов.
- Надёжный цикл `Inspect → Plan → Change → Verify → Recover` с hard reset и защитой от зацикливания.
- Автономная отладка через Output, F9, Script Analysis и `ScriptDebuggerService`, если доступен.
- Автономный Playtest: клиент/сервер, повтор сценария, screenshots, mobile, controller и multiplayer, если поддерживается MCP.
- API research перед незнакомыми методами, а не генерация сигнатуры из памяти.
- Шаблоны Inventory, Shop, Quest, Dialogue, Combat, Round, Lobby, NPC, Boss, Tycoon, Simulator, Obby, Tower Defense, Pet, Trading и Crafting.

## Структура

```
skills/roblox-studio/
├── SKILL.md                      точка входа и обязательный цикл агента
├── references/                   35 гайдов, грузятся по необходимости
│   ├── project-search.md         карта проекта, поиск, references и зависимости
│   ├── agent-state-loop.md       транзакции, hard reset, откат, антизацикливание
│   ├── autonomous-debugging.md   Output, stack trace, breakpoints, runtime state
│   ├── playtesting-and-visual.md Play, Run, input, multiplayer, screenshots, mobile
│   ├── api-research.md           актуальная документация и проверка сигнатур
│   ├── system-templates.md       каркасы типовых игровых систем
│   ├── mcp-workflow.md           безопасная работа в живой сессии Studio
│   ├── engine-basics.md          Explorer, Properties, типы скриптов, client/server
│   ├── api-and-docs.md           поиск API, deprecated, Script Analysis
│   ├── datatypes.md              Vector3, CFrame, UDim2, Color3, случайность
│   ├── architecture.md           структура проекта и модулей
│   ├── luau-style.md             стиль кода и типизация
│   ├── ui-style.md               мультяшный визуальный язык
│   ├── ui-implementation.md      адаптивность, мобилки, safe area
│   ├── ui-screens.md              HUD, загрузка, настройки, инвентарь, магазин
│   ├── building-models.md        3D-сборка, пивоты, теги, атрибуты
│   ├── physics-and-raycast.md    физика, collision groups, raycast, streaming
│   ├── input-and-interaction.md  ввод, prompts, твины, циклы, Debris
│   ├── character-and-camera.md   Humanoid, анимации, камера, движение, статусы
│   ├── combat.md                 здоровье, урон, оружие, хитбоксы
│   ├── npc-and-ai.md             NPC, pathfinding, боссы, диалоги
│   ├── economy-and-progression.md валюта, инвентарь, магазин, квесты, XP
│   ├── rounds-and-teams.md       раунды, лобби, спавн, чекпоинты, команды
│   ├── data-and-services.md      DataStore, лидерборды, MemoryStore, телепорты
│   ├── monetization.md           Game Passes, Developer Products, бейджи
│   ├── audio-visual.md           звук, музыка, свет, атмосфера, VFX
│   ├── procedural-generation.md  генерация карт и контента
│   ├── genre-playbooks.md        симулятор, тайкун, обби, TD, FPS, RPG, survival
│   ├── bug-prevention.md         анти-баг чек-лист
│   ├── debugging.md              ручная диагностика и утечки
│   ├── security.md               серверная безопасность и античит
│   ├── performance.md            FPS, память, сеть и MicroProfiler
│   ├── testing.md                итоговая проверка
│   ├── admin-and-moderation.md   права, фильтрация, баны
│   ├── existing-projects.md      зависимости, code review, рефакторинг
│   └── big-tasks.md              от ТЗ до системы
└── snippets/                     готовые модули с --!strict
```

## Установка

```bash
git clone https://github.com/beknuramantay2-del/roblox-studio-skill.git
cd roblox-studio-skill
bash scripts/install.sh          # глобально
bash scripts/install.sh --local  # только текущий проект
```

Пути: Claude Code `~/.claude/skills/roblox-studio/`, OpenCode `~/.config/opencode/skills/roblox-studio/` или `.opencode/skills/roblox-studio/`, Codex/прочие `.agents/skills/roblox-studio/`. В проекте также можно использовать `.claude/skills/`.

## Ограничения

Debugger, Playtest Agent, screenshots, device simulation и virtual input зависят от версии Roblox Studio и конкретного MCP-клиента. Скилл требует фактическую проверку и не позволяет агенту выдавать недоступную проверку за выполненную.

## Подключение Studio

MCP-сервер встроен в Roblox Studio. Подключи клиента и держи нужный `.rbxl` открытым: агент работает с активной сессией.

## Лицензия

MIT
