silvername_shard = class({})
LinkLuaModifier( "modifier_silvername_shard", "heroes/silvername/silvername_shard", LUA_MODIFIER_MOTION_NONE )

function silvername_shard:OnSpellStart()
	EmitSoundOn( "orlov", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_silvername_shard", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_silvername_shard = class({})

function modifier_silvername_shard:IsPurgable()
	return false
end

function modifier_silvername_shard:OnCreated( kv )
end

function modifier_silvername_shard:OnRemoved()
end

function modifier_silvername_shard:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end