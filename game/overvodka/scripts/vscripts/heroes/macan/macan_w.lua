macan_w = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

function macan_w:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/govor.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_dispose_aoe_damage.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_dispose_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_dispose_land_aoe.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_grapple.vpcf", context )
end

function macan_w:Spawn()
	if not IsServer() then return end
end
function macan_w:GetAOERadius()
	return 300
end

function macan_w:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function macan_w:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return ""
end

function macan_w:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor( "air_duration" )
	local height = self:GetSpecialValueFor( "air_height" )
	local distance = self:GetSpecialValueFor( "throw_distance_behind" )
	local enemies_radius = self:GetSpecialValueFor( "enemies_radius" )
	local radius = self:GetSpecialValueFor( "landing_radius" )
	local stun = self:GetSpecialValueFor( "stun_duration" )
	local damage = self:GetSpecialValueFor( "impact_damage" )
	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(),
		target:GetOrigin(),
		nil,
		enemies_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)
	local damagedEnemies = {}
	for _,enemy in pairs(targets) do
		local targetpos = caster:GetOrigin() - caster:GetForwardVector() * distance
		local totaldist = (enemy:GetOrigin() - targetpos):Length2D()
		local arc = enemy:AddNewModifier(
			caster,
			self,
			"modifier_generic_arc_lua",
			{
				target_x = targetpos.x,
				target_y = targetpos.y,
				duration = duration,
				distance = totaldist,
				height = height,
				fix_end = false,
				fix_duration = false,
				isStun = true,
				isForward = true,
				activity = ACT_DOTA_FLAIL,
			}
		)	
		arc:SetEndCallback( function()
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(),
				enemy:GetOrigin(),
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				0,
				0,
				false
			)
			local damageTable = {
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
			}

			for _,enemy1 in pairs(enemies) do
				if not damagedEnemies[enemy1:entindex()] then
					enemy1:AddNewModifier(
						caster,
						self,
						"modifier_generic_stunned_lua",
						{ duration = stun }
					)
					damageTable.victim = enemy1
					ApplyDamage(damageTable)
					self:PlayEffects2( enemy1:GetOrigin() )
					damagedEnemies[enemy1:entindex()] = true
				end
			end
			GridNav:DestroyTreesAroundPoint( enemy:GetOrigin(), radius, false )
			self:PlayEffects1( enemy:GetOrigin(), radius )
		end)
		self:PlayEffects3( caster, enemy, duration )
		self:PlayEffects4( caster )
	end

end

function macan_w:PlayEffects1( point, radius )
	local particle_cast = "particles/units/heroes/hero_marci/marci_dispose_land_aoe.vpcf"
	local sound_cast = "Hero_Marci.Grapple.Impact"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius, 0, 0) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end

function macan_w:PlayEffects2( point )
	local particle_cast = "particles/units/heroes/hero_marci/marci_dispose_aoe_damage.vpcf"
	local sound_cast = "Hero_Marci.Grapple.Stun"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end

function macan_w:PlayEffects3( caster, target, duration )
	local particle_cast = "particles/units/heroes/hero_marci/marci_dispose_debuff.vpcf"
	local sound_cast = "Hero_Marci.Grapple.Target"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
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
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, target )
end

function macan_w:PlayEffects4( caster )
	local particle_cast = "particles/units/heroes/hero_marci/marci_grapple.vpcf"
	local sound_cast = "Hero_Marci.Grapple.Cast"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, caster )
	EmitSoundOn( "govor", self:GetCaster() )
end