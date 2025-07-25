LinkLuaModifier( "modifier_speed_shake", "heroes/speed/speed_shake", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_speed_shake_scepter", "heroes/speed/speed_shake", LUA_MODIFIER_MOTION_NONE )

speed_shake = class({})

function speed_shake:Precache(context)
    PrecacheResource("particle", "particles/speed_r.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", context)
    PrecacheResource("soundfile", "soundevents/gennadiy_start.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/gennadiy.vsndevts", context)
end

function speed_shake:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function speed_shake:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function speed_shake:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function speed_shake:OnAbilityPhaseStart()
    EmitSoundOn("gennadiy_start", self:GetCaster())
    return true
end

function speed_shake:OnAbilityPhaseInterrupted()
    StopSoundOn("gennadiy_start", self:GetCaster())
end

function speed_shake:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("gennadiy")
    caster:AddNewModifier( caster, self, "modifier_speed_shake", { duration = duration } )
    if caster:HasScepter() then
        caster:AddNewModifier( caster, self, "modifier_speed_shake_scepter", { duration = duration } )
    end
end

modifier_speed_shake = class({})

function modifier_speed_shake:IsHidden()
    return false
end

function modifier_speed_shake:IsPurgable()
    return false
end

function modifier_speed_shake:OnCreated( kv )
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    self.spinner_damage_tick = self:GetAbility():GetSpecialValueFor("damage_tick")
    self.damage = self.damage * self.spinner_damage_tick

    self.damageTable = 
    {
        attacker = self:GetParent(),
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
    }

    self.particle = ParticleManager:CreateParticle( "particles/speed_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.particle, 5, Vector( radius + 60, 0, 0 ) )
    self:AddParticle( self.particle, false, false, -1, false, false )

    self:StartIntervalThink(self.spinner_damage_tick)
end

function modifier_speed_shake:OnDestroy( kv )
    if not IsServer() then return end
    self:GetParent():StopSound("gennadiy")
end

function modifier_speed_shake:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    for _,enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        self.damageTable.damage = self.damage + (self:GetCaster():GetIdealSpeed() * 0.01 * self:GetAbility():GetSpecialValueFor("dmg_scepter") * self.spinner_damage_tick)
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") * self.damage * 0.01
        self:GetCaster():Heal( heal, self:GetAbility() )
        SendOverheadEventMessage( self:GetCaster(), OVERHEAD_ALERT_HEAL, self:GetCaster(), heal, nil )
        local particle = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
        ParticleManager:SetParticleControl( particle, 0, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 1, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 2, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 3, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 4, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 5, enemy:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( particle )
        ApplyDamage( self.damageTable )
    end
end

function modifier_speed_shake:CheckState()
    local state = 
    {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
    return state
end

function modifier_speed_shake:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }
end

function modifier_speed_shake:GetModifierProcAttack_BonusDamage_Physical( params )
	return -params.damage
end

function modifier_speed_shake:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_5
end

function modifier_speed_shake:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist")
end

modifier_speed_shake_scepter = class({})

function modifier_speed_shake_scepter:IsHidden()
    return true
end
function modifier_speed_shake_scepter:IsPurgable()
    return false
end
function modifier_speed_shake_scepter:DeclareFunctions()
    return {MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT}
end

function modifier_speed_shake_scepter:GetModifierIgnoreMovespeedLimit()
    return 1
end