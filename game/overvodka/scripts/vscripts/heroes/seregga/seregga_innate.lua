LinkLuaModifier("modifier_seregga_innate", "heroes/seregga/seregga_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_innate_proc", "heroes/seregga/seregga_innate", LUA_MODIFIER_MOTION_NONE)

seregga_innate = class({})

function seregga_innate:GetIntrinsicModifierName()
    return "modifier_seregga_innate"
end


modifier_seregga_innate = class({})

function modifier_seregga_innate:IsHidden()        return self:GetStackCount() == 0 end
function modifier_seregga_innate:IsPurgable()      return false end
function modifier_seregga_innate:RemoveOnDeath()   return false end

function modifier_seregga_innate:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    if not IsServer() then return end

    self.stack_timers = {}
    self:SetStackCount(0)

    self:StartIntervalThink(0.1)
end

function modifier_seregga_innate:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

local function _IsValidCastForStacks(parent, ability)
    if not ability then return false end
    if ability:IsItem() then return false end
    if ability:IsToggle() then return false end
    if ability:GetAbilityName() == "seregga_scepter_stop" then return false end
    return true
end

function modifier_seregga_innate:OnAbilityExecuted(event)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not self:GetAbility():IsCooldownReady() then return end
    if event.unit ~= self.parent then return end
    local ability = event.ability
    if not _IsValidCastForStacks(self.parent, ability) then return end

    local stack_duration = self.ability:GetSpecialValueFor("stack_duration")
    local stacks_needed  = self.ability:GetSpecialValueFor("stacks_needed")

    table.insert(self.stack_timers, GameRules:GetGameTime() + stack_duration)
    self:SetStackCount(#self.stack_timers)

    if #self.stack_timers >= stacks_needed then
        self.stack_timers = {}
        self:SetStackCount(0)
        self.ability:UseResources(false, false, false, true)
        local buff_dur = self.ability:GetSpecialValueFor("bonus_duration")
        self.parent:AddNewModifier(self.parent, self.ability, "modifier_seregga_innate_proc", {duration = buff_dur})

        self.parent:EmitSound("seregga_innate")
        local p = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_splash.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 1, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 3, self.parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p)
    end
end

function modifier_seregga_innate:OnIntervalThink()
    if not IsServer() then return end
    if #self.stack_timers == 0 then return end

    local now = GameRules:GetGameTime()
    local changed = false

    local alive = {}
    for _,expire in ipairs(self.stack_timers) do
        if expire > now then
            table.insert(alive, expire)
        else
            changed = true
        end
    end
    if changed then
        self.stack_timers = alive
        self:SetStackCount(#self.stack_timers)
    end
end


modifier_seregga_innate_proc = class({})

function modifier_seregga_innate_proc:IsHidden()      return false end
function modifier_seregga_innate_proc:IsPurgable()    return true end
function modifier_seregga_innate_proc:GetEffectName() return "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_debuff.vpcf" end
function modifier_seregga_innate_proc:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_seregga_innate_proc:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability then return end
    self.ms_pct   = self.ability:GetSpecialValueFor("bonus_ms_pct")
    self.hp_reg   = self.ability:GetSpecialValueFor("bonus_hp_regen_pct")
    self.mp_reg   = self.ability:GetSpecialValueFor("bonus_mana_regen_pct")
end

function modifier_seregga_innate_proc:OnRefresh()
    if not self.ability then return end
    self.ms_pct   = self.ability:GetSpecialValueFor("bonus_ms_pct")
    self.hp_reg   = self.ability:GetSpecialValueFor("bonus_hp_regen_pct")
    self.mp_reg   = self.ability:GetSpecialValueFor("bonus_mana_regen_pct")
end

function modifier_seregga_innate_proc:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end

function modifier_seregga_innate_proc:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_pct or 0
end

function modifier_seregga_innate_proc:GetModifierHealthRegenPercentage()
    return self.hp_reg or 0
end

function modifier_seregga_innate_proc:GetModifierTotalPercentageManaRegen()
    return self.mp_reg or 0
end
