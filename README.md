# roblox-studio-skill

Agent Skill для разработки игр в **Roblox Studio через MCP**. Подходит для Claude/Claude Code, OpenCode и Codex.

## v5.1: защита от недопонимания и типичных ошибок

Добавлено то, где средние модели чаще всего тупят:

- перевод русского/размытого запроса в implementation brief;
- failure-pattern preflight для правдоподобно неправильного Luau и Roblox-кода;
- семантика Edit vs runtime DataModel, Starter containers, replication, signal ordering, yield и Streaming;
- ментальная модель Luau: tables, nil, `:` vs `.`, metatables, optional types, task ordering и typed results;
- архитектурные решения: ModuleScript vs BindableEvent vs Remote, snapshot + events, один writer, idempotency и state transitions;
- библиотека паттернов Interaction, Combat, Simulator, NPC, Round, Trading, Crafting, Abilities и Loading;
- обязательная проверка после yield и доказательство результата, а не только успешная компиляция.

Roblox-документация подтверждает ключевые основания: RemoteEvent не yield, RemoteFunction yield, `UnreliableRemoteEvent` подходит только для некритичных непрерывных данных, сервер владеет состоянием, а DataModel Search и testing tools нужно использовать по capability, не выдумывать.

## Как проверить среднюю модель

1. `добавь в существующую игру питомцев, но сначала составь implementation brief и найди все связанные системы`;
2. `сделай меч с hitbox, cooldown, hit VFX/SFX и проверь, что клиент не может подделать урон`;
3. `почему после респавна кнопка срабатывает дважды, найди причину и докажи исправление`;
4. `сделай simulator loop: collect, sell, upgrade, unlock, сначала один vertical slice`.

Плохой результат: модель сразу создаёт десятки файлов и говорит «готово». Хороший: interpretation, карта проекта, контракт, маленький change-set, evidence и `pass/fail/not tested`.

## Установка

```bash
git clone https://github.com/beknuramantay2-del/roblox-studio-skill.git
cd roblox-studio-skill
bash scripts/install.sh          # глобально
bash scripts/install.sh --local  # текущий проект
```

Пути: Claude Code `~/.claude/skills/roblox-studio/`, OpenCode `~/.config/opencode/skills/roblox-studio/` или `.opencode/skills/roblox-studio/`, Codex/прочие `.agents/skills/roblox-studio/`. В проекте можно использовать `.claude/skills/`.

## Ограничения

Debugger, Playtest Agent, screenshots, device simulation, virtual input и multiplayer automation зависят от версии Roblox Studio и MCP-клиента. Скилл обязан использовать fallback и не выдавать недоступную проверку за выполненную.

## Лицензия

MIT
