arsen_konchai = class({})
LinkLuaModifier( "modifier_arsen_konchai", "heroes/arsen/modifier_arsen_konchai", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_konchai_buff", "heroes/arsen/modifier_arsen_konchai_buff", LUA_MODIFIER_MOTION_NONE )

function arsen_konchai:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	return behavior
end


function arsen_konchai:OnSpellStart()
	caster = self:GetCaster()
	target = self:GetCursorTarget()
	local projectile_name = "particles/bristleback_viscous_nasal_goo_new.vpcf"
	local projectile_speed = self:GetSpecialValueFor("goo_speed")

	local info = {
		Target = target,
		Source = caster,
		Ability = self,
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
	}
	local radius = self:GetSpecialValueFor("radius_scepter")
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetCaster():GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		info.Target = enemy
		ProjectileManager:CreateTrackingProjectile(info)
	end

	self:PlayEffects1()
end

function arsen_konchai:OnProjectileHit( hTarget, vLocation )
	if hTarget == nil or hTarget:IsInvulnerable() then
		return
	end
	local stack_duration = self:GetSpecialValueFor("goo_duration")
	hTarget:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_arsen_konchai",
		{ duration = stack_duration * (1 - hTarget:GetStatusResistance()) }
	)
	if self:GetCaster():HasScepter() then
		self:GetCaster():PerformAttack(hTarget, true, true, true, true, true, false, true)
	end
	self:PlayEffects2( hTarget )
end

function arsen_konchai:PlayEffects1()
	local sound_cast = "konchai"

	EmitSoundOn( sound_cast, self:GetCaster() )
end

function arsen_konchai:PlayEffects2( target )
	local sound_cast = "Hero_Bristleback.ViscousGoo.Target"

	EmitSoundOn( sound_cast, target )
end
