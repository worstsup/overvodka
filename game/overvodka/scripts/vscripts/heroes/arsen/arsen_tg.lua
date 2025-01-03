arsen_tg = class({})
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_arsen_tg", "heroes/arsen/modifier_arsen_tg", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_tg_blocker", "heroes/arsen/modifier_arsen_tg_blocker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_tg_thinker", "heroes/arsen/modifier_arsen_tg_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_tg_wall_aura", "heroes/arsen/modifier_arsen_tg_wall_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_tg_spear_aura", "heroes/arsen/modifier_arsen_tg_spear_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arsen_tg_projectile_aura", "heroes/arsen/modifier_arsen_tg_projectile_aura", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function arsen_tg:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
function arsen_tg:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_arsen_tg_thinker", -- modifier name
		{  }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
end

--------------------------------------------------------------------------------
arsen_tg.projectiles = {}
function arsen_tg:OnProjectileHitHandle( target, location, id )
	local data = self.projectiles[id]
	self.projectiles[id] = nil

	if data.destroyed then return end

	local attacker = EntIndexToHScript( data.entindex_source_const )
	attacker:PerformAttack( target, true, true, true, true, false, false, true )
end