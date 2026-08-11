# roblox-studio-skill

Agent Skill для разработки в **Roblox Studio через MCP**.

Что внутри: единый набор правил, по которым ИИ-агент делает

- **мультяшный, детский, яркий UI** с простыми читаемыми шрифтами,
- **чистые скрипты на Luau** (модульная архитектура, строгая типизация),
- **игровые системы**: бой, NPC и ИИ, экономика, квесты, раунды, сохранения, монетизация,
- **модели и сборку в Studio** без сломанных пивотов и якорей,
- и главное — **без багов**: чек-листы утечек памяти, гонок загрузки, безопасности remote-ов и производительности.

Скилл написан по стандарту [Agent Skills](https://agentskills.io/specification), поэтому работает сразу в **Claude / Claude Code**, **opencode** и **Codex**.

## Структура

```
skills/roblox-studio/
├── SKILL.md                      точка входа: рабочий цикл, 7 правил, маршрутизация
├── references/                   21 гайд, грузятся по необходимости
│   ├── mcp-workflow.md           безопасная работа в живой сессии Studio
│   ├── engine-basics.md          Explorer, Properties, типы скриптов, клиент-сервер, remote
│   ├── api-and-docs.md           поиск в API, deprecated, Script Analysis
│   ├── datatypes.md              Vector3, CFrame, UDim2, Color3, случайность
│   ├── architecture.md           структура проекта и модулей
│   ├── luau-style.md             стиль кода и типизация
│   ├── ui-style.md               мультяшный визуальный язык
│   ├── ui-implementation.md      адаптивность, мобилки, safe area
│   ├── ui-screens.md             HUD, загрузка, настройки, инвентарь, магазин, туториал
│   ├── building-models.md        3D-сборка, пивоты, теги, атрибуты
│   ├── physics-and-raycast.md    физика, collision groups, raycast, network ownership
│   ├── input-and-interaction.md  ввод, промпты, твины, циклы
│   ├── character-and-camera.md   Humanoid, анимации, камера, движение, статусы
│   ├── combat.md                 здоровье, урон, оружие, хитбоксы
│   ├── npc-and-ai.md             NPC, состояния, pathfinding, боссы, диалоги
│   ├── economy-and-progression.md валюта, инвентарь, магазин, квесты, XP, баланс
│   ├── rounds-and-teams.md       раунды, лобби, спавн, чекпоинты, команды
│   ├── data-and-services.md      DataStore, лидерборды, MemoryStore, телепорты
│   ├── monetization.md           Game Passes, Developer Products, ProcessReceipt, бейджи
│   ├── audio-visual.md           звук, музыка, свет, атмосфера, VFX, погода
│   ├── procedural-generation.md  генерация карт и контента
│   ├── genre-playbooks.md        симулятор, тайкун, обби, TD, FPS, RPG, survival, horror
│   ├── bug-prevention.md         главный анти-баг чек-лист
│   ├── debugging.md              чтение Output, поиск причин, охота за утечками
│   ├── security.md               не доверяй клиенту
│   ├── performance.md            бюджеты кадра и памяти
│   ├── testing.md                проверка перед сдачей
│   ├── admin-and-moderation.md   права, фильтрация, баны
│   ├── existing-projects.md      чужой проект, зависимости, code review, рефакторинг
│   └── big-tasks.md              от ТЗ до системы
└── snippets/                     готовые модули с --!strict
    ├── Theme.lua                 палитра, шрифты, тайминги
    ├── CartoonButton.lua         кнопка в стиле, с пружинкой
    ├── Trove.lua                 уборка соединений
    ├── RemoteGuard.lua           валидация и кулдауны remote
    ├── DataStoreService.lua      безопасное сохранение
    └── ServiceTemplate.lua       каркас новой системы
```

## Установка

```bash
git clone https://github.com/beknuramantay2-del/roblox-studio-skill.git
cd roblox-studio-skill
bash scripts/install.sh          # ставит глобально, для всех проектов
bash scripts/install.sh --local  # ставит только в текущий проект
```

Или вручную скопируй папку `skills/roblox-studio` в одно из мест:

| Клиент | Путь |
| --- | --- |
| Claude Code (глобально) | `~/.claude/skills/roblox-studio/` |
| Claude Code (проект) | `.claude/skills/roblox-studio/` |
| opencode (глобально) | `~/.config/opencode/skills/roblox-studio/` |
| opencode (проект) | `.opencode/skills/roblox-studio/` |
| Codex и прочие | `.agents/skills/roblox-studio/` плюс упоминание в `AGENTS.md` |

opencode также читает `.claude/skills/`, так что одной установки обычно хватает на оба клиента.

В Claude.ai скилл добавляется как папка через настройки Skills: загрузи `skills/roblox-studio` целиком.

## Подключение Studio

MCP-сервер встроен в Roblox Studio. Включи его в настройках Studio, подключи клиента (`claude mcp add`, `opencode.json` или `~/.codex/config.toml`) и держи нужный `.rbxl` открытым: агент работает с той сессией, которая открыта прямо сейчас.

## Лицензия

MIT
