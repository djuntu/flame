local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')

local Window = require(script.Window)
local Autocomplete = require(script.Autocomplete)
local Mount = require(script.Parent.GuiMount)
local Types = require(script.Parent.Types)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Initializer = {
    Gui = nil,
    Window = nil,
    Autocomplete = nil,
}

return function (Main)
    local Gui: Types.CLI

    if not StarterGui:WaitForChild('Flame', 1) and task.wait() and PlayerGui:FindFirstChild('Flame') == nil then
        Gui = Mount()
        Gui.Parent = PlayerGui
    else
        Gui = PlayerGui:FindFirstChild('Flame')
    end

    Gui.Enabled = false
    Initializer.Gui = Gui
    Initializer.Main = Main

    Initializer.Window = Window.new(Initializer)
    Initializer.Autocomplete = Autocomplete.new()

    return Initializer
end