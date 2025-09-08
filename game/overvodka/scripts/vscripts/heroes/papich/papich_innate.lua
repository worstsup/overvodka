LinkLuaModifier("modifier_papich_innate_ms",  "heroes/papich/papich_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_innate_amp", "heroes/papich/papich_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_innate_str", "heroes/papich/papich_innate", LUA_MODIFIER_MOTION_NONE)

papich_innate = class({})

function papich_innate:Precache(context)
    PrecacheResource("soundfile", "soundevents/papich_innate_1.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/papich_innate_2.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/papich_innate_3.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_impact_filler_smoke.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/sven/sven_ti10_helmet/sven_ti10_helmet_gods_strength.vpcf", context)
end

function papich_innate:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
	local heal_pct = self:GetSpecialValueFor("heal_pct")
	if heal_pct > 0 then
		local heal = caster:GetMaxHealth() * heal_pct * 0.01
		caster:HealWithParams(heal, self, false, true, caster, false)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, caster and caster:GetPlayerOwner())
	end
    self._cycle = (self._cycle or 0)
    local idx = self._cycle % 3
    self._cycle = self._cycle + 1

    if idx == 0 then
        caster:AddNewModifier(caster, self, "modifier_papich_innate_ms",  { duration = duration })
    elseif idx == 1 then
        caster:AddNewModifier(caster, self, "modifier_papich_innate_amp", { duration = duration })
    else
        caster:AddNewModifier(caster, self, "modifier_papich_innate_str", { duration = duration })
    end
end


modifier_papich_innate_ms = class({})

function modifier_papich_innate_ms:IsPurgable() return true end

function modifier_papich_innate_ms:OnCreated()
    if not IsServer() then return end
    EmitSoundOn("papich_innate_1", self:GetParent())
end

function modifier_papich_innate_ms:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_papich_innate_ms:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("ms")
end

function modifier_papich_innate_ms:GetEffectName()
    return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf"
end

function modifier_papich_innate_ms:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_papich_innate_amp = class({})

function modifier_papich_innate_amp:IsPurgable() return true end

function modifier_papich_innate_amp:OnCreated()
    if not IsServer() then return end
    EmitSoundOn("papich_innate_2", self:GetParent())
end

function modifier_papich_innate_amp:DeclareFunctions()
    return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_papich_innate_amp:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("base_amp") * self:GetParent():GetLevel()
end

function modifier_papich_innate_amp:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_impact_filler_smoke.vpcf"
end

function modifier_papich_innate_amp:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_papich_innate_str = class({})

function modifier_papich_innate_str:IsPurgable() return true end

function modifier_papich_innate_str:OnCreated()
    if not IsServer() then return end
    EmitSoundOn("papich_innate_3", self:GetParent())
end

function modifier_papich_innate_str:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_papich_innate_str:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("base_str") * self:GetParent():GetLevel()
end

function modifier_papich_innate_str:GetEffectName()
    return "particles/econ/items/sven/sven_ti10_helmet/sven_ti10_helmet_gods_strength.vpcf"
end

function modifier_papich_innate_str:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end