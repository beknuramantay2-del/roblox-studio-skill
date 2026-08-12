# Матрица тестов

Одна проверка в Play не доказывает готовность. Выбирай матрицу по риску функции.

## Core matrix

| Область | Минимальная проверка |
| --- | --- |
| client/server | 1 server + 2 clients |
| UI | desktop + narrow mobile + touch/controller |
| character | first spawn + respawn + leave during action |
| remotes | valid + wrong type + spam + impossible distance |
| data | new player + existing data + failed load + rejoin |
| economy | success + insufficient + duplicate request + rollback |
| NPC | idle + chase + blocked path + death + respawn |
| VFX/SFX | loaded asset + missing asset + max concurrent effects |
| performance | baseline + stressed scene + 10-15 minute soak |

## Evidence

Для каждого теста сохраняй короткий evidence: Output excerpt, screenshot, metric или точное `not tested` с причиной. Не называй визуальную проверку выполненной по одному факту создания Instance.

## Regression

После исправления повтори исходный баг, соседний сценарий и happy path. Если ошибка исчезла, ищи вторичные ошибки: warning, duplicate event, memory growth, desync или stale UI.

## Test data

Используй фикстуры и mock/studio-safe storage. Не трогай реальные Robux, production receipts и реальные данные игроков в негативном тесте.