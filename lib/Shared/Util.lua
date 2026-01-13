--[[
    Handles utility functions which may be used by Flame itself and
    the user.
]]

local TextService = game:GetService('TextService')
local TweenService = game:GetService('TweenService')
local FlameTypes = require(script.Parent.Parent.Types.FlameTypes)
local Util = {}
Util.TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint)

local wrapChar = { `'`, `"` }
local continueChar = { `,` }

--[[
    Creates a key: boolean dictionary of the given elements.
]]
function Util.makeDictionary (array: { any })
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
function Util.parseParams (rawText: string): (string, FlameTypes.CommandStyle | string, string)
	local determinant, args, entry
	rawText = string.split(rawText, ' ')

	if not rawText[1] then return nil end

	determinant = rawText[1]
	table.remove(rawText, 1)

	-- Restructure args
	args = table.concat(rawText, ' ')

	if string.find(determinant, '/') then
		determinant, entry = unpack(string.split(determinant, '/'))
	else
		entry = 'Primary'
	end

	return determinant, entry, args
end

--[[
    Maps through each item in a list and modifies based on transformer.
]]
function Util.map (list: FlameTypes.List<any>, transformer: (any) -> any)
	for i = 1, #list do
		list[i] = transformer(i)
	end
end

--[[
	Filters through each item in the given table and constructs a new table
	based on the callback.
]]
function Util.filterKeys (
	comparative: FlameTypes.KeyList<any, any>,
	callback: (any) -> boolean
): FlameTypes.KeyList<any, any>
	local filter = {}

	for key, _ in pairs(comparative) do
		if callback(key) then table.insert(filter, key) end
	end

	return filter
end

--[[
	Filters through each item in the given table and constructs a new table
	based on the callback.
]]
function Util.filterValues (
	comparative: FlameTypes.KeyList<any, any>,
	callback: (any) -> boolean
): FlameTypes.KeyList<any, any>
	local filter = {}

	for _, value in pairs(comparative) do
		if callback(value) then table.insert(filter, value) end
	end

	return filter
end

