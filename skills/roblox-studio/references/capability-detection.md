# Проверка возможностей Studio и MCP

Инструменты Roblox и MCP зависят от версии Studio, beta-функций и конкретного клиента. Не выдумывай capability.

## Перед задачей

Составь capability matrix:

```text
DataModel search: available / unavailable
Edit inspection and write: available / unavailable
Play/Run control: available / unavailable
server/client peers: available / unavailable
virtual input: available / unavailable
screenshots: available / unavailable
debugger/breakpoints: available / unavailable
device simulation: available / unavailable
performance data: available / unavailable
```

Проверяй возможность маленьким безопасным probe, а не разрушительной операцией. Сохраняй результат в рабочем журнале задачи.

## Fallback

- нет Data Model Search: узкие обходы дерева и чтение ближайших файлов;
- нет debugger: Output, F9, Script Analysis, диагностические логи;
- нет screenshot: ручная проверка viewport и описание ограничений;
- нет virtual input: ручный Playtest-сценарий;
- нет multiplayer automation: Test с несколькими клиентами вручную;
- нет performance API: Developer Console и MicroProfiler вручную.

Никогда не сообщай, что test/screenshot/debugger выполнен, если инструмент не вернул доказательство.