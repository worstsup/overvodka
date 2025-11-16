silvername_q_facet_1 = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

function silvername_q_facet_1:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", ctx)
end 

function silvername_q_facet_1:OnSpellStart()
    if not IsServer() then return end
	local target = self:GetCursorTarget()

	local info = {
		Source = self:GetCaster(),
		Target = target,
		Ability = self,
		iMoveSpeed = self:GetSpecialValueFor("chaos_bolt_speed"),
		EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
		bDodgeable = true,
	}
	ProjectileManager:CreateTrackingProjectile( info )

	EmitSoundOn("Hero_ChaosKnight.ChaosBolt.Cast", self:GetCaster())
end

function silvername_q_facet_1:OnProjectileHit_ExtraData( hTarget, vLocation, kv )
    if not IsServer() then return end
	if hTarget==nil or hTarget:IsInvulnerable() then return end
	if hTarget:TriggerSpellAbsorb( self ) then return end

	local damage_min = self:GetSpecialValueFor("damage_min")
	local damage_max = self:GetSpecialValueFor("damage_max")
	local stun_min = self:GetSpecialValueFor("stun_min")
	local stun_max = self:GetSpecialValueFor("stun_max")

	local rand = math.random()
	local damage_act = self:Expand(rand,damage_min,damage_max)
	local stun_act = self:Expand(1-rand,stun_min,stun_max)

	hTarget:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_generic_stunned_lua",
		{ duration = stun_act }
	)

	self:PlayEffect2( hTarget, stun_act, damage_act )

    local damage = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = damage_act,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self
	}
	ApplyDamage( damage )
end

function silvername_q_facet_1:Expand( value, min, max )
	return (max-min)*value + min
end

function silvername_q_facet_1:PlayEffect2( target, stun, damage )
	local digit = 4
	if damage < 100 then digit = 3 end
	local digit1 = damage%10
	local digit2 = math.floor((damage%100)/10)
	local digit3 = math.floor((damage%1000)/100)
	local number = digit3*100 + digit2*10 + digit1

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
	ParticleManager:SetParticleControl( nFXIndex, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 0, number, 3 ) )
	ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 2, digit, 0 ) )
	ParticleManager:SetParticleControl( nFXIndex, 3, Vector( 0,	stun, 4 ) )
	ParticleManager:SetParticleControl( nFXIndex, 4, Vector( 2,	2, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_ChaosKnight.ChaosBolt.Impact", target )
end