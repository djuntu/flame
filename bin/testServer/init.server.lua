local types = game.ReplicatedStorage.Lib.Types
local flameTypes = require(types.FlameTypes)
local buildTypes  = require(types.BuildTypes)

local lib: flameTypes.FlameMain<buildTypes.ServerBuildProps> = require(game.ReplicatedStorage.Lib) {
    DoNotAnnounceRunner = true,
}
:addMiddleware(script.BeforeExecution)

print(lib.Dispatcher:EvaluateAndRun(nil, 'test Primary'))