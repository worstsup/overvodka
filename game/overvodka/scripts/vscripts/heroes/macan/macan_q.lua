macan_q = class({})
LinkLuaModifier( "modifier_wisp_ambient", "heroes/macan/macan_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_macan_q", "heroes/macan/macan_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_macan_q_attack", "heroes/macan/macan_q", LUA_MODIFIER_MOTION_NONE )

function macan_q:Precache( context )
	PrecacheResource( "soundfile", "soundevents/privik.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/zanovo.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/brat.vsndevts", context )
	PrecacheResource( "particle", "particles/dark_willow_willowisp_ambient_new.vpcf", context)
	PrecacheResource( "particle", "particles/dark_willow_wisp_aoe_cast_new.vpcf", context)
	PrecacheResource( "particle", "particles/dark_willow_wisp_aoe_new.vpcf", context)
	PrecacheResource( "particle", "particles/dark_willow_willowisp_base_attack_new.vpcf", context)
end

function macan_q:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "roaming_duration" )
	caster:AddNewModifier(
		caster,
		self,
		"modifier_macan_q",
		{ duration = duration }
	)

end
function macan_q:OnProjectileHit_ExtraData( target, location, ExtraData )
	local effect_cast = ExtraData.effect
	ParticleManager:DestroyParticle( effect_cast, false )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	if not target then return end
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = ExtraData.damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}
	ApplyDamage(damageTable)
end

modifier_macan_q = class({})

function modifier_macan_q:IsHidden()
	return false
end

function modifier_macan_q:IsDebuff()
	return false
end

function modifier_macan_q:IsPurgable()
	return false
end

function modifier_macan_q:OnCreated( kv )
	self.parent = self:GetParent()
	self.zero = Vector(0,0,0)
	self.revolution = self:GetAbility():GetSpecialValueFor( "roaming_seconds_per_rotation" )
	self.rotate_radius = self:GetAbility():GetSpecialValueFor( "roaming_radius" )
	if not IsServer() then return end
	self.bol = self:GetAbility():GetSpecialValueFor( "bol" )
	self.interval = 0.03
	self.base_facing = Vector(0,1,0)
	self.relative_pos = Vector( -self.rotate_radius, 0, 100 )
	self.rotate_delta = 360/self.revolution * self.interval
	self.position = self.parent:GetOrigin() + self.relative_pos
	self.rotation = 0
	self.facing = self.base_facing
	self.wisp = CreateUnitByName(
		"npc_dota_dark_willow_creature",
		self.position,
		true,
		self.parent,
		self.parent:GetOwner(),
		self.parent:GetTeamNumber()
	)
	self.wisp:SetForwardVector( self.facing )
	self.wisp:AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"modifier_wisp_ambient",
		{}
	)
	self.wisp:AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"modifier_macan_q_attack",
		{ duration = kv.duration }
	)
	if self:GetCaster():HasModifier("modifier_macan_r") and self.bol == 1 then 
		self.base_facing_new = Vector(0,1,0)
		self.rotate_radius_new = self:GetAbility():GetSpecialValueFor( "roaming_radius" ) + 500
		self.rotate_delta_new = 360/self.revolution * self.interval
		self.relative_pos_new = Vector( -self.rotate_radius_new, 0, 100 )
		self.position_new = self.parent:GetOrigin() + self.relative_pos_new
		self.rotation_new = 0
		self.facing_new = self.base_facing_new
		self.wisp_new = CreateUnitByName(
			"npc_dota_dark_willow_creature",
			self.position_new,
			true,
			self.parent,
			self.parent:GetOwner(),
			self.parent:GetTeamNumber()
		)
		self.wisp_new:SetForwardVector( self.facing_new )
		self.wisp_new:AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_wisp_ambient",
			{}
		)
		self.wisp_new:AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_macan_q_attack",
			{ duration = kv.duration }
		)
	end
	self:StartIntervalThink( self.interval )
	self:PlayEffects()
end

function modifier_macan_q:OnRefresh( kv )
	self.revolution = self:GetAbility():GetSpecialValueFor( "roaming_seconds_per_rotation" )
	self.rotate_radius = self:GetAbility():GetSpecialValueFor( "roaming_radius" )
	self.bol = self:GetAbility():GetSpecialValueFor( "bol" )
	if not IsServer() then return end
	self.relative_pos = Vector( -self.rotate_radius, 0, 100 )
	self.rotate_delta = 360/self.revolution * self.interval
	self.wisp:AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"modifier_macan_q_attack",
		{ duration = kv.duration }
	)
	if self:GetCaster():HasModifier("modifier_macan_r") and self.bol == 1 then 
		self.rotate_delta_new = 360/self.revolution * self.interval
		self.rotate_radius_new = self:GetAbility():GetSpecialValueFor( "roaming_radius" ) + 500
		self.relative_pos_new = Vector( -self.rotate_radius_new, 0, 100 )
		self.wisp_new:AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_macan_q_attack",
			{ duration = kv.duration }
		)
	end
end

function modifier_macan_q:OnRemoved()
end

function modifier_macan_q:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self.wisp )
	UTIL_Remove( self.wisp_new )
end

