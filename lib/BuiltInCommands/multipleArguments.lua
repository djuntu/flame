--[[
    This is a example built-in command that shows different arguments being displayed.
    Shows the parsing and execution of several arguments.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)
local Middleware = require(Flame.Objects.Middleware)

-- Create the 'multipleArguments' command
local MultipleArguments: Types.CommandProps = {
	Name = 'multipleArguments',
	Aliases = {},
	Group = 'Utilities',
}

Command.Primary {
	Hoist = MultipleArguments,
	Realm = 'Shared',
	Arguments = {
		{
			Type = 'strings',
			Name = 'Friends',
			Description = 'Who are your friends?',
			Optional = false,
		},
		{
			Type = 'numbers',
			Name = 'Ages',
			Description = 'What are their ages?',
			Optional = false,
		},
		{
			Type = 'strings',
			Name = 'Best Friends',
			Description = 'Who are your best friends?',
			Optional = true,
		},
	},
}(function (context: Types.CommandContext)
	print(context.Arguments)
	return 'Done!'
end)

return MultipleArguments
