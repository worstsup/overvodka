vihor_e = class({})
LinkLuaModifier( "modifier_vihor_e", "heroes/vihor/vihor_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vihor_e_debuff", "heroes/vihor/vihor_e", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function vihor_e:GetIntrinsicModifierName()
	return "modifier_vihor_e"
end
function vihor_e:Precache(context)
    PrecacheResource("particle", "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_2.vpcf", context)
	PrecacheResource( "soundfile", "soundevents/vihor_e.vsndevts", context )
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
	self.tick_duration = self:GetAbility():GetSpecialValueFor("tick_duration")
end

function modifier_vihor_e:OnRefresh( kv )
	self.duration = self:GetAbility():GetSpecialValueFor("hex_duration")
	self.blocked = self:GetAbility():GetSpecialValueFor("blocked")
	self.chance = self:GetAbility():GetSpecialValueFor("chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.tick_duration = self:GetAbility():GetSpecialValueFor("tick_duration")
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
			params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_vihor_e_debuff", { duration = self.tick_duration } )
			ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			EmitSoundOn("vihor_e", self:GetParent())
			self:GetAbility():UseResources( false, false, false, true )
			if self.blocked == 1 then
				self:GetParent():Heal(params.damage*2, self:GetParent())
			end
		end
	end
end

modifier_vihor_e_debuff = class({})
function modifier_vihor_e_debuff:IsDebuff()
	return true
end
function modifier_vihor_e_debuff:OnCreated( kv )
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self:StartIntervalThink( 1 )
end
function modifier_vihor_e_debuff:OnRefresh( kv )
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self:StartIntervalThink( 1 )
end

function modifier_vihor_e_debuff:OnDestroy()
end

function modifier_vihor_e_debuff:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
	end
end
function modifier_vihor_e_debuff:GetEffectName()
	return "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_2.vpcf"
end
function modifier_vihor_e_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end