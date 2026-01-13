local runService = game:GetService('RunService')

-- Handles building commands through the Registry and providing an outward
-- view for developers when building commands.
local Flame = script.Parent.Parent

local Types = Flame.Types
local FlameTypes = require(Types.FlameTypes)
local ErrorTypes = require(Types.ErrorTypes)
local Arguments = require(Flame.Objects.Arguments)
local Util = require(Flame.Shared.Util)
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

function Command.new (command: FlameTypes.CommandProps): (FlameTypes.Command, string)
	local aliases = Command.formatAliases(command.Aliases)
	local CommandHologram = {
		Name = Command.formatName(command.Name),
		Aliases = aliases,
		Group = command.Group,
		Store = {},
		State = {},
		Middleware = command.Middleware,
		__newindex = function (self, k, v) end,
	}
	local _contextUsesState = rawget(command, 'New') and typeof(rawget(command, 'New')) == 'function'
	local _commands = command.Subcommands

	-- Start tracking state.
	if _contextUsesState then CommandHologram.State = command.New() end

	-- Instantiate each command to mesh context on execution.
	for commandName, subcommand in pairs(_commands) do
		CommandHologram.Store[commandName] = Command.makeContextProvider(subcommand)
	end

	CommandHologram.__index = CommandHologram.Store

	function CommandHologram.extract (self: FlameTypes.Command, subcommand: string)
		return self.Store[subcommand]
	end

	return setmetatable(CommandHologram, CommandHologram), CommandHologram.Name
end

--[[
    @within Command
    @function stackCommandContext
	Unionizes the given contexts to create a CommandContext.

	@private
	@notprototypical
]]
function Command.stackCommandContext (...)
	local commandContext: FlameTypes.CommandContext = {}
	for _, context in pairs { ... } do
		for key, arg in pairs(context) do
			commandContext[key] = arg
		end
	end

	return commandContext
end

--[[
    @within Command
    @function makeContext
	Creates an ExecutionContext from a Command, which is the native
	Context of the Command itself.

	@private
	@notprototypical
]]
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
		GetIcon = function (self: FlameTypes.ExecutionContext, iconName: FlameTypes.IconName): string
			-- This needs to be shared in a configuration module with the client down the line
			local icons = {
				['Success'] = 'rbxassetid://81345199294878',
				['Failure'] = 'rbxassetid://130930319386024',
			}

			return iconName and (icons[iconName] or '') or ''
		end,
	}
end

--[[
    @within Command
    @function makeContextArgument
	Unionizes the ArgumentContext to the CommandContext to derive from the CommandContext to
	include ArgumentContext (still appropriates to CommandContext).

	@private
	@notprototypical
]]
function Command.makeContextArgument (
	commandContext: FlameTypes.CommandContext,
	argumentContext: FlameTypes.KeyList<string, FlameTypes.ArgumentContext>
): FlameTypes.CommandContext
	commandContext.Arguments = argumentContext
	commandContext.GetArgument = function (self: FlameTypes.CommandContext, name: string)
		assert(name, 'Expected argument for GetArgument got nil.')
		assert(self.Arguments[name], ('%s is not a known argument in %s'):format(name, self.Name))

		return self.Arguments[name].Input
	end
end

--[[
    @within Command
    @function makeContextProvider
	Creates a Provider for the Subcommand itself, this is what is called
	and utilized when being executed itself.

	@private
	@notprototypical
]]
function Command.makeContextProvider (subcommand: FlameTypes.Subcommand)
	return {
		Executor = function (commandContext: FlameTypes.CommandContext)
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

			return subcommand.Exec(commandContext)
		end,
		Realm = subcommand.Realm,
		ArgumentStruct = subcommand.ArgumentStruct,
	}
end

--[[
    @within Command
    @function makeCommandExecutor
	Structures a Command based on its hoist and realm to create a provisional
	Executable (Subcommand)

	@private
	@notprototypical
]]
function Command.makeCommandExecutor (
	commandOptions: FlameTypes.CommandOptions,
	_exception: ErrorTypes.ErrorObject,
	commandStyle: FlameTypes.CommandStyle
): FlameTypes.Subcommand
	local hoist, realm = commandOptions.Hoist, commandOptions.Realm
	local arguments = commandOptions.Arguments or {}
	return function (Executor: (context: FlameTypes.CommandContext) -> ())
		if not rawget(hoist, 'Subcommands') then hoist.Subcommands = {} end
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
			ArgumentStruct = Arguments.Struct(arguments),
		}
	end
end

--[[
    @within Command
    @function formatName
	Strips and lowers string.

	@private
	@notprototypical
]]
function Command.formatName (name: string): string
	return name:lower():gsub('%s+', '')
end

--[[
    @within Command
    @function formatAliases
	Formats all given Aliases to comply with the same logic as
	the name.

	@private
	@notprototypical
]]
function Command.formatAliases (aliases: { string }?)
	if aliases and typeof(aliases) == 'table' and next(aliases) then
		Util.map(aliases, function (key: number)
			local alias = aliases[key]
			if typeof(alias) ~= 'string' then return nil end

			return Command.formatName(alias)
		end)

		return aliases
	end
end

--[[
    @within Command
    @function Primary
	Creates a Primary Command based on the given options.

	::: @note :::
	A primary command is that which is called by default/can be called without
	any further routing.

	@pseudocode
	```lua
	local Command = ...

	run Command, +args...
	```

	@cli
	```lua
	$ command 'Arguments', ...
	```

	@public
	@param commandOptions: CommandOptions
	@returns Subcommand
]]
function Command.prototype.Primary (commandOptions: FlameTypes.CommandOptions): FlameTypes.Subcommand
	local _exception = BaseError.implements(runService:IsClient() and ClientReporter or ServerReporter)
	_exception
		:setContext('Expected Hoist, Realm properties when passing command options.')
		:recommend('Ensure all commands when building have a hoist and a realm.')

	local hoist, realm = commandOptions.Hoist, commandOptions.Realm
	_exception:assertsay(hoist and realm)

	return Command.makeCommandExecutor(commandOptions, _exception, 'Primary')
end

--[[
    @within Command
    @function Secondary
	Creates a Secondary Command based on the given options.

	::: @note :::
	A secondary command is one which is not executed by default/requires
	a routing input when calling.

	@pseudocode
	```lua
	local Command = ...

	run Command, EntryPoint, +args...
	```

	@cli
	```lua
	$ command/Route 'Arguments', ...
	```

	@public
	@param commandOptions: CommandOptions
	@returns Subcommand
]]
function Command.prototype.Secondary (commandOptions: FlameTypes.CommandOptions): FlameTypes.Subcommand
	local _exception = BaseError.implements(runService:IsClient() and ClientReporter or ServerReporter)
	_exception
		:setContext('Expected Hoist, Realm, Name properties when passing command options.')
		:recommend('Ensure all commands when building have a hoist and a realm.')

	local hoist, realm, name = commandOptions.Hoist, commandOptions.Realm, commandOptions.Name
	_exception:assertsay(hoist and realm and name)

	return Command.makeCommandExecutor(commandOptions, _exception, 'Secondary')
end

return Command.prototype
