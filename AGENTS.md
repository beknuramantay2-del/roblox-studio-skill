# AGENTS.md

Этот репозиторий содержит Agent Skill для разработки в Roblox Studio через MCP.

Для Roblox-задачи сначала загрузи `skills/roblox-studio/SKILL.md`. Протокол: `Interpret → Inspect → Plan → Change → Verify → Recover`.

Перед кодом: переведи запрос в implementation brief, проверь Studio mode и capabilities, составь карту DataModel, найди зависимости/references, контракт, schema, один writer на domain value и checkpoint.

Для механики сначала собери vertical slice. Для VFX/SFX проверь recipe, timing, asset contract, cleanup и fallback. После каждого yield повторно проверь player, Instance и state.

После каждого микрошагa: DataModel/Properties, Script Analysis и узкий тест. Перед отчётом пройди failure-pattern preflight, test matrix и release gates; укажи evidence как `pass/fail/not tested`.

После критической ошибки остановись, hard reset и rollback последнего change-set. Не продолжай вслепую, не повторяй операцию без проверки и не создавай огромный каркас вместо доказуемого среза.

Подробности загружай из `references/` по текущей ветке. Установленные копии не редактируй: source of truth находится в `skills/roblox-studio/`.