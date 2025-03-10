LinkLuaModifier("modifier_sans_innate", "heroes/sans/sans_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_innate_debuff", "heroes/sans/sans_innate", LUA_MODIFIER_MOTION_NONE)

sans_innate = class({})
function sans_innate:Precache(context)
	PrecacheResource("particle", "particles/sans_innate_debuff.vpcf", context)
end
function sans_innate:GetIntrinsicModifierName()
    return "modifier_sans_innate"
end
function sans_innate:GetAbilityTextureName()
	return "sans_innate"
end
modifier_sans_innate = class({})

function modifier_sans_innate:IsHidden() return true end
function modifier_sans_innate:IsPermanent() return true end

function modifier_sans_innate:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_sans_innate:OnTakeDamage(keys)
    if IsServer() then
        if self:GetParent():PassivesDisabled() then return end
        if keys.attacker == self:GetParent() and
           keys.unit ~= self:GetParent() and
           keys.damage > 0 and
           keys.inflictor ~= self:GetAbility() then
            local victim = keys.unit
            local damage = keys.damage
            local debuff = victim:FindModifierByName("modifier_sans_innate_debuff")
            local is_new = false
            local duration = self:GetAbility():GetSpecialValueFor("dur_tooltip")
            local damage_pct = self:GetAbility():GetSpecialValueFor("pct_tooltip") * 0.01
            if not debuff then
                debuff = victim:AddNewModifier(
                    self:GetParent(),
                    self:GetAbility(),
                    "modifier_sans_innate_debuff",
                    { duration = duration }
                )
                is_new = true
            end

            if debuff then
                local remaining_time = is_new and duration or debuff:GetRemainingTime()
                local carried_damage = debuff.damage_per_second * remaining_time
                debuff.total_damage = carried_damage + (damage * damage_pct)
                debuff:ForceRefresh()
                debuff:SetDuration(duration, true)
                debuff.damage_per_second = debuff.total_damage / duration
                debuff:SetStackCount(math.floor(debuff.total_damage + 0.5))
            end
        end
    end
end

modifier_sans_innate_debuff = class({})

function modifier_sans_innate_debuff:OnCreated()
    if IsServer() then
        self.total_damage = 0
        self.damage_per_second = 0
        self:StartIntervalThink(1.0)
    end
end

function modifier_sans_innate_debuff:OnIntervalThink()
    if IsServer() then
        if self.total_damage <= 1 then
            self:Destroy()
            return
        end

        local damage_to_deal = math.min(self.damage_per_second, self.total_damage)
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage_to_deal,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION,
            ability = self:GetAbility()
        })

        self.total_damage = self.total_damage - damage_to_deal
        self:SetStackCount(math.floor(self.total_damage + 0.5))
    end
end

function modifier_sans_innate_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end
function modifier_sans_innate_debuff:GetTexture()
	return "sans_innate"
end
function modifier_sans_innate_debuff:IsDebuff() return true end
function modifier_sans_innate_debuff:IsPurgable() return false end

function modifier_sans_innate_debuff:GetEffectName()
    return "particles/sans_innate_debuff.vpcf"
end