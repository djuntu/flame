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

local Gui: GuiTypes.CLIRegistry = {
	Events = nil,
	Handler = nil,
	Flame = nil,
}
Gui.__index = Gui

function Gui:ExecuteAction (...) end

function Gui.create ()
	local self = setmetatable(Gui, Gui)

	self.Handler = Initializer(self) :: GuiTypes.InitializedCLIRegistry
	self.Events = Events(self.Handler) :: GuiTypes.Events
	self.Toggled = false

	-- Hook main events
	UserInputService.InputBegan:Connect(function (input)
		if table.find(self.Flame.Props.EntryPoints, input.KeyCode) then
			self.Toggled = not self.Toggled
			self.Handler.Window:Toggle(self.Toggled)
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

	self.Flame.Props.ContextCommunicator.OnClientEvent:Connect(function (...)
		self:ExecuteAction(...)
	end)

	return self
end

function Gui:InvokeEvent (eventName: string, ...)
	if self.Events[eventName] then self.Events[eventName](...) end
end

return function (Flame: Types.FlameMain<BuildTypes.ClientBuildProps>)
	Gui.Flame = Flame
	Gui.create()

	return Gui
end
