kachok_pure_protein = class ({})

function kachok_pure_protein:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end
    -- Damage by Strength
    local strength = caster:GetStrength()
    local strengthDamage = strength * self:GetSpecialValueFor("dmg_strength") / 100
    -- Damage by Random
    local randomDamage = RandomFloat(self:GetSpecialValueFor("damage_min"), self:GetSpecialValueFor("damage_max"))

    local totalDamage = strengthDamage + randomDamage
    ApplyDamage({
        victim = target,
        damage = totalDamage,
        damage_type = self:GetAbilityDamageType(),
        attacker = caster,
        ability = self
    })

    EmitSoundOn("zizi", target)
    local particle = ParticleManager:CreateParticle("particles/ogre_magi_arcana_egg_run_new.vpcf", PATTACH_ABSORIGIN, target)
    --ParticleManager:ReleaseParticleIndex(particle)
end