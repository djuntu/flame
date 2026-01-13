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
    Name = 'friends',
    Arguments = {
        {
            Type = 'strings',
            Name = 'Friends',
            Description = 'What friends do you have?',
            Optional = true,
        },
    }
} (function(context)
    local myFriends = context:GetArgument('Friends')
    if #myFriends == 0 then
        context:Reply('You have no friends!')
    else
        context:Reply('Your friends are: ' .. table.concat(myFriends, ', '))
    end
end)

CommandBuilder.Secondary {
    Hoist = Command,
    Realm = 'Client',
    Name = 'add',
    Arguments = {
        {
            Type = 'number',
            Name = 'number1',
            Description = 'First number',
            Optional = false,
        },
        {
            Type = 'number',
            Name = 'number2',
            Description = 'Second number',
            Optional = false,
        },
    }
} (function(context)
    local num1, num2 = context:GetArgument('number1'), context:GetArgument('number2')
    context:Reply('The sum is ' .. tostring(num1 + num2))
end)

CommandBuilder.Secondary {
    Hoist = Command,
    Realm = 'Client',
    Name = 'color',
    Arguments = {
        {
            Type = 'color3',
            Name = 'messageColor',
            Description = 'What color should the CommandExecutionResponse be?',
            Optional = false,
        },
    }
} (function(context)
    local color: Color3 = context:GetArgument('messageColor')
    context:Reply({
        Message = 'This is your chosen color!',
        Color = color,
        LineStyle = 'PlainText'
    })
end)

return Command
