eldzhey_w = class({})

--------------------------------------------------------------------------------
function eldzhey_w:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
function eldzhey_w:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	local radius = self:GetSpecialValueFor("radius")
	local friends = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		target:GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	if caster:HasModifier("modifier_windrun_caster_datadriven") then
		caster:RemoveModifierByName("modifier_windrun_caster_datadriven")
	end
	if caster:HasModifier("modifier_roots") then
		caster:RemoveModifierByName("modifier_roots")
	end
	if caster:HasModifier("modifier_windrun_debuff_aura_datadriven") then
		caster:RemoveModifierByName("modifier_windrun_debuff_aura_datadriven")
	end
	caster:Purge( false, true, false, false, false )
	for _,friend in pairs(friends) do
		friend:Heal( heal, self )
	end
	local damagebyfacet = self:GetSpecialValueFor("damagebyfacet")
	if damagebyfacet == 1 then
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			target:GetOrigin(),
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
			damage = heal/2,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self,
		}
		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			ApplyDamage(damageTable)
			self:PlayEffects2( target, enemy )
		end
	end

	self:PlayEffects1( target, radius )
end

--------------------------------------------------------------------------------
function eldzhey_w:PlayEffects1( target, radius )
	local particle_cast = "particles/eldzhey_w_cast.vpcf"
	local particle_target = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
	local sound_target = "nepar"
	local effect_target = ParticleManager:CreateParticle( particle_target, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_target, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_target )
	EmitSoundOn( sound_target, target )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		self:GetCaster():GetOrigin(), 
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function eldzhey_w:PlayEffects2( origin, target )
	local particle_target = "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf"
	local effect_target = ParticleManager:CreateParticle( particle_target, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_target,
		0,
		origin,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		origin:GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_target,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_target )
end