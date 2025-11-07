k = 0
require( "utility_functions" )
function ThrowCoin( args )
	local coinAttach = args.caster:ScriptLookupAttachment( "coin_toss_point" )
	local coinSpawn = Vector( 0, 0, 0 )
	if coinAttach ~= -1 then
		coinSpawn = args.caster:GetAttachmentOrigin( coinAttach )
	end
	if _G.overvodka_events and not IsInToolsMode() then
		if k == 10 or k == 18 or k == 36 or k == 48 or k == 64 or k == 76 or k == 88 or k == 96 or k == 104 or k == 112 or (k >= 118 and k % 8 == 0) then
			SpawnBombardiro()
		end
		if k == 23 then
			CustomGameEventManager:Send_ServerToAllClients( "golden_rain_announce", {} )
			EmitGlobalSound( "golden_rain_announce" )
			Timers:CreateTimer( 15, function()
				CustomGameEventManager:Send_ServerToAllClients( "golden_rain_start", {} )
				args.caster:AddAbility("golden_rain")
				args.caster:FindAbilityByName("golden_rain"):SetLevel(1)
				args.caster:CastAbilityNoTarget(args.caster:FindAbilityByName("golden_rain"), -1)
			end)
		end
		if k == 53 or k == 110 then
			CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
			EmitGlobalSound( "hamster_announce" )
			Timers:CreateTimer( 15, function()
				SpawnHamster()
			end)
		end
		if k == 83 then
			CustomGameEventManager:Send_ServerToAllClients( "golden_rain_announce", {} )
			EmitGlobalSound( "golden_rain_announce" )
			Timers:CreateTimer( 15, function()
				CustomGameEventManager:Send_ServerToAllClients( "golden_rain_start", {} )
				args.caster:FindAbilityByName("golden_rain"):SetLevel(2)
				args.caster:CastAbilityNoTarget(args.caster:FindAbilityByName("golden_rain"), -1)
			end)
		end
	end
	k = k + 1
	GameRules:GetGameModeEntity().OvervodkaGameMode:SpawnGoldEntity( coinSpawn )
end
