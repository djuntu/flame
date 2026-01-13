--[[
    This is a example built-in command that shows using complex-compound Enum & Listable types.
    Shows the parsing and interpretation of these arguments.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)

-- Create the 'favoriteFoods' command
local FavoriteFoods: Types.CommandProps = {
	Name = 'favoriteFoods',
	Aliases = {},
	Group = 'Utilities',
}

Command.Primary {
	Hoist = FavoriteFoods,
	Realm = 'Client',
    Arguments = {
        {
            Type = 'FavoriteFoods',
            Name = 'Foods',
            Description = 'What foods do you like?',
        }
    }
}(function (context: Types.CommandContext)
    local descriptions = {
        ['Pizza'] = 'Pizza is a versatile Italian dish featuring a baked dough base, tangy tomato sauce, melted cheese, and various toppings.',
        ['Salad'] = 'A salad is a versatile dish, typically cold, featuring a mix of fresh or cooked ingredients.',
        ['Stew'] = 'A stew is a hearty, one-pot meal of chunky ingredients like meat and vegetables slow-simmered in liquid until tender, creating a rich, flavorful gravy, perfect for cold weather.',
        ['Hamburger'] = 'A hamburger is a sandwich with a cooked ground meat patty (usually beef) served in a sliced bun.',
        ['Kebab'] = 'Kebab is a versatile dish of meat (lamb, beef, chicken) or vegetables, typically grilled on a skewer or spit.',
        ['Paella'] = 'Paella is a traditional Spanish saffron-flavored rice dish from Valencia, cooked in a wide, shallow pan with meat, seafood, and vegetables.',
        ['Hotdog'] = 'A hot dog is a cooked sausage, often beef or pork, typically served in a split bun with various condiments.',
    }

    local favoriteFoods = context:GetArgument('Foods')
    for _, food in favoriteFoods do
        context:Reply(descriptions[food])
    end

    return 'Here are your favorite foods!'
end)

return FavoriteFoods
