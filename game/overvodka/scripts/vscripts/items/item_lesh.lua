function lesh_start(keys)
    local target = keys.target
    if target:TriggerSpellAbsorb(keys.ability) then return end
    local target_maxHealth = target:GetMaxHealth()
    local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
    local particle_effect_intensity = 800
    ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
    local special_damage = target_maxHealth * 0.4
    keys.caster:EmitSound("ailesh")
    keys.target:EmitSound("ailesh")
    if target:IsDebuffImmune() then return end
    keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_abyssal_blade_datadriven_active", nil)
    ApplyDamage({victim = keys.target, attacker = keys.caster, damage = special_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
end
