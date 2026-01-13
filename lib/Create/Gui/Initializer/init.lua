-- Initializes the command line interface with both the Window and Autocomplete components mounted.
local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')

local Mount = require(script.Parent.GuiMount)
local Types = require(script.Parent.Types)
local FlameTypes = require(script.Parent.Parent.Parent.Types.FlameTypes)
local BuildTypes = require(script.Parent.Parent.Parent.Types.BuildTypes)
local Arguments = require(script.Parent.Parent.Parent.Objects.Arguments)
local Util = require(script.Parent.Parent.Parent.Shared.Util)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

--[[
	@interface Initializer
	@within Create.Gui

	@public
	@type Initializer
]]
local Initializer = {
	Gui = nil,
	Window = nil,
	Autocomplete = nil,
}
--[[
	@prop Gui
	@within Initializer

	@public
	@type Types.CLI
	@readonly
]]
--[[
	@prop Window
	@within Initializer

	@public
	@type Types.Window
	@readonly
]]
--[[
	@prop Autocomplete
	@within Initializer

	@public
	@type Types.Autocomplete
	@readonly
]]

return function (Main)
	local Gui: Types.CLI

	if not StarterGui:WaitForChild('Flame', 1) and task.wait() and PlayerGui:FindFirstChild('Flame') == nil then
		Gui = Mount()
		Gui.Parent = PlayerGui
	else
		Gui = PlayerGui:FindFirstChild('Flame')
	end

	Initializer.Gui = Gui
	Initializer.Main = Main

	Initializer.UserInput = ''
	Initializer.UserArgument = nil
	Initializer.Window = require(script.Window).new(Initializer)
	Initializer.Autocomplete = require(script.Autocomplete).new(Initializer)
	Initializer.WaitingOnDispatchResponse = false

	local Window = Initializer.Window
	local Autocomplete = Initializer.Autocomplete
	local Flame: FlameTypes.FlameMain<BuildTypes.ClientBuildProps> = Main.Flame

	function Initializer.Dispatch (text: string)
		text = Initializer.GetEntryText(text)

		local canEnter, response = Window.CanProcess, Window.CanProcessResponse

		if not canEnter then
			Window:WriteLine(response, 'PlainText', Color3.fromRGB(255, 0, 72))
			return
		end

		if Initializer.WaitingOnDispatchResponse then return end
		Initializer.WaitingOnDispatchResponse = true
		local serverResponse = Flame.Dispatcher:EvaluateAndRun(LocalPlayer, text)
		if typeof(serverResponse) == 'table' then
			local success = serverResponse.Success
			local userResponse = serverResponse.UserResponse or 'Command successfully executed.'
			Window:WriteLine(
				userResponse,
				'Expressive',
				success and Color3.fromRGB(26, 255, 0) or Color3.fromRGB(255, 0, 72),
				nil,
				success and 'rbxassetid://81345199294878' or 'rbxassetid://130930319386024'
			)
		else
			Window:WriteLine(
				serverResponse,
				'Expressive',
				Color3.fromRGB(255, 0, 72),
				nil,
				'rbxassetid://130930319386024'
			)
		end
		Initializer.WaitingOnDispatchResponse = false
	end

	function Initializer.FillAutocomplete (targetInput: string)
		local textBox: TextBox = Initializer.Window.Writer.Object.TextBox
		local cursorPosition = textBox.CursorPosition

		if string.find(targetInput, ' ') then targetInput = `'{targetInput}'` end
		textBox.Text = Util.targettedSubstringReplace(textBox.Text, cursorPosition, Initializer.UserInput, targetInput)
			.. ' '
		Initializer.OnTextChanged(textBox.Text)
		Window:Focus()
	end

	function Initializer.GetEntryText (text: string)
		return Util.trim(text):gsub('[\t\n]', '')
	end

	function Initializer.GetEntryPosition (): UDim2
		local X_OFFSET, Y_OFFSET = 40, 40
		local textBox: TextBox = Initializer.Window.Writer.Object.TextBox
		local yPosition = textBox.AbsolutePosition.Y

		local textBoundsX = Util.getTextSize(textBox.Text, textBox)
		return UDim2.fromOffset((textBoundsX.X + textBox.AbsolutePosition.X) + X_OFFSET, yPosition + Y_OFFSET)
	end

	function Initializer.OnTextChanged (text: string)
		local textBox: TextBox = Initializer.Window.Writer.Object.TextBox
		local commandName: string, commandEntryPoint: string, rawArgs = Util.parseParams(text)
		local isEnteringArguments = string.find(text, ' ')
		local autoCompleteOptions = {}

		local function evaluateAutocomplete ()
			text = Initializer.GetEntryText(text)

			local function setCommandAutocompleteOptions ()
				if string.find(text, ' ') then text = text:split(' ')[1] end

				Initializer.UserArgument = nil
				Initializer.UserInput = text
				local commands = Flame.Registry:GetCommands()
				autoCompleteOptions = Util.filterKeys(commands, function (key)
					return Util.startsWith(key, string.lower(text))
				end)

				-- We don't display alias options as default.
				if text ~= '' then
					for _, command: FlameTypes.Command in pairs(commands) do
						if command.Aliases and next(command.Aliases) then
							for _, alias in pairs(command.Aliases) do
								if Util.startsWith(alias, string.lower(text)) then
									table.insert(autoCompleteOptions, alias)
								end
							end
						end
					end
				end

				local commandObject = Flame.Registry:Get(commandName, 'Command')
				if not commandObject then
					Window:SetProcessableEntry(
						false,
						string.format('%s is not a valid command. Type help to view a list of commands.', text)
					)

					return
				end

				if commandEntryPoint ~= 'Primary' then
					autoCompleteOptions = Util.filterMap(commandObject.Store, function (key, value)
						return commandName .. '/' .. key
					end, function (key, value)
						return Util.startsWith(key, string.lower(commandEntryPoint)) and key ~= 'Primary'
					end)
				end

				local subCommand = commandObject:extract(commandEntryPoint)
				if not subCommand then
					Window:SetProcessableEntry(
						false,
						string.format(
							'%s is not a valid subcommand within %s. Type help to view a list of commands.',
							commandEntryPoint,
							commandName
						)
					)
					return
				end

				local commandHasRequiredArgs = false
				for _, argument in subCommand.ArgumentStruct do
					if argument.Optional == false then
						commandHasRequiredArgs = true
						break
					end
				end

				if commandHasRequiredArgs then
					Window:SetProcessableEntry(
						false,
						string.format(
							'%s has required arguments. None have been provided.',
							Util.trim(commandName) .. '/' .. Util.trim(commandEntryPoint)
						)
					)
					return
				end

				Window:SetProcessableEntry(true)
			end
			if isEnteringArguments then
				local command = unpack(string.split(text, ' '))
				local offset = string.len(command) + 1
				local parsed, characterSets = Util.parseArgs(rawArgs)
				local cursorPosition = textBox.CursorPosition - offset

				if cursorPosition < 1 then
					isEnteringArguments = false
					setCommandAutocompleteOptions()
					return
				end

				local argumentIndex = math.max(1, table.maxn(characterSets))

				for index, bounds in pairs(characterSets) do
					if cursorPosition >= bounds[1] and cursorPosition <= bounds[2] then
						argumentIndex = index + 1
						break
					end
				end

				if
					characterSets[table.maxn(characterSets)]
					and cursorPosition > characterSets[table.maxn(characterSets)][2]
				then
					argumentIndex = table.maxn(characterSets) + 1
				end

				local commandObject = Flame.Registry:Get(commandName, 'Command')
				if not commandObject then
					Window:SetProcessableEntry(
						false,
						string.format('%s is not a valid command. Type help to view a list of commands.', commandName)
					)
					autoCompleteOptions = {}
					return
				end

				local subCommand = commandObject:extract(commandEntryPoint)
				if not subCommand then
					Window:SetProcessableEntry(
						false,
						string.format(
							'%s is not a valid subcommand within %s. Type help to view a list of commands.',
							commandEntryPoint,
							commandName
						)
					)
					autoCompleteOptions = {}
					return
				end

				local argumentWillBeIgnored = rawArgs:match('^%s*$') ~= nil
				local isArgumentOutofBounds = subCommand.ArgumentStruct[argumentIndex] == nil
				if isArgumentOutofBounds and not argumentWillBeIgnored then
					Window:SetProcessableEntry(
						false,
						string.format(
							'%s is out of the bounds of the arguments required.',
							parsed[argumentIndex] or 'Unknown argument'
						)
					)
					autoCompleteOptions = {}
					return
				end

				if #subCommand.ArgumentStruct == 0 then
					autoCompleteOptions = {}
					Window:SetProcessableEntry(true)
					return
				end

				local structItem = subCommand.ArgumentStruct[argumentIndex]
				Initializer.UserArgument = structItem
				local input = parsed[argumentIndex] or rawArgs
				local isListableEntry = string.find(input, ',') and structItem.IsListableType and true or false

				local isOK, hintList = Arguments.Seems(
					subCommand.ArgumentStruct,
					argumentIndex,
					input,
					isListableEntry and Util.getListItemFromCharIndex(input, cursorPosition)
				)

				if isListableEntry then
					Initializer.UserInput = Util.getListItemFromCharIndex(input, cursorPosition)
				else
					Initializer.UserInput = input
				end

				-- A DataType will never have any options there exists no given list of preset options.
				-- Therefore we set the first option to be a blank table (skippable entry)
				-- so the autocomplete still shows but with no options.
				local isDataType = structItem.IsDataType
				if isDataType then hintList = { {} } end
				autoCompleteOptions = hintList
				if not isOK then
					Window:SetProcessableEntry(
						false,
						string.format(
							'Type %s expects type %s, got "%s".',
							structItem.Name,
							structItem.Type,
							parsed[argumentIndex] or 'Null'
						)
					)

					return
				end

				Window:SetProcessableEntry(true)
			else
				setCommandAutocompleteOptions()
			end
		end

		evaluateAutocomplete()
		if next(autoCompleteOptions) then
			local isSkippableEntry = typeof(autoCompleteOptions[1]) == 'table'
			Autocomplete:Visible(true)

			if not isSkippableEntry then
				Autocomplete:DisplayOptions(autoCompleteOptions)
				Autocomplete:SetPosition(Initializer.GetEntryPosition())
				Autocomplete:Select(1, Initializer.UserInput)
			else
				Autocomplete:DisplayOptions {}
			end

			if not isEnteringArguments or not Initializer.UserArgument then
				Autocomplete:SetContext('command', 'Command', 'The name of the command to be executed.')
				return
			end
			local argumentType = Initializer.UserArgument.Type
			if Initializer.UserArgument.Optional then
				argumentType ..= '?'
			end
			Autocomplete:SetContext(Initializer.UserArgument.Name, argumentType, Initializer.UserArgument.Description)
		else
			Autocomplete:Visible(false)
			Autocomplete:DisplayOptions {}
		end
	end

	return Initializer
end
