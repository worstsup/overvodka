LinkLuaModifier( "modifier_rivendare_lua", "heroes/silvername/silvername_rivendare", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rivendare_lua_debuff", "heroes/silvername/silvername_rivendare", LUA_MODIFIER_MOTION_NONE )

silvername_rivendare = class({})

function silvername_rivendare:Precache(context)
    PrecacheResource( "soundfile", "soundevents/baron.vsndevts", context )
    PrecacheResource( "model", "models/heroes/abaddon/abaddon.vmdl", context )
    PrecacheResource( "particle", "particles/doom_bringer_doom_new.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_beserkers_call.vpcf", context )
end

function silvername_rivendare:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function silvername_rivendare:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function silvername_rivendare:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function silvername_rivendare:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function silvername_rivendare:OnAbilityPhaseStart()
    EmitSoundOn("baron", self:GetCaster())
    return true
end

function silvername_rivendare:OnAbilityPhaseInterrupted()
    StopSoundOn("baron", self:GetCaster())
end

function silvername_rivendare:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local base_damage = self:GetSpecialValueFor("base_dmg")
    local rivendare = CreateUnitByName("npc_rivendare", point, true, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(rivendare, point, true)
    rivendare:SetControllableByPlayer(caster:GetPlayerID(), false)
    rivendare:SetOwner(caster)
    rivendare:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    rivendare:SetMaximumGoldBounty(gold)
    rivendare:SetMinimumGoldBounty(gold)
    rivendare:SetBaseMaxHealth(base_hp)
    rivendare:SetMaxHealth(base_hp)
    rivendare:SetBaseDamageMin(base_damage)
    rivendare:SetBaseDamageMax(base_damage)
    rivendare:SetHealth(base_hp)
    rivendare:SetDeathXP(xp)
    rivendare:AddNewModifier(self:GetCaster(), self, "modifier_rivendare_lua", {})
end

modifier_rivendare_lua = class({})

function modifier_rivendare_lua:IsHidden()
	return true
end

function modifier_rivendare_lua:IsDebuff()
	return false
end

function modifier_rivendare_lua:IsPurgable()
	return false
end

function modifier_rivendare_lua:OnCreated( kv )
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.health_increments = 1
	self.hero_attack_multiplier = 1
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_rivendare_lua:OnRefresh( kv )
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_rivendare_lua:OnDestroy( kv )
end

function modifier_rivendare_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end
function modifier_rivendare_lua:OnAttackLanded(keys)
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
        local new_health = self:GetParent():GetHealth() - self.health_increments
        if keys.attacker:IsRealHero() then
            new_health = self:GetParent():GetHealth() - (self.health_increments * self.hero_attack_multiplier)
        end
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_rivendare_lua:GetDisableHealing()
    return 1
end

function modifier_rivendare_lua:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_rivendare_lua:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_rivendare_lua:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_rivendare_lua:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_rivendare_lua:IsAura() return true end

function modifier_rivendare_lua:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_rivendare_lua:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_rivendare_lua:GetModifierAura()
    return "modifier_rivendare_lua_debuff"
end

function modifier_rivendare_lua:GetAuraDuration()
    return 0
end

function modifier_rivendare_lua:GetAuraRadius()
    if self:GetAbility() then
        if not self:GetParent():IsAlive() or self:GetParent():IsOutOfGame() or self:GetParent():IsInvisible() then return 0 end
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_rivendare_lua_debuff = class({})

function modifier_rivendare_lua_debuff:IsHidden()
	return false
end

function modifier_rivendare_lua_debuff:IsDebuff()
	return true
end

function modifier_rivendare_lua_debuff:IsStunDebuff()
	return false
end

function modifier_rivendare_lua_debuff:IsPurgable()
	return false
end

function modifier_rivendare_lua_debuff:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetAuraOwner() )
    self:GetParent():MoveToTargetToAttack( self:GetAuraOwner() )
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_rivendare_lua_debuff:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetAuraOwner():GetOwner()
    local parent = self:GetParent()
    if self:GetAuraOwner():GetOwner():HasTalent("special_bonus_unique_silvername_8") then
        local damage = caster:GetMaxHealth() * 8 * 0.01
        ApplyDamage({ attacker = caster, victim = parent, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() })
    end
end

function modifier_rivendare_lua_debuff:OnRefresh( kv )
end

function modifier_rivendare_lua_debuff:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_rivendare_lua_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_rivendare_lua_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
	}
	return state
end

function modifier_rivendare_lua_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end