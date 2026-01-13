-- List of native numbers/s from Roblox Luau engine.
local Types = require(script.Parent.Parent.Types.FlameTypes)
local Util = require(script.Parent.Parent.Shared.Util)
return function (argument: Types.Arguments)
    return argument.Make('numbers', argument.MakeListableType {
        Parse = function(value: string)
            local numbers = string.split(value, ',')
            Util.map(numbers, function(numStr: string)
                return tonumber(numStr)
            end)

            return numbers
        end,
        Validate = function(numbers: {number})
            local numberType: Types.DataType = argument.Inherit('number')
            for _, num in numbers do
                if not numberType.Validate(num) then
                    return false
                end
            end

            return true
        end,
        Transform = function(value: any)
            return value
        end,
    })
end