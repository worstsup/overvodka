kirill_q = class({})

LinkLuaModifier( "modifier_kirill_q", "heroes/kirill/kirill_q", LUA_MODIFIER_MOTION_NONE )

function kirill_q:Precache( context )
	PrecacheResource( "soundfile", "soundevents/prov.vsndevts", context )
end

function kirill_q:OnSpellStart()
	EmitSoundOn( "prov", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kirill_q", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_kirill_q = class({})

function modifier_kirill_q:IsPurgable()
	return false
end

function modifier_kirill_q:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_agility = self:GetAbility():GetSpecialValueFor( "bonus_agility" )
	self.agility = self:GetParent():GetAgility() * self.bonus_agility * 0.01
	self.scepter = self:GetCaster():HasScepter()
	self.resist = self:GetAbility():GetSpecialValueFor( "resist" )
	if self.scepter then
		self.model_scale = self.model_scale - 10
	end
end

function modifier_kirill_q:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_kirill_q:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_UNSELECTABLE] = self.scepter,
	}
	return state
end

function modifier_kirill_q:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_kirill_q:GetModifierIncomingDamage_Percentage( params )
	return self.resist
end

function modifier_kirill_q:GetModifierMoveSpeedBonus_Percentage( params )
	return self.move_speed
end

function modifier_kirill_q:GetModifierBonusStats_Agility( params )
	return self.agility
end