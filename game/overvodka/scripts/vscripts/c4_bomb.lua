LinkLuaModifier("modifier_c4_bomb", "modifier_c4_bomb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_c4_defuse_channel", "modifier_c4_defuse_channel", LUA_MODIFIER_MOTION_NONE)

c4_bomb = class({})
function c4_bomb:OnAbilityPhaseStart()
	EmitGlobalSound("c4_activate")
end
function c4_bomb:OnSpellStart()
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local duration = self:GetLevelSpecialValueFor("detonation_time", self:GetLevel() - 1)

    -- Spawn the bomb
    local bomb = CreateUnitByName("npc_dota_c4_bomb", target_point, true, caster, caster, caster:GetTeam())
    bomb:AddNewModifier(caster, self, "modifier_c4_bomb", { duration = 41 })
end
