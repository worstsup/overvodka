mellstroy_business_new = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mellstroy_business_new", "heroes/mellstroy/modifier_mellstroy_business_new", LUA_MODIFIER_MOTION_NONE )

function mellstroy_business_new:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

function mellstroy_business_new:OnSpellStart()
end

function mellstroy_business_new:OnOrbImpact( params )
	if self:GetCaster():PassivesDisabled() then return end
	local duration = self:GetSpecialValueFor( "duration" )
	local gold_cost = self:GetSpecialValueFor( "gold_cost" )
	local percent = self:GetSpecialValueFor( "percent" )
	local player_id = self:GetCaster():GetPlayerID()
	local gold = PlayerResource:GetGold(player_id)
	local damage = gold_cost + percent * 0.01 * gold
	if gold < damage  then
		ability:EndCooldown()
		return
	end
	PlayerResource:SpendGold(player_id, damage, 4)
	local sound_cast = "biznes"
	EmitSoundOn( sound_cast, self:GetCaster() )
	if self:GetCaster():HasScepter() then
		damage = damage * 1.5
	end
	ApplyDamage({attacker = self:GetCaster(), victim = params.target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PURE})
	if params.target and not params.target:IsNull() then
		params.target:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_mellstroy_business_new",
			{ duration = duration }
		)
	end
end