local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
	return argument.Make(
		'Names',
		argument.MakeEnumType('Names', {
			'John',
			'Peter',
			'Mark',
		})
	)
end
