-- Handles creating the remotes which will be used for data correspondence.

local runService = game:GetService('RunService')
local lib = script.Parent.Parent

--[[
    Instance.new wrapper for cleaner logic.
]]
local function create (className: string, name: string, parent: Instance?)
	if parent and parent:FindFirstChild(name) then return end

	local instance = Instance.new(className, parent)
	instance.Name = name

	return instance
end

--[[
    Network builder called upon by a metamethod to prevent
    duplication errors.
]]
local NetBuilder = {}

-- Disallow client access.
if runService:IsClient() then return NetBuilder._Root end

--[[
    Builds network based on optional oneWayCommunicator and required dispatcher.
    @within Net
    @params oneWayCommunicator: string!, dispatcher: string!, networkRoot: Instance?
    @returns (RemoteEvent, RemoteFunction, _networkRoot?)
]]
function NetBuilder:__call <R>(
	oneWayCommunicator: string?,
	dispatcher: string,
	networkRoot: R
): (RemoteEvent?, RemoteFunction, R)
	assert(dispatcher, 'Expected Dispatcher name got nil.')

	local instanceNetworkRoot = networkRoot or create('Folder', 'Net', lib)
	return oneWayCommunicator and create('RemoteFunction', oneWayCommunicator, instanceNetworkRoot),
		create('RemoteFunction', dispatcher, instanceNetworkRoot),
		networkRoot
end

return setmetatable({}, NetBuilder)
