# Архитектура проекта

Цель простая: чтобы через полгода можно было добавить фичу, не сломав три другие. В Roblox это достигается не хитрыми паттернами, а одним принципом — **каждая система живёт в одном месте и общается с остальными через явный интерфейс**.

## Раскладка

```
ServerScriptService/
├── Main.server.lua              единственная точка входа сервера
└── Services/                    серверные системы (ModuleScript)
    ├── DataService
    ├── ShopService
    └── CoinService

ReplicatedStorage/
├── Shared/                      код, нужный обеим сторонам
│   ├── Config          цифры и баланс игры
│   ├── Types           общие типы Luau
│   ├── Trove
│   └── Theme           палитра и шрифты UI
└── Remotes/                     RemoteEvent / RemoteFunction

StarterPlayer/StarterPlayerScripts/
├── Main.client.lua              единственная точка входа клиента
└── Controllers/                 клиентские системы
    ├── ShopController
    └── HudController

StarterGui/                      только сами ScreenGui, без логики
```

**Одна точка входа на сторону.** `Main` требует модули, инициализирует их в понятном порядке и всё. Десяток независимых `Script`-ов, стартующих одновременно, дают гонки, которые невозможно воспроизвести: сегодня магазин загрузился раньше данных, завтра нет.

```lua
--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services

-- Порядок важен: данные до всего, что их читает.
local order = { "DataService", "CoinService", "ShopService" }

local loaded = {}
for _, name in order do
	local service = require(Services[name])
	loaded[name] = service
	print("[Main] loaded", name)
end

for name, service in loaded do
	if type(service.Init) == "function" then
		local ok, err = pcall(service.Init, service)
		if not ok then
			warn("[Main] init failed:", name, err)
		end
	end
end
```

Ошибка в одном сервисе не должна валить загрузку остальных — отсюда `pcall` вокруг `Init`.

## Один модуль — одна ответственность

Правило проверки: если название модуля приходится соединять через "и" ("магазин и инвентарь и монеты"), это два-три модуля. Каркас лежит в `snippets/ServiceTemplate.lua`.

Модуль отдаёт наружу минимум. Внутреннее состояние держи в локальных переменных файла, не в возвращаемой таблице: то, что снаружи не видно, снаружи и не сломают.

```lua
local CoinService = {}
local balances: { [Player]: number } = {}  -- приватно

function CoinService.GetBalance(player: Player): number
	return balances[player] or 0
end

function CoinService.Add(player: Player, amount: number): boolean
	if amount <= 0 or amount ~= amount then -- отсекаем 0, минус и NaN
		return false
	end
	balances[player] = (balances[player] or 0) + amount
	return true
end

return CoinService
```

## Никаких циклических зависимостей

`ShopService` требует `CoinService`, а `CoinService` требует `ShopService` — Roblox либо повиснет, либо отдаст полупустую таблицу. Если два модуля тянутся друг к другу, значит между ними есть третья сущность: вынеси общее в отдельный модуль либо разверни связь через событие (`CoinService` шлёт `BalanceChanged`, `ShopService` слушает).

Зависимости должны идти в одну сторону: `Controllers → Shared ← Services`. Клиент никогда не требует серверный модуль, сервер никогда не требует контроллер.

## Цифры отдельно от логики

Весь баланс — в `Shared/Config`. Стоимость предметов, скорость бега, кулдауны, награды.

```lua
return table.freeze({
	WalkSpeed = 18,
	CoinPerPickup = 5,
	ShopItems = table.freeze({
		SpeedBoost = table.freeze({ Price = 100, Duration = 15 }),
	}),
})
```

`table.freeze` не даст случайно перезаписать конфиг в рантайме — такой баг ищется мучительно, потому что код выглядит правильным. Плюс правка баланса становится правкой одной цифры в одном файле, а не поиском по проекту.

## Связь клиент-сервер

Remote-ы создавай заранее в `ReplicatedStorage/Remotes` и **никогда не в рантайме**: клиент может успеть подписаться до появления объекта и молча ничего не получать.

Имена по смыслу действия и стороне: `RequestPurchase` (клиент просит), `BalanceUpdated` (сервер сообщает). Из имени должно быть видно, кто кому и зачем — это резко снижает шанс написать логику начисления на клиенте.

Подробности валидации — в `security.md`.
