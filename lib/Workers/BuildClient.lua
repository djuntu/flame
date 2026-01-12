-- Builds Flame on the client, handles the front-end and replication.

local runService = game:GetService('RunService')
local lib = script.Parent.Parent

local Types = lib.Types
local ErrorTypes = require(Types.ErrorTypes)
local BuildTypes = require(Types.BuildTypes)

local BUILD: BuildTypes.Builder<BuildTypes.ClientBuildProps> = {}

--[[
    @object Error
    @within Flame

    Instantiate the error object for the ClientBuild to appropriately document
    and report errors within client initialization.
]]
local Error: ErrorTypes.ErrorObject = require(lib.Error) {
	Source = 'Client',
}

Error:setSpeaker(Error.Speakers.InitializationException)

--[[
    Verify that the builder isn't being called on the client.
]]
if runService:IsServer() then return end

--[[
    @object Build
    @within Flame

    Manages the build for the BuildClient mainly for cacheing and state.
]]
function BUILD:__call (buildConfig: BuildTypes.FlameBuildConfig)
	if self.IS_BUILDING or self.HAS_BUILT then
		Error:setContext('Attempted to rebuild Flame Client.')
			:setTraceback(debug.traceback())
			:recommend('Do not try to manually require the BuildClient directly. Remove the import at this traceback.')
			:say()
		return
	end
	self.IS_BUILDING = true

	local clientBuilt, response: BuildTypes.ClientBuildProps | string
	do
		clientBuilt, response = pcall(function ()
			local netRoot = lib:FindFirstChild('Net')
			local entryPoints = {}
			if buildConfig.EntryPoints and typeof(buildConfig.EntryPoints) == 'table' then
				for _, point: Instance | Enum in pairs(buildConfig.EntryPoints) do
					if typeof(point) ~= 'Enum' and typeof(point) ~= 'Instance' then
						warn(`{point} is not an appropriate entry point.`)
						continue
					end

					if typeof(point) == 'Instance' and not point:IsA('BindableEvent') then
						warn(`{point} is not an appropriate entry point.`)
						continue
					end

					table.insert(entryPoints, point)
				end
			end

			if not next(entryPoints) then entryPoints = { Enum.KeyCode.F2 } end

			return {
				ContextCommunicator = netRoot:FindFirstChild('ContextComm'),
				DispatcherReceiver = netRoot:FindFirstChild('Dispatcher'),
				DoNotAnnounceRunner = buildConfig.DoNotAnnounceRunner,
				EntryPoints = entryPoints,
			}
		end)

		if not clientBuilt then
			Error:setContext('Internal exception encountered building Flame.\n' .. tostring(response))
				:setTraceback(debug.traceback())
				:recommend('Reinstall the Flame wally package and/or, try install a younger version of Flame.')
				:say()
		else
			self.Props = response :: BuildTypes.ClientBuildProps
		end
	end

	self.HAS_BUILT = true

	return self
end

return setmetatable({}, BUILD)
