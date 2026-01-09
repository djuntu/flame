local SoundService = game:GetService('SoundService')
local lib = script.Parent

local ErrorTypes = require(lib.Types.ErrorTypes)
local VALID_ERROR_SOURCES = { 'Server', 'Client', 'Shared' }
local VALID_WRITE_TYPES = {
	error = error,
	warn = warn,
	print = print,
}
local ERROR_GHOST =
	'\n--------------Start FlameError [%s]--------------\nFlame encountered a %s error.\n%s\n%s\n------------------------------------------\nRecommended action: %s\n--------------End FlameError--------------'

--[[
    @object Error
    @within Flame

    Creates a new Error object based on the error configuration provided.

    ```lua
    local error = Error() {
        Source = 'Client'
    }

    error
        :setSpeaker(error.Speakers.CommandException)
        :recommend('I recommend you learn coding.')
        :say()
    ```

    @param ErrorObjectCreationConfig
    @returns ErrorInterface
]]
local _Error = { mode = 'kv' }
_Error.__index = _Error

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
		__index = function (_, k)
			error(('%s is not apart of Enum %s'):format(k, enumName))
		end,
		__newindex = function (_, k, v)
			error(('Attempted to create [%s]=%s in Enum %s when creating is disallowed.'):format(k, v, enumName))
		end,
	})
end

--[[
    Returns if the value can be called by either natural type of metamethod.
]]
local function isCallable (value: () -> () | { __call: any } | any?)
	if type(value) == 'function' then return true end

	if type(value) == 'table' then
		local metatable = getmetatable(value)
		if metatable and type(rawget(metatable, '__call')) == 'function' then return true end
	end

	return false
end

--[[
    Returns if the given value is an Error object.

    @within Error
    @param e: ErrorObject | any
    @returns boolean
]]
function _Error.isKind (e: ErrorTypes.ErrorObject | any)
	return typeof(e) == 'table' and (rawget(e, 'className') == 'error')
end

--[[
    Wraps isKind into a __eq (==) operator.
]]
function _Error:__eq (value: ErrorTypes.ErrorObject | any)
	return self.isKind(value)
end

function _Error.new (errorConfig: ErrorTypes.ErrorObjectCreationConfig)
	local config
	do
		config = errorConfig
		config.Speakers = makeEnum('ErrorSpeaker', {
			'InitializationException',
			'CommandException',
			'PermissionMismatchException',
			'CommandExecutionException',
			'MiddlewareException'
		})

		config.className = 'error'
	end

	local self = config
	setmetatable(self, _Error)

	return self
end

--[[
    'Speaks' (writes error to console) the error data by formatting all
    structured values.

    @within ErrorPrototype
    @param writeType?: string
    @returns ErrorObject
    @optional
]]
function _Error:say (writeType: string?)
	local speaker = writeType or 'error'
	if writeType and not VALID_WRITE_TYPES[writeType] then
		error(('%s is not a valid write type.'):format(writeType))
	end

	local evaluator = self:_getEvaluator()
	self:_say(speaker, evaluator)

	return self
end

--[[
    Wraps the `say` function in an assertion check (condition provided
	is false or nil).

    @within ErrorPrototype
	@param condition: Condition?
    @param writeType?: string
    @returns ErrorObject
    @optional
]]
function _Error:assertsay <C>(condition: C?, writeType: string?)
	if condition then return self end
	return self:say(writeType)
end

--[[
    Used when displaying the error itself by
    meshing error items into a singleton string.

    @within Error
    @returns string
]]
function _Error:__tostring ()
	local satisfyArgs = { 'Source', 'Speaker', 'Context', 'Traceback', 'Recommend' }
	local argsStack = {}

	-- Go through each key and extract the value or state as not provided.
	for i, k in ipairs(satisfyArgs) do
		table.insert(argsStack, rawget(self, k) or 'No data provided.')
	end

	-- Format based on stack.
	return ERROR_GHOST:format(table.unpack(argsStack))
end

--[[
    Prevents unintentional writing to the Error object.
]]
function _Error:__newindex (k: string)
	error(
		('Attempted to index Error object outside of method. %s'):format(
			k and string.format('You may mean #set%s', k) or 'No suggested method.'
		)
	)
end

