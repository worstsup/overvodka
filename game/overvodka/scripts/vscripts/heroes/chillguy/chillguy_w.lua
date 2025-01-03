chillguy_w = class({})
LinkLuaModifier( "modifier_chillguy_w", "heroes/chillguy/modifier_chillguy_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_w_debuff", "heroes/chillguy/modifier_chillguy_w_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_w_shard", "heroes/chillguy/modifier_chillguy_w_shard", LUA_MODIFIER_MOTION_NONE )
function chillguy_w:OnSpellStart()
	local caster = self:GetCaster()
end
function chillguy_w:OnToggle()
	local caster = self:GetCaster()
	local toggle = self:GetToggleState()
	if toggle then
		self.modifier = caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_chillguy_w", -- modifier name
			{  } -- kv
		)
	else
		if self.modifier and not self.modifier:IsNull() then
			self.modifier:Destroy()
		end
		self.modifier = nil
	end
end