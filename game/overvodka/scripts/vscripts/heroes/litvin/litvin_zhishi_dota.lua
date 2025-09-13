litvin_zhishi_dota = class({})
LinkLuaModifier( "modifier_dark_seer_vacuum_lit", "heroes/litvin/modifier_dark_seer_vacuum_lit", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_litvin_enrage", "heroes/litvin/modifier_litvin_enrage", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_litvin_litenergy", "heroes/litvin/modifier_litvin_litenergy", LUA_MODIFIER_MOTION_NONE )

function litvin_zhishi_dota:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
	PrecacheResource( "particle", "particles/dark_seer_vacuum_new.vpcf", context )
end

function litvin_zhishi_dota:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function litvin_zhishi_dota:OnAbilityPhaseStart()
	local point = self:GetCursorPosition()
	EmitSoundOnLocationWithCaster( point, "zhishi_start", self:GetCaster() )

	return true
end

function litvin_zhishi_dota:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local radius = self:GetSpecialValueFor( "radius" )
	local tree = self:GetSpecialValueFor( "radius_tree" )
	local duration = self:GetSpecialValueFor( "duration" )
	local buff_dur = self:GetSpecialValueFor( "buff_dur" )
	local direction = (point - origin)
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		point,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_dark_seer_vacuum_lit",
			{
				duration = duration,
				x = point.x,
				y = point.y,
			}
		)
	end
	GridNav:DestroyTreesAroundPoint( point, tree, false )
	FindClearSpaceForUnit( caster, origin + direction, true )
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_litvin_enrage",
		{ duration = buff_dur }
	)
	if self:GetCaster():HasShard() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_litvin_litenergy", { duration = buff_dur } )
	end
	self:PlayEffects( origin, direction, point, radius )
end

function litvin_zhishi_dota:PlayEffects( origin, direction, point, radius )
	local particle_cast_a = "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf"
	local particle_cast_b = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:SetParticleControl( effect_cast_a, 1, origin + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	local particle_cast = "particles/dark_seer_vacuum_new.vpcf"
	local sound_cast = "zhishi"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end
