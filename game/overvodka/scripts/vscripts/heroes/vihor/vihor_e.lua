vihor_e = class({})
LinkLuaModifier( "modifier_vihor_e", "heroes/vihor/vihor_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vihor_e_debuff", "heroes/vihor/vihor_e", LUA_MODIFIER_MOTION_NONE )

function vihor_e:GetIntrinsicModifierName()
	return "modifier_vihor_e"
end

function vihor_e:Precache(context)
    PrecacheResource("particle", "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_2.vpcf", context)
	PrecacheResource("soundfile", "soundevents/vihor_e.vsndevts", context )
end

modifier_vihor_e = class({})

function modifier_vihor_e:IsHidden() return true end
function modifier_vihor_e:IsDebuff() return false end
function modifier_vihor_e:IsPurgable() return false end

function modifier_vihor_e:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("hex_duration")
	self.blocked = self:GetAbility():GetSpecialValueFor("blocked")
	self.chance = self:GetAbility():GetSpecialValueFor("chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_vihor_e:OnRefresh()
	self.duration = self:GetAbility():GetSpecialValueFor("hex_duration")
	self.blocked = self:GetAbility():GetSpecialValueFor("blocked")
	self.chance = self:GetAbility():GetSpecialValueFor("chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_vihor_e:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_vihor_e:OnAttackLanded( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
		if params.attacker == self:GetParent() then return end
		if params.target ~= self:GetParent() then return end
		if not params.attacker:IsRealHero() then return end
		if params.target:IsIllusion() then return end
		local random_chance = RandomInt(1, 100)
		if random_chance <= self.chance then
			params.attacker:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_shadow_shaman_voodoo", { duration = self.duration } )
			params.attacker:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_vihor_e_debuff", { duration = self:GetAbility():GetSpecialValueFor("tick_duration") } )
			ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			EmitSoundOn("vihor_e", self:GetParent())
			self:GetAbility():UseResources( false, false, false, true )
			if self.blocked == 1 then
				self:GetParent():HealWithParams( params.damage*2, self:GetAbility(), false, false, self:GetParent(), false )
			end
		end
	end
end

modifier_vihor_e_debuff = class({})

function modifier_vihor_e_debuff:IsPurgable() return false end
function modifier_vihor_e_debuff:IsHidden() return false end

function modifier_vihor_e_debuff:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.damage = self.ability:GetSpecialValueFor("damage")
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_vihor_e_debuff:OnIntervalThink()
	if IsServer() and self.ability then
		ApplyDamage( {victim = self.parent, attacker = self.caster, damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self.ability} )
	end
end

function modifier_vihor_e_debuff:GetEffectName()
	return "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_2.vpcf"
end

function modifier_vihor_e_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end