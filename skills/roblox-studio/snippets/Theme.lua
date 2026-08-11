--!strict
-- Единый источник стиля. Положи в ReplicatedStorage/Shared/Theme.
-- Любой UI берёт цвета, шрифты и тайминги отсюда, иначе стиль разойдётся между экранами.

local Theme = {}

Theme.Color = table.freeze({
	-- Смысловые цвета: применяй по назначению, а не по вкусу.
	Primary = Color3.fromRGB(80, 170, 255),   -- навигация, информация
	Success = Color3.fromRGB(85, 220, 110),   -- купить, подтвердить
	Danger = Color3.fromRGB(255, 90, 95),     -- закрыть, отказ
	Gold = Color3.fromRGB(255, 205, 60),      -- валюта, награды
	Rare = Color3.fromRGB(180, 120, 255),     -- редкое, премиум

	-- Поверхности
	Panel = Color3.fromRGB(255, 252, 245),
	PanelDark = Color3.fromRGB(60, 70, 95),

	-- Текст
	Text = Color3.fromRGB(45, 50, 70),
	TextLight = Color3.fromRGB(255, 255, 255),

	-- Обводка не чисто чёрная: чёрный мертвит мультяшную картинку.
	Outline = Color3.fromRGB(45, 40, 70),
})

Theme.Font = table.freeze({
	Title = Enum.Font.FredokaOne,     -- заголовки и кнопки
	Body = Enum.Font.GothamBold,      -- обычный текст
	Number = Enum.Font.GothamBlack,   -- баланс, цифры
})

Theme.Radius = table.freeze({
	Panel = UDim.new(0.08, 0),
	Button = UDim.new(0.3, 0),
	Pill = UDim.new(0.5, 0),
})

Theme.Stroke = table.freeze({
	Thin = 2,
	Normal = 3,
	Thick = 5,
})

Theme.Tween = table.freeze({
	Press = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Release = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Open = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Close = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	Reward = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
})

-- Затемнённый вариант цвета для обводок и теней.
function Theme.darken(color: Color3, amount: number?): Color3
	local k = 1 - (amount or 0.35)
	return Color3.new(color.R * k, color.G * k, color.B * k)
end

-- Осветлённый вариант для верха градиента.
function Theme.lighten(color: Color3, amount: number?): Color3
	local k = amount or 0.2
	return Color3.new(
		color.R + (1 - color.R) * k,
		color.G + (1 - color.G) * k,
		color.B + (1 - color.B) * k
	)
end

-- Толстая обводка. Без неё UI выглядит плоским, а не мультяшным.
function Theme.applyStroke(target: GuiObject, color: Color3?, thickness: number?): UIStroke
	local stroke = target:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = color or Theme.Color.Outline
	stroke.Thickness = thickness or Theme.Stroke.Normal
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = target
	return stroke
end

-- Вертикальный градиент: верх светлее, элемент кажется выпуклым.
function Theme.applyGradient(target: GuiObject, base: Color3): UIGradient
	local gradient = target:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.lighten(base, 0.18)),
		ColorSequenceKeypoint.new(1, base),
	})
	gradient.Parent = target
	return gradient
end

function Theme.applyCorner(target: GuiObject, radius: UDim?): UICorner
	local corner = target:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = radius or Theme.Radius.Button
	corner.Parent = target
	return corner
end

return Theme
