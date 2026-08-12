---
name: roblox-studio
description: Разработка игр в Roblox Studio через MCP: детский мультяшный UI, Luau, механики по ТЗ, VFX/SFX, поиск DataModel, автономная отладка и защита от типичных ошибок средних моделей.
license: MIT
metadata:
  version: 5.1.0
---

Ты работаешь с Roblox Studio через MCP для детской игры примерно 7-13 лет. Переводи запрос человека в implementation brief, исследуй существующий DataModel, собери контракт и vertical slice, затем докажи результат.

## Обязательный цикл

`Interpret → Inspect → Plan → Change → Verify → Continue`; при ошибке `InspectError → Recover → Verify`.

### Interpret

Сначала выпиши goal, player action, expected feedback, state change, server/client ownership, existing paths, failure cases, proof и out of scope. Читай `references/request-translation.md`. Если запрос основан на референсе, извлекай поведение и темп, но не копируй защищённые ассеты или контент.

### Inspect

Проверь Studio mode и capability matrix. Составь короткую карту DataModel, найди объекты, скрипты, references, `require`, tags, attributes и активные ошибки. Используй `references/ai-failure-patterns.md` как preflight; для длинного поиска используй Data Model Search, если доступен.

### Plan

Разбей задачу на core loop, entities, states и systems. Зафиксируй data schema/migration, один writer для каждого domain value, public API, remote contract, acceptance table, fallback и выбранный playbook. Для незнакомого API/asset/capability сначала сделай документационный research или безопасный probe.

### Change

Прочитай существующий код целиком. Делай микрошаги и vertical slice: input → validation → state/result → feedback → cleanup. Для VFX/SFX используй recipe из `vfx-sfx-craft.md`, для механик `mechanics-patterns.md`. После каждого yield revalidate player, Instance и state. Не повторяй операцию без проверки.

### Verify

Проверь DataModel/Properties, Script Analysis, Output/F9, happy/negative path, spam, duplicate, respawn, leave, reconnect, two clients и regression. Для UI/VFX сделай screenshot или ручную viewport-проверку на mobile/touch/controller. Для performance измерь baseline, stress и soak. Перед `готово` пройди failure-pattern preflight и `test-matrix.md`; каждая проверка имеет `pass/fail/not tested` и evidence.

### Recover

После критической ошибки остановись, сохрани stack trace, hard reset, откати последний change-set или пометь новый объект `_draft`, затем повтори тот же тест. После двух безрезультатных попыток измени гипотезу или попроси уточнение.

## Невзламываемые правила

1. Сервер владеет истиной: клиент не определяет валюту, предметы, урон, покупки, права, победы или сохранения.
2. У каждого connection, Instance, VFX и Sound есть cleanup/pooling план.
3. Новый Luau-файл начинается с `--!strict` и проходит Script Analysis.
4. UI mobile-first, доступный, локализуемый и мультяшный.
5. API, asset id, capability и смысл не выдумываются.
6. Ошибка не маскируется пустым `pcall`, удалением логов или бесконечными retry.
7. Не говори `готово`, пока есть evidence или честный `not tested`.

## Маршрутизация

- перевод запроса: `request-translation.md`; ошибки ИИ/Roblox: `ai-failure-patterns.md`; Luau: `luau-mental-model.md`;
- семантика Roblox: `roblox-semantics.md`; архитектура: `architecture-decisions.md`;
- механики: `mechanics-reconstruction.md`, `mechanics-patterns.md`, `implementation-playbooks.md`;
- VFX/SFX: `vfx-sfx-craft.md`, `audio-visual.md`, `audio-modern.md`, `asset-pipeline.md`;
- поиск/состояние/тесты: `project-search.md`, `medium-model-tactics.md`, `test-fixtures.md`, `test-matrix.md`, `autonomous-debugging.md`;
- API/capabilities/версии: `api-research.md`, `capability-detection.md`, `source-control-and-versioning.md`;
- UI: `ui-style.md`, `ui-implementation.md`, `ui-screens.md`, `accessibility-and-localization.md`;
- безопасность/performance/release: `security.md`, `safety-and-policy.md`, `performance.md`, `release-readiness.md`;
- остальные механики: соответствующие guides в `references/`.

## Формат отчёта

Цель, interpretation, изменённые пути, карта шагов, evidence (`pass/fail/not tested`), ограничения и следующий ручной шаг. Пиши так, чтобы другой агент мог продолжить без повторного исследования.