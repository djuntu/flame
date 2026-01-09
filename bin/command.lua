local Types = require(game.ReplicatedStorage.Lib.Types.FlameTypes)
local CommandBuilder: Types.UserCommandBuilder = require(game.ReplicatedStorage.Lib.Objects.Command)

local Command: Types.CommandProps = {
	Name = 'Kick',
	Aliases = { 'Banish', 'Disconnect' },
	Group = 'Managers',

	Subcommands = {},
}

function Command.New()
	local State = {
		TestState = 'True'
	}

	return State
end

CommandBuilder.Primary({
	Hoist = Command,
	Realm = 'Shared',
})(function(context)
	print(context)
end)

return Command