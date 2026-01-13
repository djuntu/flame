local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
	return argument.Make(
		'Foods',
		argument.MakeEnumType('Foods', {
			'Pizza',
			'Salad',
			'Stew',
			'Hamburger',
			'Kebab',
			'Paella',
			'Hotdog',
		})
	)
end
