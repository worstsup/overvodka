ashab_slushay = class({})
LinkLuaModifier( "modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ashab_slushay_buff", "heroes/ashab/modifier_ashab_slushay_buff", LUA_MODIFIER_MOTION_NONE )

function ashab_slushay:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_tidehunter_7" )
end

function ashab_slushay:OnSpellStart()
	local caster = self:GetCaster()
	local reduction_radius = self:GetSpecialValueFor("radius")
	local reduction_duration = self:GetSpecialValueFor("reduction_duration")
	local bonus_damage = self:GetSpecialValueFor("attack_damage")
	 if caster:HasModifier("modifier_item_aghanims_shard") then
		caster:Purge( false, true, false, false, false)
	end
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
	local mod = caster:AddNewModifier(
		caster,
		self,
		"modifier_ashab_slushay_buff",
		{
			bonus = bonus_damage,
		}
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_generic_disarmed_lua",
			{ duration = reduction_duration }
		)
		caster:PerformAttack( enemy, true, true, true, true, false, false, true )
	end
	mod:Destroy()

	self:PlayEffects()
end

function ashab_slushay:PlayEffects()
	local particle_cast = "particles/base_statue_destruction_gold_lvl2_new.vpcf"
	local sound_cast = "slushay"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end