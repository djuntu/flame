-- List of native string/s from Roblox Luau engine.
local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
	return argument.Make(
		'strings',
		argument.MakeListableType {
			Parse = function (value: string)
				return string.split(value, ',')
			end,
			Validate = function (strings: { string })
				local stringType: Types.DataType = argument.Inherit('string')
				for _, str in strings do
					if not stringType.Validate(str) then return false end
				end

				return true
			end,
			Transform = function (value: any)
				if value == nil then return {} end
				return value
			end,
		}
	)
end
