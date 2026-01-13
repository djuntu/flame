--[[
    This is a example built-in command that shows custom middleware hooks within the command.
    It displays listing and execution of middleware within the command object.
]]
local Flame = script.Parent.Parent
local Types = require(Flame.Types.FlameTypes)
local Command: Types.UserCommandBuilder = require(Flame.Objects.Command)
local Middleware = require(Flame.Objects.Middleware)

-- Create the 'customMiddleware' command
local CustomMiddleware: Types.CommandProps = {
	Name = 'customMiddleware',
	Aliases = {},
	Group = 'Utilities',
	Middleware = {
		BeforeExecution = Middleware.new('BeforeExecution', function (context)
			context:Reply('This has been called in BeforeExecution.')
			return true
		end),
		AfterExecution = Middleware.new('AfterExecution', function (context, success)
			context:Reply(
				`This has been called in AfterExecution, the command was a {success and 'success' or 'failure'}!`
			)
		end),
	},
}

Command.Primary {
	Hoist = CustomMiddleware,
	Realm = 'Shared',
}(function (context: Types.CommandContext)
	context:Reply('Waiting 3 seconds...')
	for i = 1, 3 do
		context:Reply(`{i} {i > 1 and 'seconds' or 'second'} elapsed...`)
		task.wait(1)
	end

	return 'Done!'
end)

Command.Secondary {
	Hoist = CustomMiddleware,
	Name = 'somethingwentwrong',
	Realm = 'Shared',
}(function (context: Types.CommandContext)
	error('Something went wrong!')
end)

return CustomMiddleware
