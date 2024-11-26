modifier_shadow_fiend_presence_of_the_dark_lord_lua = class({})
--------------------------------------------------------------------------------

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:IsDebuff()
	return true
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:IsHidden()
	return true
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:IsAura()
	return true
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetModifierAura()
	return "modifier_shadow_fiend_presence_of_the_dark_lord_lua"
end


function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end


function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetAuraRadius()
	return self.aura_radius
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetAuraEntityReject( hEntity )
	return not hEntity:CanEntityBeSeenByMyTeam(self:GetCaster())
end
--------------------------------------------------------------------------------

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "presence_radius" )
	self.armor_reduction = self:GetAbility():GetSpecialValueFor( "presence_armor_reduction" )
	self.mag = self:GetAbility():GetSpecialValueFor( "mag" )
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:OnRefresh( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "presence_radius" )
	self.armor_reduction = self:GetAbility():GetSpecialValueFor( "presence_armor_reduction" )
	self.mag = self:GetAbility():GetSpecialValueFor( "mag" )
end

--------------------------------------------------------------------------------

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetModifierPhysicalArmorBonus( params )
	if self:GetParent():GetUnitName() == "npc_dota_hero_axe" then
		return self.armor_reduction
	end
	return 0
end

function modifier_shadow_fiend_presence_of_the_dark_lord_lua:GetModifierMagicalResistanceBonus( params )
	if self:GetParent():GetUnitName() == "npc_dota_hero_axe" then
		return self.mag
	end
	return 0
end
--------------------------------------------------------------------------------
