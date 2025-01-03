arsen_testosteron = class({})
LinkLuaModifier( "modifier_arsen_testosteron", "heroes/arsen/modifier_arsen_testosteron", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_testosteron_debuff", "heroes/arsen/modifier_arsen_testosteron_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Phase Start
function arsen_testosteron:OnAbilityPhaseInterrupted()
	-- stop effects 
	local sound_cast = "testosteron"
	StopSoundOn( sound_cast, self:GetCaster() )
end
function arsen_testosteron:OnAbilityPhaseStart()
	-- play effects 
	local sound_cast = "testosteron"
	EmitSoundOn( sound_cast, self:GetCaster() )

	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function arsen_testosteron:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = caster:GetOrigin()
	local buff_duration = self:GetSpecialValueFor("buff_duration")
	-- load data
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	-- find units caught
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- call
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_arsen_testosteron_debuff", -- modifier name
			{ duration = duration } -- kv
		)
	end

	-- self buff
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_arsen_testosteron", -- modifier name
		{ duration = buff_duration } -- kv
	)

	-- play effects
	if #enemies>0 then
		local sound_cast = "Hero_Axe.Berserkers_Call"
		EmitSoundOn( sound_cast, self:GetCaster() )
	end
	self:PlayEffects()
end

--------------------------------------------------------------------------------
function arsen_testosteron:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/axe_ti9_beserkers_call_owner_new.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_mouth",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end