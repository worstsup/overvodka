LinkLuaModifier("modifier_custom_critical_strike", "modifier_custom_critical_strike.lua", LUA_MODIFIER_MOTION_NONE)

custom_critical_strike = class({})

-- Ability logic when cast
function custom_critical_strike:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )

    -- Apply the critical strike modifier to the caster
    caster:AddNewModifier(caster, self, "modifier_custom_critical_strike", {duration = duration})

    -- Sound and effects (optional)
    EmitSoundOn("awp_draw", caster)
end