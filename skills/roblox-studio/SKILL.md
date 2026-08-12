---
name: roblox-studio
description: Разработка игр в Roblox Studio через MCP: перевод запроса в план, Luau, механики, VFX/SFX, поиск DataModel, автономная проверка и безопасный release workflow.
license: MIT
metadata:
  version: 5.2.0
---

Работай с Roblox Studio как проверяемый инженерный агент. Не угадывай состояние проекта и не генерируй большой каркас до разведки.

## Маршрут

1. **Interpret:** переведи запрос в goal, player action, state change, ownership, feedback, failure cases, proof и out of scope. Если проект не задаёт иное, используй мультяшный mobile-first UI для детской аудитории.
2. **Inspect:** проверь Studio mode/capabilities, карту DataModel, существующие objects/scripts/references/require/tags/attributes и Output. Для большого проекта используй `project-search.md`.
3. **Plan:** выбери один playbook, опиши data schema, one writer per domain value, public API, remote contract, acceptance criteria и checkpoint. Незнакомый API/asset/capability сначала проверь.
4. **Change:** сделай минимальный vertical slice, затем проверку. После yield перепроверь player, Instance и state. Не повторяй операцию без проверки результата.
5. **Verify:** DataModel/Properties, Script Analysis, Output/F9, happy/negative/repeat/respawn/leave/reconnect/two-client tests, mobile UI и performance по доступности инструментов.
6. **Recover:** при критической ошибке остановись, сохрани stack trace, hard reset и откати последний change-set или пометь новый объект `_draft`. После двух одинаковых безрезультатных попыток измени гипотезу.

## Decision rules

| Вопрос | Выбор |
|---|---|
| Состояние игры, деньги, урон, права, покупки? | Server authority, клиент только просит/показывает |
| Связь client/server? | `RemoteEvent` по умолчанию; `UnreliableRemoteEvent` только для частого некритичного визуального потока; `RemoteFunction` только когда синхронный ответ действительно нужен и timeout/отказ безопасны |
| UI/layout? | Scale для responsive части, Offset допустим для фиксированных пиксельных элементов; constraints и safe area проверять |
| Shared API или config? | ModuleScript; событие между скриптами одной стороны? BindableEvent/BindableFunction |
| Edit или Play? | DataModel меняй в Edit; runtime проверяй в Play/Run, не считай runtime-правки сохранёнными |
| Незнакомый API? | Creator Hub research, затем минимальный probe |
| Доступна capability? | используй; недоступна? fallback и `not tested`, без выдуманного evidence |
| Новый VFX/SFX? | event contract, asset ownership, anticipation/action/impact, cleanup/pooling, fallback |

## Non-negotiables

- Сервер владеет критичным состоянием и валидирует входные данные.
- Новый Luau-файл начинается с `--!strict`; Script Analysis нельзя прятать пустым `pcall` или `:: any` без причины.
- У connections, Instances, VFX и Sounds есть lifecycle/cleanup plan.
- Не удаляй чужие объекты без согласования.
- Не говори `готово` без evidence либо честного `not tested`.

## Progressive disclosure

Загружай только нужные references: запрос `request-translation.md`; поиск `project-search.md`; Luau `luau-mental-model.md` и `ai-failure-patterns.md`; Roblox semantics `roblox-semantics.md`; механика `mechanics-reconstruction.md`/`mechanics-patterns.md`; VFX/SFX `vfx-sfx-craft.md`; тесты `test-matrix.md`/`autonomous-debugging.md`; API/capabilities `api-research.md`/`capability-detection.md`; release `release-readiness.md`.

## Report

Укажи interpretation, изменённые пути, доказательства, `pass/fail/not tested`, ограничения и следующий ручной шаг. Полный набор guides остаётся доступен, но не загружай его целиком без причины.