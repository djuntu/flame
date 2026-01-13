--[[
    This is a example built-in command that shows using string types in Flame.
    It demonstrates how to parse and display strings from user input.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)

-- Create the 'showSomeColor' command
local MyFriends: Types.CommandProps = {
	Name = 'myFriends',
	Aliases = {},
	Group = 'Utilities',
}

Command.Primary {
	Hoist = MyFriends,
	Realm = 'Client',
	Arguments = {
		{
			Type = 'strings',
			Name = 'Friends',
			Description = 'Who are your friends?',
			Optional = true,
		},
	},
}(function (context: Types.CommandContext)
	local myFriends = context:GetArgument('Friends')
	if #myFriends == 0 then
		context:Reply {
			Message = 'You have no friends! :(',
			LineStyle = 'Expressive',
			Expression = context:GetIcon('Failure'),
		}
	else
		context:Reply {
			Message = 'Your friends are ' .. table.concat(myFriends, ', '),
			LineStyle = 'Expressive',
			Expression = context:GetIcon('Success'),
		}
	end

	return 'Here are you friends!'
end)

return MyFriends
