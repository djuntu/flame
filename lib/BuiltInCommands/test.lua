local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local CommandBuilder: Types.UserCommandBuilder = require(Flame.Objects.Command)

local Command: Types.CommandProps = {
	Name = 'test',
	Aliases = {},
	Group = 'Managers',
}

function Command.New ()
	local State = {
		TestState = 'True',
	}

	return State
end

CommandBuilder.Primary {
	Hoist = Command,
	Realm = 'Shared',
    Arguments = {
        {
            Type = 'People',
            Name = 'target',
            Description = 'the target',
            Optional = true,
        },
    }
}(function (context)
	print(context:GetArgument('target'))
end)

CommandBuilder.Secondary {
    Hoist = Command,
    Realm = 'Client',
    Name = 'subcommand'
} (function(context)
    print(context)
end)

return Command
