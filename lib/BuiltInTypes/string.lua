-- Native string type on the Roblox Luau engine.
local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
    return argument.Make('string', argument.MakeDataType {
        Parse = function(value: string)
            return value
        end,
        Validate = function(string: any?)
            return tostring(string) and not tonumber(string)
        end,
        Transform = function(value: any)
            return value
        end,
    })
end