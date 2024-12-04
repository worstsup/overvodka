chillguy_q = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_chillguy_q_slow", "modifier_chillguy_q_slow", LUA_MODIFIER_MOTION_NONE )

function chillguy_q:OnSpellStart()
	local target = self:GetCursorTarget()
	local projectile_speed = self:GetSpecialValueFor("blast_speed")
	local projectile_name = "particles/skeletonking_hellfireblast_new.vpcf"
	local info = {
		EffectName = projectile_name,
		Ability = self,
		iMoveSpeed = projectile_speed,
		Source = self:GetCaster(),
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	}
	ProjectileManager:CreateTrackingProjectile( info )
	self:PlayEffects1()
end

function chillguy_q:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:IsMagicImmune() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		local stun_duration = self:GetSpecialValueFor( "blast_stun_duration" )
		local stun_damage = self:GetAbilityDamage()
		local dot_duration = self:GetSpecialValueFor( "blast_dot_duration" )
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = stun_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}
		ApplyDamage( damage )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = stun_duration } )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_chillguy_q_slow", { duration = dot_duration } )
		self:PlayEffects2( hTarget )
	end
	return true
end

function chillguy_q:PlayEffects1()
	local sound_cast = "vibes"
	EmitSoundOn( sound_cast, self:GetCaster() )
end
function chillguy_q:PlayEffects2( target )
	local sound_impact = "klonk"
	EmitSoundOn( sound_impact, target )
end