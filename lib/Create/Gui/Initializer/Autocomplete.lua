-- Creates an autocomplete for the command input and handles applying it with the flow of the Window.
local TweenService = game:GetService('TweenService')
local Components = script.Parent.Parent.Components
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

local BASE_EXTENTS = 75
local MAX_EXTENTS = 300

local Autocomplete = {}
Autocomplete.__index = Autocomplete

--[[
    @interface Autocomplete
    @within Initializer

    @public
    @type Autocomplete
]]
function Autocomplete.new (Main)
	local self = setmetatable({}, Autocomplete)
	self.Main = Main
	self.Object = self:Create(Main.Gui)
	self.RawOptions = {}
	self.CurrentSelectionMount = 1

	return self
end

--[[
    @method Autocomplete
    @within Autocomplete
    Sets the color of the Writer text.

    @public
    @param targetInput: string?
    @returns void
]]
function Autocomplete:Autocomplete (targetInput: string?)
	if not targetInput then
		local selected = self:GetSelected()

		if not selected then return end

		targetInput = selected.Autocomplete.Text
	end
	self.Main.FillAutocomplete(targetInput)
end

--[[
    @method CycleInput
    @within Autocomplete
    Cycles the selected autocomplete option up or down.

    @public
    @param up: string
    @param userInput: string
    @returns void
]]
function Autocomplete:CycleInput (up: string, userInput: string)
	up = up == 'Up'
	local selection = up and self.CurrentSelectionMount - 1 or self.CurrentSelectionMount + 1

	if selection < 1 then
		selection = #self.RawOptions
	elseif selection > #self.RawOptions then
		selection = 1
	end
	self:Select(selection, userInput)
end

--[[
    @method Visible
    @within Autocomplete
    Toggles the visibility of the autocomplete.

    @public
    @param bool: boolean
    @returns void
]]
function Autocomplete:Visible (bool: boolean)
	self:SetSelectedInput('')
	self.Object.Visible = bool
end

--[[
    @method GetSelected
    @within Autocomplete
    Gets the current selected autocomplete option.

    @public
    @returns void
]]
function Autocomplete:GetSelected ()
	local query = self.RawOptions[self.CurrentSelectionMount]

	for _, member in pairs(self.Object:GetChildren()) do
		if member:IsA('TextButton') and member.Name == query then return member end
	end
end

--[[
    @method Select
    @within Autocomplete
    Selects an autocomplete option by its index and registers the user's fill
    input for highlighting.

    ::: @note :::
    This does not apply the autocomplete, it only highlights it. Use #:Autocomplete to apply.
    ::: @note :::

    @public
    @param n: number
    @param userInput: string
    @returns void
]]
function Autocomplete:Select (n: number, userInput: string)
	local selection = self.RawOptions[n]
	if not selection then return end

	self:SetSelectedInput('')
	self:ClearOldSelectons()
	self.CurrentSelectionMount = n

	local textButton = self:GetSelected()
	self:SetSelectedInput(userInput)

	textButton.BackgroundColor3 = Color3.fromRGB(20, 20, 61)
	textButton.BackgroundTransparency = 0.4
end

--[[
    @method ClearOldSelectons
    @within Autocomplete
    Clears the darkened and more opaque background of previously selected options.

    @public
    @returns void
]]
function Autocomplete:ClearOldSelectons ()
	for _, member in pairs(self.Object:GetChildren()) do
		if member:IsA('TextButton') then
			member.BackgroundColor3 = Color3.fromRGB(3, 3, 9)
			member.BackgroundTransparency = 0.7
		end
	end
end

--[[
    @method SetSelectedInput
    @within Autocomplete
    Sets the highlighted portion of the selected autocomplete option based on user input.

    ::: @note :::
    A highlight is determined by matching characters from the start of the string
    until a mismatch is found.
    ::: @note :::

    @public
    @param userInput: string
    @returns void
]]
function Autocomplete:SetSelectedInput (userInput: string)
	local textButton = self:GetSelected()
	if not textButton then return end

	local input = ''
	local expectedInput = textButton.Autocomplete.Text

	for i = 1, expectedInput:len() do
		local expectedCharacter = expectedInput:sub(i, i)
		local givenCharacter = userInput:sub(i, i)

		if expectedCharacter:lower() == givenCharacter:lower() then
			input ..= expectedCharacter
		else
			break
		end
	end
	textButton.Input.Text = input
end

--[[
    @method SetContext
    @within Autocomplete
    Sets the context information for the autocomplete suggestion.

    @public
    @param name: string
    @param type: string
    @param description: string?
    @returns void
]]
function Autocomplete:SetContext (name: string, type: string, description: string?)
	self.Object.Title.Text = `{name}: {type}`
	self.Object.Description.Text = description or 'No description provided.'
end

--[[
    @method SetPosition
    @within Autocomplete
    Sets the actual position of the autocomplete suggestion.

    @public
    @param udim2: UDim2
    @returns void
]]
function Autocomplete:SetPosition (udim2: UDim2)
	TweenService:Create(self.Object, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
		Position = udim2,
	}):Play()
end

