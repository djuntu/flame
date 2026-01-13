local types = game.ReplicatedStorage.Lib.Types
local flameTypes = require(types.FlameTypes)
local buildTypes  = require(types.BuildTypes)

local lib: flameTypes.FlameMain<buildTypes.ServerBuildProps> = require(game.ReplicatedStorage.Lib) {
    DoNotAnnounceRunner = false,
}
:addMiddleware(script.BeforeExecution)