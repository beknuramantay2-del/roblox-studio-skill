---
name: roblox-studio
description: Разработка игр в Roblox Studio через MCP: детский мультяшный UI, Luau, механики по ТЗ, VFX/SFX, поиск DataModel, автономная отладка, playtesting и release gates для средних моделей.
license: MIT
metadata:
  version: 5.0.0
---

Ты работаешь с Roblox Studio через MCP для детской игры примерно 7-13 лет. Не угадывай состояние проекта и не генерируй огромный каркас вслепую: исследуй, собери контракт, сделай вертикальный срез и докажи результат.

## Обязательный цикл

`Inspect → Plan → Change → Verify → Continue`; при ошибке `InspectError → Recover → Verify`.

### Inspect

Проверь Studio mode и capability matrix. Составь короткую карту DataModel, найди существующие объекты, скрипты, references, `require`, tags, attributes и активные ошибки. Для длинного исследования используй Data Model Search, если он доступен.

### Plan

Разбей vague request на core loop, entities, states и systems. Для каждой системы зафиксируй server/client ownership, data schema/migration, public API, remote contract, acceptance criteria, edge cases и fallback. Если задача основана на игре-референсе, извлекай правила поведения, но не копируй защищённые ассеты или контент.

Выбери playbook из `references/implementation-playbooks.md` и существующий system template. Незнакомый API, asset id или Studio capability сначала проверь по документации/маленьким probe.

### Change

Сначала прочитай существующий код целиком. Делай микрошаги: один-два файла или небольшой идемпотентный пакет Instances, затем проверка. Для новой механики строй vertical slice: один путь от input до state/result/feedback. Для VFX/SFX синхронизируй anticipation, action, impact и cleanup, не связывай игровую логику с загрузкой ассета.

Веди working memory card: goal, mode, current system, last verified change, changed paths, open error, next action, required proof. Не повторяй операцию без проверки результата.

### Verify

Проверь DataModel/Properties, Script Analysis, Output/F9, happy path, negative path, spam, respawn, leave, two clients и regression. Для UI/VFX сделай screenshot или ручную viewport-проверку на narrow mobile и touch/controller. Для производительности измерь baseline, stressed case и soak, а не оптимизируй на глаз. Используй `references/test-matrix.md`.

Отчитай каждую проверку как `pass`, `fail` или `not tested` с evidence.

### Recover

После критической ошибки остановись, сохрани stack trace, сделай hard reset, откати только последний change-set или пометь новый объект `_draft`, затем повтори тот же тест. Если две попытки не дали нового результата, измени гипотезу или остановись для уточнения.

## Невзламываемые правила

1. Сервер владеет истиной: клиент не определяет валюту, предметы, урон, покупки, права, победы или сохранения.
2. У каждого connection, Instance, VFX и Sound есть cleanup/pooling план.
3. Новый Luau-файл начинается с `--!strict` и проходит Script Analysis.
4. UI mobile-first, доступный, локализуемый и мультяшный.
5. API, asset id и capability не выдумываются.
6. Ошибка не маскируется пустым `pcall`, удалением логов или бесконечными retry.
7. Не говори `готово`, пока есть evidence или честный `not tested`.

## Маршрутизация

- поиск/карта: `project-search.md`; состояние: `agent-state-loop.md`; средняя модель: `medium-model-tactics.md`;
- контракты/схемы: `project-contracts.md`; механики: `mechanics-reconstruction.md`; playbooks: `implementation-playbooks.md`;
- VFX/SFX: `vfx-sfx-craft.md`, `audio-visual.md`, `asset-pipeline.md`;
- тесты: `test-fixtures.md`, `test-matrix.md`, `playtesting-and-visual.md`, `autonomous-debugging.md`;
- API/capabilities/версии: `api-research.md`, `capability-detection.md`, `source-control-and-versioning.md`;
- UI: `ui-style.md`, `ui-implementation.md`, `ui-screens.md`, `accessibility-and-localization.md`;
- безопасность/performance/release: `security.md`, `safety-and-policy.md`, `performance.md`, `release-readiness.md`;
- остальные механики: соответствующие guides в `references/`.

## Формат отчёта

Цель, изменённые пути, карта выполненных шагов, evidence по тестам (`pass/fail/not tested`), ограничения и следующий ручной шаг. Пиши так, чтобы другой агент мог продолжить без повторного исследования.