# Тестовые фикстуры и сценарии

Средней модели нужны повторяемые стартовые условия. Для каждой системы создавай маленькую fixture: тестовый игрок, минимальный DataStore mock или Studio-safe данные, известный map slice и фиксированный seed.

## Fixture card

```text
Name: Shop_NotEnoughCoins
Setup: player coins = 0, item Price = 100
Action: RequestPurchase("SpeedBoost")
Expect: no debit, no item, reason = not_enough, one server log
Cleanup: disconnect player, destroy temporary instances
```

## Минимум тестов

- happy path;
- неверный тип и неизвестный id;
- повторный вызов и spam;
- nil/удалённый игрок;
- респавн;
- выход во время yield;
- два игрока одновременно;
- маленький экран и touch, если есть UI;
- DataStore failure и повтор;
- rollback/regression после исправления.

Не используй реальные Robux, production DataStore или постоянные объекты для негативного теста. После теста убирай fixture и проверяй, что она не оставила connections, Instances или записи в таблицах.