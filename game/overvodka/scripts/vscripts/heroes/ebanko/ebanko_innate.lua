ebanko_innate = class({})
LinkLuaModifier( "modifier_ebanko_innate", "heroes/ebanko/ebanko_innate", LUA_MODIFIER_MOTION_NONE )

function ebanko_innate:GetIntrinsicModifierName()
	return "modifier_ebanko_innate"
end

modifier_ebanko_innate = class({})

function modifier_ebanko_innate:IsHidden()
	return false
end
function modifier_ebanko_innate:IsDebuff()
	return false
end
function modifier_ebanko_innate:IsPurgable()
	return false
end

function modifier_ebanko_innate:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "steal_range" )
	self.steal = 1
	if not IsServer() then return end
end

function modifier_ebanko_innate:OnRefresh( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "steal_range" )
	self.steal = 1
	if not IsServer() then return end
end

function modifier_ebanko_innate:OnRemoved()
end

function modifier_ebanko_innate:OnDestroy()
end

function modifier_ebanko_innate:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
	}
	return funcs
end

function modifier_ebanko_innate:OnHeroKilled( params )
	if not IsServer() then return end
	if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end
	if params.attacker==self:GetParent() then
		self:Steal( params.target )
		return
	end
	local distance = (params.target:GetOrigin()-self:GetParent():GetOrigin()):Length2D()
	if distance<=self.radius then
		self:Steal( params.target )
	end
end

function modifier_ebanko_innate:Steal( target )
	local steal = self.steal
	self:GetParent():ModifyStrength(steal)
	self:SetStackCount( self:GetStackCount() + steal )
end