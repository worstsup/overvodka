ashab_dogon = class({})
LinkLuaModifier( "modifier_ashab_dogon", "heroes/ashab/modifier_ashab_dogon", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_ashab_dogon_debuff", "heroes/ashab/modifier_ashab_dogon_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_magresist", "modifier_magresist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_BOTH )


function ashab_dogon:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/primal_beast/primal_beast_2022_prestige/primal_beast_2022_prestige_onslaught_charge_mesh.vpcf", context )
	PrecacheResource( "particle", "particles/spirit_breaker_charge_target_new.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context )
end

function ashab_dogon:Spawn()
	if not IsServer() then return end
end


function ashab_dogon:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_ashab_dogon", -- modifier name
		{ target = target:entindex() } -- kv
	)
end