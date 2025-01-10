modifier_snapfire_lil_shredder_lua_debuff = class({})

--------------------------------------------------------------------------------
function modifier_snapfire_lil_shredder_lua_debuff:IsHidden()
	return false
end

function modifier_snapfire_lil_shredder_lua_debuff:IsDebuff()
	return true
end

function modifier_snapfire_lil_shredder_lua_debuff:IsStunDebuff()
	return false
end

function modifier_snapfire_lil_shredder_lua_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
function modifier_snapfire_lil_shredder_lua_debuff:OnCreated( kv )
	if not IsServer() then return end
	if self:GetAbility() and self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.slow = - (self:GetAbility():GetOrbSpecialValueFor( "attack_speed_slow_per_stack", "e" ) )
	else
		self.slow = -3
	end
	self:SetStackCount( 1 )
end

function modifier_snapfire_lil_shredder_lua_debuff:OnRefresh( kv )
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_snapfire_lil_shredder_lua_debuff:OnRemoved()
end

function modifier_snapfire_lil_shredder_lua_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
function modifier_snapfire_lil_shredder_lua_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end

function modifier_snapfire_lil_shredder_lua_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self:GetStackCount() * 3
end
function modifier_snapfire_lil_shredder_lua_debuff:GetModifierMagicalResistanceBonus()
	return -self:GetStackCount() * 3
end

--------------------------------------------------------------------------------
function modifier_snapfire_lil_shredder_lua_debuff:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_snapfire_lil_shredder_lua_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end