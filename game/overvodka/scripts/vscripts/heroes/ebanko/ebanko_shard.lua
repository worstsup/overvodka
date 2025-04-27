ebanko_shard = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_vector_target", "modifier_generic_vector_target", LUA_MODIFIER_MOTION_NONE )
function ebanko_shard:Precache( context )
	PrecacheResource( "soundfile", "soundevents/fof.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/ya_tebya.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt.vpcf", context )
end

function ebanko_shard:Spawn()
	if not IsServer() then
		CustomIndicator:RegisterAbility( self )
		return
	end
end

function ebanko_shard:GetIntrinsicModifierName()
	return "modifier_generic_vector_target"
end
function ebanko_shard:CreateCustomIndicator( position, unit, behavior )
	if behavior~=DOTA_CLICK_BEHAVIOR_VECTOR_CAST then return end
	local caster = self:GetCaster()
	local cone_radius = 125
	if unit then
		self.is_primary_unit = true
		self.client_vector_target = unit
	else
		self.is_primary_unit = false
		self.client_vector_target = position or self:GetCaster():GetAbsOrigin()
	end
	local particle_cast = "particles/ui_mouseactions/range_finder_cone.vpcf"
	self.indicator = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( self.indicator, 3, Vector( cone_radius, cone_radius, 0 ) )
	ParticleManager:SetParticleControl( self.indicator, 4, Vector( 0, 255, 0 ) )
	ParticleManager:SetParticleControl( self.indicator, 6, Vector( 1, 0, 0 ) )
	self:UpdateCustomIndicator( position, unit, behavior )
end

function ebanko_shard:UpdateCustomIndicator( position, unit, behavior )
	if behavior~=DOTA_CLICK_BEHAVIOR_VECTOR_CAST then return end
	local ricochet_range = self:GetSpecialValueFor( "knockback_distance" )
	local origin_pos = self.client_vector_target
	if self.is_primary_unit then
		origin_pos = self.client_vector_target:GetAbsOrigin()
	end

	local direction = position - origin_pos
	direction.z = 0
	direction = direction:Normalized()

	local end_pos = origin_pos + direction * ricochet_range

	ParticleManager:SetParticleControl( self.indicator, 1, origin_pos )
	ParticleManager:SetParticleControl( self.indicator, 2, end_pos )
end

function ebanko_shard:DestroyCustomIndicator( position, unit, behavior )
	if behavior~=DOTA_CLICK_BEHAVIOR_VECTOR_CAST then return end
	self.is_primary_unit = nil
	self.client_vector_target  = nil
	ParticleManager:DestroyParticle(self.indicator, false)
	ParticleManager:ReleaseParticleIndex(self.indicator)
	self.indicator = nil
end

function ebanko_shard:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local vector_point = self.vector_position or caster:GetAbsOrigin()
	local direction = vector_point - target:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()
	if target:TriggerSpellAbsorb( self ) then
		return
	end
	local duration = self:GetSpecialValueFor( "stun_duration" )
	local flight_dur = duration - 1.0
	local damage = self:GetSpecialValueFor( "damage" )
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, 
	}
	ApplyDamage( damageTable )
	if not target:IsDebuffImmune() and not target:IsMagicImmune() then
		local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = flight_dur, distance = 1600, height = 150, direction_x = direction.x, direction_y = direction.y })
		target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = duration })
	end
	self:PlayEffects1( target )
end

--------------------------------------------------------------------------------

function ebanko_shard:PlayEffects1( target )
	local particle_cast = "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	EmitSoundOn( "fof", target )
	EmitSoundOn( "ya_tebya", target )
end