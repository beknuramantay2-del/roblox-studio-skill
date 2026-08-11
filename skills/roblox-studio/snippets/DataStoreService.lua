--!strict
-- Безопасное сохранение прогресса.
-- DataStore падает регулярно, и это нормальный сценарий, а не исключение.
-- Самое важное правило здесь: если загрузка не удалась, НЕ СОХРАНЯЙ.
-- Иначе затрёшь реальный прогресс ребёнка нулями. Это самый дорогой баг в жанре.
--
-- Положи в ServerScriptService/Services/DataService.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("PlayerData_v1")

local RETRIES = 3
local RETRY_DELAY = 2
local AUTOSAVE_INTERVAL = 120

local DEFAULT_DATA = table.freeze({
	Coins = 0,
	Items = table.freeze({}),
	Version = 1,
})

local DataService = {}

local cache: { [Player]: { [string]: any } } = {}
-- Отдельно помним, у кого загрузка провалилась: таким сохранять нельзя.
local loadFailed: { [Player]: boolean } = {}

local function deepCopy(source: { [any]: any }): { [any]: any }
	local copy = {}
	for key, value in source do
		copy[key] = if type(value) == "table" then deepCopy(value) else value
	end
	return copy
end

-- Повторы с задержкой: разовый сбой DataStore обычно проходит сам.
local function retry<T>(label: string, fn: () -> T): (boolean, T?)
	for attempt = 1, RETRIES do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		warn(`[Data] {label} попытка {attempt} провалилась: {result}`)
		if attempt < RETRIES then
			task.wait(RETRY_DELAY * attempt)
		end
	end
	return false, nil
end

-- Структура могла измениться между версиями игры: дозаполняем недостающее.
local function migrate(data: { [string]: any }): { [string]: any }
	for key, value in DEFAULT_DATA do
		if data[key] == nil then
			data[key] = if type(value) == "table" then deepCopy(value) else value
		end
	end
	return data
end

function DataService.Load(player: Player)
	local key = `player_{player.UserId}`
	local ok, result = retry("load", function()
		return store:GetAsync(key)
	end)

	if not ok then
		-- Работаем на дефолтах в памяти, но помечаем: сохранять запрещено.
		loadFailed[player] = true
		cache[player] = deepCopy(DEFAULT_DATA)
		warn(`[Data] загрузка провалилась для {player.Name}, сохранение отключено`)
		return
	end

	if type(result) == "table" then
		cache[player] = migrate(result :: { [string]: any })
	else
		cache[player] = deepCopy(DEFAULT_DATA) -- новый игрок
	end
end

function DataService.Get(player: Player): { [string]: any }?
	return cache[player]
end

function DataService.Save(player: Player): boolean
	if loadFailed[player] then
		warn(`[Data] пропуск сохранения для {player.Name}: загрузка была неуспешной`)
		return false
	end

	local data = cache[player]
	if not data then return false end

	local key = `player_{player.UserId}`
	local snapshot = deepCopy(data) -- фиксируем состояние на момент вызова
	local ok = retry("save", function()
		store:UpdateAsync(key, function()
			return snapshot
		end)
		return true
	end)
	return ok
end

function DataService.Init()
	for _, player in Players:GetPlayers() do
		task.spawn(DataService.Load, player)
	end
	Players.PlayerAdded:Connect(function(player)
		DataService.Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		DataService.Save(player)
		cache[player] = nil
		loadFailed[player] = nil
	end)

	-- Автосейв: без него краш сервера съедает весь прогресс сессии.
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for player in cache do
				task.spawn(DataService.Save, player)
			end
		end
	end)

	-- Сохранение при остановке сервера. Без BindToClose данные последних минут теряются.
	game:BindToClose(function()
		for player in cache do
			DataService.Save(player)
		end
	end)
end

return DataService
