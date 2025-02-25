function item_blink_datadriven_on_spell_start(keys)
	ProjectileManager:ProjectileDodge(keys.caster)
	
	ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, keys.caster)
	EmitSoundOn( "byebye", keys.caster )
	local team = keys.caster:GetTeam()
	local target_point = 0
	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		if fountainEnt:GetTeamNumber() == keys.caster:GetTeamNumber() then
			target_point = fountainEnt:GetAbsOrigin()
			break
		end
    end
	local origin_point = keys.caster:GetAbsOrigin()
	local difference_vector = target_point - origin_point
	
	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)
	
	ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, keys.caster)
end