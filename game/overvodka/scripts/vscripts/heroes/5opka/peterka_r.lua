peterka_r = class({})
LinkLuaModifier( "modifier_peterka_r_thinker", "heroes/5opka/peterka_r", LUA_MODIFIER_MOTION_NONE )

function peterka_r:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	CreateModifierThinker(
		caster,
		self,
		"modifier_peterka_r_thinker",
		{},
		point,
		caster:GetTeamNumber(),
		false
	)
	self:PlayEffects()
end

function peterka_r:OnProjectileHit_ExtraData( target, location, extraData )
	if not target then return true end
	local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			location,
			nil,
			extraData.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0,
			0,
			false
		)
	local damageTable = {
		attacker = self:GetCaster(),
		damage = extraData.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, 
	}
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end
	self:GetCaster():ModifyGold(self:GetSpecialValueFor("gold_per_hit"), false, 0)
	return true
end


function peterka_r:PlayEffects()
	local particle_cast = "particles/peterka_r_cast.vpcf"
	local sound_cast = "5opka_r"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationForAllies( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end

modifier_peterka_r_thinker = class({})

function modifier_peterka_r_thinker:IsHidden()
	return true
end
function modifier_peterka_r_thinker:IsDebuff()
	return false
end
function modifier_peterka_r_thinker:IsPurgable()
	return false
end

function modifier_peterka_r_thinker:OnCreated( kv )
	if IsServer() then
		local duration = self:GetAbility():GetSpecialValueFor( "duration" )
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
		local speed = self:GetAbility():GetSpecialValueFor( "speed" )
		local distance = self:GetAbility():GetSpecialValueFor( "distance" )
		local machines_per_sec = self:GetAbility():GetSpecialValueFor( "machines_per_sec" )
		local collision_radius = self:GetAbility():GetSpecialValueFor( "collision_radius" )
		local splash_radius = self:GetAbility():GetSpecialValueFor( "splash_radius" )
		local splash_damage = self:GetAbility():GetAbilityDamage()
		local projectile_name = "particles/peterka_r.vpcf"
		local interval = 1/machines_per_sec
		local center = self:GetParent():GetOrigin()
		local direction = (center-self:GetCaster():GetOrigin())
		direction = Vector( direction.x, direction.y, 0 ):Normalized()
		self:GetParent():SetForwardVector( direction )
		self.spawn_vector = self:GetParent():GetRightVector()
		self.center_start = center - direction*self.radius
		self.projectile_info = {
			Source = self:GetCaster(),
			Ability = self:GetAbility(),
			
		    bDeleteOnHit = true,
		    
		    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		    
		    EffectName = projectile_name,
		    fDistance = distance,
		    fStartRadius = collision_radius,
		    fEndRadius = collision_radius,
			vVelocity = direction * speed,

			ExtraData = {
				radius = splash_radius,
				damage = splash_damage,
			}
		}
		self:SetDuration( duration, false )
		self:StartIntervalThink( interval )
		self:OnIntervalThink()
	end
end

function modifier_peterka_r_thinker:OnRefresh( kv )
end

function modifier_peterka_r_thinker:OnDestroy( kv )
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end


function modifier_peterka_r_thinker:OnIntervalThink()
	local spawn = self.center_start + self.spawn_vector*RandomInt( -self.radius, self.radius )
	self.projectile_info.vSpawnOrigin = spawn
	ProjectileManager:CreateLinearProjectile(self.projectile_info)
end