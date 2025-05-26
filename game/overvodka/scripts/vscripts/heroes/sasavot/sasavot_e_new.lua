sasavot_e_new = class({})

LinkLuaModifier("modifier_sasavot_debuff", "heroes/sasavot/sasavot_e_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasavot_bonus_buff", "heroes/sasavot/sasavot_e_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magresist_sasavot", "heroes/sasavot/sasavot_e_new.lua", LUA_MODIFIER_MOTION_NONE)


function sasavot_e_new:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    self.cast_duration = self:GetSpecialValueFor("cast_duration")
    self.buffs_duration = self:GetSpecialValueFor("buffs_duration")
    self.hp_perc = self:GetSpecialValueFor("hp_perc")
    self.mp_perc = self:GetSpecialValueFor("mp_perc")
    self.magresist_duration_min = self:GetSpecialValueFor("magresist_duration_min")
    self.magresist_duration_max = self:GetSpecialValueFor("magresist_duration_max")
    self.interval = 0.5
    caster:AddNewModifier(caster, self, "modifier_sasavot_debuff", { duration = self.cast_duration })
end

function sasavot_e_new:OnChannelThink(flInterval)
    self.magresist_duration_min = self.magresist_duration_min + 0.03
end

function sasavot_e_new:OnChannelFinish(interrupted)
    local caster = self:GetCaster() 
    caster:RemoveModifierByName("modifier_sasavot_debuff")
    if interrupted then
        caster:AddNewModifier(caster, self, "modifier_sasavot_bonus_buff", { duration = self.buffs_duration })
        caster:AddNewModifier(
            caster,
            self,
            "modifier_magresist_sasavot",
            { duration = self.magresist_duration_min }
        )
        self:PlayEffects1()
    else
        local heal = self.hp_perc * caster:GetMaxHealth() * 0.01
        local mana = self.mp_perc * caster:GetMaxMana() * 0.01
        caster:Heal(heal, self)
        caster:GiveMana(mana)
        caster:AddNewModifier(caster, self, "modifier_sasavot_bonus_buff", { duration = self.buffs_duration })
        caster:AddNewModifier(
            caster,
            self,
            "modifier_magresist_sasavot",
            { duration = self.magresist_duration_max }
        )
        self:PlayEffects()
        EmitSoundOn("sasavot_dance_success", self:GetCaster())
    end
end
function sasavot_e_new:PlayEffects()
    self.nChannelFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green_mid.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end
function sasavot_e_new:PlayEffects1()
    self.nChannelFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end
random_chance = 0
modifier_sasavot_debuff = class({})

function modifier_sasavot_debuff:IsHidden() return true end
function modifier_sasavot_debuff:IsDebuff() return true end
function modifier_sasavot_debuff:IsPurgable() return false end

function modifier_sasavot_debuff:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_sasavot_debuff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_sasavot_debuff:OnCreated()
    random_chance = random_chance + 1
    if (random_chance % 2) == 1 then
        EmitSoundOn("sasavot_dance_1", self:GetCaster())
    else
        EmitSoundOn("sasavot_dance_2", self:GetCaster())
    end
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage_aoe")
    self:StartIntervalThink(0.5)
end
function modifier_sasavot_debuff:OnIntervalThink()
    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self:GetAbility():GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false) 

    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetParent(), damage = self.damage * 0.5, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    end
end
function modifier_sasavot_debuff:OnTakeDamage(keys)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if keys.unit == caster and keys.attacker:GetTeamNumber() ~= caster:GetTeamNumber() and keys.attacker:IsHero() and not keys.attacker:IsBuilding() then
        caster:InterruptChannel()
        StopSoundOn("sasavot_dance_1", self:GetCaster())
        StopSoundOn("sasavot_dance_2", self:GetCaster())
        EmitSoundOn("sasavot_dance_interrupt", self:GetCaster())
        caster:RemoveModifierByName("modifier_sasavot_debuff")
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_sasavot_bonus_buff", { duration = 5 })
    end
end
function modifier_sasavot_debuff:GetEffectName()
    return "particles/sasavot_e.vpcf"
end
function modifier_sasavot_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_sasavot_bonus_buff = class({})

function modifier_sasavot_bonus_buff:IsHidden() return false end
function modifier_sasavot_bonus_buff:IsDebuff() return false end
function modifier_sasavot_bonus_buff:IsPurgable() return false end

function modifier_sasavot_bonus_buff:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")

    if not IsServer() then return end
end

function modifier_sasavot_bonus_buff:OnRefresh()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")

    if not IsServer() then return end
end

function modifier_sasavot_bonus_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_sasavot_bonus_buff:GetModifierMoveSpeedBonus_Constant()
    return self.movespeed
end

function modifier_sasavot_bonus_buff:GetModifierPreAttack_BonusDamage()
    return self.damage
end

modifier_magresist_sasavot = class({})

function modifier_magresist_sasavot:IsPurgable()
    return false
end
function modifier_magresist_sasavot:OnCreated( kv )
end
function modifier_magresist_sasavot:OnRemoved()
end

function modifier_magresist_sasavot:CheckState()
    local state = {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }

    return state
end
function modifier_magresist_sasavot:GetEffectName()
    return "particles/black_king_bar_avatar_sasavot.vpcf"
end

function modifier_magresist_sasavot:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end