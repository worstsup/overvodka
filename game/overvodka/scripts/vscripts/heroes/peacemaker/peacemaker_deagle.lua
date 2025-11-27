LinkLuaModifier("modifier_peacemaker_deagle", "heroes/peacemaker/peacemaker_deagle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peacemaker_deagle_vision", "heroes/peacemaker/peacemaker_deagle", LUA_MODIFIER_MOTION_NONE)

peacemaker_deagle = class({})

function peacemaker_deagle:GetIntrinsicModifierName()
    return "modifier_peacemaker_deagle"
end

modifier_peacemaker_deagle = class({})

function modifier_peacemaker_deagle:IsHidden()   return true end
function modifier_peacemaker_deagle:IsPurgable() return false end
function modifier_peacemaker_deagle:RemoveOnDeath() return false end

function modifier_peacemaker_deagle:OnCreated()
    self.attack_range_bonus = self:GetAbility():GetSpecialValueFor("attack_range")
    if not IsServer() then return end
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function modifier_peacemaker_deagle:OnRefresh()
    self:OnCreated()
end

function modifier_peacemaker_deagle:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_peacemaker_deagle:GetModifierAttackRangeOverride()
    return self.attack_range_bonus
end

function modifier_peacemaker_deagle:GetModifierModelChange()
    return "models/peacemaker/deagle_peacemaker.vmdl"
end

function modifier_peacemaker_deagle:GetAttackSound()
    return "Peacemaker.Deagle.Attack"
end

function modifier_peacemaker_deagle:GetModifierProjectileName()
    return "particles/peacemaker_deagle_proj.vpcf"
end

function modifier_peacemaker_deagle:OnAttackLanded(params)
    if not IsServer() then return end
    local attacker = params.attacker
    local target = params.target
    if attacker ~= self:GetParent() then return end
    if not target or target:IsNull() then return end
    if target:IsBuilding() or target:IsOther() then return end
    target:AddNewModifier(attacker, self:GetAbility(), "modifier_peacemaker_deagle_vision", { duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - target:GetStatusResistance()) })
end

modifier_peacemaker_deagle_vision = class({})

function modifier_peacemaker_deagle_vision:IsHidden()      return false end
function modifier_peacemaker_deagle_vision:IsDebuff()      return true end
function modifier_peacemaker_deagle_vision:IsPurgable()    return true end

function modifier_peacemaker_deagle_vision:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_peacemaker_deagle_vision:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent() or self:GetParent():IsNull() then return end
    if not self:GetCaster() or self:GetCaster():IsNull() then return end
    if not self:GetParent():IsAlive() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 150, 0.15, false)
end