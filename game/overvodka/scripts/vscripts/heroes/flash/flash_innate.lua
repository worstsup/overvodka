LinkLuaModifier("modifier_flash_innate", "heroes/flash/flash_innate", LUA_MODIFIER_MOTION_NONE)

flash_innate = class({})

function flash_innate:GetIntrinsicModifierName()
    return "modifier_flash_innate"
end

modifier_flash_innate = class({})

function modifier_flash_innate:IsHidden() return true end
function modifier_flash_innate:IsPurgable() return false end

function modifier_flash_innate:DeclareFunctions()
    return {MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_flash_innate:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_flash_innate:GetModifierMoveSpeedBonus_Constant()
    return self:GetParent():GetAgility() * self:GetAbility():GetSpecialValueFor("agi_to_ms")
end