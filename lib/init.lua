-- Flame is a lightweight object-orientated command evaluation library, and aims to
-- provide straightforward command creation whilst exposing more features to the user
-- to build more complex applications.

local runService = game:GetService('RunService')
local Flame = script

local INVALID_INDEX_ERROR = 'Attempted to index Flame with forbidden/unknown key \'%s\'.'
local UNCONTROLLED_INDEX_ERROR = 'Attempted to create new key %s with value %s in Flame.'

local Types = Flame.Types
local Build = require(Flame.Workers.Build)
local Util = require(Flame.Shared.Util)
local BuildTypes = require(Types.BuildTypes)
local FlameTypes = require(Types.FlameTypes)
local View = require(Flame.Create.View)

local BuiltInCommands = Flame.BuiltInCommands
local BuiltInTypes = Flame.BuiltInTypes

--[[
    Creates the builder for initializing Flame.

    @att Dispatcher: Types.Dispatcher*
    @within Flame

    Handles the navigation from the user (whether that be the server or the client)
    to the actual command.


    @att Registry: Types.Registry*
    @within Flame

    Handles the registration of commands within Flame.


    @att Util: Types.Util*
    @within Flame

    Handles isolated utility functions which are built specifically for Flame Type instances.
]]
return function <C>(userBuilderOptions: BuildTypes.FlameBuildConfig?): FlameTypes.FlameMain<C>
	local _Flame: BuildTypes.Builder<C> =
		Build(userBuilderOptions and typeof(userBuilderOptions) and next(userBuilderOptions) and userBuilderOptions or {
			NetworkRoot = nil,
			Util = Util,
		})
	do
		_Flame = setmetatable(_Flame, {
			__index = function (self, k)
				error(INVALID_INDEX_ERROR:format(k))
			end,
		}) :: FlameTypes.FlameMain<C>

		_Flame.Dispatcher = require(Flame.Shared.Dispatcher)(_Flame)
		_Flame.Registry = require(Flame.Shared.Registry)(_Flame)
		_Flame.Middleware = {}

		if runService:IsClient() then
			require(Flame.Create.Gui)(_Flame)
		end

		local UserView: C = View(_Flame)

		local Main: FlameTypes.FlameMain<C> = _Flame
		for _, type in BuiltInTypes:GetChildren() do
			if not type:IsA('ModuleScript') then continue end

			Main:addType(type)
		end
		for _, command in BuiltInCommands:GetChildren() do
			if not command:IsA('ModuleScript') then continue end

			Main:addCommand(command)
		end
	end

	return _Flame
end
