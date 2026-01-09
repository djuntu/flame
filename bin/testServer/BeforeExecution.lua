local types = require(game.ReplicatedStorage.Lib.Types.FlameTypes)
local middleware = require(game.ReplicatedStorage.Lib.Objects.Middleware)

return middleware.new('BeforeExecution', function(context)
    return true
end)