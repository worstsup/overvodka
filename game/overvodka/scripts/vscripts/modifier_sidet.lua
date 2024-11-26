modifier_sidet = class({})
--------------------------------------------------------------------------------
function modifier_sidet:IsPurgable()
	return false
end

function modifier_sidet:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
	self.bonus_agility = 0
	local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_sleep.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
	self:AddParticle( nFXIndex, false, false, -1, false, true )	
	self.hpregen = self:GetAbility():GetSpecialValueFor( "hpregen" )
	if IsServer() then
		self.nHealTicks = 0
		self:StartIntervalThink( 0.05 )
	end
end

--------------------------------------------------------------------------------

function modifier_sidet:OnRemoved()
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

function modifier_sidet:OnIntervalThink()
	if IsServer() then
		self:GetParent():Heal( ( self.bonus_strength * 20 ) * 0.05, self:GetAbility() )
		self.nHealTicks = self.nHealTicks + 1
		if self.nHealTicks >= 20 then
			self:StartIntervalThink( -1 )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_sidet:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}

	return funcs
end
function modifier_sidet:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
--------------------------------------------------------------------------------


function modifier_sidet:OnAttackLanded( params )
	if IsServer() then
		local hTarget = params.target

		if hTarget == nil or hTarget ~= self:GetParent() then
			return 0
		end
		EmitGlobalSound( "lolkek" )
	end
end

--------------------------------------------------------------------------------

function modifier_sidet:GetModifierModelScale( params )
	return self.model_scale
end
function modifier_sidet:GetModifierHealthRegenPercentage( params )
	return self.hpregen
end

function modifier_sidet:GetModifierExtraStrengthBonus( params )
	return self.bonus_strength
end

function modifier_sidet:GetModifierBonusStats_Intellect( params )
	return self.bonus_intellect
end

function modifier_sidet:GetModifierMoveSpeed_Limit( params )
	return self.move_speed
end

function modifier_sidet:GetModifierBonusStats_Agility( params )
	return self.bonus_agility
end