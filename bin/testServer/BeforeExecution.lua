local types = require(game.ReplicatedStorage.Lib.Types.FlameTypes)
local middleware = require(game.ReplicatedStorage.Lib.Objects.Middleware)

return middleware.new('BeforeExecution', function(context)
    print('before execution')
    return true
end)