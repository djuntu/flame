-- Implementation of a player on the server.
local Types = require(script.Parent.Parent.Types.FlameTypes)
local Util = require(script.Parent.Parent.Shared.Util)
return function (argument: Types.Arguments)
    return argument.Make('players', argument.MakeListableType {
        Parse = function(value: string)
            return string.split(value, ',')
        end,
        Validate = function(values: {string})
            local serverPlayers = game.Players:GetPlayers()
            for _, value in pairs(values) do
                local foundPlayer = false
                for _, player in  serverPlayers do
                    if value:lower() == player.Name:lower() then
                        foundPlayer = true
                        break
                    end
                end

                if not foundPlayer then
                    return false
                end
            end

            return true
        end,
        Transform = function(values: {string})
            local players = {}
            local serverPlayers = game.Players:GetPlayers()
            for _, value in pairs(values) do
                for _, player in  serverPlayers do
                    if value:lower() == player.Name:lower() then
                        table.insert(players, player)
                    end
                end
            end

            return players
        end,
        Search = function(value: string)
            local players = game.Players:GetPlayers()
            Util.map(players, function(k: number)
                local player = players[k]
                return player.Name
            end)

            return argument.SearchLikeEnum(players)(value)
        end
    })
end