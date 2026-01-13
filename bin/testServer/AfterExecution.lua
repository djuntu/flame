local types = require(game.ReplicatedStorage.Lib.Types.FlameTypes)
local middleware = require(game.ReplicatedStorage.Lib.Objects.Middleware)

return middleware.new('AfterExecution', function(context, success)
    print(success)
    return true
end)