LinkLuaModifier("modifier_bratishkin_r_debuff", "heroes/bratishkin/bratishkin_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_r_shard", "heroes/bratishkin/bratishkin_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_r_buff", "heroes/bratishkin/bratishkin_r", LUA_MODIFIER_MOTION_NONE)
bratishkin_r = class({})
t = 0
function bratishkin_r:Precache(context)
    PrecacheResource("particle", "particles/bratishkin_r.vpcf", context)
    PrecacheResource("soundfile", "soundevents/bratishkin_r_1.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/bratishkin_r_2.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/bratishkin_r_3.vsndevts", context)
end

function bratishkin_r:GetIntrinsicModifierName()
    return "modifier_bratishkin_r_shard"
end

function bratishkin_r:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    if not caster:HasModifier("modifier_bratishkin_r_buff") then
        caster:AddNewModifier(caster, self, "modifier_bratishkin_r_buff", {duration = -1})
    end
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
end

modifier_bratishkin_r_buff = class({})
function modifier_bratishkin_r_buff:IsHidden() return true end
function modifier_bratishkin_r_buff:IsPurgable() return false end
function modifier_bratishkin_r_buff:RemoveOnDeath() return false end
function modifier_bratishkin_r_buff:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_bratishkin_r_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    }
end

function modifier_bratishkin_r_buff:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
        local modifier = params.target:FindModifierByNameAndCaster("modifier_bratishkin_r_debuff", self:GetParent())
        if modifier and modifier:GetStackCount() > 0 then
            self.record = params.record
            local bonus_dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_dmg_pct") or 4
            return modifier:GetStackCount() * bonus_dmg_pct + 100
        end
	end
end

function modifier_bratishkin_r_buff:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self.record then
			self.record = nil
		end
	end
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
        if t == 0 then
            EmitSoundOn("bratishkin_r_1", parent)
            t = 1
        elseif t == 1 then
            EmitSoundOn("bratishkin_r_2", parent)
            t = 2
        else
            EmitSoundOn("bratishkin_r_3", parent)
            t = 0
        end
    end
end

function modifier_bratishkin_r_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_bratishkin_r_debuff:OnTooltip()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_dmg_pct")
end

function modifier_bratishkin_r_debuff:GetTexture()
    return "bratishkin_r"
end


modifier_bratishkin_r_shard = class({})

function modifier_bratishkin_r_shard:IsHidden() return true end
function modifier_bratishkin_r_shard:IsPurgable() return false end
function modifier_bratishkin_r_shard:RemoveOnDeath() return false end

function modifier_bratishkin_r_shard:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_bratishkin_r_shard:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if not params.target or not params.target:IsHero() or params.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    if not self:GetParent():HasModifier("modifier_item_aghanims_shard") then return end
    self.attack_count = (self.attack_count or 0) + 1
    if self.attack_count >= self:GetAbility():GetSpecialValueFor("attacks_needed") then
        self.attack_count = self.attack_count - self:GetAbility():GetSpecialValueFor("attacks_needed")
        local caster = self:GetParent()
        local ability = self:GetAbility()
        local target = params.target
        local modifier = target:FindModifierByNameAndCaster("modifier_bratishkin_r_debuff", caster)
        local is_new = false
        if not modifier then
            modifier = target:AddNewModifier(caster, ability, "modifier_bratishkin_r_debuff", { duration = -1 })
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
    end
end
