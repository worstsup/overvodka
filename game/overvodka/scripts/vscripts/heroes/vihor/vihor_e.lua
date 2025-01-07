vihor_e = class({})
LinkLuaModifier( "modifier_vihor_e", "heroes/vihor/vihor_e", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function vihor_e:GetIntrinsicModifierName()
	return "modifier_vihor_e"
end

modifier_vihor_e = class({})

--------------------------------------------------------------------------------
function modifier_vihor_e:IsHidden()
	return true
end

function modifier_vihor_e:IsDebuff()
	return false
end

function modifier_vihor_e:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_vihor_e:OnCreated( kv )
	self.duration = self:GetAbility():GetSpecialValueFor("hex_duration")
	self.blocked = self:GetAbility():GetSpecialValueFor("blocked")
	self.chance = self:GetAbility():GetSpecialValueFor("chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_vihor_e:OnRefresh( kv )
	self.duration = self:GetAbility():GetSpecialValueFor("hex_duration")
	self.blocked = self:GetAbility():GetSpecialValueFor("blocked")
	self.chance = self:GetAbility():GetSpecialValueFor("chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_vihor_e:OnDestroy( kv )
end

--------------------------------------------------------------------------------
function modifier_vihor_e:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_vihor_e:OnAttackLanded( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
		if params.attacker == self:GetParent() then return end
		if params.target ~= self:GetParent() then return end
		if params.attacker:IsTower() then return end
		local random_chance = RandomInt(1, 100)
		if random_chance <= self.chance then
			params.attacker:AddNewModifier( params.attacker, self:GetAbility(), "modifier_shadow_shaman_voodoo", { duration = self.duration } )
			ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			EmitSoundOn("vihor_e", self:GetParent())
			self:GetAbility():UseResources( false, false, false, true )
			if self.blocked == 1 then
				self:GetParent():Heal(params.damage*2, self:GetParent())
			end
		end
	end
end