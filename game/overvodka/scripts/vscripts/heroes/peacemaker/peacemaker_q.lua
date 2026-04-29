peacemaker_q = class({})

function peacemaker_q:Precache(ctx)
    PrecacheResource( "particle", "particles/peacemaker_q.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_windwalk.vpcf", ctx )
	PrecacheResource( "soundfile", "soundevents/peacemaker_sounds.vsndevts", ctx )
end

function peacemaker_q:GetAbilityDamageType()
    if self:GetCaster():HasAbility("peacemaker_deagle") then
        return DAMAGE_TYPE_PHYSICAL
	end
    return DAMAGE_TYPE_MAGICAL
end

function peacemaker_q:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("peacemaker_q_cast")
	return true
end

function peacemaker_q:OnAbilityPhaseInterrupted()
    self:GetCaster():StopSound("peacemaker_q_cast")
end

function peacemaker_q:GetBehavior()
	local additive = self:GetCaster():HasTalent("special_bonus_unique_peacemaker_5") and 1099511627776 or 0
    local behavior = self.BaseClass.GetBehavior(self)
    return tonumber(tostring(behavior)) + additive
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

	local distance = self:GetSpecialValueFor("distance")
    local speed    = self:GetSpecialValueFor("speed")

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = "particles/peacemaker_q.vpcf",
	    fDistance = distance,
	    fStartRadius = self:GetSpecialValueFor( "width_initial" ),
	    fEndRadius = self:GetSpecialValueFor( "width_end" ),
		vVelocity = projectile_direction * speed,

		bProvidesVision = true,
        iVisionRadius = 300,
        iVisionTeamNumber = caster:GetTeamNumber(),
	}
	ProjectileManager:CreateLinearProjectile(info)

	if caster:HasTalent("special_bonus_unique_peacemaker_5") and self:GetAltCastState() then
        local duration = distance / math.max(speed, 1)

        caster:AddNewModifier(
            caster,
            self,
            "modifier_generic_arc_lua",
            {
                dir_x = projectile_direction.x,
                dir_y = projectile_direction.y,

                distance = distance,
                duration = duration,
                speed    = speed,

                height       = 130,
                fix_height   = 1,
                fix_end      = 0,
                fix_duration = 1,

                isStun       = 1,
                isRestricted = 1,
                isForward    = 1,

                activity = ACT_DOTA_OVERRIDE_ABILITY_1,

                isInvulnerable = 1,
                isOutOfGame    = 1,
            }
        )
    end

	caster:EmitSound("peacemaker_q")
end

function peacemaker_q:OnProjectileHitHandle( target, location, projectile )
	if not target then return end

	if self:GetCaster():HasTalent("special_bonus_unique_peacemaker_3") then
		target:AddNewModifier(self:GetCaster(), self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor("stun_duration")})
	end

	local direction = ProjectileManager:GetLinearProjectileVelocity( projectile )
	direction.z = 0
	direction = direction:Normalized()

	local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_brewmaster/brewmaster_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( p, 0, target:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( p )

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor( "damage" ),
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}
	ApplyDamage( damageTable )
end