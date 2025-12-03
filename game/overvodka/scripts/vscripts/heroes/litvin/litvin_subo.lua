litvin_subo = class({})

function litvin_subo:Precache(context)
    PrecacheResource( "soundfile", "soundevents/subo.vsndevts", context )
    PrecacheResource( "particle", "particles/subo_dance.vpcf", context )
    PrecacheResource( "particle", "particles/subo_dance_start.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/enchantress/enchantress_2022_immortal/enchantress_2022_immortal_untouchable_base.vpcf", context)
    PrecacheUnitByNameSync("npc_subo", context)
end

function litvin_subo:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local subo = CreateUnitByName("npc_subo", point, true, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(subo, point, true)
    subo:SetControllableByPlayer(caster:GetPlayerID(), false)
    subo:SetOwner(caster)
    subo:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    if caster:HasTalent("special_bonus_unique_litvin_5") then
        subo:AddNewModifier(caster, self, "modifier_magic_immune", {})
    end
    subo:SetBaseMaxHealth(base_hp)
    subo:SetMaxHealth(base_hp)
    subo:SetHealth(base_hp)
    subo:SetMaximumGoldBounty(gold)
    subo:SetMinimumGoldBounty(gold)
    subo:SetDeathXP(xp)
    local dance = subo:FindAbilityByName("subo_dance")
    if dance then
        dance:SetLevel(self:GetLevel())
    end
    EmitSoundOn("subo", caster)
end


LinkLuaModifier("modifier_subo_dance", "heroes/litvin/litvin_subo", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_subo_dance_debuff", "heroes/litvin/litvin_subo", LUA_MODIFIER_MOTION_NONE )

subo_dance = class({})

function subo_dance:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_subo_dance", {duration = self:GetSpecialValueFor("duration")})
    if not global_sounds_muted then
        self:GetCaster():EmitSound("subo_dance_"..RandomInt(1,2))
    end
    self:GetCaster():GetOwner():StopSound("subo")
    local p = ParticleManager:CreateParticle("particles/subo_dance_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(p)
end

modifier_subo_dance = class({})

function modifier_subo_dance:IsHidden() return false end
function modifier_subo_dance:IsPurgable() return false end

function modifier_subo_dance:OnCreated()
    local parent = self:GetParent()
    if not IsServer() then return end
    local smash = parent:FindAbilityByName("ogre_bruiser_ogre_smash")
    if smash then
        smash:SetActivated(false)
    end
    local p = ParticleManager:CreateParticle("particles/subo_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 1, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 2, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 3, parent:GetAbsOrigin())
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_subo_dance:OnDestroy()
    if not IsServer() then return end
    local smash = self:GetParent():FindAbilityByName("ogre_bruiser_ogre_smash")
    if smash then
        smash:SetActivated(true)
    end
end

function modifier_subo_dance:IsAura() return true end

function modifier_subo_dance:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_subo_dance:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_subo_dance:GetModifierAura()
    return "modifier_subo_dance_debuff"
end

function modifier_subo_dance:GetAuraDuration()
    return 0.25
end

function modifier_subo_dance:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_subo_dance:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_subo_dance:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

modifier_subo_dance_debuff = class({})

function modifier_subo_dance_debuff:GetEffectName()
    return "particles/econ/items/enchantress/enchantress_2022_immortal/enchantress_2022_immortal_untouchable_base.vpcf"
end

function modifier_subo_dance_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_subo_dance_debuff:IsHidden() return false end
function modifier_subo_dance_debuff:IsPurgable() return false end

function modifier_subo_dance_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_subo_dance_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("slow_as")
end

function modifier_subo_dance_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_ms")
end
