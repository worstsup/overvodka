sasavot_shard = class({})
LinkLuaModifier( "modifier_sasavot_shard", "heroes/sasavot/modifier_sasavot_shard", LUA_MODIFIER_MOTION_NONE )

function sasavot_shard:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor( "duration" )
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_sasavot_shard", -- modifier name
		{ duration = duration } -- kv
	)
end