LinkLuaModifier("modifier_custom_vision_aura", "heroes/cheater/modifier_custom_vision_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_vision_aura_lol", "heroes/cheater/modifier_custom_vision_aura_lol.lua", LUA_MODIFIER_MOTION_NONE)
custom_vision_aura = class({})

function custom_vision_aura:GetCooldown( level )
    local base_cd = self.BaseClass.GetCooldown( self, level )
    if GetMapName() == "overvodka_5x5" then
        return base_cd + self:GetSpecialValueFor("dota_bonus_cooldown")
    end
    return base_cd
end

function custom_vision_aura:GetIntrinsicModifierName()
    return "modifier_custom_vision_aura"
end

function custom_vision_aura:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    caster:AddNewModifier(caster, self, "modifier_custom_vision_aura_lol", { duration = duration })
    AddFOWViewer(caster:GetTeamNumber(), Vector(0, 0, 0), 12000, duration, false)
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        Vector(0, 0, 0),
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
    EmitSoundOn("wallhack", caster)
end