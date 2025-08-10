flash_q_facet_1 = class({})

function flash_q_facet_1:Precache(context)
    PrecacheResource("particle", "particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
end

function flash_q_facet_1:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_speed") * caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), true) * 0.01
    ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType()})
    local particle = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    local particle2 = ParticleManager:CreateParticle("particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle2)
    target:EmitSound("Hero_Zuus.LightningBolt")
end