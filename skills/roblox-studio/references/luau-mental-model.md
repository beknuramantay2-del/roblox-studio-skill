# Ментальная модель Luau для ИИ

## Таблицы

Таблица может быть array, dictionary или смешанным объектом. `#t` и `ipairs` подходят только для плотного array; для dictionary используй `pairs`, а для состояния игрока лучше явный тип.

Не меняй структуру таблицы во время обхода без осознанной стратегии. При удалении игрока сначала выполни cleanup, затем убери запись из cache.

## nil и optional values

`nil` удаляет ключ из таблицы. Optional типы (`T?`) надо сузить проверкой перед использованием. `FindFirstChild`, attributes и методы с timeout возвращают отсутствие как нормальный сценарий.

## Методы и metatables

`object:Method(x)` передаёт `object` как self; `object.Method(object, x)` эквивалентен, а `object.Method(x)` обычно ошибка. Metatable/OOP усложняет inference, поэтому экспортируй типы явно и проверяй Script Analysis.

## Yield и task

`task.wait`, `Wait`, `InvokeServer`, DataStore и многие API yield. После yield игрок, персонаж, Instance или состояние могли исчезнуть. После каждого критичного yield revalidate owner/state.

`task.spawn` не делает код безопасным и не гарантирует порядок завершения. Используй его только с явным owner, cancellation/cleanup и обработкой ошибок.

## Строгая типизация

Начинай с `--!strict`, но не подменяй типы бездумным `:: any`. Разделяй domain types, Instance checks и network payload types. После изменения публичного типа проверь всех consumers.

## Ошибки

Возвращай typed result для ожидаемого отказа (`boolean, reason` или result table); используй `pcall` для внешних/yielding границ и обрабатывай failure. Не превращай неизвестную ошибку в успешный default.