dark_willow_bedlam_lua = class({})
LinkLuaModifier( "modifier_wisp_ambient", "modifier_wisp_ambient.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bedlam_lua", "modifier_dark_willow_bedlam_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_willow_bedlam_lua_attack", "modifier_dark_willow_bedlam_lua_attack.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function dark_willow_bedlam_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "roaming_duration" )

	-- add buff
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dark_willow_bedlam_lua", -- modifier name
		{ duration = duration } -- kv
	)

end
--------------------------------------------------------------------------------
-- Projectile
function dark_willow_bedlam_lua:OnProjectileHit_ExtraData( target, location, ExtraData )
	-- destroy effect projectile
	local effect_cast = ExtraData.effect
	ParticleManager:DestroyParticle( effect_cast, false )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	if not target then return end

	-- damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = ExtraData.damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
end