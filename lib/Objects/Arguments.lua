-- Handles type registration and argument type hinting.
local lib = script.Parent.Parent
local FlameTypes = require(lib.Types.FlameTypes)

local Util = require(lib.Shared.Util)
local Error = require(lib.Error) {
	Source = 'Shared',
}
Error:setSpeaker(Error.Speakers.ArgumentParserException)

--[[
    No repeating-pairs value which eliminates duplicates.
]]
local function nrpairs (items: { string })
	local i = {}
	for _, item in ipairs(items) do
		if table.find(i, item) then continue end

		table.insert(i, item)
	end

	return i
end

--[[
    Provides a simple Enum which prevents modification to maintain
    intended shape.
]]
local function makeEnum (enumName: string, enumItems: { string })
	local enum = {}

	for _, item in nrpairs(enumItems) do
		enum[item] = item
	end

	return setmetatable(enum, {
		__newindex = function (_, k, v)
			error(('Attempted to create [%s]=%s in Enum %s when creating is disallowed.'):format(k, v, enumName))
		end,
	})
end

--[[
    @interface Arguments
    @within Flame

    @public
    @type Arguments
]]
local Arguments: FlameTypes.Arguments = {
	Types = {},
}
--[[
    @prop Types
    @type TypeRegistry

    @public
]]

--[[
    @within Arguments
    @function StructHasArgument
	Checks whether the given ArgumentStruct has a given argument.

	@param struct: ArgumentStruct
	@param name: string
	@returns number: Index | boolean=false
]]
function Arguments.StructHasArgument(struct: FlameTypes.ArgumentStruct, name: string)
    for index, argument in pairs(struct) do
        if argument.Name == name then
            return index
        end
    end

    return false
end

--[[
    @within Arguments
    @function Struct
	Creates an ArgumentStruct

	@param givenArguments: GivenArguments <- This comes from the Command
	@returns ArgumentStruct
]]
function Arguments.Struct (givenArguments: FlameTypes.GivenArguments): FlameTypes.ArgumentStruct
	local required, optional = {}, {}
	for i, argument in ipairs(givenArguments) do
		local structTable = argument.Optional and optional or required

		if Arguments.StructHasArgument(required, argument.Name) or Arguments.StructHasArgument(optional, argument.Name) then
			Error:setContext(('Clashnig attempt on ArgumentStruct index for key %s.'):format(argument.Name))
				:setTraceback(debug.traceback())
				:recommend(
					'You have two or more Arguments with the same Name= property, all arguments must have a different name.'
				)
				:say()
			return
		end

		Error:setContext('Missing required property in CommandArgument.')
			:setTraceback(debug.traceback())
			:recommend('Ensure you have a Name= and a Type= property.')

		Error:assertsay(Util.is(argument.Name, 'string'))
		Error:assertsay(Util.is(argument.Type, 'string'))

		local registeredType = Arguments.Types[argument.Type]

		if not registeredType then
			Error:setContext(('%s is not a registered type!'):format(argument.Type))
				:setTraceback(debug.traceback())
				:recommend('If this is a custom type, ensure you have registered it with RegisterTypes.')
				:say()
			return
		end

		local isDataType = Arguments.typeOf(registeredType) == 'DataType'
        table.insert(structTable, {
            Name = argument.Name,
            Evaluate = function (argumentInput: string)
                return Arguments.Evaluator(argument.Type, argumentInput)
            end,
			Transform = isDataType and registeredType.Transform or function(value: string)
				for target, _ in pairs(registeredType) do
					if string.lower(target) == string.lower(value) then
						return target
					end
				end

				return value
			end,
			Parse = isDataType and registeredType.Parse or function (value)
				return value
			end
        })
	end

	if next(optional) then
		for i, optionalArgument in ipairs(optional) do
			table.insert(required, optionalArgument)
		end
	end

	return required
end

--[[
    @within Arguments
    @function Inherit
	Used to get a Type from the Registry.

	::: @cyclic :::
	This should be used within your Type functions (Parse, Transform, Validate)
	as inheriting types before they exist may be a risk if not.
	::: @note :::

	@param name: string
	@returns FlameTypes.DataType | FlameTypes.EnumType
]]
function Arguments.Inherit (name: string): FlameTypes.DataType | FlameTypes.EnumType
	local type = Arguments.Types[name]
	assert(type, string.format('%s exists as no type.\n%s', name, debug.traceback()))
	return type
end

