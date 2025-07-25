vovchik = class({})

function vovchik:CastFilterResultTarget( hTarget )
	local immune = 0

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		immune,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function vovchik:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = target:GetHealth() * 0.25
	local heal = target:GetHealth() * 0.25
	if target:TriggerSpellAbsorb( self ) then
		return
	end
	caster:Heal( heal, self )
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self,
	}
	self:PlayEffects( target )
	ApplyDamage(damageTable)
end

function vovchik:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_bane/bane_sap.vpcf"
	local particle_cast_new = "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn_bone_explosion_style2.vpcf"
	local sound_cast = "vovchik"
	local sound_target = "Hero_Bane.BrainSap.Target"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast_new, PATTACH_ABSORIGIN_FOLLOW, target )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetCaster():GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end