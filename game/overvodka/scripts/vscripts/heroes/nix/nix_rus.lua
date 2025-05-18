nix_rus = class({})
LinkLuaModifier( "modifier_nix_rus", "heroes/nix/nix_rus", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nix_rus_debuff", "heroes/nix/nix_rus", LUA_MODIFIER_MOTION_NONE )

function nix_rus:Precache(context)
	PrecacheResource("particle", "particles/nix_r.vpcf", context)
	PrecacheResource("soundfile", "soundevents/nix_rus.vsndevts", context )
	PrecacheResource("particle", "particles/units/heroes/hero_oracle/oracle_fatesedict_disarm_ovrhead.vpcf", context)
end

function nix_rus:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "nix_rus", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_nix_rus", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_nix_rus = class({})

function modifier_nix_rus:IsPurgable()
	return false
end

function modifier_nix_rus:OnCreated()
	if not IsServer() then return end
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.dps = self:GetAbility():GetSpecialValueFor( "dps" )
	self.interval = 0.5
	self:StartIntervalThink(self.interval)
	self:OnIntervalThink()
    local particle = ParticleManager:CreateParticle("particles/nix_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius + 25, self.radius + 25, self.radius + 25))
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_nix_rus:OnRemoved()
end

function modifier_nix_rus:OnIntervalThink()
	if IsServer() then
		local damage = self.dps * self.interval
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			0,
			false
		)
		for _,unit in pairs(enemies) do
			ApplyDamage({ victim = unit, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
		end
	end
end

function modifier_nix_rus:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end

function modifier_nix_rus:GetModifierModelScale()
	return self.model_scale
end

function modifier_nix_rus:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_nix_rus:IsAura() return true end

function modifier_nix_rus:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_nix_rus:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_nix_rus:GetModifierAura()
    return "modifier_nix_rus_debuff"
end

function modifier_nix_rus:GetAuraDuration()
    return 0.5
end

function modifier_nix_rus:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_nix_rus_debuff = class({})

function modifier_nix_rus_debuff:IsHidden()
	return false
end

function modifier_nix_rus_debuff:IsDebuff()
	return true
end

function modifier_nix_rus_debuff:IsStunDebuff()
	return false
end

function modifier_nix_rus_debuff:IsPurgable()
	return false
end

function modifier_nix_rus_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.lose_strength = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_loss") * 0.01
	self.scepter = self:GetCaster():HasScepter()
	if self.scepter then
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_oracle/oracle_fatesedict_disarm_ovrhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		self:AddParticle( effect_cast, false, false, -1, false, false )
	end
end

function modifier_nix_rus_debuff:OnRefresh( kv )
	self.lose_strength = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_loss") * 0.01
end

function modifier_nix_rus_debuff:OnRemoved()
end

function modifier_nix_rus_debuff:OnDestroy()
end

function modifier_nix_rus_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_nix_rus_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = self.scepter,
	}
	return state
end

function modifier_nix_rus_debuff:GetModifierBonusStats_Strength()
	return self.lose_strength
end

function modifier_nix_rus_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor( "as_loss" )
end

function modifier_nix_rus_debuff:GetModifierModelScale()
	return -30
end

function modifier_nix_rus_debuff:GetEffectName()
	return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_nix_rus_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end