--[[
    @method DisplayOptions
    @within Autocomplete
    Displays all the available autocomplete options to the user in a list layout.

    @public
    @param options: {string}
    @returns void
]]
function Autocomplete:DisplayOptions (options: { string })
	self.RawOptions = options
	local Members = Util.filterValues(self.Object:GetChildren(), function (value)
		return value:IsA('TextButton')
	end)

	for index, member in pairs(options) do
		local exists = false
		for _, frame: TextButton in pairs(Members) do
			if frame.Name == member then
				exists = true
				frame.LayoutOrder = index
			end
		end

		if exists then continue end

		local option = self:CreateOption(member)
		option.LayoutOrder = index
		option.Parent = self.Object
	end

	for _, oldMember: TextButton in pairs(self.Object:GetChildren()) do
		if not table.find(options, oldMember.Name) and oldMember:IsA('TextButton') then oldMember:Destroy() end
	end

	self:AdjustExtents(#options)
end

--[[
    @method AdjustExtents
    @within Autocomplete
    Adjusts the extents of the autocomplete based on the number of members and caps based
    on the max extents.

    @public
    @param memberCount: number
    @returns void
]]
function Autocomplete:AdjustExtents (memberCount: number)
	local extents = math.min(MAX_EXTENTS, BASE_EXTENTS + memberCount * 25)

	TweenService:Create(self.Object, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
		Size = UDim2.fromOffset(self.Object.Size.X.Offset, extents),
	}):Play()
end

--[[
    @method CreateOption
    @within Autocomplete
    Creates an individual autocomplete option button.

    @public
    @param text: string
    @returns TextButton
]]
function Autocomplete:CreateOption (text: string): TextButton
	local Option = Instance.new('TextButton')
	Option.BackgroundColor3 = Color3.fromRGB(3, 3, 9)
	Option.BackgroundTransparency = 0.7
	Option.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 25))
	Option.Text = ''
	Option.Name = text

	local Complete = Instance.new('TextLabel')
	Complete.Size = UDim2.fromScale(0.8, 1)
	Complete.BackgroundTransparency = 1
	Complete.AnchorPoint = Vector2.new(0.5, 0)
	Complete.Position = UDim2.fromScale(0.5, 0)
	Complete.Text = text
	Complete.TextWrapped = true
	Complete.Name = 'Autocomplete'
	Complete.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
	Complete.TextSize = 18
	Complete.TextColor3 = Color3.new(1, 1, 1)
	Complete.TextXAlignment = Enum.TextXAlignment.Left
	Complete.ZIndex = 3
	Complete.Parent = Option

	local Input = Instance.new('TextLabel')
	Input.Size = UDim2.fromScale(0.8, 1)
	Input.BackgroundTransparency = 1
	Input.AnchorPoint = Vector2.new(0.5, 0)
	Input.Position = UDim2.fromScale(0.5, 0)
	Input.Text = ''
	Input.TextWrapped = true
	Input.Name = 'Input'
	Input.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
	Input.TextSize = 18
	Input.TextColor3 = Color3.fromRGB(26, 255, 0)
	Input.TextXAlignment = Enum.TextXAlignment.Left
	Input.ZIndex = 4
	Input.Parent = Option

	Option.Activated:Connect(function (inputObject, clickCount)
		self:Autocomplete(Complete.Text)
	end)

	return Option
end

--[[
    @method Create
    @within Autocomplete
    Creates the actual autocomplete object for the Autocomplete class.

    @public
    @param parent: ScreenGui
    @returns void
]]
function Autocomplete:Create (parent: ScreenGui)
	local Suggestion = Instance.new('ScrollingFrame')
	Suggestion.BackgroundColor3 = Color3.fromRGB(3, 3, 9)
	Suggestion.BackgroundTransparency = 0.3
	Suggestion.Size = UDim2.fromOffset(220, 0)
	Suggestion.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Suggestion.CanvasSize = UDim2.fromOffset(0, 0)
	Suggestion.ScrollBarThickness = 0
	Suggestion.ScrollBarImageTransparency = 1
	Suggestion.ScrollingDirection = Enum.ScrollingDirection.Y
	Suggestion.Position = UDim2.fromScale(0.5, 0.5)
	Suggestion.Name = 'Autocomplete'
	Suggestion.ZIndex = 2

	local Title = Instance.new('TextLabel')
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(UDim.new(0.8, 0), UDim.new(0, 30))
	Title.Name = 'Title'
	Title.AnchorPoint = Vector2.new(0.5, 0)
	Title.LayoutOrder = 0
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextSize = 25
	Title.TextColor3 = Color3.new(1, 1, 1)
	local font = Font.fromEnum(Enum.Font.RobotoMono)
	font.Bold = true
	Title.FontFace = font
	Title.ZIndex = 3
	Title.Parent = Suggestion

	local Description = Instance.new('TextLabel')
	Description.BackgroundTransparency = 1
	Description.Size = UDim2.new(UDim.new(0.8, 0), UDim.new(0, 35))
	Description.Name = 'Description'
	Description.AnchorPoint = Vector2.new(0.5, 0)
	Description.LayoutOrder = 1
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top
	Description.TextWrapped = true
	Description.TextSize = 15
	Description.TextColor3 = Color3.new(1, 1, 1)
	Description.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
	Description.ZIndex = 3
	Description.Parent = Suggestion

	local Layout = Instance.new('UIListLayout')
	Layout.Padding = UDim.new(0, 0)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.Parent = Suggestion

	local Padding = Instance.new('UIPadding')
	Padding.PaddingBottom = UDim.new(0, 5)
	Padding.PaddingTop = UDim.new(0, 5)
	Padding.Parent = Suggestion

	local Corner = Instance.new('UICorner')
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Suggestion

	Suggestion.Visible = false
	Suggestion.Parent = parent

	return Suggestion
end
return Autocomplete
