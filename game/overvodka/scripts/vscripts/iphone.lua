function IphoneNew( event )
	local caster = event.caster
	local ability = event.ability
	local duration = ability:GetSpecialValueFor( "illusion_duration" )
	local outgoing = ability:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incoming = ability:GetSpecialValueFor( "illusion_incoming_damage" )
	local distance = 0
	local illusions = CreateIllusions(
		caster,
		caster,
		{
			outgoing_damage = outgoing,
			incoming_damage = incoming,
			duration = duration,
		},
		1,
		distance,
		false,
		true
	)
	caster:Purge(false, true, false, false, false)
end