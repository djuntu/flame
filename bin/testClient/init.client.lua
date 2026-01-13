local types = game.ReplicatedStorage.Lib.Types
local flameTypes = require(types.FlameTypes)
local buildTypes  = require(types.BuildTypes)

local lib: flameTypes.FlameMain<buildTypes.ClientBuildProps> = require(game.ReplicatedStorage.Lib) {
    EntryPoints = { Enum.KeyCode.F2, Enum.KeyCode.F8 }
}

