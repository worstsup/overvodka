LinkLuaModifier( "modifier_cheater_rage", "heroes/cheater/cheater_rage", LUA_MODIFIER_MOTION_NONE )

cheater_rage = class({})

function cheater_rage:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	caster:AddNewModifier(caster, self, "modifier_cheater_rage", {duration = duration})
	local sound_cast = "scar_start"
	EmitSoundOn( sound_cast, caster )
end


modifier_cheater_rage = class({})

function modifier_cheater_rage:IsHidden() return false end
function modifier_cheater_rage:IsDebuff() return false end
function modifier_cheater_rage:IsPurgable() return false end
function modifier_cheater_rage:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_cheater_rage:OnCreated()
	if not IsServer() then return end
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_reduction" )
end

function modifier_cheater_rage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_cheater_rage:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

function modifier_cheater_rage:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_6
end

function modifier_cheater_rage:GetModifierAttackSpeedBonus_Constant()
	return self.bonus
end

function modifier_cheater_rage:GetModifierDamageOutgoing_Percentage()
	return self.reduction
end

function modifier_cheater_rage:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	self:GetParent():EmitSound("scar")
end