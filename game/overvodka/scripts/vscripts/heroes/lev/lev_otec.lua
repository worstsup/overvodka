LinkLuaModifier( "modifier_otec", "heroes/lev/lev_otec", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_otec_start", "heroes/lev/lev_otec", LUA_MODIFIER_MOTION_NONE )
Lev_Otec = class({})

function Lev_Otec:Precache(context)
	PrecacheResource( "soundfile", "soundevents/lev_r_start.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/lev_r.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start.vpcf", context )
end

function Lev_Otec:OnSpellStart()
	if not IsServer() then return end
	EmitGlobalSound( "lev_r_start" )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_otec_start", { duration = self:GetSpecialValueFor("duration") } )
	self:EndCooldown()
end

modifier_otec_start = class({})

function modifier_otec_start:IsPurgable() return false end
function modifier_otec_start:RemoveOnDeath() return true end

function modifier_otec_start:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( particle )
	self:GetParent():GiveMana( 300 )
	for i = 1, 6 do
		local ability = self:GetParent():GetAbilityByIndex(i)
		if ability then
			local lev_ability = self:GetParent():FindAbilityByName(ability:GetAbilityName())
			lev_ability:SetActivated(false)
		end
	end
end

function modifier_otec_start:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
	}
end

function modifier_otec_start:OnDestroy()
	if not IsServer() then return end
	for i = 1, 6 do
		local ability = self:GetParent():GetAbilityByIndex(i)
		if ability then
			local lev_ability = self:GetParent():FindAbilityByName(ability:GetAbilityName())
			lev_ability:SetActivated(true)
		end
	end
	self:GetAbility():UseResources( false, false, false, true )
end

function modifier_otec_start:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_otec_start:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor( "move_speed_start" )
end

function modifier_otec_start:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_otec_start:GetModifierInvisibilityLevel()
	return 2
end

function modifier_otec_start:OnAbilityFullyCast( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		if params.ability~=self:GetParent():GetAbilityByIndex(0) then return end
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_otec", { duration = self:GetAbility():GetSpecialValueFor("duration") } )
		EmitSoundOn( "lev_r", self:GetParent() )
		self:Destroy()
	end
end

modifier_otec = class({})

function modifier_otec:IsPurgable() return false end

function modifier_otec:DeclareFunctions()
	return	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_otec:GetModifierModelScale()
	return self:GetAbility():GetSpecialValueFor( "model_scale" )
end

function modifier_otec:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor( "bonus_strength" )
end

function modifier_otec:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor( "move_speed" )
end

function modifier_otec:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor( "bonus_agility" )
end