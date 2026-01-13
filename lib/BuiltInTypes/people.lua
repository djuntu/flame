local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
    return argument.Make('People', argument.MakeListableType {
        Parse = function(value: string)
            return string.split(value, ',')
        end,
        Validate = function(people: {string})
            local names = argument.Inherit('Names')
            for _, person in people do
                if not names[person] then
                    return false
                end
            end

            return true
        end,
        Transform = function(value: any)
            return value
        end,
        Search = function(value: string)
            local names = argument.Inherit('Names')
            return argument.SearchLikeEnum(names)(value)
        end
    })
end