-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_faceless_void_chronosphere_lua_thinker = class({})

--------------------------------------------------------------------------------
-- Initializations
function modifier_faceless_void_chronosphere_lua_thinker:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_faceless_void_chronosphere_lua_thinker:OnRefresh( kv )
	
end

function modifier_faceless_void_chronosphere_lua_thinker:OnRemoved()
end

function modifier_faceless_void_chronosphere_lua_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_faceless_void_chronosphere_lua_thinker:CheckState()
	local state = {
		[MODIFIER_STATE_FROZEN] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_faceless_void_chronosphere_lua_thinker:IsAura()
	return true
end

function modifier_faceless_void_chronosphere_lua_thinker:GetModifierAura()
	return "modifier_faceless_void_chronosphere_lua_effect"
end

function modifier_faceless_void_chronosphere_lua_thinker:GetAuraRadius()
	return self.radius
end

function modifier_faceless_void_chronosphere_lua_thinker:GetAuraDuration()
	return 0.01
end

function modifier_faceless_void_chronosphere_lua_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_faceless_void_chronosphere_lua_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_faceless_void_chronosphere_lua_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_faceless_void_chronosphere_lua_thinker:GetAuraEntityReject( hEntity )
	if IsServer() then
		-- -- reject if owner
		-- if hEntity==self:GetCaster() then return true end

		-- -- reject if owner controlled
		-- if hEntity:GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end

		-- reject if unit is named faceless void
		if hEntity:GetUnitName()=="npc_dota_faceless_void" then return true end
	end

	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
