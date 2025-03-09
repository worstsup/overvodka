LinkLuaModifier("modifier_bratishkin_r_debuff", "heroes/bratishkin/bratishkin_r", LUA_MODIFIER_MOTION_NONE)
bratishkin_r = class({})

function bratishkin_r:Precache(context)
    PrecacheResource("particle", "particles/bratishkin_r.vpcf", context)
end

bratishkin_r = class({})

function bratishkin_r:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    if not target:IsHero() then return end
    local modifier = target:FindModifierByNameAndCaster("modifier_bratishkin_r_debuff", caster)
    local is_new = false
    
    if not modifier then
        modifier = target:AddNewModifier(
            caster,
            self,
            "modifier_bratishkin_r_debuff",
            {duration = -1}
        )
        is_new = true
    end
    if modifier then
        if is_new then
            modifier:SetStackCount(1) 
        else
            modifier:IncrementStackCount()
        end
        modifier:ForceRefresh()
    end

    self:PlayEffects(target)
end

function bratishkin_r:PlayEffects(target)
    local sound_cast = "gennadiy_start"
    EmitSoundOn(sound_cast, target)
end

modifier_bratishkin_r_debuff = class({})

function modifier_bratishkin_r_debuff:IsHidden() return false end
function modifier_bratishkin_r_debuff:IsDebuff() return true end
function modifier_bratishkin_r_debuff:IsPurgable() return false end
function modifier_bratishkin_r_debuff:RemoveOnDeath() return false end
function modifier_bratishkin_r_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_bratishkin_r_debuff:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.2)
    end
end

function modifier_bratishkin_r_debuff:OnIntervalThink()
    if not self:GetParent():IsAlive() then
        self:SetDuration(-1, true)
    end
end

function modifier_bratishkin_r_debuff:OnStackCountChanged(previous_stacks)
    if IsServer() then
        local parent = self:GetParent()
        local stack_count = self:GetStackCount()
        if self.effect then
            ParticleManager:DestroyParticle(self.effect, true)
        end
        
        self.effect = ParticleManager:CreateParticle("particles/bratishkin_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(self.effect)
    end
end

function modifier_bratishkin_r_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_bratishkin_r_debuff:GetModifierIncomingDamage_Percentage(keys)
    if keys.attacker == self:GetCaster() then
        local bonus_dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_dmg_pct")
        return self:GetStackCount() * bonus_dmg_pct
    end
    return 0
end

function modifier_bratishkin_r_debuff:OnTooltip()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_dmg_pct")
end

function modifier_bratishkin_r_debuff:GetTexture()
    return "bratishkin_r"
end