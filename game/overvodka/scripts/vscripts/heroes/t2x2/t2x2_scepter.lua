t2x2_scepter = class({})
LinkLuaModifier( "modifier_t2x2_scepter", "heroes/t2x2/t2x2_scepter", LUA_MODIFIER_MOTION_NONE )

function t2x2_scepter:Precache(context)
    PrecacheResource("soundfile", "soundevents/t2x2_sounds.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_muerta.vsndevts", context )
    PrecacheResource("particle", "particles/t2x2_scepter.vpcf", context )
    PrecacheResource("particle", "particles/t2x2_scepter_debuff.vpcf", context )
end

function t2x2_scepter:OnAbilityPhaseStart()
    EmitSoundOn("t2x2_scepter_cast", self:GetCaster())
    return true
end

function t2x2_scepter:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local point = self:GetCursorPosition()
    if point == origin then
        point = point + caster:GetForwardVector()
    end
	local projectile_name = "particles/t2x2_scepter.vpcf"
	local projectile_speed = self:GetSpecialValueFor("arrow_speed")
	local projectile_distance = self:GetSpecialValueFor("arrow_range")
	local projectile_start_radius = self:GetSpecialValueFor("arrow_width")
	local projectile_end_radius = self:GetSpecialValueFor("arrow_width")
	local projectile_vision = self:GetSpecialValueFor("arrow_vision")

	local min_damage = self:GetSpecialValueFor("damage")
	local bonus_damage = self:GetSpecialValueFor( "arrow_bonus_damage" )
	local min_stun = self:GetSpecialValueFor( "arrow_min_stun" )
	local max_stun = self:GetSpecialValueFor( "arrow_max_stun" )
	local max_distance = self:GetSpecialValueFor( "arrow_max_stunrange" )

	local projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin(),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius = projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = caster:GetTeamNumber(),

		ExtraData = {
			originX = origin.x,
			originY = origin.y,
			originZ = origin.z,

			max_distance = max_distance,
			min_stun = min_stun,
			max_stun = max_stun,

			min_damage = min_damage,
			bonus_damage = bonus_damage,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)
	EmitSoundOn( "t2x2_scepter_shoot", caster )
end

function t2x2_scepter:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
    if not IsServer() then return end
	if hTarget==nil then return end
	local origin = Vector( extraData.originX, extraData.originY, extraData.originZ )
	local distance = (vLocation-origin):Length2D()
	local bonus_pct = math.min(1,distance/extraData.max_distance)
	if (not hTarget:IsConsideredHero()) and (not hTarget:IsAncient()) then
		local damageTable = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = hTarget:GetHealth() + 1,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
		}
		ApplyDamage(damageTable)
		return true
	end

	local damageTable = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = extraData.min_damage + extraData.bonus_damage*bonus_pct,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	ApplyDamage(damageTable)
	hTarget:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_t2x2_scepter",
		{ duration = math.max(extraData.min_stun, extraData.max_stun*bonus_pct) * (1 - hTarget:GetStatusResistance()) }
	)
	AddFOWViewer( self:GetCaster():GetTeamNumber(), vLocation, 500, 3, false )
	EmitSoundOn( "Hero_Muerta.DeadShot.Ricochet.Impact", hTarget )
    EmitSoundOn( "Hero_Muerta.DeadShot.Fear", hTarget )
	return true
end

modifier_t2x2_scepter = class({})

function modifier_t2x2_scepter:IsHidden() return false end
function modifier_t2x2_scepter:IsPurgable() return false end
function modifier_t2x2_scepter:OnCreated()
    if not IsServer() then return end
end

function modifier_t2x2_scepter:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
	}
	return state
end

function modifier_t2x2_scepter:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_t2x2_scepter:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_t2x2_scepter:GetEffectName()
	return "particles/t2x2_scepter_debuff.vpcf"
end

function modifier_t2x2_scepter:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end