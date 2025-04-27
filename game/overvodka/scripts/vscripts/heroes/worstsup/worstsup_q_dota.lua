worstsup_q_dota = class({})
LinkLuaModifier( "modifier_worstsup_q_dota_thinker", "heroes/worstsup/worstsup_q_dota", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_worstsup_q_dota_effect", "heroes/worstsup/worstsup_q_dota", LUA_MODIFIER_MOTION_NONE )

function worstsup_q_dota:Precache(context)
	PrecacheResource( "soundfile", "soundevents/stopan.vsndevts", context )
	PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_combined.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_chronosphere_combined_v2.vpcf", context )
end

function worstsup_q_dota:GetCooldown( level )
	return self.BaseClass.GetCooldown( self, level )
end
function worstsup_q_dota:OnAbilityPhaseStart()
	EmitSoundOn( "stopan", self:GetCaster() )
end
function worstsup_q_dota:OnAbilityPhaseInterrupted()
	StopSoundOn( "stopan", self:GetCaster() )
end

function worstsup_q_dota:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")
	local vision = self:GetSpecialValueFor("vision_radius")
	self.thinker = CreateModifierThinker(
		caster,
		self,
		"modifier_worstsup_q_dota_thinker",
		{ duration = duration },
		point,
		caster:GetTeamNumber(),
		false
	)
	self.thinker = self.thinker:FindModifierByName("modifier_worstsup_q_dota_thinker")
	AddFOWViewer( self:GetCaster():GetTeamNumber(), point, vision, duration, false)
end

modifier_worstsup_q_dota_effect = class({})

function modifier_worstsup_q_dota_effect:IsHidden()
	return false
end

function modifier_worstsup_q_dota_effect:IsDebuff()
	return not self:NotAffected()
end

function modifier_worstsup_q_dota_effect:IsStunDebuff()
	return not self:NotAffected()
end

function modifier_worstsup_q_dota_effect:IsPurgable()
	return false
end

function modifier_worstsup_q_dota_effect:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_worstsup_q_dota_effect:NotAffected()
	if self:GetParent()==self:GetCaster() then return true end
	if self:GetParent():GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end
end

function modifier_worstsup_q_dota_effect:OnCreated( kv )
	self.speed = 700
	self.as = self:GetAbility():GetSpecialValueFor( "as" )
	if IsServer() then
		if not self:NotAffected() then
			self:GetParent():InterruptMotionControllers( false )
		else
			self:PlayEffects()
		end
	end
end

function modifier_worstsup_q_dota_effect:OnRefresh( kv )
end
function modifier_worstsup_q_dota_effect:OnRemoved()
end
function modifier_worstsup_q_dota_effect:OnDestroy()
end

function modifier_worstsup_q_dota_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end
function modifier_worstsup_q_dota_effect:GetModifierAttackSpeedBonus_Constant()
	if self:NotAffected() then return self.as end
end

function modifier_worstsup_q_dota_effect:GetModifierMoveSpeed_AbsoluteMin()
	if self:NotAffected() then return self.speed end
end

function modifier_worstsup_q_dota_effect:CheckState()
	local state1 = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	local state2 = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	if self:NotAffected() then return state1 else return state2 end
end


function modifier_worstsup_q_dota_effect:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
	local particle_cast_2 = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_combined.vpcf"
	local effect_cast_2 = ParticleManager:CreateParticle( particle_cast_2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast_2, 1, Vector( 1000, 1000, 1000 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast_2 )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)

	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

modifier_worstsup_q_dota_thinker = class({})

function modifier_worstsup_q_dota_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_worstsup_q_dota_thinker:OnRefresh( kv )
	
end

function modifier_worstsup_q_dota_thinker:OnRemoved()
end

function modifier_worstsup_q_dota_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_worstsup_q_dota_thinker:CheckState()
	local state = {
		[MODIFIER_STATE_FROZEN] = true,
	}

	return state
end

function modifier_worstsup_q_dota_thinker:IsAura()
	return true
end

function modifier_worstsup_q_dota_thinker:GetModifierAura()
	return "modifier_worstsup_q_dota_effect"
end

function modifier_worstsup_q_dota_thinker:GetAuraRadius()
	return self.radius
end

function modifier_worstsup_q_dota_thinker:GetAuraDuration()
	return 0.01
end

function modifier_worstsup_q_dota_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_worstsup_q_dota_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_worstsup_q_dota_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_worstsup_q_dota_thinker:GetAuraEntityReject( hEntity )

	return false
end

function modifier_worstsup_q_dota_thinker:PlayEffects()
	local particle_cast = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_chronosphere_combined_v2.vpcf"
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end