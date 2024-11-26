tidehunter_anchor_smash_lua = class({})
LinkLuaModifier( "modifier_tidehunter_anchor_smash_lua", "modifier_tidehunter_anchor_smash_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tidehunter_anchor_smash_lua_buff", "modifier_tidehunter_anchor_smash_lua_buff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function tidehunter_anchor_smash_lua:OnSpellStart()
	local caster = self:GetCaster()

	-- get references
	local reduction_radius = self:GetSpecialValueFor("radius")
	local reduction_duration = self:GetSpecialValueFor("reduction_duration")
	local bonus_damage = self:GetSpecialValueFor("attack_damage")
	 if caster:HasModifier("modifier_item_aghanims_shard") then
	 	local RemovePositiveBuffs = false
		local RemoveDebuffs = true
		local BuffsCreatedThisFrameOnly = false
		local RemoveStuns = true
		local RemoveExceptions = false
		caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	end
	-- get list of affected enemies
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		reduction_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	-- add buff modifier
	-- SUPPRESS_CLEAVE doesn't work yet
	local mod = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_tidehunter_anchor_smash_lua_buff", -- modifier name
		{
			bonus = bonus_damage,
		} -- kv
	)

	-- Do for each affected enemies
	for _,enemy in pairs(enemies) do
		-- Add reduction modifier
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_tidehunter_anchor_smash_lua",
			{ duration = reduction_duration }
		)
		-- attack
		caster:PerformAttack( enemy, true, true, true, true, false, false, true )
	end

	-- destroy modifier
	mod:Destroy()

	self:PlayEffects()
end

function tidehunter_anchor_smash_lua:PlayEffects()
	-- get resources
	local particle_cast = "particles/base_statue_destruction_gold_lvl2_new.vpcf"
	local sound_cast = "slushay"

	-- play effects
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end