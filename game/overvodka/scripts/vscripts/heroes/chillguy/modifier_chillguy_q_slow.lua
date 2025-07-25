modifier_chillguy_q_slow = class({})
function modifier_chillguy_q_slow:IsDebuff()
	return true
end
function modifier_chillguy_q_slow:OnCreated( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor( "blast_dot_damage" )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
	self.tick = 0
	self.interval = self:GetRemainingTime()/kv.duration
	self.duration = kv.duration
	self:StartIntervalThink( self.interval )
end
function modifier_chillguy_q_slow:OnRefresh( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor( "blast_dot_damage" )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
	self.tick = 0
	self.interval = self:GetRemainingTime()/kv.duration 
	self.duration = kv.duration
	self:StartIntervalThink( self.interval )
end

function modifier_chillguy_q_slow:OnDestroy()
	if IsServer() then
		if self.tick < self.duration then
			self:OnIntervalThink()
		end
	end
end
function modifier_chillguy_q_slow:DeclareFunctions()	
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_chillguy_q_slow:GetModifierMoveSpeedBonus_Percentage( params )
	return self.dot_slow
end
function modifier_chillguy_q_slow:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dot_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
	end
	self.tick = self.tick + 1
end
function modifier_chillguy_q_slow:GetEffectName()
	return "particles/skeletonking_hellfireblast_debuff_new.vpcf"
end
function modifier_chillguy_q_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end