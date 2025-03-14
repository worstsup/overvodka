LinkLuaModifier( "modifier_otec", "lev_otec", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_otec_start", "lev_otec", LUA_MODIFIER_MOTION_NONE )
Lev_Otec = class({})

function Lev_Otec:Precache(context)
	PrecacheResource( "soundfile", "soundevents/lev_r_start.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/lev_r.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start.vpcf", context )
end

function Lev_Otec:OnSpellStart()
	if not IsServer() then return end
	EmitGlobalSound( "lev_r_start" )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_otec_start", { duration = -1 } )
	self:EndCooldown()
end

modifier_otec_start = class({})

function modifier_otec_start:IsPurgable()
	return false
end
function modifier_otec_start:RemoveOnDeath()
	return true
end

function modifier_otec_start:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( particle )
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
	self.move_speed_start = self:GetAbility():GetSpecialValueFor( "move_speed_start" )
	self:GetParent():GiveMana( 300 )  
	self:GetParent():GetAbilityByIndex(0):EndCooldown()
	for i = 1, 6 do
		local ability = self:GetParent():GetAbilityByIndex(i)
		if ability then
			local lev_ability = self:GetParent():FindAbilityByName(ability:GetAbilityName())
			lev_ability:SetActivated(false)
		end
	end
end

function modifier_otec_start:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
	}
	return state
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
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_otec_start:GetModifierMoveSpeed_Absolute()
	return self.move_speed_start
end

function modifier_otec_start:GetModifierBonusStats_Intellect( params )
	return self.bonus_intellect
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

function modifier_otec:IsPurgable()
	return false
end

function modifier_otec:OnCreated()
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.bonus_agility = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_lion" then
		local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_enigma_2")
		if Talented:GetLevel() == 1 then
			self.bonus_agility = self.bonus_agility + 150
		end
	end
end

function modifier_otec:OnRemoved()
end

function modifier_otec:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return funcs
end

function modifier_otec:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_otec:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_otec:GetModifierMoveSpeed_Limit( params )
	return self.move_speed
end

function modifier_otec:GetModifierBonusStats_Agility( params )
	return self.bonus_agility
end