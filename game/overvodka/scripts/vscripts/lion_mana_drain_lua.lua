lion_mana_drain_lua = class({})
LinkLuaModifier( "modifier_lion_mana_drain_lua", "modifier_lion_mana_drain_lua.lua", LUA_MODIFIER_MOTION_NONE )

lion_mana_drain_lua.modifiers = {}
function lion_mana_drain_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then
		return
	end
	local duration = self:GetSpecialValueFor("duration") + 0.1
	local modifier = target:AddNewModifier(
		caster,
		self,
		"modifier_lion_mana_drain_lua",
		{ duration = duration }
	)
	self.modifiers[modifier] = true
	self.sound_cast = "hehe"
	EmitSoundOn( self.sound_cast, caster )
end

function lion_mana_drain_lua:Unregister( modifier )
	self.modifiers[modifier] = nil
	local counter = 0
	for modifier,_ in pairs(self.modifiers) do
		if not modifier:IsNull() then
			counter = counter+1
		end
	end
end