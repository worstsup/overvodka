arsen_testosteron = class({})
LinkLuaModifier( "modifier_arsen_testosteron", "heroes/arsen/modifier_arsen_testosteron", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_testosteron_debuff", "heroes/arsen/modifier_arsen_testosteron_debuff", LUA_MODIFIER_MOTION_NONE )

function arsen_testosteron:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/testosteron.vsndevts", context )
end
function arsen_testosteron:OnAbilityPhaseInterrupted()
	local sound_cast = "testosteron"
	StopSoundOn( sound_cast, self:GetCaster() )
end
function arsen_testosteron:OnAbilityPhaseStart()
	local sound_cast = "testosteron"
	EmitSoundOn( sound_cast, self:GetCaster() )
	return true
end

function arsen_testosteron:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetOrigin()
	local buff_duration = self:GetSpecialValueFor("buff_duration")
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		point,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_arsen_testosteron_debuff",
			{ duration = duration * (1 - enemy:GetStatusResistance()) }
		)
	end
	caster:AddNewModifier(
		caster,
		self,
		"modifier_arsen_testosteron",
		{ duration = buff_duration }
	)
	if #enemies>0 then
		local sound_cast = "Hero_Axe.Berserkers_Call"
		EmitSoundOn( sound_cast, self:GetCaster() )
	end
	self:PlayEffects(radius)
end

function arsen_testosteron:PlayEffects(radius)
	local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end