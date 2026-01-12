local runService = game:GetService('RunService')
local lib = script.Parent.Parent

local BuildTypes = require(lib.Types.BuildTypes)

--[[
    Handles the pathing of the build mode when initializing
    Flame.

    @params FlameBuildConfig
    @returns FlameBuildTable
]]
return function <C>(config: BuildTypes.FlameBuildConfig): BuildTypes.Builder<C>
	local isClient = runService:IsClient()

	local builder = isClient and require(lib.Workers.BuildClient) or require(lib.Workers.BuildServer)
	return builder(config)
end
