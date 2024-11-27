LinkLuaModifier("modifier_custom_vision_aura", "modifier_custom_vision_aura.lua", LUA_MODIFIER_MOTION_NONE)

custom_vision_aura = class({})

-- Apply the modifier when the ability is created
function custom_vision_aura:GetIntrinsicModifierName()
    return "modifier_custom_vision_aura"
end
function custom_vision_aura:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )

    -- Provide global vision for the duration
    AddFOWViewer(caster:GetTeamNumber(), Vector(0, 0, 0), 10000, duration, false)

    -- Add True Sight to all enemies on the map for the duration
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        Vector(0, 0, 0), -- Global position
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
            enemy:AddNewModifier(caster, self, "modifier_truesight", {duration = duration})
    end

    -- Play sound or particle effects to indicate activation (optional)
    EmitSoundOn("wallhack", caster)
end