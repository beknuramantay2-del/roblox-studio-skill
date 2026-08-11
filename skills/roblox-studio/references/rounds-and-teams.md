# Раунды, лобби, матчмейкинг, спавн, команды

## Round system: одна машина состояний

Раунд — это конечный автомат на сервере. Разбросанные по коду `while true` с `task.wait` дают раунды, которые накладываются друг на друга, и это невозможно отладить.

```lua
type RoundState = "Waiting" | "Intermission" | "Starting" | "Playing" | "Ending"

local state: RoundState = "Waiting"
local MIN_PLAYERS = 2

local function setState(newState: RoundState)
	state = newState
	Remotes.RoundStateChanged:FireAllClients(newState)  -- UI следит за этим
	print("[Round] ->", newState)
end

local function loop()
	while true do
		if #Players:GetPlayers() < MIN_PLAYERS then
			setState("Waiting")
			task.wait(2)
			continue
		end

		setState("Intermission")
		task.wait(Config.IntermissionTime)

		-- Список участников фиксируем один раз на старте.
		-- Иначе вошедший посреди раунда попадёт в подсчёт победителей.
		local participants = table.clone(Players:GetPlayers())
		setState("Playing")
		local winner = runRound(participants)

		setState("Ending")
		awardWinner(winner)
		task.wait(Config.EndingTime)
		cleanupRound()
	end
end
```

Что ломается почти всегда:

- **Игрок вышел посреди раунда.** Проверяй `player.Parent == Players` перед любым обращением к нему после ожидания. Иначе ошибки в подсчёте очков и в DataStore.
- **Игрок вошёл посреди раунда.** Реши заранее: наблюдатель или участник. Молчаливое включение в участники ломает логику победы.
- **Уборка между раундами.** Всё созданное в раунде (оружие, эффекты, временные части) должно исчезнуть. Trove на раунд решает это одной строкой.
- **Раунд не должен зависать.** Всегда ставь максимальную длительность: если условие победы не наступило, раунд заканчивается по таймеру. Раунд без таймаута — самый частый способ убить сервер игры.
- **Одна точка запуска.** Цикл раунда стартует ровно один раз из `Main`. Два экземпляра цикла дадут гонки, которые выглядят как мистика.

Все состояния сообщай клиенту событием, а не отдельными флагами. Тогда UI (таймер, счёт, надпись "ждём игроков") получается автоматически и никогда не рассинхронизируется.

## Lobby и матчмейкинг

Два подхода:

**Лобби внутри места.** Все в одном сервере, игроки телепортируются между зоной лобби и картой. Просто, надёжно, подходит для детских игр. Отключи автоспавн (`Players.CharacterAutoLoads = false`) и вызывай `player:LoadCharacter()` сам, когда нужно, либо просто телепортируй персонажа к нужной точке спавна.

**Отдельные места.** Лобби и игра — разные `place`, переход через `TeleportService` (см. `cross-server.md`). Нужно, когда карта тяжёлая или требуется настоящий матчмейкинг. Сложнее: надо передавать данные между местами и обрабатывать неудачные телепорты.

Для детской игры почти всегда лучше первый вариант: меньше точек отказа, а ожидание в лобби ребёнок переносит плохо. Если ждать всё же надо, покажи, кого и сколько ждём, живым счётчиком.

Матчмейкинг по скиллу в детских играх обычно вреден: он увеличивает время ожидания ради честности, которая аудитории не важна. Балансируй составы простым перемешиванием.

## Spawn, respawn, checkpoints

`SpawnLocation` работает сам, если он в `Workspace`. Свойства, которые решают проблемы: `Neutral` (кто может спавниться), `TeamColor`, `Duration` (время неуязвимости `ForceField`), `AllowTeamChangeOnTouch`.

Случайный спавн из набора точек делай так, чтобы игроки не появлялись друг в друге: проверяй занятость точки или просто добавляй небольшой случайный сдвиг.

```lua
local function respawnAt(player: Player, cframe: CFrame)
	local character = player.Character
	if not character or not character.PrimaryPart then return end
	-- Небольшой подъём: иначе персонаж застревает в полу.
	character:PivotTo(cframe + Vector3.new(0, 3, 0))
end
```

**Checkpoints.** Храни номер чекпоинта в данных игрока (см. `data-and-services.md`), а не в `IntValue` внутри персонажа: второй теряется при смерти, и это классический баг обби, когда прогресс сбрасывается.

```lua
checkpointPart.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	local data = DataService.Get(player)
	if not data then return end

	local index = checkpointPart:GetAttribute("Index") or 0
	if index <= data.Checkpoint then return end  -- назад не откатываем

	data.Checkpoint = index
	DataService.Save(player)
	Remotes.CheckpointReached:FireClient(player, index)  -- звук и вспышка
end)
```

Проверка `index <= data.Checkpoint` обязательна: без неё игрок, пробежавший назад, потеряет прогресс.

**Respawn.** `player.CharacterAdded` — единственная надёжная точка для восстановления состояния после смерти: телепорт на чекпоинт, выдача инструментов, применение улучшений. Всё, что делается один раз при входе, при респавне надо делать заново.

Время респавна: `Players.RespawnTime`. Для детской игры ставь коротким (1-2 секунды). Долгое ожидание после смерти — прямой путь к тому, что ребёнок закроет игру.

## Teams

```lua
local Teams = game:GetService("Teams")

local red = Instance.new("Team")
red.Name = "Красные"
red.TeamColor = BrickColor.new("Bright red")
red.AutoAssignable = false  -- распределяем сами
red.Parent = Teams
```

Практика:

- `AutoAssignable = false` и распределение кодом: автоматическое даёт неравные составы.
- Балансируй по количеству, а не случайно: считай игроков в каждой команде и кидай в меньшую.
- Смена команды не убивает персонажа автоматически. Если по дизайну надо, вызывай `player:LoadCharacter()` явно.
- Цвет команды используй в UI и в подсветке персонажей: дети должны различать своих без чтения имён.
- Проверку "свой или чужой" держи в одной функции (`isFriendly`), которую вызывает единая точка урона, см. `combat.md`.

В детских PvP командный дружественный огонь почти всегда стоит выключить: он провоцирует конфликты и обвинения.
