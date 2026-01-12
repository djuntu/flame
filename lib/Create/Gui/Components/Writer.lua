-- Creates a writer object which is displayed in the Window.
local Types = require(script.Parent.Parent.Types)

local Writer = {}
Writer.__index = Writer

local HEADER_TEXT_COLOR_3 = Color3.fromRGB(26, 255, 0)

--[[
	@interface Writer
	@within Components

	@public
	@type Writer
]]
function Writer.new ()
	local self = {}
	self.Object = nil

	setmetatable(self, Writer)
	return self
end

--[[
    @method SetContent
    @within Writer
    Sets the content of the writer object.

    @public
    @param text: string
    @returns Writer
]]
function Writer:SetContent (text: string)
	self.Object:FindFirstChild('TextBox').Text = text
	return self
end

--[[
    @method SetContentColor
    @within Writer
    Sets the color of the Writer text.

    @public
    @param color: Color3
    @returns Writer
]]
function Writer:SetContentColor (color: Color3)
	self.Object:FindFirstChild('TextBox').TextColor3 = color
	return self
end

--[[
    @method SetHeader
    @within Writer
    Sets the header text if the Writer's LineStyle is Header.

    @public
    @param text: string
    @returns Writer
]]
function Writer:SetHeader (text: string)
	self.Object:FindFirstChild('TextLabel').Text = text
	return self
end

--[[
    @method Create
    @within Writer
    Creates a writer object for the given parent GuiObject.

    @public
    @param parent: GuiObject
    @returns Writer
]]
function Writer:Create (parent: GuiObject)
	local Frame = Instance.new('Frame')
	Frame.Name = 'Writer'
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(UDim.new(0.95, 0), UDim.new(0, 30))

	local Content = Instance.new('TextBox')
	Content.TextEditable = true
	Content.Text = ''
	Content.PlaceholderText = ''
	Content.PlaceholderColor3 = Color3.new(1, 1, 1)
	Content.BackgroundTransparency = 1
	Content.ClearTextOnFocus = false
	Content.Interactable = true
	Content.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 30))
	Content.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
	Content.TextColor3 = Color3.new(1, 1, 1)
	Content.TextWrapped = true
	Content.TextXAlignment = Enum.TextXAlignment.Left
	Content.TextSize = 18
	Content.LayoutOrder = 1
	Content.RichText = true
	Content.Parent = Frame

	local User = Instance.new('TextLabel')
	User.BackgroundTransparency = 1
	User.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
	User.TextColor3 = HEADER_TEXT_COLOR_3
	User.TextXAlignment = Enum.TextXAlignment.Left
	User.TextSize = 18
	User.Size = UDim2.fromOffset(0, 30)
	User.AutomaticSize = Enum.AutomaticSize.X
	User.Parent = Frame

	local Layout = Instance.new('UIListLayout')
	Layout.FillDirection = Enum.FillDirection.Horizontal
	Layout.Padding = UDim.new(0, 5)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Frame

	Frame.Parent = parent
	self.Object = Frame
	return self
end

return Writer
