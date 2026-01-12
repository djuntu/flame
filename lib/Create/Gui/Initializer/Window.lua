local Players = game:GetService('Players')
local Types = require(script.Parent.Parent.Types)
local Components = script.Parent.Parent.Components

local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local Line = require(Components.Line)
local Writer = require(Components.Writer)
local Window: Types.Window = {}
Window.__index = Window

function Window.new (Main: Types.InitializedCLIRegistry)
	local self = setmetatable({}, Window)
	self.Writer = Writer.new()
	self.Main = Main
	self.Writer:Create(Main.Gui.Window)
	self.CanProcess = false
	self.CanProcessResponse = ''

	self.Writer:SetHeader(Players.LocalPlayer.Name .. '@Flame$')

	return self
end

function Window:WriteLine (
	text: string,
	lineStyle: Types.LineStyle?,
	color: Color3?,
	header: string?,
	expression: string?
)
	local cli: Types.CLI = self.Main.Gui
	local window = cli.Window

	lineStyle = lineStyle or 'PlainText'
	color = color or Color3.new(1, 1, 1)

	local writtenLine = Line.new():Create(lineStyle, window):SetContent(text):SetContentColor(color)

	if header then writtenLine:SetHeader(header) end
	if expression then writtenLine:SetExpression(expression) end

	Util.adjustConsoleSize(window, 30, 300)
end

function Window:SetProcessableEntry (bool: boolean, canProcessResponse: string?)
	self.CanProcess = bool
	self.CanProcessResponse = canProcessResponse or ''
end

function Window:Focus ()
	local writer = self.Writer
	local textBox = writer.Object.TextBox

	textBox:CaptureFocus()
	textBox.CursorPosition = #textBox.Text + 1
end

function Window:ClearWindowInput ()
	-- reset autocomplete
	local textBox = self.Writer.Object.TextBox
	textBox.Text = ''
end

function Window:GoToFocus ()
	local cli: Types.CLI = self.Main.Gui
	local window = cli.Window

	window.CanvasPosition = Vector2.new(0, window.AbsoluteCanvasSize.Y)
end

function Window:FocusLost (enterPressed: boolean)
	local textBox: TextBox = self.Writer.Object.TextBox

	textBox.Text = Util.trim(textBox.Text)

	self:Focus()
	self:GoToFocus()

	if enterPressed then
        local commandEntry = textBox.Text
        if self.CanProcess then
			self:ClearWindowInput()
			self:GoToFocus()
		end
		self.Main.Dispatch(commandEntry)
	end
end

function Window:Toggle (toggle: boolean)
	local scrollingFrame = self.Main.Gui.Window
	if toggle then
		Util.adjustConsoleSize(scrollingFrame, 30, 300, true)
		self:Focus()
		self:GoToFocus()
	else
		Util.fadeOutConsole(scrollingFrame)
	end
end

return Window
