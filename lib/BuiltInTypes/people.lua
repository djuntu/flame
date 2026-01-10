local Types = require(script.Parent.Parent.Types.FlameTypes)
return function (argument: Types.Arguments)
    return argument.Make('People', argument.MakeDataType {
        Parse = function(value: string)
            local names = argument.Inherit('Names')
            if value == '*' then
                local all = {}
                for _, name in pairs(names) do
                    table.insert(all, name)
                end
                return all
            end
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
        end
    })
end