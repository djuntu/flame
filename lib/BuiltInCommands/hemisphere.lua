--[[
    This is a example built-in command that shows using complex-compound Enum & Listable types.
    Shows the parsing and interpretation of these arguments.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)

-- Create the 'hemisphere' command
local Hemisphere: Types.CommandProps = {
	Name = 'hemisphere',
	Aliases = {},
	Group = 'Utilities',
}

Command.Primary {
	Hoist = Hemisphere,
	Realm = 'Client',
    Arguments = {
        {
            Type = 'Continent',
            Name = 'Continent',
            Description = 'What continent do you live in?',
        }
    }
}(function (context: Types.CommandContext)
    local hemispheres = {
        ['North America'] = 'Northern',
        ['South America'] = 'Northern/Southern',
        ['Europe'] = 'Northern',
        ['Africa'] = 'Northern/Southern',
        ['Oceania'] = 'Southern',
        ['Asia'] = 'Northern',
        ['Antarctica'] = 'Southern'
    }

    local userHemisphere = hemispheres[context:GetArgument('Continent')]
    return `You live in the {userHemisphere} hemisphere!`
end)

return Hemisphere
