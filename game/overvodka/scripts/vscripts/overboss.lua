k = 0
require( "utility_functions" )
function ThrowCoin( args )
--	print( "ThrowCoin" )
	local coinAttach = args.caster:ScriptLookupAttachment( "coin_toss_point" )
	local coinSpawn = Vector( 0, 0, 0 )
	if coinAttach ~= -1 then
		coinSpawn = args.caster:GetAttachmentOrigin( coinAttach )
	end
	if k == 53 then
		CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
		EmitGlobalSound( "hamster_announce" )
	end
	if k == 55 then
		EmitGlobalSound( "kirill_start" )
		CustomGameEventManager:Send_ServerToAllClients( "hamster_spawn", {} )
		local hamsterSpawn = Vector( math.random(100, 300), math.random(100, 300), 0 )
		local hamster = CreateUnitByName(
			"npc_hamster",
			hamsterSpawn,
			true,
			undefined,
			undefined,
			DOTA_TEAM_NEUTRALS
		)
		hamster:AddNewModifier(hamster, nil, "modifier_kill", {duration = 30})
	end
--	print( coinSpawn )
	k = k + 1
	GameRules:GetGameModeEntity().COverthrowGameMode:SpawnGoldEntity( coinSpawn )
end
