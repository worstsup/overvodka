sasavot_e_new = class({})

LinkLuaModifier("modifier_sasavot_debuff", "sasavot_e_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasavot_bonus_buff", "sasavot_e_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magresist_sasavot", "sasavot_e_new.lua", LUA_MODIFIER_MOTION_NONE)


function sasavot_e_new:OnSpellStart()
    local caster = self:GetCaster()
    self.cast_duration = self:GetSpecialValueFor("cast_duration")
    self.buffs_duration = self:GetSpecialValueFor("buffs_duration")
    self.hp_perc = self:GetSpecialValueFor("hp_perc")
    self.mp_perc = self:GetSpecialValueFor("mp_perc")
    self.magresist_duration = self:GetSpecialValueFor("magresist_duration")
    caster:AddNewModifier(caster, self, "modifier_sasavot_debuff", { duration = self.cast_duration })
end

function sasavot_e_new:OnChannelFinish(interrupted)
    local caster = self:GetCaster() 
    caster:RemoveModifierByName("modifier_sasavot_debuff")
    if interrupted then
        caster:AddNewModifier(caster, self, "modifier_sasavot_bonus_buff", { duration = self.buffs_duration })
        self:PlayEffects1()
    else
        local heal = self.hp_perc * caster:GetMaxHealth() * 0.01
        local mana = self.mp_perc * caster:GetMaxMana() * 0.01
        caster:Heal(heal, self)
        caster:GiveMana(mana)
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_magresist_sasavot", -- modifier name
            { duration = self.magresist_duration } -- kv
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
    local random_chance = RandomInt(1, 2)
    if random_chance == 1 then
        EmitSoundOn("sasavot_dance_1", self:GetCaster())
    elseif random_chance == 2 then
        EmitSoundOn("sasavot_dance_2", self:GetCaster())
    end
    if not IsServer() then return end
end

function modifier_sasavot_debuff:OnTakeDamage(keys)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if keys.unit == caster and keys.attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
        caster:InterruptChannel()
        StopSoundOn("sasavot_dance_1", self:GetCaster())
        StopSoundOn("sasavot_dance_2", self:GetCaster())
        EmitSoundOn("sasavot_dance_interrupt", self:GetCaster())
        caster:RemoveModifierByName("modifier_sasavot_debuff")
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_sasavot_bonus_buff", { duration = 5 })
    end
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
--------------------------------------------------------------------------------
function modifier_magresist_sasavot:IsPurgable()
    return false
end

function modifier_magresist_sasavot:OnCreated( kv )
end

--------------------------------------------------------------------------------

function modifier_magresist_sasavot:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_magresist_sasavot:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }

    return state
end
function modifier_magresist_sasavot:GetEffectName()
    return "particles/black_king_bar_avatar_sasavot.vpcf"
end

function modifier_magresist_sasavot:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end