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
local REALM_MISMATCH =
	'Attempted to run a %s command from the %s. Use the Shared realm if you wish to allow all sources run this command.'

local Error = require(Flame.Error) {
	Source = 'Shared',
}
Error:setSpeaker(Error.Speakers.CommandExecutionException)

local Registry = require(script.Parent.Registry)
local Arguments = require(script.Parent.Parent.Objects.Arguments)
local Command = require(script.Parent.Parent.Objects.Command)
local Dispatcher = {
	Flame = nil,
}

--[[
    @within Dispatcher
    @function Provide
    Provides the CommandContext to be passed through the Registry.

    @param executor: Player?
    @param entryPoint: CommandStyle | string
    @param rawArgs: string
    @returns CommandContext
]]
function Dispatcher.Provide (
	self: FlameTypes.Dispatcher,
	executor: Player?,
	command: FlameTypes.Command,
	rawArgs: string,
	rawText: string
): FlameTypes.CommandContext
	local dispatchContext = {
		Executor = executor,
		IsRobot = not executor,
		RawText = rawText,
		RawArgs = rawArgs,

		Reply = function (_, communication: FlameTypes.ContextCommuniction)
			if runService:IsClient() then
				self.Flame.Gui:Communicate(communication)
			else
				self.Flame.Props.ContextCommunicator:InvokeClient(executor, communication)
			end
		end,
	}

	local commandContext = Command.stackCommandContext(dispatchContext, Command.makeContext(command))
	return commandContext
end

--[[
    @within Dispatcher
    @function Evaluate
    Evaluates if a command can be executed with the given instructions.

    @param executor: Player?
    @param entryPoint: CommandStyle | string
    @param rawArgs: string
    @param rawText: string
    @returns boolean
]]
function Dispatcher.Evaluate (
	self: FlameTypes.Dispatcher,
	executor: Player?,
	command: FlameTypes.Command,
	executable: FlameTypes.Executable,
	rawArgs: string,
	rawText: string
): (boolean, FlameTypes.CommandContext)
	local localBeforeExecMdwr, globalBeforeExecMdwr =
		self.Flame.Registry:GetMdwr(command, 'BeforeExecution'), self.Flame.Middleware.BeforeExecution
	local mdwrEvaluator = localBeforeExecMdwr and localBeforeExecMdwr or globalBeforeExecMdwr

	local commandContext = Dispatcher:Provide(executor, command, rawArgs, rawText)
	local successRunningMdwr, satisfiesBeforeExecMdwr
	if not mdwrEvaluator then
		successRunningMdwr = true
		satisfiesBeforeExecMdwr = true
	else
		successRunningMdwr, satisfiesBeforeExecMdwr = pcall(mdwrEvaluator, commandContext)
	end

	if not successRunningMdwr then
		Error:setContext(satisfiesBeforeExecMdwr):setTraceback(debug.traceback()):say()
		return
	end

	-- check arguments
	local satisfiesArguments, argumentContext = false, {}
	if next(executable.ArgumentStruct) then
		satisfiesArguments, argumentContext = Arguments.Dilute(executable.ArgumentStruct, rawArgs)
	else
		satisfiesArguments = true
	end

	Command.makeContextArgument(commandContext, argumentContext)

	local userCanRunCommand = satisfiesBeforeExecMdwr and satisfiesArguments
	return userCanRunCommand, commandContext
end

--[[
    @within Dispatcher
    @function EvaluateAndRunAsParsed
    Evaluates parsed (non-text) instructions and executes if able.

    @param executor: Player?
    @param commandName: string
    @param commandEntryPoint: CommandStyle | string
    @param rawArgs: string
    @param rawText: string
    @returns CommandExecutionResponse
]]
function Dispatcher.EvaluateAndRunAsParsed (
	self: FlameTypes.Dispatcher,
	executor: Player?,
	commandName: string,
	commandEntryPoint: FlameTypes.CommandStyle | string,
	rawArgs: string,
	rawText: string
)
	local command: FlameTypes.Command = self.Flame.Registry:Get(commandName, 'Command')

	if not command then print('yeah nah') return string.format(UNKNOWN_COMMAND, commandName) end
	if not command:extract(commandEntryPoint) then print('salaam') return string.format(UNKNOWN_COMMAND_ENTRY, commandEntryPoint) end

	local canRun, commandContext =
		self:Evaluate(executor, command, command:extract(commandEntryPoint), rawArgs, rawText)
	if canRun then return self:Execute(command, commandEntryPoint, commandContext) end
	return 'Error evaluating command execution.'
end

--[[
    @within Dispatcher
    @w.function EvaluateAndRun
    Evaluates the given instructions and executes if able.

    @param executor: Player?
    @param rawText: string
    @returns CommandExecutionResponse
]]
function Dispatcher.EvaluateAndRun (
	self: FlameTypes.Dispatcher,
	executor: Player | nil,
	rawText: string
): FlameTypes.CommandExecutionResponse
	local commandName: string, commandEntryPoint: string, rawArgs: string = Util.parseParams(rawText)
	if not commandName then return string.format(INVALID_COMMAND_ARGUMENTS, rawText) end

	local command: FlameTypes.Command = self.Flame.Registry:Get(commandName, 'Command')
	if not command then return string.format(UNKNOWN_COMMAND, commandName) end
	if not command:extract(commandEntryPoint) then return string.format(UNKNOWN_COMMAND_ENTRY, commandEntryPoint) end

	local subCommand: FlameTypes.Subcommand = command:extract(commandEntryPoint)
	if runService:IsClient() and subCommand.Realm == 'Shared' then return self:Dispatch(rawText) end
	if runService:IsClient() and subCommand.Realm == 'Server' then
		return string.format(REALM_MISMATCH, 'Server', 'Client')
	end
	if runService:IsServer() and subCommand.Realm == 'Client' then
		return string.format(REALM_MISMATCH, 'Client', 'Server')
	end

	return self:EvaluateAndRunAsParsed(executor, commandName, commandEntryPoint, rawArgs, rawText)
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
	command: FlameTypes.Command,
	commandEntryPoint: FlameTypes.CommandStyle | string,
	commandContext: FlameTypes.CommandContext
): FlameTypes.CommandExecutionResponse
	local executor = command:extract(commandEntryPoint)
	if not executor then return string.format(UNKNOWN_COMMAND_ENTRY, commandEntryPoint) end

	if runService:IsClient() and executor.Realm == 'Server' then
		return string.format(REALM_MISMATCH, 'Server', 'Client')
	end
	if runService:IsServer() and executor.Realm == 'Client' then
		return string.format(REALM_MISMATCH, 'Client', 'Server')
	end

	local success, commandResponse = pcall(executor.Executor, commandContext)
	if not success then return {
		Success = false,
		UserResponse = commandResponse,
	} end

	if self.Flame.Props.DoNotAnnounceRunner then return true end
	if commandResponse and typeof(commandResponse) ~= 'table' then
		commandResponse = {
			Success = true,
			UserResponse = (commandResponse and typeof(commandResponse) == 'string' and commandResponse)
				or 'Command executed successfully.',
		}
	end
	return commandResponse or {
		Success = true,
		UserResponse = 'Command executed successfully.',
	}
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
