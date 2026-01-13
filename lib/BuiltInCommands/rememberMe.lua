--[[
    This is a example built-in command that shows how state works in commands.
    It shows state instantiation and modification.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)
local Middleware = require(Flame.Objects.Middleware)

-- Create the 'rememberMe' command
local RememberMe: Types.CommandProps = {
	Name = 'rememberMe',
	Aliases = {},
	Group = 'Utilities',
}

-- Create the Command's state
function RememberMe.New ()
	local State = {
		whatShouldIRemember = 'nothing',
	}

	return State
end

Command.Primary {
	Hoist = RememberMe,
	Realm = 'Shared',
	Arguments = {
		{
			Type = 'string',
			Name = 'Remember',
			Description = 'What should the command remember?',
			Optional = true,
		},
	},
}(function (context: Types.CommandContext)
	local remember = context:GetArgument('Remember')
	local state = context:GetState()

	if remember == nil then return `I remembered: {state.whatShouldIRemember}` end

	state.whatShouldIRemember = remember
	return 'I\'ll keep that in mind!'
end)

return RememberMe
