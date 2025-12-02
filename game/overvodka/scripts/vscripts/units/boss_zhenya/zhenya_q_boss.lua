LinkLuaModifier("modifier_zhenya_q_boss_caster", "units/boss_zhenya/zhenya_q_boss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zhenya_q_boss_debuff", "units/boss_zhenya/zhenya_q_boss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zhenya_q_boss_scepter", "units/boss_zhenya/zhenya_q_boss", LUA_MODIFIER_MOTION_NONE)

zhenya_q_boss = class({})

function zhenya_q_boss:Precache(context)
    PrecacheResource("particle", "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_gold.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_gold_shard.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/zhenya_w.vsndevts", context)
end

function zhenya_q_boss:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("Hero_Pugna.NetherWard")
    EmitSoundOn("zhenya_q", caster)
    caster:AddNewModifier(caster, self, "modifier_zhenya_q_boss_caster", { duration = duration })
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if enemy and enemy:IsAlive() then
            enemy:AddNewModifier(enemy, self, "modifier_zhenya_q_boss_scepter", {duration = self:GetSpecialValueFor("root_duration") * (1 - enemy:GetStatusResistance())})
        end
    end
end

modifier_zhenya_q_boss_caster = class({})

function modifier_zhenya_q_boss_caster:IsHidden()           return false end
function modifier_zhenya_q_boss_caster:IsPurgable()         return false end
function modifier_zhenya_q_boss_caster:IsAura()             return true end
function modifier_zhenya_q_boss_caster:GetAuraRadius()      return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_zhenya_q_boss_caster:GetAuraSearchTeam()  return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_zhenya_q_boss_caster:GetAuraSearchType()  return DOTA_UNIT_TARGET_HERO end
function modifier_zhenya_q_boss_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE end
function modifier_zhenya_q_boss_caster:GetModifierAura()    return "modifier_zhenya_q_boss_debuff" end

function modifier_zhenya_q_boss_caster:OnCreated()
    if not IsServer() then return end
    EmitSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetParent())
end

function modifier_zhenya_q_boss_caster:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    StopSoundOn("Hero_Pugna.LifeDrain.Loop", parent)
end

modifier_zhenya_q_boss_debuff = class({})

function modifier_zhenya_q_boss_debuff:IsHidden()    return false end
function modifier_zhenya_q_boss_debuff:IsDebuff()    return true  end
function modifier_zhenya_q_boss_debuff:IsPurgable()  return false end

function modifier_zhenya_q_boss_debuff:OnCreated()
    if not IsServer() then return end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.abil = self:GetAbility()
    self.interval = 0.25
    self.damage_pct = self.abil:GetSpecialValueFor("damage")
    self:StartIntervalThink(self.interval)
    local p = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(p, 0, self.caster,  PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
    EmitSoundOn("Hero_Pugna.LifeDrain.Target", self.parent)
end

function modifier_zhenya_q_boss_debuff:OnIntervalThink()
    if not IsServer() then return end
    if not self.caster or not self.caster:IsAlive() then
        return self:Destroy()
    end
    local radius = self.abil:GetSpecialValueFor("radius") + 100
    if (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D() > radius then
        return self:Destroy()
    end
    local dmg = self.parent:GetMaxHealth() * self.damage_pct * 0.01 * self.interval
    dmg = math.floor(dmg)
    if dmg > 0 then
        ApplyDamage({
            victim      = self.parent,
            attacker    = self.caster,
            damage      = dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability     = self.abil,
        })
        local heal = dmg * self:GetAbility():GetSpecialValueFor("heal_pct") * 0.01
        self.caster:Heal(heal, self.abil)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.caster, heal, nil)
    end
end

function modifier_zhenya_q_boss_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_zhenya_q_boss_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_zhenya_q_boss_debuff:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("Hero_Pugna.LifeDrain.Target", self.parent)
end

modifier_zhenya_q_boss_scepter = class({})
function modifier_zhenya_q_boss_scepter:IsHidden() return false end
function modifier_zhenya_q_boss_scepter:IsDebuff() return true end
function modifier_zhenya_q_boss_scepter:IsPurgable() return true end
function modifier_zhenya_q_boss_scepter:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
    }
end
function modifier_zhenya_q_boss_scepter:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble.vpcf"
end
function modifier_zhenya_q_boss_scepter:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end