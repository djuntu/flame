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
    return unpack(string.split(rawText, ' '))
end

--[[
    Maps through each item in a list and modifies based on callback.
]]
function Util.map(list: FlameTypes.List<any>, callback: (any) -> any)
    for i = 1, #list do
        list[i] = callback(i)
    end
end

return Util