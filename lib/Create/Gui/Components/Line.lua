-- Creates a line object which is displayed in the Window.
local Types = require(script.Parent.Parent.Types)

--[[
    @interface Line
    @within Components

    @public
    @type Line
]]
local Line = {}
Line.__index = Line

local HEADER_TEXT_COLOR_3 = Color3.fromRGB(26, 255, 0)

function Line.new ()
	local self = {}
	self.Object = nil
	self.ObjectStyle = 'PlainText'

	setmetatable(self, Line)
	return self
end

--[[
    @method SetContent
    @within Line
    Sets the content of the line object.

    @public
    @param text: string
    @returns Line
]]
function Line:SetContent (text: string)
	self.Object:FindFirstChild('TextBox').Text = text
	return self
end

--[[
    @method SetContentColor
    @within Line
    Sets the color of the line itself.

    @public
    @param cplor: Color3
    @returns Line
]]
function Line:SetContentColor (color: Color3)
	self.Object:FindFirstChild('TextBox').TextColor3 = color

	if self.ObjectStyle == 'Expressive' then self.Object:FindFirstChild('ImageLabel').ImageColor3 = color end
	if self.ObjectStyle == 'Header' then self.Object:FindFirstChild('TextLabel').TextColor3 = color end

	return self
end

--[[
    @method SetHeader
    @within Line
    Sets the header of the line if it is a Header LineStyle.

    @public
    @param text: string
    @returns Line
]]
function Line:SetHeader (text: string)
	if self.ObjectStyle ~= 'Header' then return self end
	self.Object:FindFirstChild('TextLabel').Text = text
	return self
end

--[[
    @method SetExpression
    @within Line
    Sets the expression (image) of the line if it is an Expressive LineStyle.

    @public
    @param expressionid: string
    @returns Line
]]
function Line:SetExpression (expressionid: string)
	if self.ObjectStyle ~= 'Expressive' then return self end
	self.Object:FindFirstChild('ImageLabel').Image = expressionid
	return self
end

--[[
    @method Create
    @within Line
    Creates a line object for the given line class.

    @public
    @param LineStyle: LineStyle
    @param parent: GuiObject
    @returns Line
]]
function Line:Create (LineStyle: Types.LineStyle, parent: GuiObject)
	LineStyle = LineStyle or 'PlainText'
	local Frame = Instance.new('Frame')
	Frame.Name = 'Line'
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(UDim.new(0.95, 0), UDim.new(0, 30))

	local Content = Instance.new('TextBox')
	Content.TextEditable = false
	Content.Text = ''
	Content.PlaceholderText = ''
	Content.PlaceholderColor3 = Color3.new(1, 1, 1)
	Content.BackgroundTransparency = 1
	Content.ClearTextOnFocus = false
	Content.Interactable = false
	Content.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 30))
	Content.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
	Content.TextColor3 = Color3.new(1, 1, 1)
	Content.TextWrapped = true
	Content.TextXAlignment = Enum.TextXAlignment.Left
	Content.TextSize = 18
	Content.LayoutOrder = 1
	Content.RichText = true
	Content.Parent = Frame

	if LineStyle == 'Expressive' then
		local Layout = Instance.new('UIListLayout')
		Layout.FillDirection = Enum.FillDirection.Horizontal
		Layout.VerticalAlignment = Enum.VerticalAlignment.Center
		Layout.Padding = UDim.new(0, 5)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = Frame

		local Image = Instance.new('ImageLabel')
		Image.Size = UDim2.fromOffset(20, 20)
		Image.BackgroundTransparency = 1
		Image.Image = ''
		Image.ResampleMode = Enum.ResamplerMode.Pixelated
		Image.Parent = Frame
	elseif LineStyle == 'Header' then
		local Layout = Instance.new('UIListLayout')
		Layout.FillDirection = Enum.FillDirection.Horizontal
		Layout.Padding = UDim.new(0, 5)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = Frame

		local Header = Instance.new('TextLabel')
		Header.BackgroundTransparency = 1
		Header.FontFace = Font.fromEnum(Enum.Font.RobotoMono)
		Header.TextColor3 = HEADER_TEXT_COLOR_3
		Header.TextXAlignment = Enum.TextXAlignment.Left
		Header.TextSize = 18
		Header.Size = UDim2.fromOffset(0, 30)
		Header.AutomaticSize = Enum.AutomaticSize.X
		Header.Parent = Frame
	end

	Frame.Parent = parent

	self.ObjectStyle = LineStyle
	self.Object = Frame
	return self
end

return Line
