-------------------------
-- UNDYING FLESH GOLEM --
-------------------------

imba_undying_flesh_golem = imba_undying_flesh_golem or class({})
LinkLuaModifier( "modifier_imba_undying_flesh_golem", "modifier_imba_undying_flesh_golem.lua", LUA_MODIFIER_MOTION_NONE )
function imba_undying_flesh_golem:OnSpellStart()
	self:GetCaster():EmitSound("pubg")
	
	self:GetCaster():StartGesture(ACT_DOTA_SPAWN)
	
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_flesh_golem", {duration = self:GetSpecialValueFor("duration")})
end
