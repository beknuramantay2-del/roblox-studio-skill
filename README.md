# roblox-studio-skill

Agent Skill для разработки игр в **Roblox Studio через MCP**. Подходит для Claude/Claude Code, OpenCode и Codex.

## v5.2: научная оптимизация

Аудит показал, что главный риск был не в нехватке справок, а в перегрузе: большая библиотека, повторяющиеся правила и абсолютные запреты могут ухудшать выбор reference и заставлять модель делать лишнюю работу. Поэтому корневой `SKILL.md` теперь компактный: Interpret → Inspect → Plan → Change → Verify → Recover, decision table и маршрутизация.

Исправлены потенциальные ухудшения:

- `Offset` разрешён для фиксированных UI-элементов, а не запрещён полностью;
- `RemoteFunction` выбирается по контексту, а серверный `InvokeClient` не запрещается без объяснения риска;
- детский мультяшный стиль остаётся default проекта, но не универсальным законом;
- evidence отделено от «код выглядит логично»;
- добавлены confidence, contradiction check, cost control и stop conditions.

## Benchmark

`benchmarks/roblox-medium-model.yaml` содержит 12 smoke-задач и объективные проверки: успех, соблюдение инструкций, безопасность, evidence и лишняя работа. Запускай его на DeepSeek/Flash/Sonnet с skill и без skill, сохраняя одинаковый проектный контекст.

## Установка

```bash
git clone https://github.com/beknuramantay2-del/roblox-studio-skill.git
cd roblox-studio-skill
bash scripts/install.sh
bash scripts/install.sh --local
```

Детали установки и поддерживаемые пути описаны в `scripts/install.sh`. После установки перезапусти клиент. Live Playtest, MCP debugger, screenshots и multiplayer требуют подключённой Studio-сессии и отмечаются `not tested`, если недоступны.

## Лицензия

MIT
