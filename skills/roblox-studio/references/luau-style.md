# Стиль кода Luau

## Строгие типы включены всегда

Первая строка каждого нового файла — `--!strict`. Это не педантизм: strict-режим ловит `nil` и опечатки в именах полей до плейтеста. Половина "необъяснимых" Roblox-багов — это `attempt to index nil`, который анализатор увидел бы сразу.

```lua
--!strict

export type ItemId = "SpeedBoost" | "DoubleJump"

export type Item = {
	Id: ItemId,
	Price: number,
	Duration: number?,  -- ? значит "может не быть"
}

local function buy(player: Player, item: Item): (boolean, string?)
	-- возвращаем успех + причину отказа
	return true, nil
end
```

Общие типы держи в `Shared/Types` и экспортируй через `export type`, чтобы клиент и сервер описывали одни и те же данные одинаково. Расхождение типов между сторонами — классический источник багов при передаче через remote.

## Имена

- `PascalCase` — модули, классы, публичные методы, свойства инстансов.
- `camelCase` — локальные переменные и приватные функции.
- `SCREAMING_SNAKE` — константы уровня файла.
- Приставка `_` — намеренно неиспользуемый аргумент (`function(_, value)`).

Пиши слова целиком: `playerCharacter`, не `plrChar`. Код читают в десять раз чаще, чем пишут, а через MCP его читают ещё и агенты, которым сокращения мешают понять смысл.

Булевы значения формулируй как утверждение: `isJumping`, `hasKey`, `canPurchase`. `flag` и `check` ничего не сообщают.

## Никаких магических чисел

```lua
-- плохо
task.wait(2.5)
if player.Character.Humanoid.Health < 20 then

-- хорошо
local RESPAWN_DELAY = 2.5
local LOW_HEALTH_THRESHOLD = 20
```

Число без имени невозможно поправить осмысленно: непонятно, это баланс, тайминг или костыль под конкретный баг.

## Ранний выход вместо вложенности

```lua
-- плохо: логика уезжает вправо
if player then
	if player.Character then
		if player.Character:FindFirstChild("Humanoid") then
			-- дело
		end
	end
end

-- хорошо
local character = player and player.Character
if not character then return end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end
-- дело
```

Плоский код с проверками сверху читается линейно, и добавить условие в него можно не переписывая структуру.

## Современный API вместо устаревшего

| Не используй | Используй | Почему |
| --- | --- | --- |
| `wait()` | `task.wait()` | старый `wait` неточен и просыпается позже заявленного |
| `spawn()` / `delay()` | `task.spawn()` / `task.delay()` | старые глушат ошибки и портят стек |
| `game.Players` | `game:GetService("Players")` | работает даже если сервис переименован |
| `Instance.new("Part", parent)` | сначала свойства, `Parent` в конце | назначение Parent первым вызывает лишний реплик и пересчёт физики |
| `:connect()`, `:FindFirstChild()` в цикле каждый кадр | `:Connect()`, кэшированная ссылка | регистр — legacy, поиск каждый кадр — мусор в бюджете |
| `while true do task.wait() end` | `RunService.Heartbeat` / `.PostSimulation` | привязано к реальному циклу движка |

## Ошибки

Всё, что может не получиться (сеть, DataStore, `require` внешнего, парсинг данных игрока), оборачивай в `pcall` и **обрабатывай результат**:

```lua
local ok, result = pcall(loadPlayerData, player)
if not ok then
	warn("[Data] load failed for", player.Name, result)
	result = getDefaultData() -- игра продолжается на дефолтах
end
```

Пустой `pcall(...)` без разбора ошибки хуже краша: баг остаётся, но становится невидимым, и искать его будешь по симптомам через неделю.

В функциях, где отказ — нормальный сценарий, возвращай `(boolean, string?)` вместо `error()`. Вызывающий сможет показать ребёнку понятное "Не хватает монеток" вместо красной строки в Output.

## Комментарии

Комментируй **почему**, а не **что**. `-- увеличиваем счётчик` мусор. `-- ждём кадр, иначе Humanoid ещё не успел появиться после респавна` спасает следующего, кто захочет эту строку удалить.

Особо помечай костыли под движковые особенности: без пометки их обязательно "почистят" и баг вернётся.
