PARTICLE_CAST = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
SOUND_VKUSNO = "vkusno"

LinkLuaModifier("modifier_kachok_big_tasty_transformation", "heroes/kachok/modifier_kachok_big_tasty_transformation", LUA_MODIFIER_MOTION_NONE)

kachok_big_tasty = class({})

function kachok_big_tasty:OnSpellStart()
    local caster = self:GetCaster()
    local particle = ParticleManager:CreateParticle(PARTICLE_CAST, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn(SOUND_VKUSNO, caster)

    caster:AddNewModifier(caster, self, "modifier_kachok_big_tasty_transformation", { duration = self:GetSpecialValueFor("transformation_time") })
end