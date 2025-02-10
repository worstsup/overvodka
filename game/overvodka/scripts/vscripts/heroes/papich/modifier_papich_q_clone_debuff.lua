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
modifier_papich_q_clone_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_papich_q_clone_debuff:IsHidden()
	return false
end

function modifier_papich_q_clone_debuff:IsDebuff()
	return true
end

function modifier_papich_q_clone_debuff:IsStunDebuff()
	return false
end

function modifier_papich_q_clone_debuff:IsPurgable()
	return false
end

function modifier_papich_q_clone_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_papich_q_clone_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.radius = kv.radius

	self.leash = self:GetParent():AddNewModifier(
		self:GetCaster(), -- player source
		self:GetAbility(), -- ability source
		"modifier_generic_leashed_lua", -- modifier name
		kv -- kv
	)
	self.leash:SetEndCallback(function()
		-- destroy this modifier when leash ends
		if self:IsNull() then return end
		self.leash = nil
		self:Destroy()
	end)

	-- play effects
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_papich_q_clone_debuff:OnRefresh( kv )
end

function modifier_papich_q_clone_debuff:OnRemoved()
end

function modifier_papich_q_clone_debuff:OnDestroy()
	if not IsServer() then return end
	-- destroy leash modifier
	if self.leash and not self.leash:IsNull() then
		self.leash:Destroy()
	end

	local sound_cast = "papich_q_clone_success"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_papich_q_clone_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_papich_q_clone_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_papich_q_clone_debuff:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/slark_ti6_pounce_ground_new.vpcf"
	local sound_cast = "papich_q_clone_success"

	local caster = self:GetCaster()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		caster,
		PATTACH_WORLDORIGIN,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_papich_q_clone_debuff:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/slark_ti6_pounce_leash_new.vpcf"

	local caster = self:GetCaster()
	local parent = self:GetParent()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetParent():GetOrigin() )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end