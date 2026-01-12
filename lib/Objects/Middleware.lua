-- Handles code which is executed prior to and after the execution of a command.
local lib = script.Parent.Parent

local Types = lib.Types
local FlameTypes = require(Types.FlameTypes)
local Util = require(lib.Shared.Util)
local Error = require(lib.Error) {
	Source = 'Shared',
}
Error:setSpeaker(Error.Speakers.MiddlewareException)

--[[
    @interface Middleware
    @within Middleware

    @public
    @type MiddlewareAbsorber
]]
local Middleware = {
	Types = Util.makeDictionary { 'BeforeExecution', 'AfterExecution' },
}

function Middleware.new (
	mdwrType: FlameTypes.MdwrType,
	callback: (context: FlameTypes.CommandContext) -> boolean?
): FlameTypes.MiddlewareReference
	if not mdwrType or not Middleware.Types[mdwrType] then
		Error:setContext(`{mdwrType} is not a valid MiddlewareType.`)
			:recommend('Recommended types: BeforeExecution, AfterExecution')
			:setTraceback(debug.traceback())
			:say()
		return
	end

	return {
		[mdwrType] = callback,
	}
end

return Middleware
