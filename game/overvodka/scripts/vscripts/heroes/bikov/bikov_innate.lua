LinkLuaModifier("modifier_bikov_innate_aura", "heroes/bikov/bikov_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bikov_innate_buff", "heroes/bikov/bikov_innate", LUA_MODIFIER_MOTION_NONE)

bikov_innate = class({})

function bikov_innate:GetIntrinsicModifierName()
	return "modifier_bikov_innate_aura"
end


modifier_bikov_innate_aura = class({})

function modifier_bikov_innate_aura:IsHidden() return true end
function modifier_bikov_innate_aura:IsPurgable() return false end

function modifier_bikov_innate_aura:IsAura() return true end
function modifier_bikov_innate_aura:GetAuraRadius()
	return self:GetAbility() and self:GetAbility():GetSpecialValueFor("radius") or 0
end
function modifier_bikov_innate_aura:GetAuraSearchTeam()  return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_bikov_innate_aura:GetAuraSearchType()  return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_bikov_innate_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_bikov_innate_aura:GetAuraDuration()    return 0.4 end
function modifier_bikov_innate_aura:GetModifierAura()    return "modifier_bikov_innate_buff" end


modifier_bikov_innate_buff = class({})

function modifier_bikov_innate_buff:IsHidden() return false end
function modifier_bikov_innate_buff:IsPurgable() return false end

function modifier_bikov_innate_buff:OnCreated()
	local ab = self:GetAbility()
	self.regen = ab and ab:GetSpecialValueFor("bonus_hp_regen") or 0
	self.as    = ab and ab:GetSpecialValueFor("bonus_as") or 0
	self.sr    = ab and ab:GetSpecialValueFor("bonus_status_res") or 0

	if IsServer() then
		self:SetHasCustomTransmitterData(true)
		self:SendBuffRefreshToClients()
	end
end

function modifier_bikov_innate_buff:OnRefresh() self:OnCreated() end

function modifier_bikov_innate_buff:AddCustomTransmitterData()
	return { r = self.regen or 0, a = self.as or 0, s = self.sr or 0 }
end

function modifier_bikov_innate_buff:HandleCustomTransmitterData(d)
	self.regen = d.r or 0
	self.as    = d.a or 0
	self.sr    = d.s or 0
end

function modifier_bikov_innate_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
end

function modifier_bikov_innate_buff:GetModifierConstantHealthRegen()      return self.regen or 0 end
function modifier_bikov_innate_buff:GetModifierAttackSpeedBonus_Constant() return self.as or 0 end
function modifier_bikov_innate_buff:GetModifierStatusResistance()  return self.sr or 0 end
