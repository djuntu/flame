--[[
    This is a example built-in command that shows how to use a Color3 argument type.
    It demonstrates how to parse and validate Color3 inputs from the command line.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)

-- Create the 'showSomeColor' command
local ShowSomeColor: Types.CommandProps = {
	Name = 'showSomeColor',
	Aliases = { 'someColor', 'showColor' },
	Group = 'Utilities',
}

Command.Primary {
	Hoist = ShowSomeColor,
	Realm = 'Client',
	Arguments = {
		{
			Type = 'color3',
			Name = 'Color',
			Description = 'The Color3 value to display (format: R,G,B)',
			Optional = false,
		},
	},
}(function (context: Types.CommandContext)
	local color: Color3 = context:GetArgument('Color')
	context:Reply {
		Message = 'Here is the color you provided!',
		Color = color,
	}
end)

Command.Secondary {
	Hoist = ShowSomeColor,
	Realm = 'Client',
	Name = 'inverse',
	Arguments = {
		{
			Type = 'color3',
			Name = 'Color',
			Description = 'The color which will be inversed.',
			Optional = false,
		},
	},
}(function (context: Types.CommandContext)
	local color: Color3 = context:GetArgument('Color')
	local R, G, B = color.R, color.G, color.B
	context:Reply {
		Message = 'Now it\'s inversed!',
		Color = Color3.new(1 - R, 1 - G, 1 - B),
	}
end)

return ShowSomeColor