--[[
    @within Arguments
    @function Evaluator
	Evaluates the validity of given type against the provided input and provides
	a consensus and a hint list.

	@param stringType: string
	@param argumentInput: string
	@returns (consensus: boolean, HintList: FlameTypes.Hint)
]]
function Arguments.Evaluator (stringType: string, argumentInput: string?): (boolean, FlameTypes.Hint)
	local registeredType = Arguments.Types[stringType]

	if not registeredType then
		Error:setContext(('%s is not a registered type!'):format(stringType))
			:setTraceback(debug.traceback())
			:recommend('If this is a custom type, ensure you have registered it with RegisterTypes.')
			:say()
		return
	end

	local isDataType = Arguments.typeOf(registeredType) == 'DataType'
	local type = isDataType and registeredType :: FlameTypes.DataType or registeredType :: FlameTypes.EnumType
	local validateFunction = isDataType and type.Validate
		or function (value: string)
			local canIndex = typeof(value) == 'string'
			if not canIndex then
				return false
			end

			for index, _ in pairs(type) do
				if string.lower(index) == string.lower(value) then
					return true
				end
			end
			return false
		end

	local isValid = validateFunction(argumentInput)

	return isValid, isDataType and (type.Search and type.Search(argumentInput) or {}) or type
end

--[[
    @within Arguments
    @function Make
	Creates a new Type.

	@param argumentName: string
	@param evaluator: FlameTypes.DataType | FlameTypes.EnumType
	@returns ArgumentType
]]
function Arguments.Make(argumentName: string, argumentEvaluator: FlameTypes.DataType | FlameTypes.EnumType): FlameTypes.ArgumentType
	return function ()
		return argumentName, argumentEvaluator
	end
end

--[[
    @within Arguments
    @function Make
	Creates a new EnumType.

	@param name: string
	@param list: List<string>
	@returns EnumType
]]
function Arguments.MakeEnumType(name: string, list: FlameTypes.List<string>): FlameTypes.EnumType
	return makeEnum(name, list)
end

--[[
    @within Arguments
    @function Make
	Creates a new DataType.

	@param holotype: DataType
	@returns DataType
]]
function Arguments.MakeDataType(holotype: FlameTypes.DataType): FlameTypes.DataType
	-- Validate properties
	assert(typeof(holotype) == 'table', 'Expected table for MakeDataType entry.')
	assert(typeof(holotype.Parse) == 'function', 'Expected function for Parse got other.')
	assert(typeof(holotype.Validate) == 'function', 'Expected function for Validate got other.')
	assert(typeof(holotype.Transform) == 'function', 'Expected function for Transform got other.')

	if holotype.Search then
		assert(typeof(holotype.Search) == 'function', 'Expected function for optional Search got other.')
	end

	-- Remove sparse entries
	return {
		Parse = holotype.Parse,
		Validate = holotype.Validate,
		Transform = holotype.Transform,

		Search = holotype.Search,
	}
end

--[[
    @within Arguments
    @function Make
	Single Evaluator for a given argument, used by the client as an entry point.

	@param struct: ArgumentStruct
	@param argumentName: string
	@userInput: string?
	@returns (boolean, Hint)
]]
function Arguments.Seems (
	struct: FlameTypes.ArgumentStruct,
	argumentName: string,
	userInput: string?
): (boolean, FlameTypes.Hint)
	if struct[argumentName] then return struct[argumentName](userInput) end

	return false
end

--[[
    @within Arguments
    @function Dilute
	Evaluates the given arguments and makes a decision as well as creating
	ArgumentContext to be used by the Command through its CommandContext.

	@param struct: ArgumentStruct
	@userInput: string?
	@returns (boolean, KeyList<string, ArgumentContext>)
]]
function Arguments.Dilute (
	struct: FlameTypes.ArgumentStruct,
	userInput: string?
): (boolean, FlameTypes.KeyList<string, FlameTypes.ArgumentContext>)
    local argumentsSeemOK = true
	local contextMesh = {}

	local parsedInputs = Util.parseArgs(userInput or '')
	for index, structInner in pairs(struct) do
		local input = structInner.Parse(parsedInputs[index])
		if not structInner.Evaluate(input) then
			argumentsSeemOK = false
		end

		contextMesh[structInner.Name] = Arguments.Context(structInner.Name, structInner.Transform(input))
	end

	return argumentsSeemOK, contextMesh
end

--[[
    @within Arguments
    @function Context
	Creates a Context for an argument.

	@param name: string
	@param userInput: string?
	@returns ArgumentContext
]]
function Arguments.Context (name: string, userInput: string?): FlameTypes.ArgumentContext
	return {
		Name = name,
		Input = userInput
	}
end

--[[
    @within Arguments
    @function Register
	Registers a type to the Argument Registry.

	@param type: ArgumentType
	@returns void
]]
function Arguments.Register (type: FlameTypes.ArgumentType): ()
	local typeName, t = type()

	if Arguments.Types[typeName] then error(('%s already exists as a type.'):format(typeName)) end
	Arguments.Types[typeName] = t
end

--[[
    @within Arguments
    @function typeOf
	Evaluates the type of the given input (DataType or EnumType). Used
	for making decisions when parsing.

	::: @notfriendly :::
	This does not have inherent error checking as it is only
	meant to be used by the Arguments object itself.
	::: @note :::

	@protected
	@param type: DataType | EnumType
	@returns string
]]
function Arguments.typeOf (t: FlameTypes.DataType | FlameTypes.EnumType)
	if t['Parse'] then return 'DataType' end

	return 'EnumType'
end

return Arguments
