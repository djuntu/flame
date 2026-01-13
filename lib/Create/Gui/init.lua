-- Handles the initialization of the command-line interface and managing external
-- inputs into the CLI.
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

if not RunService:IsClient() then
	warn('You cannot run the Gui initializer on the server.')
	return
end

local Types = require(script.Parent.Parent.Types.FlameTypes)
local BuildTypes = require(script.Parent.Parent.Types.BuildTypes)
local GuiTypes = require(script.Types)
local Initializer = require(script.Initializer)
local Events = require(script.Events)

--[[
	@interface CLIRegistry
	@within Create.Gui

	@public
	@type CLIRegistry
]]
local Gui: GuiTypes.CLIRegistry = {
	Events = nil,
	Handler = nil,
	Flame = nil,
}
Gui.__index = Gui
--[[
	@prop Events
	@within CLIRegistry

	@public
	@type GuiTypes.Events
	@readonly
]]
--[[
	@prop Handler
	@within CLIRegistry

	@public
	@type GuiTypes.InitializedCLIRegistry
	@readonly
]]
--[[
	@prop Flame
	@within CLIRegistry

	@public
	@type FlameMain<BuildTypes.ClientBuildProps>
	@readonly
]]

--[[
	@method Communicate
	@within CLIRegistry
	Handles communication from the command context to the CLI window.

	@public
	@param communication: Types.ContextCommuniction
	@returns void
]]
function Gui:Communicate (communication: Types.ContextCommuniction)
	local Handler: GuiTypes.InitializedCLIRegistry = self.Handler

	if not communication then return end
	if typeof(communication) == 'table' then
		local lineStyle = communication.LineStyle or 'PlainText'
		local color = communication.Color
		local message = communication.Message
		local headerText = communication.HeaderText
		local imageId = communication.Expression
		if typeof(color) == 'string' then
			color = color == 'Green' and Color3.fromRGB(26, 255, 0)
				or color == 'Red' and Color3.fromRGB(255, 0, 72)
				or Color3.new(1, 1, 1)
		elseif typeof(color) ~= 'Color3' then
			color = Color3.new(1, 1, 1)
		end

		if typeof(lineStyle) ~= 'string' then
			lineStyle = 'PlainText'
		else
			if lineStyle ~= 'PlainText' and lineStyle ~= 'Expressive' and lineStyle ~= 'Header' then
				lineStyle = 'PlainText'
			end
		end

		if typeof(message) ~= 'string' then message = '[Invalid format provided]' end

		if lineStyle == 'Header' then
			if typeof(headerText) ~= 'string' then headerText = '[Invalid header provided]' end
		end

		if lineStyle == 'Expressive' then
			if typeof(imageId) ~= 'string' then
				warn('[Communication error] ImageId expects a string in format rbxassetid://xxxxxxxxx')
				imageId = ''
			end
		end
		Handler.Window:WriteLine(message, lineStyle, color, headerText, imageId)
	elseif typeof(communication) == 'string' then
		Handler.Window:WriteLine(communication)
	end
end

--[[
	@function create
	@within CLIRegistry
	Creates the CLI registry object.

	@private
	@returns CLIRegistry
]]
function Gui.create ()
	local self = setmetatable(Gui, Gui)

	self.Handler = Initializer(self) :: GuiTypes.InitializedCLIRegistry
	self.Events = Events(self.Handler) :: GuiTypes.Events
	self.Toggled = false

	self.Navigation = {
		[Enum.KeyCode.Up] = 'Up',
		[Enum.KeyCode.Down] = 'Down',
	}

	-- Hook main events
	UserInputService.InputBegan:Connect(function (input)
		if table.find(self.Flame.Props.EntryPoints, input.KeyCode) then
			self.Toggled = not self.Toggled
			self.Handler.Window:Toggle(self.Toggled)
		elseif self.Navigation[input.KeyCode] then
			if not self.Toggled then return end
			self.Handler.Autocomplete:CycleInput(self.Navigation[input.KeyCode], self.Handler.UserInput)
		elseif input.KeyCode == Enum.KeyCode.Tab then
			if not self.Toggled then return end
			self.Handler.Autocomplete:Autocomplete()
		end
	end)

	for _, event: BindableEvent in pairs(self.Flame.Props.EntryPoints) do
		if event:IsA('BindableEvent') then
			event.Event:Connect(function ()
				self.Toggled = not self.Toggled
				self.Handler.Window:Toggle(self.Toggled)
			end)
		end
	end

	local TextBox = self.Handler.Window.Writer.Object.TextBox
	TextBox.FocusLost:Connect(function (enterPressed)
		self.Handler.Window:FocusLost(enterPressed)
	end)

	TextBox:GetPropertyChangedSignal('Text'):Connect(function ()
		self.Handler.Window:GoToFocus()
		if TextBox.Text:gmatch('\t') then TextBox.Text = TextBox.Text:gsub('\t', '') end
		if self.Handler.OnTextChanged then self.Handler.OnTextChanged(TextBox.Text) end
	end)

	self.Flame.Props.ContextCommunicator.OnClientInvoke = function (communication: Types.ContextCommuniction)
		self:Communicate(communication)
	end

	return self
end

--[[
	@method InvokeEvent
	@within CLIRegistry
	Invokes an event from the Events table.

	@public
	@param eventName: string
	@returns void
]]
function Gui:InvokeEvent (eventName: string, ...)
	if self.Events[eventName] then self.Events[eventName](...) end
end

return function (Flame: Types.FlameMain<BuildTypes.ClientBuildProps>)
	Gui.Flame = Flame
	Gui.create()

	return Gui
end
