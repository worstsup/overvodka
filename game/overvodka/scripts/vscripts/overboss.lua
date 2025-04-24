k = 0
require( "utility_functions" )

function ThrowCoin( args )
	local coinAttach = args.caster:ScriptLookupAttachment( "coin_toss_point" )
	local coinSpawn = Vector( 0, 0, 0 )
	if coinAttach ~= -1 then
		coinSpawn = args.caster:GetAttachmentOrigin( coinAttach )
	end
	if k == 8 or k == 16 or k == 32 or k == 44 or k == 64 or k == 76 or k == 88 or k == 96 or k == 102 or k == 108 or (k >= 112 and k % 6 == 0) then
		SpawnBombardiro()
	end
	if k == 23 then
		CustomGameEventManager:Send_ServerToAllClients( "golden_rain_announce", {} )
		EmitGlobalSound( "golden_rain_announce" )
	end
	if k == 25 then
		CustomGameEventManager:Send_ServerToAllClients( "golden_rain_start", {} )
		args.caster:AddAbility("golden_rain")
		args.caster:FindAbilityByName("golden_rain"):SetLevel(1)
		args.caster:CastAbilityNoTarget(args.caster:FindAbilityByName("golden_rain"), -1)
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
	if k == 83 then
		CustomGameEventManager:Send_ServerToAllClients( "golden_rain_announce", {} )
		EmitGlobalSound( "golden_rain_announce" )
	end
	if k == 85 then
		CustomGameEventManager:Send_ServerToAllClients( "golden_rain_start", {} )
		args.caster:FindAbilityByName("golden_rain"):SetLevel(2)
		args.caster:CastAbilityNoTarget(args.caster:FindAbilityByName("golden_rain"), -1)
	end
	if k == 110 then
		CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
		EmitGlobalSound( "hamster_announce" )
	end
	if k == 112 then
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
	k = k + 1
	GameRules:GetGameModeEntity().COverthrowGameMode:SpawnGoldEntity( coinSpawn )
end
