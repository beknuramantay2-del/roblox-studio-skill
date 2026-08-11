# AGENTS.md

Этот репозиторий содержит Agent Skill для разработки в Roblox Studio через MCP.

## Обязательное поведение

Для любой задачи по Roblox сначала загрузи `skills/roblox-studio/SKILL.md`. Он задаёт цикл `Inspect → Plan → Change → Verify → Recover`.

Перед изменением: проверь режим Studio, составь короткую карту DataModel, найди существующие объекты/скрипты/references и проверь отсутствие дубликатов.

После изменения: проверь Explorer и Properties, Script Analysis, Output/F9 и пользовательский Playtest. Не продолжай после критической ошибки, не повторяй операцию без проверки результата и делай hard reset при неожиданном состоянии.

Если доступен отдельный Data Model Search subagent, используй его для длинного исследования, чтобы не засорять контекст основного агента. Если debugger, screenshots, device simulation, multiplayer или virtual input недоступны, честно отмечай это и не выдумывай результат.

Подробные правила находятся в `references/`; загружай только ветки, относящиеся к текущей задаче. Установленные копии не редактируй: source of truth находится в `skills/roblox-studio/`.