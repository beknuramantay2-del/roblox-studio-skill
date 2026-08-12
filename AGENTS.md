# AGENTS.md

Этот репозиторий содержит Agent Skill для разработки в Roblox Studio через MCP.

Для Roblox-задачи сначала загрузи `skills/roblox-studio/SKILL.md`. Обязательный протокол: `Inspect → Plan → Change → Verify → Recover`.

Перед кодом: проверь Studio mode и capabilities, составь короткую DataModel map, найди зависимости, контракт, схему данных и checkpoint. Для механики сначала опиши core loop и собери vertical slice. Для VFX/SFX проверь asset contract, timing, cleanup и fallback.

После каждого микрошагa: проверь DataModel/Properties, Script Analysis и узкий тест. Перед отчётом пройди test matrix и release gates, укажи evidence как `pass/fail/not tested`.

После критической ошибки остановись, сделай hard reset и откати последний change-set. Не продолжай вслепую, не повторяй операцию без проверки и не создавай огромный каркас вместо проверяемого среза.

Подробности загружай из `references/` по текущей ветке. Установленные копии не редактируй: source of truth находится в `skills/roblox-studio/`.