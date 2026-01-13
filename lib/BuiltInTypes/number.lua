-- Native number type on the Roblox Luau engine.
local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
	return argument.Make(
		'number',
		argument.MakeDataType {
			Parse = function (value: string)
				return tonumber(value)
			end,
			Validate = function (number: any?)
				return tonumber(number) ~= nil
			end,
			Transform = function (value: number)
				return value
			end,
		}
	)
end
