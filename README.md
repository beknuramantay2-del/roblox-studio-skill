# roblox-studio-skill

Agent Skill для разработки игр в **Roblox Studio через MCP**. Подходит для Claude/Claude Code, OpenCode и Codex.

## v5: что добавилось

- **Mechanics reconstruction:** core loop, entities, states, authority, failure cases и vertical slices для воссоздания механик по ТЗ или референсу.
- **VFX/SFX craft:** recipes для ParticleEmitter, Beam, Trail, timing, impact, audio layers, pooling, fallback и asset contracts.
- **Implementation playbooks:** отдельный порядок для механики, UI, NPC/boss, экономики и изменений существующей системы.
- **Medium-model tactics:** working-memory card, micro-steps, anti-drift и stop conditions.
- **Test matrix:** client/server, mobile, touch, controller, data failure, NPC, VFX/SFX, performance soak и regression evidence.

Вместе с v4 это даёт не просто справочник, а рабочий протокол: **исследовать → спроектировать → собрать vertical slice → проверить → расширить**.

## Установка

```bash
git clone https://github.com/beknuramantay2-del/roblox-studio-skill.git
cd roblox-studio-skill
bash scripts/install.sh          # глобально
bash scripts/install.sh --local  # текущий проект
```

Пути: Claude Code `~/.claude/skills/roblox-studio/`, OpenCode `~/.config/opencode/skills/roblox-studio/` или `.opencode/skills/roblox-studio/`, Codex/прочие `.agents/skills/roblox-studio/`. В проекте можно использовать `.claude/skills/`.

## Что тестировать после установки

1. `найди все зависимости магазина и составь карту проекта`;
2. `создай одну механику сбора монетки с мультяшным VFX/SFX и проверь vertical slice`;
3. `сделай NPC с телеграфом атаки, проверь respawn, два клиента и недоступные MCP-возможности`.

Ожидаемый ответ агента должен содержать карту, изменённые пути, evidence и `pass/fail/not tested`. Если модель сразу создаёт десятки файлов, она игнорирует скилл.

## Ограничения

Debugger, Playtest Agent, screenshots, device simulation, virtual input и multiplayer automation зависят от версии Roblox Studio и MCP-клиента. Скилл обязан использовать fallback и не выдавать недоступную проверку за выполненную.

## Лицензия

MIT
