gunnar_bash = class({})
LinkLuaModifier( "modifier_gunnar_bash", "heroes/nix/modifier_gunnar_bash", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_armor", "modifier_generic_armor", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function gunnar_bash:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf", context )
end

function gunnar_bash:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function gunnar_bash:GetIntrinsicModifierName()
	return "modifier_gunnar_bash"
end