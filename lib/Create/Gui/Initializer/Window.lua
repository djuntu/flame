local Players = game:GetService('Players')
local Types = require(script.Parent.Parent.Types)
local Components = script.Parent.Parent.Components

local Line = require(Components.Line)
local Writer = require(Components.Writer)
local Window: Types.Window = {}
Window.__index = Window

function Window.new (Main: Types.InitializedCLIRegistry)
	local self = setmetatable({}, Window)
	self.Writer = Writer.new()
    self.Main = Main
	self.Writer:Create(Main.Gui.Window)

	self.Writer:SetHeader(Players.LocalPlayer.Name .. '@Flame$')

	return self
end

function Window:Focus()
    local writer = self.Writer
    local textBox = writer.Object.TextBox

    textBox:CaptureFocus()
    textBox.CursorPosition = #textBox.Text + 1
end

function Window:GoToFocus()
    local cli: Types.CLI = self.Main.Gui
    local window = cli.Window

    window.CanvasPosition = Vector2.new(0, window.AbsoluteCanvasSize.Y)
end

function Window:Toggle(toggle: boolean)
    if toggle then
        self:Focus()
        self:GoToFocus()
    end

    local Main = self.Main :: Types.InitializedCLIRegistry
    Main.Gui.Enabled = toggle
end

return Window