function modifier_macan_q:OnIntervalThink()
	self.rotation = self.rotation + self.rotate_delta
	local origin = self.parent:GetOrigin()
	self.position = RotatePosition( origin, QAngle( 0, -self.rotation, 0 ), origin + self.relative_pos )
	self.facing = RotatePosition( self.zero, QAngle( 0, -self.rotation, 0 ), self.base_facing )
	self.wisp:SetOrigin( self.position )
	self.wisp:SetForwardVector( self.facing )
	if self:GetCaster():HasModifier("modifier_macan_r") then 
		self.rotation_new = self.rotation_new + self.rotate_delta_new
		self.position_new = RotatePosition( origin, QAngle( 0, -self.rotation_new, 0 ), origin + self.relative_pos_new )
		self.facing_new = RotatePosition( self.zero, QAngle( 0, -self.rotation_new, 0 ), self.base_facing_new )
		self.wisp_new:SetOrigin( self.position_new )
		self.wisp_new:SetForwardVector( self.facing_new )
	else
		UTIL_Remove( self.wisp_new )
	end
end

function modifier_macan_q:PlayEffects()
	local particle_cast = "particles/dark_willow_wisp_aoe_cast_new.vpcf"
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( self.rotate_radius, self.rotate_radius, self.rotate_radius ) )
	if self:GetCaster():HasModifier("modifier_macan_r") then 
		ParticleManager:SetParticleControl( effect_cast, 3, Vector( self.rotate_radius_new, self.rotate_radius_new, self.rotate_radius_new ) )
	end
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_macan_q_attack = class({})

function modifier_macan_q_attack:IsHidden()
	return false
end

function modifier_macan_q_attack:IsDebuff()
	return false
end

function modifier_macan_q_attack:IsStunDebuff()
	return false
end

function modifier_macan_q_attack:IsPurgable()
	return false
end

function modifier_macan_q_attack:OnCreated( kv )
	local damage = self:GetAbility():GetSpecialValueFor( "attack_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "attack_radius" )
	if not IsServer() then return end
	local projectile_name = ""
	local projectile_speed = 1400

	self.info = {
		Source = self:GetParent(),
		Ability = self:GetAbility(),	
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		ExtraData = {
			damage = damage,
		}
	}
	self:StartIntervalThink( self.interval )
	self:PlayEffects()
end

function modifier_macan_q_attack:OnRefresh( kv )
	local damage = self:GetAbility():GetSpecialValueFor( "attack_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "attack_radius" )
	if not IsServer() then return end
	self.info.ExtraData.damage = damage
	self:PlayEffects()
end

function modifier_macan_q_attack:OnRemoved()
	StopSoundOn( music, self:GetParent() )
end

function modifier_macan_q_attack:OnDestroy()
end

function modifier_macan_q_attack:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		local effect = self:PlayEffects1( enemy, self.info.iMoveSpeed )
		self.info.Target = enemy
		self.info.ExtraData.effect = effect
		ProjectileManager:CreateTrackingProjectile( self.info )
		local sound_cast = "Hero_DarkWillow.WillOWisp.Damage"
		EmitSoundOn( sound_cast, self:GetParent() )
		break
	end
end

function modifier_macan_q_attack:PlayEffects()
	local particle_cast = "particles/dark_willow_wisp_aoe_new.vpcf"
	local random_chance = RandomInt(1, 3)
	if random_chance == 1 then
		music = "privik"
	end
	if random_chance == 2 then
		music = "zanovo"
	end
	if random_chance == 3 then
		music = "brat"
	end
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )

	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( music, self:GetParent() )
end

function modifier_macan_q_attack:PlayEffects1( target, speed )
	local particle_cast = "particles/dark_willow_willowisp_base_attack_new.vpcf"
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )

	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, 0, 0 ) )

	return effect_cast
end

modifier_wisp_ambient = class({})

function modifier_wisp_ambient:IsHidden()
	return false
end

function modifier_wisp_ambient:IsPurgable()
	return false
end

function modifier_wisp_ambient:OnCreated( kv )
	if not IsServer() then return end
	self:GetParent():SetModel( "models/heroes/dark_willow/dark_willow_wisp.vmdl" )
	self:PlayEffects()
	local spell_steal = self:GetCaster():FindAbilityByName("rubick_spell_steal_lua")
	local stolen = (self:GetAbility():IsStolen() and spell_steal)
	if stolen then
		self:GetParent():SetModelScale( 0.01 )
	end

end

function modifier_wisp_ambient:OnRefresh( kv )
	
end

function modifier_wisp_ambient:OnRemoved()
end

function modifier_wisp_ambient:OnDestroy()
end

function modifier_wisp_ambient:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}

	return funcs
end

function modifier_wisp_ambient:GetModifierBaseAttack_BonusDamage()
	if not IsServer() then return end
	local target = self:GetParent():GetOrigin() + self:GetParent():GetForwardVector()
	local forward = self:GetParent():GetForwardVector()
	ParticleManager:SetParticleControl( self.effect_cast, 2, target )
end

function modifier_wisp_ambient:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end

function modifier_wisp_ambient:PlayEffects()
	local particle_cast = "particles/dark_willow_willowisp_ambient_new.vpcf"
	self.effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end