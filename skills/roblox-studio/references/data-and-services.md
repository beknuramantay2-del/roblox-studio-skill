# Данные, лидерборды, телепорты, кросс-сервер

Базовая обёртка сохранения — в `snippets/DataStoreService.lua`, читай её перед тем, как писать своё. Здесь то, что вокруг.

## Главное правило DataStore

**Если загрузка не удалась, не сохраняй.** Иначе затрёшь реальный прогресс дефолтными нулями. Это самый дорогой баг жанра: он необратим, и ребёнок теряет всё.

Остальные правила:

- Все вызовы в `pcall` с повторами и задержкой. Сбой DataStore — штатная ситуация, а не исключение.
- `UpdateAsync` вместо `SetAsync`, когда важно не потерять параллельную запись.
- Лимиты по запросам реальны: не сохраняй чаще раза в минуту на игрока. Спам сохранений даст очередь и потери.
- Автосейв каждые 2-3 минуты плюс `BindToClose` плюс сохранение при выходе. Без автосейва краш сервера съедает всю сессию.
- Версионируй имя стора (`PlayerData_v1`). Меняя структуру несовместимо, поднимай версию, а не ломай старые данные.
- Валидируй загруженное и дозаполняй недостающие поля дефолтами: структура могла измениться между версиями игры.
- Не храни в данных то, что есть в конфиге (цены, названия). Только состояние игрока.
- В Studio DataStore работает только с включённым доступом к API-сервисам. Если данные не сохраняются в тестах, проверь это первым.

## OrderedDataStore и глобальные лидерборды

`OrderedDataStore` умеет сортировать и выдавать топ. Хранит **только целые числа**, поэтому дробные значения умножай и округляй.

```lua
local DataStoreService = game:GetService("DataStoreService")
local board = DataStoreService:GetOrderedDataStore("TopCoins_v1")

-- Обновляем по факту изменения, но не чаще раза в минуту на игрока.
local function publish(player: Player, value: number)
	pcall(function()
		board:SetAsync(tostring(player.UserId), math.floor(value))
	end)
end

-- Чтение топа: раз в минуту на весь сервер, результат кэшируем.
local function fetchTop(count: number)
	local ok, pages = pcall(function()
		return board:GetSortedAsync(false, count)  -- false = по убыванию
	end)
	if not ok then return nil end

	local result = {}
	for rank, entry in pages:GetCurrentPage() do
		-- entry.key это UserId строкой, entry.value это число
		table.insert(result, {
			Rank = rank,
			UserId = tonumber(entry.key),
			Value = entry.value,
		})
	end
	return result
end
```

Имена и аватарки подтягивай отдельно: `Players:GetNameFromUserIdAsync` и `Players:GetUserThumbnailAsync`, оба в `pcall`, оба с кэшем. Без кэша сервер упрётся в лимиты, и лидерборд будет пустым.

Кэшируй топ на сервере и рассылай клиентам одним событием. Отдельный запрос на каждого игрока — прямой путь к исчерпанию лимитов.

## MemoryStoreService

Быстрое временное хранилище, общее для всех серверов игры. Это не замена DataStore, а инструмент координации между серверами.

Где реально полезен:

- Очередь матчмейкинга между серверами (`SortedMap`, `Queue`).
- Глобальные события с общим счётчиком ("все игроки вместе собрали 10000 монет").
- Живой лидерборд текущего события, который не нужно хранить навсегда.
- Блокировка, чтобы два сервера не выдали одну награду дважды.

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local map = MemoryStoreService:GetSortedMap("EventScores")

pcall(function()
	map:SetAsync(tostring(player.UserId), score, 3600)  -- живёт час
end)
```

Все вызовы асинхронные и падают так же, как DataStore, значит `pcall` обязателен. И помни: данные исчезают по истечении срока, поэтому ничего важного здесь хранить нельзя.

## MessagingService

Сообщения между серверами одной игры. Лимиты жёсткие, поэтому только для событий, а не для потока данных.

```lua
local MessagingService = game:GetService("MessagingService")

-- Подписка (в pcall: она тоже может не удаться)
pcall(function()
	MessagingService:SubscribeAsync("GlobalEvent", function(message)
		announceToAll(message.Data)
	end)
end)

-- Отправка: только по важному поводу
pcall(function()
	MessagingService:PublishAsync("GlobalEvent", { Type = "BossSpawned" })
end)
```

Подходит для объявлений на всю игру, старта глобального события, оповещения о бане. Не подходит для синхронизации состояния в реальном времени: лимиты не позволят.

## TeleportService

```lua
local TeleportService = game:GetService("TeleportService")

local function teleport(players: { Player }, placeId: number, data: { [string]: any }?)
	local options = Instance.new("TeleportOptions")
	if data then
		options:SetTeleportData(data)  -- передаём контекст в новое место
	end

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(placeId, players, options)
	end)
	if not ok then
		warn("[Teleport] не удался:", err)
		-- Обязательно скажи игроку: молчаливый провал выглядит как зависание.
		for _, player in players do
			Remotes.TeleportFailed:FireClient(player)
		end
	end
end
```

Что важно:

- **Сохраняй данные игрока перед телепортом.** Иначе прогресс, набранный до перехода, потеряется.
- Телепорт может не удаться (сервер полон, место недоступно). Подпишись на `TeleportInitFailed` и покажи понятное сообщение с кнопкой "попробовать снова".
- `TeleportData` читается в новом месте через `player:GetJoinData().TeleportData`. Не доверяй ему как источнику истины для ценностей: данные проходят через клиент. Валюту и инвентарь читай из DataStore, через TeleportData передавай только контекст (номер команды, режим).
- Групповой телепорт через `TeleportAsync` со списком игроков собирает их в один сервер. Для игры с друзьями это обязательно, иначе группа разъедется по разным серверам.
- Показывай экран загрузки перед телепортом: несколько секунд молчания ребёнок воспринимает как поломку.

## Private servers

`game.PrivateServerId` и `game.PrivateServerOwnerId` позволяют понять, что игра в приватном сервере и кто владелец.

```lua
local isPrivate = game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0
local function isOwner(player: Player): boolean
	return isPrivate and player.UserId == game.PrivateServerOwnerId
end
```

Типичное применение: владельцу приватного сервера дают доступ к настройкам матча. Это популярная у детей механика (играть с друзьями по своим правилам) и хороший повод для Game Pass.

Прогресс в приватных серверах обычно стоит сохранять так же, как в обычных, иначе игроки разочаруются. Если по балансу нельзя (эксплуатируемые награды), скажи об этом внутри игры явно, а не молча.
