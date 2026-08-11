# Ввод, взаимодействие, твины и циклы

## RunService: какой цикл выбрать

| Событие | Когда | Для чего |
| --- | --- | --- |
| `RenderStepped` | клиент, до отрисовки | **только камера**, ничего больше |
| `PreRender` | клиент, современный аналог | камера и визуальные привязки |
| `Heartbeat` / `PostSimulation` | обе стороны, после физики | вся обычная логика |
| `PreSimulation` | перед физикой | силы и констрейнты |
| `Stepped` | устаревающий | заменяй на Pre/PostSimulation |

`RenderStepped` блокирует отрисовку кадра: тяжёлая работа там напрямую съедает FPS. Всё, что не про камеру, вешай на `Heartbeat`.

И главное: **не делай в каждом кадре то, что можно делать реже**. Аккумулятор времени вместо цикла на каждый кадр экономит бюджет почти бесплатно, пример в `performance.md`.

## UserInputService: клавиши, тач, геймпад

Только клиент. Основной инструмент, когда нужен сырой ввод.

```lua
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- gameProcessed = true значит ввод уже съеден чатом или UI.
	-- Без этой проверки игрок будет прыгать, печатая в чате пробел.
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		Movement.startSprint()
	end
end)
```

Определение платформы для подсказок и раскладки UI:

```lua
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	-- телефон: покажи экранные кнопки вместо надписей про клавиши
elseif UserInputService.GamepadEnabled then
	-- консоль: включи навигацию Selectable
end
```

В детской игре мобильный ввод — основной, а не дополнительный. Любая механика на клавише обязана иметь экранную кнопку, иначе половина игроков не сможет ей пользоваться. Это не опция, это требование.

## ContextActionService: когда лучше него

`ContextActionService` привязывает действие к нескольким источникам ввода сразу (клавиша, кнопка на экране, геймпад) и умеет приоритеты. Используй его для игровых действий, а `UserInputService` — для низкоуровневых вещей.

```lua
local ContextActionService = game:GetService("ContextActionService")

local function onDash(actionName, inputState)
	if inputState ~= Enum.UserInputState.Begin then return end
	Abilities.dash()
end

ContextActionService:BindAction("Dash", onDash, true, -- true = кнопка на экране
	Enum.KeyCode.Q, Enum.KeyCode.ButtonX)
ContextActionService:SetTitle("Dash", "Рывок")
```

Главное преимущество: `true` в третьем аргументе автоматически создаёт мобильную кнопку. Это самый дешёвый способ выполнить требование выше.

Второе: `BindActionAtPriority` позволяет временно перехватить действие (например, во время катсцены) и потом отпустить через `UnbindAction`, не переписывая логику.

## ProximityPrompt: взаимодействие с миром

Лучший выбор для "подойди и нажми": двери, магазины, NPC, сундуки. Работает на всех платформах сам, включая мобилку и геймпад, и не требует своего UI.

```lua
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Открыть магазин"
prompt.ObjectText = "Магазин"
prompt.HoldDuration = 0        -- держать не нужно: дети не любят удержание
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false  -- иначе не срабатывает из-за декора
prompt.Parent = shopPart

-- Обработчик на сервере: клиенту нельзя доверять факт активации.
prompt.Triggered:Connect(function(player)
	ShopService.open(player)
end)
```

`RequiresLineOfSight = false` почти всегда правильнее: с включённым игроки жалуются, что промпт не появляется, хотя объект прямо перед ними. `HoldDuration` больше нуля ставь только там, где нужна защита от случайного нажатия.

Важно: `Triggered` можно слушать и на клиенте (для UI), но действие с последствиями выполняй на сервере. Клиент может активировать промпт скриптом на любом расстоянии, поэтому сервер проверяет дистанцию сам.

## ClickDetector

Простой клик по объекту. Работает и на тач. Уступает `ProximityPrompt` в удобстве на мобилке и не показывает подсказку, поэтому используй для того, что кликают издалека: кнопки-рычаги, декоративные интерактивы.

```lua
local detector = Instance.new("ClickDetector")
detector.MaxActivationDistance = 32
detector.Parent = leverPart

detector.MouseClick:Connect(function(player)
	if not RemoteGuard.check(player, "Lever", 1) then return end
	LeverService.toggle(player, leverPart)
end)
```

Кулдаун обязателен: клик можно спамить скриптом.

## TweenService: анимация свойств

Основной способ двигать UI и объекты предсказуемо. Дешевле физики и полностью контролируем.

```lua
local TweenService = game:GetService("TweenService")

local info = TweenInfo.new(
	0.25,                          -- длительность
	Enum.EasingStyle.Back,         -- пружинистый, см. ui-style.md
	Enum.EasingDirection.Out,
	0,                             -- повторы
	false,                         -- реверс
	0                              -- задержка
)

local tween = TweenService:Create(frame, info, { Size = UDim2.fromScale(1, 1) })
tween:Play()
tween.Completed:Wait()  -- если нужно дождаться
```

Практика:

- Твины на UI создавай на клиенте. Твин на сервере для UI не имеет смысла и создаёт лишнюю репликацию.
- Не запускай новый твин, не остановив предыдущий на том же свойстве (`tween:Cancel()`), иначе они начнут драться и элемент задёргается.
- Твин на `CFrame` объекта в `Workspace` реплицируется — годится для дверей и платформ. Но для быстрых частых движений дешевле анимировать на клиенте.
- Тайминги в `snippets/Theme.lua`: единый источник делает всю игру ощущающейся цельно.

## CollectionService и Debris

`CollectionService` — теги вместо поиска по имени. Подробно с примерами в `building-models.md`. Главная причина использовать: код перестаёт зависеть от имён объектов, и дизайнер может добавить сотую монетку без правки скриптов.

`Debris:AddItem(instance, seconds)` — самоуничтожение временных объектов. Ставь на каждый эффект, пулю, всплывающий текст. Объект без плана на удаление живёт до перезапуска сервера, и `Workspace` за час распухает до тысяч мёртвых частей.

```lua
local Debris = game:GetService("Debris")
Debris:AddItem(explosionEffect, 3)
```

## Attributes

Параметры конкретного объекта храни в атрибутах, а не в скрытых `IntValue`. Они видны в Studio, редактируются без кода, реплицируются автоматически и имеют событие изменения.

```lua
coin:SetAttribute("Value", 5)
local value = coin:GetAttribute("Value") or 1  -- дефолт обязателен

coin:GetAttributeChangedSignal("Value"):Connect(updateLabel)
```

Дефолт через `or` не формальность: атрибут может быть не выставлен на объекте, добавленном вручную, и без дефолта получишь nil в арифметике.
