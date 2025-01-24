zolo_stopapupa = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_stopapupa", "heroes/zolo/modifier_zolo_stopapupa", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_slow", "heroes/zolo/zolo_stopapupa", LUA_MODIFIER_MOTION_NONE )

function zolo_stopapupa:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

function zolo_stopapupa:OnSpellStart()
end

function zolo_stopapupa:OnOrbImpact( params )
	local duration = self:GetSpecialValueFor( "armor_duration" )
	local bash = self:GetSpecialValueFor( "ministun_duration" )
	local chance = self:GetSpecialValueFor( "chance" )
	local str = self:GetCaster():GetStrength()
	local damage = self:GetSpecialValueFor( "str_damage" ) * str * 0.01
	local random_chance = RandomInt(1, 100)
	if random_chance <= chance then
		self:GetCaster():ModifyGold(300, false, 0)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self:GetCaster(), 300, nil)
	end
	ApplyDamage({victim = params.target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
	params.target:AddNewModifier(
		self:GetCaster(), 
		self, 
		"modifier_zolo_stopapupa", 
		{ duration = duration }
	)
	params.target:AddNewModifier(
		self:GetCaster(), 
		self, 
		"modifier_dark_willow_debuff_fear", 
		{ duration = bash }
	)
	params.target:AddNewModifier(
		self:GetCaster(), 
		self, 
		"modifier_zolo_slow", 
		{ duration = bash }
	)
end

modifier_zolo_slow = class({})

function modifier_zolo_slow:IsHidden()
	return true
end
function modifier_zolo_slow:IsDebuff()
	return true
end
function modifier_zolo_slow:IsStunDebuff()
	return false
end
function modifier_zolo_slow:IsPurgable()
	return true
end

function modifier_zolo_slow:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_zolo_slow:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_zolo_slow:OnRemoved()
end
function modifier_zolo_slow:OnDestroy()
end

function modifier_zolo_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_zolo_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end
