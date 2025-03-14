LinkLuaModifier("modifier_kachok_trenbolone", "heroes/kachok/modifier_kachok_trenbolone", LUA_MODIFIER_MOTION_NONE)

kachok_trenbolone = class({})

function kachok_trenbolone:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_kachok_trenbolone", { duration = duration })
end