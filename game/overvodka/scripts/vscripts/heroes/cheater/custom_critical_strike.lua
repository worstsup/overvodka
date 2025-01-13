LinkLuaModifier("modifier_custom_critical_strike", "heroes/cheater/modifier_custom_critical_strike.lua", LUA_MODIFIER_MOTION_NONE)

custom_critical_strike = class({})

function custom_critical_strike:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    caster:AddNewModifier(caster, self, "modifier_custom_critical_strike", {duration = duration})
    EmitSoundOn("awp_draw", caster)
end