shkolnik_innate = class({})
LinkLuaModifier( "modifier_shkolnik_innate", "heroes/shkolnik/shkolnik_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shkolnik_innate_debuff", "heroes/shkolnik/shkolnik_innate", LUA_MODIFIER_MOTION_NONE )

function shkolnik_innate:GetIntrinsicModifierName()
	return "modifier_shkolnik_innate"
end

modifier_shkolnik_innate = class({})

function modifier_shkolnik_innate:IsHidden()
	return true
end

function modifier_shkolnik_innate:IsPurgable()
	return false
end

function modifier_shkolnik_innate:OnCreated( kv )
end

function modifier_shkolnik_innate:OnRefresh( kv )
end

function modifier_shkolnik_innate:OnDestroy( kv )
end

function modifier_shkolnik_innate:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
	}

	return funcs
end

function modifier_shkolnik_innate:OnAttackStart( params )
	if IsServer() then
		if params.target~=self:GetParent() then return end
		if params.attacker:IsMagicImmune() then return end
		if params.attacker:IsDebuffImmune() then return end
		if params.attacker:IsBuilding() then return end
		if self:GetParent():PassivesDisabled() then return end
		params.attacker:AddNewModifier(
			self:GetParent(), 
			self:GetAbility(),
			"modifier_shkolnik_innate_debuff",
			{}
		)
	end
end

modifier_shkolnik_innate_debuff = class({})

function modifier_shkolnik_innate_debuff:IsHidden()
	return false
end
function modifier_shkolnik_innate_debuff:IsDebuff()
	return true
end
function modifier_shkolnik_innate_debuff:IsStunDebuff()
	return false
end
function modifier_shkolnik_innate_debuff:IsPurgable()
	return true
end

function modifier_shkolnik_innate_debuff:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_attack_speed" )
	self.duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
end

function modifier_shkolnik_innate_debuff:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_attack_speed" )
	self.duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
end

function modifier_shkolnik_innate_debuff:OnDestroy( kv )
end

function modifier_shkolnik_innate_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FINISHED,

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_shkolnik_innate_debuff:GetModifierPreAttack( params )
	if IsServer() then
		if not self.HasAttacked then
			self.record = params.record
		end
		if params.target~=self:GetCaster() then
			self.attackOther = true
		end
	end
end

function modifier_shkolnik_innate_debuff:OnAttack( params )
	if IsServer() then
		if params.record~=self.record then return end
		self:SetDuration(self.duration, true)
		self.HasAttacked = true
	end
end

function modifier_shkolnik_innate_debuff:OnAttackFinished( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		if not self.HasAttacked then
			self:Destroy()
		end
		if self.attackOther then
			self:Destroy()
		end
	end
end

function modifier_shkolnik_innate_debuff:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		if self:GetParent():GetAggroTarget()==self:GetCaster() then
			return self.slow
		else
			return 0
		end
	end

	return self.slow
end

function modifier_shkolnik_innate_debuff:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_untouchable.vpcf"
end

function modifier_shkolnik_innate_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end