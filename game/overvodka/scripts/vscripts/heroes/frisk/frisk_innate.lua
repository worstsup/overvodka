LinkLuaModifier("modifier_frisk_innate", "heroes/frisk/frisk_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frisk_innate_buff", "heroes/frisk/frisk_innate", LUA_MODIFIER_MOTION_NONE)

frisk_innate = class({})

function frisk_innate:GetIntrinsicModifierName()
    return "modifier_frisk_innate"
end


modifier_frisk_innate = class({})

function modifier_frisk_innate:IsHidden() return true end
function modifier_frisk_innate:IsPurgable() return false end

function modifier_frisk_innate:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_frisk_innate:OnTakeDamage(params)
    if not IsServer() then return end
    if not self:GetParent() or not params.attacker or not params.unit then return end
    if not self:GetAbility() then return end
    if not self:GetAbility():IsCooldownReady() then return end
    if params.attacker == self:GetParent() then return end
    if params.unit ~= self:GetParent() then return end
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_frisk_innate_buff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
    self.cooldown = self:GetAbility():GetCooldown( self:GetAbility():GetLevel() )
    self:GetAbility():StartCooldown(self.cooldown)
    EmitSoundOn("sans_damage", self:GetParent())
end


modifier_frisk_innate_buff = class({})

function modifier_frisk_innate_buff:IsHidden() return false end
function modifier_frisk_innate_buff:IsPurgable() return true end

function modifier_frisk_innate_buff:OnCreated()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/econ/events/seasonal_reward_line_fall_2025/lotus_orb_fallrewardline_2025_shield_fallrewardline_2025.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(p, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_frisk_innate_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_AVOID_DAMAGE}
end

function modifier_frisk_innate_buff:GetModifierAvoidDamage(params)
    return 1
end