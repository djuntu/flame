--[[
    This is a example built-in command that shows using Shared Realm commands in Flame.
    It doesn't necessarily display parsing or arguments, more so a focus on the realm itself.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)

-- Create the 'showSomeColor' command
local ClientDoesThis: Types.CommandProps = {
	Name = 'clientDoesThis',
	Aliases = {},
	Group = 'Utilities',
}

Command.Primary {
	Hoist = ClientDoesThis,
	Realm = 'Client',
	Arguments = {
		{
			Type = 'number',
			Name = 'Parts',
			Description = 'The number of parts you wish to spawn.',
		},
	},
}(function (context: Types.CommandContext)
	local executor = context.Executor
	local parts = context:GetArgument('Parts')

	local humanoidRootPart: BasePart = executor.Character.HumanoidRootPart
	for i = 1, parts do
		local part = Instance.new('Part', workspace)
		part.Anchored = false
		part:PivotTo(humanoidRootPart.CFrame + Vector3.new(0, 5, 0))

		context:Reply(`Spawned part {i}/{parts}.`)
		task.wait(0.1)
	end

	return 'Spawned all parts!'
end)

return ClientDoesThis
