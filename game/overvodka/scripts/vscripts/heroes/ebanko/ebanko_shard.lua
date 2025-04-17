ebanko_shard = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

function ebanko_shard:Precache( context )
	PrecacheResource( "soundfile", "soundevents/fof.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/ya_tebya.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt.vpcf", context )
end

function ebanko_shard:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
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
		local knockback = target:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_knockback",
			{
				center_x = caster:GetAbsOrigin().x,
				center_y = caster:GetAbsOrigin().y,
				center_z = caster:GetAbsOrigin().z,
				duration = flight_dur,
				knockback_duration = flight_dur,
				knockback_distance = 1600,
				knockback_height = 150
			}
		)
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