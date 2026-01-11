local Components = script.Parent.Parent.Components

local Autocomplete = {}
Autocomplete.__index = Autocomplete

function Autocomplete.new(Main)
    local self = setmetatable({}, Autocomplete)
    self.Main = Main

    return self
end
return Autocomplete