local Types = require(script.Parent.Types)
local Events: Types.Events = {
	Main = nil,
}

Events.OnTextChange = function ()
	Events.Main.Window:GoToFocus()
end

return function (Main)
	Events.Main = Main
	return Events
end
