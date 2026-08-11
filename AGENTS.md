# AGENTS.md

Этот репозиторий содержит Agent Skill для разработки в Roblox Studio через MCP.

## Обязательное поведение

Для Roblox-задачи сначала загрузи `skills/roblox-studio/SKILL.md` и следуй циклу `Inspect → Plan → Change → Verify → Recover`.

Перед изменением: проверь режим Studio и capability matrix, составь короткую карту DataModel, найди существующие объекты/скрипты/references, проверь дубликаты, контракт, схему данных и checkpoint.

После изменения: проверь DataModel/Properties, Script Analysis, Output/F9, повторяемый fixture и Playtest. Для крупной задачи пройди release gates и отчитай `pass/fail/not tested`.

После критической ошибки остановись, сделай hard reset и откати только последний change-set. Не продолжай вслепую и не повторяй операцию без проверки результата.

Используй Data Model Search subagent для длинной разведки, если он доступен. Если debugger, screenshots, device simulation, multiplayer или virtual input недоступны, используй fallback и честно пометь ограничение.

Подробности загружай из `references/` только по ветке текущей задачи. Source of truth находится в `skills/roblox-studio/`, установленные копии не редактируй.