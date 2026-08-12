# Перевод запроса человека в реализацию

Средняя модель часто отвечает на слова запроса, но не на нужный результат. Перед кодом переводи запрос в короткий implementation brief.

## Brief

```text
User goal:
Player action:
Expected feedback:
State that changes:
Source of truth:
Server responsibilities:
Client responsibilities:
Objects/paths to reuse:
New objects/files:
Failure cases:
Proof of success:
Out of scope:
```

## Примеры

`сделай кнопку прыжка красиво` → mobile button in existing HUD, `Activated`, ContextActionService or input contract, cartoon style, cooldown/feedback if mechanic needs it, no gameplay authority in UI, screenshot plus touch test.

`сделай питомцев` → pet definitions, ownership data, equip limit, spawn/cleanup, follow movement, inventory UI, server validation, save migration, duplicate equip test, not just models in Workspace.

`сделай как в simulator` → identify collect → convert/sell → upgrade → unlock loop, timing and reward cadence, then implement one collectible and one upgrade before content expansion.

`исправь баг` → reproduce, capture exact error, identify side, trace, minimal fix, rerun same scenario, regression test. Do not refactor the whole project first.

## One-sentence confirmation

Если запрос критически неоднозначен, сформулируй один короткий interpretation: `Я трактую это как X в существующей системе Y; проверю Z`. Не устраивай анкету, если безопасный vertical slice может показать правильное направление.