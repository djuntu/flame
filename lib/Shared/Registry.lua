--[[
    Handles Flame's knowledge of commands and what they do.
]]
local Flame = script.Parent.Parent
local Objects = Flame.Objects
local Shared = Flame.Shared
local Types = Flame.Types

local FlameTypes = require(Types.FlameTypes)

local Util = require(Shared.Util)
local Command = require(Objects.Command)
local Error, BaseError = require(Flame.Error) {
	Source = 'Shared',
}

--[[
    @interface Registry
    @within Flame

    @public
    @type RegistryTypes.Registry
]]
local Registry: FlameTypes.Registry = {
	ObjectProps = Util.makeDictionary {},
	CommandArguments = Util.makeDictionary { 'Name', 'Aliases', 'Group', 'Middleware', 'Subcommands', 'New' },
	MiddlewareArguments = Util.makeDictionary { 'BeforeExecution', 'AfterExecution' },
	Middleware = {
		BeforeExecution = nil,
		AfterExecution = nil,
	},
	Flame = nil,
	Reporter = nil,
	Commands = {},
	UnknownError = Error:setSpeaker(Error.Speakers.CommandException):setContext('An unknown error has occured.'),
	Backlog = {},
}
Registry.__index = Registry

--[[
    @prop ObjectProps
    @type Dictionary

    @readonly
    @private
]]
--[[
    @prop CommandArguments
    @type Dictionary

    @readonly
    @private
]]
--[[
    @prop MiddlewareArguments
    @type Dictionary

    @readonly
    @private
]]
--[[
    @prop Middleware
    @type { BeforeExecution: Middleware, AfterExecution: Middleware }

    @readonly
    @private
]]
--[[
    @prop Flame
    @type Flame

    @readonly
    @private
]]
--[[
    @deprecated
    @prop Reporter
    @type Reporter

    @readonly
    @private
]]
--[[
    @prop Commands
    @type Store<Command>

    @readonly
    @private
]]
--[[
    @prop Backlog
    @type Store<Command>

    @readonly
    @private
]]
--[[
    @prop UnknownError
    @type Error

    @readonly
    @private
]]

--[[
    @within Registry
    @w.function Register
    Wrapper function for registering command.
    Registers a Command to the Registry.

    @param command: Command
    @returns void
]]
function Registry.Register (self: FlameTypes.Registry, command: FlameTypes.Command)
	local _exception = BaseError.implements(self.UnknownError)

	if not command or (command and typeof(command) ~= 'Instance') or not command:IsA('ModuleScript') then
		_exception
			:setContext('Cannot register command, expected ModuleScript got other.')
			:setTraceback(debug.traceback())
			:say()
	end

	command = require(command)

	-- Verify the command complies with necessary structures.
	if not self:VerifyObject(command) then
		_exception
			:setContext('Attempted to instantiate command to Registry, given invalid object.')
			:recommend(
				'It\'s highly likely one of your command modules is incorrectly formatted, or you have attempted to add an invalid command using #.addCommand/s().'
			)
			:say()

		return
	end

	-- Ensure validate properties.
	if not self:VerifyCommandProps(command) then
		_exception
			:setContext(
				('Attempted to instantiate %s command yet missing a required property.'):format(
					command.Name or 'Unknown'
				)
			)
			:recommend('All commands should have a Name and an Executor, please check documentation if you are unsure.')
			:say()

		return
	end

	-- Check if the command exists already.
	if self:CheckPresence(command.Name) then
		_exception:setContext(('Command %s already exists!'):format(command.Name)):say()
		return
	end

	-- Ensure middleware (if passed) complies.
	if command.Middleware and next(command.Middleware) then
		local _middlewareException = false
		for mdwr, middleware: FlameTypes.Middleware in pairs(command.Middleware) do
			if not self.MiddlewareArguments[mdwr] then
				_exception
					:setContext(('No such middleware exists as %s'):format(mdwr))
					:recommend('The only middleware types that exist are BeforeExecution and AfterExecution.')
					:say()
				return
			end

			if not self:VerifyCommandMiddleware(middleware) then
				_middlewareException = mdwr
				break
			end
		end

		if _middlewareException then
			_exception
				:setContext(
					('Invalid middleware provided in %s <Middleware %s>, expected Middleware got other.'):format(
						command.Name,
						_middlewareException
					)
				)
				:recommend('Middleware must be a function!')
				:say()
			return
		end
	end

	-- Continue to register command.
	self:RegisterCommand(command)
end

--[[
    @within Registry
    @private function RegisterCommand
    Registers a command object (that which has been verified
    can be registered to the Registry) to the Registry.

    ::: @private :::
    Use :Register instead.

    @param command: Command
    @returns void
]]
function Registry.RegisterCommand (self: FlameTypes.Registry, command: FlameTypes.Command)
	local object, name = Command.new(command)
	self.Commands[name] = object
end