--[[
	Returns true if given string starts with the given comparator.
]]
function Util.startsWith (text: string, comparator: string)
	return text:sub(1, #comparator) == comparator
end

--[[
    Checks if given data exists and if it is compliant with given type.
]]
function Util.is (b: any?, mustBeType: string)
	return b and typeof(b) == mustBeType
end

--[[
	Trim the leading and trailing whitespace in a string.
]]
function Util.trim (str: string): string
	local _, from = string.find(str, '^%s*')
	return from == #str and '' or string.match(str, '.*%S', from + 1)
end

--[[
	Updates the console size based on the number of lines and clamps at a given Y offset.
]]
function Util.adjustConsoleSize (
	scrollingFrame: ScrollingFrame,
	elementPower: number,
	maxExtents: number,
	fadeElementsIn: boolean
)
	local elements = Util.filterValues(scrollingFrame:GetChildren(), function (item: GuiObject)
		return item:IsA('Frame') or item:IsA('TextBox')
	end)

	if fadeElementsIn then
		for _, element: TextBox | Frame in pairs(elements) do
			if element:IsA('TextBox') then
				TweenService:Create(element, Util.TweenInfo, {
					TextTransparency = 0,
				}):Play()
			else
				for _, child: GuiObject in element:GetChildren() do
					if child:IsA('TextLabel') or child:IsA('TextBox') then
						TweenService:Create(child, Util.TweenInfo, {
							TextTransparency = 0,
						}):Play()
					elseif child:IsA('ImageLabel') then
						TweenService:Create(child, Util.TweenInfo, {
							ImageTransparency = 0,
						}):Play()
					end
				end
			end
		end
	end

	local extents = math.min(maxExtents, elementPower * #elements)
	TweenService:Create(scrollingFrame, Util.TweenInfo, {
		Size = UDim2.new(scrollingFrame.Size.X, UDim.new(0, extents)),
		BackgroundTransparency = 0.3,
	}):Play()
end

--[[
	Fades out the console.
]]
function Util.fadeOutConsole (scrollingFrame: ScrollingFrame)
	local elements = Util.filterValues(scrollingFrame:GetChildren(), function (item: GuiObject)
		return item:IsA('Frame') or item:IsA('TextBox')
	end)

	for _, element: TextBox | Frame in pairs(elements) do
		if element:IsA('TextBox') then
			TweenService:Create(element, Util.TweenInfo, {
				TextTransparency = 1,
			}):Play()
		else
			for _, child: GuiObject in element:GetChildren() do
				if child:IsA('TextLabel') or child:IsA('TextBox') then
					TweenService:Create(child, Util.TweenInfo, {
						TextTransparency = 1,
					}):Play()
				elseif child:IsA('ImageLabel') then
					TweenService:Create(child, Util.TweenInfo, {
						ImageTransparency = 1,
					}):Play()
				end
			end
		end
	end

	TweenService:Create(scrollingFrame, Util.TweenInfo, {
		Size = UDim2.new(scrollingFrame.Size.X, UDim.new(0, 0)),
		BackgroundTransparency = 1,
	}):Play()
end

--[[
	Gets the text size (Vector2) for displaying Autocomplete.
]]
function Util.getTextSize (text: string, textLabel: TextLabel): Vector2
	return TextService:GetTextSize(text, textLabel.TextSize, textLabel.Font, Vector2.new(textLabel.AbsoluteSize.X, 0))
end

--[[
	Filters and then maps the changes to the given list.
]]
function Util.filterMap (
	list: FlameTypes.List<any> | FlameTypes.KeyList<any, any>,
	consumer: (any, any) -> any | nil,
	predicate: (any, any) -> boolean
): FlameTypes.List<any>
	local filtered = {}

	for key, value in pairs(list) do
		if predicate(key, value) then table.insert(filtered, consumer(key, value)) end
	end

	return filtered
end

--[[
	Replaces the comparative string at the index given, used for autofilling.
]]
function Util.targettedSubstringReplace (str, index, comparator, desirable)
	local compLen = #comparator
	local strLen = #str

	local startMin = index - compLen
	local startMax = index

	for startPos = startMin, startMax do
		if startPos >= 1 and startPos + compLen - 1 <= strLen then
			if str:sub(startPos, startPos + compLen - 1) == comparator then
				return str:sub(1, startPos - 1) .. desirable .. str:sub(startPos + compLen)
			end
		end
	end

	return str
end

--[[
	Extracts the item the index is upon based on a string based list (item, item, item)
]]
function Util.getListItemFromCharIndex (list: string, index: number)
	if index < 1 then return string.split(list, ',')[1]:gsub('%s+', '') end

	local item = ''
	local min, max
	for i = 1, index do
		local bi = index - i
		local char = list:sub(bi, bi)

		if char == ',' then
			min = bi + 1
			break
		end

		if i == index then
			min = bi + 1
			break
		end
	end

	for i = index, list:len() do
		local char = list:sub(i, i)

		if char == ',' then
			max = i - 1
			break
		end

		if i == list:len() then
			max = i
			break
		end
	end

	item = list:sub(min, max)
	return item:gsub('%s+', '')
end

--[[
    Parses arguments based on given inputs.
]]
function Util.parseArgs (str: string)
	local characterSets = {}
	local argumentRunBegin = 1
	local export = {}
	local token = ''
	local isInWrapCase = false
	local continueNextChar = false

	local function move (index)
		local set = table.maxn(export)
		characterSets[set] = { argumentRunBegin, index }
		argumentRunBegin = index + 1
		table.insert(export, token)
	end

	for i = 1, string.len(str) do
		local char = str:sub(i, i)
		if table.find(wrapChar, char) then
			isInWrapCase = not isInWrapCase

			if not isInWrapCase then
				local willContinue = table.find(continueChar, str:sub(i + 1, i + 1))
				if willContinue then continue end

				move(i)
				token = ''
			end
			continue
		end

		if table.find(continueChar, char) then
			continueNextChar = i
			token ..= ','
			continue
		end

		if not isInWrapCase then
			if char == ' ' then
				if continueNextChar and continueNextChar == i - 1 then
					continueNextChar = false
					continue
				end
				if token ~= '' then move(i) end
				token = ''
				continue
			end
		end

		token ..= char
	end

	if token:len() > 0 then move(string.len(str)) end

	return export, characterSets
end

--[[
	Returns whether each value of a list satisfies the predicate function.
]]
function Util.every (list: FlameTypes.List<any>, predicate: (any) -> boolean)
	for _, item in pairs(list) do
		if not predicate(item) then return false end
	end

	return true
end

--[[
	Assigns a strength token to each value based on the comparative assessment and then
	resorts the table.
]]
function Util.tokensort (unsorted: FlameTypes.List<string>, strengthTransformer: (string) -> number)
	local tokenArray = {}
	local sorted = {}
	for _, unsortedItem in pairs(unsorted) do
		table.insert(tokenArray, {
			value = unsortedItem,
			token = strengthTransformer(unsortedItem),
		})
	end
	table.sort(tokenArray, function (n1, n2)
		return n1.token > n2.token
	end)

	for i, data in ipairs(tokenArray) do
		table.insert(sorted, data.value)
	end

	return sorted
end

--[[
	Provides a cumulative match for string comparison to where n of s1[n] must equal
	s2[n].
]]
function Util.cmatch (str1: string, str2: string)
	local cumulative = 0
	if typeof(str1) == 'table' then str1 = str1[1] end

	for i = 1, string.len(str1) do
		local char1, char2 = str1:sub(i, i), str2:sub(i, i)
		if char1:lower() == char2:lower() then
			cumulative += 1
			continue
		end

		break
	end

	return cumulative
end

return Util
