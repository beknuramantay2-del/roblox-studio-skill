# roblox-studio-skill

Agent Skill для разработки в **Roblox Studio через MCP**. Подходит для Claude/Claude Code, OpenCode и Codex.

## v4: что добавилось

- Контракты систем: схема данных, server ownership, remote args/results/limits и acceptance criteria.
- Capability detection: агент проверяет, доступны ли Data Model Search, debugger, screenshots, Playtest, device simulation и multiplayer APIs.
- Source control и rollback: Studio Version History, Script Sync, Rojo, Team Create, checkpoints и единый source of truth.
- Asset pipeline для моделей, анимаций, звуков, изображений, ownership, preload и fallback.
- Повторяемые test fixtures для happy path, отказов, spam, respawn, leave, multiplayer и DataStore failure.
- Observability: структурированные логи, correlation id, ошибки без пустого `pcall` и измерения до/после.
- Accessibility и localization: touch targets, controller, reduced motion, контраст, длинные строки и RTL.
- Safety/policy для детской игры: фильтрация текста, privacy, UGC, content maturity и честная монетизация.
- Release gates: scope, DataModel, code, security, data, UX, runtime, performance, safety и recovery.

## Структура

```text
skills/roblox-studio/
├── SKILL.md                        v4 workflow и маршрутизация
├── references/                     guides, загружаемые по необходимости
│   ├── project-search.md           карта DataModel и зависимости
│   ├── agent-state-loop.md         транзакции, hard reset, откат, антизацикливание
│   ├── project-contracts.md        схемы данных и remote-контракты
│   ├── capability-detection.md     capability matrix и fallback
│   ├── source-control-and-versioning.md checkpoints, sync и rollback
│   ├── asset-pipeline.md           ассеты, ownership, preload, fallback
│   ├── test-fixtures.md            повторяемые тестовые стартовые условия
│   ├── observability.md             логи, метрики и диагностика
│   ├── accessibility-and-localization.md доступность и локализация
│   ├── safety-and-policy.md        безопасность, privacy, UGC, policy
│   ├── release-readiness.md        release gates и Definition of Done
│   ├── autonomous-debugging.md     Output, stack trace, debugger
│   ├── playtesting-and-visual.md   Play, Run, peers, screenshots, mobile
│   ├── api-research.md             актуальная проверка Roblox API
│   ├── system-templates.md         каркасы игровых систем
│   └── ...                         остальные guides по Studio, Luau и геймплею
└── snippets/                       готовые модули с --!strict
```

## Установка

```bash
git clone https://github.com/beknuramantay2-del/roblox-studio-skill.git
cd roblox-studio-skill
bash scripts/install.sh          # глобально
bash scripts/install.sh --local  # текущий проект
```

Пути: Claude Code `~/.claude/skills/roblox-studio/`, OpenCode `~/.config/opencode/skills/roblox-studio/` или `.opencode/skills/roblox-studio/`, Codex/прочие `.agents/skills/roblox-studio/`. В проекте можно использовать `.claude/skills/`.

## Ограничения

Debugger, Playtest Agent, screenshots, device simulation, virtual input и multiplayer automation зависят от версии Roblox Studio и MCP-клиента. Скилл требует доказательство и помечает недоступные проверки как `not tested`, а не выдумывает результат.

## Лицензия

MIT
