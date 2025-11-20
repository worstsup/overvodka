function ThrowCoin( args )
	if not IsServer() then return end
	if not args or not args.caster or args.caster:IsNull() then return end

	local caster = args.caster

	local coinAttach = caster:ScriptLookupAttachment( "coin_toss_point" )
	local coinSpawn = Vector( 0, 0, 0 )
	if coinAttach ~= -1 then
		coinSpawn = caster:GetAttachmentOrigin( coinAttach )
	end

	GameRules:GetGameModeEntity().OvervodkaGameMode:SpawnGoldEntity( coinSpawn )
end