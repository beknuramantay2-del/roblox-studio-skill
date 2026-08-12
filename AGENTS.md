# AGENTS.md

Для Roblox-задачи сначала загрузи `skills/roblox-studio/SKILL.md`. Он специально сделан компактным: не загружай все references сразу.

Следуй Interpret → Inspect → Plan → Change → Verify → Recover. Перед сложным решением используй `optimization-protocol.md`: confidence, contradiction check, cost control и evidence quality.

Проверяй benchmark-задачи из `benchmarks/roblox-medium-model.yaml` при изменении маршрутизации или корневых правил. Не считай документальный аудит доказательством runtime-работы.

После критической ошибки остановись, hard reset и rollback последнего change-set. Не редактируй установленные копии skill: source of truth находится в `skills/roblox-studio/`. 