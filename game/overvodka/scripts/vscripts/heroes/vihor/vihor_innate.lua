vihor_innate = class({})
LinkLuaModifier( "modifier_vihor_innate", "heroes/vihor/vihor_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vihor_innate_effect", "heroes/vihor/vihor_innate", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function vihor_innate:GetIntrinsicModifierName()
	return "modifier_vihor_innate"
end

--------------------------------------------------------------------------------
modifier_vihor_innate = class({})
--------------------------------------------------------------------------------

function modifier_vihor_innate:IsDebuff()
	return true
end

function modifier_vihor_innate:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function modifier_vihor_innate:IsAura()
	return true
end

function modifier_vihor_innate:GetModifierAura()
	return "modifier_vihor_innate_effect"
end


function modifier_vihor_innate:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end


function modifier_vihor_innate:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_vihor_innate:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_vihor_innate:GetAuraRadius()
	return self.aura_radius
end

function modifier_vihor_innate:GetAuraEntityReject( hEntity )
	return not hEntity:CanEntityBeSeenByMyTeam(self:GetCaster())
end
--------------------------------------------------------------------------------

function modifier_vihor_innate:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_vihor_innate:OnRefresh( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
modifier_vihor_innate_effect = class({})
--------------------------------------------------------------------------------

function modifier_vihor_innate_effect:IsDebuff()
	return true
end

function modifier_vihor_innate_effect:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function modifier_vihor_innate_effect:GetAuraEntityReject( hEntity )
	return not hEntity:CanEntityBeSeenByMyTeam(self:GetCaster())
end
--------------------------------------------------------------------------------

function modifier_vihor_innate_effect:OnCreated( kv )
	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
end

function modifier_vihor_innate_effect:OnRefresh( kv )
	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
end

--------------------------------------------------------------------------------

function modifier_vihor_innate_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}

	return funcs
end

function modifier_vihor_innate_effect:GetModifierHealthBonus( params )
	if self:GetParent():GetUnitName() == "npc_dota_hero_skeleton_king" then
		self.hp = self.bonus_hp * self:GetParent():GetMaxHealth() * 0.01
		if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			return -self.hp
		end
		return self.hp
	end
	return 0
end

--------------------------------------------------------------------------------