--[[
    @within Registry
    @function VerifyCommandProps
    Validates command props (attributes established in the raw
    command object).

    @param commandProps: CommandProps
    @returns boolean
]]
function Registry.VerifyCommandProps (self: FlameTypes.Registry, props: FlameTypes.CommandProps): boolean
	-- Check initial props.
	for key, value in pairs(props) do
		if not self.CommandArguments[key] then return false end
	end

	return props.Name and true or false
end

--[[
    @within Registry
    @function VerifyCommandMiddleware
    Validates command middleware (through object initialization
    or Flame initialization).

    @param middleware: Middleware?
    @returns boolean
]]
function Registry.VerifyCommandMiddleware (self: FlameTypes.Registry, middleware: FlameTypes.Middleware?): boolean
	local bfExecution, afExecution = middleware.BeforeExecution, middleware.AfterExecution

	if bfExecution and typeof(bfExecution) ~= 'function' then return false end

	if afExecution and typeof(afExecution) ~= 'function' then return false end

	return true
end

--[[
    @within Registry
    @function VerifyObject
    Validates if given object can furthermore be instantiated
    as a Command.

    @param object: any?
    @returns boolean
]]
function Registry.VerifyObject (self: FlameTypes.Registry, object: any?): boolean
	return true
end

--[[
    @within Registry
    @function CheckPresence
    Checks if given command exists via string input.

    @param commandName: string
    @returns boolean
]]
function Registry.CheckPresence (self: FlameTypes.Registry, commandName: string): boolean
	return self.Commands[commandName]
end

--[[
    @within Registry
    @function EvaluateBacklog
    Checks the next command that can be run to concur
    with command state.

    @optin
    @returns Command?
]]
function Registry.EvaluateBacklog (self: FlameTypes.Registry): FlameTypes.Command? end

--[[
    @within Registry
    @uses Dispatcher
    @w.function EvaluateAndFlushBacklog
    Evalautes backlog and then flushes the next command/s which
    can be evaluated.

    @optin
    @returns void
]]
function Registry.EvaluateAndFlushBacklog (self: FlameTypes.Registry) end

--[[
    @within Registry
    @function MarkCommandExecutionBuffer
    Updates the execution state when a command is being ran.

    @optin
    @param executionMarker: ExecutionState
    @returns void
]]
function Registry.MarkCommandExecutionBuffer (self: FlameTypes.Registry, executionMarker: FlameTypes.ExecutionState) end

--[[
    @within Registry
    @w.function Get
    Wrapper function for getting data from the Registry.

    @param getTarget: string
    @param getScope: Scope
    @return getObjective?
]]
function Registry.Get (self: FlameTypes.Registry, target: string, scope: string)
	assert(scope, 'Expected scope got nil.')
	assert(target, 'Expected target got nil.')
	assert(
		typeof(scope) == 'string' and typeof(target) == 'string',
		'Expected strings to be provided got one or more of other.'
	)

	local getEvaluator = 'Get' .. scope

	if not self[getEvaluator] then return nil end
	return self[getEvaluator](self, target)
end

--[[
    @within Registry
    @function GetCommands
    Returns a list of registered commands.

    @returns KeyList<string, Command>
]]
function Registry:GetCommands (): FlameTypes.KeyList<string, FlameTypes.Command>
	return self.Commands
end

--[[
    @within Registry
    @private function GetCommand
    Extract a command from the Registry.

    ::: @private :::
    Use :Get instead.

    @param commandName: string
    @returns Command?, isAliasOfCommand: boolean?
]]
function Registry.GetCommand (self: FlameTypes.Registry, commandName: string): (FlameTypes.Command?, boolean?)
	commandName = string.lower(commandName)
	local existsByExactReference = self.Commands[commandName]
	if existsByExactReference then return existsByExactReference end

	for _, command in pairs(self.Commands) do
		if
			command.Aliases
			and typeof(command.Aliases) == 'table'
			and next(command.Aliases)
			and table.find(command.Aliases, commandName)
		then
			return command, true
		end
	end
end

--[[
    @within Registry
    @function GetMdwr
    Gets the global middleware (within scope) or the dedicated middleware of the given
    command (within scope).

    @param command: Command
    @param middleware: MdwrType
    @returns Middleware
]]
function Registry.GetMdwr (
	self: FlameTypes.Registry,
	command: FlameTypes.Command,
	middleware: FlameTypes.MdwrType
): FlameTypes.Middleware?
	if command.Middleware and typeof(command.Middleware) == 'table' then
		return command.Middleware[middleware] and command.Middleware[middleware][middleware]
	end
end

--[[
    @within Registry
    @function isKind
    Returns if the given object is a member of registered commands.

    @param object: Command | any?
    @returns boolean
]]
function Registry.isKind (object: FlameTypes.Command | any): boolean end

--[[
    @within Registry
    @function extract

    @protected
    @returns Command, listof<Subcommand>
]]
function Registry.extract (key: string): (FlameTypes.Command, { FlameTypes.Subcommand }) end

return function (self): FlameTypes.Registry
	Registry.Flame = self
	return Registry
end
