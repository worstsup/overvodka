peterka_r = class({})
LinkLuaModifier( "modifier_peterka_r_thinker", "heroes/5opka/peterka_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_peterka_r", "heroes/5opka/peterka_r", LUA_MODIFIER_MOTION_NONE )

function peterka_r:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition() + Vector(10, 0, 0)
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
		if self:GetCaster():HasScepter() and not enemy:HasModifier("modifier_generic_stunned_lua") then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_peterka_r", {duration = self:GetSpecialValueFor("stun_dur")})
		end
	end
	if target:IsRealHero() then
		self:GetCaster():ModifyGold(self:GetSpecialValueFor("gold_per_hit"), false, 0)
	end
	return true
end


function peterka_r:PlayEffects()
	local particle_cast = "particles/peterka_r_cast.vpcf"
	local sound_cast = "5opka_r_"..RandomInt(1,2)
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
	EmitGlobalSound( sound_cast )
end
modifier_peterka_r = class({})
function modifier_peterka_r:IsHidden()
	return false
end
function modifier_peterka_r:IsDebuff()
	return true
end
function modifier_peterka_r:IsPurgable()
	return true
end
function modifier_peterka_r:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_peterka_r:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
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
		local splash_damage = self:GetAbility():GetSpecialValueFor( "damage" )
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
function modifier_peterka_r_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
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