snapfire_lil_shredder_lua = class({})
LinkLuaModifier( "modifier_snapfire_lil_shredder_lua", "modifier_snapfire_lil_shredder_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_lil_shredder_lua_debuff", "modifier_snapfire_lil_shredder_lua_debuff.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function snapfire_lil_shredder_lua:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetDuration()
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_snapfire_lil_shredder_lua", -- modifier name
		{ duration = duration } -- kv
	)
end