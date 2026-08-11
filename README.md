# roblox-studio-skill

Agent Skill для разработки в **Roblox Studio через MCP**.

Что внутри: единый набор правил, по которым ИИ-агент делает

- **мультяшный, детский, яркий UI** с простыми читаемыми шрифтами,
- **чистые скрипты на Luau** (модульная архитектура, строгая типизация),
- **модели и сборку в Studio** без сломанных пивотов и якорей,
- и главное — **без багов**: чек-листы утечек памяти, гонок загрузки, безопасности remote-ов и производительности.

Скилл написан по стандарту [Agent Skills](https://agentskills.io/specification), поэтому работает сразу в **Claude / Claude Code**, **opencode** и **Codex**.

## Структура

```
skills/roblox-studio/
├── SKILL.md                  # точка входа: рабочий цикл + маршрутизация
├── references/               # подробные гайды, грузятся по необходимости
│   ├── mcp-workflow.md       # как безопасно работать через Studio MCP
│   ├── architecture.md       # структура проекта и модулей
│   ├── luau-style.md         # стиль кода и типы
│   ├── ui-style.md           # мультяшный визуальный язык (палитра, шрифты, анимации)
│   ├── ui-implementation.md  # Scale/Offset, адаптивность, мобилки
│   ├── building-models.md    # 3D-сборка, пивоты, теги, атрибуты
│   ├── bug-prevention.md     # главный анти-баг чек-лист
│   ├── security.md           # не доверяй клиенту
│   ├── performance.md        # бюджеты кадра и памяти
│   └── testing.md            # проверка перед сдачей
└── snippets/                 # готовые шаблоны кода
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
| Codex / прочие | `.agents/skills/roblox-studio/` + строчка про скилл в `AGENTS.md` |

opencode также читает `.claude/skills/`, так что одной установки обычно хватает на оба клиента.

В Claude.ai скилл добавляется как папка через настройки Skills — просто загрузи `skills/roblox-studio` целиком.

## Подключение Studio

MCP-сервер встроен в Roblox Studio. Включи его в настройках Studio, подключи клиента (`claude mcp add`, `opencode.json` или `~/.codex/config.toml`) и держи нужный `.rbxl` открытым — агент работает с той сессией, которая открыта прямо сейчас.

## Лицензия

MIT
