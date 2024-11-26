modifier_provor = class({})
--------------------------------------------------------------------------------
function modifier_provor:IsPurgable()
	return false
end

function modifier_provor:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
	self.bonus_agility = self:GetAbility():GetSpecialValueFor( "bonus_agility" )
	self.agility = self:GetParent():GetAgility() * self.bonus_agility * 0.01
	self.scepter = self:GetCaster():HasScepter()
	self.resist = self:GetAbility():GetSpecialValueFor( "resist" )
	if self.scepter then
		self.model_scale = self.model_scale - 10
	end
	if IsServer() then
		self.nHealTicks = 0
		self:StartIntervalThink( 0.05 )
	end
end

--------------------------------------------------------------------------------

function modifier_provor:OnRemoved()
	if IsServer() then
		local flHealth = self:GetParent():GetHealth() 
		local flMaxHealth = self:GetParent():GetMaxHealth()
		local flHealthPct = flHealth / flMaxHealth

		self:GetParent():CalculateStatBonus()

		local flNewHealth = self:GetParent():GetHealth()  
		local flNewMaxHealth = self:GetParent():GetMaxHealth()

		local flNewDesiredHealth = flNewMaxHealth * flHealthPct
		if flNewHealth ~= flNewDesiredHealth then
			self:GetParent():ModifyHealth( flNewDesiredHealth, self:GetAbility(), false, 0 )
		end	
	end
end

--------------------------------------------------------------------------------

function modifier_provor:OnIntervalThink()
	if IsServer() then
		self:GetParent():Heal( ( self.bonus_strength * 20 ) * 0.05, self:GetAbility() )
		self.nHealTicks = self.nHealTicks + 1
		if self.nHealTicks >= 20 then
			self:StartIntervalThink( -1 )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_provor:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_provor:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_UNSELECTABLE] = self.scepter,
	}

	return state
end
--------------------------------------------------------------------------------


function modifier_provor:OnAttackLanded( params )
	if IsServer() then
		local hTarget = params.target

		if hTarget == nil or hTarget ~= self:GetParent() then
			return 0
		end
		EmitGlobalSound( "lolkek" )
	end
end

--------------------------------------------------------------------------------

function modifier_provor:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_provor:GetModifierIncomingDamage_Percentage( params )
	return self.resist
end

function modifier_provor:GetModifierExtraStrengthBonus( params )
	return self.bonus_strength
end

function modifier_provor:GetModifierBonusStats_Intellect( params )
	return self.bonus_intellect
end

function modifier_provor:GetModifierMoveSpeedBonus_Percentage( params )
	return self.move_speed
end

function modifier_provor:GetModifierBonusStats_Agility( params )
	return self.agility
end