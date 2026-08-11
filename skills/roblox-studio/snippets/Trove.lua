--!strict
-- Минимальный сборщик мусора для соединений и инстансов.
-- Причина существования: каждый Connect держит ссылку и не даёт объекту умереть.
-- Через час игры это тысячи мёртвых подписок и необъяснимые лаги.
-- Правило: если у Connect нет очевидного владельца, который его отключит, используй Trove.
--
-- Положи в ReplicatedStorage/Shared/Trove.

export type Cleanable = RBXScriptConnection | Instance | () -> () | { Destroy: (any) -> () }

local Trove = {}
Trove.__index = Trove

export type Trove = typeof(setmetatable({} :: { _items: { Cleanable } }, Trove))

function Trove.new(): Trove
	return setmetatable({ _items = {} }, Trove)
end

-- Добавить что угодно на уборку: соединение, инстанс, функцию, объект с Destroy.
function Trove.Add<T>(self: Trove, item: T & Cleanable): T
	table.insert(self._items, item)
	return item
end

-- Подписка с автоматической регистрацией на уборку.
function Trove.Connect(
	self: Trove,
	signal: RBXScriptSignal,
	callback: (...any) -> ()
): RBXScriptConnection
	return self:Add(signal:Connect(callback))
end

local function cleanupOne(item: Cleanable)
	if typeof(item) == "RBXScriptConnection" then
		item:Disconnect()
	elseif typeof(item) == "Instance" then
		item:Destroy()
	elseif type(item) == "function" then
		item()
	elseif type(item) == "table" and type((item :: any).Destroy) == "function" then
		(item :: any):Destroy()
	end
end

-- Убрать всё. Trove остаётся годным к повторному использованию.
function Trove.Clean(self: Trove)
	-- С конца: порядок уборки обратный порядку создания, как в стеке.
	for index = #self._items, 1, -1 do
		local item = self._items[index]
		self._items[index] = nil
		-- pcall: одна упавшая уборка не должна оставить остальное неубранным.
		local ok, err = pcall(cleanupOne, item)
		if not ok then
			warn("[Trove] ошибка уборки:", err)
		end
	end
end

Trove.Destroy = Trove.Clean

return Trove
