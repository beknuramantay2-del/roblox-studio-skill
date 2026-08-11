# Персонаж, анимации, камера, движение

## Humanoid: что важно

Персонаж это `Model` с `Humanoid` внутри. Ключевые части: `HumanoidRootPart` (физический корень, он же `PrimaryPart`), `Head`, `Animator`, `HumanoidDescription`.

**Персонаж создаётся заново при каждом респавне.** Все ссылки на старый Humanoid, части тела и загруженные анимации становятся мусором. Отсюда единственно верный шаблон:

```lua
local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid or not humanoid:IsA("Humanoid") then return end
	local root = character:WaitForChild("HumanoidRootPart", 5)

	local trove = Trove.new()  -- своя уборка на каждую жизнь
	trove:Connect(humanoid.Died, function()
		trove:Clean()
	end)
	-- настройки, зависящие от персонажа, ставим здесь
	humanoid.WalkSpeed = Config.WalkSpeed
end

local character = player.Character or player.CharacterAdded:Wait()
onCharacterAdded(character)
player.CharacterAdded:Connect(onCharacterAdded)
```

Первая строка с `or ... :Wait()` обязательна: персонаж может уже существовать к моменту запуска скрипта, и тогда одна подписка на `CharacterAdded` его пропустит. Без этого механика "не работает при первом входе, работает после смерти" — очень частый баг.

Полезные свойства и приёмы:

- Двигай персонажа через `PivotTo` на модели, а не `Position` на `HumanoidRootPart`: второе может разорвать сборку.
- `humanoid:MoveTo(position)` для простого движения NPC, `humanoid.MoveToFinished` для ожидания. У `MoveTo` таймаут 8 секунд, потом событие срабатывает с `false` — учитывай это, иначе NPC замрёт.
- `humanoid.StateChanged` и `SetStateEnabled` для контроля прыжков, падений, лазанья. Отключение `Enum.HumanoidStateType.Jumping` — правильный способ запретить прыжок вместо обнуления `JumpPower`.
- `humanoid:GetState()` вместо флагов вроде `isJumping`: движок уже знает состояние.
- `humanoid.HealthChanged`, `humanoid.Died` — только на сервере как источник истины.
- `CharacterAutoLoads = false` на `Players`, если нужен лобби-режим без спавна, см. `rounds-and-teams.md`.

## Анимации

Анимации загружаются через `Animator`, не через устаревший `Humanoid:LoadAnimation`.

```lua
local animator = humanoid:WaitForChild("Animator") :: Animator

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://ВАШ_ID"

local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action  -- перебивает ходьбу
track.Looped = false
track:Play(0.1)  -- 0.1 = плавное вливание, без рывка
```

Что ломается чаще всего:

- **Приоритет.** `Core` < `Idle` < `Movement` < `Action` < `Action4`. Анимация удара с приоритетом `Movement` будет перебиваться ходьбой, и выглядит это как "анимация не проигрывается". Ставь `Action` на всё активное.
- **Владелец ассета.** Анимация проигрывается только если её загрузил владелец игры или группа. Чужой ID даст молчаливое ничего. Если анимация не играет, а ошибок нет, проверь это первым.
- **Загружай треки один раз** и переиспользуй. `LoadAnimation` в каждом ударе течёт памятью и добавляет задержку.
- Анимации для NPC работают так же: `AnimationController` плюс `Animator` для моделей без `Humanoid`, но с `Humanoid` проще и надёжнее.
- `track.Stopped`, `track:GetMarkerReachedSignal("hit")` — правильный способ синхронизировать урон с моментом замаха вместо угадывания через `task.wait`.

Визуально анимации играются у всех, если запущены на сервере, и только локально, если на клиенте. Для отзывчивости запускай на клиенте немедленно и параллельно шли remote серверу, который проиграет её остальным.

## Камера

Камера полностью клиентская: `workspace.CurrentCamera`. Сервер её не контролирует и не должен пытаться.

```lua
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable  -- забираем управление

RunService:BindToRenderStep("CustomCamera", Enum.RenderPriority.Camera.Value, function()
	camera.CFrame = CFrame.lookAt(desiredPosition, targetPosition)
end)
```

Правила:

