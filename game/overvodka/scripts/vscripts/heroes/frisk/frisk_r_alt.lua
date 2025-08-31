LinkLuaModifier("modifier_frisk_r_alt_buff", "heroes/frisk/frisk_r_alt", LUA_MODIFIER_MOTION_NONE)

frisk_r_alt = class({})

function frisk_r_alt:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf", ctx)
end

function frisk_r_alt:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not target or target:IsNull() then return end

    local debuff_count = 0
    for _,m in pairs(target:FindAllModifiers() or {}) do
        if m and not m:IsNull() and m.IsDebuff and m:IsDebuff() then
            debuff_count = debuff_count + 1
        end
    end

    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, "modifier_frisk_r_alt_buff", {
        duration = duration,
        debuffs  = debuff_count
    })

    EmitSoundOn("frisk_r_alt", target)
end

modifier_frisk_r_alt_buff = class({})

function modifier_frisk_r_alt_buff:IsPurgable() return false end
function modifier_frisk_r_alt_buff:IsBuff()     return true  end

function modifier_frisk_r_alt_buff:OnCreated(kv)
    local ability = self:GetAbility()
    self.debuffs = (kv and kv.debuffs) or 0

    if kv and kv.override == 1 then
        self.magic_res   = tonumber(kv.magic_res) or 60
        local base_str   = tonumber(kv.base_str)  or 0
        local base_regen = tonumber(kv.base_reg)  or 0
        local per_eff    = tonumber(kv.per_eff)   or 0
        self.bonus_str   = base_str   + per_eff * self.debuffs
        self.bonus_regen = base_regen + per_eff * self.debuffs
        return
    end

    self.magic_res = (ability and ability:GetSpecialValueFor("magic_resist_pct")) or 60
    local base_str   = (ability and ability:GetSpecialValueFor("bonus_str"))     or 0
    local base_regen = (ability and ability:GetSpecialValueFor("bonus_hpregen")) or 0
    local per_eff    = (ability and ability:GetSpecialValueFor("bonus_per_effect")) or 0
    self.bonus_str   = base_str   + per_eff * self.debuffs
    self.bonus_regen = base_regen + per_eff * self.debuffs
end

function modifier_frisk_r_alt_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_frisk_r_alt_buff:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

function modifier_frisk_r_alt_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_frisk_r_alt_buff:GetModifierMagicalResistanceBonus()
    return self.magic_res or 60
end

function modifier_frisk_r_alt_buff:GetModifierBonusStats_Strength()
    return self.bonus_str or 0
end

function modifier_frisk_r_alt_buff:GetModifierConstantHealthRegen()
    return self.bonus_regen or 0
end

function modifier_frisk_r_alt_buff:CheckState()
    return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
end
