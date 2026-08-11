--!strict
-- Каркас новой системы. Копируй его, когда добавляешь фичу.
-- Правило проверки: если название сервиса приходится соединять через "и"
-- ("магазин и инвентарь"), это два сервиса, а не один.
--
-- Положи в ServerScriptService/Services/<Имя> или
-- StarterPlayerScripts/Controllers/<Имя> для клиента.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Trove = require(ReplicatedStorage.Shared.Trove)
local Config = require(ReplicatedStorage.Shared.Config)

local ExampleService = {}

-- Приватное состояние держим в локальных переменных файла, а не в таблице
-- сервиса: то, что снаружи не видно, снаружи и не сломают.
local state: { [Player]: number } = {}
local troves: { [Player]: Trove.Trove } = {}

local function onPlayerAdded(player: Player)
	local trove = Trove.new()
	troves[player] = trove
	state[player] = 0

	-- Персонаж появляется позже игрока и создаётся заново при каждом респавне,
	-- поэтому все ссылки на него пересобираем здесь, а не один раз.
	trove:Connect(player.CharacterAdded, function(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not humanoid or not humanoid:IsA("Humanoid") then
			warn("[Example] нет Humanoid у", player.Name)
			return
		end
		humanoid.WalkSpeed = Config.WalkSpeed
	end)
end

local function onPlayerRemoving(player: Player)
	-- Обязательная уборка: без неё соединения и таблицы растут вечно.
	local trove = troves[player]
	if trove then
		trove:Clean()
	end
	troves[player] = nil
	state[player] = nil
end

-- Публичное API: минимум методов, каждый с явными типами.
function ExampleService.GetValue(player: Player): number
	return state[player] or 0
end

-- Отказ — нормальный сценарий, поэтому возвращаем (успех, причина),
-- а не бросаем error: вызывающий покажет ребёнку понятное сообщение.
function ExampleService.SetValue(player: Player, value: number): (boolean, string?)
	if type(value) ~= "number" or value ~= value then
		return false, "invalid_value"
	end
	if not state[player] then
		return false, "player_not_ready"
	end
	state[player] = value
	return true, nil
end

function ExampleService.Init()
	-- Игроки, вошедшие до старта сервиса, тоже должны быть обработаны.
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return ExampleService
