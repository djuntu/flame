--[[
    Handles the sendnig and receiving of Flame commands as well as what happens before and after.
]]
local runService = game:GetService('RunService')

local Flame = script.Parent.Parent
local Objects = Flame.Objects
local Shared = Flame.Shared
local Types = Flame.Types

local Util = require(Shared.Util)
local FlameTypes = require(Types.FlameTypes)
local BuildTypes = require(Types.BuildTypes)

local UNKNOWN_COMMAND = '%s is not a valid command.'
local UNKNOWN_COMMAND_ENTRY = '%s is not a valid command.'
local INVALID_COMMAND_ARGUMENTS = 'Could not parse given input:\n%s'

local Registry = require(script.Parent.Registry)
local Dispatcher = {
	Flame = nil,
}

--[[
    @within Dispatcher
    @function Evaluate
    Evaluates if a command can be executed with the given instructions.

    @param executor: Player?
    @param entryPoint: CommandStyle | string
    @param rawArgs: string
    @returns boolean
]]
function Dispatcher.Evaluate (self: FlameTypes.Dispatcher, executor: Player?, command: FlameTypes.Command, rawArgs: string, rawText: string): boolean
    local dispatchContext = {
        Executor = executor,
        IsRobot = not executor,
        RawText = rawText,
        RawArgs = rawArgs,
    }
end

--[[
    @within Dispatcher
    @w.function
    Evaluates the given instructions and executes if able.

    @param executor: Player?
    @param commandName: string
    @param commandEntryPoint: CommandStyle | string
    @param rawArgs: string
    @returns CommandExecutionResponse
]]
function Dispatcher.EvaluateAndRun (
	self: FlameTypes.Dispatcher,
	executor: Player | nil,
	rawText: string
): FlameTypes.CommandExecutionResponse
    local commandName: string, commandEntryPoint: string, rawArgs: string = Util.makeParams(rawText)

    if not commandName then
        return string.format(INVALID_COMMAND_ARGUMENTS, rawText)
    end

	if runService:IsClient() then
		self:Dispatch(commandName, commandEntryPoint, rawArgs)
		return
	end

	local isHuman = executor and true or false
	local command: FlameTypes.Command = self.Flame.Registry:Get(commandName, 'Command')

	if not command then return string.format(UNKNOWN_COMMAND, commandName) end
	if not command:extract(commandEntryPoint) then return string.format(UNKNOWN_COMMAND_ENTRY, commandEntryPoint) end

    local canRun = self:Evaluate()
end

--[[
    @within Dispatcher
    @function
    Dispatches a command across the wire.

    @param Command
    @returns CommandExecutionResponse
]]
function Dispatcher.Dispatch (self: FlameTypes.Dispatcher, rawText: string)
	local flame: FlameTypes.FlameMain<BuildTypes.ClientBuildProps> = self.Flame
	return flame.Props.DispatcherReceiver:InvokeServer(rawText)
end

--[[
    @within Dispatcher
    @function
    Executes a command.

    @param executor: Player?
    @param commandEntryPoint: FlameTypes.CommandStyle | string
    @param rawArgs: string
    @returns CommandExecutionResponse
]]
function Dispatcher.Execute (
	self: FlameTypes.Dispatcher,
	executor: Player | nil,
	commandEntryPoint: FlameTypes.CommandStyle | string,
	rawArgs: string
): FlameTypes.CommandExecutionResponse
end

return function (self: FlameTypes._Flame): FlameTypes.Dispatcher
	if runService:IsServer() then
		local flame: FlameTypes.FlameMain<BuildTypes.ServerBuildProps> = self
		flame.Props.DispatcherReceiver.OnServerInvoke = function (executor: Player, ...)
			return Dispatcher:EvaluateAndRun(executor, ...)
		end
	end

	Dispatcher.Flame = self
	return Dispatcher
end
