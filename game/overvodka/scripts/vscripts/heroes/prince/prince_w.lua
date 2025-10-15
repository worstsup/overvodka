LinkLuaModifier("modifier_prince_w",        "heroes/prince/prince_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prince_w_stacks", "heroes/prince/prince_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prince_w_burst",  "heroes/prince/prince_w", LUA_MODIFIER_MOTION_NONE)

prince_w = class({})

function prince_w:Precache(ctx)
    PrecacheResource("particle", "particles/prince_w_stack.vpcf", ctx)
    PrecacheResource("particle", "particles/prince_w_debuff.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/prince_sounds.vsndevts", ctx)
end

function prince_w:GetIntrinsicModifierName()
    return "modifier_prince_w"
end


modifier_prince_w = class({})

function modifier_prince_w:IsHidden()   return true end
function modifier_prince_w:IsPurgable() return false end

function modifier_prince_w:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_prince_w:OnAttackLanded(params)
    if not IsServer() then return end
    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    if params.attacker ~= parent then return end
    local target = params.target
    if not target or target:IsNull() then return end
    if target:IsBuilding() or target:IsOther() or target:IsWard() then return end
    if target:HasModifier("modifier_prince_w_burst") then return end
    if parent:PassivesDisabled() or parent:IsIllusion() then return end

    local duration = ability:GetSpecialValueFor("duration")
    local stacks_need = ability:GetSpecialValueFor("stacks_need")

    local mod = target:FindModifierByName("modifier_prince_w_stacks")
    if not mod then
        mod = target:AddNewModifier(parent, ability, "modifier_prince_w_stacks", { duration = duration * (1 - target:GetStatusResistance()) })
        if not mod then return end
        mod:SetStackCount(1)
    else
        mod:SetDuration(duration * (1 - target:GetStatusResistance()), true)
        mod:IncrementStackCount()
    end

    if mod:GetStackCount() >= stacks_need then
        EmitSoundOn("prince_w", target)
        mod:Destroy()
        target:AddNewModifier(parent, ability, "modifier_prince_w_burst", {duration = ability:GetSpecialValueFor("effect_duration") * (1 - target:GetStatusResistance()) })
    end
end


modifier_prince_w_stacks = class({})

function modifier_prince_w_stacks:IsHidden()   return false end
function modifier_prince_w_stacks:IsPurgable() return false end
function modifier_prince_w_stacks:IsDebuff()   return true  end

function modifier_prince_w_stacks:OnCreated()
    self.resist_per_stack = self:GetAbility() and self:GetAbility():GetSpecialValueFor("magic_resist") or 0
    if not IsServer() then return end
    self.pfx = ParticleManager:CreateParticle("particles/prince_w_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.pfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
    ParticleManager:SetParticleControl(self.pfx, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.pfx, false, false, -1, false, false)
end

function modifier_prince_w_stacks:OnStackCountChanged(old)
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
    end
end

function modifier_prince_w_stacks:OnRefresh()
    self.resist_per_stack = self:GetAbility() and self:GetAbility():GetSpecialValueFor("magic_resist") or self.resist_per_stack or 0
end

function modifier_prince_w_stacks:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_prince_w_stacks:GetModifierMagicalResistanceBonus()
    local stacks = self:GetStackCount()
    return -(self.resist_per_stack or 0) * stacks
end


modifier_prince_w_burst = class({})

function modifier_prince_w_burst:IsHidden()   return false end
function modifier_prince_w_burst:IsPurgable() return true  end
function modifier_prince_w_burst:IsDebuff()   return true  end

function modifier_prince_w_burst:OnCreated()
    self.total_reduction = self:GetAbility():GetSpecialValueFor("magic_resist") * self:GetAbility():GetSpecialValueFor("stacks_need")
    self.tick = 0.5
    if not IsServer() then return end
    self:StartIntervalThink(self.tick)
end

function modifier_prince_w_burst:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    local dmg = ability:GetSpecialValueFor("debuff_damage") * self.tick
    if ability:GetSpecialValueFor("int_damage") > 0 then
        dmg = dmg + ability:GetSpecialValueFor("int_damage") * self:GetCaster():GetIntellect(false) * self.tick / 100
    end
    ApplyDamage({
        attacker    = self:GetCaster(),
        victim      = self:GetParent(),
        ability     = ability,
        damage      = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
    })
end

function modifier_prince_w_burst:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_prince_w_burst:GetModifierMagicalResistanceBonus()
    return -(self.total_reduction)
end

function modifier_prince_w_burst:GetEffectName()
    return "particles/prince_w_debuff.vpcf"
end

function modifier_prince_w_burst:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end