ebanko_innate = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ebanko_innate", "heroes/ebanko/modifier_ebanko_innate", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function ebanko_innate:GetIntrinsicModifierName()
	return "modifier_ebanko_innate"
end
--------------------------------------------------------------------------------
function ebanko_innate:CastFilterResultTarget( hTarget )
	local flag = 0
	if self:GetCaster():HasScepter() then
		flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES 
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		flag,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------
function ebanko_innate:OnSpellStart()
end

--------------------------------------------------------------------------------
function ebanko_innate:GetProjectileName()
	return "particles/units/heroes/hero_silencer/silencer_glaives_of_wisdom.vpcf"
end

function ebanko_innate:OnOrbFire( params )
	local sound_cast = "Hero_Silencer.GlaivesOfWisdom"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function ebanko_innate:OnOrbImpact( params )
	local caster = self:GetCaster()
	local int_mult = self:GetSpecialValueFor( "intellect_damage_pct" )
	local damage = caster:GetIntellect(true) * int_mult/100
	if caster:HasScepter() then
		damage = damage*2
	end
	local damageTable = {
		victim = params.target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, 
	}
	ApplyDamage(damageTable)
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
		params.target,
		damage,
		nil
	)
	local sound_cast = "Hero_Silencer.GlaivesOfWisdom.Damage"
	EmitSoundOn( sound_cast, params.target )
end