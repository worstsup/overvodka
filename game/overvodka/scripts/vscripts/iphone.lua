function IphoneNew( event )
	-- unit identifier
	local caster = event.caster
	local ability = event.ability
	-- load data
	local duration = ability:GetSpecialValueFor( "illusion_duration" )
	local outgoing = ability:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incoming = ability:GetSpecialValueFor( "illusion_incoming_damage" )
	local distance = 0
	-- create illusion
	local illusions = CreateIllusions(
		caster, -- hOwner
		caster, -- hHeroToCopy
		{
			outgoing_damage = outgoing,
			incoming_damage = incoming,
			duration = duration,
		}, -- hModiiferKeys
		1, -- nNumIllusions
		distance, -- nPadding
		false, -- bScramblePosition
		true -- bFindClearSpace
	)
end