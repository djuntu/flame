return function (): ScreenGui
    local Main = Instance.new('ScreenGui')
    Main.Name = 'Flame'
    Main.DisplayOrder = 999
    Main.Enabled = true
    Main.IgnoreGuiInset = false
    Main.ResetOnSpawn = false
    Main.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local Window = Instance.new('ScrollingFrame')
    Window.Name = 'Window'
    Window.BackgroundColor3 = Color3.fromRGB(3, 3, 9)
    Window.BackgroundTransparency = 0.3
    Window.AnchorPoint = Vector2.new(0.5, 0)
    Window.AutomaticSize = Enum.AutomaticSize.Y
    Window.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Window.Position = UDim2.fromScale(0.5, 0.05)
    Window.Size = UDim2.fromScale(0.9, 0)
    Window.ScrollBarImageTransparency = 1
    Window.ScrollBarThickness = 1
    Window.ScrollingDirection = Enum.ScrollingDirection.Y
    Window.CanvasSize = UDim2.fromScale(0, 0)
    Window.Parent = Main

    local WindowPadding = Instance.new('UIPadding')
    WindowPadding.Name = 'Padding'
    WindowPadding.PaddingBottom = UDim.new(0, 25)
    WindowPadding.PaddingTop = UDim.new(0, 25)
    WindowPadding.PaddingRight = UDim.new(0, 20)
    WindowPadding.PaddingLeft = UDim.new(0, 20)
    WindowPadding.Parent = Window

    local WindowLayout = Instance.new('UIListLayout')
    WindowLayout.Name = 'Layout'
    WindowLayout.Padding = UDim.new(0, 10)
    WindowLayout.Parent= Window

    local WindowCorner = Instance.new('UICorner')
    WindowCorner.Name = 'Corner'
    WindowCorner.CornerRadius = UDim.new(0, 8)
    WindowCorner.Parent = Window

    local WindowStoke = Instance.new('UIStroke')
    WindowStoke.Name = 'Stroke'
    WindowStoke.Color = Color3.fromRGB(3, 3, 9)
    WindowStoke.Parent = Window

    return Main
end