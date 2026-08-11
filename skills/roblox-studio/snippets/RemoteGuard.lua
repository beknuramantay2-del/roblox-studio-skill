--!strict
-- Валидация и ограничение частоты для remote-ов.
-- Без этого любой игрок может спамить сервер тысячи раз в секунду
-- и присылать мусор вместо аргументов: nil, таблицы, math.huge, NaN.
--
-- Положи в ServerScriptService/Services/RemoteGuard (только сервер).

local Players = game:GetService("Players")

local RemoteGuard = {}

-- [player][action] = время последнего вызова
local lastCall: { [Player]: { [string]: number } } = {}

Players.PlayerRemoving:Connect(function(player)
	lastCall[player] = nil -- иначе таблица растёт вечно
end)

-- Кулдаун на действие. Возвращает false, если игрок спамит.
function RemoteGuard.check(player: Player, action: string, cooldown: number): boolean
	local now = os.clock()
	local playerCalls = lastCall[player]
	if not playerCalls then
		playerCalls = {}
		lastCall[player] = playerCalls
	end

	local previous = playerCalls[action]
	if previous and now - previous < cooldown then
		return false
	end
	playerCalls[action] = now
	return true
end

-- Полная проверка числа. n ~= n отсекает NaN: он проходит любые сравнения
-- и портит данные так, что потом невозможно понять причину.
function RemoteGuard.isNumber(value: unknown, min: number, max: number): boolean
	if type(value) ~= "number" then return false end
	if value ~= value then return false end          -- NaN
	if value == math.huge or value == -math.huge then return false end
	return value >= min and value <= max
end

-- Строка с ограничением длины: без лимита клиент пришлёт мегабайт текста.
function RemoteGuard.isString(value: unknown, maxLength: number?): boolean
	if type(value) ~= "string" then return false end
	return #value <= (maxLength or 64)
end

-- Значение из белого списка. Единственный надёжный способ принимать идентификаторы.
function RemoteGuard.isKeyOf(value: unknown, allowed: { [string]: any }): boolean
	if type(value) ~= "string" then return false end
	return allowed[value] ~= nil
end

-- Игрок физически рядом с объектом. Клиент может утверждать что угодно.
function RemoteGuard.isWithinReach(player: Player, position: Vector3, maxDistance: number): boolean
	local character = player.Character
	local root = character and character.PrimaryPart
	if not root then return false end
	return (root.Position - position).Magnitude <= maxDistance
end

-- Игрок ещё в игре. Проверяй после любой задержки: он мог выйти
-- посреди твоего task.wait, и дальше пойдут ошибки в DataStore и UI.
function RemoteGuard.isInGame(player: Player): boolean
	return player.Parent == Players
end

return RemoteGuard
