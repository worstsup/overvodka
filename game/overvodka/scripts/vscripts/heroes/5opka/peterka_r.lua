peterka_r = class({})
LinkLuaModifier( "modifier_peterka_r_thinker", "heroes/5opka/peterka_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_peterka_r_scepter", "heroes/5opka/peterka_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peterka_r_scepter_wave", "heroes/5opka/peterka_r", LUA_MODIFIER_MOTION_NONE)

function peterka_r:GetIntrinsicModifierName()
	return "modifier_peterka_r_scepter"
end

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

modifier_peterka_r_scepter = class({})

function modifier_peterka_r_scepter:IsHidden()       return true end
function modifier_peterka_r_scepter:IsPurgable()     return false end
function modifier_peterka_r_scepter:RemoveOnDeath()  return false end

function modifier_peterka_r_scepter:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_peterka_r_scepter:OnAbilityExecuted(params)
    if not IsServer() then return end
	if not self:GetParent():HasScepter() then return end
	if not params.target then return end
    local caster = self:GetParent()
	if params.target:GetTeamNumber() == caster:GetTeamNumber() then return end
    local ability = params.ability
    if params.unit ~= caster then return end
    if ability == self:GetAbility() or ability:IsToggle() or ability:IsPassive() then return end
    local pt = params.target:GetAbsOrigin()
    caster:AddNewModifier(caster, self:GetAbility(), "modifier_peterka_r_scepter_wave", {
        duration = self:GetAbility():GetSpecialValueFor("duration_scepter"),
        tx = pt.x,
        ty = pt.y,
    })
end

modifier_peterka_r_scepter_wave = class({})

function modifier_peterka_r_scepter_wave:IsHidden()    return true end
function modifier_peterka_r_scepter_wave:IsPurgable()  return false end

function modifier_peterka_r_scepter_wave:OnCreated(kv)
    if not IsServer() then return end
    local caster  = self:GetParent()
    local ability = self:GetAbility()
    self.origin = caster:GetAbsOrigin()
    
    self.speed           = ability:GetSpecialValueFor("speed")
    self.distance        = ability:GetSpecialValueFor("distance_scepter")
    self.collision_rad   = ability:GetSpecialValueFor("collision_radius")
    self.splash_radius   = ability:GetSpecialValueFor("radius_scepter")
    self.splash_damage   = ability:GetSpecialValueFor("damage")
    self.radius          = ability:GetSpecialValueFor("radius_scepter")
    
    local machines_per_sec = 18
    self.interval = 1 / machines_per_sec
    local tx = kv.tx or caster:GetAbsOrigin().x
    local ty = kv.ty or caster:GetAbsOrigin().y
    local targetPt = Vector(tx, ty, 0)
    local dir = (targetPt - caster:GetAbsOrigin())
    dir.z = 0
    self.direction = dir:Normalized()
    
    self.perp_vector = Vector(-self.direction.y, self.direction.x, 0)
    self.perp_vector = self.perp_vector:Normalized()
    
    self.proj = {
        Ability           = ability,
        EffectName        = "particles/peterka_r.vpcf",
        iUnitTargetTeam   = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType   = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags  = 0,
        bDeleteOnHit      = true,
        fDistance         = self.distance,
        fStartRadius      = self.collision_rad,
        fEndRadius        = self.collision_rad,
        vVelocity         = self.direction * self.speed,
        Source            = caster,
        ExtraData         = { radius = self.splash_radius, damage = self.splash_damage },
    }
    
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_peterka_r_scepter_wave:OnIntervalThink()
    local caster = self:GetParent()
    if not caster or caster:IsNull() or not caster:IsAlive() then
        self:Destroy()
        return
    end
    
    local offset = RandomFloat(-self.radius, self.radius)
    local spawnPos = self.origin + self.perp_vector * offset
    spawnPos.z = GetGroundHeight(spawnPos, caster) + 50
    
    self.proj.vSpawnOrigin = spawnPos
    ProjectileManager:CreateLinearProjectile(self.proj)
end