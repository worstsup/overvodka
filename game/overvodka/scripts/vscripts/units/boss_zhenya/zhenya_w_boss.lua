LinkLuaModifier( "modifier_zhenya_w_boss", "units/boss_zhenya/zhenya_w_boss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_w_boss_buff", "units/boss_zhenya/zhenya_w_boss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_w_boss_enemy_aura", "units/boss_zhenya/zhenya_w_boss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_w_boss_enemy_debuff", "units/boss_zhenya/zhenya_w_boss", LUA_MODIFIER_MOTION_NONE )

zhenya_w_boss = class({})

function zhenya_w_boss:Precache(context)
    PrecacheResource("model", "models/burgers/burgers.vmdl", context)
    PrecacheResource("particle", "particles/zhenya_w.vpcf", context)
    PrecacheResource("soundfile", "soundevents/zhenya_w.vsndevts", context)
end

function zhenya_w_boss:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function zhenya_w_boss:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local burger = CreateUnitByName("npc_burger", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    burger:SetOwner(caster)
    burger:SetMaximumGoldBounty(200)
    burger:SetMinimumGoldBounty(200)
    burger:SetDeathXP(200)
    burger:SetModelScale(1.6)
    burger:AddNewModifier(caster, self, "modifier_zhenya_w_boss", {})
    burger:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    burger:AddNewModifier(caster, self, "modifier_zhenya_w_boss_enemy_aura", {})
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "zhenya_w_start", caster)
end

modifier_zhenya_w_boss = class({})

function modifier_zhenya_w_boss:IsHidden() return true end
function modifier_zhenya_w_boss:IsPurgable() return false end

function modifier_zhenya_w_boss:OnCreated()
    if not IsServer() then return end
    local base_hp = self:GetAbility():GetSpecialValueFor("base_hp")
    self:GetParent():SetBaseMaxHealth(base_hp)
    self:GetParent():SetMaxHealth(base_hp)
    self:GetParent():SetHealth(base_hp)
    EmitSoundOn("zhenya_w_loop", self:GetParent())
    local fx = ParticleManager:CreateParticle("particles/zhenya_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(fx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
    self:AddParticle(fx, false, false, -1, false, false)
end

function modifier_zhenya_w_boss:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("zhenya_w_loop", self:GetParent())
    UTIL_Remove(self:GetParent())
end

function modifier_zhenya_w_boss:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE]      = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_zhenya_w_boss:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
end

function modifier_zhenya_w_boss:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - 1
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_zhenya_w_boss:GetDisableHealing()
    return 1
end

function modifier_zhenya_w_boss:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_zhenya_w_boss:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_zhenya_w_boss:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_zhenya_w_boss:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_zhenya_w_boss:IsAura() return true end
function modifier_zhenya_w_boss:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_zhenya_w_boss:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_zhenya_w_boss:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_zhenya_w_boss:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_zhenya_w_boss:GetModifierAura() return "modifier_zhenya_w_boss_buff" end
function modifier_zhenya_w_boss:GetAuraDuration() return 0 end

modifier_zhenya_w_boss_buff = class({})

function modifier_zhenya_w_boss_buff:IsHidden() return false end
function modifier_zhenya_w_boss_buff:IsPurgable() return true end
function modifier_zhenya_w_boss_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_zhenya_w_boss_buff:OnCreated()
    self.heal_pct = self:GetAbility():GetSpecialValueFor("heal_pct")
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_zhenya_w_boss_buff:OnIntervalThink()
    local parent = self:GetParent()
    local auraCaster = self:GetAuraOwner()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    if (parent:GetAbsOrigin() - auraCaster:GetAbsOrigin()):Length2D() <= radius then
        local heal = math.floor(parent:GetMaxHealth() * self.heal_pct * 0.01)
        parent:HealWithParams(heal, self:GetAbility(), false, true, parent, false)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, parent)
    end
end

modifier_zhenya_w_boss_enemy_aura = class({})

function modifier_zhenya_w_boss_enemy_aura:IsHidden() return true end
function modifier_zhenya_w_boss_enemy_aura:IsPurgable() return false end

function modifier_zhenya_w_boss_enemy_aura:IsAura() return true end
function modifier_zhenya_w_boss_enemy_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_zhenya_w_boss_enemy_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_zhenya_w_boss_enemy_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_zhenya_w_boss_enemy_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_zhenya_w_boss_enemy_aura:GetModifierAura() return "modifier_zhenya_w_boss_enemy_debuff" end
function modifier_zhenya_w_boss_enemy_aura:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("aura_duration") end

modifier_zhenya_w_boss_enemy_debuff = class({})

function modifier_zhenya_w_boss_enemy_debuff:IsHidden() return false end
function modifier_zhenya_w_boss_enemy_debuff:IsDebuff() return true end
function modifier_zhenya_w_boss_enemy_debuff:IsPurgable() return true end
function modifier_zhenya_w_boss_enemy_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_zhenya_w_boss_enemy_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_zhenya_w_boss_enemy_debuff:OnIntervalThink()
    local parent = self:GetParent()
    local auraCaster = self:GetAuraOwner()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    if (parent:GetAbsOrigin() - auraCaster:GetAbsOrigin()):Length2D() <= radius then
        self:IncrementStackCount()
        parent:CalculateStatBonus(true)
    end
end

function modifier_zhenya_w_boss_enemy_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_zhenya_w_boss_enemy_debuff:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("strength_loss") * self:GetStackCount()
end
