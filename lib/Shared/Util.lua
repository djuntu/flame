--[[
    Handles utility functions which may be used by Flame itself and
    the user.
]]
local FlameTypes = require(script.Parent.Parent.Types.FlameTypes)
local Util = {}

local wrapChar = { `'`, `"` }
local continueChar = { `,` }
local specialChar = { `.`, `*`, `?`, `*.` }
local argumentiveChar = { `$` }

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

	if not rawText[1] then
		return nil
	end

	determinant = rawText[1]
	table.remove(rawText, 1)

	-- Restructure args
	args = table.concat(rawText, ' ')

	if string.find(determinant, '/') then
		determinant, entry = string.split(determinant, '/')
	else
		entry = 'Primary'
	end

	return determinant, entry, args
end

--[[
    Maps through each item in a list and modifies based on callback.
]]
function Util.map (list: FlameTypes.List<any>, callback: (any) -> any)
	for i = 1, #list do
		list[i] = callback(i)
	end
end

--[[
    Checks if given data exists and if it is compliant with given type.
]]
function Util.is (b: any?, mustBeType: string)
	return b and typeof(b) == mustBeType
end

--[[
    Parses arguments based on given inputs.
]]
function Util.parseArgs (str: string)
	local stripped = str:gsub('%s+', '')
	for _, special in specialChar do
		if stripped == special then return {stripped} end
	end

	local export = {}
	local token = ''
	local isInWrapCase = false
	local continueNextChar = false
	for i = 1, string.len(str) do
		local char = str:sub(i, i)
		if table.find(wrapChar, char) then
			isInWrapCase = not isInWrapCase

			if not isInWrapCase then
				local willContinue = table.find(continueChar, str:sub(i + 1, i + 1))
				if willContinue then continue end
				table.insert(export, token)
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
				if token ~= '' then table.insert(export, token) end
				token = ''
				continue
			end
		end

		token ..= char
	end

	if token:len() > 0 then table.insert(export, token) end

	return export
end

return Util
