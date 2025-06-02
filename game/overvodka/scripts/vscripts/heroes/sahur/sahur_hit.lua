sahur_hit = class({})
LinkLuaModifier("modifier_sahur_hit", "heroes/sahur/sahur_hit.lua", LUA_MODIFIER_MOTION_NONE)

function sahur_hit:GetIntrinsicModifierName()
    return "modifier_sahur_hit"
end


modifier_sahur_hit = class({})
function modifier_sahur_hit:IsHidden() return true end
function modifier_sahur_hit:IsPurgable() return false end
function modifier_sahur_hit:RemoveOnDeath() return false end
function modifier_sahur_hit:DeclareFunctions()
    return { MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND }
end
function modifier_sahur_hit:GetAttackSound()
    return "udar_sahur"
end