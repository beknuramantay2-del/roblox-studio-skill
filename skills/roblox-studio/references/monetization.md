# Монетизация: Game Passes, Developer Products, Badges

Важный контекст: аудитория — дети. Монетизация должна быть честной и не давить. Roblox активно модерирует манипулятивные схемы, а родительские жалобы бьют по игре сильнее, чем недополученные Robux. Никаких обманных кнопок, скрытых списаний и "последний шанс" таймеров.

## Game Pass против Developer Product

| | Game Pass | Developer Product |
| --- | --- | --- |
| Покупается | один раз навсегда | сколько угодно раз |
| Для чего | VIP, постоянный питомец, доступ к зоне | пачка монет, оживление, бустер |
| Проверка | `UserOwnsGamePassAsync` | обработчик `ProcessReceipt` |

## Game Pass

```lua
local MarketplaceService = game:GetService("MarketplaceService")

local function ownsPass(player: Player, passId: number): boolean
	-- Асинхронный запрос, может упасть: без pcall уронит весь скрипт.
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	if not ok then
		warn("[Market] проверка пасса не удалась:", owns)
		return false  -- при сбое считаем, что нет: щедрость тут дороже безопасности
	end
	return owns == true
end
```

Кэшируй результат на сессию: запрос сетевой, и вызывать его в цикле нельзя. Но обязательно слушай `PromptGamePassPurchaseFinished`, чтобы сбросить кэш сразу после покупки, иначе купивший ребёнок не получит доступ до перезахода и решит, что его обманули.

Проверку прав делай **только на сервере**. Клиентская проверка VIP означает VIP для всех.

## Developer Product и ProcessReceipt

Это самое ответственное место в монетизации: здесь реальные деньги.

```lua
local function processReceipt(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		-- Игрок вышел: НЕ подтверждаем, Roblox повторит попытку позже.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = DataService.Get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Защита от двойной выдачи: Roblox может вызвать обработчик повторно.
	data.ProcessedReceipts = data.ProcessedReceipts or {}
	if data.ProcessedReceipts[info.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local handler = ProductHandlers[info.ProductId]
	if not handler then
		warn("[Market] неизвестный продукт:", info.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local ok, err = pcall(handler, player, data)
	if not ok then
		warn("[Market] выдача провалилась:", err)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	data.ProcessedReceipts[info.PurchaseId] = true
	-- Сохраняем ДО подтверждения: иначе краш между ними съест покупку.
	if not DataService.Save(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
```

Четыре правила, которые нельзя нарушать:

1. **Возвращай `PurchaseGranted` только после успешного сохранения.** Подтвердил, но не сохранил — ребёнок заплатил и ничего не получил.
2. **Всегда проверяй `PurchaseId` на повтор.** Roblox вызывает обработчик заново при сбоях, и без проверки игрок получит товар дважды (а при откате данных — потеряет).
3. **`NotProcessedYet` при любой неуверенности.** Roblox повторит позже. Это безопасный ответ, `PurchaseGranted` — необратимый.
4. **Только один обработчик `ProcessReceipt` на всю игру.** Второе присваивание молча перезапишет первое, и часть покупок перестанет работать. Держи его в одном сервисе.

Обработчики продуктов держи в таблице по id: добавление нового товара становится добавлением строки, а не правкой логики.

## Приглашение к покупке

```lua
-- С клиента, по нажатию кнопки
MarketplaceService:PromptProductPurchase(player, productId)
MarketplaceService:PromptGamePassPurchase(player, passId)
```

Цену показывай реальную, полученную через `GetProductInfo`, а не вписанную руками: цены меняются, а несоответствие выглядит как обман.

Честные практики для детской игры: покупка ускоряет, но не открывает единственный путь. Всё важное для геймплея достижимо без Robux. Никаких таймеров давления и никаких кнопок покупки рядом с обычными кнопками действий — случайное нажатие ребёнком это худший сценарий для отзывов.

## BadgeService

Бейджи видны в профиле Roblox, и для детей это заметная награда. Выдаются раз и навсегда.

```lua
local BadgeService = game:GetService("BadgeService")

local function awardBadge(player: Player, badgeId: number)
	local ok, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
	end)
	if not ok or hasBadge then return end

	-- Тоже в pcall: сервис бывает недоступен, и это не должно ронять механику.
	pcall(function()
		BadgeService:AwardBadge(player.UserId, badgeId)
	end)
end
```

Проверка перед выдачей обязательна: `AwardBadge` на уже имеющийся бейдж тратит лимит запросов зря. Вызывай не чаще, чем нужно, и никогда в цикле.
