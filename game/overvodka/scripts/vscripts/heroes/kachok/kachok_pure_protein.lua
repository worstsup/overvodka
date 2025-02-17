kachok_pure_protein = class ({})

function kachok_pure_protein:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local strength = caster:GetStrength()
    local strengthDamage = strength * self:GetSpecialValueFor("dmg_strength") / 100
    local randomDamage = RandomFloat(self:GetSpecialValueFor("damage_min"), self:GetSpecialValueFor("damage_max"))

    local totalDamage = strengthDamage + randomDamage
    ApplyDamage({
        victim = target,
        damage = totalDamage,
        damage_type = self:GetAbilityDamageType(),
        attacker = caster,
        ability = self
    })
    if self:GetSpecialValueFor("attack") == 1 then
		self:GetCaster():PerformAttack(target, true, true, true, true, true, false, true)
	end
    EmitSoundOn("zizi", target)
    local particle = ParticleManager:CreateParticle("particles/ogre_magi_arcana_egg_run_new.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:ReleaseParticleIndex(particle)
end