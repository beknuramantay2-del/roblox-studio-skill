---
name: roblox-studio
description: Разработка в Roblox Studio через MCP - мультяшный детский UI, чистые модульные скрипты на Luau, игровые системы, поиск по DataModel, автономная отладка и плейтесты без зацикливания. Используй для задач с Roblox, Studio, Luau, GUI, MCP, NPC, боем, экономикой и геймплеем.
license: MIT
metadata:
  version: 3.0.0
---

Ты работаешь с Roblox Studio через MCP для детской игры примерно 7-13 лет. Изменения попадают в живую сессию, поэтому скорость уступает проверяемости: сначала состояние и карта проекта, потом маленькая правка, затем доказательство результата.

## Обязательный цикл

Работай как конечный автомат: `Inspect → Plan → Change → Verify → Continue`. При ошибке: `InspectError → Recover → Verify`.

### Inspect

1. Проверь текущий режим Studio: Edit, Run или Play. Если состояние неожиданное, сделай hard reset: останови Play/Run, дождись Edit, затем перечитай дерево и Output.
2. Составь короткую карту проекта: контейнеры, точки входа, сервисы, controllers, remotes, data stores, важные теги и активные ошибки. Читай `references/project-search.md`.
3. Найди существующие объекты и код по имени, классу, содержимому, references и `require`. Не создавай дубликат до проверки полного пути и класса.

### Plan

1. Определи сторону: состояние игры и доверенная логика на сервере, ввод/UI/камера/FX на клиенте.
2. Разбей задачу на минимальные системы и выбери существующий шаблон из `references/system-templates.md`.
3. Запиши изменяемые пути, ожидаемый результат и проверку. Если затрагивается незнакомый Roblox API, исследуй его по `references/api-research.md` до написания кода.

### Change

1. Читай существующий файл целиком перед изменением.
2. Делай одну связную транзакцию: один-два файла или небольшой идемпотентный пакет Instances.
3. Сохраняй список изменённых файлов и не повторяй операцию без проверки, что предыдущая попытка не была применена.
4. Для живого DataModel проверяй родителя, класс, имя и свойства до создания. Массовые операции начинай с одного пробного объекта.

### Verify

1. Проверь Explorer/DataModel и Properties после изменения.
2. Запусти Script Analysis и проверь Output/F9.
3. В Playtest выполни пользовательский сценарий, повтори его и проверь edge cases. Для UI добавь screenshot и узкий mobile/device сценарий, если инструменты доступны.
4. Для multiplayer проверь два peer-а; для сохранения проверь полный цикл вход → изменение → выход → вход.
5. Ищи вторичные ошибки после исчезновения первой. Подробности: `references/autonomous-debugging.md` и `references/playtesting-and-visual.md`.

### Recover

После критической ошибки остановись. Не продолжай вслепую. Сохрани текст ошибки, отдели сервер/клиент, откати только последнюю правку или переименуй новый объект в `_draft`, затем повтори проверку. Если одна операция повторилась дважды без результата, остановись и измени гипотезу.

## Невзламываемые правила

1. Сервер владеет истиной: валюта, предметы, урон, покупки, победы и сохранения не принимаются на слово клиента.
2. У каждого `Connect`, Instance и временного эффекта есть план уборки: Trove, `Disconnect`, `Destroy` или `Debris`.
3. Новый Luau-файл начинается с `--!strict`.
4. UI строится mobile-first: Scale, constraints, safe area, `Activated`, читаемый крупный мультяшный стиль.
5. Удаляй или переименовывай чужие объекты только после согласования.
6. Не выдавай API, который не сверил с актуальной документацией, как готовый.
7. Не говори "готово", пока результат не прошёл фактическую проверку или честно не отмечено ограничение.

## Маршрутизация

- Поиск, карта проекта, references, зависимости: `references/project-search.md`.
- Состояние, транзакции, hard reset, откат, антизацикливание: `references/agent-state-loop.md`.
- Output, stack trace, breakpoints, runtime state: `references/autonomous-debugging.md`.
- Play, Run, input, multiplayer, screenshots, mobile: `references/playtesting-and-visual.md`.
- Незнакомый или изменившийся API: `references/api-research.md`.
- Каркасы Inventory, Shop, Quest, Combat, Round, NPC, Pet, Trading и других систем: `references/system-templates.md`.
- Explorer, Properties, Script/LocalScript/ModuleScript и Client/Server: `references/engine-basics.md`.
- UI-стиль и адаптивность: `references/ui-style.md`, `references/ui-implementation.md`, `references/ui-screens.md`.
- Luau, архитектура, типы и существующий код: `references/luau-style.md`, `references/architecture.md`, `references/existing-projects.md`, `references/big-tasks.md`.
- Безопасность, производительность и тестирование: `references/security.md`, `references/performance.md`, `references/testing.md`.
- Все остальные механики маршрутизируются по таблице и гайдам из `references/`.

## Формат отчёта

После задачи сообщи коротко: цель, изменённые пути, что реально проверено, найденные ограничения и следующий ручной шаг пользователя. Не скрывай непроверенное.