--!strict
-- Фабрика мультяшной кнопки: круглая, с толстой обводкой, тенью, градиентом
-- и пружинистым нажатием. Используй её вместо ручной сборки кнопок,
-- иначе стиль неизбежно разойдётся между экранами.
--
-- Положи в ReplicatedStorage/Shared/UI/CartoonButton.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Theme)

local PRESSED_SCALE = 0.94

export type ButtonConfig = {
	Text: string?,
	Icon: string?,          -- эмодзи или текстовая иконка
	Color: Color3?,
	Size: UDim2?,
	Position: UDim2?,
	LayoutOrder: number?,
	OnClick: (() -> ())?,
}

local CartoonButton = {}

function CartoonButton.create(parent: GuiObject, config: ButtonConfig): TextButton
	local color = config.Color or Theme.Color.Success

	-- Тень: отдельный фрейм под кнопкой, даёт объём.
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.BackgroundColor3 = Theme.darken(color, 0.55)
	shadow.BorderSizePixel = 0
	shadow.Size = config.Size or UDim2.fromScale(0.8, 0.14)
	shadow.Position = (config.Position or UDim2.fromScale(0.5, 0.5))
		+ UDim2.fromOffset(0, 5)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.ZIndex = 1
	shadow.LayoutOrder = config.LayoutOrder or 0
	Theme.applyCorner(shadow, Theme.Radius.Button)
	shadow.Parent = parent

	local button = Instance.new("TextButton")
	button.Name = "CartoonButton"
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.AutoButtonColor = false -- свою анимацию делаем сами
	button.Size = UDim2.fromScale(1, 1)
	button.Position = UDim2.fromScale(0.5, 0.5)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.ZIndex = 2
	button.Text = ""
	button.Parent = shadow

	Theme.applyCorner(button, Theme.Radius.Button)
	Theme.applyStroke(button, Theme.darken(color, 0.4), Theme.Stroke.Thick)
	Theme.applyGradient(button, color)

	-- UIScale для анимации нажатия: масштабируем контейнер, а не Size,
	-- чтобы не конфликтовать с Layout родителя.
	local scale = Instance.new("UIScale")
	scale.Parent = button

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(0.86, 0.6)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Font = Theme.Font.Title
	label.TextColor3 = Theme.Color.TextLight
	label.TextScaled = true
	label.Text = if config.Icon
		then `{config.Icon} {config.Text or ""}`
		else (config.Text or "")
	label.Parent = button

	-- Обводка текста: без неё белые буквы теряются на светлом фоне игры.
	Theme.applyStroke(label, Theme.Color.Outline, Theme.Stroke.Thin)

	-- Ограничитель размера текста: без него на большом экране буквы гигантские.
	local textSize = Instance.new("UITextSizeConstraint")
	textSize.MaxTextSize = 32
	textSize.MinTextSize = 14
	textSize.Parent = label

	local function press()
		TweenService:Create(scale, Theme.Tween.Press, { Scale = PRESSED_SCALE }):Play()
	end

	local function release()
		TweenService:Create(scale, Theme.Tween.Release, { Scale = 1 }):Play()
	end

	button.MouseButton1Down:Connect(press)
	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(release) -- палец уехал, кнопка не должна залипнуть

	-- Activated вместо MouseButton1Click: работает и с геймпадом, и с тачем.
	if config.OnClick then
		button.Activated:Connect(config.OnClick)
	end

	return button
end

return CartoonButton
