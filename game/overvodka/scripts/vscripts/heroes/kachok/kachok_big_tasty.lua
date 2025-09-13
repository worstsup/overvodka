LinkLuaModifier("modifier_kachok_big_tasty_transformation", "heroes/kachok/modifier_kachok_big_tasty_transformation", LUA_MODIFIER_MOTION_NONE)

kachok_big_tasty = class({})

function kachok_big_tasty:OnSpellStart()
    local caster = self:GetCaster()
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
    EmitSoundOn("vkusno", caster)

    caster:AddNewModifier(caster, self, "modifier_kachok_big_tasty_transformation", { duration = self:GetSpecialValueFor("transformation_time") })

    if not caster:HasShard() then return end

    local casterMaxHealth = caster:GetMaxHealth()
    local healing = casterMaxHealth * self:GetSpecialValueFor("shard_healing_percent") / 100
    caster:Heal( healing, caster )
end