sasavot_q = class({})
LinkLuaModifier( "modifier_sasavot_q", "heroes/sasavot/modifier_sasavot_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

function sasavot_q:GetCastPoint()
	return self:GetSpecialValueFor( "total_cast_time_tooltip" )
end

function sasavot_q:GetAOERadius()
 	return self:GetSpecialValueFor( "scepter_radius" )
end

function sasavot_q:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_sasavot_7" )
end

function sasavot_q:OnAbilityPhaseInterrupted()
	if self.modifier then
		local modifier = self:RetATValue( self.modifier )
		if not modifier:IsNull() then
			modifier:Destroy()
		end
		self.modifier = nil
	end
end

function sasavot_q:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local debuff_duration = 4
	local modifier = target:AddNewModifier(
		caster,
		self,
		"modifier_sasavot_q",
		{ duration = debuff_duration }
	)
	self.modifier = self:AddATValue( modifier )
	local sound_cast = "Ability.AssassinateLoad"
	EmitSoundOn( sound_cast, caster )
	return true
end

function sasavot_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local projectile_name = "particles/clockwerk_2022_cc_rocket_flare_new.vpcf"
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")

	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		ExtraData = { modifier = self.modifier }
	}
	ProjectileManager:CreateTrackingProjectile(info)
	self.modifier = nil
	local mod = caster:AddNewModifier(
		caster,
		self,
		"modifier_knockback",
			{
				center_x = target:GetAbsOrigin().x,
				center_y = target:GetAbsOrigin().y,
				center_z = target:GetAbsOrigin().z,
				duration = 0.4,
				knockback_duration = 0.4,
				knockback_distance = 350,
				knockback_height = 75,
			}
	)
	local sound_cast = "Ability.Assassinate"
	EmitSoundOn( sound_cast, caster )
	local sound_target = "Hero_Sniper.AssassinateProjectile"
	EmitSoundOn( sound_cast, target )
	EmitSoundOn( "sasavot_q_start", caster )
end

function sasavot_q:OnProjectileHit_ExtraData( target, location, extradata )
	if (not target) or target:IsInvulnerable() or target:IsOutOfGame() or target:TriggerSpellAbsorb( self ) then
		return
	end
	local radius = self:GetSpecialValueFor("scepter_radius")
	local health_damage = self:GetSpecialValueFor("health_damage")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local damage = self:GetSpecialValueFor("damage")
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
		target:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
	target:AddNewModifier( self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = stun_duration } )
	target:Interrupt()
	EmitSoundOn( "Hero_Sniper.AssassinateDamage", target )
	EmitSoundOn( "sasavot_q", target )
	if self:GetCaster():HasScepter() then
		self:GetCaster():PerformAttack(target, true, true, true, true, true, false, true)
	end
	local dmg = damage + self:GetCaster():GetMaxHealth() * health_damage * 0.01
	for _,unit in pairs(enemies) do
		local damageTable = {
			victim = unit,
			attacker = self:GetCaster(),
			damage = dmg,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
		}
		ApplyDamage(damageTable)
	end
	local modifier = self:RetATValue( extradata.modifier )
	if not modifier:IsNull() then
		modifier:Destroy()
	end
end

function sasavot_q:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end

function sasavot_q:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end

function sasavot_q:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end

function sasavot_q:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
	return ret
end