modifier_serega_song_scepter = class({})

function modifier_serega_song_scepter:IsHidden()
	return true
end
function modifier_serega_song_scepter:IsDebuff()
	return false
end
function modifier_serega_song_scepter:IsPurgable()
	return false
end
function modifier_serega_song_scepter:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_serega_song_scepter:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen_rate" )
	self.regen_self = self:GetAbility():GetSpecialValueFor( "regen_rate_self" )
	if not IsServer() then return end
end

function modifier_serega_song_scepter:OnRefresh( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen_rate" )
	self.regen_self = self:GetAbility():GetSpecialValueFor( "regen_rate_self" )
	if not IsServer() then return end	
end

function modifier_serega_song_scepter:OnRemoved()
end

function modifier_serega_song_scepter:OnDestroy()
end

function modifier_serega_song_scepter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end

function modifier_serega_song_scepter:GetModifierHealthRegenPercentage()
	if self:GetParent()==self:GetCaster() then
		return self.regen_self
	end
	return self.regen
end

function modifier_serega_song_scepter:IsAura()
	return self:GetParent()==self:GetCaster()
end

function modifier_serega_song_scepter:GetModifierAura()
	return "modifier_serega_song_scepter"
end

function modifier_serega_song_scepter:GetAuraRadius()
	return self.radius
end

function modifier_serega_song_scepter:GetAuraDuration()
	return 0.4
end

function modifier_serega_song_scepter:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_serega_song_scepter:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_serega_song_scepter:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_serega_song_scepter:GetAuraEntityReject( hEntity )
	return false
end