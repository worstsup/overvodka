peacemaker_q = class({})

function peacemaker_q:Precache(ctx)
    PrecacheResource( "particle", "particles/peacemaker_q.vpcf", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", ctx )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lina.vsndevts", ctx )
end

function peacemaker_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	if target then
		point = target:GetAbsOrigin()
	end

	local direction = point-caster:GetAbsOrigin()
	direction.z = 0
	local projectile_direction = direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = "particles/peacemaker_q.vpcf",
	    fDistance = self:GetSpecialValueFor( "distance" ),
	    fStartRadius = self:GetSpecialValueFor( "width_initial" ),
	    fEndRadius = self:GetSpecialValueFor( "width_end" ),
		vVelocity = projectile_direction * self:GetSpecialValueFor( "speed" ),

		bProvidesVision = true,
        iVisionRadius = 300,
        iVisionTeamNumber = caster:GetTeamNumber(),
	}
	ProjectileManager:CreateLinearProjectile(info)

	EmitSoundOn( "Hero_Lina.DragonSlave.Cast", self:GetCaster() )
	EmitSoundOn( "Hero_Lina.DragonSlave", self:GetCaster() )
end

function peacemaker_q:OnProjectileHitHandle( target, location, projectile )
	if not target then return end

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor( "damage" ),
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}
	ApplyDamage( damageTable )

	local direction = ProjectileManager:GetLinearProjectileVelocity( projectile )
	direction.z = 0
	direction = direction:Normalized()

	local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlForward( p, 1, direction )
	ParticleManager:ReleaseParticleIndex( p )
end