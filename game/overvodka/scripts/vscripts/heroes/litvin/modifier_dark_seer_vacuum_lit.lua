modifier_dark_seer_vacuum_lit = class({})

function modifier_dark_seer_vacuum_lit:IsHidden()
	return false
end
function modifier_dark_seer_vacuum_lit:IsDebuff()
	return true
end
function modifier_dark_seer_vacuum_lit:IsStunDebuff()
	return true
end
function modifier_dark_seer_vacuum_lit:IsPurgable()
	return true
end

function modifier_dark_seer_vacuum_lit:OnCreated( kv )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	if not IsServer() then return end
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()
	self.direction.z = 0
	self.direction = self.direction:Normalized()
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function modifier_dark_seer_vacuum_lit:OnRefresh( kv )
	self:OnCreated( kv )
end
function modifier_dark_seer_vacuum_lit:OnRemoved()
end

function modifier_dark_seer_vacuum_lit:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(),
	}
	ApplyDamage(damageTable)
end

function modifier_dark_seer_vacuum_lit:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_dark_seer_vacuum_lit:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_dark_seer_vacuum_lit:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_dark_seer_vacuum_lit:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function modifier_dark_seer_vacuum_lit:OnHorizontalMotionInterrupted()
	self:Destroy()
end