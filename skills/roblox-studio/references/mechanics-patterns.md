# Библиотека паттернов механик

Используй как starting point, не как копипасту. Сначала найди существующий service/controller и адаптируй контракт.

## Interaction

`detect → validate → reserve/lock → apply once → feedback → cleanup`.

Подходит для pickup, prompt, click, lever, chest, harvesting. Lock ставь до награды, иначе double-fire.

## Combat

`input → local anticipation → server request → cooldown/authority/range/line-of-sight → damage once → replicated result → impact feedback`.

Клиент не сообщает окончательную цель или урон. Сервер не зависит от локальной анимации.

## Collection/simulator

`spawn → discover → collect → inventory/currency → sell/convert → upgrade → unlock next zone`.

Считай экономику сервером, content definitions держи в config, эффекты и numbers показывай клиентом.

## NPC

`idle → detect → choose target → path/chase → telegraph → attack → recover → lose target → return → cleanup`.

Каждый переход имеет timeout и fallback. Не создавай отдельный heartbeat на каждого NPC без бюджета.

## Round

`waiting → intermission → snapshot participants → countdown → playing → win/timeout → rewards → cleanup`.

Snapshot участников и cleanup обязательны: игроки входят и выходят в любой момент.

## Trading

`offer draft → validate ownership → lock both inventories → confirm both players → atomic swap → save/rollback → result`.

Никогда не меняй один инвентарь до того, как второй подтверждён и транзакция может быть откатана.

## Crafting

`recipe whitelist → validate materials → reserve materials → create result → persist → feedback`.

При ошибке после reserve восстанови материалы или используй idempotency key.

## Abilities/status

Считай итог из источников: base + equipment + buffs - debuffs. Не позволяй нескольким системам напрямую перезаписывать `WalkSpeed`, `JumpPower` или damage.

## Loading/onboarding

`load → show progress → ready or bounded fallback → teach one action → first reward → unlock next action`.

Никогда не держи игрока бесконечно на loading из-за необязательного ассета.