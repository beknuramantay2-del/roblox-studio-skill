# Архитектурные решения без путаницы

## ModuleScript или BindableEvent

ModuleScript подходит для reusable API, pure functions, config и service/controller interfaces. BindableEvent подходит для one-to-many событий внутри одной стороны, когда подписчики не должны знать внутренний вызов. Remote нужен только через client/server boundary.

## State и events

Событие сообщает изменение, snapshot описывает текущее состояние. Для UI используй оба: initial snapshot при открытии/подключении и events после изменений. Иначе поздно подключившийся клиент получит пустой или устаревший экран.

## Один владелец

У каждой domain value один writer: CurrencyService пишет currency, InventoryService пишет ownership, RoundService пишет phase. Остальные вызывают API или подписываются. Если два сервиса пишут одно поле, баг уже заложен.

## Слои

`Config/Types → Data → Services → Remotes → Controllers → UI/VFX`. Зависимость должна идти сверху вниз по смыслу, а не циклом. Shared modules не должны содержать server secrets.

## Idempotency

Retry, reconnect, duplicate remote и repeated prompt возможны всегда. Для покупок, наград, receipts, trading и saves используй operation/receipt id и безопасное повторное выполнение.

## Переходы состояний

Для round, NPC, onboarding, shop transaction и ability используй явные состояния и таблицу разрешённых переходов. Нельзя просто менять десяток boolean flags без инвариантов.