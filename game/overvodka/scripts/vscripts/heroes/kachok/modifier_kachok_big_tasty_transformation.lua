LinkLuaModifier("modifier_kachok_big_tasty_buff", "heroes/kachok/modifier_kachok_big_tasty_buff", LUA_MODIFIER_MOTION_NONE)

modifier_kachok_big_tasty_transformation = class ({})

function modifier_kachok_big_tasty_transformation:IsPurgable()
    return false
end

function modifier_kachok_big_tasty_transformation:IsBuff()
    return true
end

function modifier_kachok_big_tasty_transformation:IsHidden()
    return true
end

function modifier_kachok_big_tasty_transformation:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_kachok_big_tasty_transformation:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true
    }
end

function modifier_kachok_big_tasty_transformation:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    parent:AddNewModifier(caster, ability, "modifier_kachok_big_tasty_buff", { duration = ability:GetSpecialValueFor("duration")} )
end

