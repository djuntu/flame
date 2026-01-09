--[[
    Handles utility functions which may be used by Flame itself and
    the user.
]]
local FlameTypes = require(script.Parent.Parent.Types.FlameTypes)
local Util = {}

--[[
    Creates a key: boolean dictionary of the given elements.
]]
function Util.makeDictionary(array: {any})
    local dict = {}

    for i = 1, table.maxn(array) do
        dict[array[i]] = true
    end

    return dict
end


--[[
    commandName: string,
	commandEntryPoint: FlameTypes.CommandStyle | string,
	rawArgs: string
]]
function Util.parseParams(rawText: string): (string, FlameTypes.CommandStyle | string, string)
    --do this
    return string.split(rawText, ' ')
end

return Util