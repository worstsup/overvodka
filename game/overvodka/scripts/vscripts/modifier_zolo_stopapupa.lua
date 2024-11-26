-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_zolo_stopapupa = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_zolo_stopapupa:IsHidden()
	return false
end

function modifier_zolo_stopapupa:IsDebuff()
	return true
end

function modifier_zolo_stopapupa:IsStunDebuff()
	return false
end

function modifier_zolo_stopapupa:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_zolo_stopapupa:OnCreated( kv )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	-- Play effects
	self:PlayEffects()
end

function modifier_zolo_stopapupa:OnRefresh( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	-- Play effects
	self:PlayEffects()
end

function modifier_zolo_stopapupa:OnRemoved()
end

function modifier_zolo_stopapupa:OnDestroy()
end
function modifier_zolo_stopapupa:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_zolo_stopapupa:GetModifierPhysicalArmorBonus()
	return -self.armor
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------


function modifier_zolo_stopapupa:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf"
	Chance = RandomInt(1,5)
	if Chance == 1 then
		EmitSoundOn( "mayas", self:GetParent() )
	elseif Chance == 2 then
		EmitSoundOn( "stopapupa", self:GetParent() )
	elseif Chance == 3 then
		EmitSoundOn( "nizkaya", self:GetParent() )	
	elseif Chance == 4 then
		EmitSoundOn( "raif", self:GetParent() )
	elseif Chance == 5 then
		EmitSoundOn( "snadom", self:GetParent() )	
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end