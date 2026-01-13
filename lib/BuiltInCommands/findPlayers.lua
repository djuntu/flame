--[[
    This is a example built-in command that shows using types which are constantly changing.
    This shows the full abilities of the ListableType.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)

-- Create the 'findPlayers' command
local FindPlayers: Types.CommandProps = {
	Name = 'findPlayers',
	Aliases = {},
	Group = 'Utilities',
}

Command.Primary {
	Hoist = FindPlayers,
	Realm = 'Shared',
	Arguments = {
		{
			Type = 'players',
			Name = 'Players',
			Description = 'The players you want to find!',
		},
	},
}(function (context: Types.CommandContext)
	for _, player: Player in context:GetArgument('Players') do
		context:Reply(`{player.Name}'s position is {player.Character.HumanoidRootPart.Position}!`)
	end
end)

return FindPlayers
