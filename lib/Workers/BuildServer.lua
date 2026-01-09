-- Builds Flame on the server, handles the actual initialization of dependencies.

local runService = game:GetService('RunService')
local lib = script.Parent.Parent

local Types = lib.Types
local ErrorTypes = require(Types.ErrorTypes)
local BuildTypes = require(Types.BuildTypes)

local BUILD: BuildTypes.Builder<BuildTypes.ServerBuildProps> = {}

--[[
    @object Error
    @within Flame

    Instantiate the error object for the ServerBuild to appropriately document
    and report errors within server initialization.
]]
local Error: ErrorTypes.ErrorObject = require(lib.Error) {
	Source = 'Server',
}

Error:setSpeaker(Error.Speakers.InitializationException)

--[[
    Verify that the builder isn't being called on the client.
]]
if runService:IsClient() then return end

--[[
    @object Build
    @within Flame

    Manages the build for the BuildServer mainly for cacheing and state.
]]
function BUILD:__call (buildConfig: BuildTypes.FlameBuildConfig)
	if self.IS_BUILDING or self.HAS_BUILT then
		Error:setContext('Attempted to rebuild Flame Server.')
			:setTraceback(debug.traceback())
			:recommend(
				'Do not try to manually require the BuildServer directly. Remove the import at this traceback.'
			)
			:say()
		return
	end
	self.IS_BUILDING = true

	local serverBuilt, response: BuildTypes.ServerBuildProps | string do
		serverBuilt, response = pcall(function()
			local oneWayComm, dispatcher = require(lib.Create.Net) ( buildConfig.EnableServerClientComms and 'ContexComm', 'Dispatcher', buildConfig.NetworkRoot )
			return {
				ContextCommunicator = oneWayComm,
				DispatcherReceiver = dispatcher,
				DoNotAnnounceRunner = buildConfig.DoNotAnnounceRunner,
			}
		end)

		if not serverBuilt then
			Error:setContext('Internal exception encountered building Flame.\n' .. tostring(response))
			:setTraceback(debug.traceback())
			:recommend(
				'Reinstall the Flame wally package and/or, try install a younger version of Flame.'
			)
			:say()
		else
			self.Props = response :: BuildTypes.ServerBuildProps
		end
	end

	self.HAS_BUILT = true

	return self
end

return setmetatable({}, BUILD)
