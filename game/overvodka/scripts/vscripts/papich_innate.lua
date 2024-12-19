papich_innate = class({})
LinkLuaModifier( "modifier_papich_innate", "papich_innate", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
random_chance = 0
function papich_innate:OnSpellStart()
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_papich_innate", { duration = self:GetSpecialValueFor( "duration" ) } )
end
--------------------------------------------------------------------------------
modifier_papich_innate = class({})
--------------------------------------------------------------------------------
function modifier_papich_innate:IsPurgable()
	return false
end

function modifier_papich_innate:OnCreated( kv )
	self.base_amp = 0
	self.str = 0
	self.ms = 0
	self.level = self:GetCaster():GetLevel()
	if (random_chance % 3) == 0 then
		self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
		EmitSoundOn("papich_innate_1", self:GetCaster())
	elseif (random_chance % 3) == 1 then
		self.base_amp = self:GetAbility():GetSpecialValueFor( "base_amp" ) * self.level
		EmitSoundOn("papich_innate_2", self:GetCaster())
	elseif (random_chance % 3) == 2 then
		self.str = self:GetAbility():GetSpecialValueFor( "base_str" ) * self.level
		EmitSoundOn("papich_innate_3", self:GetCaster())
	end
	random_chance = random_chance + 1
end

--------------------------------------------------------------------------------

function modifier_papich_innate:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_papich_innate:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_papich_innate:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_papich_innate:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_papich_innate:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_papich_innate:GetEffectName()
	if ((random_chance - 1) % 3) == 0 then
		return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf"
	elseif ((random_chance - 1) % 3) == 1 then
		return "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_impact_filler_smoke.vpcf"
	elseif ((random_chance - 1) % 3) == 2 then
		return "particles/econ/items/sven/sven_ti10_helmet/sven_ti10_helmet_gods_strength.vpcf"
	end
end

function modifier_papich_innate:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------
