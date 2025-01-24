function CreateWard(keys)
	local caster = keys.caster
	local ability = keys.ability
	local position = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("duration")
	local talent = ability:GetSpecialValueFor("talent")
	local level = ability:GetLevel()
	local particle_cast = "particles/alchemist_smooth_criminal_unstable_concoction_explosion_new.vpcf"
	local rot_radius = ability:GetSpecialValueFor("rot_radius")

	-- Create Particle
	if level == 1 then
		caster.death_ward = CreateUnitByName("npc_batya_1", position, true, caster, nil, caster:GetTeam())
	end
	if level == 2 then
		caster.death_ward = CreateUnitByName("npc_batya_2", position, true, caster, nil, caster:GetTeam())
	end
	if level == 3 then
		if talent == 1 then
			caster.death_ward = CreateUnitByName("npc_batya_4", position, true, caster, nil, caster:GetTeam())
		else
			caster.death_ward = CreateUnitByName("npc_batya_3", position, true, caster, nil, caster:GetTeam())
		end
	end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster.death_ward )
	caster.death_ward:SetControllableByPlayer(caster:GetPlayerID(), true)
	caster.death_ward:SetOwner(caster)
	caster.death_ward:AddNewModifier(caster.death_ward, nil, "modifier_kill", {duration = duration})
end

function DestroyWard(keys)
	local caster = keys.caster
	
	UTIL_Remove(caster.death_ward)
	StopSoundEvent(keys.sound, caster)
end
