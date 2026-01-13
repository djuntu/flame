local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
	return argument.Make(
		'Continent',
		argument.MakeEnumType('Continent', {
			'North America',
			'South America',
			'Europe',
			'Africa',
			'Asia',
			'Oceania',
			'Antarctica',
		})
	)
end
