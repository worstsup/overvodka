sahur_q = class({})

LinkLuaModifier( "modifier_sahur_q", "heroes/sahur/sahur_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_sahur_facet_bonus", "heroes/sahur/sahur_q", LUA_MODIFIER_MOTION_NONE)

function sahur_q:Precache( context )
	PrecacheResource( "soundfile", "soundevents/prov.vsndevts", context )
end

function sahur_q:GetIntrinsicModifierName()
	if self:GetSpecialValueFor("has_facet") == 1 then
		return "modifier_sahur_facet_bonus"
	end
end

function sahur_q:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	EmitSoundOn( "prov", caster )
	local bonusDuration = 0
	if caster:HasModifier("modifier_sahur_facet_bonus") then
		bonusDuration = caster:FindModifierByName("modifier_sahur_facet_bonus"):GetStackCount() * self:GetSpecialValueFor("duration_increase")
	end
	local finalDuration = self:GetSpecialValueFor("duration") + bonusDuration
	caster:AddNewModifier( caster, self, "modifier_sahur_q", { duration = finalDuration } )
end

modifier_sahur_q = class({})

function modifier_sahur_q:IsPurgable()
	return false
end

function modifier_sahur_q:OnCreated( kv )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_agility = self:GetAbility():GetSpecialValueFor( "bonus_agility" )
	self.agility = self:GetParent():GetAgility() * self.bonus_agility * 0.01
	self.scepter = self:GetCaster():HasScepter()
	if self.scepter then
		self.model_scale = self.model_scale - 10
	end
	self.has_facet = (self:GetAbility():GetSpecialValueFor("has_facet") == 1)
end

function modifier_sahur_q:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	return funcs
end

function modifier_sahur_q:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_UNSELECTABLE] = self.scepter,
	}
	return state
end
function modifier_sahur_q:OnHeroKilled(params)
    if not IsServer() then return end
    local parent = self:GetParent()
	if not parent:IsRealHero() or parent:IsIllusion() then return end
    if params.target:GetTeamNumber() == parent:GetTeamNumber() then return end
	if not self.has_facet then return end
    if params.attacker ~= parent then return end
	if not params.target or not params.target:IsRealHero() or params.target:IsIllusion() then return end
    local bonusMod = parent:FindModifierByName("modifier_sahur_facet_bonus")
    if bonusMod then
        bonusMod:IncrementStackCount()
    end
end

function modifier_sahur_q:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_sahur_q:GetModifierMoveSpeedBonus_Percentage( params )
	return self.move_speed
end

function modifier_sahur_q:GetModifierBonusStats_Agility( params )
	return self.agility
end

modifier_sahur_facet_bonus = class({})

function modifier_sahur_facet_bonus:IsHidden()
	if self:GetStackCount() > 0 then
    	return false
	else
		return true
	end
end

function modifier_sahur_facet_bonus:IsPurgable()
    return false
end

function modifier_sahur_facet_bonus:RemoveOnDeath()
    return false
end

function modifier_sahur_facet_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_sahur_facet_bonus:OnTooltip()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("duration_increase")
end