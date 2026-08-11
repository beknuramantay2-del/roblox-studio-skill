# NPC, ИИ, pathfinding, диалоги

## Устройство NPC

NPC — это `Model` с `Humanoid` и `PrimaryPart`. Держи шаблоны в `ServerStorage/NPCs` и клонируй. Не храни их в `Workspace` невидимыми: невидимые модели всё равно грузятся и реплицируются всем.

Обязательное на каждом NPC:

- `humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None`, если полоска здоровья над головой не нужна: по умолчанию она мешает.
- Тег через `CollectionService` (`Enemy`, `Villager`), чтобы код не зависел от имени модели.
- Атрибуты с параметрами: `Health`, `Damage`, `Speed`, `AggroRange`. Тогда дизайнер меняет сложность в Studio без правки скриптов.
- Своя `CollisionGroup`, иначе толпа мобов выталкивает игроков с карты.

**Вся логика NPC на сервере.** Клиентский ИИ рассинхронизируется между игроками: каждый увидит своего моба в другом месте.

Один управляющий сервис на всех NPC вместо скрипта внутри каждой модели. Сто скриптов с собственными циклами `while true` — это сто независимых таймеров и гарантированная просадка. Сервис обходит всех NPC в одном цикле с разумной частотой.

## Состояния вместо флагов

ИИ без явных состояний превращается в кашу из `if isChasing and not isAttacking and hasTarget`. Состояние решает это.

```lua
type AiState = "Idle" | "Patrol" | "Chase" | "Attack" | "Return"

local function step(npc: Model, data: NpcData, dt: number)
	local target = findNearestPlayer(npc, data.AggroRange)

	if data.State == "Idle" or data.State == "Patrol" then
		if target then
			data.State = "Chase"
			data.Target = target
		else
			patrol(npc, data)
		end
	elseif data.State == "Chase" then
		if not target then
			data.State = "Return"   -- потерял, идёт домой
		elseif distanceTo(npc, target) <= data.AttackRange then
			data.State = "Attack"
		else
			moveTowards(npc, target)
		end
	elseif data.State == "Attack" then
		attack(npc, data)
		if distanceTo(npc, target) > data.AttackRange * 1.3 then
			data.State = "Chase"  -- запас 1.3, иначе состояние задёргается
		end
	end
end
```

Обрати внимание на множитель 1.3. Без запаса NPC на границе дистанции будет переключаться между Chase и Attack каждый кадр и выглядеть сломанным. Такой запас нужен на любом переходе по расстоянию.

## Бюджет: не думай каждый кадр

Пятьдесят NPC, считающих путь каждый кадр, положат сервер. Разумные частоты:

- Поиск цели: 3-5 раз в секунду.
- Пересчёт пути: раз в 0.5-1 секунду или когда цель ушла далеко от точки, для которой путь считался.
- Движение по уже посчитанному пути: каждый кадр, оно дешёвое.
- NPC далеко от всех игроков: усыпляй полностью. Проверка "есть ли игрок в радиусе 150" дешевле любого ИИ.

Распределяй нагрузку: обрабатывай не всех NPC за один тик, а по частям (десять из пятидесяти). Тогда пик размазывается и не даёт рывков.

## PathfindingService

Нужен, когда есть препятствия. Для открытой площадки хватит `humanoid:MoveTo`, и он в разы дешевле.

```lua
local PathfindingService = game:GetService("PathfindingService")

local path = PathfindingService:CreatePath({
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
	WaypointSpacing = 4,
})

local ok = pcall(function()
	path:ComputeAsync(npcRoot.Position, targetPosition)
end)

if not ok or path.Status ~= Enum.PathStatus.Success then
	-- Путь не найден: нормальная ситуация, а не исключение.
	-- Двигайся напрямую или вернись на патруль, но не зависай молча.
	humanoid:MoveTo(targetPosition)
	return
end

for _, waypoint in path:GetWaypoints() do
	if waypoint.Action == Enum.PathWaypointAction.Jump then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	humanoid:MoveTo(waypoint.Position)
	local reached = humanoid.MoveToFinished:Wait()
	if not reached then break end  -- застрял, пора пересчитать путь
end
```

Что ломается:

- `ComputeAsync` может бросить ошибку **и** вернуть неуспешный статус. Оба случая обязательны к обработке, иначе NPC зависнет навсегда.
- `MoveToFinished` возвращает `false` при таймауте восемь секунд. Игнорировать нельзя: это признак застревания.
- Путь устаревает: игрок ушёл, а NPC идёт по старым точкам. Прерывай обход, если цель сместилась на несколько метров.
- `path.Blocked` даёт событие, если путь перекрыли. Подпишись и пересчитай.
- `PathfindingModifier` на воде и опасных зонах, чтобы NPC их обходил.

## Boss AI

Босс отличается от обычного моба не количеством здоровья, а **фазами и телеграфом**.

- **Фазы по здоровью**: на 66% и 33% меняется набор атак. Это создаёт ощущение прогресса в бою.
- **Телеграф обязателен**: перед атакой заметный знак (свечение, круг на земле, замах, звук) с задержкой 0.6-1 секунда. Без предупреждения бой воспринимается как несправедливый, а для детей это критично.
- **Выбор атаки не полностью случайный**: держи список доступных с кулдаунами, чтобы одна атака не повторилась четыре раза подряд.
- **Не бей мгновенно после спавна.** Дай игроку 2-3 секунды осмотреться.
- Полоска здоровья босса на весь экран, с отметками фаз. Дети должны видеть, что побеждают.

Атаку разбивай на явные фазы: `Telegraph` (показать), `Execute` (нанести), `Recover` (окно для контратаки). Окно восстановления — то, что делает босса интересным, а не просто мешком с уроном.

## Диалоги NPC

Для детской игры: короткие фразы, крупный шрифт, максимум 2-3 варианта ответа, много иконок. Длинные диалоги здесь не читают.

Данные отдельно от логики:

```lua
return table.freeze({
	Greeting = {
		Text = "Привет! Поможешь мне найти монетки?",
		Options = {
			{ Text = "Да!", Icon = "✅", Next = "QuestAccept" },
			{ Text = "Потом", Icon = "👋", Next = nil },
		},
	},
})
```

Диалог показывает клиент, но **последствия применяет сервер**: выданный квест, награда, изменение состояния. Клиент присылает только id выбранного варианта, а сервер проверяет, что этот вариант доступен в текущем узле. Иначе игрок выберет "получить награду" из любого места диалога.

Запуск диалога через `ProximityPrompt` (см. `input-and-interaction.md`): он сам корректно работает на всех платформах.
