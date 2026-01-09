-- Builds the user's view of the Flame library by provided access points to API.
local lib = script.Parent.Parent

local Types = lib.Types
local FlameTypes = require(Types.FlameTypes)
local Middleware = require(lib.Objects.Middleware)

local function addCommand (self: FlameTypes._Flame, module: ModuleScript)
	self.Registry:Register(module)
	return self
end

local function addMiddleware (self: FlameTypes._Flame, module: ModuleScript)
	if not module or (module and typeof(module) ~= 'Instance') or not module:IsA('ModuleScript') then
		error('addMiddleware expects a ModuleScript!')
	end

	for mdwrType, callback in pairs(require(module)) do
		self.Middleware[mdwrType] = callback
	end
end

--[[
    @interface View
    Provides bundle access to Flame's API which users can use without tangling
    with the actual API (the user's View).

    @public
    @type View* extends FlameMain
]]
return function <Context>(Flame: FlameTypes.FlameMain<Context>)
	type M = FlameTypes.FlameMain<Context>
	Flame.addCommand = function (...): M
		return addCommand(...)
	end
	Flame.addMiddleware = function (...): M
		return addMiddleware(...)
	end
end
