local runService = game:GetService('RunService')

-- Handles building commands through the Registry and providing an outward
-- view for developers when building commands.
local Flame = script.Parent.Parent

local Types = Flame.Types
local FlameTypes = require(Types.FlameTypes)
local ErrorTypes = require(Types.ErrorTypes)
local ServerReporter, BaseError = require(Flame.Error) {
	Source = 'Server',
}
local ClientReporter = require(Flame.Error) {
	Source = 'Client',
}
ClientReporter:setSpeaker(ServerReporter.Speakers.CommandExecutionException)

--[[
    @interface Command
    @within Flame

    @public
    @type Commands
]]
local Command = {
	prototype = {},
}
Command.prototype.__index = Command
Command.prototype = setmetatable({}, Command.prototype)

function Command.new (command: FlameTypes.CommandProps): FlameTypes.Command
	local CommandHologram = {
		Name = command.Name,
		Aliases = command.Aliases or {},
		Group = command.Group,
		Store = {},
		State = {},
		__newindex = function (self, k, v) end,
	}
	local _contextUsesState = rawget(command, 'New') and typeof(rawget(command, 'New')) == 'function'
	local _commands = command.Subcommands

	-- Start tracking state.
	if _contextUsesState then CommandHologram.State = command.New() end

	-- Instantiate each command to mesh context on execution.
	for commandName, subcommand in pairs(_commands) do
		CommandHologram.Store[commandName] = Command.makeContextProvider(
			CommandHologram,
			subcommand
		)
	end

	CommandHologram.__index = CommandHologram.Store

	function CommandHologram.extract (self: FlameTypes.Command, subcommand: string)
		return self.Store[subcommand]
	end

	return setmetatable(CommandHologram, CommandHologram)
end

function Command.stackCommandContext (...)
	local commandContext: FlameTypes.CommandContext = {}
	for _, context in pairs { ... } do
		for key, arg in pairs(context) do
			commandContext[key] = arg
		end
	end

	return commandContext
end

function Command.makeContext <State>(commandHologram: FlameTypes.Command): FlameTypes.ExecutionContext
	return {
		State = commandHologram.State,
		Name = commandHologram.Name,
		Group = commandHologram.Group,
		Aliases = commandHologram.Aliases,

		GetStore = function (self: FlameTypes.ExecutionContext): FlameTypes.CommandStore
			return commandHologram.Store
		end,
		GetState = function (self: FlameTypes.ExecutionContext): FlameTypes.State
			return commandHologram.State
		end,
	}
end

function Command.makeContextProvider (commandHologram: FlameTypes.Command, subcommand: FlameTypes.Subcommand)
	return {
		Executor = function (dispatchContext: FlameTypes.DispatchContext)
			local _commandContext =
				Command.stackCommandContext(dispatchContext, Command.makeContext(commandHologram))

			if subcommand.Realm ~= 'Shared' then
				local isServerRealm = subcommand.Realm ~= 'Client'

				if isServerRealm and runService:IsClient() then
					ClientReporter:setContext('Attempted to run a Server subcommand on the client.'):say()
					return
				elseif not isServerRealm and runService:IsServer() then
					ServerReporter:setContext('Attempted to run a Client subcommand on the server.'):say()
					return
				end
			end

			subcommand.Exec(_commandContext)
		end,
        Realm = subcommand.Realm,
	}
end

function Command.makeCommandExecutor (
	commandOptions: FlameTypes.CommandOptions,
	_exception: ErrorTypes.ErrorObject,
	commandStyle: FlameTypes.CommandStyle
)
	local hoist, realm = commandOptions.Hoist, commandOptions.Realm
	return function (Executor: (context: FlameTypes.CommandContext) -> ())
		_exception
			:setContext(('Invalid Executor expected type function got %s in %s'):format(typeof(Executor), hoist.Name))
			:recommend('You must pass a function as the only argument of your command builder.')
		_exception:assertsay(typeof(Executor) == 'function')

		local reference = commandStyle == 'Primary' and 'Primary' or commandOptions.Name
		if rawget(hoist.Subcommands, reference) then
			_exception
				:setContext(
					('%s has two or more %s commands, use a secondary command instead.'):format(hoist.Name, reference)
				)
				:recommend()
			return
		end

		hoist.Subcommands[reference] = {
			Realm = realm,
			Exec = Executor,
		}
	end
end

function Command.prototype.Primary (commandOptions: FlameTypes.CommandOptions)
	local _exception = BaseError.implements(runService:IsClient() and ClientReporter or ServerReporter)
	_exception
		:setContext('Expected Hoist, Realm properties when passing command options.')
		:recommend('Ensure all commands when building have a hoist and a realm.')

	local hoist, realm = commandOptions.Hoist, commandOptions.Realm
	_exception:assertsay(hoist and realm)

	return Command.makeCommandExecutor(commandOptions, _exception, 'Primary')
end

function Command.prototype.Secondary (commandOptions: FlameTypes.CommandOptions)
	local _exception = BaseError.implements(runService:IsClient() and ClientReporter or ServerReporter)
	_exception
		:setContext('Expected Hoist, Realm, Name properties when passing command options.')
		:recommend('Ensure all commands when building have a hoist and a realm.')

	local hoist, realm, name = commandOptions.Hoist, commandOptions.Realm, commandOptions.Name
	_exception:assertsay(hoist and realm and name)

	return Command.makeCommandExecutor(commandOptions, _exception, 'Secondary')
end

return Command.prototype