--[[
    Proto-raw form of :say to allow internal bargaining of the speech
    function if necessary.

    @within ErrorPrototype
    @param writeType?: string
    @returns ErrorObject
    @optional
]]
function _Error:_say (speaker: string, evaluator: () -> ()?)
	local message = tostring(self)

	if evaluator then
		local evaluatorAllowsSpeech = self:_evaluate(evaluator)
		if not evaluatorAllowsSpeech then return end
	end

	VALID_WRITE_TYPES[speaker](message)

	return self
end

--[[
    Sets the speaker of the error (the type of the error).

    @within ErrorPrototype
    @param Speaker: string
    @returns ErrorObject
]]
function _Error.setSpeaker (self: ErrorTypes.ErrorObject, speaker: string)
	if speaker == nil then
		rawset(self, 'Speaker', nil)
		return self
	end

	assert(typeof(speaker) == 'string', 'Expected literal string for base type in setSpeaker, got other.')

	-- Checks to see if the Speaker is apart of the Enum.
	speaker = self.Speakers[speaker]
	rawset(self, 'Speaker', speaker)

	return self
end

--[[
    Sets the context of the error (plain-text English for what the error is).

    @within ErrorPrototype
    @param Context: string
    @returns ErrorObject
]]
function _Error:setContext (context: string)
	if context == nil then
		rawset(self, 'Context', nil)
		return self
	end

	assert(typeof(context) == 'string', 'Expected literal string for base type in setContext, got other.')
	rawset(self, 'Context', context)

	return self
end

--[[
    Sets the context of the error (plain-text English for what the error is).
    Error prefers that the user sets the traceback to ensure the traceback path is more
    direct.

    @within ErrorPrototype
    @param Context: string
    @returns ErrorObject
]]
function _Error:setTraceback (traceback: string)
	if traceback == nil then
		rawset(self, 'Traceback', nil)
		return self
	end

	assert(typeof(traceback) == 'string', 'Expected literal string for base type in setTraceback, got other.')
	rawset(self, 'Traceback', traceback)

	return self
end

--[[
    Sets the recommendation for the Error. This is a suggestion from Documentation to make developer
    resolution of any problems encountered by Flame quicker to resolve.

    @within ErrorPrototype
    @param Recommendation: string
    @returns ErrorObject
    @optional
]]
function _Error:recommend (recommendation: string)
	if recommendation == nil then
		rawset(self, 'Recommend', nil)
		return self
	end

	assert(typeof(recommendation) == 'string', 'Expected literal string for base type in recommend, got other.')
	rawset(self, 'Recommend', recommendation)

	return self
end

--[[
    Evaluates respective evaluator and provides a cushion response
    to be parsed back to the speaker.

    @within ErrorPrototype
    @param evaluator: ErrorEvaluator
    @returns boolean
    @optional
]]
function _Error:_evaluate (evaluator: () -> ()?)
	local nonDestructive, evaluation = pcall(evaluator)

	assert(nonDestructive, string.format('Provided evaluator was destructive and threw exception:\n %s', evaluation))
	return evaluation
end
--[[
    Returns the error evaluator (if it exists).

    @within ErrorPrototype
    @returns ErrorEvaluator?: ErrorEvaluator
]]
function _Error._getEvaluator (self: ErrorTypes.ErrorObject)
	if self.Evaluator and isCallable(self.Evaluator) then return self.Evaluator end
end

--[[
    Derives a new error using an existing Error object to allow multi-use
    Errors.

    @within Error
    @param baseError: ErrorObject
    @returns ErrorObject
]]
function _Error.implements (baseError: ErrorTypes.ErrorObject)
	assert(
		_Error.isKind(baseError),
		'Attempted to implement a new error with invalid object. Expected ErrorObject got other.'
	)

	getmetatable(baseError).__newindex = nil

	return _Error.new(baseError)
end

--[[
    Wraps the Error instantiation to allow for derivation of other Error
    Objects as the validation is outside the primary scope.
]]
return function (errorConfig: ErrorTypes.ErrorObjectCreationConfig): (ErrorTypes.ErrorObject, ErrorTypes.ErrorObject)
	assert(errorConfig, 'Expected type ErrorObjectCreationConfig got nil.')
	assert(typeof(errorConfig) == 'table', 'Expected type table for base literal got non table when instantiating.')

	assert(errorConfig.Source, 'Expected errorConfig Source, got nil.')
	assert(
		table.find(VALID_ERROR_SOURCES, errorConfig.Source),
		string.format('%s is not a valid Error Source!', errorConfig.Source)
	)

	return _Error.new(errorConfig), _Error
end
