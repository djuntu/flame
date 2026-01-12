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
            Optional = false,
        },
    }
}(function (context)
	print(context:GetArgument('target'))
    context:Reply({
        Message = context:GetArgument('target')[1],
        Color = Color3.fromRGB(255, 85, 241),
        LineStyle = 'Expressive'
    })
    return 'Hello'
end)

CommandBuilder.Secondary {
    Hoist = Command,
    Realm = 'Client',
    Name = 'subcommand'
} (function(context)
    print(context)
end)

return Command
