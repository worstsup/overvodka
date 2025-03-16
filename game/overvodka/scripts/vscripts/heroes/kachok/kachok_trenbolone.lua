LinkLuaModifier("modifier_kachok_trenbolone", "heroes/kachok/modifier_kachok_trenbolone", LUA_MODIFIER_MOTION_NONE)

kachok_trenbolone = class({})

function kachok_trenbolone:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf", context)
    PrecacheResource("model", "models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl", context)
end

function kachok_trenbolone:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    EmitSoundOn("trenbolone", caster)
    caster:AddNewModifier(caster, self, "modifier_kachok_trenbolone", { duration = duration })
end