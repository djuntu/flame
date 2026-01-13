-- Handles initializing and managing the CLI window for user input and output.
local Players = game:GetService('Players')
local Types = require(script.Parent.Parent.Types)
local Components = script.Parent.Parent.Components

local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local Line = require(Components.Line)
local Writer = require(Components.Writer)
local Window: Types.Window = {}
Window.__index = Window

--[[
	@interface Window
	@within Initializer

	@public
	@type Window
]]
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

--[[
	@method WriteLine
	@within Window
	Writes a line to the CLI window.

	@public
	@param text: string
	@param lineStyle: Types.LineStyle?
	@param color: Color3?
	@param header: string?
	@param expression: string?
	@returns void
]]
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

--[[
	@method SetProcessableEntry
	@within Window
	Sets whether the current entry can be processed or not.

	@public
	@param bool: boolean
	@param canProcessResponse: string?
	@returns void
]]
function Window:SetProcessableEntry (bool: boolean, canProcessResponse: string?)
	self.CanProcess = bool
	self.CanProcessResponse = canProcessResponse or ''
end

--[[
	@method Focus
	@within Window
	Focuses the CLI window input box.

	@public
	@param textIsCleared: boolean?
	@returns void
]]
function Window:Focus (textIsCleared: boolean?)
	local writer = self.Writer
	local textBox = writer.Object.TextBox

	textBox:CaptureFocus()
	if textIsCleared then return end
	textBox.CursorPosition = #textBox.Text + 1
end

--[[
	@method ClearWindowInput
	@within Window
	Clears the current input in the CLI window.

	@public
	@returns void
]]
function Window:ClearWindowInput ()
	local textBox = self.Writer.Object.TextBox
	wait()
	textBox.Text = ''
end

--[[
	@method GoToFocus
	@within Window
	Scrolls the CLI window to the bottom.

	@public
	@returns void
]]
function Window:GoToFocus ()
	local cli: Types.CLI = self.Main.Gui
	local window = cli.Window

	window.CanvasPosition = Vector2.new(0, window.AbsoluteCanvasSize.Y)
end

--[[
	@method FocusLost
	@within Window
	Handles when the CLI window input box loses focus.

	@public
	@param enterPressed: boolean
	@returns boolean
]]
function Window:FocusLost (enterPressed: boolean)
	local textBox: TextBox = self.Writer.Object.TextBox

	textBox.Text = Util.trim(textBox.Text)

	self:GoToFocus()

	if enterPressed then
		local commandEntry = textBox.Text
		local willBeProcessed = self.CanProcess

		self.Main.Dispatch(commandEntry)
		if willBeProcessed then
			self:ClearWindowInput()
			self:GoToFocus()
		end
		self:Focus(willBeProcessed)
	else
		self:Focus(false)
	end
end

--[[
	@method Toggle
	@within Window
	Toggles the visibility of the CLI window.

	@public
	@param toggle: boolean
	@returns void
]]
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
