-- Native Lua implementation Color3 type for the Roblox Luau engine. 
local Types = require(script.Parent.Parent.Types.FlameTypes)
local Util = require(script.Parent.Parent.Shared.Util)
return function (argument: Types.Arguments)
    return argument.Make('color3', argument.MakeListableType {
        Parse = function(value: string)
            return value
        end,
        Validate = function(color: string)
            local unpackable = string.split(color, ',')
            if #unpackable ~= 3 then
                return false
            end

            local allCanBeColors = Util.every(unpackable, function(component: string)
                local num = tonumber(component)
                return num ~= nil and num >= 0 and num <= 255
            end)

            return allCanBeColors
        end,
        Transform = function(value: string)
            local red, green, blue = unpack(string.split(value, ','))
            return Color3.fromRGB(tonumber(red), tonumber(green), tonumber(blue))
        end,
    })
end