- Камеру двигай **только** в `RenderStepped` / `BindToRenderStep` с приоритетом камеры. В `Heartbeat` картинка будет дёргаться, потому что кадр отрисуется до обновления.
- Возвращая управление, ставь `CameraType = Custom` и `camera.CameraSubject = humanoid`. Забытый `CameraSubject` даёт застывшую камеру после респавна.
- Первое и третье лицо переключай через `player.CameraMode` (`LockFirstPerson` / `Classic`), а не своими костылями: встроенный режим корректно работает с мобильным управлением.
- Ограничения зума: `player.CameraMinZoomDistance` и `CameraMaxZoomDistance`.
- Тряска камеры (shake) делай смещением CFrame на маленькие случайные величины с затуханием. В детской игре держи её слабой: сильная тряска у детей вызывает дискомфорт.
- Не забывай отвязывать `BindToRenderStep` через `UnbindFromRenderStep`, иначе кастомная камера продолжит бороться со стандартной.

## Движение: sprint, dash, double jump

Механики движения делаются на клиенте для отзывчивости, но параметры и лимиты держит сервер. Клиент, который сам решает свою скорость, — это летающий читер.

**Sprint.** Клиент меняет `WalkSpeed` локально и сообщает серверу. Сервер проверяет, что игрок имеет право бежать (есть стамина, не оглушён) и держит своё значение как истину. Простой античит: сервер периодически сверяет фактическую скорость перемещения с максимально допустимой, см. `security.md`.

**Dash.** Импульс через `LinearVelocity` или разовое смещение `CFrame` с проверкой препятствий raycast-ом. Обязательны: кулдаун (на клиенте для UI, на сервере для честности), проверка состояния (нельзя рывок в воздухе, если по дизайну нельзя), и `Debris` на созданные эффекты.

```lua
local DASH_COOLDOWN = 2
local DASH_SPEED = 60
local DASH_TIME = 0.2

local function dash(root: BasePart, direction: Vector3)
	local attachment = Instance.new("Attachment")
	attachment.Parent = root

	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.MaxForce = math.huge
	velocity.VectorVelocity = direction.Unit * DASH_SPEED
	velocity.Parent = root

	task.delay(DASH_TIME, function()
		velocity:Destroy()
		attachment:Destroy()
	end)
end
```

Проверяй `direction.Magnitude > 0` перед `Unit`: рывок без направления даст NaN и улетевшего в бесконечность игрока.

**Double jump.** Считай прыжки в `humanoid.StateChanged`: сбрасывай счётчик на `Landed`, разрешай второй прыжок в `Freefall`. Реализация через `humanoid:ChangeState(Enum.HumanoidStateType.Jumping)`. Не пытайся ловить двойное нажатие пробела — состояние надёжнее.

Для детской игры двойной прыжок и рывок стоит делать щедрыми: большое окно, слабое наказание за ошибку. Точные тайминги фрустрируют аудиторию, которая ещё плохо владеет управлением.

## Status effects, stun, knockback

Держи эффекты в одном месте (сервисе), а не разбросанно по механикам. Иначе два эффекта, меняющих `WalkSpeed`, перезапишут друг друга, и игрок останется медленным навсегда — классический баг.

```lua
-- Правильно: считаем итоговое значение из всех активных эффектов,
-- а не пишем WalkSpeed напрямую из каждой механики.
local function recalculate(player: Player)
	local humanoid = getHumanoid(player)
	if not humanoid then return end

	local speed = Config.WalkSpeed
	for _, effect in activeEffects[player] do
		speed *= effect.SpeedMultiplier or 1
	end
	humanoid.WalkSpeed = if isStunned(player) then 0 else speed
end
```

Это главный принцип статусов: **храни причины, вычисляй результат**. Прямая запись свойства из разных мест не восстанавливается после снятия одного из эффектов.

Stun: `WalkSpeed = 0` плюс `SetStateEnabled(Jumping, false)`, обязательно с гарантированным снятием через `task.delay` в защищённом виде. Если игрок умрёт во время стана, снимать нечего — проверяй существование персонажа.

Knockback: импульс `LinearVelocity` на короткое время в направлении от источника. Держи слабым: сильный отброс в детской игре чаще раздражает, чем радует, потому что игрок теряет контроль.

Все эффекты снимай при смерти и выходе игрока. Забытый статус в таблице по игроку — утечка памяти и баг при переподключении.
