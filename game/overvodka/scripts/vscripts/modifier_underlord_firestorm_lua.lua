modifier_underlord_firestorm_lua = class({})

function modifier_underlord_firestorm_lua:IsHidden()
	return true
end

function modifier_underlord_firestorm_lua:IsDebuff()
	return true
end

function modifier_underlord_firestorm_lua:IsStunDebuff()
	return false
end

function modifier_underlord_firestorm_lua:IsPurgable()
	return true
end

function modifier_underlord_firestorm_lua:OnCreated( kv )
	if not IsServer() then return end
	local interval = kv.interval
	self.damage_pct = kv.damage/100
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	}
	self:StartIntervalThink( interval )
end

function modifier_underlord_firestorm_lua:OnRefresh( kv )
	if not IsServer() then return end
	self.damage_pct = kv.damage/100
end

function modifier_underlord_firestorm_lua:OnRemoved()
end

function modifier_underlord_firestorm_lua:OnDestroy()
end

function modifier_underlord_firestorm_lua:OnIntervalThink()
	local damage = self:GetParent():GetMaxHealth() * self.damage_pct
	self.damageTable.damage = damage
	ApplyDamage( self.damageTable )
end

function modifier_underlord_firestorm_lua:GetEffectName()
	return "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf"
end

function modifier_underlord_firestorm_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end