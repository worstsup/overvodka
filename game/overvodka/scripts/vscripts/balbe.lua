LinkLuaModifier("modifier_item_balbe", "balbe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_balbe_active", "balbe", LUA_MODIFIER_MOTION_NONE)

item_balbe = class({})

function item_balbe:GetIntrinsicModifierName()
    return "modifier_item_balbe"
end

function item_balbe:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end
    local haste_pfx = ParticleManager:CreateParticle("particles/items2_fx/phase_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(haste_pfx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(haste_pfx)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_balbe_active", {duration = duration} )
    self:GetParent():EmitSound("DOTA_Item.PhaseBoots.Activate")
end

modifier_item_balbe = class({})

function modifier_item_balbe:IsHidden() return true end
function modifier_item_balbe:IsPurgable() return false end
function modifier_item_balbe:IsPurgeException() return false end
function modifier_item_balbe:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_balbe:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end
function modifier_item_balbe:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('attack_speed_bonus')
    end
end
function modifier_item_balbe:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end

function modifier_item_balbe:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_damage')
    end
end

function modifier_item_balbe:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_armor')
    end
end

function modifier_item_balbe:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_all')
    end
end

function modifier_item_balbe:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_all')
    end
end

function modifier_item_balbe:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_all')
    end
end

modifier_item_balbe_active = class({})

function modifier_item_balbe_active:IsPurgable()
    return false
end

function modifier_item_balbe_active:GetTexture()
    return "items/balbe"
end

function modifier_item_balbe_active:OnCreated()
    self.movespeed_bonus = self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end

function modifier_item_balbe_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_item_balbe_active:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed_bonus
end

function modifier_item_balbe_active:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end
