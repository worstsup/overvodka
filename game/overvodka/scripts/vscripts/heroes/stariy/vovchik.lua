vovchik = class({})


--------------------------------------------------------------------------------
-- Ability Cast Filter
function vovchik:CastFilterResultTarget( hTarget )
	local immune = 0

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		immune,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------
-- Ability Start
function vovchik:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local damage = target:GetHealth() * 0.3
	local heal = target:GetHealth() * 0.3

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then
		return
	end

	-- heal
	caster:Heal( heal, self )

	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- Play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function vovchik:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_bane/bane_sap.vpcf"
	local particle_cast_new = "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn_bone_explosion_style2.vpcf"
	local sound_cast = "vovchik"
	local sound_target = "Hero_Bane.BrainSap.Target"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast_new, PATTACH_ABSORIGIN_FOLLOW, target )
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetCaster():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end