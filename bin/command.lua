local flame_builder
local kick = flame_builder() {
	name = 'kick',
    alias = {},

    group = 'TestGroup'
}

function kick:main (context)
	local players = context.args.pick('players')

	for _, player in players do
		player:Kick()
	end

	return 'Done'
end

function kick:onCondition (context)
	local players = context.args.pick('players')

	local kick_players = context.args.filter(players, function (player)
		return player.Name == 'Djuntu'
	end)

	for _, player in kick_players do
		player:Kick()
	end

	return 'Done'
end

return kick
